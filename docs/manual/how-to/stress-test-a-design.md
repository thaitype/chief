# How to stress-test a design before building

Use this guide when you have a design idea, architecture decision, or plan you want challenged before you commit to it.

---

## When to do this

- You're about to make an irreversible architectural decision (database choice, auth model, data schema)
- Your goal exists but you suspect there are hidden assumptions you haven't examined
- You've been burned before by planning on top of things that turned out to be wrong
- You want a second opinion that knows your actual codebase, not just general advice

---

## Quick stress-test: `/grill-design`

For smaller decisions or early-stage exploration:

```
/grill-design
```

Describe your idea when prompted. The skill walks the decision tree, asks one question at a time, and — crucially — self-critiques its own suggested answers before presenting them to you. This catches cases where the first answer is plausible but undersells trade-offs.

Stateless: the session lives in agent context only. If context resets, the session is gone.

---

## Deep stress-test: `/chief-grill`

For high-stakes decisions or anything you might want to resume later:

```
/chief-grill
```

Name the session when prompted (e.g. "auth redesign", "database migration strategy"). The skill:

1. Opens a session file at `.chief/_grill/opened/NNNN-topic.md`
2. Asks questions one at a time
3. Writes every Q&A to the file as it goes — survives context resets
4. Spawns a throwaway verifier subagent in the background to verify each answer against your actual repo before moving to the next question

At the end, the skill summarises the session and asks whether to proceed or revise any answers. The session file is moved to `.chief/_grill/coach/` when closed.

> **Token cost:** `/chief-grill` runs two agents simultaneously — expect roughly double the token usage of a normal skill session. The trade-off is codebase-grounded verification that a single-agent session can't provide.

---

## After the session

If any decisions should be permanent rules — not just one-off choices — capture them:

```
/chief-rule
```

See [How to capture a decision as a permanent rule](capture-a-rule.md).

If you're ready to plan the story:

```
/chief-plan
```

The grill session output feeds directly into planning.

---

## Related

- [How to pick the right skill](pick-the-right-skill.md)
- [Skills reference](../reference/skills.md)
- [Why pre-coding matters](../explanation/pre-coding-first.md)
