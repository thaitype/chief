# How to write effective AGENTS.md rules

This guide is for writing the `## Project Rules` section of `AGENTS.md` — the highest-authority rules in Chief.

---

## What belongs in Project Rules

Only hard constraints that:

- Apply to every story, forever
- Should never be violated under any circumstance
- Would cause real damage if ignored (security, architecture, compliance)

Everything else belongs in `.chief/_rules/`.

---

## Format

Use strong language. Agents follow rules, not preferences.

**Good:**
```md
## Project Rules

- NEVER expose internal IDs in API responses
- MUST use TypeScript strict mode
- All database migrations MUST be reversible
- Database access ONLY through repository pattern in `src/repos/`
- NEVER commit `.env` files or secrets
```

**Bad:**
```md
## Project Rules

We prefer to use dependency injection in this project because it makes
testing easier. When writing services, try to inject dependencies through
the constructor rather than importing them directly.
```

The bad version is vague (`try`, `prefer`), verbose, and explains rationale instead of stating the constraint.

---

## Rules checklist

Before adding a rule to `AGENTS.md`, check:

- [ ] Is it a constraint, not a preference? (Uses MUST/NEVER, not "prefer"/"try")
- [ ] Is it actionable? (An agent can verify compliance)
- [ ] Is it scoped? (Clear which code, files, or layers it applies to)
- [ ] Is it non-obvious? (Not already enforced by the framework)
- [ ] Would violating it cause real damage?

If any answer is "no", it belongs in `.chief/_rules/_standard/` instead.

---

## Size guide

Keep `AGENTS.md` Project Rules under 20 lines. Agents lose signal in long files.

| Location | Target size | Content type |
|---|---|---|
| `AGENTS.md` Project Rules | 5–20 lines | Hard constraints only |
| `.chief/_rules/_standard/` | 50–200 lines total | Detailed standards with examples |
| `.chief/_rules/_contract/` | As needed | Schemas, interfaces, data models |
| `.chief/_rules/_verification/` | 10–50 lines | Commands, definition of done |
| `.chief/_rules/_goal/` | 5–20 lines | Long-term direction |

---

## Common mistakes

**Putting everything in AGENTS.md** — If it needs detail or an example, it belongs in `_rules/_standard/`, not here.

**Duplicating agent behavior** — Don't re-explain what `/chief-plan` or `/chief-build` do. Their skill definitions already cover it.

**Aspirational rules** — `"Code should be clean and well-documented"` is not a rule. `"All public functions MUST have JSDoc with @param and @returns"` is.

**Missing "why" in `_rules/`** — `AGENTS.md` doesn't need rationale — it's law. But `_rules/` files benefit from a brief context line, especially for compliance or incident-driven rules.

---

## Related

- [Rules hierarchy reference](../reference/rules-hierarchy.md)
- [How to capture a decision as a permanent rule](capture-a-rule.md)
