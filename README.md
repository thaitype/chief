# Chief Agent Framework

**English** | **[ไทย](README.th.md)**

A framework that reduces the cognitive load of working with AI coding agents — without sacrificing quality or speed.

> Under the hood, Chief Agent Framework is just markdown files. It defines structure for your AI agents to follow.

> You're currently on v2 document, which supports multiple coding agents. If you have v1 installed, follow the [upgrade instructions](#upgrading) below or see the [v1 docs](https://github.com/thaitype/chief-agent-framework/tree/release/v1)

When you use AI coding agents on a real project, the work goes beyond a single prompt. There are multiple features to build, decisions to track, and progress to maintain across sessions.

AI doesn't reduce the effort — it changes the type. Instead of routine work like writing syntax and debugging, you spend energy on constant decision-making: which architecture, which pattern, which direction to take next. Every interaction with AI is a decision. The more you rush, the more decisions you skip, and the more tech debt follows.

**Chief Agent Framework** externalizes those decisions out of your head and into a system.

- You define rules and goals once
- A planning agent breaks work into milestones and tasks
- A builder agent implements them
- A tester agent verifies the results
- A review agent can check plans for contradictions when you want a second opinion

You give short prompts. The agents handle planning, execution, and verification.

Built for developers already using AI coding agents who want a structured workflow instead of ad-hoc prompting.

## Three Pillars of Working with AI

Effective AI-assisted development depends on three components working together:

- **Human** — Sets the goal, defines direction, and makes critical design decisions. The clearer the goal, the less back-and-forth needed. Templates and structured rules reduce the number of decisions you have to make.
- **Rules** — Encodes standards, contracts, and constraints so AI knows how to behave in your project. Architecture patterns, type safety, verification steps — all written down once, enforced every session.
- **AI** — Applies AI engineering techniques to work more effectively: agentic coding, multi-agent orchestration, and automatic feedback loops from external systems (type checkers, linters, tests). Better techniques mean more accurate results.

This framework provides the prompt and context structure. Coding agent selection and model selection are your own decisions.

## Supported Coding Agents

| Coding Agent                                                    | Integration                                           | Notes                                  |
| --------------------------------------------------------------- | ----------------------------------------------------- | -------------------------------------- |
| Claude Code                                                     | `CLAUDE.md → AGENTS.md` symlink + `.claude/` symlinks | Full support (agents + skills)         |
| GitHub Copilot                                                  | `.github/agents/` symlinks or copies                  | Full support (agents)                  |
| OpenCode, Codex, Cursor, Gemini CLI, Amp, Windsurf, Kiro, Aider | Reads `AGENTS.md` natively                            | Should work out of the box (untested ⚠️ — [open an issue](https://github.com/thaitype/chief-agent-framework/issues) if you hit problems) |

## Setup

Current version is v2, which supports multiple coding agents. If you have v1 installed, follow the [upgrade instructions](#upgrading) below.

```bash
npx skills@latest add thaitype/chief-agent-framework --skill install-chief
```

```
/install-chief
```

The skill asks which coding agent you use, picks the install mode, copies framework files, and sets up everything.

For manual installation options (shell script, git clone), see [docs/manual-install.md](docs/manual-install.md).

> **Windows users:** Link mode requires Developer Mode enabled and `git config --global core.symlinks true`. The setup script auto-detects this — if symlinks aren't available, it falls back to copy mode.

## Directory Structure

After setup, your project will have:

```
project/
├── AGENTS.md               # Framework rules — canonical file (highest authority)
├── CLAUDE.md → AGENTS.md   # Symlink (Claude Code only)
├── .github/agents/        # Copilot agent definitions (symlinks or copies)
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
- `AGENTS.md` defines the highest-authority framework rules
- `CLAUDE.md` is a symlink to `AGENTS.md` (Claude Code only)
- `.github/agents/` contains symlinks or copies for GitHub Copilot
- Agent-specific directories (`.claude/`, `.github/agents/`, etc.) are populated via symlinks or copies pointing back to `.agents/`

## Getting Started

After installing, set up your project context in `.chief/project.md` (not `AGENTS.md` — that contains framework rules only):

```
chief-agent: use grill-me to help me fill in project.md
```

Chief-agent will interview you about your tech stack, architecture, and dev commands, then fill in `.chief/project.md`. Or edit it manually if you prefer.

Milestones can be simple (`milestone-1`, `milestone-2`) or reference your project tracker (`milestone-JIRA-123`, `milestone-CU-456`).

## Agents at a Glance

| Agent             | When it works                                                                   | When to call manually                                       |
| ----------------- | ------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| chief-agent       | You start here. Give it a goal.                                                 | Plan work, review progress, or change direction             |
| review-plan-agent | Optional. Not part of the automatic flow.                                       | When you want to validate a plan for contradictions         |
| builder-agent     | Chief delegates tasks to it after plan is reviewed                              | When a task is ready and you want to start building         |
| tester-agent      | Runs after builder finishes                                                     | When you need integration/E2E testing beyond unit tests     |

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

| What you want                                                              | What to type                                              |
| -------------------------------------------------------------------------- | --------------------------------------------------------- |
| Start a new milestone                                                      | `chief-agent: plan milestone-1, goal is to ...`           |
| Check progress                                                             | `chief-agent: review milestone-1 progress`                |
| Start building a task                                                      | `builder-agent: implement task-1 from milestone-1`        |
| Validate a plan for contradictions (optional)                              | `review-plan-agent: review milestone-1 plan`              |
| Run integration tests                                                      | `tester-agent: validate milestone-1`                      |
| Change direction mid-milestone                                             | `chief-agent: update milestone-1, new goal is to ...`     |
| Set up project config with help                                            | `chief-agent: use grill-me to help me fill in project.md` |

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

> this will be upgraded to v2

Install the upgrade skill:

```bash
npx skills@latest add thaitype/chief-agent-framework --skill upgrade-chief
```

Then run:

```
/upgrade-chief
```

With no arguments, it upgrades to the latest stable release. Or specify a version:

```
/upgrade-chief canary
/upgrade-chief v2.0.0
```

The skill compares your current files against the target version, creates an upgrade plan, and waits for your approval before applying any changes.

## Release

- v1 was the initial release, focused on Claude Code support, see the [docs](https://github.com/thaitype/chief-agent-framework/tree/release/v1) for details.

## Branches
- `release/v1` — Stable v1 release, focused on Claude Code support
- `main` - latest stable release (currently v2)
- `canary` - active development branch, may be unstable

## Development

To test changes locally before submitting a PR:

1. Push your feature branch to GitHub
2. In a **separate test project** (not inside this repo), install the skill from your branch:

```bash
npx skills@latest add thaitype/chief-agent-framework#<your-branch> --skill install-chief
```

3. Test it:

```
/install-chief <your-branch>
```

The same pattern works for other skills like `upgrade-chief`.

## Contributing

1. Fork the repo and branch from `canary`
2. Make your changes
3. Test locally using the [Development](#development) workflow above
4. Push and open a PR targeting `canary`
5. Follow existing commit style: `type: description` (e.g. `fix: resolve merge issue`, `feat: add kiro agent support`)

## Acknowledgement

- Grill me Skill from [mattpocock](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md)
- Multi-agent architecture inspired by [vercel-labs/skills](https://github.com/vercel-labs/skills)
