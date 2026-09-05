# AGENTS.md

<!-- chief-framework:begin -->
## Chief Framework

This project uses the [Chief](https://github.com/thaitype/chief) framework. Run `/chief-explain`
for how it's structured (directory layout, storage location, what each skill owns), or
`/ask-chief` if you're not sure which skill fits your situation.
<!-- chief-framework:end -->

## Project Rules

- This repo IS the Chief framework. Sources of truth:
  - Skills: `skills/` (chief, engineering, misc, setup)
  - Example `.chief/` layout (reference only): `docs/example-chief/`
- There is no `template/` directory anymore — no `template/AGENTS.md`, no
  `template/.agents/agents/`. v5 has no install/upgrade skill and writes nothing to
  `AGENTS.md`; don't recreate either. Root `AGENTS.md` (this file) is this repo's own,
  hand-maintained, not generated from or synced with any template.
- Product changes (skill content) → edit the skill's own `SKILL.md` directly; nothing to sync
  elsewhere.
- `.chief/` is created lazily at runtime by whichever `chief-*` skill runs first.
- Dogfooding-only changes (story plans, tickets, reports) → edit root `.chief/` directly.

---

## Project Configuration

Project-specific details (dev commands, tech stack, architecture) are defined in
`.chief/project.md`.
