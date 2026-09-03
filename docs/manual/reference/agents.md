# chief-* execution skills reference

v5 has **no persistent subagent roster**. What v4 shipped as four `.agents/agents/*.md` files
(`chief-agent`, `builder-agent`, `tester-agent`, `answer-verifier-agent`) are now `chief-*`
skills. Each still has a defined role and clear boundaries — they don't cross into each other's
territory — but there's nothing to install separately anymore: a skill spawns its own throwaway
subagent when it needs isolated context, rather than referencing a registered agent type.

---

## `/chief-plan`

**Role:** Planner.

Offers a grill-vs-`/chief-wayfinder` choice, then writes the story's goal and contract, then
breaks the work into tickets. Waits for approval at every phase.

Does **not** write code.

---

## `/chief-wayfinder`

**Role:** Fog-charter.

Optional. Charts a story's open decisions as a map of decision-tickets when it's too foggy for
one grill session, resolves them one at a time. Feeds `/chief-plan`'s goal/contract phases —
never loops straight into implementation itself.

Does **not** write the goal or contract itself, and does **not** write code.

---

## `/chief-build`

**Role:** Implementer. Replaces `builder-agent`.

Given one ticket, drives TDD at pre-agreed seams, typechecks and runs tests as it goes, runs
`/chief-review-code`, and commits. All fast, local, deterministic verification is its
responsibility.

Does **not** decide what's next, and does **not** decide whether the story is done — that's
`/chief-loop`/`/chief-autopilot`'s job even when they're the ones spawning it.

**When to call:**
```
/chief-build 1-3
```

Or automatically, spawned per ticket by `/chief-loop`/`/chief-autopilot`.

---

## `/chief-test`

**Role:** Real-world verifier. Replaces `tester-agent`.

Runs integration tests, validates API responses, tests UI flows, checks environment-level
behavior. Handles slow, non-deterministic, real-world verification that `/chief-build` doesn't
touch.

Does **not** write code. Does **not** run unit tests, lint, or build.

**Only triggered when you explicitly request it** — `/chief-loop`/`/chief-autopilot` never call
it automatically.

**When to call:**
```
/chief-test story-1
```

Use when unit tests aren't enough and you need real-world coverage.

---

## `/chief-review-code`

**Role:** Two-axis reviewer.

Reviews a diff along Standards (does it follow `.chief/_rules/_standard` + a Fowler-smell
baseline?) and Spec (does it faithfully implement the story's goal/contract?) — run as two
parallel throwaway sub-agents, reported separately.

Called automatically as the last beat of `/chief-build`, before commit. Also directly
invocable.

---

## The verifier pattern (was `answer-verifier-agent`)

`/chief-grill` and `/chief-wayfinder`'s `grilling`-type tickets both need to check a per-answer
claim against the actual codebase, in the background, with narrow context (just the current
question, not the whole session). v4 shipped this as a standing agent file
(`answer-verifier-agent`) that both could reference by name.

v5 folds the same prompt inline into each skill instead — spawned fresh, per call, as a plain
throwaway `Agent` invocation. No registered agent type, and nothing to install: the prompt is
the appendix in `chief-grill`'s own `SKILL.md`.

> This pattern replaced `review-plan-agent` (deprecated in v4), then the standalone
> `answer-verifier-agent` file itself was folded inline in v5.

---

## Compatibility

| Coding agent | How `chief-*` skills are wired |
|---|---|
| Claude Code | `CLAUDE.md → AGENTS.md` symlink; skills installed via `npx skills` |
| GitHub Copilot | Reads `AGENTS.md` directly; skills installed via `npx skills` |
| Other agents | Read `AGENTS.md` directly (if supported); skills installed via `npx skills` |

`/chief-install` only ever wires `AGENTS.md` (and, for Claude Code, the `CLAUDE.md` pointer) —
there's no per-agent subagent-file wiring left to do.
