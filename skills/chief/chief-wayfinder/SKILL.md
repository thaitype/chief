---
name: chief-wayfinder
description: Chart a story's fog as a map of decision-tickets when the story is too foggy for one grill session, and resolve them one at a time. Optional — explicit invocation only, offered as a choice at /chief-plan's Phase 0, callable again at any later point in the story's life if new fog surfaces.
---

A story has arrived wrapped in fog: the way from here to a written goal/contract isn't visible
yet. Wayfinding charts that way as a **map** — one file, scoped to this single story — and works
its **decision-tickets** (questions whose resolution is a decision, not a slice of build to
execute) one at a time until the fog clears enough to write `_goal/goal.md` and
`_contract/contract.md`.

**Scoped to one story.** Unlike a general-purpose wayfinder that can span many units of work,
this map never outgrows the story it belongs to — the story is the root container (see
`docs/design/v5-ai-workflow.md` for why). If charting reveals the idea is actually several
stories' worth of work, say so and stop rather than letting the map sprawl; the human splits it
into separate stories first.

**Plan, don't do.** Each ticket resolves a decision. The map is done when the way is clear, with
nothing left to decide before `/chief-plan` can write the goal and contract. The pull to just
implement something is the signal you've reached the edge of the map — hand off to `/chief-plan`
instead.

**Explicit invocation only.** Never trigger this yourself because a story "looks foggy." A human
runs `/chief-wayfinder`, or `/chief-plan`'s Phase 0 offers it as a choice and the human picks it.
Callable again later in the same story's life if new fog surfaces mid-build — not restricted to
running before `/chief-plan` starts.

**Storage location:** `.chief/` is the default. If `.chief.config.md` exists at the repo
root, resolve `storage-root:` from it first and use that path everywhere below instead.

---

## The map

One file per story: `.chief/story-N/_map.md`. Created only when `/chief-wayfinder` is first
invoked on that story (lazy, like everything else under `.chief/`).

```markdown
## Destination

<what "the fog is clear" looks like for this story — one or two lines, oriented to before
starting on any ticket>

## Notes

<domain context; skills this story's sessions should consult; standing preferences>

## Decisions so far

<!-- index: one line per resolved ticket, enough to judge relevance, zoom the link for detail -->

- [<ticket title>](../_tickets/<id>-<slug>.md): <one-line gist of the answer>

## Not yet specified

<!-- fog: in-scope questions you can sense but can't sharpen into a ticket yet -->

## Out of scope

<!-- ruled beyond this story's destination — closed, never graduates -->
```

The map is an **index**, not a store. It gists resolved decisions and points at the ticket that
holds the detail — a decision lives in exactly one place, its ticket.

---

## Tickets

Decision-tickets live in the **same** `.chief/story-N/_tickets/` folder as
`/chief-plan`'s implementation tickets (see `docs/design/v5-ai-workflow.md`, "Ticket model") —
one shared numbering sequence, one shared file shape, distinguished by the `Type:` field:

```markdown
# 3: <the question>

Type: wayfinder:research | wayfinder:prototype | wayfinder:grilling | wayfinder:task
Status: open | claimed | resolved
Blocked by: 1  (or "None (can start immediately)")

## Question

<the decision or investigation this ticket resolves — sized to one session>

## Answer

<filled in on resolve>
```

A session **claims** a ticket by setting `Status: claimed` **before** any work, so concurrent
sessions skip it. **Frontier** = tickets with `Type: wayfinder:*`, `Status: open`, and every
blocker `resolved`.

### Ticket types

Every ticket is **HITL** (worked with a human who speaks for themselves) or **AFK** (agent
alone). A HITL ticket only resolves through that live exchange — never answer your own question
on the human's behalf.

- **`wayfinder:research`** (AFK) — reading docs, third-party APIs, or local resources to surface
  a fact a decision waits on. Resolve by calling the Skill tool with `research`.
- **`wayfinder:prototype`** (HITL) — raise the fidelity of discussion with a cheap, rough,
  concrete artifact (outline, stub, UI/logic snippet) via the Skill tool with `prototype`. Link
  it as an asset from the ticket; don't paste it inline.
