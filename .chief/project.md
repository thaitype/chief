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
├── skills/                # chief-* skills (chief, engineering, misc, setup buckets)
└── docs/                  # Additional documentation
```

v5 has no `.agents/agents/` subagent roster anymore, in `template/` or dogfooded at root —
`/chief-build` and `/chief-test` are skills under `skills/chief/`, not agent files. There's no
`scripts/` directory at all — neither `setup.sh` nor `upgrade.sh` exist; `/chief-install` and
`/chief-upgrade` both write/diff `AGENTS.md` directly (see their `SKILL.md` files), the same
judgment-sensitive-merge pattern in both cases rather than shelling out to a script.

### Key Distinction

- `template/` = the package that gets installed into other projects
- Root-level files = this project eating its own dogfood

## Setup Concept

Installation into a user project (`/chief-install`):

1. Clone the target version, read `template/AGENTS.md` from it
2. Present what will be written (fresh, or a diff against the target's existing `AGENTS.md`
   split at the `<!-- chief-framework:begin/end -->` markers) and confirm
3. Write `AGENTS.md` (fresh write, or the framework block appended/updated)
4. For Claude Code: create `CLAUDE.md` → `AGENTS.md`

`.chief/` is never touched at install time — it's created lazily by whichever `chief-*` skill
first needs it.

## Tech Stack

- Markdown for all skill definitions, rules, and documentation
- Symlinks for Claude Code integration (`CLAUDE.md` → `AGENTS.md`)
- No runtime dependencies, no shell scripts
