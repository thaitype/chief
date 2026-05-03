# Chief ⚔️

**English** | **[ไทย](README.th.md)**

A portable framework that reduces the cognitive load of working with AI coding agents — without sacrificing quality or speed.

> Chief is part of the [chief-tribe](https://github.com/thaitype/chief-tribe) ecosystem. It uses [sage](https://github.com/thaitype/sage) as its behavioral baseline.

> Under the hood, Chief is just markdown files. It defines structure for your AI agents to follow.

> You're currently on v4 docs. If you have v1 or v2 installed, follow the [upgrade instructions](#upgrading) below or see the [v1 docs](https://github.com/thaitype/chief-agent-framework/tree/release/v1). Chief was previously known as `chief-agent-framework`.

Chief is a structured workflow for AI coding agents. You define rules and goals once, and agents handle planning, building, and verification across sessions — milestone by milestone.

When you use AI on a real project, the challenge isn't writing code — it's the constant decision-making. Which architecture, which pattern, which direction next. Every AI interaction is a decision. The more you rush, the more you skip, and the more tech debt follows.

Chief externalizes those decisions into a system:

- A planning agent breaks work into milestones and tasks
- A builder agent implements them
- A tester agent verifies the results
- A review agent can check plans for contradictions when you want a second opinion

Built for developers already using AI coding agents who want a structured workflow instead of ad-hoc prompting. Learn more about the [design philosophy](docs/philosophy.md).

## Supported Coding Agents

| Coding Agent                                                    | Integration                                           | Notes                                  |
| --------------------------------------------------------------- | ----------------------------------------------------- | -------------------------------------- |
| Claude Code                                                     | `CLAUDE.md → AGENTS.md` symlink + `.claude/` symlinks | Full support                            |
| GitHub Copilot                                                  | `.github/agents/` symlinks or copies                  | Full support                            |
| OpenCode, Codex, Cursor, Gemini CLI, Amp, Windsurf, Kiro, Aider | Reads `AGENTS.md` natively                            | Should work out of the box (untested ⚠️ — [open an issue](https://github.com/thaitype/chief/issues) if you hit problems) |

## Setup

Current version is v4. If you have v1 or v2 installed, follow the [upgrade instructions](#upgrading) below.

```bash
# 1. Install Chief skills (chief-install, chief-init, chief-upgrade, chief-plan, chief-autopilot, chief-retro, chief-rule, chief-grill, dump-commit, grill-me)
npx skills@latest add thaitype/chief
```

```
# 2. Install framework files (subagents + AGENTS.md)
/chief-install
```

```
# 3. Bootstrap your project context (creates .chief/project.md)
/chief-init
```

Step 1 fetches the slash-command skills via the [vercel skills](https://github.com/vercel-labs/skills) ecosystem. Step 2 runs the `chief-install` skill, which asks which coding agent you use, picks the install mode, and installs subagents + `AGENTS.md`. Step 3 runs `chief-init` to interview you about your project and write `.chief/project.md`.

`.chief/` is created **lazily**: `chief-init` writes `project.md`, and chief-agent creates milestone folders, rule subfolders, and reports on demand as you work. There is no upfront `.chief/` scaffold to clean up.

For manual installation options (shell script, git clone), see [docs/manual-install.md](docs/manual-install.md).

> **Windows users:** Link mode requires Developer Mode enabled and `git config --global core.symlinks true`. The setup script auto-detects this — if symlinks aren't available, it falls back to copy mode.

## Directory Structure

After `/chief-install` your project will have:

```
project/
├── AGENTS.md               # Framework rules (fresh write, or appended to existing)
├── CLAUDE.md → AGENTS.md   # Symlink (Claude Code only)
├── .github/agents/        # Copilot agent definitions (symlinks or copies)
├── .agents/               # Canonical agent definitions (coding-agent-agnostic)
│   ├── agents/            # Agent role definitions
│   └── skills/            # Installed via npx skills (separate from /chief-install)
├── .claude/               # Claude Code integration (symlinks)
│   ├── agents/ → .agents/agents/*
│   └── skills/ → .agents/skills/*   # Installed via npx skills
```

`.chief/` is **not** created at install time. It grows on demand:

```
.chief/                    # Created lazily as you use the framework
├── project.md             # Created by /chief-init
├── _rules/                # Subfolders (_standard/_contract/_goal/_verification) created on first rule
└── milestone-N/           # Created by /chief-plan or chief-agent on first milestone
```

A canonical example layout lives at [`docs/example-chief/`](docs/example-chief/) for reference.

## How It Works

- `.agents/` is the **canonical, coding-agent-agnostic** location for agent definitions; skills are managed separately by `npx skills` and land under `.agents/skills/`
- `.chief/` contains planning, rules, milestones, and project configuration
- `AGENTS.md` defines the highest-authority framework rules
- `CLAUDE.md` is a symlink to `AGENTS.md` (Claude Code only)
- `.github/agents/` contains symlinks or copies for GitHub Copilot
- Agent-specific directories (`.claude/`, `.github/agents/`, etc.) are populated via symlinks or copies pointing back to `.agents/`

## Getting Started

After installing, set up your project context in `.chief/project.md`:

```
/chief-init
```

The `chief-init` skill interviews you about your tech stack, architecture, and dev commands, then writes `.chief/project.md`. You can also edit it manually after creation.

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
/chief-plan              # grill → goals → contracts → TODO → specs (approval at each step)
builder-agent: implement task-1 from milestone-1   # delegate tasks one by one
/chief-retro                 # review coverage and propose rule updates
```

You stay in control. Every goal, contract, and task is reviewed before execution.

### Option B: Autonomous (let AI drive)

Best for: prototyping, well-defined goals, solo work.

```
/chief-autopilot             # reads goals + contracts, creates TODO, runs all tasks
/chief-retro                 # review what happened
```

Requires goals and contracts to exist. Use `/chief-plan` first if they don't, or write them yourself.

### Mix and match

You can combine both. Plan with review gates, then switch to autopilot for execution:

```
/chief-plan              # plan carefully with approval gates
/chief-autopilot             # execute the approved plan autonomously
/chief-retro                 # review and learn
```

## Common Prompts

| What you want                          | What to type                                              |
| -------------------------------------- | --------------------------------------------------------- |
| Plan a milestone step-by-step          | `/chief-plan`                                         |
| Run milestone on autopilot             | `/chief-autopilot`                                        |
| Run milestone on autopilot (safe mode) | `/chief-autopilot safe`                                   |
| Run a retrospective                    | `/chief-retro`                                            |
| Quick commit all changes               | `/dump-commit`                                            |
| Quick commit with message              | `/dump-commit fix auth flow`                              |
| Stress-test a plan or design           | `/grill-me`                                               |
| Deep grill with codebase verification  | `/chief-grill`                                            |
| Start building a task manually         | `builder-agent: implement task-1 from milestone-1`        |
| Validate a plan for contradictions     | `review-plan-agent: review milestone-1 plan`              |
| Run integration tests (user-triggered) | `tester-agent: validate milestone-1`                      |
| Set up project config                  | `/chief-init`                                             |
| Add a rule to .chief/_rules/           | `/chief-rule`                                             |

## More Examples

**TypeScript SDK for a payment API**

```
/chief-plan
```

The skill grills you on decisions (e.g. "fetch or axios?", "class-based or functional?"), writes goals and contracts, then breaks the work into tasks. When ready:

```
/chief-autopilot
```

Chief-agent runs through all tasks autonomously. When done:

```
/chief-retro
```

Review what was delivered vs planned, and update rules for next time.

**Quick prototyping session**

```
/chief-autopilot
```

Skip detailed planning — let chief create TODO and delegate to builder on the fly. When you're done for the day:

```
/dump-commit wip: payment SDK progress
```

## Upgrading

```bash
# 1. Refresh Chief skills
npx skills@latest add thaitype/chief
```

```
# 2. Upgrade framework files
/chief-upgrade
```

Step 1 re-installs every Chief skill at the latest version (the picker shows you what's new — `npx skills add` is idempotent, so re-running it is the supported refresh path). Step 2 runs the `chief-upgrade` skill, which compares your current framework files against the target version, creates an upgrade plan, and waits for your approval before applying any changes.

With no arguments, `/chief-upgrade` targets the latest stable release. Or specify a version:

```
/chief-upgrade canary
/chief-upgrade v4.0.0
```

### Coming from v2

Skills were renamed in v3:
- `/install-chief` → `/chief-install`
- `/upgrade-chief` → `/chief-upgrade`

If you have old skills installed, remove them and install the new ones:
```bash
npx skills@latest add thaitype/chief --skill chief-upgrade
```

### Coming from v1

See the [v1 docs](https://github.com/thaitype/chief-agent-framework/tree/release/v1) for migration details.

## Release

- v1 — Initial release, focused on Claude Code support. See [docs](https://github.com/thaitype/chief-agent-framework/tree/release/v1).
- v2 — Multi-agent support, added skills system. See [docs](https://github.com/thaitype/chief-agent-framework/tree/release/v2).
- v3 — Renamed to Chief as part of the [chief-tribe](https://github.com/thaitype/chief-tribe) ecosystem. Skills renamed to `chief-` prefix (`chief-install`, `chief-upgrade`). Repo moved to [`thaitype/chief`](https://github.com/thaitype/chief).
- v4 — Skills decoupled from framework install. `/chief-install` and `/chief-upgrade` no longer manage skills; install and refresh skills via `npx skills@latest add thaitype/chief`.

## Branches
- `release/v1` — Stable v1 release
- `release/v2` — Stable v2 release
- `main` - latest stable release (currently v4)
- `canary` - active development branch, may be unstable

## Development

To test changes locally before submitting a PR:

1. Push your feature branch to GitHub
2. In a **separate test project** (not inside this repo), install the skill from your branch:

```bash
npx skills@latest add thaitype/chief#<your-branch> --skill chief-install
```

3. Test it:

```
/chief-install <your-branch>
```

The same pattern works for other skills like `chief-upgrade`. To pull the entire bundle from a branch instead of a single skill, drop the `--skill` flag: `npx skills@latest add thaitype/chief#<your-branch>`.

## Contributing

1. Fork the repo and branch from `canary`
2. Make your changes
3. Test locally using the [Development](#development) workflow above
4. Push and open a PR targeting `canary`
5. Follow existing commit style: `type: description` (e.g. `fix: resolve merge issue`, `feat: add kiro agent support`)

## Acknowledgement

- Grill me Skill from [mattpocock](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md)
- Multi-agent architecture inspired by [vercel-labs/skills](https://github.com/vercel-labs/skills)
