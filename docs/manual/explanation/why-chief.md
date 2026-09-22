# Why Chief exists

## The problem

Every software project has context — the architecture decisions made six months ago, the reasons for that one workaround, the constraints from a compliance audit. That context lives in someone's head, in a Notion page no one updates, or in a Slack thread buried under a year of other messages.

When you use AI coding agents, that context has to move. Every new chat session starts blank. So you re-explain the project. You re-explain the rules. You re-explain the decisions you already made. You're not the developer anymore — you're the context proxy.

By the end of a full day of AI-assisted coding, most of the mental load isn't from solving hard problems. It's from repeating context that should already be known.

## The idea

Chief's premise is simple: give every project the same shape, in markdown, in places that don't move.

- `AGENTS.md` holds the rules.
- `.chief/_rules/` holds the shared standards.
- `.chief/story-N/` holds whatever you're building right now.

Once the layout is fixed, agents already know where to read and where to write. You don't have to tell them. Your prompts can be one sentence: `"Plan story 3."` `"Build ticket 2."` `"What changed?"` The agents figure out the rest because everything they need is exactly where they expect it.

The result: you stop repeating yourself. You stop burning mental cycles deciding where to put things. You ship.

## What it's not

Chief is not a project management tool. It doesn't have a UI, a kanban board, or a database. It's markdown files in your repo, versioned alongside your code.

Chief doesn't choose your tech stack, your architecture, or your agent. It provides the structure; you bring the judgment.

## Why structure reduces AI cost

Bad AI runs are expensive — not just in tokens, but in time. When an AI agent works from a vague goal, it explores. It tries things. It asks for clarification. It backtracks. Each wrong turn consumes context, requires retry, and often produces code that needs to be thrown away.

The inverse is also true: when the spec is clear and the rules are explicit, agents run straight. A well-written goal + contract pair can drive `/chief-build` through 10+ tickets with minimal human intervention — because there's nothing ambiguous to stumble on.

The cost of planning clearly isn't overhead. It's leverage.

## What Chief doesn't solve yet

Chief focuses on **pre-coding** — the design, planning, and clarification that happens before an agent writes a line of code. Getting that phase right is the highest-leverage thing you can do.

**Post-coding validation** — systematically verifying that what an agent built actually matches the spec — is harder and less solved. Chief currently delegates this to `/chief-test` (for real-world validation) and to human review. A more systematic approach to spec compliance verification is planned for a future version.

---

See also: [Pre-coding first](pre-coding-first.md), [The three-agent model](three-agent-model.md)
