# The separation of concerns (was: the three-agent model)

Chief keeps three distinct roles separate: planning, building, and real-world verification. In
v4 this separation was enforced by three (then four) persistent subagent files. In v5 it's
enforced by three (then more) `chief-*` skills instead — same boundaries, no standing roster to
install. See [chief-* execution skills reference](../reference/agents.md) for what replaced
what.

## Why separate roles at all?

A single general-purpose agent that plans, builds, tests, and decides is appealing in theory. In
practice, it creates feedback loops that don't converge. An agent that writes code, then tests
it, then decides whether the tests are good enough, and then plans what to fix — all in one
context — is doing too much. Each role bleeds into the next. The agent loses the ability to be
honest about quality, because it's emotionally (context-wise) invested in the code it just
wrote.

Separate roles avoid this. Each has a defined scope, and can give an honest, unbiased assessment
of work it didn't produce.

## The roles

### Planner — `/chief-plan`, `/chief-wayfinder`

Reads rules, resolves fog, writes the goal and contract. Breaks work into tickets. When
something is ambiguous, it escalates to the human rather than guessing.

The planner does **not** write code. If it starts implementing, it's drifting out of role. The
discipline of "plan, then build" keeps each role honest.

### Builder — `/chief-build`

Given one ticket, implements it. Runs unit tests, fixes type and lint errors, runs
`/chief-review-code`, and commits. All fast, local, deterministic verification is the builder's
responsibility.

The builder does **not** make architecture decisions. If it encounters one (which library?
which pattern?), it escalates rather than guessing — to the human directly if invoked that way,
or back to `/chief-loop`/`/chief-autopilot` if they spawned it. It builds what it was told to
build, exactly, and never decides what ticket comes next.

### Real-world verifier — `/chief-test`

Runs integration tests, validates API responses, tests UI flows — anything that needs a real
environment. It handles slow, non-deterministic, environment-level checks that can't run inside
a fast unit test.

It does **not** write code, and does not fix bugs it finds — it reports them. It does not run
unit tests (that's the builder's job). And crucially: **it's only triggered when you explicitly
ask for it.** `/chief-loop`/`/chief-autopilot` never auto-delegate to it, because real-world
test runs are slow and expensive.

## The verifier pattern

`/chief-grill` and `/chief-wayfinder`'s `grilling`-type tickets both need a narrow, per-answer
codebase check while a live grill session continues — whether an answer given is actually
supported by the codebase, not just plausible in general. This runs as a throwaway subagent,
spawned fresh per question with only that question in context (not the full session), so it
can't be biased by prior answers. There's no standing file behind it in v5 — the prompt lives
inline in whichever skill spawns it.

## The boundary that matters most

The most important boundary is between the real-world verifier and everyone else: **unit tests,
lint, type checks, and build are the builder's job; integration and real-world validation are
the verifier's job.**

This gets violated most often when people fold integration-test steps into a ticket meant for
`/chief-build`. That creates slow feedback loops and non-deterministic behavior inside what
should be a fast, local verification step. Keep them separate.

## When to involve `/chief-test`

- After a story with user-facing behavior or an API surface
- When the team needs confidence before a deploy
- When something that should work doesn't, and unit tests pass

Never automatically. Always by explicit request.

---

See also: [Why Chief exists](why-chief.md), [Pre-coding first](pre-coding-first.md),
[chief-* execution skills reference](../reference/agents.md)
