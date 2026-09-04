# Chief ⚔️

![](https://img.shields.io/badge/chief_version-v5.0.0-blue)

**English** | **[ไทย](README.th.md)**

A structured workflow for AI coding agents. Drop it into any project, set your rules once, and stop re-explaining your codebase every chat.

> Chief is part of the [chief-tribe](https://github.com/thaitype/chief-tribe) ecosystem. It uses [sage](https://github.com/thaitype/sage) as its behavioral baseline.

## Why Chief exists

Every project has context — the decisions from six months ago, the weird workaround, all the "why we do it this way" stuff. It lives in your head. Every new AI chat starts blank, so you re-explain. Then again next chat.

Chief stops that. Give every project the same shape — `AGENTS.md` for rules, `.chief/_rules/` for standards, `.chief/story-N/` for current work. Agents know where to read and write. Your prompts shrink to one sentence.

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

It asks which coding agent you use and, for Claude Code, whether to symlink or copy. That's it
— v5 has no subagent roster to wire up.

**Step 3 — Bootstrap project context (optional):**

```
/chief-init
```

Interviews you about your stack and dev commands, writes `.chief/project.md`. Also confirms
where planning artifacts should live — keep the default (`.chief/`) unless you have a reason
not to. Skip this step and write the file by hand later if you prefer.

→ [Full tutorial: your first story](docs/manual/tutorials/your-first-story.md)
→ [Manual install options](docs/manual/how-to/install.md)

> **Windows users:** Symlink mode requires Developer Mode and `git config --global core.symlinks true`. The install skill auto-detects and falls back to copy mode.

## How Chief works

Chief is markdown files in three places:

```
project/
├── AGENTS.md          ← framework + project rules (highest authority)
└── .chief/
    ├── project.md     ← tech stack, dev commands (written by /chief-init)
    ├── _rules/        ← standards that apply across all stories
    └── story-1/       ← current work: goal, contract, tickets
```

`.chief/` is created lazily — nothing appears until you need it. A **story** is Chief's unit of
work, sized like a single issue/ticket in any tracker (GitHub, Jira, ClickUp) — not like a
multi-week "Milestone" (v4's name for it).

**Rules hierarchy:** `AGENTS.md` > `.chief/_rules/` > `.chief/story-N/_goal/`. Higher always wins.

→ [Rules hierarchy](docs/manual/reference/rules-hierarchy.md)
→ [Directory structure](docs/manual/reference/directory-structure.md)

## Working styles

### Controlled — review every step

Best for complex projects, unfamiliar domains, team work.

```
/chief-plan        # grill (or /chief-wayfinder) → goal → contract → tickets (approval at each step)
/chief-build 1   # build one ticket at a time
/chief-retro       # review and capture lessons as rules
```

### Autonomous — let AI drive

Best for prototyping, well-defined goals, solo work.

```
/chief-autopilot   # reads goal + contract, works the ticket frontier via /chief-build
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
| `/chief-init`        | Bootstrap `.chief/project.md` via interview, confirm storage location  |
| `/chief-wayfinder`   | Optional: chart a story's open decisions as a map, resolve one at a time |
| `/chief-plan`        | Plan a story: grill or wayfinder → goal → contract → tickets           |
| `/chief-build`       | Build one ticket: TDD, typecheck, test, review, commit                  |
| `/chief-test`        | Long-running/integration/UI/API verification, only when requested       |
| `/chief-review-code` | Two-axis (Standards + Spec) review of a diff                            |
| `/chief-autopilot`   | Run a story's ticket frontier autonomously                              |
| `/chief-loop`        | Work a full story across as many ticket rounds as it takes, one report per ticket |
| `/chief-grill`       | Deep stateful stress-test; verifies each answer against the codebase   |
| `/chief-rule`        | Capture a decision as a permanent rule in `_rules/`                    |
| `/chief-retro`       | Retrospective + lesson learned + `_rules/` update                       |
| `/chief-explain`     | Agent-facing structural reference — directory layout, skill roles       |
| `/ask-chief`         | Human-facing router — which skill fits your situation, and when         |
| `/chief-migrate-to-v5` | Convert an in-progress v4 milestone into a v5 story                   |
| `/setup-agent-behavior` | Opt-in: install general agent-conduct rules into `AGENTS.md`         |
| `/grill-design`      | Stateless design stress-test with self-critique                          |
| `/shape-up`          | Turn a fuzzy idea into a scoped spec (top-down)                          |
| `/slim-down`         | Cut a scope that's too large into a phase-sized piece                    |
| `/loop-readiness`    | Review whether a plan is ready to run as an unattended loop              |
| `/loop-preflight`    | Actually run a plan's pre-existing gates/tests to confirm they still work |
| `/dump-commit`       | Quick clean commit with auto-generated message                           |

→ [Full skills reference](docs/manual/reference/skills.md)
→ [How to pick the right skill](docs/manual/how-to/pick-the-right-skill.md)

## No more subagent roster, and a nearly-empty AGENTS.md

v4 shipped four persistent subagents (`chief-agent`, `builder-agent`, `tester-agent`,
`answer-verifier-agent`) that `/chief-install` wired into `.agents/agents/`. v5 has none of
that — `/chief-build` and `/chief-test` are skills that spawn their own throwaway subagents for
isolated context when they need it, and `chief-agent`/`answer-verifier-agent` were folded
into the skills that used them. Nothing to install separately, nothing to keep in sync. There's
no `scripts/setup.sh` either — `/chief-install` writes `AGENTS.md` directly.

The same logic applies to `AGENTS.md` itself: it used to carry a directory-structure diagram,
a skill-family table, and a responsibility-boundary writeup that loaded into every single
session whether or not that session needed it. All of that either lives inside the individual
skills that actually enforce it already, or moved to `/chief-explain` (agent-facing, on
demand) and `/ask-chief` (human-facing, "which skill do I use?"). `AGENTS.md` now holds just
your own Project Rules and a two-line pointer to those two skills.

→ [chief-* execution skills reference](docs/manual/reference/agents.md)

## Upgrading

```bash
# 1. Refresh skills
npx skills@latest add thaitype/chief

# 2. Upgrade AGENTS.md
/chief-upgrade
```

To pin a version: `npx skills@latest add thaitype/chief#v5.0.0` / `/chief-upgrade v5.0.0`

Coming from v4? `/chief-upgrade` detects it and explains the breaking change before touching
anything — see [How to upgrade](docs/manual/how-to/upgrade.md#upgrading-from-v4). It only
handles `AGENTS.md`; if you also want an in-progress v4 milestone converted into a v5 story
(rather than finished on a pinned v4 checkout), run `/chief-migrate-to-v5` afterward.

## Documentation

Full documentation lives in [`docs/manual/`](docs/manual/):

| Section                                                | Content                                               |
| ------------------------------------------------------ | ----------------------------------------------------- |
| [Tutorial](docs/manual/tutorials/your-first-story.md) | Your first story, end to end                          |
| [How-to guides](docs/manual/how-to/)                      | Install, upgrade, pick a skill, write rules           |
| [Reference](docs/manual/reference/)                       | Skills, execution skills, directory structure, rules hierarchy |
| [Explanation](docs/manual/explanation/)                   | Why Chief exists, pre-coding first, separation of concerns |

## Compatibility

| Coding agent                                          | Integration                                                |
| ----------------------------------------------------- | ---------------------------------------------------------- |
| Claude Code                                           | `CLAUDE.md → AGENTS.md` symlink                            |
| GitHub Copilot                                        | Reads `AGENTS.md` directly                                 |
| Cursor, Windsurf, Kiro, Codex, Aider, Amp, Gemini CLI | Reads `AGENTS.md` natively (untested ⚠️)               |

## Releases

- **v1** — Initial release, Claude Code support. [docs](https://github.com/thaitype/chief-agent-framework/tree/release/v1)
- **v2** — Multi-agent support, skills system. [docs](https://github.com/thaitype/chief-agent-framework/tree/release/v2)
- **v3** — Rebranded to Chief. `chief-` skill prefix. Repo moved to [`thaitype/chief`](https://github.com/thaitype/chief).
- **v4** — Skills via `npx skills` (decoupled from install). Lazy `.chief/`. New skills: `/chief-init`, `/chief-rule`, `/chief-grill`, `/grill-design`, `/shape-up`, `/slim-down`, `/chief-loop`, `/loop-readiness`. `answer-verifier-agent` replaces deprecated `review-plan-agent`. [docs](https://github.com/thaitype/chief/tree/release/v4)
- **v5** — "Milestone" renamed "story" (sized like one tracker issue, not a multi-week Milestone). `_plan/_todo.md` + task specs replaced by a `_tickets/` frontier (vertical-slice tickets with blocking edges). New: `/chief-wayfinder` (map open decisions before planning), `/chief-build` and `/chief-test` (replace `builder-agent`/`tester-agent` as skills), `/chief-review-code` (two-axis diff review), `/chief-explain` and `/ask-chief` (agent- and human-facing replacements for what used to be baked into `AGENTS.md`), `/chief-migrate-to-v5` (converts an in-progress v4 milestone into a v5 story), `/setup-agent-behavior` (opt-in general agent-conduct rules, not Chief-specific). The `.agents/agents/` subagent roster is gone entirely, `scripts/setup.sh` is gone (`/chief-install` writes `AGENTS.md` directly), and `AGENTS.md` itself shrinks to just your Project Rules. Storage location is no longer hardcoded to `.chief/` (see `.chief.config.md` in the directory structure reference). See [the design doc](docs/design/v5-ai-workflow.md) for the full rationale.

## Branches

- `release/v1`, `release/v2`, `release/v4` — Stable legacy releases
- `main` — Latest stable (v5)
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

- `/grill-design` and `/chief-grill` originated from [mattpocock's grill-me skill](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md)
- v5's `/chief-wayfinder`, `/chief-build`, and `/chief-review-code` adopt ideas from
  [mattpocock/skills](https://github.com/mattpocock/skills)' `wayfinder`, `implement`, and
  `code-review` — adapted to Chief's story/goal/contract/ticket model rather than used
  directly; see [the design doc](docs/design/v5-ai-workflow.md) for what changed and why.
- Multi-agent architecture inspired by [vercel-labs/skills](https://github.com/vercel-labs/skills)
