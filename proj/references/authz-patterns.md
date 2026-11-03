# Mẫu phân quyền theo nền tảng

## Postgres / Supabase (RLS)

```sql
begin;
create table public.items (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 category_id uuid not null,
 amount bigint not null check (amount > 0),
 created_at timestamptz default clock_timestamp(),
 unique(owner_id, id),
 foreign key(owner_id, category_id) references public.categories(owner_id, id)  -- chặn tham chiếu chéo
);
alter table public.items enable row level security;
create policy own_items on public.items for all to authenticated
 using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);

create function public.keep_created_at() returns trigger language plpgsql set search_path = '' as $$
begin
 if tg_op = 'INSERT' then new.created_at = pg_catalog.clock_timestamp(); else new.created_at = old.created_at; end if;
 return new;
end $$;
create trigger items_created_at before insert or update on public.items for each row execute function public.keep_created_at();
revoke execute on function public.keep_created_at() from public;
grant select, insert, update, delete on public.items to authenticated;
commit;
```

Test (chạy trên Postgres cô lập, sau khi bootstrap giả lập `auth.users`, `auth.uid()` đọc từ `request.jwt.claim.sub`, và các role `authenticated`/`anon`):

```sql
\set ON_ERROR_STOP on
begin;
-- seed 2 users + categories
set local role authenticated;
set local request.jwt.claim.sub = '<owner-uuid>';
do $$ begin
  -- insert hợp lệ; rồi: if (select count(*) from public.items) <> 1 then raise exception '...'; end if;
  -- tham chiếu category của user khác → expect foreign_key_violation
end $$;
set local request.jwt.claim.sub = '<other-uuid>';
do $$ begin
  if exists(select 1 from public.items) then raise exception 'Other user can read'; end if;
end $$;
reset role; set local role anon;
do $$ begin perform 1 from public.items; raise exception 'Anon can read';
exception when insufficient_privilege then null; end $$;
reset role; rollback;
\echo 'items authz passed'
```

Lưu ý: PostgREST upsert chạy BEFORE INSERT rồi BEFORE UPDATE khi có conflict, nên trigger giữ `created_at` phải xử lý cả hai.

## Firebase (Firestore Security Rules)

```
match /users/{uid}/items/{itemId} {
  allow read, delete: if request.auth != null && request.auth.uid == uid;
  allow create, update: if request.auth != null && request.auth.uid == uid
    && request.resource.data.amount is int && request.resource.data.amount > 0
    && exists(/databases/$(database)/documents/users/$(uid)/categories/$(request.resource.data.categoryId))
    && (resource == null || request.resource.data.createdAt == resource.data.createdAt);
}
```

Test bằng `@firebase/rules-unit-testing` trên Emulator Suite: chủ sở hữu được phép; user khác bị từ chối; chưa đăng nhập bị từ chối; dữ liệu sai kiểu bị từ chối; `createdAt` không sửa được.

## Backend riêng (REST/RPC)

- Middleware xác thực gắn `userId` vào context. **Mọi truy vấn** có điều kiện `where owner_id = :userId`, đóng gói trong repository để không thể quên.
- Ràng buộc DB như trên (FK ghép, check). Không tin `owner_id` client gửi lên, luôn lấy từ token.
- Test API: 401 khi thiếu token; 404 (không phải 403, tránh lộ sự tồn tại) khi truy cập bản ghi của người khác; 422 khi dữ liệu sai.

## Danh sách test phân quyền tối thiểu (mọi nền tảng)

- [ ] Chủ sở hữu: tạo, đọc, sửa, xoá được.
- [ ] Người khác: không đọc, sửa, xoá được bản ghi của chủ sở hữu.
- [ ] Không tạo được bản ghi trỏ tới tài nguyên của người khác.
- [ ] Ẩn danh: bị từ chối.
- [ ] Ràng buộc nghiệp vụ chặn dữ liệu sai ở tầng dữ liệu.
- [ ] Trường bất biến (created_at, owner) không đổi được qua update hoặc upsert.
- [ ] Hàm hoặc endpoint đặc quyền: chỉ vai trò được phép gọi được.

## Nhiều người dùng chung dữ liệu (team / tổ chức / tenant)

Dữ liệu thuộc về tổ chức, không thuộc về từng người. Quyền đọc và ghi đi theo **membership** và vai trò.

```sql
begin;
create table public.orgs (id uuid primary key default gen_random_uuid(), name text not null);
create table public.memberships (
 org_id uuid not null references public.orgs(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 role text not null check (role in ('owner','admin','member')),
 primary key (org_id, user_id)
);
create table public.projects (
 id uuid primary key default gen_random_uuid(),
 org_id uuid not null references public.orgs(id) on delete cascade,
 name text not null
);
-- Security definer helpers avoid recursive RLS on memberships.
create function public.is_member(target uuid) returns boolean language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.memberships m where m.org_id = target and m.user_id = (select auth.uid()))
$$;
create function public.has_role(target uuid, roles text[]) returns boolean language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.memberships m where m.org_id = target and m.user_id = (select auth.uid()) and m.role = any(roles))
$$;
revoke execute on function public.is_member(uuid), public.has_role(uuid, text[]) from public;
grant execute on function public.is_member(uuid), public.has_role(uuid, text[]) to authenticated;
alter table public.orgs enable row level security;
alter table public.memberships enable row level security;
alter table public.projects enable row level security;
create policy org_read on public.orgs for select to authenticated using (public.is_member(id));
create policy membership_read on public.memberships for select to authenticated using (public.is_member(org_id));
create policy membership_manage on public.memberships for all to authenticated
 using (public.has_role(org_id, array['owner','admin'])) with check (public.has_role(org_id, array['owner','admin']));
create policy project_read on public.projects for select to authenticated using (public.is_member(org_id));
create policy project_write on public.projects for insert to authenticated with check (public.is_member(org_id));
create policy project_update on public.projects for update to authenticated using (public.is_member(org_id)) with check (public.is_member(org_id));
create policy project_delete on public.projects for delete to authenticated using (public.has_role(org_id, array['owner','admin']));
grant select, insert, update, delete on public.orgs, public.memberships, public.projects to authenticated;
commit;
```

Test bắt buộc thêm: thành viên đọc được dữ liệu tổ chức của mình · **người ngoài tổ chức không thấy gì** · member không xoá được (chỉ owner/admin) · member không tự nâng vai trò · không chuyển được bản ghi sang tổ chức mình không thuộc về (`with check`) · rời tổ chức thì mất quyền ngay. Tạo tổ chức kèm membership owner đầu tiên nên dùng một RPC (security definer) để thao tác nguyên tử.

Firebase: lưu `members/{uid}: role` trong document tổ chức, rule kiểm tra `get(/databases/$(database)/documents/orgs/$(orgId)).data.members[request.auth.uid]`. Backend riêng: middleware nạp membership, truy vấn luôn lọc theo `org_id` lấy từ membership, không lấy từ dữ liệu client gửi lên.
