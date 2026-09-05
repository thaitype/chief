---
name: chief-migrate
description: Migrates an in-progress `.chief/` layout from an old framework version into
  whatever shape the current version expects. Content is copied and restructured as needed;
  only touches work still in progress; asks before deleting the old layout. See this skill's
  own Steps for exactly what's supported today — description text stays version-agnostic on
  purpose, the Steps carry the specifics.
---

> **Scope note:** this skill only knows how to migrate v4 → v5 right now — the steps below
> are written specifically for that shape change (`milestone-N` → `story-N`, `_todo.md` +
> task specs → tickets). A future version that changes `.chief/`'s shape again will need this
> file's Steps rewritten for that specific change, not extended — there's no generic
> "migrate from anything" logic here, just a stable name so this skill doesn't need renaming
> every time a version bumps. Check `git log -p` on this file for how a past migration
> actually worked, if you ever need that instead of guessing from the current content.

Migrate the *content* of an in-progress v4 milestone into v5's story shape. There's no
separate "upgrade" skill in v5 to run first — `.chief/` content is the only thing that needs
converting; nothing else about upgrading requires an agent (refreshing skill files is just
`npx skills add thaitype/chief` again). This skill is entirely optional: a v4 story can also
just finish out on a pinned v4 checkout instead, with new work starting fresh under v5.

**Read-and-plan first, write additively, ask before anything destructive.** This skill never
deletes the source milestone without an explicit, separate confirmation at the end.

**Storage location:** `.chief/` is the default. If `.chief.config.md` exists at the repo
root, resolve `storage-root:` from it first — both the v4 `milestone-*/` source and the v5
`story-N/` destination live under the resolved root, not necessarily literally `.chief/`.

## Step 1: Find candidates

Scan `.chief/` for `milestone-*/` directories (the v4 shape). For each one found, determine
whether it's **open** or **closed**:

- **Closed** if `_report/retro-milestone.md` exists, OR every item in `_plan/_todo.md` is
  checked `[x]`.
- **Open** otherwise.
- **Ambiguous** — e.g. no retro exists but the todo is fully checked anyway (never retro'd) —
  ask the user directly whether to treat it as open (migrate) or closed (skip).

**Skip closed milestones entirely.** They're historical record; converting them into the v5
ticket shape has no value, and touching them at all is unnecessary risk for zero benefit.

If no open milestones are found, tell the user so and stop — there's nothing to migrate.

## Step 2: Confirm scope

List the open milestone(s) found (name + one-line summary of what's in `_goal/`). Ask the user
to confirm which one(s) to migrate now (they may want to do them one at a time).

## Step 3: Plan the migration (read-only)

For the confirmed milestone(s), work out the mapping before writing anything:

- `_goal/*.md` → `story-N/_goal/*.md`, content copied as-is, with an empty `## Out of Scope`
  heading appended if not already present (nothing to fill in — there's no reliable way to
  infer what was out of scope from v4 content; leave it for the user to fill in later, or skip
  the heading entirely if they'd rather add it only when they actually have something to put
  there).
- `_contract/*.md` → `story-N/_contract/*.md`, same copy-as-is treatment, with an empty
  `## Testing Decisions` heading for the same reason.
- `_plan/_todo.md` items (and the matching `_plan/task-N.md` file, if one exists for that item)
  → one ticket file per item in `story-N/_tickets/`:
  - `Type: implementation`
  - `Status: resolved` if the todo item was checked `[x]`, else `open`
  - `Blocked by: None` — **do not invent blocking edges** from the todo list's order. A flat
    checklist's order is usually priority, not a dependency graph; guessing wrong is worse than
    not guessing. Tell the user in the summary that blocking edges were not inferred and should
    be reviewed manually (e.g. via `/chief-plan` Phase 3) if this story still has open tickets.
  - `Migrated-from: _plan/_todo.md <original item text>` (or `_plan/task-<n>.md` if that file
    existed) — a field unique to migrated tickets, so they stay greppable and distinguishable
    from tickets `/chief-plan` writes natively.
  - Body: `## What to build` from the task spec's Objective/Steps if a `task-N.md` existed,
    otherwise from the todo item's own text. `## Acceptance Criteria` copied from the task
    spec's Acceptance Criteria section if present, otherwise a single unchecked placeholder
    criterion noting it needs to be filled in.
  - Ticket IDs are a plain per-story sequence (`1`, `2`, `3`...), continuing from any tickets
    that already exist in the target `story-N/_tickets/` (there shouldn't be any yet for a
    fresh migration, but check).
- `_report/*` → `story-N/_report/*`, copied as-is (these are just historical notes; no shape
  change needed).

Present this plan to the user: what will be created, file by file, with the actual ticket
content for at least the first couple as a sample. **Do not write anything yet.**

## Step 4: Write

On approval, create `.chief/story-N/` (pick the next available story number — do not assume
the milestone number carries over, since story numbering and milestone numbering may already
have diverged) and write everything from Step 3.

## Step 5: Show the result, then ask about the old milestone

Present the full list of what was written (paths only, not full content again). Then ask,
as its own separate question:

> "Migration complete. Delete the old `.chief/milestone-N/` now, keep it alongside
> `.chief/story-N/` for now, or you'll decide later?"

- **Delete** → confirm once more (this is the one irreversible step in this whole skill), then
  `rm -rf` the milestone directory.
- **Keep** → leave it untouched. Tell the user nothing in v5 reads it anymore, so it's inert,
  but it's theirs to remove whenever they're satisfied the migration is correct.
- **Decide later** → same as keep, just don't ask again this session.

## Rules

- NEVER migrate a closed milestone — check the retro/todo-completion signal first, every time.
- NEVER invent blocking edges between migrated tickets. `Blocked by: None` plus a note that
  edges need manual review is the honest output; a wrong guess is worse than an admitted gap.
- NEVER delete `.chief/milestone-N/` without an explicit, separate confirmation *after* the
  migration is already written and shown — never as part of the same approval as the migration
  itself.
- ALWAYS tag migrated tickets with `Migrated-from:` — never make a migrated ticket
  indistinguishable from one `/chief-plan` wrote natively.
- This skill does not touch `AGENTS.md` or anything `.agents/`-related. If a pre-v5
  `.agents/agents/` roster is still sitting in the project, it's inert dead weight, not
  something this skill (or anything else) needs to clean up automatically — leave it for the
  user to remove whenever they're ready.
