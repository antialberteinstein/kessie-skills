---
name: agy-delegate
description: Orchestrate the Antigravity CLI (agy) as a sub-agent. Claude plans, defines acceptance tests and benchmarks up front, and makes the final call; agy implements each task via `agy -p` and handoff documents in .handoff/. Use this skill whenever the user mentions agy, Antigravity, "delegate to agy", "let agy do it", wants Claude to work alongside Gemini/Antigravity, wants to split work between two agents, or wants another agent to implement or review code — even if they never say "skill". Also use it when the project already has a .handoff/ folder or a CLAUDE.md with an agy-delegate section.
---

# Delegating to agy (Antigravity CLI)

Claude is the orchestrator: understands the request, splits it into tasks, defines what
"done" means in tests and benchmarks, reviews, and decides.
agy is the implementer: takes one well-scoped task, does it, and reports.

The files in `.handoff/` are the contract between the two and their shared memory. agy can
start a fresh session at any time and still have full context, because everything it needs
is written down.

## 1. Don't pre-check — the first real call is the check

Don't run `which agy`, `agy --version`, or a separate ping. Delegate the real task; the result
of that call tells you whether agy is installed and signed in. Checking step by step costs
time and tells you nothing the real call won't.

Read the first call's result like this:

| Signal | Meaning | What to do |
|---|---|---|
| `command not found`, exit 127, "is not recognized" (Windows) | agy isn't installed | Stop delegating. Give the user the install command below. Ask whether to wait or have Claude do the task itself. |
| Error mentioning sign in / auth / login / credentials | agy isn't signed in | Stop delegating. Sign-in needs a browser (OAuth), so Claude can't do it. Ask the user to run `agy` once in a terminal, or set `ANTIGRAVITY_API_KEY`. |
| Exit 0 but empty stdout | Possibly the stdout bug in older agy builds | Check the report file — if agy wrote it, the task ran. Suggest updating agy. |
| Timeout | Task too large | Split the task, or raise `--print-timeout`. |
| JSON with `conversation_id` and `status` | Working normally | Continue. |

Install commands to give the user:
- macOS / Linux: `curl -fsSL https://antigravity.google/cli/install.sh | bash`
- Windows PowerShell: `irm https://antigravity.google/cli/install.ps1 | iex`

Remember the outcome for the rest of the session. If agy failed on install or sign-in, don't
call it again until the user says it's fixed — it will only return the same error.

## 2. Project setup (first time only; skip what already exists)

```
.handoff/
├── PLAN.md          # Claude: goals, decisions, task table
├── acceptance/      # Claude: acceptance spec per task (task-NN.md)
├── baselines/       # Claude: benchmark baselines per task
├── prompts/         # Claude: the prompt sent to agy per task
├── reports/         # agy: report per task
├── reviews/         # Claude: verdict per task
└── .agy-session     # current agy conversation_id
```

Add `.handoff/.agy-session` to `.gitignore`.

If the project's CLAUDE.md has no `<!-- agy-delegate -->` marker, append this short block and
tell the user in one sentence. It lets future sessions know the project uses this workflow.
Don't copy the skill into CLAUDE.md — CLAUDE.md loads in every session, so shorter is better.

```markdown
<!-- agy-delegate -->
## Working with agy
This project uses the `agy-delegate` skill: Claude plans and verifies, agy implements via `agy -p`.
Current state lives in `.handoff/PLAN.md` — read it before continuing any work.
<!-- /agy-delegate -->
```

## 3. Define acceptance before delegating

Every delegated task gets an acceptance spec, written by Claude **before** agy is called.
The reason: criteria written after seeing the code tend to bend to fit the code, and an
implementer grading its own work is no grade at all. The tests are the contract; agy
fulfils it but never edits it.

For each task, Claude:

1. **Writes the acceptance tests itself**, as real test files in the repo's normal test
   framework. Cover the behaviour that matters, including the edge cases most likely to be
   gotten wrong.
2. **Runs them before delegating** to prove they test something:
   - New behaviour: they must fail, and fail for the expected reason (missing function,
     wrong output) — not because of a typo or import error in the test.
   - Refactor / no behaviour change: they must pass now, and must still pass afterwards.
   A test that already passes before a new feature exists tests nothing.
3. **Records benchmark baselines** when performance matters: run each benchmark on the
   current code, on this machine, at least 5 times, and keep the median in
   `.handoff/baselines/task-NN.md`. Set thresholds relative to that baseline (e.g. no more
   than 10% slower), because absolute numbers from another machine mean little.
4. **Locks the acceptance files**: list them in the spec with their `git hash-object`
   hashes. After agy finishes, any hash mismatch is an automatic rejection, whatever
   the test results say. Hashes work whether or not the files are committed.
5. **Chooses who runs verification**:
   - `claude` (default): Claude runs everything itself. agy's report is testimony; Claude's
     own run is evidence.
   - `agy`: only when the run needs something only agy's setup has, or takes too long to
     run twice. agy must report the exact command, exit code, and the raw tail of the output
     (not a summary). Claude still reruns the fast subset (static checks plus a sample of
     tests) and rejects a report that summarises instead of pasting output.

Acceptance spec template (`.handoff/acceptance/task-NN.md`):

