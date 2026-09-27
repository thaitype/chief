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
├── collections/tickets.json  which files: _tickets/{key}.md, slug optional
├── schemas/ticket.json       the fields: type, status, blocked_by — code TK, matching
│                              Chief's own default key prefix when it numbers a ticket itself
└── state/story-1.json        the highest ticket number already issued in story-1
```

Run `typdoc validate` from inside `docs/example-chief/` to see it type-check
`story-1/_tickets/TK-1-example-ticket.md` — try `typdoc get TK-1 --json` too.

**Slugged filenames work as of typdoc 0.4.0** — a collection's `slug` setting (`optional` by
default, which this one uses) allows `TK-1-example-ticket.md` to resolve as key `TK-1`, same as
Chief's own default `<key>-<slug>.md`. `typdoc new TK "Title" --slug some-slug` names the file
to match. On typdoc 0.3.x, only the bare key (`TK-1.md`, no slug) validated — if you're on that
version, drop the slug from your own tickets' filenames until you upgrade.

If you're adopting this over tickets that already exist (not a fresh project), hand-write
`state/<namespace>.json` with the highest number already used before running `typdoc new` —
see typdoc's own docs on state files.

The schema declares `title` even though Chief itself never reads it (a ticket's title lives in
its `# TK-<n>: <title>` heading, not frontmatter) — `typdoc new <code> "<title>"` always writes
a `title:` field from its required title argument, and without this field the schema doesn't
declare it'd trigger a harmless `frontmatter.unknown` warning on every ticket typdoc creates.
