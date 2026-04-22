# Writing an Effective AGENTS.md

## Design Principles

1. **Project Rules at the top** — highest authority, first thing agents read
2. **Under 100 lines total** — beyond ~200 lines, agents lose signal
3. **Bullets over prose** — discrete rules are followed; paragraphs get summarized
4. **Strong language for hard rules** — MUST, NEVER, CRITICAL
5. **No redundancy with agent definitions** — agents already have their behavior in `.agents/agents/*.md`

## Structure

```md
# AGENTS.md

## Project Rules
(your hard constraints here)

---

## Rules Hierarchy
(standard — don't modify)

---

## Chief Agent Framework
(standard reference — don't modify)

---

## Project Configuration
(pointer to .chief/project.md)
```

## Writing Good Project Rules

### Do

```md
## Project Rules

- NEVER expose internal IDs in API responses
- MUST use dependency injection for all service constructors
- All database migrations MUST be reversible
- Error responses MUST include correlation ID
- NEVER import from `src/internal/` outside that module
```

### Don't

```md
## Project Rules

We prefer to use dependency injection in this project because it makes
testing easier. When writing services, try to inject dependencies through
the constructor rather than importing them directly. This helps with
mocking in tests and makes the code more modular.
```

**Why:** The "Don't" example is vague (try, prefer), verbose (4 lines for one rule), and explains motivation instead of stating the constraint. Agents need rules, not rationale.

## Rule Writing Checklist

- [ ] Is it a constraint, not a preference? (Use MUST/NEVER, not "prefer"/"try")
- [ ] Is it actionable? (Agent can verify compliance)
- [ ] Is it scoped? (Clear what code/files/layers it applies to)
- [ ] Is it non-obvious? (Don't state what the framework already enforces)
- [ ] Would violating it cause real damage?

If any answer is "no," it probably belongs in `.chief/_rules/_standard/` instead.

## Common Mistakes

### 1. Putting everything in AGENTS.md

AGENTS.md is for hard constraints. Detailed coding standards, API schemas, and testing procedures belong in `.chief/_rules/`.

```
AGENTS.md        → "MUST use PostgreSQL" (one line)
_rules/_standard → "Connection pooling config, naming conventions, migration patterns" (detailed)
```

### 2. Duplicating agent behavior

Don't re-explain what chief/builder/tester do. That's already in their agent definitions. AGENTS.md just needs the reference table.

### 3. Writing aspirational rules

```md
# Bad — aspirational
- Code should be clean and well-documented

# Good — enforceable
- All public functions MUST have JSDoc with @param and @returns
```

### 4. Missing the "why" in _rules

AGENTS.md doesn't need "why" — it's law. But `.chief/_rules/` files benefit from brief context:

```md
# .chief/_rules/_standard/auth.md

- MUST validate JWT signature on every request (not just presence)
- NEVER store tokens in localStorage — use httpOnly cookies only
- Session timeout MUST be 30 minutes for admin routes

Why: SOC2 compliance requirement from 2024 audit.
```

## Sizing Guide

| Location | Target Size | Content Type |
|----------|-------------|--------------|
| AGENTS.md Project Rules | 5–20 lines | Hard constraints only |
| .chief/_rules/_standard/ | 50–200 lines total | Detailed standards with examples |
| .chief/_rules/_contract/ | As needed | Schemas, interfaces, data models |
| .chief/_rules/_verification/ | 10–50 lines | Commands, definition of done |
| .chief/_rules/_goal/ | 5–20 lines | Long-term direction |

## Example: Complete AGENTS.md for a Backend Project

```md
# AGENTS.md

## Project Rules

- MUST use TypeScript strict mode
- NEVER use `any` type — use `unknown` + type guards
- All endpoints MUST validate input with Zod schemas
- Database access ONLY through repository pattern in `src/repos/`
- NEVER commit .env files or secrets
- Error handling MUST use Result type, not thrown exceptions
- All breaking API changes MUST increment major version

---

## Rules Hierarchy

1. **Project Rules** above (highest authority)
2. `.chief/_rules`
3. `.chief/milestone-X/_goal` (lowest authority)

If rules conflict, higher priority wins. Always.

---

## Chief Agent Framework

(standard framework reference section)

---

## Project Configuration

Project-specific details (dev commands, tech stack, architecture) are defined in `.chief/project.md`.
```
