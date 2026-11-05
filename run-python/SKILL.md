---
name: run-python
description: 'Fix Python/pip environment errors by activating conda environment. Use when python or pip commands fail with environment/module errors. Automatically sources ~/.zshrc if condaon is not found, then activates conda ai environment.'
---

# RunPython - Conda Environment Activation

## When to Use

Automatically triggered when:
- `python` commands fail with module or environment errors
- `pip` commands fail (e.g., "No module named...", "command not found: python")
- Virtual environment is not properly initialized

## What It Does

1. Attempts to activate conda environment: `condaon && conda activate ai`
2. If `condaon` is not found, sources shell config first: `source ~/.zshrc`
3. Then activates conda environment: `conda activate ai`
4. Re-runs the original failed command

## Procedure

When you encounter Python/pip errors, I will:

1. Detect the command failure
2. Run: `condaon && conda activate ai`
3. If that fails with "condaon not found":
   - Run: `source ~/.zshrc` (to initialize shell functions)
   - Then: `conda activate ai`
4. Retry the original command within the activated conda environment

## Manual Trigger

You can also manually invoke this skill using `/run-python` if needed.

## Notes

- Assumes conda environment named `ai` exists
- Shell functions are loaded from `~/.zshrc`
- Works with bash/zsh shells
