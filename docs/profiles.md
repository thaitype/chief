# Profiles

The Chief Agent Framework ships in two profiles: **lite** and **full**. Both share the same six core principles. The only difference is the scaffolding around them.

---

## Lite Profile

A single `AGENTS.md` at the repo root, plus a symlink wiring it into your coding agent.

```
repo/
└── AGENTS.md             # Core principles + project-specific rules
```

When you install via `npx`, the setup creates a symlink automatically (e.g., `AGENTS.md → CLAUDE.md` for Claude Code). If you are setting up manually, create it yourself:

```bash
ln -s AGENTS.md CLAUDE.md   # Claude Code
ln -s AGENTS.md .cursorrules # Cursor
```

**When to use lite:**

- One-off scripts, prototypes, personal tools
- Exploratory work where structure adds more friction than value
- Solo projects where a single file is sufficient context

---

## Full Profile

`AGENTS.md` plus a `.chief/` directory containing global rules, milestone tracking, and subagent definitions.

```
repo/
├── AGENTS.md
├── .chief/
│   ├── project.md
│   ├── _rules/
│   │   ├── _standard/
│   │   ├── _goal/
│   │   ├── _contract/
│   │   └── _verification/
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
```

**When to use full:**

- Multi-milestone projects with evolving plans
- Shared codebases with multiple contributors
- Projects that need contracts (API schemas, data models, service boundaries)
- Work that benefits from delegating to separate chief, builder, and tester agents

---

## Core Principles (Shared by Both Profiles)

Both profiles embed the same six principles in `AGENTS.md`. These are non-negotiable regardless of profile:

1. **Think before coding** — List interpretations, ask when unclear, push back when a simpler approach exists.
2. **Minimum code** — No speculative abstractions, no unrequested flexibility.
3. **Surgical changes** — Every changed line traces to the request.
4. **Goal-driven execution** — Define success criteria and verify against them.
5. **Escalation** — Stop on ambiguity, scope leaks, or negative progress.
6. **Completion** — Verify before declaring done; use structured commit messages.

Only the scaffolding differs between profiles, not the principles.

---

## When to Upgrade Lite to Full

Upgrade when any of these conditions arise:

- `AGENTS.md` grows past ~300 lines
- Rules need categorization — standards, contracts, goals, and verification belong in separate directories
- Work spans multiple milestones or tickets
- Multiple contributors need shared planning artifacts
- You want separate agent contexts for chief, builder, and tester work

---

## Upgrade Process

Upgrading is purely additive. Nothing needs to be rewritten or renamed.

1. Keep `AGENTS.md` — extend it with the full-mode sections (hierarchy, agent roles).
2. Keep `.chief/project.md` — move enforceable rules out to `.chief/_rules/`.
3. Create `.chief/_rules/{_standard,_goal,_contract,_verification}/`.
4. Add `.agents/agents/` with subagent definitions.
5. Create your first milestone directory.

To scaffold this automatically, run:

```bash
/upgrade-chief
```

---

## Grill-Me in Lite Mode

The `grill-me` skill works in lite mode but is not installed by default. To add it separately:

```bash
npx skills@latest add thaitype/chief-agent-framework --skill grill-me
```

Once installed, use it before starting any significant piece of work to surface hidden assumptions and resolve the decision tree before building begins.
