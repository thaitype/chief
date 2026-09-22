# How to pick the right skill for your situation

Chief has multiple skills that serve different purposes. Use this guide to find the right one quickly.

---

## By job size

### Small — goal is already clear

```
/chief-plan
```

You know what you want. The skill grills you briefly, writes the goal and contract, and breaks the work into tickets. When ready, run `/chief-autopilot` to execute.

### Medium — need to clarify before planning

```
/chief-grill   →   /chief-plan
```

Your goal exists but has open design questions (architecture choices, trade-offs, unknowns). `/chief-grill` works through those questions with you — one at a time, with a background verifier checking your answers against the codebase. Feed the outcome into `/chief-plan`.

### Large — requirement is fuzzy or vision-level

```
/shape-up   →   /chief-grill   →   /slim-down   →   /chief-plan
```

You have a problem or vision but haven't turned it into concrete requirements. `/shape-up` interviews you top-down (from problem to solution) to produce a scoped spec. Then `/chief-grill` stress-tests that spec. If the scope is still too big, `/slim-down` cuts it into a phase-sized piece.

---

## By what you're trying to do

| You want to… | Use |
|---|---|
| Plan a story step by step | `/chief-plan` |
| Run a story hands-off | `/chief-autopilot` |
| Run a full story across as many rounds as it takes, one report per ticket | `/chief-loop` |
| Stress-test a design before building | `/chief-grill` or `/grill-design` |
| Turn a vague idea into a spec | `/shape-up` |
| Cut a goal down to a manageable phase | `/slim-down` |
| Check a plan is safe to run unattended | `/loop-readiness` |
| Actually run a plan's existing gates/tests before trusting them | `/loop-preflight` |
| Permanently capture a decision as a rule | `/chief-rule` |
| Bootstrap project context once | `/chief-init` |
| Review a story after it ships | `/chief-retro` |
| Make a quick commit | `/dump-commit` |

---

## Choosing between `/grill-design` and `/chief-grill`

Both stress-test ideas. The difference is persistence and verification depth.

| | `/grill-design` | `/chief-grill` |
|---|---|---|
| Session saved to file? | No — context only | Yes — `.chief/_grill/opened/` |
| Verifies answers against codebase? | No | Yes — spawns a throwaway verifier subagent per question |
| Token cost | Normal | ~2× (two agents running) |
| Best for | Quick design exploration | High-stakes decisions, sessions you might resume |

Use `/grill-design` for smaller ideas where you don't need audit trail or codebase verification. Use `/chief-grill` when the decision is consequential and you want each answer checked.

---

## Choosing between `/chief-plan` and `/chief-autopilot`

| | `/chief-plan` | `/chief-autopilot` |
|---|---|---|
| Review gates? | Yes — approve at each phase | No — runs to completion |
| Requires existing goals/contracts? | No — creates them | Yes (or creates them and runs immediately) |
| Best for | Complex projects, team work, unfamiliar domains | Prototyping, well-defined goals, solo work |

You can combine: plan carefully with `/chief-plan`, then execute with `/chief-autopilot`.

---

## Choosing between `/chief-autopilot` and `/chief-loop`

`/chief-loop` builds directly on `/chief-autopilot`'s auto mode — same no-stopping-for-ambiguity behavior, but it spans as many rounds as it takes to finish the story (not just one), and writes a report per ticket instead of one per batch. Use `/loop-readiness` first if the story is large or touches anything you'd want a real-environment check on before letting it run unattended for that long — and if it finds pre-existing gates the story depends on, follow up with `/loop-preflight` to actually confirm those still pass before starting `/chief-loop`.

If you want the "stop and ask a human on ambiguity" behavior, use `/chief-autopilot safe` instead — `/chief-loop` has no safe-mode equivalent.

---

## Related

- [Skills reference](../reference/skills.md) — Full list of all skills with parameters
- [How to stress-test a design](stress-test-a-design.md)
