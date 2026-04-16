# Chief Agent Framework

**Chief Agent Framework** is an agent-agnostic framework for goal-driven autonomous development with minimal human intervention.

## Supported Agents

| Agent | Integration | Notes |
|-------|------------|-------|
| Claude Code | Symlinks from `.claude/` to `.agents/` | Full support (agents + skills) |
| OpenCode | Reads `.agents/` directly | No symlinks needed |

## Setup (v1 — Stable)

Recommended for production use. Uses `v1.0.0` tagged release.

```bash
npx degit thaitype/chief-agent-framework/.chief#v1.0.0 .chief
npx degit thaitype/chief-agent-framework/.claude#v1.0.0 .claude
npx degit thaitype/chief-agent-framework/CLAUDE.md#v1.0.0 CLAUDE.md
```

## Setup (v2 — Development)

> **Not yet released.** Use from `main` branch for testing only.

```bash
git clone --depth 1 https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
bash .chief-agent-tmp/scripts/setup.sh claude
rm -rf .chief-agent-tmp
```

Replace `claude` with `opencode` if using OpenCode.

### Mode Options

- `--mode link` (default) — creates symlinks from agent-specific directories to `.agents/`
- `--mode copy` — copies files instead of symlinking (fallback for environments without symlink support)

```bash
bash .chief-agent-tmp/scripts/setup.sh --mode copy claude
```

### Manual Install

If you prefer not to use the setup script:

1. Copy the directories and file into your project:

```bash
git clone --depth 1 https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
cp -r .chief-agent-tmp/.agents .agents
cp -r .chief-agent-tmp/.chief .chief
cp .chief-agent-tmp/CLAUDE.md CLAUDE.md
rm -rf .chief-agent-tmp
```

2. For **Claude Code**, create symlinks from `.claude/` to `.agents/`:

```bash
mkdir -p .claude/agents .claude/skills
ln -s ../../.agents/agents/chief-agent.md .claude/agents/chief-agent.md
ln -s ../../.agents/agents/builder-agent.md .claude/agents/builder-agent.md
ln -s ../../.agents/agents/tester-agent.md .claude/agents/tester-agent.md
ln -s ../../.agents/agents/review-plan-agent.md .claude/agents/review-plan-agent.md
ln -s ../../.agents/skills/grill-me .claude/skills/grill-me
```

3. For **OpenCode**, no extra steps — it reads `.agents/` directly.

## Directory Structure

After setup, your project will have:

```
project/
├── CLAUDE.md              # Framework rules (highest authority)
├── .agents/               # Canonical agent definitions (tool-agnostic)
│   ├── agents/            # Agent role definitions
│   │   ├── chief-agent.md
│   │   ├── builder-agent.md
│   │   ├── tester-agent.md
│   │   └── review-plan-agent.md
│   └── skills/            # Installable skills
│       └── grill-me/
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

- `.agents/` is the **canonical, tool-agnostic** location for agent definitions and skills
- `.chief/` contains planning, rules, milestones, and project configuration
- `CLAUDE.md` defines the highest-authority framework rules
- Agent-specific directories (`.claude/`, etc.) are populated via symlinks or copies pointing back to `.agents/`

## Prerequisite

- Define clear `CLAUDE.md` as high-level rules for chief-agent to follow
- Edit `.chief/project.md` with your project's tech stack, commands, and architecture
- Optionally define global goals in `.chief/_rules/_goal/`
- Define milestone goals in `.chief/milestone-*/_goal/`

## Usage

1. Ask `chief-agent` to create the contract at rules level (optional)
2. Ask `chief-agent` to create the contract at milestone level
3. Human reviews contract, iterates with `chief-agent` until satisfied
4. Ask `chief-agent` to create plan and tasks based on the contract
5. Ask `builder-agent` to implement tasks from the plan
6. Ask `chief-agent` to review work and plan next tasks
7. Repeat until milestone is achieved

## Release

- `main` is the active development branch
- `v1.0.0` — first stable release (Claude Code only, uses `degit`)
- v2 release planned with multi-agent support

## Acknowledgement

- Grill me Skill from [mattpocock](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md)
- Multi-agent architecture inspired by [vercel-labs/skills](https://github.com/vercel-labs/skills)
