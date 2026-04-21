# Rules Hierarchy

## Priority Order

```
┌─────────────────────────────────┐
│ 1. AGENTS.md  (Project Rules)   │  ← Highest authority
├─────────────────────────────────┤
│ 2. .chief/_rules                │  ← Global rules
├─────────────────────────────────┤
│ 3. .chief/milestone-X/_goal     │  ← Lowest authority
└─────────────────────────────────┘
```

When rules conflict, higher priority **always** wins. No exceptions.

## What Lives Where

### AGENTS.md → Project Rules (Priority 1)

Hard constraints that override everything. These are non-negotiable decisions about your project.

```md
## Project Rules

- NEVER use ORM in this project
- All APIs MUST return JSON:API format
- MUST use pnpm, not npm
- Database access ONLY through repository pattern
```

**When to put something here:**
- It's a hard constraint that should never be violated
- It applies across all milestones, all time
- Violating it would cause real damage (security, architecture, compliance)

### .chief/_rules → Global Rules (Priority 2)

Detailed standards that apply across all milestones. More verbose than AGENTS.md, includes examples.

```
.chief/_rules/
├── _standard/       # HOW to write code
├── _contract/       # WHAT the interfaces look like
├── _goal/           # WHERE we're heading (long-term)
└── _verification/   # HOW to verify correctness
```

**When to put something here:**
- It needs detail, examples, or code snippets
- It's a standard that may evolve over time
- It applies to all milestones but isn't a hard constraint

### .chief/milestone-X/_goal → Milestone Goals (Priority 3)

Scoped goals for a specific milestone. Can be more detailed than global goals but must never contradict them.

**When to put something here:**
- It only applies to this milestone
- It's a tactical decision, not a permanent rule
- It might change in the next milestone

## Conflict Resolution Examples

### Example 1: Direct Override

```
AGENTS.md:           "NEVER use MongoDB ObjectId in service layer"
.chief/_rules:       "MongoDB ObjectId may be used in some cases"
```

**Result:** AGENTS.md wins. ObjectId is never used in service layer.

### Example 2: Specificity Without Conflict

```
AGENTS.md:           "All APIs MUST return JSON:API format"
.chief/_rules:       "Pagination MUST use cursor-based approach"
milestone-1/_goal:   "Implement user listing endpoint"
```

**Result:** All three apply. The user listing endpoint uses JSON:API format with cursor-based pagination.

### Example 3: Milestone Narrows Scope

```
.chief/_rules/_goal: "Support PostgreSQL and MySQL"
milestone-1/_goal:   "Focus only on PostgreSQL for now"
```

**Result:** Valid. Milestone narrows scope without contradicting the global goal.

### Example 4: Milestone Contradicts Global

```
.chief/_rules/_standard: "All functions MUST have unit tests"
milestone-1/_goal:       "Skip tests for prototyping speed"
```

**Result:** Global rule wins. Tests are still required.

## How Agents Use the Hierarchy

1. Chief-agent reads all three levels before planning
2. If ambiguity exists, chief-agent escalates to human
3. Builder-agent follows task specs (which already resolve conflicts)
4. No agent may silently ignore a higher-priority rule
