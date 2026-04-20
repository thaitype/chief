# AI Agent Coding Config Paths

All known instruction and config file paths per tool — project-local and global.

> **Cross-tool tip:** `AGENTS.md` is the Linux Foundation AAIF standard (Dec 2025), supported by 25+ tools. Start here for maximum compatibility.

---

## Claude Code

Anthropic's CLI agent. Merges CLAUDE.md from three locations in order.

| Path | Scope | Notes |
|---|---|---|
| `~/.claude/CLAUDE.md` | Global | Applied to all projects |
| `.claude/CLAUDE.md` or `CLAUDE.md` | Project root | Shared via git |
| `<subdir>/CLAUDE.md` | Subdir scoped | Loaded when agent accesses that dir |
| `.claude/settings.json` | Config | Filename override, hooks, permissions |
| `.claude/commands/*.md` | Slash commands | Custom `/commands` |
| `~/.claude/skills/*/SKILL.md` | Global skills | Reusable instructions (global) |
| `.claude/skills/*/SKILL.md` | Project skills | Reusable instructions (local) |
| `AGENTS.md` | Fallback | Read if no CLAUDE.md found in dir |

---

## OpenCode

Open-source multi-model CLI. Walks up from cwd to git root loading skills.

| Path | Scope | Notes |
|---|---|---|
| `~/.config/opencode/config.json` | Global config | Model, providers, agents |
| `.opencode/config.json` | Project config | Overrides global |
| `.opencode/skills/*/SKILL.md` | Project skills | Agent-discoverable skills |
| `.claude/skills/*/SKILL.md` | Project skills | Cross-compat with Claude Code |
| `.agents/skills/*/SKILL.md` | Project skills | Cross-compat standard path |
| `~/.config/opencode/skills/*/SKILL.md` | Global skills | |
| `~/.claude/skills/*/SKILL.md` | Global skills | Cross-compat |
| `~/.agents/skills/*/SKILL.md` | Global skills | Cross-compat |
| `AGENTS.md` | Instructions | Primary instruction file |
| `.opencode/agents/*.md` | Agent definitions | Custom agents with YAML frontmatter |

---

## Cursor

AI-first IDE (VS Code fork). Most granular rule scoping system.

| Path | Scope | Notes |
|---|---|---|
| `.cursorrules` | Legacy project | Plain text, still supported but deprecated |
| `.cursor/rules/*.mdc` | Project rules | MDC format with YAML frontmatter |
| `.cursor/rules/*/RULE.md` | Project rules | Directory-based (2026) |
| `.cursorignore` | Ignore | Exclude files from indexing |
| `AGENTS.md` | Cross-tool | Read natively |

---

## GitHub Copilot

GitHub's AI coding assistant. Added AGENTS.md support Aug 2025.

| Path | Scope | Notes |
|---|---|---|
| `.github/copilot-instructions.md` | Project-wide | Original format |
| `.github/instructions/*.instructions.md` | Scoped | YAML frontmatter with glob patterns (2025) |
| `AGENTS.md` | Cross-tool | Supported since Aug 2025 |
| `.github/agents/*.agent.md` | Agent definitions | Custom agents with YAML frontmatter |

---

## Windsurf

Codeium's AI IDE.

| Path | Scope | Notes |
|---|---|---|
| `.windsurfrules` | Project root | Plain text rules |
| `.windsurf/rules/` | Project scoped | Directory of rule files |
| `.codeiumignore` | Ignore | Exclude files from AI context |
| `AGENTS.md` | Cross-tool | Supported |

---

## Gemini CLI

Google's open-source terminal agent. Agent Skills in preview since Jan 2026.

| Path | Scope | Notes |
|---|---|---|
| `~/.gemini/settings.json` | Global config | Theme, model, preferences |
| `GEMINI.md` | Project root | Primary instruction file |
| `<subdir>/GEMINI.md` | Subdir scoped | Loaded dynamically when files accessed |
| `.gemini/settings.json` | Project config | Local overrides |
| `~/.gemini/skills/*/SKILL.md` | Global skills | Agent Skills (preview) |
| `.gemini/skills/*/SKILL.md` | Project skills | Agent Skills (preview) |
| `~/.gemini/antigravity/skills/` | Global skills | Antigravity skills default path |
| `AGENTS.md` | Cross-tool | Supported |

---

## Codex CLI

OpenAI's CLI agent (written in Rust). Originated the AGENTS.md spec.

| Path | Scope | Notes |
|---|---|---|
| `AGENTS.md` | Primary | Walks from git root → cwd, nearest wins |
| `AGENTS.override.md` | Override | Highest precedence at each dir level |
| `.agents.md` | Fallback | Alt name (lowercase) |
| `TEAM_GUIDE.md` | Fallback | Legacy fallback name |
| `~/.codex/config.toml` | Global config | Model, sandbox settings |

---

## Aider

Mature git-native CLI pair programmer (4.1M+ installs).

| Path | Scope | Notes |
|---|---|---|
| `~/.aider.conf.yml` | Global config | All CLI flags as YAML |
| `.aider.conf.yml` | Project config | Project-level overrides |
| `.aider.env` | Env vars | API keys, env config |
| `.aiderignore` | Ignore | Like .gitignore for Aider context |
| `AGENTS.md` / `CONVENTIONS.md` | Instructions | Read for project context |

---

## Kiro (AWS)

AWS spec-driven IDE + CLI (formerly Amazon Q Developer, rebranded Nov 2025).

| Path | Scope | Notes |
|---|---|---|
| `.kiro/steering/*.md` | Steering docs | Always-loaded project context |
| `.kiro/agents/*.md` | Agent definitions | Custom agents with YAML frontmatter |
| `.kiro/skills/*/SKILL.md` | Project skills | Agent Skills format |
| `.kiro/hooks.json` | Hooks | Automate actions on file save, etc. |
| `.kiro/settings.json` | Project config | Model, permissions |
| `AGENTS.md` | Cross-tool | Supported |

---

## Amp (Sourcegraph)

Deep codebase analysis agent with Oracle/Librarian sub-agents.

| Path | Scope | Notes |
|---|---|---|
| `AGENTS.md` | Primary instructions | Primary cross-tool file |
| `.amp/config.json` | Project config | Agent, model, tool settings |
| `.amp/agents/*.md` | Agent definitions | Specialized sub-agents |

---

## Agent Skills Standard

Universal cross-tool `SKILL.md` format (AAIF / Linux Foundation).

| Path | Scope | Notes |
|---|---|---|
| `.agents/skills/*/SKILL.md` | Project | Universal cross-tool path |
| `~/.agents/skills/*/SKILL.md` | Global | Universal cross-tool global |
| `AGENTS.md` | Instructions | Root standard |

---

## Recommended multi-tool project layout

```
project/
├── AGENTS.md                              # primary cross-tool instructions (start here)
├── CLAUDE.md                              # Claude Code specific (or just reference AGENTS.md)
├── .claude/
│   ├── settings.json
│   └── skills/*/SKILL.md
├── .kiro/
│   └── steering/*.md
├── .cursor/
│   └── rules/*.mdc
├── .github/
│   ├── copilot-instructions.md
│   └── instructions/*.instructions.md
└── .agents/
    └── skills/*/SKILL.md                  # universal skills path
```

> **SKILL.md precedence in OpenCode/Claude Code:** Global (`~/.claude/skills/`) → Project (`.claude/skills/`) → Subdir, with closer paths winning. Each `SKILL.md` requires YAML frontmatter with at minimum a `name` and `description` field.
