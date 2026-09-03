---
name: chief-review-code
description: Two-axis review of the diff since a fixed point — Standards (does it follow .chief/_rules/_standard and a Fowler-smell baseline?) and Spec (does it faithfully implement the ticket's story goal/contract?). Runs both axes as parallel throwaway sub-agents so neither pollutes the other's context, reports them separately. Called by /chief-build before every commit; also directly invocable.
---

# Chief Review Code

Two-axis review of the diff between `HEAD` and a fixed point:

- **Standards**: does the diff follow `.chief/_rules/_standard/**` and the smell baseline below?
- **Spec**: does the diff faithfully implement what the ticket's story goal/contract asked for?

Both axes run as **parallel throwaway sub-agents** so neither pollutes the other's context, then
this skill aggregates their findings side by side — never merged, never re-ranked against each
other (see "Why two axes").

## Process

### 1. Pin the fixed point

If invoked from `/chief-build`, the fixed point is the commit the story branch was at before
this ticket's work started. If invoked directly by a human, use whatever they specify (a commit
SHA, branch, tag, `main`, `HEAD~5`); if they didn't specify one, ask.

Capture `git diff <fixed-point>...HEAD` (three-dot, against the merge-base) and
`git log <fixed-point>..HEAD --oneline`. Confirm the fixed point resolves
(`git rev-parse <fixed-point>`) and the diff is non-empty before spawning anything — a bad ref
or empty diff should fail here, not inside two parallel sub-agents.

### 2. Identify the spec source

- If a ticket ID was given (or is inferable from the branch/current story), read that ticket's
  originating story: `.chief/story-N/_goal/goal.md` and `.chief/story-N/_contract/contract.md`.
- If no story is inferable, ask which story this diff belongs to.
- If the user says there isn't one, the Spec sub-agent skips and reports "no spec available."

### 3. Identify the standards sources

`.chief/_rules/_standard/**`, plus anything else the repo documents (e.g. `CONTRIBUTING.md`).

On top of whatever's documented, the Standards axis always carries this **smell baseline** — a
fixed set of Fowler code smells (*Refactoring*, ch. 3) that applies even when a repo documents
nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something
  the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"),
  never a hard violation. Skip anything tooling already enforces.

| Smell | What it is | Fix |
|---|---|---|
| Mysterious Name | a name that doesn't reveal what it does or holds | rename; if no honest name comes, the design's murky |
| Duplicated Code | the same logic shape in more than one hunk/file | extract the shared shape, call it from both |
| Feature Envy | a method reaching into another object's data more than its own | move the method onto the data it envies |
| Data Clumps | the same few fields/params keep travelling together | bundle into one type, pass that |
| Primitive Obsession | a primitive/string standing in for a domain concept | give the concept its own small type |
| Repeated Switches | the same switch/if-cascade on the same type recurs | polymorphism, or one shared map |
| Shotgun Surgery | one logical change forces scattered edits across many files | gather what changes together into one module |
| Divergent Change | one file/module edited for several unrelated reasons | split so each module changes for one reason |
| Speculative Generality | abstraction/params/hooks added for needs the spec doesn't have | delete it; inline back until a real need shows |
| Message Chains | long `a.b().c().d()` navigation the caller shouldn't depend on | hide the walk behind one method on the first object |
| Middle Man | a class/function that mostly just delegates onward | cut it, call the real target direct |
| Refused Bequest | a subclass/implementer that ignores/overrides most of what it inherits | drop the inheritance, use composition |

### 4. Spawn both sub-agents in parallel

**Standards sub-agent prompt** includes: the diff command + commit list; the standards-source
files found in step 3 **plus the smell baseline table pasted in full** (the sub-agent has no
other access to it); the brief — "Report, per file/hunk where relevant, (a) every place the diff
violates a documented standard, citing the standard (file + rule), and (b) any baseline smell
spotted, named, with the hunk quoted. Distinguish hard violations (documented-standard breaches)
from judgement calls (baseline smells are always judgement calls; a documented repo standard
overrides the baseline). Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** includes: the diff command + commit list; the fetched contents of
`goal.md` and `contract.md` for the story; the brief — "Report: (a) requirements the goal or
contract asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for
(scope creep); (c) requirements that look implemented but where the implementation looks wrong.
Quote the goal/contract line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly
cleaned. Do **not** merge or rerank findings across axes. End with a one-line summary: total
findings per axis, and the worst issue *within each axis* (if any) — never a single winner
across both.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the ticket asked but breaks the project's conventions → **Spec
  pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
