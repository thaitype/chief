# Optional typdoc project for `_tickets/`

A ready-to-copy [typdoc](https://github.com/thaitype/typdoc) project that types this example's
`_tickets/` collection: `type`, `status`, and `blocked_by` as real fields, `blocked_by` as an
actual ref. Copy this whole `.typdoc/` folder into your own `.chief/` (or wherever your
storage root resolves to, see `chief-explain`) to get the same typing over your own tickets.
Chief works exactly the same with or without it — see `docs/design/typdoc-tickets.md` for the
full rationale.

```
.typdoc/
├── config.json               one namespace per story: story-1, story-2, ...
├── collections/tickets.json  which files: _tickets/{key}.md
├── schemas/ticket.json       the fields: type, status, blocked_by — code TK, matching
│                              Chief's own default key prefix when it numbers a ticket itself
└── state/story-1.json        the highest ticket number already issued in story-1
```

Run `typdoc validate` from inside `docs/example-chief/` to see it type-check
`story-1/_tickets/TK-1.md` — try `typdoc get TK-1 --json` too.

**Current limitation:** typdoc 0.3.1 rejects a wildcard alongside `{key}` in a collection's
`match`, so a coded document's filename can only be its bare key (`TK-1.md`) — not Chief's own
default `<key>-<slug>.md`. That's why this example's ticket has no slug in its filename, unlike
what `/chief-plan` normally writes. Once typdoc supports a slug alongside the key, drop this
note and the example ticket can go back to its slugged form — nothing else here needs to
change.

If you're adopting this over tickets that already exist (not a fresh project), hand-write
`state/<namespace>.json` with the highest number already used before running `typdoc new` —
see typdoc's own docs on state files.

The schema declares `title` even though Chief itself never reads it (a ticket's title lives in
its `# TK-<n>: <title>` heading, not frontmatter) — `typdoc new <code> "<title>"` always writes
a `title:` field from its required title argument, and without this field the schema doesn't
declare it'd trigger a harmless `frontmatter.unknown` warning on every ticket typdoc creates.
