#!/bin/bash
# activate-conda.sh - Activate conda environment with fallback to source ~/.zshrc

set -e

# Try condaon + activate directly
if condaon && conda activate ai 2>/dev/null; then
  exit 0
fi

# Fallback: source ~/.zshrc first, then activate
if [ -f ~/.zshrc ]; then
  source ~/.zshrc
  condaon && conda activate ai
else
  echo "Error: ~/.zshrc not found and condaon unavailable"
  exit 1
fi
