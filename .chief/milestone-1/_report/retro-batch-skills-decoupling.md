# Retro: milestone-1 — batch (skills decoupling)

Out-of-band batch: this work was delivered without formal entry in `_goal/`, `_contract/`, or `_plan/_todo.md`. The retro is scoped to the actual changes in the current working tree (uncommitted at time of writing).

## Coverage Check

| File | Status | Notes |
|------|--------|-------|
| `_goal/` (any) | ❌ Missing | No goal files existed for this work. Decision was driven entirely by an in-conversation grill-me session. |
| `_contract/` (any) | ❌ Missing | No contracts. The boundary "chief-install/chief-upgrade own framework files only, not skills" was agreed verbally but never written. |
| `_plan/_todo.md` | ❌ Missing | TODO contains only placeholder `- [ ] Add later`. |

**Finding:** the coverage check exists to verify that delivered work satisfies declared intent. Here, intent was never declared in writing. The retro can only verify *what* was delivered, not *whether it matched the plan*.

## Planned vs Delivered

**Planned (verbally, via grill-me):**
- Hard boundary: chief-install/chief-upgrade SKILL.md and scripts know nothing about skills
- Skills installation entirely handled by user via `npx skills add thaitype/chief`
- Pure deletion — no new pointers, no detection logic, no orchestration

**Delivered (4 files, 137 deletions, 8 insertions):**
- `scripts/setup.sh` — removed `.claude/skills` mkdir, the symlink/copy loops over `.agents/skills/*/`, `.claude/skills/` from help text
- `scripts/upgrade.sh` — removed entire skills compare section, the overwrite-skills loop, `.claude/skills` re-sync, related help/comment text
- `skills/setup/chief-install/SKILL.md` — removed Step 3b skills lines, Step 4 verify entries for skills, Step 5 fix instruction for `.claude/skills`
- `skills/setup/chief-upgrade/SKILL.md` — removed Step 5 manual fallback "Overwrite skills" item and `.claude/skills` lines for both modes

**Mid-execution change:** initial implementation also added "Install Chief skills: `npx skills@latest add thaitype/chief`" to chief-install Step 7 and a parallel line in chief-upgrade Step 8. User rejected, full revert, re-implemented with pure deletion.

## Blockers Hit

**1. AI-execution trap on the npx command pointer.**
- My grill Q2/Q3 surfaced "pointer at the end" as the agreed UX answer.
- Implemented as: Step 7 instruction reading `npx skills@latest add thaitype/chief` inside a code block.
- An AI reading chief-install would parse that as "execute via Bash". The npx command launches an interactive picker. AI running it non-interactively either hangs or auto-fails; user choice never happens.
- User caught it on review. Demanded full revert.
- Resolved by: re-implementing as pure deletion. SKILL.md is silent about skills — period.

**2. milestone tracking gap.**
- Work was substantive (137 lines deleted, design implications across two SKILLs and two scripts), but there is no record in `.chief/milestone-1/` of what was attempted or why.
- Future readers will only see the git diff and have to reconstruct the boundary decision from commit messages.

## Lessons Learned

- **The AI-execution trap is structural, not stylistic.** Any runnable command appearing in a SKILL.md instruction — even prefaced with "tell the user to run" — is a candidate for AI execution. Phrasing tweaks ("STOP. Do not execute.") harden against careless agents but don't eliminate the surface. The only deterministic fix is to *not include the command at all*. Documentation for the human belongs in README, where the AI doesn't read it as instruction.
- **Grilling protocol caught the design boundary; framing missed it.** The grill cleanly resolved "hard boundary, skills are user's concern". But translating that into SKILL.md prose I wrote `npx skills@latest add thaitype/chief` directly into the AI's reading context — violating the very boundary we'd agreed.
- **Hard boundary > soft boundary, every time.** Each "small refinement" (recheck, pointer, list of skill names) reopened the boundary. Pure deletion was the right answer, and the second-order question is whether a boundary that requires this much vigilance to maintain is the right shape at all.
- **Out-of-band work erodes the framework.** The framework's value is verifiable goals + contracts + plan. This batch shipped without any of them. Acceptable as a one-off; corrosive as a pattern.

## Proposed Rule Updates

### 1. SKILL.md must not contain runnable commands the user is supposed to execute

- **What:** Forbid embedding shell commands in SKILL.md when the intent is "the human runs this." Reference such commands by name only (e.g. "the user installs skills via vercel `npx skills`") and put copyable command text in README or external docs.
- **Where:** `.chief/_rules/_standard/skill-md-no-user-commands.md`
- **Why:** Hit directly in this batch. AI reading chief-install Step 7 would execute the npx command via Bash, triggering an interactive picker meant for the human.
- **Suggestion:** recommended

### 2. setup/upgrade scripts and chief-install/chief-upgrade SKILL.md own framework files only — never skills

- **What:** Permanent boundary. `.agents/agents/`, `.chief/`, `AGENTS.md`, agent integration files (`.claude/agents/`, `.github/agents/`) are framework. Anything under `.agents/skills/` or `.claude/skills/` is skill territory and belongs to the user via `npx skills`.
- **Where:** `.chief/_rules/_standard/install-scope-boundary.md`
- **Why:** This batch removed the cross-cutting skills handling. Without a written rule, a future change could re-add it (e.g. "convenience: install grill-me automatically") and re-introduce the duplicate-grouping bug we previously diagnosed in the picker.
- **Suggestion:** recommended

### 3. Grill-me sessions must include an AI-execution audit

- **What:** Add a checklist item to grill-me protocol: "For each agreed instruction that will land in a SKILL.md, identify whether AI executing it literally produces the wrong outcome." Catches the bug class hit in this batch before it ships.
- **Where:** Either `.chief/_rules/_standard/grill-me-ai-execution-audit.md` or extend `skills/mattpocock/grill-me/SKILL.md` with the audit step.
- **Why:** This batch's grill resolved the design boundary correctly but the implementation translation violated it. A structured audit would have surfaced the issue at the design stage, not after implementation + revert.
- **Suggestion:** recommended

### 4. Out-of-band batches still get a retro and a retroactive goal entry

- **What:** Even when work bypasses normal planning (small fix, opportunistic refactor), require either (a) a retroactive minimal goal/contract added to the active milestone, or (b) explicit "no-goal batch" tag in the retro report. Retros without a coverage check anchor become anecdote.
- **Where:** `.chief/_rules/_standard/retro-out-of-band.md`
- **Why:** This retro's coverage check section is N/A across the board. If that becomes the norm, the framework's defining property (verifiable intent) is moot.
- **Suggestion:** optional

## User Action Needed

- Decide which of the 4 rule proposals to apply (or modify before applying).
- Decide whether this batch's intent should be retroactively captured as a milestone-1 goal/contract, or accepted as out-of-band.
- Commit the working tree (4 files, 137 deletions, 8 insertions) once the retro decisions are settled.
