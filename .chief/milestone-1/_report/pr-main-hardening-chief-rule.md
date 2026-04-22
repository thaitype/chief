
This PR covers three major areas:

1. **Framework hardening** — Compressed AGENTS.md, added responsibility boundaries (Builder vs Tester), mandatory review gates, user interaction rules, and Agent Behavior Principles (Karpathy-inspired).
2. **Skills system** — Added 5 new skills (chief-plan, chief-autopilot, chief-retro, dump-commit, chief-upgrade), improved existing skills (plan-milestone backtrack rules, upgrade-chief process), and added upgrade.sh script.
3. **v3 rebrand** — Renamed project to "Chief", moved repo to `thaitype/chief`, renamed all framework skills to `chief-` prefix, updated all docs.

## Changes by area

### AGENTS.md overhaul
- Compressed from verbose to concise format
- Added Agent Behavior Principles (Think Before Acting, Simplicity First, Surgical Changes, Goal-Driven Execution)
- Added responsibility boundaries: Builder handles local verification, Tester handles real-world validation only
- Added User Interaction Rules (one question at a time, no recap in ask_user)
- Clarified milestone isolation rule
- Extracted detailed docs to `docs/rules-hierarchy.md` and `docs/writing-agents-md.md`

### New skills (shipped in template)
- **chief-plan** — milestone planning with grill-me, review gates, backtrack rules
- **chief-autopilot** — autonomous milestone execution with auto/safe modes
- **chief-retro** — retrospective with coverage check and rule proposals
- **dump-commit** — quick commit with minimal token usage

### Rename skills (root only)
- **chief-upgrade** (was upgrade-chief) — framework upgrade with plan/apply workflow
- **chief-install** (was install-chief) — framework upgrade with plan/apply workflow
- **upgrade.sh** — shell script for automated upgrades

### Improved skills
- **chief-upgrade**: added AGENTS.md diff/merge, temp file rules, no-delete policy, and add **upgrade.sh** — shell script for reduce failure upgrade by AI

### v3 rebrand
- Project renamed: "Chief Agent Framework" → "Chief"
- Repo URL: `thaitype/chief-agent-framework` → `thaitype/chief`
- Skills renamed: `install-chief` → `chief-install`, `upgrade-chief` → `chief-upgrade` for consistency with new skills, `chief-plan`, `chief-autopilot`, `chief-retro`,
- Added chief-tribe ecosystem and elder references
- Updated READMEs (EN + TH), MANUAL, philosophy, manual-install, all SKILL.md files
- Added v3 upgrade path docs ("Coming from v2")

