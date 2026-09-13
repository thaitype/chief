# Chief ⚔️

![](https://img.shields.io/badge/chief_version-v4.1.0-blue)

**English** | **[ไทย](README.th.md)**

A structured workflow for AI coding agents. Drop it into any project, set your rules once, and stop re-explaining your codebase every chat.

> Chief is part of the [chief-tribe](https://github.com/thaitype/chief-tribe) ecosystem. It uses [sage](https://github.com/thaitype/sage) as its behavioral baseline.

## Why Chief exists

Every project has context — the decisions from six months ago, the weird workaround, all the "why we do it this way" stuff. It lives in your head. Every new AI chat starts blank, so you re-explain. Then again next chat.

Chief stops that. Give every project the same shape — `AGENTS.md` for rules, `.chief/_rules/` for standards, `.chief/milestone-N/` for current work. Agents know where to read and write. Your prompts shrink to one sentence.

→ [Why Chief exists](docs/manual/explanation/why-chief.md)

## Quickstart

**Step 1 — Install skills:**

```bash
npx skills@latest add thaitype/chief
```

Select the skills you want. Make sure `chief-install` is included.

**Step 2 — Run `/chief-install` in your agent:**

```
/chief-install
```

It asks which coding agent you use, whether to symlink or copy, and whether to include subagents. That's it.

**Step 3 — Bootstrap project context (optional):**

```
/chief-init
```

Interviews you about your stack and dev commands, writes `.chief/project.md`. Skip it and write the file by hand later if you prefer.

→ [Full tutorial: your first milestone](docs/manual/tutorials/your-first-milestone.md)→ [Manual install options](docs/manual/how-to/install.md)

> **Windows users:** Symlink mode requires Developer Mode and `git config --global core.symlinks true`. The install skill auto-detects and falls back to copy mode.

## How Chief works

Chief is markdown files in three places:

```
project/
├── AGENTS.md          ← framework + project rules (highest authority)
└── .chief/
    ├── project.md     ← tech stack, dev commands (written by /chief-init)
    ├── _rules/        ← standards that apply across all milestones
    └── milestone-1/   ← current work: goals, contracts, tasks
```

`.chief/` is created lazily — nothing appears until you need it.

**Rules hierarchy:** `AGENTS.md` > `.chief/_rules/` > `.chief/milestone-N/_goal/`. Higher always wins.

→ [Rules hierarchy](docs/manual/reference/rules-hierarchy.md)
→ [Directory structure](docs/manual/reference/directory-structure.md)

## Working styles

### Controlled — review every step

Best for complex projects, unfamiliar domains, team work.

```
/chief-plan        # grill → goals → contracts → TODO → tasks (approval at each step)
builder-agent: implement task-1 from milestone-1
/chief-retro       # review and capture lessons as rules
```

### Autonomous — let AI drive

Best for prototyping, well-defined goals, solo work.

```
/chief-autopilot   # reads goals + contracts, runs all tasks
/chief-retro
```

### Mix and match

```
/chief-plan        # plan with approval gates
/chief-autopilot   # execute the approved plan
/chief-retro
```

## Skills

| Skill                | What it does                                                             |
| -------------------- | ------------------------------------------------------------------------ |
| `/chief-init`      | Bootstrap `.chief/project.md` via interview                            |
| `/chief-plan`      | Plan a milestone: grill → goals → contracts → tasks                   |
| `/chief-autopilot` | Run a milestone autonomously                                             |
| `/chief-loop`      | Run chief-agent across a full milestone, batch after batch, with a report per task |
| `/chief-grill`     | Deep stateful stress-test; spawns `answer-verifier-agent` per question |
| `/chief-rule`      | Capture a decision as a permanent rule in `_rules/`                    |
| `/chief-retro`     | Retrospective + lesson learned +`_rules/` update                       |
| `/grill-design`    | Stateless design stress-test with self-critique                          |
| `/shape-up`        | Turn a fuzzy idea into a scoped spec (top-down)                          |
| `/slim-down`       | Cut a scope that's too large into a phase-sized piece                    |
| `/loop-readiness`  | Review whether a plan is ready to run as an unattended loop              |
| `/loop-preflight`  | Actually run a plan's pre-existing gates/tests to confirm they still work |
| `/dump-commit`     | Quick clean commit with auto-generated message                           |

→ [Full skills reference](docs/manual/reference/skills.md)
→ [How to pick the right skill](docs/manual/how-to/pick-the-right-skill.md)

## Agents

| Agent                     | Role                                                   |
| ------------------------- | ------------------------------------------------------ |
| `chief-agent`           | Plans, orchestrates, delegates — does not write code  |
| `builder-agent`         | Implements tasks, runs unit tests, commits             |
| `tester-agent`          | Integration/E2E validation — only when you request it |
| `answer-verifier-agent` | Background verifier spawned by `/chief-grill`        |

→ [Subagents reference](docs/manual/reference/agents.md)

## Upgrading

```bash
# 1. Refresh skills
npx skills@latest add thaitype/chief

# 2. Upgrade framework files
/chief-upgrade
```

To pin a version: `npx skills@latest add thaitype/chief#v4.0.0` / `/chief-upgrade v4.0.0`

→ [How to upgrade](docs/manual/how-to/upgrade.md)

## Documentation

Full documentation lives in [`docs/manual/`](docs/manual/):

| Section                                                | Content                                               |
| ------------------------------------------------------ | ----------------------------------------------------- |
| [Tutorial](docs/manual/tutorials/your-first-milestone.md) | Your first milestone, end to end                      |
| [How-to guides](docs/manual/how-to/)                      | Install, upgrade, pick a skill, write rules           |
| [Reference](docs/manual/reference/)                       | Skills, agents, directory structure, rules hierarchy  |
| [Explanation](docs/manual/explanation/)                   | Why Chief exists, pre-coding first, three-agent model |

## Compatibility

| Coding agent                                          | Integration                                                |
| ----------------------------------------------------- | ---------------------------------------------------------- |
| Claude Code                                           | `CLAUDE.md → AGENTS.md` symlink + `.claude/` symlinks |
| GitHub Copilot                                        | `.github/agents/` symlinks or copies                     |
| Cursor, Windsurf, Kiro, Codex, Aider, Amp, Gemini CLI | Reads `AGENTS.md` natively (untested ⚠️)               |

## Releases

- **v1** — Initial release, Claude Code support. [docs](https://github.com/thaitype/chief-agent-framework/tree/release/v1)
- **v2** — Multi-agent support, skills system. [docs](https://github.com/thaitype/chief-agent-framework/tree/release/v2)
- **v3** — Rebranded to Chief. `chief-` skill prefix. Repo moved to [`thaitype/chief`](https://github.com/thaitype/chief).
- **v4** — Skills via `npx skills` (decoupled from install). Lazy `.chief/`. New skills: `/chief-init`, `/chief-rule`, `/chief-grill`, `/grill-design`, `/shape-up`, `/slim-down`, `/chief-loop`, `/loop-readiness`. `answer-verifier-agent` replaces deprecated `review-plan-agent`.

## Branches

- `release/v1`, `release/v2` — Stable legacy releases
- `main` — Latest stable (v4)
- `canary` — Active development, may be unstable

## Development

To test changes locally:

```bash
# Install from your branch in a separate test project
npx skills@latest add thaitype/chief#<your-branch> --skill chief-install

# Then test:
/chief-install <your-branch>
```

## Contributing

1. Fork and branch from `canary`
2. Make changes
3. Test with the development workflow above
4. PR targeting `canary`
5. Commit style: `type: description` (e.g. `feat: add kiro support`)

## Acknowledgements

- `/grill-design` and `/chief-grill` originated from [mattpocock&#39;s grill-me skill](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md)
- Multi-agent architecture inspired by [vercel-labs/skills](https://github.com/vercel-labs/skills)
