# Chief Agent Framework

**English** | **[ไทย](README.th.md)**

A framework that reduces the cognitive load of working with AI coding agents — without sacrificing quality or speed.

> Under the hood, Chief Agent Framework is just markdown files. It defines structure for your AI agents to follow.

> You're currently on v2 document, which supports multiple coding agents. If you have v1 installed, follow the [upgrade instructions](#upgrading) below or see the [v1 docs](https://github.com/thaitype/chief-agent-framework/tree/release/v1)

Chief Agent Framework is a structured workflow for AI coding agents. You define rules and goals once, and agents handle planning, building, and verification across sessions — milestone by milestone.

When you use AI on a real project, the challenge isn't writing code — it's the constant decision-making. Which architecture, which pattern, which direction next. Every AI interaction is a decision. The more you rush, the more you skip, and the more tech debt follows.

This framework externalizes those decisions into a system:

- A planning agent breaks work into milestones and tasks
- A builder agent implements them
- A tester agent verifies the results
- A review agent can check plans for contradictions when you want a second opinion

Built for developers already using AI coding agents who want a structured workflow instead of ad-hoc prompting. Learn more about the [design philosophy](docs/philosophy.md).

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
│       ├── grill-me/
│       ├── plan-milestone/
│       ├── autopilot-chief/
│       ├── retro-chief/
│       └── dump-commit/
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
| tester-agent      | Only when you request it — not part of the automatic flow                        | When you need integration/E2E testing beyond unit tests     |

## Quick Start — Pick Your Style

There are two ways to work. Pick the one that fits your situation.

### Option A: Controlled (review every step)

Best for: complex projects, unfamiliar domains, team work.

```
/plan-milestone              # grill → goals → contracts → TODO → specs (approval at each step)
builder-agent: implement task-1 from milestone-1   # delegate tasks one by one
/retro-chief                 # review coverage and propose rule updates
```

You stay in control. Every goal, contract, and task is reviewed before execution.

### Option B: Autonomous (let AI drive)

Best for: prototyping, well-defined goals, solo work.

```
/autopilot-chief             # reads goals + contracts, creates TODO, runs all tasks
/retro-chief                 # review what happened
```

Requires goals and contracts to exist. Use `/plan-milestone` first if they don't, or write them yourself.

### Mix and match

You can combine both. Plan with review gates, then switch to autopilot for execution:

```
/plan-milestone              # plan carefully with approval gates
/autopilot-chief             # execute the approved plan autonomously
/retro-chief                 # review and learn
```

## Common Prompts

| What you want                          | What to type                                              |
| -------------------------------------- | --------------------------------------------------------- |
| Plan a milestone step-by-step          | `/plan-milestone`                                         |
| Run milestone on autopilot             | `/autopilot-chief`                                        |
| Run milestone on autopilot (safe mode) | `/autopilot-chief safe`                                   |
| Run a retrospective                    | `/retro-chief`                                            |
| Quick commit all changes               | `/dump-commit`                                            |
| Quick commit with message              | `/dump-commit fix auth flow`                              |
| Stress-test a plan or design           | `/grill-me`                                               |
| Start building a task manually         | `builder-agent: implement task-1 from milestone-1`        |
| Validate a plan for contradictions     | `review-plan-agent: review milestone-1 plan`              |
| Run integration tests (user-triggered) | `tester-agent: validate milestone-1`                      |
| Set up project config                  | `chief-agent: use grill-me to help me fill in project.md` |

## More Examples

**TypeScript SDK for a payment API**

```
/plan-milestone
```

The skill grills you on decisions (e.g. "fetch or axios?", "class-based or functional?"), writes goals and contracts, then breaks the work into tasks. When ready:

```
/autopilot-chief
```

Chief-agent runs through all tasks autonomously. When done:

```
/retro-chief
```

Review what was delivered vs planned, and update rules for next time.

**Quick prototyping session**

```
/autopilot-chief
```

Skip detailed planning — let chief create TODO and delegate to builder on the fly. When you're done for the day:

```
/dump-commit wip: payment SDK progress
```

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

The same pattern works for other skills like `upgrade-chief`

## Contributing

1. Fork the repo and branch from `canary`
2. Make your changes
3. Test locally using the [Development](#development) workflow above
4. Push and open a PR targeting `canary`
5. Follow existing commit style: `type: description` (e.g. `fix: resolve merge issue`, `feat: add kiro agent support`)

## Acknowledgement

- Grill me Skill from [mattpocock](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md)
- Multi-agent architecture inspired by [vercel-labs/skills](https://github.com/vercel-labs/skills)
