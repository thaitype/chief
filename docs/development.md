# Development Install

Install a specific branch directly using `curl`. Useful for testing feature branches before they're released.

## Lite profile

```bash
curl -fsSL https://raw.githubusercontent.com/thaitype/chief-agent-framework/refs/heads/<branch>/template/AGENTS.lite.md -o AGENTS.md
```

For coding agents that need a symlink:

```bash
# Claude Code
ln -s AGENTS.md CLAUDE.md

# Cursor
ln -s AGENTS.md .cursorrules
```

## Full profile

```bash
git clone --depth 1 --branch <branch> https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
bash .chief-agent-tmp/scripts/setup.sh --agent claude-code
rm -rf .chief-agent-tmp
```

Replace `<branch>` with the branch name (e.g. `canary`, `canary.lite-profile`, `main`).
