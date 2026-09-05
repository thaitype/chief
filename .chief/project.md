# Project Configuration

## Overview

This project **is** the Chief framework. The root-level `AGENTS.md` and `.chief/` are
dogfooded — this project uses its own framework on itself.

## Architecture

### Directory Structure

```
project/
├── AGENTS.md              # This repo's own rules (dogfooded, hand-maintained)
├── CLAUDE.md → AGENTS.md  # Symlink for Claude Code
├── .chief/                # Dogfooded planning state (this file lives here)
├── skills/                # chief-* skills (chief, engineering, misc, setup buckets)
└── docs/                  # Additional documentation
```

There is no `template/` directory. v5 has no `.agents/agents/` subagent roster anymore —
`/chief-build` and `/chief-test` are skills under `skills/chief/`, not agent files. There's no
install/upgrade skill either, and no `scripts/` directory — Chief writes nothing to
`AGENTS.md` for any project, including this one; root `AGENTS.md` here is just this repo's own
hand-maintained file, same as any consuming project's would be if they chose to have one.

### Key Distinction

Nothing to distinguish anymore — there's no separate installable package vs. dogfood split.
Everything under `skills/` is both what this repo runs on itself and what ships to consumers.

## Setup Concept

There isn't one. Getting Chief's skills into a project (`npx skills add thaitype/chief` or
copying `skills/**/SKILL.md` files by hand) is the only step — every `chief-*` slash command
works immediately, nothing else needs to exist first.

`.chief/` is created lazily at runtime by whichever `chief-*` skill first needs it — never at
"install" time, because there is no install time.

## Tech Stack

- Markdown for all skill definitions, rules, and documentation
- Symlinks for Claude Code integration (`CLAUDE.md` → `AGENTS.md`), set up by hand, not by any
  skill
- No runtime dependencies, no shell scripts
