---
name: setup-agent-behavior
description: Opt-in setup skill that writes a general (not Chief-specific) block of agent-conduct rules — think-before-acting, simplicity-first, surgical changes, goal-driven execution, single-question interaction — into AGENTS.md. Use when the user wants these principles binding every session rather than something to remember to ask for.
---

Write a general agent-conduct block into `AGENTS.md`, if the user wants it. This content isn't
specific to Chief — it's usable in any project — which is why it's a standalone skill rather
than something any other setup step installs automatically, and isn't Chief-prefixed. Nothing
in this skill is Chief-specific, and it has no dependency on Chief at all beyond `AGENTS.md`
existing.

## Steps

### 1. Check current state

Read the target `AGENTS.md`. If it doesn't exist, tell the user this skill only adds a section
to an existing file — ask if they want one created fresh (just this block, nothing else) or
stop so they can create their own first.

Check whether an `## Agent Behavior Principles` section already exists.

- **Already present** → tell the user it's already installed, show them the current content
  next to `template.md`'s (see Step 2), ask if they want to update it to the latest version or
  leave it. Do not reinstall over an existing block without asking — the user may have edited it.
- **Absent** → continue to Step 2.

### 2. Confirm

Read `template.md` in this skill's own folder — that file **is** the block, kept separate from
these instructions the same way `setup-matt-pocock-skills` keeps its seed templates (e.g.
`issue-tracker-local.md`) next to its own `SKILL.md`: one source of truth for the content,
editable without touching the procedure around it.

Show its content to the user, then ask once: "Install the general agent-conduct principles
(think-before-acting, simplicity-first, surgical changes, goal-driven execution,
single-question interaction) into `AGENTS.md`?" Show before asking, not after — the user should
see exactly what they're agreeing to.

### 3. Write

On approval, insert `template.md`'s content verbatim. Insert it near the top of the file,
before any `## Project Rules` section if one exists — this content is the user's own to edit
afterward, same as everything else in the file; nothing else in Chief reads or manages this
section, so there's no marker convention to observe here.

### 4. Report

Confirm the block was written and where. Remind the user this content is theirs to edit freely
— this skill only ever offers to install or update it, never enforces it silently.

## Rules

- NEVER write without the Step 2 confirmation.
- NEVER overwrite an existing block without asking first — the user may have customized it.
- NEVER touch anything outside the `## Agent Behavior Principles` / `## User Interaction Rules`
  section pair — not Project Rules, not anything else already in the file.
