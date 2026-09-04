# AGENTS.md

<!-- chief-framework:begin -->
## Chief Framework

This project uses the [Chief](https://github.com/thaitype/chief) framework. Run `/chief-explain`
for how it's structured (directory layout, storage location, what each skill owns), or
`/ask-chief` if you're not sure which skill fits your situation.
<!-- chief-framework:end -->

## Project Rules

- This repo IS the Chief framework. Sources of truth:
  - Framework rules file: `template/AGENTS.md`
  - Skills: `skills/` (chief, engineering, misc, setup)
  - Example `.chief/` layout (reference only, not consumed by install): `docs/example-chief/`
- v5 has no `template/.agents/agents/` subagent roster — `/chief-build`/`/chief-test` are
  skills under `skills/chief/`, not agent files. Don't recreate `.agents/agents/`.
- `/chief-install` writes `AGENTS.md` directly (diff, present, confirm, write) — there is no
  `scripts/setup.sh` to keep in sync with it. Don't recreate one.
- Product changes (`AGENTS.md` content, skills) → MUST edit the source-of-truth path first,
  then sync to root if applicable.
- `.chief/` is created lazily at runtime by whichever `chief-*` skill runs first. There is no
  `template/.chief/` to scaffold from.
- Dogfooding-only changes (story plans, tickets, reports) → edit root `.chief/` directly.
- NEVER let root and template drift without explicit reason.

---

## Project Configuration

Project-specific details (dev commands, tech stack, architecture) are defined in
`.chief/project.md`.
