#!/usr/bin/env bash
set -euo pipefail

# Chief Agent Framework - Setup Script
# Installs .agents/, .chief/, and CLAUDE.md into a project,
# then creates symlinks for the specified agent tool.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(dirname "$SCRIPT_DIR")"

# --- Parse arguments ---

MODE="link"
AGENT=""
PRESET="full"

print_usage() {
  echo "Usage: bash scripts/setup.sh [--preset lite|full] [--mode link|copy] --agent <agent>"
  echo ""
  echo "Agents:"
  echo "  claude-code   Claude Code (CLAUDE.md + .claude/agents/ and .claude/skills/)"
  echo "  opencode      OpenCode (reads AGENTS.md and .agents/ directly)"
  echo "  codex         Codex CLI (reads AGENTS.md directly)"
  echo "  cursor        Cursor (reads AGENTS.md directly)"
  echo "  copilot       GitHub Copilot (reads AGENTS.md directly)"
  echo "  gemini-cli    Gemini CLI (reads AGENTS.md directly)"
  echo "  amp           Amp (reads AGENTS.md directly)"
  echo "  windsurf      Windsurf (reads AGENTS.md directly)"
  echo "  kiro          Kiro (reads AGENTS.md directly)"
  echo "  aider         Aider (reads AGENTS.md directly)"
  echo ""
  echo "Options:"
  echo "  -a, --agent <agent>   Specify coding agent (required)"
  echo "  --preset full         Install full framework (default)"
  echo "  --preset lite         Install lite preset (sa-agent + review-plan-agent + CHIEF.md)"
  echo "  --mode link           Create symlinks (default)"
  echo "  --mode copy           Copy files instead of symlinking"
  echo ""
  echo "Example:"
  echo "  bash .chief-agent-tmp/scripts/setup.sh --agent claude-code"
  echo "  bash .chief-agent-tmp/scripts/setup.sh --agent cursor"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preset)
      PRESET="$2"
      shift 2
      ;;
    --mode)
      MODE="$2"
      shift 2
      ;;
    -a|--agent)
      AGENT="$2"
      shift 2
      ;;
    --help|-h)
      print_usage
      exit 0
      ;;
    *)
      echo "Error: Unknown argument '$1'"
      echo ""
      print_usage
      exit 1
      ;;
  esac
done

SUPPORTED_AGENTS="claude-code opencode codex cursor copilot gemini-cli amp windsurf kiro aider"

if [[ -z "$AGENT" ]]; then
  echo "Error: Please specify an agent with --agent"
  echo ""
  print_usage
  exit 1
fi

if [[ "$MODE" != "link" && "$MODE" != "copy" ]]; then
  echo "Error: --mode must be 'link' or 'copy'"
  exit 1
fi

if [[ "$PRESET" != "lite" && "$PRESET" != "full" ]]; then
  echo "Error: --preset must be 'lite' or 'full'"
  exit 1
fi

if ! echo "$SUPPORTED_AGENTS" | grep -qw "$AGENT"; then
  echo "Error: Unsupported agent '$AGENT'."
  echo "Supported: $SUPPORTED_AGENTS"
  exit 1
fi

# --- Detect target directory ---
# If running from a temp clone (e.g. .chief-agent-tmp/scripts/setup.sh),
# install into the parent of the clone directory.
# Otherwise, install into the current working directory.

if [[ "$(basename "$SOURCE_ROOT")" == .chief-agent-tmp ]]; then
  TARGET_DIR="$(dirname "$SOURCE_ROOT")"
else
  TARGET_DIR="$(pwd)"
fi

echo "Installing Chief Agent Framework into: $TARGET_DIR"
echo "Agent: $AGENT"
echo "Preset: $PRESET"
echo "Mode: $MODE"
echo ""

# --- Helper functions ---

copy_dir() {
  local src="$1"
  local dest="$2"
  local name="$3"

  if [[ -d "$dest" ]]; then
    echo "  SKIP $name/ (already exists)"
  else
    cp -r "$src" "$dest"
    echo "  COPY $name/"
  fi
}

copy_file() {
  local src="$1"
  local dest="$2"
  local name="$3"

  if [[ -f "$dest" ]]; then
    echo "  SKIP $name (already exists)"
  else
    cp "$src" "$dest"
    echo "  COPY $name"
  fi
}

create_symlink() {
  local target="$1"
  local link_path="$2"
  local name="$3"

  if [[ -e "$link_path" || -L "$link_path" ]]; then
    echo "  SKIP $name (already exists)"
  else
    ln -s "$target" "$link_path"
    echo "  LINK $name -> $target"
  fi
}

copy_to_dest() {
  local src="$1"
  local dest="$2"
  local name="$3"

  if [[ -e "$dest" ]]; then
    echo "  SKIP $name (already exists)"
  else
    if [[ -d "$src" ]]; then
      cp -r "$src" "$dest"
    else
      cp "$src" "$dest"
    fi
    echo "  COPY $name"
  fi
}

