# How to upgrade Chief

Upgrading Chief is one step: refresh the skill files.

```bash
npx skills@latest add thaitype/chief
```

This pulls the latest version of every Chief skill. The picker shows what changed. Safe to
re-run anytime — `npx skills add` is idempotent. There's nothing else to do — Chief writes
nothing to `AGENTS.md`, so there's no separate file to diff, merge, or sign off on.

---

## Pinning a specific version

```bash
npx skills@latest add thaitype/chief#v5.0.0
npx skills@latest add thaitype/chief#canary
```

Any git ref works — a tag, a branch, or a commit.

---

## What is safe to overwrite

| File | Safe to overwrite? |
|---|---|
| Skill files (`.agents/skills/**` or wherever your agent keeps them) | Yes — managed by `npx skills` |
| `AGENTS.md` / `CLAUDE.md` (if you made one) | N/A — Chief never touches these |
| `.chief/project.md` | No — your content |
| `.chief/story-*/` | No — your work |
| `.chief.config.md` (if present) | No — your storage-location choice |

v5 has no `.agents/agents/*.md` subagent roster — nothing there to diff or overwrite. If one
exists, it's a leftover from a pre-v5 install (see "Upgrading from v4" below) — inert, safe to
delete whenever you're ready, not something anything automatically cleans up.

---

## Upgrading from v4

v4 → v5 is a **major, breaking** change to the skill files themselves, not just a version bump
— see `docs/design/v5-ai-workflow.md` for the full rationale. Refreshing skills
(`npx skills@latest add thaitype/chief`) simply replaces v4's skill files with v5's; there's no
migration step for the skill files themselves, and nothing checks for a pre-v5 install
automatically anymore (v5 has no install/upgrade skill at all — see
[chief-* execution skills reference](../reference/agents.md) for why). What to know before you
do:

1. `.agents/agents/` (the `chief-agent`/`builder-agent`/`tester-agent`/`answer-verifier-agent`
   roster, if `/chief-install` ever wrote one for you under v4) becomes dead weight — nothing
   in v5 reads it. `/chief-build` and `/chief-test` replace two of them as skills, not agent
   files; the other two are gone outright. Delete it whenever you're ready; nothing breaks by
   leaving it either.
2. Your existing `.chief/milestone-N/` content is **not migrated** by refreshing skills. Finish
   anything in flight on a pinned v4 checkout (`npx skills@latest add thaitype/chief#v4.0.0`,
   or the `release/v4` branch); new work started with `/chief-plan` after upgrading uses the v5
   `.chief/story-N/` shape. If you want an in-progress v4 milestone converted instead of
   finished on v4, run `/chief-migrate`.
3. If you have an `AGENTS.md`, whatever you wrote in it is entirely yours either way — v4's
   `/chief-install` may have added a `<!-- chief-framework:begin/end -->` block to it; that
   block is now just inert text since nothing manages it anymore. Edit or remove it freely.

If you're upgrading within v4 (pre-v4.x → later v4.x), or within v5, this is a routine
refresh — just the one step above.

---

## Related

- [How to get the Chief skills into a project](install.md)
- [Directory structure reference](../reference/directory-structure.md)
