# Chief ⚔️

**English** | **[ไทย](README.th.md)**

A portable framework that reduces the cognitive load of working with AI coding agents — without sacrificing quality or speed.

> Chief is part of the [chief-tribe](https://github.com/thaitype/chief-tribe) ecosystem. It uses [sage](https://github.com/thaitype/sage) as its behavioral baseline.

> You're currently on v4 docs. If you have older version installed, follow the [upgrade instructions](#upgrading) below or see the [v1 docs](https://github.com/thaitype/chief-agent-framework/tree/release/v1). Chief was previously known as `chief-agent-framework`.

Chief is a structured workflow for AI coding agents. It's the backbone you can drop into any project — domain doesn't matter.

Your job:

* Set the rules and goals once. Agents handle the rest — planning, building, verifying — one milestone at a time.
* Pull in specialized subagents or skills when something needs domain expertise.

On a real project, writing code isn't the hard part. The hard part is deciding. Which architecture. Which pattern. What to do next. Every prompt you send is a decision, and when you rush them, you get tech debt.

Chief takes those decisions out of your head and puts them in a system:

* A planning agent breaks work into milestones and tasks
* A builder agent implements them
* A tester agent verifies the results

Built for developers already using AI coding agents who want a structured workflow instead of ad-hoc prompting. Learn more about the [design philosophy](docs/philosophy.md).

#### Quickstart (30-second setup)

Install Chief skills:

```bash
npx skills@latest add thaitype/chief
```

Pick the skills you want, and which coding agents you want to install them on. Make sure you select `chief-install`.

Run `/chief-install` in your agent. It will:

* Ask which coding agent you use (Claude Code, Copilot, Cursor, etc.)
* Pick the install mode (symlink or copy)
* Ask whether you want to install the subagents
* Install `AGENTS.md` (and the subagents, if you opted in) into your project

That's it — you're ready to go.

**Optional:** Run `/chief-init` to bootstrap project context. It interviews you about your tech stack, architecture, and dev commands. You can also write it by hand later, or skip it entirely if you don't need project-level rules yet.

For manual installation options (shell script, git clone), see [docs/manual-install.md](docs/manual-install.md).

> **Windows users:** Link mode requires Developer Mode enabled and `git config --global core.symlinks true`. The setup script auto-detects this — if symlinks aren't available, it falls back to copy mode.

> Current version is v4, If you come from the older version follow the [upgrade instructions](#upgrading).

### Compatibility

Chief has three main parts: `AGENTS.md`, subagents (or custom agents), and skills.

* **`AGENTS.md`** — Most AI coding agents read `AGENTS.md` out of the box as user-defined rules. For Claude Code and GitHub Copilot, which use their own filenames, `/chief-install` sets up the symlinks automatically.
* **Skills** — Compatible with most major agents through the [vercel skills](https://github.com/vercel-labs/skills) ecosystem, the de facto open standard for installing skills.
* **Subagents** — Skills alone are enough for most cases. Pair them with `AGENTS.md` and subagents (or custom agents), and Chief becomes much more effective.

Learn more in the [compatibility guide](docs/compatibility.md).

## Getting Started

### How Chief is structured

Chief lives in three places:

- **`AGENTS.md`** — framework + project rules. The highest authority.
- **`.chief/_rules/`** — governance shared across milestones (standards, contracts, goals, verification).
- **`.chief/milestone-N/`** — the active unit of work (goals, contracts, plan, reports).

```
project/
├── AGENTS.md
└── .chief/
    ├── project.md
    ├── _rules/
    └── milestone-1/
```

### Rules hierarchy

When rules conflict, the higher level wins:

1. `AGENTS.md` (highest)
2. `.chief/_rules/`
3. `.chief/milestone-N/_goal/` (lowest)

### Per-milestone lifecycle

For each milestone you typically:

1. **Clarify** — for high-stakes or ambiguous goals, run `/chief-grill` first to interview yourself with codebase verification.
2. **Plan** — `/chief-plan` walks goals → contracts → TODO → tasks with review gates.
3. **Build** — chief-agent delegates to `builder-agent` (controlled), or `/chief-autopilot` runs everything.
4. **Verify** — `tester-agent` is invoked on demand for integration/E2E checks.
5. **Reflect** — `/chief-retro` reviews coverage and proposes rule updates.

### First run

After installing, bootstrap project context:

```
/chief-init
```

It interviews you about your tech stack, architecture, and dev commands, then writes `.chief/project.md`. Edit by hand later if needed.

Milestones can be simple (`milestone-1`, `milestone-2`) or reference your project tracker (`milestone-JIRA-123`, `milestone-CU-456`).

## Agents at a Glance

| Agent                 | When it works                                                             | When to call manually                                       |
| --------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------------- |
| chief-agent           | You start here. Give it a goal.                                           | Plan work, review progress, or change direction             |
| builder-agent         | Chief delegates tasks to it after plan is reviewed                        | When a task is ready and you want to start building         |
| tester-agent          | Only when you request it — not part of the automatic flow                | When you need integration/E2E testing beyond unit tests     |
| answer-verifier-agent | Spawned by `/chief-grill` per question (background) and at end-of-grill | When you want a codebase-grounded second opinion on a claim |

## Quick Start — Pick Your Style

There are two ways to work. Pick the one that fits your situation.

> **High-stakes or ambiguous goal?** Run `/chief-grill` first to clarify before planning. The grill outcome feeds straight into `/chief-plan` (or skip into `/chief-autopilot` if the answer is clear). Skip the grill when the goal is already concrete.

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

| What you want                          | What to type                                         |
| -------------------------------------- | ---------------------------------------------------- |
| Plan a milestone step-by-step          | `/chief-plan`                                      |
| Run milestone on autopilot             | `/chief-autopilot`                                 |
| Run milestone on autopilot (safe mode) | `/chief-autopilot safe`                            |
| Run a retrospective                    | `/chief-retro`                                     |
| Quick commit all changes               | `/dump-commit`                                     |
| Quick commit with message              | `/dump-commit fix auth flow`                       |
| Shape a top-down design spec           | `/shape-up`                                        |
| Stress-test a design or decision tree  | `/grill-design`                                    |
| Deep grill with codebase verification  | `/chief-grill`                                     |
| Start building a task manually         | `builder-agent: implement task-1 from milestone-1` |
| Validate a plan for contradictions     | `/chief-grill`                                     |
| Run integration tests (user-triggered) | `tester-agent: validate milestone-1`               |
| Set up project config                  | `/chief-init`                                      |
| Add a rule to .chief/_rules/           | `/chief-rule`                                      |

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

**High-stakes decision (e.g. picking a database, redesigning auth)**

```
/chief-grill
```

Walks the decision tree one question at a time, recommends an answer with self-critique, and verifies each answer against your actual repo via the `answer-verifier-agent` in the background. The session is logged to `.chief/_grill/opened/NNNN-topic.md` so it survives context resets. Capture any rules that come out of the discussion with `/chief-rule`.

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
- v4.x — Lazy `.chief/` install. `/chief-install` ships only subagents and `AGENTS.md`; `.chief/` (project.md, milestones, rules) is created on demand by chief-agent or `/chief-init`. New skills: `/chief-init`, `/chief-rule`, `/chief-grill`, `/grill-design`. `review-plan-agent` deprecated in favor of `answer-verifier-agent`.

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

- The grill-me concept (now `/grill-design` and `/chief-grill`) originated from [mattpocock&#39;s grill-me skill](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md)
- Multi-agent architecture inspired by [vercel-labs/skills](https://github.com/vercel-labs/skills)
