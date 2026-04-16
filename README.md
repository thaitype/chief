# Chief Agent Framework

When you use AI coding agents on a real project, the work goes beyond a single prompt. There are multiple features to build, decisions to track, and progress to maintain across sessions.

AI doesn't reduce the effort — it changes the type. Instead of routine work like writing syntax and debugging, you spend energy on constant decision-making: which architecture, which pattern, which direction to take next. Every interaction with AI is a decision. The more you rush, the more decisions you skip, and the more tech debt follows.

**Chief Agent Framework** externalizes those decisions out of your head and into a system.

- You define rules and goals once
- A planning agent breaks work into milestones and tasks
- A builder agent implements them
- A tester agent verifies the results
- A review agent checks plans for contradictions before anything gets built

You give short prompts. The agents handle planning, execution, and verification.

Built for developers already using AI coding agents who want a structured workflow instead of ad-hoc prompting.

## Three Pillars of Working with AI

Effective AI-assisted development depends on three components working together:

- **Human** — Sets the goal, defines direction, and makes critical design decisions. The clearer the goal, the less back-and-forth needed. Templates and structured rules reduce the number of decisions you have to make.
- **Rules** — Encodes standards, contracts, and constraints so AI knows how to behave in your project. Architecture patterns, type safety, verification steps — all written down once, enforced every session.
- **AI** — Applies AI engineering techniques to work more effectively: agentic coding, multi-agent orchestration, and automatic feedback loops from external systems (type checkers, linters, tests). Better techniques mean more accurate results.

This framework provides the prompt and context structure. Coding agent selection and model selection are your own decisions.

## Supported Coding Agents

| Coding Agent | Integration | Notes |
|--------------|------------|-------|
| Claude Code | Symlinks from `.claude/` to `.agents/` | Full support (agents + skills) |
| OpenCode | Reads `.agents/` directly | No symlinks needed |

## Setup (v1 — Stable)

