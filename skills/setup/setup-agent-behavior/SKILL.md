---
name: setup-agent-behavior
description: Opt-in setup skill that writes a general (not Chief-specific) block of agent-conduct rules — think-before-acting, simplicity-first, surgical changes, goal-driven execution, single-question interaction — into AGENTS.md. Use when the user wants these principles binding every session rather than something to remember to ask for.
---

Write a general agent-conduct block into `AGENTS.md`, if the user wants it. This content isn't
specific to Chief — it's usable in any project — which is why it isn't installed automatically
by `/chief-install` and isn't Chief-prefixed. Nothing in this skill is Chief-specific.

## Steps

### 1. Check current state

Read the target `AGENTS.md` (create-if-missing is not this skill's job — if it doesn't exist,
tell the user to run `/chief-install` or create one first, then stop).

Check whether an `## Agent Behavior Principles` section already exists.

- **Already present** → tell the user it's already installed, show them the current content
  next to `template.md`'s (see Step 2), ask if they want to update it to the latest version or
  leave it. Do not reinstall over an existing block without asking — the user may have edited it.
- **Absent** → continue to Step 2.

### 2. Confirm

Read `template.md` in this skill's own folder — that file **is** the block, kept separate from
these instructions the same way `chief-install`/`chief-upgrade` keep `template/AGENTS.md`
separate from their own steps (and the way `setup-matt-pocock-skills` keeps its seed templates
like `issue-tracker-local.md` next to its own `SKILL.md`): one source of truth for the content,
editable without touching the procedure around it.

Show its content to the user, then ask once: "Install the general agent-conduct principles
(think-before-acting, simplicity-first, surgical changes, goal-driven execution,
single-question interaction) into `AGENTS.md`?" Show before asking, not after — the user should
see exactly what they're agreeing to.

### 3. Write

On approval, insert `template.md`'s content verbatim. Placement follows the same marker
convention as everything else `AGENTS.md`-related:

- If `AGENTS.md` has `<!-- chief-framework:begin -->` / `<!-- chief-framework:end -->`
  markers, insert the block **immediately after the opening marker**, before whatever the
  framework block already contains — this content isn't Chief-specific, so it doesn't belong
  nested inside a Chief-only subsection, but it also isn't the user's own Project Rules, so it
  doesn't belong below that boundary either. Placing it at the top of the framework-managed
  region keeps it easy to find and easy for `/chief-upgrade` to leave alone (upgrade only
  touches Chief's own content, never this block).
- If there are no markers at all, insert it near the top of the file, before any
  `## Project Rules` section if one exists.

### 4. Report

Confirm the block was written and where. Remind the user this content is theirs to edit freely
— this skill only ever offers to install or update it, never enforces it silently.

## Rules

- NEVER write without the Step 2 confirmation.
- NEVER overwrite an existing block without asking first — the user may have customized it.
- NEVER touch anything outside the `## Agent Behavior Principles` / `## User Interaction Rules`
  section pair — not Project Rules, not any Chief framework content.
- This skill has no dependency on Chief being installed beyond `AGENTS.md` existing — the
  content itself never mentions Chief.
