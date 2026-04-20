#!/usr/bin/env bash
set -euo pipefail

# Chief Agent Framework - Setup Script
# Installs .agents/, .chief/, and AGENTS.md into a project,
# then sets up agent-specific integrations.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(dirname "$SCRIPT_DIR")"

# --- Parse arguments ---

MODE="link"
AGENT=""

print_usage() {
  echo "Usage: bash scripts/setup.sh [--mode link|copy] --agent <agent>"
  echo ""
  echo "Agents:"
  echo "  claude-code   Claude Code (CLAUDE.md + .claude/agents/ and .claude/skills/)"
  echo "  opencode      OpenCode (reads AGENTS.md and .agents/ directly)"
  echo "  codex         Codex CLI (reads AGENTS.md directly)"
  echo "  cursor        Cursor (reads AGENTS.md directly)"
  echo "  copilot       GitHub Copilot (.github/agents/)"
  echo "  gemini-cli    Gemini CLI (reads AGENTS.md directly)"
  echo "  amp           Amp (reads AGENTS.md directly)"
  echo "  windsurf      Windsurf (reads AGENTS.md directly)"
  echo "  kiro          Kiro (reads AGENTS.md directly)"
  echo "  aider         Aider (reads AGENTS.md directly)"
  echo ""
  echo "Options:"
  echo "  -a, --agent <agent>   Specify coding agent (required)"
  echo "  --mode link           Create symlinks (default)"
  echo "  --mode copy           Copy files instead of symlinking"
  echo ""
  echo "Example:"
  echo "  bash .chief-agent-tmp/scripts/setup.sh --agent claude-code"
  echo "  bash .chief-agent-tmp/scripts/setup.sh --agent copilot"
  echo "  bash .chief-agent-tmp/scripts/setup.sh --agent cursor"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
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

if ! echo "$SUPPORTED_AGENTS" | grep -qw "$AGENT"; then
  echo "Error: Unsupported agent '$AGENT'."
  echo "Supported: $SUPPORTED_AGENTS"
  exit 1
fi

# --- Windows symlink detection ---

check_symlink_support() {
  local test_target="$1"
  local test_link="${test_target}.symlink-test-$$"
  if ln -s "$test_target" "$test_link" 2>/dev/null; then
    rm -f "$test_link"
    return 0
  else
    rm -f "$test_link" 2>/dev/null
    return 1
  fi
}

IS_WINDOWS=false
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=true ;;
esac

if [[ "$MODE" == "link" && "$IS_WINDOWS" == true ]]; then
  if ! check_symlink_support "$(dirname "${BASH_SOURCE[0]}")"; then
    echo "⚠️  Symlinks not supported on this Windows environment."
    echo "   Enable Developer Mode in Windows Settings, or use --mode copy."
    echo "   Falling back to copy mode."
    MODE="copy"
  fi
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

merge_dir() {
  local src="$1"
  local dest="$2"
  local name="$3"

  if [[ ! -d "$dest" ]]; then
    cp -r "$src" "$dest"
    echo "  COPY $name/"
  else
    # File-level merge: copy new files, skip existing
    local count=0
    while IFS= read -r -d '' file; do
      local rel="${file#$src/}"
      local dest_file="$dest/$rel"
      local dest_dir="$(dirname "$dest_file")"
      if [[ ! -e "$dest_file" ]]; then
        mkdir -p "$dest_dir"
        if [[ -d "$file" ]]; then
          mkdir -p "$dest_file"
        else
          cp "$file" "$dest_file"
        fi
        count=$((count + 1))
      fi
    done < <(find "$src" -mindepth 1 \( -type f -o -type d \) -print0)
    if [[ $count -gt 0 ]]; then
      echo "  MERGE $name/ ($count new files added)"
    else
      echo "  SKIP $name/ (all files already exist)"
    fi
  fi
}

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

# --- Model replacement for non-Claude Code agents ---

prompt_and_replace_models() {
  local target_dir="$1"
  local agent_dir="$2"  # e.g. .github/agents or .agents/agents

  echo ""
  echo "Model configuration:"
  echo "  Claude Code uses 'opus' (thinking) and 'sonnet' (coding) by default."
  echo "  For other agents, you need to specify equivalent model names."
  echo ""
  read -rp "  Thinking Model (for chief-agent, e.g. o3, gemini-2.5-pro): " THINKING_MODEL
  read -rp "  Coding Model (for builder/tester/review-plan, e.g. gpt-4.1, gemini-2.5-flash): " CODING_MODEL

  if [[ -z "$THINKING_MODEL" || -z "$CODING_MODEL" ]]; then
    echo "  ⚠️  No models specified. Keeping defaults (opus/sonnet). You can edit the agent files manually."
    return
  fi

  echo ""
  echo "  Replacing models..."

  # Replace model in agent files
  for agent_file in "$target_dir/$agent_dir"/*; do
    if [[ -f "$agent_file" ]]; then
      local filename="$(basename "$agent_file")"
      if [[ "$filename" == *"chief-agent"* ]]; then
        sed -i '' "s/^model: opus$/model: $THINKING_MODEL/" "$agent_file" 2>/dev/null || \
        sed -i "s/^model: opus$/model: $THINKING_MODEL/" "$agent_file"
        echo "    $filename: model → $THINKING_MODEL"
      else
        sed -i '' "s/^model: sonnet$/model: $CODING_MODEL/" "$agent_file" 2>/dev/null || \
        sed -i "s/^model: sonnet$/model: $CODING_MODEL/" "$agent_file"
        echo "    $filename: model → $CODING_MODEL"
      fi
    fi
  done
}

# --- Step 1: Copy core files ---

echo "Copying core files..."
merge_dir "$SOURCE_ROOT/.agents" "$TARGET_DIR/.agents" ".agents"
copy_dir "$SOURCE_ROOT/.chief" "$TARGET_DIR/.chief" ".chief"
copy_file "$SOURCE_ROOT/AGENTS.md" "$TARGET_DIR/AGENTS.md" "AGENTS.md"
echo ""

# --- Step 2: Agent-specific setup ---

case "$AGENT" in
  claude-code)
    echo "Setting up Claude Code integration..."
    mkdir -p "$TARGET_DIR/.claude/agents"
    mkdir -p "$TARGET_DIR/.claude/skills"

    if [[ "$MODE" == "link" ]]; then
      # Symlink CLAUDE.md to AGENTS.md
      create_symlink "AGENTS.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md -> AGENTS.md"

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
      # Copy CLAUDE.md from AGENTS.md
      copy_to_dest "$TARGET_DIR/AGENTS.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md (copy of AGENTS.md)"

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

  copilot)
    echo "Setting up GitHub Copilot integration..."
    mkdir -p "$TARGET_DIR/.github/agents"

    if [[ "$MODE" == "link" ]]; then
      # Symlink individual agent files
      for agent_file in "$TARGET_DIR/.agents/agents"/*.md; do
        filename="$(basename "$agent_file")"
        create_symlink "../../.agents/agents/$filename" "$TARGET_DIR/.github/agents/$filename" ".github/agents/$filename"
      done
    else
      # Copy individual agent files
      for agent_file in "$TARGET_DIR/.agents/agents"/*.md; do
        filename="$(basename "$agent_file")"
        copy_to_dest "$agent_file" "$TARGET_DIR/.github/agents/$filename" ".github/agents/$filename"
      done
    fi

    # Prompt for model replacement
    prompt_and_replace_models "$TARGET_DIR" ".github/agents"
    ;;

  *)
    echo "Setting up $AGENT integration..."
    echo "  $AGENT reads AGENTS.md and .agents/ directly. No additional file setup needed."

    # Prompt for model replacement in .agents/agents/
    prompt_and_replace_models "$TARGET_DIR" ".agents/agents"
    ;;
esac

# --- Step 3: Write metadata ---

echo "Writing metadata..."
cat > "$TARGET_DIR/.chief/.metadata.json" <<METAEOF
{
  "agent": "$AGENT",
  "mode": "$MODE"
}
METAEOF
echo "  WRITE .chief/.metadata.json"

echo ""
echo "Done! Chief Agent Framework installed successfully."
echo ""
echo "Next steps:"
echo "  1. Edit .chief/project.md with your project details"
echo "  2. Review AGENTS.md and customize if needed"
echo "  3. Start using: ask chief-agent to plan your first milestone"
