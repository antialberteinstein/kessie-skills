#!/usr/bin/env python3
"""
Scans the repository for directories containing SKILL.md,
extracts metadata (name, description, slash commands),
and automatically updates the "Skills Included" section in README.md.
"""

import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
README_PATH = REPO_ROOT / "README.md"

TABLE_START_MARKER = "<!-- SKILLS_TABLE_START -->"
TABLE_END_MARKER = "<!-- SKILLS_TABLE_END -->"
COUNT_START_MARKER = "<!-- SKILLS_COUNT_START -->"
COUNT_END_MARKER = "<!-- SKILLS_COUNT_END -->"


def parse_skill_file(skill_path: Path):
    content = skill_path.read_text(encoding="utf-8")
    
    # 1. Parse YAML frontmatter
    name = skill_path.parent.name
    description = ""
    
    fm_match = re.search(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
    if fm_match:
        fm_text = fm_match.group(1)
        name_match = re.search(r"^name:\s*([^\n]+)", fm_text, re.MULTILINE)
        if name_match:
            name = name_match.group(1).strip().strip("'\"")
            
        desc_match = re.search(r"^description:\s*([^\n]+)", fm_text, re.MULTILINE)
        if desc_match:
            description = desc_match.group(1).strip().strip("'\"")

    # 2. Extract slash commands / triggers from "## When to Use"
    triggers = []
    when_match = re.search(r"## When to Use\s*\n(.*?)(?=\n## |\Z)", content, re.DOTALL)
    if when_match:
        when_text = when_match.group(1)
        found_commands = re.findall(r"(/[\w-]+)", when_text)
        # Deduplicate while preserving order
        for cmd in found_commands:
            if cmd not in triggers:
                triggers.append(cmd)
    
    if not triggers:
        triggers = [f"/{name}"]

    formatted_triggers = ", ".join(f"`{t}`" for t in triggers)
    
    # Clean description for table
    description = description.replace("|", "\\|")
    
    return {
        "dir_name": skill_path.parent.name,
        "name": name,
        "triggers": formatted_triggers,
        "description": description,
    }


def find_all_skills():
    skills = []
    for item in sorted(REPO_ROOT.iterdir()):
        if item.is_dir() and not item.name.startswith((".", "_", "scripts", "node_modules")):
            skill_md = item / "SKILL.md"
            if skill_md.is_file():
                skills.append(parse_skill_file(skill_md))
    return sorted(skills, key=lambda s: s["name"])


def build_markdown_table(skills):
    lines = [
        "| Skill | Trigger / Slash Command | Description |",
        "| :--- | :--- | :--- |",
    ]
    for s in skills:
        link = f"**[`{s['name']}`](./{s['dir_name']}/SKILL.md)**"
        lines.append(f"| {link} | {s['triggers']} | {s['description']} |")
    return "\n".join(lines)


def update_readme(check_mode=False):
    if not README_PATH.is_file():
        print(f"Error: {README_PATH} not found.", file=sys.stderr)
        sys.exit(1)

    readme_content = README_PATH.read_text(encoding="utf-8")
    skills = find_all_skills()
    table_content = build_markdown_table(skills)
    skill_count = len(skills)

    # 1. Update Table
    table_pattern = re.compile(
        re.escape(TABLE_START_MARKER) + r".*?" + re.escape(TABLE_END_MARKER),
        re.DOTALL,
    )
    if not table_pattern.search(readme_content):
        print(f"Error: Markers {TABLE_START_MARKER} and {TABLE_END_MARKER} not found in README.md", file=sys.stderr)
        sys.exit(1)

    replacement_table = f"{TABLE_START_MARKER}\n{table_content}\n{TABLE_END_MARKER}"
    new_content = table_pattern.sub(replacement_table, readme_content)

    # 2. Update Badge Count
    count_pattern = re.compile(
        re.escape(COUNT_START_MARKER) + r".*?" + re.escape(COUNT_END_MARKER),
        re.DOTALL,
    )
    if count_pattern.search(new_content):
        badge = f"{COUNT_START_MARKER}![Skills Count](https://img.shields.io/badge/skills-{skill_count}-blue.svg?style=flat-square){COUNT_END_MARKER}"
        new_content = count_pattern.sub(badge, new_content)

    if new_content == readme_content:
        print(f"README.md is already up to date ({skill_count} skills).")
        return False

    if check_mode:
        print("README.md is OUT OF DATE! Run scripts/update-readme.py to update it.", file=sys.stderr)
        sys.exit(1)

    README_PATH.write_text(new_content, encoding="utf-8")
    print(f"✓ Updated README.md with {skill_count} skills:")
    for s in skills:
        print(f"  - {s['name']} ({s['triggers']})")
    return True


if __name__ == "__main__":
    check = "--check" in sys.argv
    update_readme(check_mode=check)
