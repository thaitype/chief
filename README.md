# Chief Agent Framework

When you use AI coding agents on a real project, the work goes beyond a single prompt. There are multiple features to build, decisions to track, and progress to maintain across sessions.

AI doesn't reduce the effort — it changes the type. Instead of routine work like writing syntax and debugging, you spend energy on constant decision-making: which architecture, which pattern, which direction to take next. Every interaction with AI is a decision. The more you rush, the more decisions you skip, and the more tech debt follows.

**Chief Agent Framework** externalizes those decisions out of your head and into a system.

- You define rules and goals once
- A planning agent breaks work into milestones and tasks
- A builder agent implements them
- A tester agent verifies the results

You give short prompts. The agents handle planning, execution, and verification.

Built for developers already using AI coding agents who want a structured workflow instead of ad-hoc prompting.

## Three Pillars of Working with AI

Effective AI-assisted development depends on three components working together:

- **Human** — Sets the goal, defines direction, and makes critical design decisions. The clearer the goal, the less back-and-forth needed. Templates and structured rules reduce the number of decisions you have to make.
- **Rules** — Encodes standards, contracts, and constraints so AI knows how to behave in your project. Architecture patterns, type safety, verification steps — all written down once, enforced every session.
- **AI** — Applies AI engineering techniques to work more effectively: agentic coding, multi-agent orchestration, and automatic feedback loops from external systems (type checkers, linters, tests). Better techniques mean more accurate results.

This framework provides the prompt and context structure. Coding agent selection and model selection are your own decisions.

## Supported Coding Agents

`AGENTS.md` is the cross-tool standard (Linux Foundation AAIF). `CLAUDE.md` is a symlink to `AGENTS.md` for Claude Code compatibility.

| Coding Agent | Integration | Notes |
|--------------|------------|-------|
| Claude Code | `CLAUDE.md → AGENTS.md` symlink + `.claude/` agents/skills | Full support |
| OpenCode, Codex, Cursor, Copilot, Gemini CLI, Amp, Windsurf, Kiro, Aider | Reads `AGENTS.md` natively | Works out of the box |

## Setup

### Setup with degit (Recommended)

```bash
npx degit thaitype/chief-agent-framework/.chief#v1 .chief
npx degit thaitype/chief-agent-framework/.claude#v1 .claude
npx degit thaitype/chief-agent-framework/AGENTS.md#v1 AGENTS.md
```

Then create `CLAUDE.md` symlink for Claude Code:

```bash
ln -s AGENTS.md CLAUDE.md
```

### Setup with git

```bash
git clone --depth 1 --branch v1 https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
cp -r .chief-agent-tmp/.chief .chief
cp -r .chief-agent-tmp/.claude .claude
cp .chief-agent-tmp/AGENTS.md AGENTS.md
ln -s AGENTS.md CLAUDE.md
rm -rf .chief-agent-tmp
```

## Directory Structure

After setup, your project will have:

```
project/
├── AGENTS.md              # Framework rules — canonical file (highest authority)
├── CLAUDE.md → AGENTS.md  # Symlink for Claude Code compatibility
├── .chief/                # Plans, rules, milestones
│   ├── project.md         # Project-specific config (tech stack, commands)
│   ├── MANUAL.md          # Framework usage guide
│   ├── _rules/            # Global rules
│   └── milestone-1/       # First milestone
├── .claude/               # Claude Code agents and skills
│   └── agents/
│       ├── chief-agent.md
│       ├── builder-agent.md
│       └── tester-agent.md
```

## How It Works

- `AGENTS.md` defines the highest-authority framework rules. `CLAUDE.md` is a symlink to it for Claude Code compatibility
- `.chief/` contains planning, rules, milestones, and project configuration
- `.claude/agents/` contains agent definitions (Claude Code specific)
- Other coding agents read `AGENTS.md` directly

## Getting Started

After installing, fill in `.chief/project.md` with your project's tech stack, dev commands, and architecture.

Milestones can be simple (`milestone-1`, `milestone-2`) or reference your project tracker (`milestone-JIRA-123`, `milestone-CU-456`).

## Agents at a Glance

| Agent | When it works | When to call manually |
|-------|--------------|----------------------|
| chief-agent | You start here. Give it a goal. | Plan work, review progress, or change direction |
| builder-agent | Chief delegates tasks to it | When a task is ready and you want to start building |
| tester-agent | Runs after builder finishes | When you need integration/E2E testing beyond unit tests |

## Quick Start Example

You're building a CLI that converts markdown to PDF. Here's the full workflow:

**1. Start a milestone**

```
chief-agent: plan milestone-1, goal is to build a CLI that converts markdown to PDF with support for custom templates
```

Chief-agent reads your rules, asks you a few key design questions (e.g. "which PDF library?"), creates contracts, and breaks the work into tasks.

**2. Build**

```
builder-agent: implement task-1 from milestone-1
```

Builder implements, runs tests, fixes lint errors, and commits.

**3. Review progress**

```
chief-agent: review milestone-1 progress and plan next tasks
```

Chief reviews completed work, plans the next batch of tasks.

**4. Repeat until done.**

## Common Prompts

| What you want | What to type |
|---|---|
| Start a new milestone | `chief-agent: plan milestone-1, goal is to ...` |
| Check progress | `chief-agent: review milestone-1 progress` |
| Start building a task | `builder-agent: implement task-1 from milestone-1` |
| Run integration tests | `tester-agent: validate milestone-1` |
| Change direction mid-milestone | `chief-agent: update milestone-1, new goal is to ...` |

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

## Upgrading

To upgrade to the latest v1.x, re-run the setup commands. Existing files will be overwritten.

For skill-based upgrades (install-chief, upgrade-chief), see the [`canary` branch](https://github.com/thaitype/chief-agent-framework/tree/canary).

## Release

- `canary` is the active development branch — use for testing unreleased changes, not for production
- Stable releases are tagged (e.g. `v1.0.0`) on release branches (`release/v1`)
- `v1.0.0` — first stable release (Claude Code focused)
- `v1.1.0` — added multi-coding-agent support via `AGENTS.md`, split project config to `.chief/project.md`
- v2 release planned with `.agents/` canonical directory and setup script

## Acknowledgement

- Multi-agent architecture inspired by [vercel-labs/skills](https://github.com/vercel-labs/skills)
