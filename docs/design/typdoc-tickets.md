# Chief v5 — Optional typdoc Ticket Format

**Status:** Implemented on this branch (PR #31), revised once already after real-world adoption
feedback from `thaitype/typdoc` itself. Written from a grill-design session, revised through a
second one after that feedback.

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

## Numbering, reading, and updating — revised after real adoption

The first cut of this section specified an exact `typdoc new <namespace> "<title>"` call and a
strict exit-code branch (0 = use the key, anything else = fall back to `TK-<n>`), duplicated
into `chief-plan`, `chief-wayfinder`, `chief-migrate`, and implied for `chief-loop` /
`chief-autopilot` / `chief-retro`. Real adoption in `thaitype/typdoc` itself (Aria/Mina,
2026-09-28, against typdoc 0.5.0) found this specified command wrong (the first argument is the
schema **code**, not the namespace) and, more importantly, under-specified: getting exit 0 at
all needed `TYPDOC_DIR`/cwd control, `--namespace`, and `--set type=`, none of which the skills
mentioned — so `typdoc new` never exited 0 as written, and the silent fallback hid that every
ticket was being self-numbered instead of delegated.

That revealed the deeper problem: exit-code detail belongs to typdoc's own docs, not duplicated
here, and duplicating even a corrected version of it into every ticket-touching skill just
recreates the same drift risk the moment typdoc's CLI changes again (it already has, twice,
across 0.3 → 0.4 → 0.5 during this design's own lifetime).

**Revised architecture:** typdoc knowledge lives in exactly one place, `chief-explain`'s typdoc
section — not duplicated into any other skill. Every other `chief-*` skill that creates, reads,
or updates a ticket does two things only: check whether typdoc is usable, and if so, follow
`chief-explain`'s guidance instead of carrying its own copy of the mechanics. No skill outside
`chief-explain` names a flag, an exit code, or a fixed schema code.

**The policy is deliberately light, not a decision tree:** typdoc is optional. If it's there,
use it for the operation at hand (create, read/query the frontier, update status, validate). If
it isn't installed, do the operation directly on the files — that's the only condition that
triggers silently working around it. If it's installed and a specific call hits a snag (wrong
code guessed, a missing field), that's an ordinary problem to resolve with judgment — check an
existing ticket's key, or ask typdoc itself what it expects, and retry — not a fixed rule to
branch on by exit code.

**No fixed code.** `TK` is Chief's own default only when it numbers a ticket itself with no
typdoc involved at all; it was never meant to be assumed as the code of an actual typdoc
project's schema, and earlier drafts of this doc didn't say clearly enough how to find the real
one — a story's existing ticket filenames already show it, or `typdoc get`/`typdoc list` on an
existing document reports its own `code`.

Chief never checks *where* a typdoc project lives, never creates one, and never asserts an
opinion about `.typdoc/config.json`'s location or the schema/collection definitions that make
`_tickets/` a valid typdoc collection. Setting that up is entirely on whoever wants to run
`typdoc` against a project's tickets — the same way chief doesn't own whether a user has `gh`
installed. Chief's only commitment is that its ticket frontmatter is shaped so that a
correctly-configured typdoc project *can* type it.

## Filename convention

typdoc's coded documents are named by their key, optionally followed by `-<slug>` (a
collection's `slug` setting controls whether that's `optional`, `required`, or `none` — this is
cosmetic and orthogonal to everything above: chief never parses a slug out of a ticket's
filename, only its key/ref, so nothing in this design ever depended on it). Whatever `typdoc
new` returns as the file's name is the file's name (pass `--slug <slug>` to get one); the
fallback path writes `TK-<n>-<slug>.md` (using its own default code from the section above), not
the bare `<seq>-<slug>.md` it uses today — so a ticket's filename and its frontmatter key always
agree, in both modes.

**Confirmed against a real typdoc install, both versions:** on 0.3.1, a collection's `match`
rejected combining `{key}` with a wildcard (`_tickets/{key}*.md` was `config.match-template`),
so only bare-key filenames (`TK-1.md`) validated. On 0.4.0, the same collection file validates
`TK-1-example-ticket.md` unchanged — the default `slug: optional` covers both forms, no config
edit needed. This round-trip is itself evidence the orthogonality claim held: chief's own logic
never referenced a slug either way, only the *reference template's* validity moved.

## Reference typdoc project

`docs/example-chief/.typdoc/` is a working, ready-to-copy typdoc project (config, collection,
schema) typing `docs/example-chief/story-1/_tickets/`, verified against a real typdoc 0.4.0
install (`validate`, `get`, and `new --slug` all clean). Chief doesn't provision this for
anyone (see **Out of scope** below) — it's a template a user copies into their own storage root
by hand, the same way `docs/example-chief/` itself already is. Its own README covers why the
schema declares an otherwise-unused `title` field (`typdoc new`'s required title argument
always writes one; declaring it avoids a spurious `frontmatter.unknown` warning on every ticket
typdoc creates) and the 0.3.x fallback for anyone not yet upgraded.

## Skills touched

Every skill that reads or writes a ticket's `Type:`/`Status:`/`Blocked by:` fields moves from
string-matching the body to reading/writing frontmatter. Only `chief-explain` carries any
typdoc mechanics; every other skill below gets a one-line pointer to it at the point it creates,
reads, or updates a ticket, nothing more:

- `chief-wayfinder` — creates decision-tickets, resolves them (`status: open → claimed →
  resolved`). Pointer at ticket creation.
- `chief-plan` — Phase 3, creates implementation tickets. Pointer at ticket creation.
- `chief-loop` / `chief-autopilot` — compute the frontier, claim and resolve tickets. Pointer at
  frontier computation (the read side; `chief-explain` covers the update side too).
- `chief-retro` — scans `_tickets/` for coverage. Pointer at the scan.
- `chief-migrate` — writes v5-shaped tickets from a v4 milestone's todo/task-spec. Pointer at
  ticket creation.
- `chief-explain` — the single source of truth: the frontmatter shape, and the typdoc section
  (optional, light policy, rough per-action examples, no exit codes, no fixed code) covered
  above.

## Out of scope for this pass

- Any `_goal:`/`_contract:`/`_report:` typing (see Scope).
- Automating typdoc project setup, or a `chief-init`-style step that offers to scaffold one for
  a user — chief supports the format; it does not provision the tool. A copyable reference
  project is still shipped (see **Reference typdoc project** above) — that's a template the user
  applies by hand, not chief configuring anything on its own.
- Cross-bucket refs (a ticket referencing a specific contract field as a typed ref) — closed off
  by the tickets-only scope above; revisit only if that need becomes concrete.
