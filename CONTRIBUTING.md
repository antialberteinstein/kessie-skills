# Contributing to Kessie Skills

Thank you for contributing to **Kessie Skills**! This guide outlines how to create, test, and refine skills for Claude Code, Codex, and Gemini CLI.

---

## Skill Architecture

Every skill lives in its own directory and must have a canonical `SKILL.md` file:

```
kessie-skills/
├── <skill-name>/
│   └── SKILL.md
```

### `SKILL.md` Format Requirements

1. **YAML Frontmatter**:
   ```yaml
   ---
   name: <skill-name>
   description: <High-signal summary of what this skill does and when to activate>
   author: <Author Name>
   requires:
     - <prerequisite tools/CLIs>
   ---
   ```
2. **Sections Required**:
   - `# <Skill Title>`: Human-readable header.
   - `## Overview`: 1–2 sentence description of goal.
   - `## When to Use`: Explicit trigger phrases or slash commands.
   - `## Workflow`: Sequenced, actionable steps with concrete commands.

---

## Quality Checklist

Before submitting changes:
- [ ] File is strictly named `SKILL.md` (singular).
- [ ] Frontmatter YAML parses cleanly with valid `name` and `description`.
- [ ] CLI commands use valid parameters (e.g. `gh issue view`, not non-existent subcommands).
- [ ] Safe defaults: Skills should never run destructive operations or push unreviewed changes without explicit steps.
- [ ] Instructions are concise, high-signal, and easy for LLMs to follow deterministically.

---

## Testing Locally

Run the install script to test in your active environment:

```bash
# Link skills to your local harnesses
./install.sh --symlink --all
```
