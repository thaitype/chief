---
name: design-spec
description: Co-write a top-down design spec for software projects. Starts from vision and works down through scope, building blocks, and draft specs. Use when user wants to design a system, plan a project, write a design spec, or needs to see the big picture before diving into details. Prevents losing focus on large projects by enforcing layer-by-layer progression.
---
# Design Spec — Top-Down Co-Writing

Help the user co-write a design spec by working **top-down**: start from the big picture, confirm alignment at each layer, then go deeper. This is NOT an interview — it's collaborative writing where the agent drafts and the user shapes.

## When to Use

- User says "design spec", "let's design", "plan a system", "I need to think through this"
- User has a large or ambiguous project and needs to see the big picture first
- Before `/grill-me` — when the scope isn't clear enough to grill on details yet

## Core Principle

**One layer at a time. Confirm before going deeper. Never jump ahead.**

If the user can't answer something at the current layer, mark it `[TBD]` and move on. Don't drill down into unknowns — that's how people lose focus.

## Workflow

### Layer 1: Vision

Ask the user to describe what they're building in plain language. Then co-write a short vision block:

- **What** — one sentence describing the thing
- **Why** — what problem it solves, who it's for
- **Done looks like** — how you'd know it succeeded

Draft this as a short block (5-8 lines max). Show it to the user. Adjust until they say it's right.

Do NOT ask about tech stack, architecture, or implementation yet.

### Layer 2: Scope

Now that the vision is clear, co-write the scope:

- **In scope** — what this project will do (bullet list)
- **Out of scope** — what it explicitly won't do (bullet list)
- **Constraints** — timeline, tech, team, budget, dependencies
- **Users / Actors** — who interacts with it

Draft and show. The user cuts, adds, moves things between in/out scope. Keep going until scope feels tight.

If scope is getting too big, say so: *"This feels like it's growing — want to split it?"*

### Layer 3: Building Blocks

Break the in-scope work into 3-7 big blocks. Each block is a major component, feature area, or workstream. For each block:

- **Name** — short label
- **Purpose** — one line
- **Depends on** — which other blocks it needs

Show as a simple list or diagram. The user rearranges, renames, merges, splits. This is the skeleton — no detail yet.

If a block is unclear, mark it `[TBD]` and keep going. Don't stop the whole flow for one unknown.

### Layer 4: Draft Spec

For each block (in order the user chooses), co-write a short spec:

- What it does
- Key decisions or trade-offs
- Open questions

Each block spec should be **half a page to one page max**. If it's getting longer, it probably needs to be split into smaller blocks — go back to Layer 3.

The user can stop at any point and say "that's enough for now." Respect that. Not every block needs a spec in the first pass.

### Output

Write the spec to a file. The user decides the filename and location. If the user doesn't specify, suggest `design-spec.md` in the current directory.

The spec can have multiple drafts — e.g., `draft/phase-1.md`, `draft/final-spec.md`. Follow the user's lead on structure.

## How to Co-Write (not interview)

- **Draft first, ask second.** Don't open with a list of questions. Write a rough version based on what you know, then let the user correct it.
- **Show, don't ask.** Instead of "what should the scope be?", write a scope and say "this is what I'm hearing — what's wrong?"
- **Keep momentum.** If the user gives a vague answer, write your best interpretation and move on. They'll correct you if it's wrong.
- **Short blocks.** Each layer's output should fit on one screen. If you're writing more than that, you've gone too deep.

## What NOT to Do

- Don't start with 10 clarifying questions (that's grill-me's job)
- Don't discuss implementation details in Layer 1-2
- Don't expand `[TBD]` items unless the user asks
- Don't write a full spec in one shot — layer by layer
- Don't keep going deeper if the user hasn't confirmed the current layer
