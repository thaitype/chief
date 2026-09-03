# How to upgrade Chief

Upgrading Chief is a two-step process: refresh skills, then upgrade `AGENTS.md`.

---

## Step 1 — Refresh skills

```bash
npx skills@latest add thaitype/chief
```

This pulls the latest version of every Chief skill. The picker shows what changed. Safe to
re-run anytime — `npx skills add` is idempotent.

---

## Step 2 — Upgrade `AGENTS.md`

```
/chief-upgrade
```

The skill diffs `AGENTS.md` against the target version and waits for your sign-off before
changing anything. If it detects a pre-v5 install (a `.agents/agents/chief-agent.md` still
present), it stops first to explain that v4 → v5 is a one-way breaking change — no `.chief/`
content gets migrated automatically — before touching anything.

Your `AGENTS.md` Project Rules section (or, in newer installs, everything outside the
`<!-- chief-framework:begin/end -->` markers) is flagged for review, never silently overwritten.

---

## Pinning a specific version

Both steps support version pinning:

```bash
# Skills — any git ref (tag, branch, or commit)
npx skills@latest add thaitype/chief#v5.0.0
```

```
# Framework files
/chief-upgrade v5.0.0
/chief-upgrade canary
```

---

## What is safe to overwrite

| File | Safe to overwrite? |
|---|---|
| Skill files (`.agents/skills/**`) | Yes — managed by `npx skills` |
| `AGENTS.md` framework sections | Yes |
| `AGENTS.md` Project Rules section | No — your content, review manually |
| `.chief/project.md` | No — your content |
| `.chief/story-*/` | No — your work |
| `.chief.config.md` (if present) | No — your storage-location choice |

v5 has no `.agents/agents/*.md` subagent roster — nothing there to diff or overwrite. If one
exists, it's a leftover from a pre-v5 install (see "Upgrading from v4" below).

---

## Upgrading from v4

v4 → v5 is a **major, breaking** upgrade, not a routine refresh — see
`docs/design/v5-ai-workflow.md` for the full rationale. `/chief-upgrade` detects this
automatically and explains it before proceeding. In short:

1. `.agents/agents/` (the `chief-agent`/`builder-agent`/`tester-agent`/`answer-verifier-agent`
   roster) is removed entirely — `/chief-build` and `/chief-test` replace two of them as skills,
   not agent files; the other two are gone outright.
2. Your existing `.chief/milestone-N/` content is **not migrated**. Finish anything in flight on
   a pinned v4 checkout (`npx skills@latest add thaitype/chief#v4.0.0`, or the `release/v4`
   branch); new work started with `/chief-plan` after upgrading uses the v5 `.chief/story-N/`
   shape.
3. Your `AGENTS.md` Project Rules are preserved either way.

If you're upgrading within v4 (pre-v4.x → later v4.x), or within v5, this is a routine refresh —
same two steps as above.

---

## Related

- [How to install Chief](install.md)
- [Directory structure reference](../reference/directory-structure.md)