Recommended for production use. See [v1.0.0 release](https://github.com/thaitype/chief-agent-framework/tree/v1.0.0).

> **Note:** v1 only provides templates for Claude Code. For other coding agents, copy the files manually into the appropriate directories.
> `CLAUDE.md` contains framework rules only — do not add project-specific config there. Use `.chief/project.md` for your project details.

```bash
npx degit thaitype/chief-agent-framework/.chief#v1.0.0 .chief
npx degit thaitype/chief-agent-framework/.claude#v1.0.0 .claude
npx degit thaitype/chief-agent-framework/CLAUDE.md#v1.0.0 CLAUDE.md
```

Or using git:

```bash
git clone --depth 1 --branch v1.0.0 https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
cp -r .chief-agent-tmp/.chief .chief
cp -r .chief-agent-tmp/.claude .claude
cp .chief-agent-tmp/CLAUDE.md CLAUDE.md
rm -rf .chief-agent-tmp
```

## Setup (v2 — Development)

> **Not yet released.** Use from `main` branch for testing only.

```bash
git clone --depth 1 https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
bash .chief-agent-tmp/scripts/setup.sh claude
rm -rf .chief-agent-tmp
```

Replace `claude` with `opencode` if using OpenCode.

### Mode Options

- `--mode link` (default) — creates symlinks from agent-specific directories to `.agents/`
- `--mode copy` — copies files instead of symlinking (fallback for environments without symlink support)

```bash
bash .chief-agent-tmp/scripts/setup.sh --mode copy claude
```

### Manual Install

If you prefer not to use the setup script:

1. Copy the directories and file into your project:

```bash
git clone --depth 1 https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
cp -r .chief-agent-tmp/.agents .agents
cp -r .chief-agent-tmp/.chief .chief
cp .chief-agent-tmp/CLAUDE.md CLAUDE.md
rm -rf .chief-agent-tmp
```

2. For **Claude Code**, create symlinks from `.claude/` to `.agents/`:

```bash
mkdir -p .claude/agents .claude/skills
ln -s ../../.agents/agents/chief-agent.md .claude/agents/chief-agent.md
ln -s ../../.agents/agents/builder-agent.md .claude/agents/builder-agent.md
ln -s ../../.agents/agents/tester-agent.md .claude/agents/tester-agent.md
ln -s ../../.agents/agents/review-plan-agent.md .claude/agents/review-plan-agent.md
ln -s ../../.agents/skills/grill-me .claude/skills/grill-me
```

3. For **OpenCode**, no extra steps — it reads `.agents/` directly.

## Directory Structure

After setup, your project will have:

```
project/
├── CLAUDE.md              # Framework rules (highest authority)
├── .agents/               # Canonical agent definitions (coding-agent-agnostic)
│   ├── agents/            # Agent role definitions
│   │   ├── chief-agent.md
│   │   ├── builder-agent.md
│   │   ├── tester-agent.md
│   │   └── review-plan-agent.md
│   └── skills/            # Installable skills
│       └── grill-me/
├── .chief/                # Plans, rules, milestones
│   ├── project.md         # Project-specific config (tech stack, commands)
│   ├── MANUAL.md          # Framework usage guide
│   ├── _rules/            # Global rules
│   └── milestone-1/       # First milestone
├── .claude/               # Claude Code integration (symlinks)
│   ├── agents/ → .agents/agents/*
│   └── skills/ → .agents/skills/*
```

## How It Works

- `.agents/` is the **canonical, coding-agent-agnostic** location for agent definitions and skills
- `.chief/` contains planning, rules, milestones, and project configuration
- `CLAUDE.md` defines the highest-authority framework rules
- Agent-specific directories (`.claude/`, etc.) are populated via symlinks or copies pointing back to `.agents/`

## Getting Started

After installing, set up your project context in `.chief/project.md` (not `CLAUDE.md` — that contains framework rules only):

```
chief-agent: use grill-me to help me fill in project.md
```

Chief-agent will interview you about your tech stack, architecture, and dev commands, then fill in `.chief/project.md`. Or edit it manually if you prefer.

Milestones can be simple (`milestone-1`, `milestone-2`) or reference your project tracker (`milestone-JIRA-123`, `milestone-CU-456`).

## Agents at a Glance

| Agent | When it works | When to call manually |
|-------|--------------|----------------------|
| chief-agent | You start here. Give it a goal. | Plan work, review progress, or change direction |
| review-plan-agent | Runs automatically after every plan is created. Mandatory gate before building. | If you want to re-check an existing plan for contradictions |
| builder-agent | Chief delegates tasks to it after plan is reviewed | When a task is ready and you want to start building |
| tester-agent | Runs after builder finishes | When you need integration/E2E testing beyond unit tests |

## Quick Start Example

You're building a CLI that converts markdown to PDF. Here's the full workflow:

**1. Start a milestone**

```
chief-agent: plan milestone-1, goal is to build a CLI that converts markdown to PDF with support for custom templates
```

Chief-agent reads your rules, asks you a few key design questions (e.g. "which PDF library?"), creates contracts, and breaks the work into tasks. Review-plan-agent automatically checks the plan for contradictions and gaps before anything gets built.

**2. Build**

```
builder-agent: implement task-1 from milestone-1
```

Builder implements, runs tests, fixes lint errors, and commits.

**3. Review progress**

```
chief-agent: review milestone-1 progress and plan next tasks
```

Chief reviews completed work, plans the next batch of tasks. Review-plan-agent validates the new plan again.

**4. Repeat until done.**

## Common Prompts

| What you want | What to type |
|---|---|
| Start a new milestone | `chief-agent: plan milestone-1, goal is to ...` |
| Check progress | `chief-agent: review milestone-1 progress` |
| Start building a task | `builder-agent: implement task-1 from milestone-1` |
| Manually trigger plan review (runs automatically, but can be re-triggered) | `review-plan-agent: review milestone-1 plan` |
| Run integration tests | `tester-agent: validate milestone-1` |
| Change direction mid-milestone | `chief-agent: update milestone-1, new goal is to ...` |
| Set up project config with help | `chief-agent: use grill-me to help me fill in project.md` |

## More Examples

**TypeScript SDK for a payment API**

```
chief-agent: plan milestone-1, goal is to create a TypeScript SDK for our payment API with typed request/response and error handling
```

Chief-agent will ask key decisions (e.g. "fetch or axios?", "class-based or functional?"), then plan tasks like: generate types from OpenAPI spec, implement client methods, write tests, add docs.

**React component library with Storybook**

```
chief-agent: plan milestone-1, goal is to build a React component library with Button, Input, and Modal components, documented in Storybook
```

Chief-agent handles the planning — task breakdown, component contracts, verification steps. You answer a couple of design decisions, builder does the rest.

## Release

- `main` is the active development branch
- `v1.0.0` — first stable release (Claude Code only, uses `degit`)
- v2 release planned with multi-coding-agent support and setup script

## Acknowledgement

- Grill me Skill from [mattpocock](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md)
- Multi-agent architecture inspired by [vercel-labs/skills](https://github.com/vercel-labs/skills)
