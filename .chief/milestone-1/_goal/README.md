# Milestone 1: Lite and Full AGENTS.md Profiles

## Objective

Deliver two installable AGENTS.md profiles (lite and full) with install/upgrade skill support, so users can choose the right level of framework structure for their project.

## Deliverables

1. **`template/AGENTS.lite.md`** -- new file. Lite profile template based on `_goal/AGENTS.lite.md` draft.
2. **`template/AGENTS.full.md`** -- new file. Rename current `template/AGENTS.md` to `template/AGENTS.full.md` and replace its content with the `_goal/AGENTS.full.md` draft.
3. **`docs/profiles.md`** -- new file. Explains both profiles, their differences, and upgrade criteria. Based on `_report/profiles-design-spec.md`.
4. **`skills/install-chief/SKILL.md`** -- updated. Ask user which profile (lite/full), create appropriate files + coding agent symlink.
5. **`skills/upgrade-chief/SKILL.md`** -- updated. Support lite-to-full upgrade and version upgrades within the same profile. No downgrade.
6. **Framework README** -- updated. Reference both profiles, link to `docs/profiles.md`.

## Key Decisions

### Profile behavior

- The user's project always gets `AGENTS.md` (never `AGENTS.lite.md` or `AGENTS.full.md`). The template files in this repo are named with the profile suffix; the install skill copies the chosen one as `AGENTS.md`.
- **Lite mode** = only `AGENTS.md` + coding agent symlink (e.g. `CLAUDE.md`). No `.chief/`, no `.agents/`, no skills directory.
- **Full mode** = `AGENTS.md` + `.chief/` + `.agents/` + skills + subagents. Supports both inline project rules in `AGENTS.md` AND `.chief/project.md`. `AGENTS.md` always wins on conflicts.

### Core principles

- 6 core principles are shared and finalized as drafted. Wording differences between lite and full templates are intentional adaptations (not contradictions).

### Lite profile specifics

- Lite `AGENTS.md` has a "Project-specific rules" section: empty with a brief note and example headings in 1-2 sentences.
- Grill-me skill is NOT shipped in lite mode. Docs mention optional install: `npx skills@latest add thaitype/chief-agent-framework --skill grill-me`.
- Lite users can manually create coding agent symlinks (e.g. `ln -s AGENTS.md CLAUDE.md`).

### Install skill

- Asks which profile (lite/full) and which coding agent.
- Lite install: copies lite template as `AGENTS.md`, creates coding agent symlink. Nothing else.
- Full install: existing behavior, but uses `AGENTS.full.md` as source for `AGENTS.md`.

### Upgrade skill

- Supports lite-to-full upgrade (additive: add `.chief/`, `.agents/`, skills, extend `AGENTS.md`).
- Supports version upgrades within same profile.
- No downgrade support.

### Reference material

- Karpathy guidelines (`_report/karpathy-guidelines.md`) are reference only. Principles are well-aligned, no revision needed.

## Drafts and References

- `_goal/AGENTS.lite.md` -- draft lite template (spec for `template/AGENTS.lite.md`)
- `_goal/AGENTS.full.md` -- draft full template (spec for `template/AGENTS.full.md`)
- `_report/profiles-design-spec.md` -- original design spec for both profiles
- `_report/karpathy-guidelines.md` -- reference material
