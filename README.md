# Kessie Skills

A lightweight, high-signal collection of agent skills for **Claude Code**, **Codex**, and **Gemini CLI / Antigravity**.

Designed to automate the core GitHub software delivery lifecycle: resolving issues end-to-end and performing thorough, structured pull request reviews.

---

## Skills Included

| Skill | Trigger / Slash Command | Description |
| :--- | :--- | :--- |
| **[`issue-resolve`](file:///Volumes/Data/TheNewMeArrange/Kessie/kessie-skills/issue-resolve/SKILL.md)** | `/issue-resolve <ISSUE>`, `/resolve-issue` | Analyzes a GitHub issue, branches, writes minimal fix with tests, creates a PR, and iterates on review feedback. |
| **[`pr-review`](file:///Volumes/Data/TheNewMeArrange/Kessie/kessie-skills/pr-review/SKILL.md)** | `/pr-review <PR>`, `/pull-request-review` | Inspects pull request diffs or checks out code locally to run tests, delivering structured, actionable review feedback. |

---

## Prerequisites

Before using these skills, ensure you have the following installed and authenticated:

- **[git](https://git-scm.com/)**: Version 2.20 or newer.
- **[GitHub CLI (`gh`)](https://cli.github.com/)**: Logged in to your GitHub account:
  ```bash
  gh auth login
  ```

---

## Installation & Deployment

The repository includes a unified [install.sh](file:///Volumes/Data/TheNewMeArrange/Kessie/kessie-skills/install.sh) script to deploy skills to your AI agent harnesses.

### 1. Install to All Detected Harnesses (Default)
Copies skills to Claude Code (`~/.claude/skills`), Codex (`~/.codex/skills`), and Gemini (`~/.gemini/config/skills` & `~/.gemini/skills`):

```bash
./install.sh
```

### 2. Symlink Mode (Recommended for Development)
Links directly to this repository so any edits made here take effect immediately across all harnesses without re-copying:

```bash
./install.sh --symlink all
```

### 3. Selective Installation
Target specific harnesses as needed:

```bash
# Install only to Claude Code
./install.sh claude

# Install only to Gemini CLI / Antigravity
./install.sh gemini

# Install only to Codex
./install.sh codex
```

### 4. Local Project Installation
Deploy skills directly into an individual repository rather than user-global paths:

```bash
./install.sh --local /path/to/your/project
```

---

## Uninstallation

To remove the skills from all harnesses, run [uninstall.sh](file:///Volumes/Data/TheNewMeArrange/Kessie/kessie-skills/uninstall.sh):

```bash
./uninstall.sh
```

---

## Usage

### Using `issue-resolve`

Invoke with the issue number or URL:

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

## Repository Structure

```
kessie-skills/
├── .gitignore             # Standard ignore rules
├── CONTRIBUTING.md        # Skill authoring standards
├── LICENSE                # MIT License
├── README.md              # Project documentation
├── install.sh             # Multi-harness deployment script
├── uninstall.sh           # Clean removal script
├── issue-resolve/
│   └── SKILL.md           # End-to-end issue resolution workflow
└── pr-review/
    └── SKILL.md           # Structured PR review and testing workflow
```

---

## Contributing

Please review [CONTRIBUTING.md](file:///Volumes/Data/TheNewMeArrange/Kessie/kessie-skills/CONTRIBUTING.md) for skill format rules, YAML frontmatter standards, and validation checklists.

---

## License

This project is licensed under the [MIT License](file:///Volumes/Data/TheNewMeArrange/Kessie/kessie-skills/LICENSE).
