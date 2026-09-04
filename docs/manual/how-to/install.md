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

`/chief-install` writes `AGENTS.md` directly (there's no `scripts/setup.sh` in v5 — see
`docs/design/v5-ai-workflow.md` for why: the only thing it ever did was a small,
judgment-sensitive file merge, which fits an agent's diff-then-confirm loop better than a blind
script). If you can't use `npx skills` to fetch the skill files, you still need *some* coding
agent session to run `/chief-install` — point it at this repo and ask it to install the
skill, or copy `skills/setup/chief-install/SKILL.md`'s instructions into your agent manually.

Truly agent-free install (no session at all) means doing what `/chief-install` would do, by
hand:

```bash
git clone --depth 1 --branch main https://github.com/thaitype/chief.git .chief-agent-tmp
cp .chief-agent-tmp/template/AGENTS.md AGENTS.md   # only if you don't already have one -
                                                     # if you do, merge by hand: see the
                                                     # <!-- chief-framework:begin/end --> markers
                                                     # in the template file
ln -s AGENTS.md CLAUDE.md   # Claude Code only; use `cp` instead of `ln -s` if symlinks aren't available
rm -rf .chief-agent-tmp
```

This is the one case where care matters: if `AGENTS.md` already exists, don't overwrite it
blindly — merge the template's `<!-- chief-framework:begin -->`/`<!-- chief-framework:end -->`
block in and leave the rest of the file untouched, the same way `/chief-install` does when an
agent runs it.

---

## Windows

Symlink mode requires Developer Mode enabled and:

```bash
git config --global core.symlinks true
```

`/chief-install` detects symlink support automatically and falls back to copy mode if
unavailable.

---

## After install

Run `/chief-init` to bootstrap project context. See [the tutorial](../tutorials/your-first-story.md#step-3--bootstrap-project-context) for what this does.

To verify the install worked, check that `AGENTS.md` exists in your project root and that your agent can read it.

---

## Related

- [How to upgrade Chief](upgrade.md)
- [Directory structure reference](../reference/directory-structure.md)
- [Compatibility reference](../reference/agents.md)
