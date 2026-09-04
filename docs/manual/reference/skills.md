# Skills reference

Skills are installed via `npx skills@latest add thaitype/chief`. Each skill is a prompt
injected into your coding agent when you run the slash command.

---

## Chief workflow skills

### `/chief-init`

Bootstraps project context for a new project.

Interviews you about your tech stack, architecture, dev commands, and key constraints. Writes
the answers to `.chief/project.md`. Also confirms where planning artifacts should live (keep
the default `.chief/` unless you have a reason not to). Every `chief-*` skill reads
`project.md` at the start of every session.

Run once when setting up a project, or re-run to update project context.

---

### `/chief-wayfinder`

Optional. Charts a story's open decisions as a map of decision-tickets when it's too foggy for
one grill session, and resolves them one at a time.

Offered as a choice at `/chief-plan`'s Phase 0 (so you don't need to already know it exists),
or callable directly at any point in a story's life. Scoped to one story — never spans several.
Feeds `/chief-plan`'s goal/contract phases; doesn't loop straight into implementation.

---

### `/chief-plan`

Plans a story end-to-end with review gates.

Phases, in order:

1. **Grill or `/chief-wayfinder`** — your choice, up front
2. **Goal** — writes `.chief/story-N/_goal/goal.md` (plus Out of Scope)
3. **Contract** — writes `.chief/story-N/_contract/contract.md` (plus Testing Decisions)
4. **Tickets** — vertical-slice breakdown for `/chief-build`, each with blocking edges

Waits for your approval after each phase before proceeding.

---

### `/chief-build`

Builds one ticket. Replaces `builder-agent`.

Drives TDD at pre-agreed seams, typechecks and runs tests as it goes, runs
`/chief-review-code`, and commits. Never decides what's next or whether the story is done.

Invoke directly (`/chief-build 3`) or let `/chief-loop`/`/chief-autopilot` spawn it per
ticket, in its own isolated context.

---

### `/chief-test`

Long-running/integration/UI/API/environment verification. Replaces `tester-agent`.

Never runs unit tests, lint, or build — that's `/chief-build`'s job. Only triggered when you
explicitly ask for it; `/chief-loop`/`/chief-autopilot` never call it automatically.

---

### `/chief-review-code`

