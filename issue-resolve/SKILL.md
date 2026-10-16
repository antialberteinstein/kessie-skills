---
name: issue-resolve
description: "Resolve a GitHub issue end-to-end: fetch issue details, reproduce, implement fix, test, submit PR, and iterate on review feedback."
author: Nhat Nguyen
requires:
  - GitHub CLI (gh)
  - git
---

# Issue Resolve Skill

## Overview
Automates resolving a GitHub issue from requirement analysis to submitting and refining a pull request.

## When to Use
- Triggered by `/issue-resolve` or `/resolve-issue <ISSUE_NUMBER | URL>`.
- If the issue identifier is missing, prompt the user for the issue number or URL before proceeding.

## Workflow

### 1. Retrieve Issue Context
- Fetch issue details and comments:
  ```bash
  gh issue view <ISSUE_NUMBER> --comments
  ```
- Identify the problem statement, reproduction steps, and expected behavior.

### 2. Prepare Branch
- Ensure working directory is clean and base branch is up-to-date:
  ```bash
  git checkout main && git pull origin main
  ```
- Create a dedicated branch following standard naming conventions:
  ```bash
  git checkout -b fix/<ISSUE_NUMBER>-<short-description>
  # (Use feat/, docs/, or refactor/ prefix where appropriate)
  ```

### 3. Implement & Test
- Implement minimal, targeted changes.
- Add or update regression tests to verify the fix.
- Run project test suite and linters to ensure no regressions.

### 4. Create Pull Request
- Commit changes using conventional commit messages (`fix: ...`, `feat: ...`).
- Push branch and open a PR linked to the issue:
  ```bash
  git push -u origin HEAD
  gh pr create --title "fix: <summary>" --body "Closes #<ISSUE_NUMBER>. <details of the fix>"
  ```

### 5. Review & Feedback Loop
- When asked to review feedback or recheck:
  ```bash
  gh pr view <PR_NUMBER> --comments
  ```
- Address reviewer feedback with surgical commits, re-verify tests, and push updates.
- Notify the user once all feedback is addressed for final user merge/close.
