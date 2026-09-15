# How to get the Chief skills into a project

This guide covers getting Chief's skills into an existing project. If you want to understand
the full workflow first, start with the [tutorial](../tutorials/your-first-story.md).

There's no install step beyond this — nothing needs to be written to `AGENTS.md` for Chief to
work. Every `chief-*` slash command is available the moment its skill file is present.

---

## Prerequisites

- Node.js 18+ (for `npx skills`)
- A project directory with a coding agent configured (Claude Code, GitHub Copilot, Cursor, etc.)

---

## Standard way (recommended)

```bash
npx skills@latest add thaitype/chief
```

Select the skills you want. Press `a` to select all. That's it.

---

## Without npx

If you can't use `npx skills` to fetch the skill files, copy them manually: clone this repo
and copy whichever `skills/**/SKILL.md` files you want into wherever your coding agent expects
skill files (e.g. `.claude/skills/<name>/SKILL.md` for Claude Code).

```bash
git clone --depth 1 --branch main https://github.com/thaitype/chief.git .chief-skills-tmp
cp -r .chief-skills-tmp/skills/chief/chief-plan .claude/skills/
# repeat for whichever skills you want
rm -rf .chief-skills-tmp
```

---

## Optional: `AGENTS.md` / `CLAUDE.md`

Chief never creates or writes to these files — they're entirely yours, and only matter if you
want your own Project Rules recognized by your coding agent. If you want one:

- Most agents (GitHub Copilot, Cursor, and others) read `AGENTS.md` directly. Write your rules
  there.
- Claude Code reads `CLAUDE.md` specifically. Symlink it to `AGENTS.md` if you want to
  maintain one file for both:
  ```bash
  ln -s AGENTS.md CLAUDE.md   # or `cp` instead of `ln -s` if symlinks aren't available
  ```

See [chief-* execution skills reference](../reference/agents.md) for how Chief's own rules
hierarchy treats whatever you put there.

---

## After getting the skills

Run `/chief-init` to bootstrap project context. See [the tutorial](../tutorials/your-first-story.md#step-2--bootstrap-project-context) for what this does.

---

## Related

- [How to upgrade Chief](upgrade.md)
- [Directory structure reference](../reference/directory-structure.md)
- [Compatibility reference](../reference/agents.md)
