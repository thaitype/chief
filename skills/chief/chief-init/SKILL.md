---
name: chief-init
description: Bootstrap `.chief/project.md` for a Chief-installed project by interviewing the user about their tech stack, dev commands, architecture, and key rules. Use after `/chief-install` (or any time the user wants to set up project-wide context). This is the lazy entry point for `.chief/` — it creates only `project.md`; milestones and rules are created later, on demand.
---

You are bootstrapping the project's `.chief/project.md`. This is the only thing this skill creates. Milestones, rules, and other `.chief/` content are created later by chief-agent on first need.

## Steps

### 1. Pre-flight checks

1. Verify the framework is installed: `.agents/agents/chief-agent.md` must exist. If missing, tell the user to run `/chief-install` first and stop.
2. Check if `.chief/project.md` already exists.
   - If yes → ask the user: "`.chief/project.md` already exists. Update it / overwrite / cancel?"
   - If overwrite, back up the current file to `.chief/project.md.bak` before proceeding.
   - If update, read the current content first and treat the interview as a refinement pass.
   - If cancel, stop.
3. Create `.chief/` if it does not exist.

### 2. Interview the user

Walk through these topics, one short question at a time. Keep questions focused. Wait for the answer before moving on. Skip a topic if the user says "skip" or "n/a".

- **Project name and one-line summary.**
- **Tech stack** — primary languages, frameworks, runtimes, databases, key libraries.
- **Dev commands** — how to install deps, run dev, run tests, lint, typecheck, build.
- **Architecture overview** — main patterns (e.g. Repository Pattern, Service Layer, hexagonal, monorepo, etc.).
- **Directory structure** — top-level folders and what they hold.
- **Important development rules** — conventions developers must follow (commit style, branch policy, formatting, testing requirements, etc.).

If the user is unsure about a topic, suggest reasonable defaults derived from files you can see in the repo (`package.json`, `pyproject.toml`, `Cargo.toml`, `Makefile`, `README.md`, etc.) and confirm.

### 3. Show a draft and confirm

Print the proposed `.chief/project.md` content as formatted markdown. Then ask once: "Write this to `.chief/project.md`?"

If the user requests changes, apply them and re-confirm. Do not loop more than three rounds — if alignment is hard, write the current draft and tell the user they can edit manually.

### 4. Write the file

Write to `.chief/project.md`. Use this structure (omit empty sections rather than leaving placeholder prose):

```markdown
# Project Configuration

## Project
{name and one-line summary}

## Development Commands
{commands as a list or table}

## Architecture Overview

### Tech Stack
{...}

### Key Architectural Patterns
{...}

### Directory Structure
{...}

### Important Development Rules
{...}
```

### 5. Next steps

Tell the user:

- `.chief/project.md` is now set. chief-agent will read it for project context.
- To start a milestone: `/chief-plan` (creates `.chief/milestone-N/` lazily).
- To run autonomously once a milestone is planned: `/chief-autopilot`.
- Rules can be added later under `.chief/_rules/_standard/`, `_contract/`, `_goal/`, `_verification/` — chief-agent creates the appropriate subfolder on first rule.

## Important rules

- This skill creates **only** `.chief/` (if missing) and `.chief/project.md`. Do not scaffold milestones, rule subfolders, or `_template/`.
- Never overwrite an existing `project.md` without explicit user confirmation; always back up to `.bak` first.
- If `.agents/agents/chief-agent.md` is missing, do not proceed — direct the user to `/chief-install`.
- Keep the interview short. One focused question at a time, no compound questions.
- Reference: a canonical layout example lives at `docs/example-chief/` in the chief repo.
