---
name: slim-down
description: Cut an over-engineered plan down to one achievable increment. Reads the current codebase to understand what exists, then trims scope to the smallest useful step that still scales. Use when user says "slim down", "too much", "over-engineered", "simplify the plan", "what's the MVP", "cut scope".
---

# Slim Down — Cut Scope, Keep Scale

Take a plan or design that's grown too big and cut it down to **one increment** — the smallest step that delivers value and doesn't block future growth.

**Make it work before make it great — but never paint yourself into a corner.**

## When to Use

- When a plan or design feels over-engineered
- When user says "this is too much", "what do I actually need first?", "MVP"
- Any time scope has ballooned beyond what's practical to build next

## Core Principle

**Cut scope, not corners.** Remove features, not quality. The increment should be small but extensible — no dead-ends, no "throw it away later."

## Workflow

### Step 1: Read the Ground

Before cutting anything, understand what already exists:

- Read the current codebase — what's built, what patterns are in use
- Read the plan/grill result/spec that needs slimming
- Identify what's **new work** vs **already done or partially done**

Summarize in a short block:
- **Current state** — what exists today (2-3 lines)
- **Full goal** — what the plan wants to achieve
- **Gap** — what's missing between current state and full goal

### Step 2: Identify the Core

Ask: **"What is the one thing this plan must deliver to be useful?"**

Draft a single sentence describing the core value. Show it to the user. This is the anchor — everything else gets judged against it.

### Step 3: Sort Into Keep / Defer / Drop

Take every item from the plan and sort it:

| | Criteria |
|---|---|
| **Keep** | Required for the core to work. Can't ship without it. |
| **Defer** | Valuable but not needed yet. Design so it can be added later. |
| **Drop** | Nice-to-have, speculative, or solves a problem that doesn't exist yet. |

Show the table. Let the user move things around.

**Rules for sorting:**
- If it's only needed at 10x scale → **Defer**
- If it handles an edge case that hasn't happened → **Defer**
- If removing it doesn't break the core → **Defer**
- If it adds a new abstraction layer "for flexibility" → **Drop** unless proven needed
- If current code already handles it partially → **Keep** (finish, don't redo)

### Step 4: Check Scalability

For each **Defer** item, verify:
- Does the **Keep** list block it from being added later?
- Does the current increment create a dead-end that forces a rewrite?

If yes → move that item back to **Keep** or adjust the design.

If the user asks "will this scale?" — answer honestly based on the code, not hypotheticals.

### Step 5: Write the Increment

Co-write a short definition of what to build:

- **Goal** — one sentence
- **Delivers** — bullet list of Keep items
- **Deferred** — bullet list of Defer items (so nothing is forgotten)
- **Out** — what's dropped and why
- **Done when** — how to verify it's complete

Write to a file if the user wants. Otherwise just confirm alignment.

## How to Cut (not gut)

- **Respect existing code.** Don't propose replacing what works. Build on it.
- **Defer > Drop.** Dropping feels permanent. Deferring keeps options open and the user at ease.
- **Show the path.** When deferring something, briefly note how the current design leaves room for it.
- **Be specific.** "Defer auth" is vague. "Defer OAuth — use API key for now, auth middleware interface stays the same" is actionable.

## What NOT to Do

- Don't add new features while slimming down
- Don't redesign the architecture — work with what's there
- Don't say "just do an MVP" without defining what that means concretely
- Don't cut things the user already built — that's wasted work, not saved scope
- Don't assume the user wants the cheapest option — they want the smallest **useful** one