```markdown
# Acceptance: task NN

## Locked files (agy must not edit)
| File | git hash-object |
|------|-----------------|
| tests/acceptance/test_login.py | 3f2a9c... |

## Static checks
| ID | Command | Pass condition |
|----|---------|----------------|
| S1 | npm run lint | exit 0 |
| S2 | npm run typecheck | exit 0 |

## Tests
| ID | Command | Pass condition |
|----|---------|----------------|
| T1 | pytest tests/acceptance/test_login.py | exit 0, all pass |
| T2 | pytest tests/ | exit 0 (no regressions) |

## Benchmarks
| ID | Command | Metric | Runs | Baseline (median) | Threshold |
|----|---------|--------|------|-------------------|-----------|
| B1 | python bench/login.py | p50 latency ms | 5 | 42 | ≤ 46 (+10%) |

## Pre-delegation check
- T1 failed as expected: <one line on the failure reason>
- Baseline recorded: <date>

## Verified by: claude
```

Omit sections that don't apply — a docs task has no benchmarks. If writing the acceptance
spec would take longer than doing the task, Claude does the task itself.

## 4. Division of labour

**Claude:** requirements, architecture, task breakdown, interfaces between modules,
acceptance tests and benchmarks, verification, integration, cross-module debugging, and the
keep-or-revert decision.

**agy:** implementing well-scoped tasks within a fixed set of files; boilerplate, migrations,
bulk renames; work tied to the Google ecosystem (Flutter, Firebase, GCP, Gemini API);
researching docs and summarising; a second-opinion review of Claude's code when it matters.
agy may add its own unit tests outside the locked paths, but they don't count toward
acceptance.

**Never delegate:** acceptance tests or thresholds, cross-module changes, architecture
decisions, secrets, deployment config, data deletion, git operations (commit, push, reset).

## 5. The loop for each task

1. **Checkpoint.** If the working tree has the user's uncommitted changes, ask once whether to
   make a checkpoint commit. Don't commit the user's work without asking.
2. **Define.** Add the task to `PLAN.md`, write `acceptance/task-NN.md` and the acceptance
   tests, run the pre-delegation check (section 3), then write `prompts/task-NN.md`.
3. **Call agy.**
   ```bash
   agy -p "$(cat .handoff/prompts/task-NN.md)" --output-format json --print-timeout 10m
   ```
   Set the shell command's own timeout longer than `--print-timeout`.
   - Follow-up task in the same module: add `--conversation <id>` using `.handoff/.agy-session`.
   - Unrelated task: drop `--conversation` for a fresh session — old context only adds noise
     and spends quota.
   - Always overwrite `.agy-session` with the `conversation_id` from the JSON. If an old id
     can't be resumed, agy silently starts a new conversation, so the returned id is the
     real one.
   - Don't use `-c` / `--continue`: "most recent conversation" may belong to another agy
     session the user has open.
4. **Verify**, cheapest first, stopping at the first failure:
   locked-file hashes → static checks → acceptance tests → full test suite → benchmarks.
   For benchmarks, run the same number of times as the baseline and compare medians. If the
   result lands within ~3% of the threshold, rerun once before judging — benchmark noise
   shouldn't decide a verdict.
5. **Verdict.** Write `reviews/task-NN.md` (each check ID with pass/fail and the measured
   value) and update the task's status in `PLAN.md`.
   - **Pass:** tell the user, move on.
   - **Fail:** send agy a fix request with `--conversation`, quoting the failing check ID and
     the exact failing output (trimmed), not a paraphrase — agy fixes what it can see. At
     most 2 fix rounds; after that Claude fixes it or asks the user. The cap stops two agents
     bouncing work back and forth and burning quota.
   - **Locked file touched, or badly broken:** revert agy's changes and tell the user before
     retrying.
   - **agy says a test is wrong:** Claude re-examines the test. If the test really is wrong,
     Claude fixes it, re-runs the pre-delegation check, re-locks it, and says so in the
     review. Acceptance never changes silently.

## 6. Prompt template for agy

```markdown
You are working on task NN in .handoff/PLAN.md. Read that file first for context.

## Task
<short description>

## Scope
- You may edit: <files/folders>
- Do not touch anything else. Do not run git commit, push, or reset.

## Acceptance
The acceptance spec is .handoff/acceptance/task-NN.md. The task is done when every check
in it passes. Run those commands yourself to check your work as you go.
The locked files listed there must not be modified in any way. If you believe a locked
test is wrong, stop and explain why in your report instead of changing it.

## When finished
Write your report to .handoff/reports/task-NN.md using the report template in
.handoff/PLAN.md. If you get blocked, still write the report and say where you got stuck.
```

## 7. PLAN.md template

```markdown
# Plan: <feature name>

## Goal
## Architecture decisions
## Tasks
| # | Task | Implementer | Verified by | Status |
|---|------|-------------|-------------|--------|
| 01 | ... | agy | claude | pending / in progress / passed / needs fix / taken over by Claude |

## Report template (for agy)
### What I did
### Files changed
### Checks I ran
For each: the exact command, exit code, and the last ~30 lines of raw output.
### What I'm NOT sure about
### Tests I believe are wrong (if any, with reasoning)
### Blocked on (if any)
```

"What I'm NOT sure about" is where Claude's review should look hardest.

## 8. Safety limits

- In `-p` mode agy may run tools without asking. Don't add permission-skipping flags (such
  as `--dangerously-skip-permissions`) unless the user has explicitly agreed.
- Never run `agy` without `-p` — the interactive TUI will hang the shell command.
- Claude and agy never edit the same file at the same time; wait for agy to finish first.
- If a flag above errors as unknown, run `agy --help` once to see the installed version's
  syntax and adjust. Don't guess.
