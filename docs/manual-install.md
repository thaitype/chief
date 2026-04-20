# Manual Install (canary)

These are alternative installation methods for the `canary` (development) version. For the recommended skill-based install, see the [README](../README.md#setup-canary--development).

## Setup with Shell Script

```bash
git clone --depth 1 --branch canary https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
bash .chief-agent-tmp/scripts/setup.sh --agent claude-code
rm -rf .chief-agent-tmp
```

Replace `claude-code` with any supported agent: `opencode`, `codex`, `cursor`, `copilot`, `gemini-cli`, `amp`, `windsurf`, `kiro`, `aider`. Add `--mode copy` if symlinks are not supported in your environment.

## Manual Install

```bash
git clone --depth 1 --branch canary https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
cp -r .chief-agent-tmp/.agents .agents
cp -r .chief-agent-tmp/.chief .chief
cp .chief-agent-tmp/AGENTS.md AGENTS.md
rm -rf .chief-agent-tmp
```

For **Claude Code**, create `CLAUDE.md` symlink and agent/skill symlinks:

```bash
ln -s AGENTS.md CLAUDE.md
```

```bash
mkdir -p .claude/agents .claude/skills
ln -s ../../.agents/agents/chief-agent.md .claude/agents/chief-agent.md
ln -s ../../.agents/agents/builder-agent.md .claude/agents/builder-agent.md
ln -s ../../.agents/agents/tester-agent.md .claude/agents/tester-agent.md
ln -s ../../.agents/agents/review-plan-agent.md .claude/agents/review-plan-agent.md
ln -s ../../.agents/skills/grill-me .claude/skills/grill-me
```

For **GitHub Copilot**, copy agents to `.github/agents/` with `.agent.md` suffix:

```bash
mkdir -p .github/agents
cp .agents/agents/chief-agent.md .github/agents/chief-agent.agent.md
cp .agents/agents/builder-agent.md .github/agents/builder-agent.agent.md
cp .agents/agents/tester-agent.md .github/agents/tester-agent.agent.md
cp .agents/agents/review-plan-agent.md .github/agents/review-plan-agent.agent.md
```

For other coding agents — no extra steps, they read `AGENTS.md` directly.
