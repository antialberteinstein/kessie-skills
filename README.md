# Kessie Skills

<div align="center">

[![Sync Skills README](https://github.com/antialberteinstein/kessie-skills/actions/workflows/sync-skills-readme.yml/badge.svg)](https://github.com/antialberteinstein/kessie-skills/actions/workflows/sync-skills-readme.yml)
<!-- SKILLS_COUNT_START -->![Skills Count](https://img.shields.io/badge/skills-3-blue.svg?style=flat-square)<!-- SKILLS_COUNT_END -->
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](./CONTRIBUTING.md)

**A lightweight, high-signal collection of agent skills for Claude Code, Codex, and Gemini CLI / Antigravity.**

[Skills Included](#skills-included) • [Prerequisites](#prerequisites) • [Installation](#installation--deployment) • [Usage](#usage) • [Structure](#repository-structure) • [Automation](#automated-skills-sync) • [Contributing](#contributing)

</div>

---

## Overview

**Kessie Skills** automates key stages of the software delivery lifecycle using specialized LLM workflows. It enables your AI pair programmer to investigate and solve GitHub issues with full test validation, to conduct structured, multi-dimensional pull request reviews, and — via `proj` — to run a whole project from idea to release (kickoff, spec, DESIGN.md, issues, build, ship) for any project type and stack.

---

## Skills Included

<!-- SKILLS_TABLE_START -->
| Skill | Trigger / Slash Command | Description |
| :--- | :--- | :--- |
| **[`issue-resolve`](./issue-resolve/SKILL.md)** | `/issue-resolve`, `/resolve-issue` | Resolve a GitHub issue end-to-end: fetch issue details, reproduce, implement fix, test, submit PR, and iterate on review feedback. |
| **[`pr-review`](./pr-review/SKILL.md)** | `/pr-review`, `/pull-request-review` | Review or test a GitHub pull request. Inspects diffs, analyzes code quality, security, and test coverage, and provides actionable feedback. |
| **[`proj`](./proj/SKILL.md)** | `/proj` | Quy trình dự án cho một người làm cùng AI agent, mọi loại dự án và stack — khởi động, spec (người dùng chốt), DESIGN.md, tạo issue, build issue → PR, kiểm chứng, phát hành, trạng thái và bảo trì. Gọi thủ công kèm chế độ; không kèm chế độ thì gợi ý bước tiếp theo. |
<!-- SKILLS_TABLE_END -->

> *Note: This table and badge are automatically updated by GitHub Actions whenever a new skill directory with a `SKILL.md` is added or modified.*

---

## Prerequisites

Ensure you have the following installed and authenticated:

- **[git](https://git-scm.com/)**: Version 2.20 or newer.
- **[GitHub CLI (`gh`)](https://cli.github.com/)**: Logged in to your GitHub account:
  ```bash
  gh auth login
  ```

---

## Installation & Deployment

There are two ways to install. **Pick one** — installing both gives you duplicate skills (e.g. `/proj` and `/kessie-skills:proj`).

### Option A — Claude Code plugin (recommended for Claude Code)

This repository is also a Claude Code marketplace (`kessie`) containing one plugin (`kessie-skills`) with every skill in the repo:

```bash
/plugin install kessie-skills --marketplace antialberteinstein/kessie-skills
```

Or from a local clone:

```bash
claude plugin marketplace add /path/to/kessie-skills
claude plugin install kessie-skills@kessie
claude plugin list                    # kessie-skills@kessie · ✔ enabled
```

Skills are namespaced: `/kessie-skills:proj`, `/kessie-skills:issue-resolve`, `/kessie-skills:pr-review`. Edits take effect next session or after `/reload-plugins`. Remove with `claude plugin marketplace remove kessie`.

### Option B — `install.sh` (Claude Code, Codex, Gemini CLI / Antigravity)

Deploy skills to your local harnesses with [install.sh](./install.sh). Skills are not namespaced (`/proj`, `/issue-resolve`, `/pr-review`).

### 1. Install to All Detected Harnesses (Default)
Copies skills to Claude Code (`~/.claude/skills`), Codex (`~/.codex/skills`), and Gemini (`~/.gemini/config/skills` & `~/.gemini/skills`):

```bash
./install.sh
```

### 2. Symlink Mode (Recommended for Development)
Creates symlinks directly to this repository so edits take effect immediately across all harnesses without re-running install:

```bash
./install.sh --symlink all
```

### 3. Selective Installation
Target specific harnesses:

```bash
# Install only to Claude Code
./install.sh claude

# Install only to Gemini CLI / Antigravity
./install.sh gemini

# Install only to Codex CLI
./install.sh codex
```

### 4. Local Project Installation
Deploy skills into a single repository instead of global user configs:

```bash
./install.sh --local /path/to/your/project
```

---

## Uninstallation

To cleanly remove installed skills from all harnesses, run [uninstall.sh](./uninstall.sh):

```bash
./uninstall.sh
```

---

## Usage

### Using `issue-resolve`

Invoke in your chat or slash command line:

```
/issue-resolve 142
```
or
```
/resolve-issue https://github.com/owner/repo/issues/142
```

**Lifecycle executed:**
1. Fetches issue details and comments via `gh issue view`.
2. Creates a clean branch: `fix/<issue>-<slug>`.
3. Implements minimal changes and adds regression tests.
4. Pushes and opens a linked PR via `gh pr create`.
5. Iterates on incoming PR review comments upon request.

---

### Using `pr-review`

Invoke with the pull request number or URL:

```
/pr-review 89
```

**Supported Modes:**
- **Code Review (Default)**: Inspects diff via `gh pr diff` and evaluates correctness, security, performance, quality, and test coverage.
- **Local Testing**: Checks out PR branch locally (`gh pr checkout`) and executes tests (`npm test`, `pytest`, etc.) upon explicit user request.

---

### Using `proj`

A manual-only (`disable-model-invocation: true`) project workflow for a solo developer working with an AI agent — one command, many modes. It never fires on its own, so it costs no context when unused. Instructions are written in Vietnamese.

```
/kessie-skills:proj                       → suggest the single next step
/kessie-skills:proj kickoff <idea>        /kessie-skills:proj kickoff tiếp nhận <repo>
/kessie-skills:proj spec <description>    /kessie-skills:proj spec thảo luận <topic> | spec inbox | spec xem
/kessie-skills:proj design [list | <template> | custom | apply]
/kessie-skills:proj issue <description>   /kessie-skills:proj plan [milestone]
/kessie-skills:proj build <#issue>
/kessie-skills:proj ship verify | security | release X.Y.Z
/kessie-skills:proj status | report | triage | deps
```

(Use `/proj …` instead if you installed with `install.sh`.)

| Mode | What it does |
| :--- | :--- |
| *(empty)* | Reads project state and proposes **one** next step |
| `kickoff` | Idea brief → spec + AC → ADR → DESIGN.md → scaffold + CI → backlog |
| `spec` | You describe or discuss; the agent proposes, you decide. Nothing is written to the spec without your approval |
| `design` | DESIGN.md from [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) (pinned by commit) or custom; `apply` maps tokens to your stack's theme and checks WCAG contrast |
| `issue` · `plan` | Create one issue · split the spec into issues and milestones |
| `build` | Issue → tests → code → quality gates → PR |
| `ship` | Verification, security review, release |
| `status` · `report` · `triage` · `deps` | Status, report, issue triage, dependency upkeep |

Every outward-facing action (push, PR, merge, tag, release, issue creation) asks you first. Full workflow: **[docs/QUY-TRINH.md](./docs/QUY-TRINH.md)** · Companion skills: **[docs/RECOMMENDED-SKILLS.md](./docs/RECOMMENDED-SKILLS.md)**.

> `proj` uses Claude Code–specific frontmatter (`argument-hint`, `disable-model-invocation`, `allowed-tools` with `${CLAUDE_SKILL_DIR}`). Under Codex, `agents/openai.yaml` sets `allow_implicit_invocation: false` to keep it manual-only.

---

## Automated Skills Sync

This repository includes a GitHub Action workflow ([`.github/workflows/sync-skills-readme.yml`](./.github/workflows/sync-skills-readme.yml)) that runs on every push or PR touching `*/SKILL.md`:
1. Scans for any new or updated skill folders containing `SKILL.md`.
2. Parses frontmatter (`name`, `description`) and triggers (`/slash-command`).
3. Automatically regenerates the [Skills Included](#skills-included) table and updates the skill count badge in `README.md`.
4. Commits and pushes the documentation update back to `main`.

You can also run the generator locally at any time:
```bash
python3 scripts/update-readme.py
```

---

## Repository Structure

```
kessie-skills/
├── .claude-plugin/
│   ├── marketplace.json            # Claude Code marketplace "kessie"
│   └── plugin.json                 # Plugin "kessie-skills" (all skills in this repo)
├── .github/
│   └── workflows/
│       └── sync-skills-readme.yml  # GitHub Action for auto-updating README table
├── docs/
│   ├── QUY-TRINH.md                # proj operating workflow (Vietnamese)
│   └── RECOMMENDED-SKILLS.md       # Companion skills to use with proj
├── scripts/
│   └── update-readme.py            # Dynamic skills scanner & README generator
├── .gitignore                      # Standard ignore rules
├── CONTRIBUTING.md                 # Skill authoring guidelines
├── LICENSE                         # MIT License
├── README.md                       # Project documentation
├── install.sh                      # Multi-harness deployment script
├── uninstall.sh                    # Clean uninstallation script
├── issue-resolve/
│   └── SKILL.md                    # Issue resolution workflow
├── pr-review/
│   └── SKILL.md                    # PR review and testing workflow
└── proj/
    ├── SKILL.md                    # Mode router + shared principles
    ├── agents/openai.yaml          # Codex metadata (manual-only)
    ├── references/modes/*.md       # kickoff, spec, design, build, ship, lead
    ├── references/*.md             # Role guides, templates, project types
    ├── scripts/                    # scaffold, snapshot, check-release, design-md, contrast
    └── templates/                  # Repo scaffold files
```

---

## Contributing

Review [CONTRIBUTING.md](./CONTRIBUTING.md) for skill format requirements, YAML frontmatter standards, and validation checklists.

---

## License

This project is licensed under the [MIT License](./LICENSE).
