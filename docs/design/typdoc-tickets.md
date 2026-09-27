# Chief v5 — Optional typdoc Ticket Format

**Status:** Design — not yet implemented. Written from a grill-design session.

**Branch:** `design/typdoc-tickets` (branched from `release/v5`)

## Motivation

A ticket at `.chief/story-N/_tickets/<seq>-<slug>.md` carries its `Type:`, `Status:`, and
`Blocked by:` fields as plain lines under the H1 heading — not YAML frontmatter. Every skill
that touches a ticket (`chief-wayfinder`, `chief-plan`, `chief-loop`, `chief-autopilot`,
`chief-retro`, `chief-migrate`) finds and reads these fields by string matching on the body.

[typdoc](https://github.com/thaitype/typdoc) types exactly this shape of problem — a schema
per collection, YAML frontmatter as the typed part, refs between documents, collision-safe key
issuance, and a query surface (`--where`, `ref.*`) — but only over real frontmatter. A ticket's
fields have to actually live in frontmatter before typdoc (or anything else that expects typed
Markdown) can see them.

This is a **format** change chief makes on its own merits, not something gated on the user
having typdoc installed. When typdoc happens to be present and pointed at a project's tickets,
chief gets faster, collision-safe numbering and real ref queries for free. When it isn't, every
`chief-*` skill still works exactly as it does today, just reading frontmatter instead of body
text.

## Ticket file shape

Ticket content moves from body-text fields to frontmatter. The vocabulary does not change —
only where it's written:

```markdown
---
type: implementation
status: open
blocked_by: []
---

# TK-3: Add OAuth callback handler
...
```

```markdown
---
type: wayfinder:research
status: open
blocked_by: [TK-1]
---

# TK-3: Which auth provider do we support first?

## Question
...

## Answer
...
```

- **`type`** — same value set as today, unchanged: `implementation`, `wayfinder:research`,
  `wayfinder:prototype`, `wayfinder:grilling`, `wayfinder:task`. One field, not split into
  `kind`/`decision_type` — this is a label with no query benefit from splitting, so the rewrite
  leaves it alone.
- **`status`** — same value set as today, unchanged: `open`, `claimed`, `resolved`.
- **`blocked_by`** — the one field whose *representation* changes, not just its location: a
  real list of ticket **keys** (`[TK-1, TK-2]`), never a string and never a bare number. typdoc
  resolves refs by key, not by number alone — there's no such thing as a codeless key in its
  model — so a bare-number ref (`[1, 2]`) would never actually resolve as a typdoc ref even
  though it looks close. An empty list means no blocker — the `"None"` sentinel string is
  dropped entirely. This is the field `chief-loop`'s frontier computation actually needs to
  query as a ref (`ref.all(blocked_by).status=resolved`), so it's the one place worth getting
  the representation right on this pass rather than deferring it.

This is a breaking rewrite in place, not an additive mode living alongside the old shape. The
exact ticket path/naming convention has no external contract tying to it — nothing beyond
`chief-*` skills reads it — so there's no back-compat surface to design around, matching the
v4 → v5 precedent of rewriting the skill group in place rather than standing up a parallel one.

## Scope

Frontmatter and typdoc apply to `_tickets/` only. `_goal/`, `_contract/`, and `_report/` stay
free-form prose, unchanged:

- `_goal/` and `_contract/` files have no fixed filename today (`chief-plan`: "name each file
  for what it holds") and no state a query would ever need — no frontier, no blocking graph.
- `_report/` is write-once narrative output, read by a human or the next ticket's context, never
  queried as a set.
- `_tickets/` is the only bucket with a real graph (`blocked_by`) and a real frontier
  (`status=open` and every blocker `resolved`) — the one place typdoc's query model earns its
  place.

## Numbering and keys

`chief-plan` and `chief-wayfinder` currently compute the next ticket number themselves by
reading what's already in `_tickets/`. Going forward:

1. Try `typdoc new <namespace> "<title>"` (or the equivalent path-based `typdoc new` form).
2. **Exit 0** — use the key it returns, verbatim, whatever code that project's schema defines
   (`WF-`, `TICKET-`, anything). This is the collision-safe path: typdoc's namespace lock means
   two sessions (notably `chief-loop`'s parallel worktree mode) can't pick the same number.
3. **Any other exit** (127 command not found, 5 no project found, or anything else) — fall back
   to today's behavior of computing the next number itself, but key it as `TK-<n>` rather than a
   bare number. `TK` here is chief's own default label for its self-managed numbering, not a
   code it mandates anywhere else — it exists only so a ticket written before any typdoc project
   existed already has a key-shaped ref (`TK-3`, not `3`), and needs no renumbering pass later if
   a typdoc project is set up over the same tickets. Nothing forces a real typdoc schema to
   actually use `TK` as its code; when typdoc is active, chief always uses the key that came
   back from step 2, not this default.

Chief never checks *where* a typdoc project lives, never creates one, and never asserts an
opinion about `.typdoc/config.json`'s location or the schema/collection definitions that make
`_tickets/` a valid typdoc collection. Setting that up is entirely on whoever wants to run
`typdoc` against a project's tickets — the same way chief doesn't own whether a user has `gh`
installed. Chief's only commitment is that its ticket frontmatter is shaped so that a
correctly-configured typdoc project *can* type it.

## Filename convention

typdoc's coded documents are named by key alone today (`WF-2.md`); a future typdoc release may
add optional `<code>-<slug>` naming. This is cosmetic and orthogonal to everything above — chief
never parses a slug out of a ticket's filename, only its key/ref, so nothing in this design
depends on whether that typdoc feature exists yet. Whatever `typdoc new` returns as the file's
name is the file's name; the fallback path writes `TK-<n>-<slug>.md` (using its own default
code from **Numbering and keys** above), not the bare `<seq>-<slug>.md` it uses today — so a
ticket's filename and its frontmatter key always agree, in both modes.

## Skills touched

Every skill that reads or writes a ticket's `Type:`/`Status:`/`Blocked by:` fields moves from
string-matching the body to reading/writing frontmatter, and gains the try-typdoc-then-fallback
numbering step where it creates tickets:

- `chief-wayfinder` — creates decision-tickets, resolves them (`Status: open → claimed →
  resolved`).
- `chief-plan` — Phase 3, creates implementation tickets.
- `chief-loop` / `chief-autopilot` — compute the frontier, claim and resolve tickets.
- `chief-retro` — scans `_tickets/` for coverage.
- `chief-migrate` — writes v5-shaped tickets from a v4 milestone's todo/task-spec; needs to
  write the new frontmatter shape, not the old body-text one.
- `chief-explain` — its directory-structure reference gains the frontmatter shape as the
  documented ticket format.

## Out of scope for this pass

- Any `_goal:`/`_contract:`/`_report:` typing (see Scope).
- typdoc project setup, schema/collection authoring, or a `chief-init`-style step that offers to
  scaffold one — chief supports the format; it does not provision the tool.
- Cross-bucket refs (a ticket referencing a specific contract field as a typed ref) — closed off
  by the tickets-only scope above; revisit only if that need becomes concrete.
