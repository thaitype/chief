# Your first story with Chief

In this tutorial, we will get the Chief skills into an existing project, set up project
context, plan a story, and hand it off to an AI agent to build — start to finish.

By the end, you will have:

- The Chief skills available in your coding agent
- A `.chief/project.md` with your project's context
- A planned story with a goal, a contract, and tickets
- Code committed by `/chief-build`

This tutorial uses **Claude Code** as the coding agent. The steps are the same for other
agents — there's no agent-specific setup at all in v5, skills work the same everywhere once
installed.

---

## Step 1 — Install the Chief skills

In a terminal inside your project:

```bash
npx skills@latest add thaitype/chief
```

The picker opens. Select all skills (press Space on each, or press `a` to select all).

That's it — there's no separate install step to run afterward. `.chief/` doesn't exist yet
(that's intentional, Chief creates it only when you need it), and nothing gets written to
`AGENTS.md` — every `chief-*` slash command already works.

> If you only want specific skills, select the ones you plan to use (e.g. `chief-plan`,
> `chief-grill`).

---

## Step 2 — Bootstrap project context

Run:

```
/chief-init
```

The skill interviews you about your project. It asks things like:

- What language and framework are you using?
- What does `npm run dev` look like?
- What are the key architectural constraints?

It also confirms where planning artifacts should live — keep the default (`.chief/`) unless you
have a reason not to; most projects do, and get no extra file from this step.

Answer in plain sentences — the skill writes the answers to `.chief/project.md`. Every
`chief-*` skill reads this file before doing anything, so they start every session already
knowing your project.

> You can skip this step and write `.chief/project.md` by hand later. But a 2-minute interview
> now saves repeating yourself every chat.

---

## Step 3 — Plan a story

Now plan what you're building. A **story** is Chief's unit of work — sized like a single
issue/ticket in any tracker (GitHub, Jira, ClickUp), not like a big multi-week "Milestone" —
see [why it's called that](../explanation/why-chief.md) if you're used to the v4 name.

If you know exactly what you want, go straight to planning:

```
/chief-plan
```

`/chief-plan`'s first question is whether to grill normally or use `/chief-wayfinder` first. If
your goal is still fuzzy, or there are several unresolved design decisions in the way, pick
wayfinder — it charts the open decisions as a map and resolves them one at a time before coming
back here. Otherwise, pick a normal grill.

`/chief-plan` then guides you through:

1. **Goal** — What this story delivers, plus what it deliberately doesn't (Out of Scope). You
   review and approve.
2. **Contract** — API shapes, data models, constraints, plus what testing this story needs
   (Testing Decisions). You review and approve.
3. **Tickets** — Vertical-slice units of work for `/chief-build` to implement, each declaring
   what blocks it. You review and approve.

At each step, the skill waits for your sign-off before proceeding.

---

## Step 4 — Build

With the plan approved, build a ticket:

```
/chief-build 1
```

Or, if you want the agent to work through every ticket autonomously:

```
/chief-autopilot
```

`/chief-autopilot` reads the goal and contract, works the ticket frontier (any ticket whose
blockers are already resolved) via `/chief-build`, and repeats until the goal is met **and**
the contract is satisfied. Use this when the plan is clear and you don't need to approve each
step.

---

## Step 5 — Reflect

After the story is done, run a retrospective:

```
/chief-retro
```

The skill compares what was delivered to what was planned, surfaces lessons learned, and
proposes any new rules that should be added to `.chief/_rules/`. You choose which ones to keep.

Rules added here apply to every future story — so the same mistake doesn't happen twice.

---

## What you built

Your project now has:

```
project/
├── AGENTS.md               ← optional, entirely your own — not shown here unless you made one
├── .chief/
│   ├── project.md          ← your project context (written by /chief-init)
│   └── story-1/
│       ├── _goal/          ← what this story delivers + Out of Scope
│       ├── _contract/      ← agreed API shapes/constraints + Testing Decisions
│       ├── _tickets/       ← ticket breakdown (blocking edges, status)
│       └── _report/        ← ticket reports, retro output
```

From this point, every future story follows the same shape. Your agents already know where to
read, where to write, and what the rules are.

---

## Next steps

- [How to pick the right skill for your situation](../how-to/pick-the-right-skill.md)
- [How to capture a decision as a permanent rule](../how-to/capture-a-rule.md)
- [Why Chief exists](../explanation/why-chief.md)
