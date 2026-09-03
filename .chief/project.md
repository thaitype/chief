# Project Configuration

## Overview

This project **is** the Chief framework. The root-level `AGENTS.md` and `.chief/` are
dogfooded — this project uses its own framework on itself.

## Architecture

### Directory Structure

```
project/
├── AGENTS.md              # Framework rules (dogfooded)
├── CLAUDE.md → AGENTS.md  # Symlink for Claude Code
├── .chief/                # Dogfooded planning state (this file lives here)
├── template/              # Installable package — what setup copies into user projects
│   └── AGENTS.md          # Framework rules file
├── scripts/
│   └── setup.sh           # First-time installation script
├── skills/                # chief-* skills (chief, engineering, misc, setup buckets)
└── docs/                  # Additional documentation
```

v5 has no `.agents/agents/` subagent roster anymore, in `template/` or dogfooded at root —
`/chief-build` and `/chief-test` are skills under `skills/chief/`, not agent files. There's no
`scripts/upgrade.sh` either; `/chief-upgrade` diffs and merges `AGENTS.md` directly (see its
`SKILL.md`).

### Key Distinction

- `template/` = the package that gets installed into other projects
- Root-level files = this project eating its own dogfood

## Setup Concept

Installation into a user project (`/chief-install` / `scripts/setup.sh`):

1. Copy `template/AGENTS.md` → target `AGENTS.md` (fresh write, or appended in a
   `<!-- chief-framework:begin -->` block if the target already has one)
2. For Claude Code: create `CLAUDE.md` → `AGENTS.md`

`.chief/` is never touched at install time — it's created lazily by whichever `chief-*` skill
first needs it.

## Tech Stack

- Shell (bash) for the setup script
- Markdown for all skill definitions, rules, and documentation
- Symlinks for Claude Code integration (`CLAUDE.md` → `AGENTS.md`)
- No runtime dependencies