- **`wayfinder:grilling`** (HITL) — conversation, the default case. Call the Skill tool with
  `grill-design`, then **verify the answer against the codebase inline before recording it** —
  same discipline `/chief-grill` uses, folded in here rather than delegated to a separate
  persistent agent: after the human answers, spawn a throwaway sub-agent to check any checkable
  claim in the answer (file paths, library names, existing patterns) against the repo, and
  against this map's own `Decisions so far`. If it comes back `concern` or `conflict`, surface
  it before recording the answer as resolved.
- **`wayfinder:task`** (HITL or AFK) — manual work that must happen before a decision can be
  made (provisioning access, moving data so its shape can be seen) — the one type that *does*
  rather than decides, earning its place by unblocking a decision. Drive it yourself where you
  can (AFK); otherwise hand the human a precise checklist (HITL). The answer records what was
  done and any resulting facts later tickets depend on.

## Fog of war

Don't chart what you can't yet see. The map's **Not yet specified** section holds questions you
can sense are coming but can't yet phrase precisely. Resolving a ticket clears the fog ahead of
it — graduate whatever's now specifiable into a fresh ticket, one at a time.

**Ticket when** the question is already sharp, even if blocked. **Not yet specified when** you
can't phrase it that sharply yet — don't pre-slice fog into ticket-sized pieces before it's
ready.

## Out of scope

Work beyond this story's destination isn't fog — it gets its own **Out of scope** line: the
gist, why it's out, linking any ticket that turned out to sit past the destination (close that
ticket rather than resolving it on the route). Stays out of **Decisions so far**, which records
the route actually walked.

---

## Invocation

Never resolve more than one ticket per session, except research tickets.

### Chart the map (first invocation on this story)

1. **Name the destination.** Call the Skill tool with `grill-design`, focused on: what does
   "ready to write the goal and contract" look like for this story? Settle this first — it
   fixes scope for everything else.
2. **Map the frontier**, breadth-first: grill again to fan out across the whole space rather
   than deep on one thread, surfacing open decisions and first steps takeable now. **If this
   surfaces no real fog** (the way is already clear, small enough for one `/chief-plan` grill
   session), say so and hand off to `/chief-plan` directly — you don't need a map for this.
3. **Create `.chief/story-N/_map.md`**: Destination and Notes filled in, Decisions so far empty,
   fog sketched into Not yet specified.
4. **Create the tickets you can specify now**, then wire `Blocked by` edges in a second pass
   (numbers need to exist before they can reference each other).
5. **Fire `wayfinder:research` tickets in parallel**: for each, spin up a subagent that calls
   the Skill tool with `research`.
6. Stop — charting is one session's work, it hand-resolves nothing.

### Work through the map (resume)

1. Load `.chief/story-N/_map.md` — the low-res view, not every ticket body.
2. Pick the ticket: if the human named one, use it; otherwise take the first frontier ticket.
   **Claim it** before any work.
3. Resolve it per its type (see above). Zoom into any related/closed ticket body on demand.
4. Record: append the answer under `## Answer`, set `Status: resolved`, append a context
   pointer to the map's Decisions so far.
5. Add newly-surfaced tickets (create, then wire blocking); graduate any fog the answer made
   specifiable, clearing it from Not yet specified. If the answer reveals a ticket sits beyond
   the destination, rule it out of scope instead of resolving it on the route.
6. **When the frontier is empty and Not yet specified is empty**: the fog is clear. Tell the
   human `/chief-plan` can now write the goal and contract — this map's Decisions so far is
   the input for that Phase 0/1/2, and Phase 0 shouldn't re-grill anything already answered
   here.

### From `/chief-plan`'s Phase 0

When a human picks "use wayfinder" at Phase 0, `/chief-plan` hands off here targeting the
current story (creating it first if it doesn't exist yet). On return, `/chief-plan` resumes its
own Phase 0, grilling only what this map didn't already resolve.
