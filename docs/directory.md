## Directory Structure

After `/chief-install` your project will have:

```
project/
├── AGENTS.md               # Framework rules (fresh write, or appended to existing)
├── CLAUDE.md → AGENTS.md   # Symlink (Claude Code only)
├── .github/agents/        # Copilot agent definitions (symlinks or copies)
├── .agents/               # Canonical agent definitions (coding-agent-agnostic)
│   ├── agents/            # Agent role definitions
│   └── skills/            # Installed via npx skills (separate from /chief-install)
├── .claude/               # Claude Code integration (symlinks)
│   ├── agents/ → .agents/agents/*
│   └── skills/ → .agents/skills/*   # Installed via npx skills
```

`.chief/` is **not** created at install time. It grows on demand:

```
.chief/                    # Created lazily as you use the framework
├── project.md             # Created by /chief-init
├── _rules/                # Subfolders (_standard/_contract/_goal/_verification) created on first rule
└── milestone-N/           # Created by /chief-plan or chief-agent on first milestone
```

A canonical example layout lives at [`docs/example-chief/`](docs/example-chief/) for reference.

## How It Works

- `.agents/` is the **canonical, coding-agent-agnostic** location for agent definitions; skills are managed separately by `npx skills` and land under `.agents/skills/`
- `.chief/` contains planning, rules, milestones, and project configuration
- `AGENTS.md` defines the highest-authority framework rules
- `CLAUDE.md` is a symlink to `AGENTS.md` (Claude Code only)
- `.github/agents/` contains symlinks or copies for GitHub Copilot
- Agent-specific directories (`.claude/`, `.github/agents/`, etc.) are populated via symlinks or copies pointing back to `.agents/`
