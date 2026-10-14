# Kessie Skills

<div align="center">

[![Sync Skills README](https://github.com/antialberteinstein/kessie-skills/actions/workflows/sync-skills-readme.yml/badge.svg)](https://github.com/antialberteinstein/kessie-skills/actions/workflows/sync-skills-readme.yml)
<!-- SKILLS_COUNT_START -->![Skills Count](https://img.shields.io/badge/skills-2-blue.svg?style=flat-square)<!-- SKILLS_COUNT_END -->
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](./CONTRIBUTING.md)

**A lightweight, high-signal collection of agent skills for Claude Code, Codex, and Gemini CLI / Antigravity.**

[Skills Included](#skills-included) • [Prerequisites](#prerequisites) • [Installation](#installation--deployment) • [Usage](#usage) • [Structure](#repository-structure) • [Automation](#automated-skills-sync) • [Contributing](#contributing)

</div>

---

## Overview

**Kessie Skills** automates key stages of the software delivery lifecycle using specialized LLM workflows. It enables your AI pair programmer to investigate and solve GitHub issues with full test validation and to conduct structured, multi-dimensional pull request reviews.

---

## Skills Included

<!-- SKILLS_TABLE_START -->
| Skill | Trigger / Slash Command | Description |
| :--- | :--- | :--- |
| **[`issue-resolve`](./issue-resolve/SKILL.md)** | `/issue-resolve`, `/resolve-issue` | Resolve a GitHub issue end-to-end: fetch issue details, reproduce, implement fix, test, submit PR, and iterate on review feedback. |
| **[`pr-review`](./pr-review/SKILL.md)** | `/pr-review`, `/pull-request-review` | Review or test a GitHub pull request. Inspects diffs, analyzes code quality, security, and test coverage, and provides actionable feedback. |
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

Deploy skills to your local harnesses with [install.sh](./install.sh):

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
├── .github/
│   └── workflows/
│       └── sync-skills-readme.yml  # GitHub Action for auto-updating README table
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
└── pr-review/
    └── SKILL.md                    # PR review and testing workflow
```

---

## Contributing

Review [CONTRIBUTING.md](./CONTRIBUTING.md) for skill format requirements, YAML frontmatter standards, and validation checklists.

---

## License

This project is licensed under the [MIT License](./LICENSE).
