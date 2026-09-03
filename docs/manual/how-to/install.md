# How to install Chief

This guide covers installing Chief into an existing project. If you want to understand the full workflow first, start with the [tutorial](../tutorials/your-first-story.md).

---

## Prerequisites

- Node.js 18+ (for `npx skills`)
- A project directory with a coding agent configured (Claude Code, GitHub Copilot, Cursor, etc.)

---

## Standard install (recommended)

**Step 1 — Install skills:**

```bash
npx skills@latest add thaitype/chief
```

Select the skills you want. At minimum, select `chief-install`. Press `a` to select all.

**Step 2 — Run the install skill in your agent:**

```
/chief-install
```

The skill asks:
- Which coding agent you use
- Whether to use symlink or copy mode (Claude Code only)

There's no subagent roster to install in v5 — see
[chief-* execution skills reference](../reference/agents.md). When done, your project has
`AGENTS.md` (and, for Claude Code, a `CLAUDE.md` pointer to it).

---

## Manual install (no npx)

If you can't use `npx skills`, install via shell script:

```bash
git clone --depth 1 --branch main https://github.com/thaitype/chief.git .chief-agent-tmp
bash .chief-agent-tmp/scripts/setup.sh --agent claude-code
rm -rf .chief-agent-tmp
```

Replace `claude-code` with your agent: `copilot`, `cursor`, `opencode`, `codex`, `gemini-cli`, `amp`, `windsurf`, `kiro`, `aider`.

Add `--mode copy` if symlinks aren't supported:

```bash
bash .chief-agent-tmp/scripts/setup.sh --agent claude-code --mode copy
```

---

## Windows

Symlink mode requires Developer Mode enabled and:

```bash
git config --global core.symlinks true
```

The setup script detects symlink support automatically and falls back to copy mode if unavailable. With `npx skills` + `/chief-install`, the skill handles this for you.

---

## After install

Run `/chief-init` to bootstrap project context. See [the tutorial](../tutorials/your-first-story.md#step-3--bootstrap-project-context) for what this does.

To verify the install worked, check that `AGENTS.md` exists in your project root and that your agent can read it.

---

## Related

- [How to upgrade Chief](upgrade.md)
- [Directory structure reference](../reference/directory-structure.md)
- [Compatibility reference](../reference/agents.md)
