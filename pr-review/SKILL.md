---
name: pr-review
description: "Review or test a GitHub pull request. Inspects diffs, analyzes code quality, security, and test coverage, and provides actionable feedback."
author: Nhat Nguyen
requires:
  - GitHub CLI (gh)
  - git
---

# Pull Request Review Skill

## Overview
Inspects, reviews, and optionally tests a GitHub pull request, providing structured, actionable feedback without making unauthorized code edits.

## When to Use
- Triggered by `/pr-review` or `/pull-request-review <PR_NUMBER | URL>`.
- If the PR identifier is missing, prompt the user for the PR number or URL.
- Clarify mode if unspecified: **Code Review** (diff analysis) vs. **Local Testing** (checkout and run test suite).

## Workflow

### 1. Fetch PR Information
- Inspect metadata and description:
  ```bash
  gh pr view <PR_NUMBER>
  ```
- Inspect changed files and diff:
  ```bash
  gh pr diff <PR_NUMBER>
  ```

### 2. Execution Modes

#### Mode A: Code Review (Default)
- Analyze the diff directly without altering the local git state.
- Evaluate against:
  1. **Correctness & Logic**: Bugs, edge cases, off-by-one errors.
  2. **Security**: Secrets, unvalidated inputs, injection risks.
  3. **Performance & Scalability**: N+1 queries, memory leaks, unindexed lookups.
  4. **Quality & Maintainability**: Clean code, readability, proper error handling.
  5. **Test Coverage**: Presence of unit/integration tests for changed code.

#### Mode B: Local Testing (When requested)
- Checkout the PR branch locally:
  ```bash
  gh pr checkout <PR_NUMBER>
  ```
- Install dependencies and run existing/new tests:
  ```bash
  npm test # or pytest / cargo test / go test depending on stack
  ```
- Verify behavior against requirements.

### 3. Deliver Structured Feedback
Provide clear, constructive feedback formatted as:
- **Summary**: Concise high-level assessment.
- **Key Findings**: Blockers (critical bugs/security issues) vs. Non-blocking suggestions.
- **Code Recommendations**: Concrete code snippets where improvements are needed.
- **Verdict**: `Approve`, `Request Changes`, or `Comment`.

> **Note**: Do not modify code on the PR branch unless explicitly asked by the user.
