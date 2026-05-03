---
name: chief-rule
description: Proactively add a rule to `.chief/_rules/`. Counterpart to `/chief-retro` (which proposes rules reactively from observed patterns). Use when the user has a rule in mind and wants to capture it now. Interviews the user (what / why / when / examples), classifies the rule into a category (_standard / _contract / _goal / _verification), shows a draft, and writes after confirmation. One rule per invocation.
---

You are helping the user capture a single rule into `.chief/_rules/`. This is the proactive counterpart to `/chief-retro` — use it whenever the user has a rule in mind and wants to write it down now.

One invocation = one rule (path 2) or scaffolding only (path 1). Re-run for more.

## Steps

### 1. Pre-flight

Just inspect — do NOT create anything yet. Note for later use:

- whether `.chief/` exists
- whether `.chief/_rules/` exists
- whether `.chief/_rules/README.md` exists

Scaffolding (creating `.chief/`, `.chief/_rules/`, the README) happens at the END of the chosen path, not now. If the user bails out, we leave the filesystem untouched.

### 2. Pre-interview fork

Ask the user, with exactly two options:

> Pick one:
> 1. Scaffold `.chief/_rules/` only (I'll write rules manually later, or use `/chief-retro` after work)
> 2. Interview me — write a rule now

If **1** → run the **scaffold routine** below, then stop.
If **2** → continue to step 3. (Scaffolding happens later, in step 7, alongside the rule write.)

#### Scaffold routine (used by path 1, and by path 7 when `_rules/` is missing)

1. Create `.chief/` if missing.
2. Create `.chief/_rules/` if missing.
3. Write `.chief/_rules/README.md` if missing, with this content:

   ```markdown
   # .chief/_rules/

   Global rules that govern this project's autonomous AI work. Lower priority than `AGENTS.md`, higher than milestone goals.

   ## Categories

   - `_standard/` — Coding standards, architecture constraints
   - `_contract/` — Data models, API contracts, schemas
   - `_goal/` — High-level goals (shared across milestones)
   - `_verification/` — Test commands, build requirements, definition of done

   Subfolders are created **lazily** — on first rule in that category. Empty subfolders are not required.

   Use `/chief-rule` to add rules proactively, or `/chief-retro` to capture them after a milestone retrospective.
   ```

4. Do NOT create the four category subfolders. They remain lazy until the first rule lands in each.

After scaffolding for path 1: tell the user the README path and stop.

### 3. Interview (one focused question at a time)

Ask each question separately. Wait for the answer before moving on. Keep questions short. Skip a question if the user says "skip" or "n/a" — but do not skip Q1 (what).

1. **What is the rule?** — A single-sentence statement of the rule.
2. **Why does it exist?** — The motivation: incident, preference, constraint, decision.
3. **When and where does it apply?** — Scope: always / specific area / specific milestone / specific file types / etc.
4. **Any code or text example?** — Optional. A short snippet showing right vs wrong, or a concrete instance.
5. **Filename?** — Short kebab-case (e.g. `commit-style`, `db-naming`, `pr-size`). No `.md` suffix needed.

### 4. Classify into a category

Based on the answers, propose one of the four categories:

- `_standard/` — coding standards, naming, formatting, architectural constraints, "how we write code"
- `_contract/` — data models, API contracts, schemas, type-level invariants
- `_goal/` — high-level goals shared across milestones, product direction
- `_verification/` — test commands, build requirements, definition of done, CI gates

Tell the user which category you picked and why (one sentence). Ask them to confirm or override.

### 5. Draft the file

Write the draft using **plain markdown, no frontmatter**:

```markdown
# <The rule statement, as a single declarative sentence>

**Why:** <motivation from Q2>

**How to apply:** <scope from Q3>

## Example

<code or prose example from Q4 — omit this section if user skipped Q4>
```

Show the rendered draft to the user. Ask once: "Write this to `.chief/_rules/<category>/<filename>.md`?"

If user requests changes, apply them and re-show. Do not loop more than three rounds — if alignment stalls, write the current draft and tell the user they can edit it manually.

### 6. Collision handling (content-aware)

Before writing, check if `.chief/_rules/<category>/<filename>.md` already exists.

If it does, **read the existing file first**, then classify the relationship and propose the right action:

| Relationship | Detection signal | Action |
|---|---|---|
| **Identical** | New rule's statement, why, and how-to-apply substantially match existing | Skip. Tell user the rule is already captured. Stop. |
| **Refines / extends** | Same concern, new adds detail (e.g. clarifies scope, adds an example, tightens wording) | Merge: produce a unified version that preserves both. Show diff. Backup existing to `<filename>.md.bak`. Confirm, then write. |
| **Contradicts** | New rule reverses or replaces existing | Replace: show old vs new side-by-side. Backup existing to `<filename>.md.bak`. Confirm, then write. |
| **Different concern, name collision** | Existing file's H1 / Why is about a different thing despite same filename | Suggest a more specific filename. Loop back to step 3 question 5 (filename) with the user. |

NEVER overwrite without backing up to `.bak` first. NEVER skip the read-before-write step on collision.

### 7. Write and report

1. If `.chief/_rules/` does not exist yet, run the **scaffold routine** from step 2 first (creates `.chief/`, `.chief/_rules/`, and `_rules/README.md`).
2. Create the target category subfolder (e.g. `.chief/_rules/_standard/`) if missing — this is the lazy creation point.
3. Write the rule file.

Then report:

- Path written
- Backup path (if collision triggered a `.bak`)
- Reminder: chief-agent will pick up this rule on its next read of `.chief/_rules/**`

Stop. Do not ask "add another?" — one rule per invocation. User re-runs for the next.

## Important rules

- This skill creates **only** rule files (and the `.chief/_rules/README.md` on first run). Do not scaffold milestones, project.md, or anything else.
- NEVER create empty category subfolders — they are lazy. Only create `_standard/`, `_contract/`, `_goal/`, or `_verification/` when the first rule lands there.
- NEVER overwrite an existing rule file without a `.bak` backup AND user confirmation.
- NEVER read or modify files outside `.chief/_rules/` (except the read of `AGENTS.md` if you need it for context — but you usually do not).
- Keep the interview short. One focused question at a time, no compound questions.
- Use plain markdown. No frontmatter. The repo's existing `.chief/_rules/` files are plain markdown — keep the convention.
- If the user picks path 1 (scaffold only), do NOT continue into the interview. Stop after the README is written.
