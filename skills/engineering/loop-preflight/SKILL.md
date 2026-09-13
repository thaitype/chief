---
name: loop-preflight
description: Actually run a loop's pre-existing feedback mechanisms (gate scripts, test suites, checks inherited from prior work) before the loop starts, to confirm they still work — not just that the plan describes them. Use before starting an unattended loop (chief-loop or similar) when the plan depends on feedback that already exists, rather than feedback the loop will build fresh. Complements `loop-readiness`, which reviews the plan statically and never executes anything — this skill is the one that actually runs things.
---

# Loop preflight

`loop-readiness` reviews a plan's feedback mechanisms *statically* — it can confirm a
gate script is described in the plan, but by its own rule it never executes anything, so
it can't confirm the gate still actually runs. This skill fills that gap: it runs the
plan's existing feedback mechanisms for real, once, before the loop starts.

A gate can be described accurately in the plan and still be broken — an unrelated change
landing between when the plan was written and when the loop actually starts can silently
break something the plan assumes still works (e.g. a hardcoded path getting renamed
elsewhere). Only actually running the check reveals that; a static read of the plan
cannot.

This is a standalone check. Run it whenever a loop depends on pre-existing feedback,
whether or not `loop-readiness` was run first — `loop-readiness`'s own report should
point here when it finds feedback the plan treats as already in place.

## Step 1: Identify

From the plan (or a list the user gives directly), identify the concrete commands that
are pre-existing verification the plan depends on — gate scripts, test suites, lint/type
checks cited as feedback. This does **not** include the loop's actual work (deploy
steps, migrations, code changes) — only the checks that trigger these to feedback about
plan-driven work already have to keep passing.

List the identified commands back to the user before running anything. Don't assume;
confirm the list is right and complete.

## Step 2: Guardrails, then run

Before running each confirmed command:

- **Scope check** — only run commands identified in Step 1 as pre-existing feedback.
  Never run anything else from the plan (a deploy step, a migration, a data write) even
  if it's nearby in the same file or the user's earlier go-ahead was general.
- **Production check** — if a command's path, arguments, or target look
  production-related (e.g. references something named `prod`, or a shared/live system),
  stop and confirm with the user specifically before running that one — even if they
  already agreed to run the batch as a whole. A general "yes, run them" from Step 1
  isn't informed consent for a specific command that turns out to touch something live.

Run each confirmed, in-scope, cleared command for real, in the actual environment the
loop will operate in (not a substitute or sandboxed copy) — the point is confirming the
real thing works. Capture the exit code and output.

## Step 3: Report

For each command: pass or fail, with the actual output/error on failure — not just "the
gate is present." A failure here is a real, confirmed blocker, not a recommendation to
weigh; report it as one.

## Relationship to `loop-readiness`

Separate skill, no shared state or file. `loop-readiness` keeps its own "never execute"
rule fully intact — this skill exists precisely so that rule doesn't have to bend.
