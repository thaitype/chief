# Chief Agent Framework

Two profiles for AI-driven coding, sharing a single set of core principles.

## Profiles

### Lite

Single `AGENTS.md` at the repo root. 

**Use when**: one-off scripts, prototypes, personal tools, exploratory work, or any project where `.chief/` ceremony would add more friction than value.

```
repo/
└── AGENTS.md             # Core principles 1–6 + project-specific rules
```

### Full

AGENTS.md + `.chief/` rules directory + milestones + 4 subagents (chief, builder, tester, review-plan).

**Use when**: multi-milestone projects, shared codebases, projects with contracts and cross-team work, or any project where structured planning and delegation pay for themselves.

```
repo/
├── AGENTS.md                         # Core principles 1–6 + hierarchy + agent roles
├── .chief/
│   ├── project.md                    # Informational: tech stack, commands, architecture
│   ├── _rules/
│   │   ├── _standard/                # Empty — user-defined
│   │   ├── _goal/                    # Empty — user-defined
│   │   ├── _contract/                # Empty — user-defined
│   │   └── _verification/            # Empty — user-defined
│   ├── _template/
│   └── milestone-1/
│       ├── _contract/
│       ├── _goal/
│       ├── _plan/_todo.md
│       └── _report/
└── .agents/
    ├── agents/
    │   ├── chief-agent.md
    │   ├── builder-agent.md
    │   ├── tester-agent.md
    │   └── review-plan-agent.md
    └── skills/
        └── grill-me/SKILL.md
```

## Core principles (shared by both profiles)

Principles 1–6 are **identical and non-negotiable** in both profiles:

1. **Think before coding** — list interpretations, ask when unclear, push back when simpler exists
2. **Minimum code** — no speculative abstractions, no unrequested flexibility
3. **Surgical changes** — every changed line traces to the request
4. **Goal-driven execution** — success criteria + verification loop
5. **Escalation** — stop on ambiguity, scope leaks, or negative progress
6. **Completion** — verify before declaring done; structured commit messages

Only the **scaffolding** differs between profiles, not the principles.

## When to upgrade lite → full

Upgrade when any of these happen:

- `AGENTS.md` + `.chief/project.md` grow past ~300 lines combined
- Rules need categorization (standards vs. contracts vs. goals vs. verification)
- Work spans multiple milestones or tickets
- Multiple contributors need shared planning artifacts
- You need subagents (separate contexts for chief / builder / tester)

Upgrade is purely additive:

1. Keep `AGENTS.md` — extend with the full-mode sections (hierarchy, agent roles)
2. Keep `.chief/project.md` — move enforceable rules out to `.chief/_rules/**`
3. Create empty `.chief/_rules/{_standard,_goal,_contract,_verification}/`
4. Add `.agents/agents/` subagent definitions
5. Create first milestone

No rule rewrites. No file renames.

