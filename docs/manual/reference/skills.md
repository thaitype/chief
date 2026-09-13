# Skills reference

Skills are installed via `npx skills@latest add thaitype/chief`. Each skill is a prompt injected into your coding agent when you run the slash command.

---

## Chief workflow skills

### `/chief-init`

Bootstraps project context for a new project.

Interviews you about your tech stack, architecture, dev commands, and key constraints. Writes the answers to `.chief/project.md`. Subagents read this file at the start of every session.

Run once when setting up a project, or re-run to update project context.

---

### `/chief-plan`

Plans a milestone end-to-end with review gates.

Phases, in order:

1. **Grill** — brief clarification session (calls `/grill-design` internally)
2. **Goals** — writes `.chief/milestone-N/_goal/`
3. **Contracts** — writes `.chief/milestone-N/_contract/`
4. **TODO** — optional batch breakdown
5. **Tasks** — individual units for `builder-agent`

Waits for your approval after each phase before proceeding.

---

### `/chief-autopilot`

Runs a milestone autonomously.

Reads existing goals and contracts, creates tasks, and delegates to `builder-agent` without stopping for approval. If goals/contracts don't exist, creates them first.

**Safe mode:** `/chief-autopilot safe` — pauses after each task for a quick check-in.

Recommended only when the goal is clear and well-scoped. Not recommended for large or ambiguous projects.

---

### `/chief-loop`

Runs chief-agent across as many batches as it takes to finish a milestone — batch after batch, no cap — writing one report per task instead of one per batch.

Builds directly on `/chief-autopilot`'s auto mode: no stopping for human input on ambiguity. When a task hits ambiguity, a throwaway decision-support agent proposes 2–3 options; chief-agent still makes the final call, and the reasoning is recorded in that task's report. Requires goals and contracts to exist.

If you want the "stop and ask a human" behavior instead, use `/chief-autopilot safe`.

---

### `/chief-grill`

Stateful, deep stress-test of a design or decision. Spawns `answer-verifier-agent` per question.

- Opens a session file: `.chief/_grill/opened/NNNN-topic.md`
- Writes every Q&A to file as it goes — survives context resets
- Verifies each answer against the actual codebase via background `answer-verifier-agent`
- Closed sessions move to `.chief/_grill/coach/`

Token cost: approximately 2× a normal skill session (two agents run simultaneously).

See also: `/grill-design` (stateless, lighter weight).

---

### `/chief-rule`

Captures a decision as a permanent rule in `.chief/_rules/`.

Describe the rule in plain language. The skill classifies it, formats it correctly, and asks for confirmation before writing.

---

### `/chief-retro`

Runs a retrospective after a milestone or batch.

1. Compares what shipped to what was planned
2. Produces a lesson-learned summary
3. Proposes rules for `.chief/_rules/` — you choose which to keep
4. Writes approved rules automatically

---

## Engineering skills

### `/grill-design`

Stateless stress-test of a design idea. Self-critiques its own suggested answers.

Lighter weight than `/chief-grill` — no file persistence, no background verifier. Session lives in agent context only.

Use for smaller decisions where you don't need audit trail or codebase verification.

---

### `/shape-up`

Top-down spec creation for fuzzy or vision-level requirements.

Interviews you from problem space down to concrete scope — like an inverted triangle. Produces a bounded spec that can feed into `/chief-grill` and `/chief-plan`.

Use when you have a problem or idea but not yet a concrete requirement.

---

### `/slim-down`

Reduces a goal or spec that's too large for a single milestone.

After writing goals, if the scope is too big, `/slim-down` trims it to a phase-sized piece, preserving the rest for a future milestone.

---

### `/loop-readiness`

Reviews whether a plan is ready to run as an unattended loop — an autopilot, scheduled job, or long-running agent workflow with no human checking every step.

Checks four dimensions: Definition of Ready, feedforward guidance, feedback/verification, and Definition of Done. Reports what's present, missing, and partial per dimension — no pass/fail verdict or single score. Nothing gets executed; this is a static review of the plan as described.

Works from an existing plan file or by interviewing you (via `/grill-design` if available). Useful before `/chief-loop` or `/chief-autopilot` on a milestone that will run many iterations unattended.

---

### `/loop-preflight`

Actually runs a plan's pre-existing feedback mechanisms — gate scripts, test suites, checks inherited from prior work — to confirm they still work, rather than just noting they're described.

`/loop-readiness` is a static review and never executes anything, so it can't tell a described gate apart from a broken one; a plan can be accurate at the time it's written and still go stale before the loop starts (e.g. a hardcoded path renamed by an unrelated change). `/loop-preflight` closes that gap: it identifies the pre-existing verification commands a plan depends on, confirms the list with you (and confirms again before running anything that looks production-related), runs them for real, and reports actual pass/fail.

Standalone — use it whether or not you ran `/loop-readiness` first. `/loop-readiness` points here when it finds feedback the plan treats as already in place.

---

## Setup skills

### `/chief-install`

Installs Chief into a project. Asks which coding agent, which mode (symlink/copy), and whether to include subagents. Writes `AGENTS.md` and wires up agent definitions.

### `/chief-upgrade`

Upgrades framework files to a target version. Diffs each file and presents an upgrade plan. Waits for sign-off before overwriting anything.

Usage: `/chief-upgrade` (latest stable), `/chief-upgrade canary`, `/chief-upgrade v4.0.0`

---

## Miscellaneous

### `/dump-commit`

Packages a clean commit. Summarises staged changes and writes a commit message.

Usage: `/dump-commit` (auto message), `/dump-commit fix auth flow` (custom message).

---

## Installing skills

```bash
# Install all Chief skills
npx skills@latest add thaitype/chief

# Install a specific skill only
npx skills@latest add thaitype/chief --skill chief-plan

# Install from a specific version
npx skills@latest add thaitype/chief#v4.0.0
```
