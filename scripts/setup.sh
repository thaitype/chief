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

print_usage() {
  echo "Usage: bash scripts/setup.sh [--mode link|copy] <agent>"
  echo ""
  echo "Agents:"
  echo "  claude      Claude Code (.claude/agents/ and .claude/skills/)"
  echo "  opencode    OpenCode (reads .agents/ directly, no symlinks needed)"
  echo ""
  echo "Options:"
  echo "  --mode link   Create symlinks (default)"
  echo "  --mode copy   Copy files instead of symlinking"
  echo ""
  echo "Example:"
  echo "  git clone --depth 1 --branch v2.0.0 https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp"
  echo "  bash .chief-agent-tmp/scripts/setup.sh claude"
  echo "  rm -rf .chief-agent-tmp"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"
      shift 2
      ;;
    --help|-h)
      print_usage
      exit 0
      ;;
    *)
      AGENT="$1"
      shift
      ;;
  esac
done

if [[ -z "$AGENT" ]]; then
  echo "Error: Please specify an agent: claude, opencode"
  echo ""
  print_usage
  exit 1
fi

if [[ "$MODE" != "link" && "$MODE" != "copy" ]]; then
  echo "Error: --mode must be 'link' or 'copy'"
  exit 1
fi

if [[ "$AGENT" != "claude" && "$AGENT" != "opencode" ]]; then
  echo "Error: Unsupported agent '$AGENT'. Supported: claude, opencode"
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
copy_dir "$SOURCE_ROOT/.agents" "$TARGET_DIR/.agents" ".agents"
copy_dir "$SOURCE_ROOT/.chief" "$TARGET_DIR/.chief" ".chief"
copy_file "$SOURCE_ROOT/AGENT.md" "$TARGET_DIR/AGENT.md" "AGENT.md"

if [[ "$MODE" == "link" ]]; then
  create_symlink "AGENT.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md -> AGENT.md"
else
  copy_to_dest "$TARGET_DIR/AGENT.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md (copy of AGENT.md)"
fi
echo ""

# --- Step 2: Agent-specific setup ---

case "$AGENT" in
  claude)
    echo "Setting up Claude Code integration..."
    mkdir -p "$TARGET_DIR/.claude/agents"
    mkdir -p "$TARGET_DIR/.claude/skills"

    if [[ "$MODE" == "link" ]]; then
      # Symlink individual agent files
      for agent_file in "$TARGET_DIR/.agents/agents"/*.md; do
        filename="$(basename "$agent_file")"
        create_symlink "../../.agents/agents/$filename" "$TARGET_DIR/.claude/agents/$filename" ".claude/agents/$filename"
      done

      # Symlink individual skill directories
      for skill_dir in "$TARGET_DIR/.agents/skills"/*/; do
        if [[ -d "$skill_dir" ]]; then
          skill_name="$(basename "$skill_dir")"
          create_symlink "../../.agents/skills/$skill_name" "$TARGET_DIR/.claude/skills/$skill_name" ".claude/skills/$skill_name"
        fi
      done
    else
      # Copy individual agent files
      for agent_file in "$TARGET_DIR/.agents/agents"/*.md; do
        filename="$(basename "$agent_file")"
        copy_to_dest "$agent_file" "$TARGET_DIR/.claude/agents/$filename" ".claude/agents/$filename"
      done

      # Copy individual skill directories
      for skill_dir in "$TARGET_DIR/.agents/skills"/*/; do
        if [[ -d "$skill_dir" ]]; then
          skill_name="$(basename "$skill_dir")"
          copy_to_dest "$skill_dir" "$TARGET_DIR/.claude/skills/$skill_name" ".claude/skills/$skill_name"
        fi
      done
    fi
    ;;

  opencode)
    echo "Setting up OpenCode integration..."
    echo "  OpenCode reads from .agents/ directly. No additional setup needed."
    ;;
esac

echo ""
echo "Done! Chief Agent Framework installed successfully."
echo ""
echo "Next steps:"
echo "  1. Edit .chief/project.md with your project details"
echo "  2. Review AGENT.md and customize if needed"
echo "  3. Start using: ask chief-agent to plan your first milestone"
