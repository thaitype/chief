# Pre-coding first

## The three phases of AI-assisted development

Working with AI on real software involves three distinct phases:

1. **Pre-coding** — clarifying what to build, making design decisions, writing specs and contracts
2. **Coding** — the AI writes code
3. **Post-coding** — validating that what was built matches what was intended

Most attention in AI tooling goes to the coding phase — faster generation, better autocomplete, smarter completion. But the coding phase is not the bottleneck. AI can write code fast. The bottleneck is direction.

## Why planning matters more than you'd expect

When an AI agent has a clear goal, a scoped spec, and explicit contracts, it runs straight. When it has a vague goal, it explores. It makes assumptions. It chooses the easiest interpretation, not necessarily the right one. Each wrong turn burns context and often produces code that has to be thrown away.

The hardest bugs to fix are the ones baked into the plan. If you start building on an unexamined assumption, you'll discover the problem three tasks in — after code is written, tests are built, and changing direction means rework.

The cost of a 10-minute grill session before building is zero compared to unraveling a wrong-direction build after the fact.

## What good pre-coding looks like

Good pre-coding produces:

- **A clear goal** — what this story delivers, in one or two sentences
- **Concrete contracts** — the shapes of APIs, data models, and service boundaries that won't change mid-implementation
- **Resolved decisions** — architecture choices, trade-offs, and constraints made explicit, not left for the AI to guess

With these three things in place, `/chief-build` can implement tickets without stopping to ask clarifying questions. The plan is unambiguous enough that there's only one valid interpretation.

## The grill session

Chief's grill skills (`/grill-design` and `/chief-grill`) exist specifically for pre-coding. They don't generate code. They don't write specs. They challenge your assumptions and push you to resolve decisions before any implementation begins.

`/chief-grill` goes further: it verifies your answers against the actual codebase via a background agent. It's easy to give a plausible answer to a design question that's actually contradicted by existing code. The verifier catches that.

## What pre-coding doesn't solve

Even with a perfect spec, an AI agent can build something that doesn't match it. Pre-coding reduces this probability significantly — but it doesn't eliminate it. Post-coding validation (verifying that the implementation satisfies the spec) is a separate problem. Chief delegates this to `/chief-test` and human review. Systematic spec-compliance verification is a known gap, not a solved one.

---

See also: [Why Chief exists](why-chief.md), [The separation of concerns](three-agent-model.md), [How to stress-test a design](../how-to/stress-test-a-design.md)
