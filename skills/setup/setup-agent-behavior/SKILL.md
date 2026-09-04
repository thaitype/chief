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

- **Already present** → tell the user it's already installed, show them the current content,
  ask if they want to update it to the latest version (see Step 3) or leave it. Do not
  reinstall over an existing block without asking — the user may have edited it.
- **Absent** → continue to Step 2.

### 2. Confirm

Ask once: "Install the general agent-conduct principles (think-before-acting, simplicity-first,
surgical changes, goal-driven execution, single-question interaction) into `AGENTS.md`?" Show
the block from Step 3 before asking, not after — the user should see exactly what they're
agreeing to.

### 3. The block

```markdown
## Agent Behavior Principles

### 1. Think Before Acting

- Start with the smallest plausible interpretation of the request.
- If uncertain, ask ONE clarifying question — don't assume the big interpretation.
- Surface tradeoffs and push back when a simpler approach exists.
- When confused, name what's unclear and stop. Don't hide confusion behind a plan.

### 2. Simplicity First

- Do the minimum that solves the problem. Nothing speculative.
- If a task can be done in 1-3 commands, do it directly. Don't delegate trivial work needlessly.
- No features, abstractions, or error handling beyond what was asked.
- If a plan starts needing an options table, pause — you may not have understood the question.

### 3. Surgical Changes

- Touch only what the request requires. Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken. Match existing style.
- Every changed line should trace directly to the user's request.
- Clean up only what YOUR changes made unused. Don't remove pre-existing dead code unless asked.

### 4. Goal-Driven Execution

- Transform vague requests into verifiable goals before starting.
- Define what "done" looks like. Loop until verified.
- For multi-step work, state a brief plan with verification at each step.
- Strong success criteria let agents work independently. Weak criteria require constant clarification.

## User Interaction Rules

- When asking the user a question, use ask_user with ONE short question only.
- When presenting a recap, summary, or review:
  1. Print it as formatted text first (numbered list, table, or markdown block).
  2. Then ask_user ONCE with a short confirmation, e.g. "Proceed?" or "Any changes?"
  3. NEVER put recap content inside ask_user.
- Do NOT ask multiple questions in a row. Make a recommendation, summarize, then confirm once.
```

### 4. Write

On approval, insert the block. Placement follows the same marker convention as everything else
`AGENTS.md`-related:

- If `AGENTS.md` has `<!-- chief-framework:begin -->` / `<!-- chief-framework:end -->`
  markers, insert the block **immediately after the opening marker**, before whatever the
  framework block already contains — this content isn't Chief-specific, so it doesn't belong
  nested inside a Chief-only subsection, but it also isn't the user's own Project Rules, so it
  doesn't belong below that boundary either. Placing it at the top of the framework-managed
  region keeps it easy to find and easy for `/chief-upgrade` to leave alone (upgrade only
  touches Chief's own content, never this block).
- If there are no markers at all, insert it near the top of the file, before any
  `## Project Rules` section if one exists.

### 5. Report

Confirm the block was written and where. Remind the user this content is theirs to edit freely
— this skill only ever offers to install or update it, never enforces it silently.

## Rules

- NEVER write without the Step 2 confirmation.
- NEVER overwrite an existing block without asking first — the user may have customized it.
- NEVER touch anything outside the `## Agent Behavior Principles` / `## User Interaction Rules`
  section pair — not Project Rules, not any Chief framework content.
- This skill has no dependency on Chief being installed beyond `AGENTS.md` existing — the
  content itself never mentions Chief.
