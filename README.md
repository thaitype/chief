# Chief ⚔️

![](https://img.shields.io/badge/chief_version-v5.0.0.alpha--0-blue)

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

Select the skills you want. That's it — there's no separate install step. Nothing needs to be
written to `AGENTS.md` for Chief to work; every `chief-*` slash command is available the
moment its skill file is present.

**Step 2 — Bootstrap project context (optional):**

```
/chief-init
```

Interviews you about your stack and dev commands, writes `.chief/project.md`. Also confirms
where planning artifacts should live — keep the default (`.chief/`) unless you have a reason
not to. Skip this step and write the file by hand later if you prefer.

→ [Full tutorial: your first story](docs/manual/tutorials/your-first-story.md)

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
| `/chief-migrate` | Convert an in-progress v4 milestone into a v5 story                   |
| `/setup-agent-behavior` | Opt-in: install general agent-conduct rules into `AGENTS.md`         |
| `/grill-design`      | Stateless design stress-test with self-critique                          |
| `/shape-up`          | Turn a fuzzy idea into a scoped spec (top-down)                          |
| `/slim-down`         | Cut a scope that's too large into a phase-sized piece                    |
| `/loop-readiness`    | Review whether a plan is ready to run as an unattended loop              |
| `/loop-preflight`    | Actually run a plan's pre-existing gates/tests to confirm they still work |
| `/dump-commit`       | Quick clean commit with auto-generated message                           |

→ [Full skills reference](docs/manual/reference/skills.md)
→ [How to pick the right skill](docs/manual/how-to/pick-the-right-skill.md)

## No more subagent roster, no more install/upgrade skills

v4 shipped four persistent subagents (`chief-agent`, `builder-agent`, `tester-agent`,
`answer-verifier-agent`) that a `chief-install` skill wired into `.agents/agents/`. v5 has none
of that — `/chief-build` and `/chief-test` are skills that spawn their own throwaway subagents
for isolated context when they need it, and `chief-agent`/`answer-verifier-agent` were folded
into the skills that used them. Nothing to install separately, nothing to keep in sync. There's
no `scripts/setup.sh` either, and — once that roster was gone — nothing left for a dedicated
install/upgrade skill to actually do: Chief doesn't write anything to `AGENTS.md` at all.
`AGENTS.md` is entirely optional and entirely yours; if you want your own Project Rules
followed, write them there yourself, in whatever shape your coding agent expects (`CLAUDE.md`
for Claude Code, `AGENTS.md` for most others — symlink one to the other yourself if you use
both).

The same logic emptied `AGENTS.md` of everything Chief used to put there: a directory-structure
diagram, a skill-family table, a responsibility-boundary writeup that used to load into every
session whether or not that session needed it. All of that either lives inside the individual
skills that actually enforce it already, or moved to `/chief-explain` (agent-facing, on
demand) and `/ask-chief` (human-facing, "which skill do I use?").

→ [chief-* execution skills reference](docs/manual/reference/agents.md)

## Upgrading

```bash
npx skills@latest add thaitype/chief
```

That's the whole upgrade — refreshing skill files is idempotent, safe to re-run anytime. To pin
a version: `npx skills@latest add thaitype/chief#v5.0.0`.

Coming from v4? See [How to upgrade](docs/manual/how-to/upgrade.md#upgrading-from-v4) for what
changed. If you also want an in-progress v4 milestone converted into a v5 story (rather than
finished on a pinned v4 checkout), run `/chief-migrate`.

## Documentation

Full documentation lives in [`docs/manual/`](docs/manual/):

| Section                                                | Content                                               |
| ------------------------------------------------------ | ----------------------------------------------------- |
| [Tutorial](docs/manual/tutorials/your-first-story.md) | Your first story, end to end                          |
| [How-to guides](docs/manual/how-to/)                      | Get the skills, pick a skill, write rules             |
| [Reference](docs/manual/reference/)                       | Skills, execution skills, directory structure, rules hierarchy |
| [Explanation](docs/manual/explanation/)                   | Why Chief exists, pre-coding first, separation of concerns |

## Compatibility

Skills work the same everywhere once installed — no per-agent setup. `AGENTS.md`/`CLAUDE.md`
only matters if you want your own Project Rules recognized, and that's entirely optional and
entirely yours to create:

| Coding agent                                          | Rules file it reads                                        |
| ----------------------------------------------------- | ---------------------------------------------------------- |
| Claude Code                                           | `CLAUDE.md` — symlink or copy it from `AGENTS.md` yourself if you keep both |
| GitHub Copilot, Cursor, Windsurf, Kiro, Codex, Aider, Amp, Gemini CLI | `AGENTS.md` (untested on most of these ⚠️) |

## Releases

- **v1** — Initial release, Claude Code support. [docs](https://github.com/thaitype/chief-agent-framework/tree/release/v1)
- **v2** — Multi-agent support, skills system. [docs](https://github.com/thaitype/chief-agent-framework/tree/release/v2)
- **v3** — Rebranded to Chief. `chief-` skill prefix. Repo moved to [`thaitype/chief`](https://github.com/thaitype/chief).
- **v4** — Skills via `npx skills` (decoupled from install). Lazy `.chief/`. New skills: `/chief-init`, `/chief-rule`, `/chief-grill`, `/grill-design`, `/shape-up`, `/slim-down`, `/chief-loop`, `/loop-readiness`. `answer-verifier-agent` replaces deprecated `review-plan-agent`. [docs](https://github.com/thaitype/chief/tree/release/v4)
- **v5** — "Milestone" renamed "story" (sized like one tracker issue, not a multi-week Milestone). `_plan/_todo.md` + task specs replaced by a `_tickets/` frontier (vertical-slice tickets with blocking edges). New: `/chief-wayfinder` (map open decisions before planning), `/chief-build` and `/chief-test` (replace `builder-agent`/`tester-agent` as skills), `/chief-review-code` (two-axis diff review), `/chief-explain` and `/ask-chief` (agent- and human-facing replacements for what used to be baked into `AGENTS.md`), `/chief-migrate` (converts an in-progress v4 milestone into a v5 story), `/setup-agent-behavior` (opt-in general agent-conduct rules, not Chief-specific). The `.agents/agents/` subagent roster is gone entirely, `scripts/setup.sh` is gone, and — once that roster was gone — so were the install/upgrade skills themselves: Chief writes nothing to `AGENTS.md` at all anymore, so `AGENTS.md` is entirely optional and entirely yours. Storage location is no longer hardcoded to `.chief/` (see `.chief.config.md` in the directory structure reference). See [the design doc](docs/design/v5-ai-workflow.md) for the full rationale.

## Branches

- `release/v1`, `release/v2`, `release/v4` — Stable legacy releases
- `main` — Latest stable (v5)
- `canary` — Active development, may be unstable

## Development

To test changes locally:

```bash
# Install the skills you're changing from your branch, into a separate test project
npx skills@latest add thaitype/chief#<your-branch>

# Then invoke whichever skill you changed directly, e.g.:
/chief-plan
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
