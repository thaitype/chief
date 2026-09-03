# Directory structure reference

This page describes every file and folder Chief touches, and when each is created.

---

## After `/chief-install`

```
project/
└── AGENTS.md          ← framework + project rules (highest authority)
    CLAUDE.md → AGENTS.md   ← symlink (Claude Code only)
```

v5 has no subagent roster to install — no `.agents/`, no `.claude/agents/`, no
`.github/agents/`. `/chief-build` and `/chief-test` are skills, not registered agent files; see
[chief-* skill roles](agents.md).

`.chief/` is **not** created at install time.

---

## After `/chief-init`

```
.chief/
└── project.md     ← tech stack, dev commands, architecture notes
```

`chief-init` also confirms where planning artifacts should live. If you keep the default, no
extra file is written. If you pick a different name, a `.chief.config.md` appears at the repo
**root** (outside `.chief/` itself — see "Storage location" below):

```
.chief.config.md    ← only if you didn't keep the default
```

---

## After `/chief-plan` (first story)

```
.chief/
├── project.md
└── story-1/
    ├── _goal/
    │   └── goal.md          ← what this story delivers + Out of Scope
    ├── _contract/
    │   └── contract.md      ← API shapes, data models, constraints + Testing Decisions
    ├── _tickets/
    │   └── 1-1-<slug>.md    ← vertical-slice tickets, numbered <story>-<seq>
    └── _report/              ← ticket reports, retro output, investigations
```

If `/chief-wayfinder` was used on this story (optional — offered as a choice at `/chief-plan`'s
Phase 0, or invoked directly), a map file also appears, and its decision-tickets share the same
`_tickets/` folder as the implementation tickets above, distinguished by a `Type:` field:

```
.chief/story-1/
├── _map.md                  ← Destination / Notes / Decisions so far / Not yet specified / Out of scope
└── _tickets/
    ├── 1-1-<slug>.md          ← Type: wayfinder:grilling (decision-ticket)
    └── 1-2-<slug>.md          ← Type: implementation
```

---

## After rules accumulate (via `/chief-rule` or `/chief-retro`)

```
.chief/
├── project.md
├── _rules/
│   ├── _standard/         ← coding standards, patterns
│   ├── _contract/         ← global API contracts, data models
│   ├── _goal/             ← long-term direction (spans stories)
│   └── _verification/     ← test commands, definition of done
└── story-N/
```

`_rules/` is empty in small projects. It grows through retros and `/chief-rule` as patterns
emerge.

---

## After `/chief-grill`

```
.chief/
└── _grill/
    ├── opened/
    │   └── NNNN-topic.md  ← active grill session (Q&A + verification results)
    └── coach/             ← closed sessions
```

---

## Storage location

`.chief/` is the **default**, not a hardcoded requirement. Every skill resolves it by checking
for `.chief.config.md` at the repo root first:

- **Absent** (the common case) → use `.chief/`. Most projects never create this file.
- **Present** → read `storage-root:` from it and use that path everywhere below instead of
  `.chief/`.

`.chief.config.md` lives at the root, outside any storage directory, on purpose — a pointer that
named the storage directory's location *inside* that same directory couldn't be found before you
already knew where to look. See `docs/design/v5-ai-workflow.md`, "Storage backend," for the full
reasoning, including the second-tier `<storage-root>/config.md` for settings that don't have
this bootstrap problem (nothing exists there yet — v5 ships one backend).

## Key rules

- `.chief/` is created lazily — only the files you actually use appear.
- `AGENTS.md` is always present after install. It is the highest-authority file.
- A canonical example layout lives at [`docs/example-chief/`](../example-chief/) for reference.

---

## File authority

| File / folder | Authority level | Created by |
|---|---|---|
| `AGENTS.md` | Highest | `/chief-install` |
| `.chief/_rules/` | Global | `/chief-rule`, `/chief-retro`, or manual |
| `.chief/story-N/_goal/` | Story | `/chief-plan` or `/chief-wayfinder` |
| `.chief/story-N/_contract/` | Story | `/chief-plan` |
| `.chief/project.md` | Context (not rules) | `/chief-init` or manual |
