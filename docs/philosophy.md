# Design Philosophy

## Three Pillars of Working with AI

Effective AI-assisted development depends on three components working together:

- **Human** — Sets the goal, defines direction, and makes critical design decisions. The clearer the goal, the less back-and-forth needed. Templates and structured rules reduce the number of decisions you have to make.
- **Rules** — Encodes standards, contracts, and constraints so AI knows how to behave in your project. Architecture patterns, type safety, verification steps — all written down once, enforced every session.
- **AI** — Applies AI engineering techniques to work more effectively: agentic coding, multi-agent orchestration, and automatic feedback loops from external systems (type checkers, linters, tests). Better techniques mean more accurate results.

This framework provides the prompt and context structure. Coding agent selection and model selection are your own decisions.

## Why Structure Matters

When you use AI on a real project, the bottleneck isn't writing code — it's decision-making. Every AI interaction forces you to choose: which architecture, which pattern, which direction next.

Without structure, these decisions pile up. You make them ad-hoc, forget the reasoning, and lose consistency across sessions. The result is tech debt — not from bad code, but from scattered decisions that don't align.

Structure solves this by making decisions explicit and durable:

- **Rules** capture decisions once so they don't need to be re-made every session
- **Contracts** define boundaries so agents don't drift from agreed-upon designs
- **Milestones** break ambiguous goals into concrete, verifiable steps
- **Plans** record what to build and why, so context survives across sessions

The goal isn't to slow you down with process. It's to free your brain from tracking decisions so you can focus on the ones that actually matter.

## Core Execution Loop

The framework follows a repeating cycle:

```
Human defines direction →
  Chief-agent plans →
    Builder builds →
      Chief decides →
        Repeat
```

Tester is injected into the cycle only when the user explicitly requests real-world validation (integration tests, UI flows, API checks).

Each role has a clear boundary:

- **Human** — Sets goals, writes rules, makes judgment calls when agents surface ambiguity. Does not micromanage implementation.
- **Chief-agent** — Reads rules and goals, creates plans, breaks work into small tasks (3-5 at a time), delegates to builder, decides next steps.
- **Builder-agent** — Implements tasks, runs unit tests, fixes type/lint/build issues autonomously, commits code. Does not make architecture decisions.
- **Tester-agent** — Runs integration tests, validates APIs and UI flows, checks environment-level behavior. Does not write code or fix bugs. Only triggered when user requests it.

The separation keeps each agent focused and prevents slow feedback loops where one agent tries to do everything.

## Design Principles

### Minimal Human Intervention

Humans define direction, rules, and constraints. Agents handle execution. The system is designed so that a well-written set of rules and goals can drive multiple milestones with minimal human involvement.

### Contract-First

Before building anything, define the contracts — API schemas, data models, service boundaries. Agents check their work against contracts, not just tests. This catches design drift early.

### Small Batches

Chief-agent creates 3-5 tasks at a time, not an entire milestone's worth. This keeps plans adaptable — if something changes mid-milestone, you don't have a stale 20-task backlog to reconcile.

### Safety-First Escalation

When agents encounter ambiguity or multiple valid approaches, they stop and ask rather than guess. A wrong guess costs more than a short pause. Agents escalate to chief-agent, chief-agent escalates to human.

### Rules Hierarchy

Not all rules are equal. The framework enforces a clear priority:

1. `AGENTS.md` (highest authority)
2. `.chief/_rules/` (global rules)
3. `.chief/milestone-X/_goal/` (milestone-specific goals)

When rules conflict, higher authority wins. This prevents milestone-level exceptions from overriding project-wide standards.

## The Grill-Me Session

### Why It Exists

The hardest bugs to fix are the ones baked into the plan. If you start building on a vague goal or unexamined assumption, you'll discover the problem three tasks in — after code has been written, tests have been built, and changing direction means rework.

The grill-design session is a structured interview that forces clarity before building begins. It challenges your assumptions, surfaces hidden decisions, and resolves ambiguity up front — when the cost of changing your mind is zero.

### How It Works

Grill-design walks down each branch of the decision tree one question at a time. It doesn't accept vague answers — it pushes until there's a concrete, actionable decision. Each question builds on the previous answer, so by the end you have a complete picture rather than a collection of isolated choices.

### When to Use It

- **Filling in `project.md`** — When setting up a new project, grill-design interviews you about your tech stack, architecture, and dev commands to build a complete project configuration.
- **Before starting a milestone** — When a goal is ambiguous or has multiple valid approaches, use grill-design to resolve the decision tree before planning begins.
- **Stress-testing a plan** — When you have a plan but aren't confident in it, grill-design can challenge the assumptions and surface gaps you missed.
- **Design decisions** — When you're choosing between architectures, patterns, or approaches, grill-design forces you to articulate trade-offs rather than going with gut feeling.

The goal is to make decisions explicit and deliberate, not to slow you down. A 5-minute grill session can save hours of rework.