Two-axis review of a diff: Standards (`.chief/_rules/_standard` + a Fowler-smell baseline) and
Spec (the story's goal/contract), run as two parallel throwaway sub-agents, reported
separately. Called automatically as the last step of `/chief-build`; also directly invocable.

---

### `/chief-autopilot`

Runs a story's ticket frontier autonomously.

Reads the existing goal and contract, creates tickets via `/chief-plan` if needed, and
delegates to `/chief-build` per ticket without stopping for approval. Repeats until the goal is
met **and** the contract is satisfied.

**Safe mode:** `/chief-autopilot safe` — stops on ambiguity for a quick check-in.

Recommended only when the goal is clear and well-scoped. Not recommended for large or
ambiguous stories.

---

### `/chief-loop`

Works a story's ticket frontier across as many rounds as it takes — round after round, no cap —
writing one report per ticket instead of one per round.

Builds directly on `/chief-autopilot`'s auto mode: no stopping for human input on ambiguity.
When a ticket hits ambiguity, a throwaway decision-support agent proposes 2–3 options; you
still make the final call, and the reasoning is recorded in that ticket's report. Requires the
goal and contract to exist.

If you want the "stop and ask a human" behavior instead, use `/chief-autopilot safe`.

---

### `/chief-grill`

Stateful, deep stress-test of a design or decision. Spawns a throwaway verifier subagent per
question.

- Opens a session file: `.chief/_grill/opened/NNNN-topic.md`
- Writes every Q&A to file as it goes — survives context resets
- Verifies each answer against the actual codebase via a background throwaway subagent
- Closed sessions move to `.chief/_grill/coach/`

Token cost: approximately 2× a normal skill session (two agents run simultaneously).

See also: `/grill-design` (stateless, lighter weight).

---

### `/chief-rule`

Captures a decision as a permanent rule in `.chief/_rules/`.

Describe the rule in plain language. The skill classifies it, formats it correctly, and asks
for confirmation before writing.

---

### `/chief-retro`

Runs a retrospective after a story or round of tickets.

1. Compares what shipped to what was planned
2. Produces a lesson-learned summary
3. Proposes rules for `.chief/_rules/` — you choose which to keep
4. Writes approved rules automatically

---

### `/chief-explain`

Self-contained structural reference: directory layout, storage-location resolution, what each
`chief-*` skill owns, and the rules for `.chief/_rules/` files. Written for the agent's own
understanding, not a human tutorial — see `/ask-chief` for that. Model-invocable: an agent may
reach for it on its own when it needs a structural fact, not only when you ask.

---

### `/chief-migrate-to-v5`

Converts an in-progress v4 milestone into a v5 story — separate from `/chief-upgrade`, which
handles `AGENTS.md` but deliberately never touches `.chief/milestone-N/` content. Only migrates
open milestones (closed ones are left alone); converts `_todo.md` + task specs into tickets
without inventing blocking edges (tagging each with `Migrated-from:` for traceability); asks
before deleting the old milestone directory, as its own separate confirmation after the
migration is already written and reviewed.

---

## Engineering skills

### `/grill-design`

Stateless stress-test of a design idea. Self-critiques its own suggested answers.

Lighter weight than `/chief-grill` — no file persistence, no background verifier. Session lives
in agent context only.

Use for smaller decisions where you don't need audit trail or codebase verification.

---

### `/shape-up`

Top-down spec creation for fuzzy or vision-level requirements.

Interviews you from problem space down to concrete scope — like an inverted triangle. Produces
a bounded spec that can feed into `/chief-grill` and `/chief-plan`.

Use when you have a problem or idea but not yet a concrete requirement.

---

### `/slim-down`

Reduces a goal or spec that's too large for a single story.

After writing a goal, if the scope is too big, `/slim-down` trims it to a phase-sized piece,
preserving the rest for a future story.

---

### `/loop-readiness`

Reviews whether a plan is ready to run as an unattended loop — an autopilot, scheduled job, or
long-running agent workflow with no human checking every step.

Checks four dimensions: Definition of Ready, feedforward guidance, feedback/verification, and
Definition of Done. Reports what's present, missing, and partial per dimension — no pass/fail
verdict or single score. Nothing gets executed; this is a static review of the plan as
described.

Works from an existing plan file or by interviewing you (via `/grill-design` if available).
Useful before `/chief-loop` or `/chief-autopilot` on a story that will run many ticket rounds
unattended.

---

### `/loop-preflight`

Actually runs a plan's pre-existing feedback mechanisms — gate scripts, test suites, checks inherited from prior work — to confirm they still work, rather than just noting they're described.

`/loop-readiness` is a static review and never executes anything, so it can't tell a described gate apart from a broken one; a plan can be accurate at the time it's written and still go stale before the loop starts (e.g. a hardcoded path renamed by an unrelated change). `/loop-preflight` closes that gap: it identifies the pre-existing verification commands a plan depends on, confirms the list with you (and confirms again before running anything that looks production-related), runs them for real, and reports actual pass/fail.

Standalone — use it whether or not you ran `/loop-readiness` first. `/loop-readiness` points here when it finds feedback the plan treats as already in place.

---

## Setup skills

### `/chief-install`

Installs Chief into a project. Asks which coding agent, and (for Claude Code) whether to
symlink or copy. Writes `AGENTS.md` directly — clones the target version, presents what would
be written (fresh, or a diff against your existing file), confirms, writes. There's no
`scripts/setup.sh` and no subagent roster to wire up in v5 — see
[chief-* execution skills](agents.md).

### `/chief-upgrade`

Upgrades `AGENTS.md` to a target version. Diffs it against the template and waits for sign-off
before overwriting anything. Detects a pre-v5 install (a leftover `.agents/agents/` roster) and
explains the v4 → v5 breaking change before proceeding — no `.chief/` content is migrated
automatically (see `/chief-migrate-to-v5` if you want that).

Usage: `/chief-upgrade` (latest stable), `/chief-upgrade canary`, `/chief-upgrade v5.0.0`

### `/setup-agent-behavior`

Opt-in, not Chief-specific. Writes a general agent-conduct block (think-before-acting,
simplicity-first, surgical changes, goal-driven execution, single-question interaction) into
`AGENTS.md`, if you want these principles binding every session rather than something you'd
have to remember to invoke. Show-then-confirm, same as everything else that writes to
`AGENTS.md`.

---

## Miscellaneous

### `/dump-commit`

Packages a clean commit. Summarises staged changes and writes a commit message.

Usage: `/dump-commit` (auto message), `/dump-commit fix auth flow` (custom message).

---

### `/ask-chief`

A router over the `chief-*` skills, written for **you** — the human deciding what to run next,
not the agent (that's `/chief-explain`). Maps your situation ("an idea with open design
questions," "a story too foggy to name a goal," "ready to build") to the right skill and says
why. `disable-model-invocation: true`, same as `mattpocock/skills`' `ask-matt` it's modeled on
— it only runs when you ask for it.

---

## Installing skills

```bash
# Install all Chief skills
npx skills@latest add thaitype/chief

# Install a specific skill only
npx skills@latest add thaitype/chief --skill chief-plan

# Install from a specific version
npx skills@latest add thaitype/chief#v5.0.0
```
