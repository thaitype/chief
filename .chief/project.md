# Project Configuration

## Overview

This project **is** the Chief Agent Framework. The root-level `.agents/`, `.chief/`, and `AGENTS.md` are dogfooded — this project uses its own framework on itself.

## Architecture

### Directory Structure

```
project/
├── AGENTS.md              # Framework rules (dogfooded)
├── CLAUDE.md → AGENTS.md  # Symlink for Claude Code
├── .agents/               # Dogfooded agent definitions (no placeholders)
├── .chief/                # Dogfooded planning state
├── template/              # Installable package — what setup copies into user projects
│   ├── .agents/           # Agent definitions with ${thinking_model}/${coding_model} placeholders
│   ├── .chief/            # Blank project scaffold (empty project.md, _rules/, etc.)
│   └── AGENTS.md          # Framework rules file
├── scripts/
│   └── setup.sh           # Installation script
└── docs/                  # Additional documentation
```

### Key Distinction

- `template/` = the package that gets installed into other projects
- Root-level files = this project eating its own dogfood

## Setup Concept

Installation into a user project follows these steps (regardless of script or manual):

1. Copy `template/.agents/` → target `.agents/`
2. Copy `template/.chief/` → target `.chief/`
3. Copy `template/AGENTS.md` → target `AGENTS.md`
4. Replace `${thinking_model}` and `${coding_model}` placeholders in `.agents/agents/*.md` with actual model names
5. Create agent-specific integration files (symlinks or copies from `.agents/agents/` to `.claude/agents/`, `.github/agents/`, etc.)

### Critical Rule

Always modify the canonical `.agents/agents/` files first (step 4), then create symlinks or copies (step 5). Never run text replacement on symlinked files — `sed` on a symlink destroys it and replaces it with a regular file.

## Tech Stack

- Shell (bash) for setup scripts
- Markdown for all agent definitions, rules, and documentation
- Symlinks for integration with coding agents
- No runtime dependencies
