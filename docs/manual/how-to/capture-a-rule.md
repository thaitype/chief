# How to capture a decision as a permanent rule

Use this guide when you've made a decision — in a grill session, a retro, or just mid-work — that should apply to every future story, not just this one.

---

## When to do this

- You made an architectural decision that should never be revisited (e.g. "always use cursor-based pagination")
- A mistake happened and you want to prevent it from recurring (e.g. "never make live network calls in unit tests")
- You've been telling the agent the same constraint repeatedly across multiple chats

---

## Using `/chief-rule`

```
/chief-rule
```

Describe the rule in plain language when prompted. The skill determines the right category (`_standard`, `_contract`, `_goal`, or `_verification`), drafts the rule in the correct format, and asks you to confirm before writing it to `.chief/_rules/`.

Rules written here apply to **every future story** — every `chief-*` skill reads `.chief/_rules/` at the start of each session.

---

## Using `/chief-retro` (after a story)

If you're running a retrospective and patterns emerge:

```
/chief-retro
```

The retro skill compares what was delivered to what was planned, identifies recurring issues, and proposes rules for `.chief/_rules/`. You choose which ones to keep. The rules are written automatically on your approval.

---

## Writing rules manually

If you prefer to write directly, add a file under `.chief/_rules/`:

```
.chief/_rules/
├── _standard/       ← how to write code (style, patterns)
├── _contract/       ← API schemas, data models, service boundaries
├── _goal/           ← long-term direction
└── _verification/   ← test commands, definition of done
```

Rules in `_rules/` should be:
- Concise — agents lose signal past ~200 lines total
- Specific — "MUST use cursor-based pagination" not "prefer cursor pagination"
- Scoped — clear about which code, layer, or situation it applies to

For hard constraints that override everything including `_rules/`, put them in `AGENTS.md` under `## Project Rules`. See [How to write effective AGENTS.md rules](write-agents-md.md).

---

## Related

- [Rules hierarchy reference](../reference/rules-hierarchy.md)
- [How to write effective AGENTS.md rules](write-agents-md.md)
