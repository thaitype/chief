---
name: ask-chief
description: Ask which Chief skill fits your situation. A router over the chief-* skills, written for the human deciding what to run next — not an agent reference (that's /chief-explain).
disable-model-invocation: true
---

# Ask Chief

You don't remember every skill, so ask.

This is written to be **read by you**, the person deciding what to do next — not consulted
silently by the agent. When invoked, present the relevant part of this map back to the user in
plain language, matching their situation to a skill and saying why.

## The main flow: idea → shipped

The route most work travels, one story at a time.

1. **`/chief-plan`** starts every story. Its first question is whether to grill normally or
   hand off to **`/chief-wayfinder`** first — pick wayfinder when the idea has several
   unresolved design decisions or needs research/access before you could even state a goal;
   pick a normal grill otherwise. Either way, `/chief-plan` then walks you through **goal**
   (what this story delivers, plus what it deliberately doesn't) and **contract** (API shapes,
   data models, plus what testing this needs), with your approval at each step.
2. **`/chief-plan` breaks the approved contract into tickets** — vertical slices, each declaring
   what blocks it. You review the breakdown before anything gets built.
3. **`/chief-build <ticket>`** builds one ticket: TDD at the seams the contract named,
   typechecking and testing as it goes, `/chief-review-code` before every commit. Run it
   yourself per ticket, or let step 4 run it for you.
4. **`/chief-autopilot`** (or **`/chief-loop`** for a longer story) works the whole ticket
   frontier through `/chief-build` without you approving each one, stopping only when the goal
   is met **and** the contract is satisfied. Use `/chief-autopilot safe` if you want it to pause
   on ambiguity instead of deciding for itself.
5. **`/chief-test`** — only if you explicitly want real-environment validation (integration,
   UI, API, auth flows) beyond what `/chief-build` already ran locally. Never runs on its own.

### Controlled vs. autonomous

Run `/chief-plan` then `/chief-build` ticket by ticket when you want to review every step —
best for unfamiliar domains, complex stories, team work. Run `/chief-plan` then
`/chief-autopilot` when the goal is clear and well-scoped and you'd rather not — best for
prototyping and solo work. Mixing is normal: plan with gates, execute autonomously.

## On-ramps

Situations that feed into the main flow rather than starting inside it.

- **An idea with open design questions, before you're ready to plan** → **`/chief-grill`**
  (persistent, verifies each answer against your actual codebase — heavier, use when stakes are
  high) or **`/grill-design`** (lighter, no file, no verification — use for smaller decisions).
  Either way, feed the outcome into `/chief-plan`.
- **A problem or vision, not yet a concrete requirement** → **`/shape-up`** interviews you
  top-down (problem → solution → scope) into something bounded enough to grill or plan.
- **A goal or spec that turned out too big for one story** → **`/slim-down`** trims it to a
  phase-sized piece, keeping the rest for a later story.
- **A story too foggy to even name a goal** → **`/chief-wayfinder`** directly (or let
  `/chief-plan`'s Phase 0 offer it to you — see step 1 above).

## Before you rely on it running unattended

**`/loop-readiness`** reviews whether a story's plan has enough feedforward guidance and
feedback/verification to run safely as `/chief-loop` or `/chief-autopilot` for many tickets with
no one watching. It doesn't execute anything — just tells you what's present, missing, or
partial. Worth a look before turning a large story loose overnight.

## Codebase health and reflection

Not feature work — the upkeep that keeps future stories cheap.

- **`/chief-retro`** after a story (or a round of tickets): checks whether delivered work
  actually satisfies the goal and contract, captures lessons, proposes rules for `.chief/_rules/`
  — you choose which to keep.
- **`/chief-rule`** captures a decision as a permanent rule the moment you have one in mind,
  without waiting for a retro.
- **`/dump-commit`** for a quick, clean commit outside the ticket flow.

## Setup, once per project

There's no install step beyond getting the skills at all (`npx skills add thaitype/chief` or
equivalent) — nothing needs to be written to `AGENTS.md` for Chief to work.

- **`/chief-init`** — the natural first thing to run: bootstraps `project.md` and confirms
  where planning artifacts should live.
- **`/setup-agent-behavior`** — optional. Writes general (not Chief-specific) agent-conduct
  rules into `AGENTS.md` if you want them binding every session, rather than something you'd
  have to remember to ask for.
- **`/chief-migrate`** — only relevant once, coming from a v4 project: converts an
  in-progress v4 milestone into a v5 story. Asks before deleting the old one.

## When you need the structural facts, not a recommendation

**`/chief-explain`** is the reference for how Chief itself is laid out — directory structure,
storage-location resolution, what each skill owns. This skill (`/ask-chief`) tells you *what to
run*; `/chief-explain` tells you *how the pieces fit together*. Reach for `/chief-explain`
yourself if you want the detail; the agent may also pull it in on its own when it needs to.
