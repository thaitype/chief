---
name: chief-init
description: Bootstrap `.chief/project.md` for a Chief-installed project by interviewing the user about their tech stack, dev commands, architecture, and key rules — and confirm where planning artifacts should live. Use after `/chief-install` (or any time the user wants to set up project-wide context). This is the lazy entry point for `.chief/` — it creates only `project.md` (and, only if the user wants a non-default location, `.chief.config.md`); stories and rules are created later, on demand.
---

You are bootstrapping the project's `.chief/project.md`, and confirming where Chief stores its
own planning artifacts. Nothing else is created here. Stories, rules, and other `.chief/`
content are created later by whichever skill first needs them.

## Steps

### 1. Pre-flight checks

1. Verify the framework is installed: `AGENTS.md` must exist and reference Chief. If missing,
   tell the user to run `/chief-install` first and stop.
2. Check if `.chief/project.md` already exists.
   - If yes → ask the user: "`.chief/project.md` already exists. Update it / overwrite /
     cancel?"
   - If overwrite, back up the current file to `.chief/project.md.bak` before proceeding.
   - If update, read the current content first and treat the interview as a refinement pass.
   - If cancel, stop.
3. Create `.chief/` if it does not exist.

### 2. Confirm the storage location

Ask one question, even though there's only one working answer today — this stays visible
rather than silently defaulting, because the storage location is deliberately not fixed to
`.chief/` (see `docs/design/v5-ai-workflow.md`, "Storage backend"):

> "Planning artifacts (stories, rules, tickets) live under `.chief/` by default. Keep that, or
> use a different directory name?"

- **Keep `.chief/` (recommended, and the only backend that works today)** → do nothing further;
  no `.chief.config.md` is written. Its absence already means "use the default."
- **Different name** → write `.chief.config.md` at the repo root:

  ```markdown
  # Chief config

  storage-root: <the name they chose>/
  ```

  Then use that root for everything else this skill does (`<root>/project.md`, etc.) instead of
  `.chief/`.

Most projects should pick the default and end up with zero extra files from this step.

### 3. Interview the user

Walk through these topics, one short question at a time. Keep questions focused. Wait for the
answer before moving on. Skip a topic if the user says "skip" or "n/a".

- **Project name and one-line summary.**
- **Tech stack** — primary languages, frameworks, runtimes, databases, key libraries.
- **Dev commands** — how to install deps, run dev, run tests, lint, typecheck, build.
- **Architecture overview** — main patterns (e.g. Repository Pattern, Service Layer, hexagonal,
  monorepo, etc.).
- **Directory structure** — top-level folders and what they hold.
- **Important development rules** — conventions developers must follow (commit style, branch
  policy, formatting, testing requirements, etc.).

If the user is unsure about a topic, suggest reasonable defaults derived from files you can see
in the repo (`package.json`, `pyproject.toml`, `Cargo.toml`, `Makefile`, `README.md`, etc.) and
confirm.

### 4. Show a draft and confirm

Print the proposed `project.md` content as formatted markdown. Then ask once: "Write this to
`<storage-root>/project.md`?"

If the user requests changes, apply them and re-confirm. Do not loop more than three rounds — if
alignment is hard, write the current draft and tell the user they can edit it manually.

### 5. Write the file(s)

Write to `<storage-root>/project.md` (`.chief/project.md` unless step 2 set otherwise). Use this
structure (omit empty sections rather than leaving placeholder prose):

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

### 6. Next steps

Tell the user:

- `<storage-root>/project.md` is now set. Every `chief-*` skill reads it for project context.
- To start a story: `/chief-plan` (creates `<storage-root>/story-N/` lazily).
- To run autonomously once a story is planned: `/chief-autopilot`.
- Rules can be added later under `<storage-root>/_rules/_standard/`, `_contract/`, `_goal/`,
  `_verification/` — the first rule written creates the appropriate subfolder.

## Important rules

- This skill creates **only** `.chief/` (if missing), `project.md`, and — only if the user
  chose a non-default location — `.chief.config.md`. Do not scaffold stories, rule subfolders,
  or `_template/`.
- Never overwrite an existing `project.md` without explicit user confirmation; always back up to
  `.bak` first.
- If `AGENTS.md` doesn't reference Chief, do not proceed — direct the user to `/chief-install`.
- Keep the interview short. One focused question at a time, no compound questions.
- Reference: a canonical layout example lives at `docs/example-chief/` in the chief repo.