# --- Step 1: Copy core files ---

echo "Copying core files..."
if [[ "$PRESET" == "full" ]]; then
  copy_dir "$SOURCE_ROOT/.agents" "$TARGET_DIR/.agents" ".agents"
  copy_dir "$SOURCE_ROOT/.chief" "$TARGET_DIR/.chief" ".chief"

  if [[ -f "$SOURCE_ROOT/AGENTS.full.md" ]]; then
    copy_file "$SOURCE_ROOT/AGENTS.full.md" "$TARGET_DIR/AGENTS.md" "AGENTS.md (from AGENTS.full.md)"
  else
    copy_file "$SOURCE_ROOT/AGENTS.md" "$TARGET_DIR/AGENTS.md" "AGENTS.md"
  fi
else
  mkdir -p "$TARGET_DIR/.agents/agents"
  copy_file "$SOURCE_ROOT/.agents/agents/sa-agent.md" "$TARGET_DIR/.agents/agents/sa-agent.md" ".agents/agents/sa-agent.md"
  copy_file "$SOURCE_ROOT/.agents/agents/review-plan-agent.md" "$TARGET_DIR/.agents/agents/review-plan-agent.md" ".agents/agents/review-plan-agent.md"

  if [[ -f "$SOURCE_ROOT/AGENTS.lite.md" ]]; then
    copy_file "$SOURCE_ROOT/AGENTS.lite.md" "$TARGET_DIR/AGENTS.md" "AGENTS.md (from AGENTS.lite.md)"
  else
    copy_file "$SOURCE_ROOT/AGENTS.md" "$TARGET_DIR/AGENTS.md" "AGENTS.md"
  fi

  copy_file "$SOURCE_ROOT/.chief/_template/CHIEF.md" "$TARGET_DIR/CHIEF.md" "CHIEF.md"
fi
echo ""

# --- Step 2: Agent-specific setup ---

case "$AGENT" in
  claude-code)
    echo "Setting up Claude Code integration..."
    mkdir -p "$TARGET_DIR/.claude/agents"
    if [[ "$PRESET" == "full" ]]; then
      mkdir -p "$TARGET_DIR/.claude/skills"
    fi

    if [[ "$MODE" == "link" ]]; then
      # Symlink CLAUDE.md to AGENTS.md
      create_symlink "AGENTS.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md -> AGENTS.md"

      # Symlink individual agent files
      for agent_file in "$TARGET_DIR/.agents/agents"/*.md; do
        filename="$(basename "$agent_file")"
        create_symlink "../../.agents/agents/$filename" "$TARGET_DIR/.claude/agents/$filename" ".claude/agents/$filename"
      done

      if [[ "$PRESET" == "full" ]]; then
        # Symlink individual skill directories
        for skill_dir in "$TARGET_DIR/.agents/skills"/*/; do
          if [[ -d "$skill_dir" ]]; then
            skill_name="$(basename "$skill_dir")"
            create_symlink "../../.agents/skills/$skill_name" "$TARGET_DIR/.claude/skills/$skill_name" ".claude/skills/$skill_name"
          fi
        done
      fi
    else
      # Copy CLAUDE.md from AGENTS.md
      copy_to_dest "$TARGET_DIR/AGENTS.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md (copy of AGENTS.md)"

      # Copy individual agent files
      for agent_file in "$TARGET_DIR/.agents/agents"/*.md; do
        filename="$(basename "$agent_file")"
        copy_to_dest "$agent_file" "$TARGET_DIR/.claude/agents/$filename" ".claude/agents/$filename"
      done

      if [[ "$PRESET" == "full" ]]; then
        # Copy individual skill directories
        for skill_dir in "$TARGET_DIR/.agents/skills"/*/; do
          if [[ -d "$skill_dir" ]]; then
            skill_name="$(basename "$skill_dir")"
            copy_to_dest "$skill_dir" "$TARGET_DIR/.claude/skills/$skill_name" ".claude/skills/$skill_name"
          fi
        done
      fi
    fi
    ;;

  *)
    echo "Setting up $AGENT integration..."
    echo "  $AGENT reads AGENTS.md and .agents/ directly. No additional setup needed."
    ;;
esac

echo ""
echo "Done! Chief Agent Framework installed successfully."
echo ""
echo "Next steps:"
if [[ "$PRESET" == "full" ]]; then
  echo "  1. Edit .chief/project.md with your project details"
  echo "  2. Review AGENTS.md and customize if needed"
  echo "  3. Start using: ask chief-agent to plan your first milestone"
else
  echo "  1. Edit CHIEF.md with your project context"
  echo "  2. Review AGENTS.md and customize if needed"
  echo "  3. Start using: ask sa-agent to grill your design decisions"
  echo "  4. Upgrade path when needed: /upgrade-chief --preset full"
fi
