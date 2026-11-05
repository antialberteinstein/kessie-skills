---
name: disk-cleanup
description: >
  Safe, interactive macOS disk-space cleanup. Scans home, Library,
  /opt, /Library and extra APFS volumes; classifies into regenerable
  cache vs orphan app data vs dev artifacts vs personal data; always
  confirms before deleting and never touches personal files. TRIGGER
  when the user asks to free up disk space, find large/redundant files,
  clean caches, or "máy hết dung lượng / dọn ổ đĩa".
---

# Disk Cleanup (macOS)

## When to Use
User wants to reclaim disk space or audit what is consuming it.
Not for deleting specific known files (just do that directly).

## Core Principles (non-negotiable)
1. **Investigate before touching.** Every run starts read-only:
   `df -h`, `du -sh <dir>/* | sort -rh`, `find ... -size +`.
2. **Never delete without classifying first.** Map every large item
   into one bucket (below) and report it before any `rm`.
3. **Confirm destructive actions.** Irreversible or >1 GB or ambiguous
   → ask the user (AskUserQuestion) and quote what will be deleted.
   Run one consolidated delete per confirmed group, then verify.
4. **Never touch personal data or Downloads** unless the user names
   the exact file. Pictures, Documents, theses, media = off-limits.
5. **Report reclaimed space** with `df` before/after every group.

## Classification Buckets

| Bucket | Examples | Action |
|---|---|---|
| 🟢 Regenerable cache | `~/.npm/_cacache`, `~/.cache/{uv,puppeteer,torch}`, `~/.gradle/caches`, `~/.m2/repository`, `~/Library/Caches/*`, conda `pkgs`, `brew cleanup` | Safe to delete after a heads-up |
| ⚪ Clear junk | `*.ShipIt` updater leftovers, 0-byte files, empty dirs | Safe to delete |
| 🔴 Data of uninstalled apps | `Application Support/`, `Containers/`, `Group Containers/` entries with **no matching app** | Delete after confirm |
| 🔵 Dev artifacts | `node_modules`, `.venv`, `venv`, `build`, `dist`, `target`, `.gradle`, `__pycache__`, `.next` | Delete after confirm (regenerable) |
| 🟠 Large model / app data | `*.gguf`, `~/.ollama/models`, `Docker.raw`, app data of *installed* apps | User decides per item |
| ⛔ Personal / system | Pictures, Documents, symlinks, `/System`, `/bin`, `~/.ssh` | Never delete |

## Procedure

### 1. Scan
- `df -h /Users/$USER` and the data volume; `du -sh ~/* ~/.* | sort -rh`.
- Also check `~/Library/{Application Support,Containers,Group Containers,Caches}`,
  `/Applications`, `/opt`, `/Library`, and any `/Volumes/*` data disks.
- Large single files: `find <root> -type f -size +150M`.

### 2. Identify uninstalled-app data
- App list: `ls /Applications ~/Applications | sed 's/\.app$//'`.
- For each non-`com.apple.*`, non-daemon folder in app-data dirs,
  flag those with no matching installed app. **Exclude macOS system
  services** (`com.apple.*`, lowercase daemons like `contactsd`).

### 3. Dev artifacts & repos (on code volumes)
- `find <code> -type d \( -name node_modules -o -name .venv ... \) -prune`.
- For `.git` bloat: **check the remote and working tree first.**
  - Upstream clone (e.g. remote is the official project, no local
    unpushed commits) → `.git` safe to delete.
  - **User's own fork** (remote under the user's account) or
    **uncommitted changes present** → DO NOT delete; ask the user.
- `.gguf`/model weights → list, let user pick (often "keep folder X").

### 4. Confirm → Delete → Verify
- Present facts (what / size / rollback) per group; get confirmation.
- One consolidated `rm` per group; then re-check the paths exist/gone
  and re-run `df`.

## macOS Gotchas (learned the hard way)
- `/` is **SIP read-only**. `/System`, `/bin`, `/usr` are not cleanup
  targets and cannot be written even with sudo.
- **Sandbox containers** (`Containers`, `Group Containers`) are
  recreated empty by `containermanagerd` — may need a second pass;
  a tiny leftover skeleton is normal and harmless.
- **Running apps recreate caches.** Brave/Chrome/Docker rebuild a
  small skeleton while open — the bulk is still freed.
- **`Docker.raw` is sparse**: `ls -lh` shows a huge apparent size,
  `du -h` shows real usage. **Never delete it while Docker runs** —
  quit Docker Desktop, confirm with `lsof Docker.raw`, then delete;
  it is recreated empty on next launch.
- Conda `du` on `pkgs` overcounts (hardlinks into envs). Use
  `conda clean --all -y`; don't `rm` the pkgs dir.
- `__Main_disk__`/`__Data_disk__`-style entries are often **symlinks**
  (0 B). Verify with `ls -la`; never `rm -rf` a symlink target.
- `/Library/Updates`, `/opt` content is root-owned → needs `sudo`;
  flag rather than silently skip.

## Examples
- "Máy hết dung lượng, dọn giúp" → full scan, classified report,
  delete 🟢/⚪ after heads-up, ask before 🔴/🔵/🟠.
- "Có app data nào của app không cài không?" → step 2 only, list, then
  delete on confirm.
- "Dọn rác lập trình trong /Volumes/Data" → step 3, protect user forks.
