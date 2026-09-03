#!/usr/bin/env bash
set -euo pipefail

# Chief Framework - Setup Script
# Installs AGENTS.md (and, for Claude Code, a CLAUDE.md pointer) into a project.
# v5 has no .agents/agents/ subagent roster to install - see
# docs/design/v5-ai-workflow.md, "All persistent subagents are deprecated".
# .chief/ is created lazily by chief-* skills at runtime.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$SOURCE_ROOT/template"

# --- Parse arguments ---

MODE="link"
AGENT=""

print_usage() {
  echo "Usage: bash scripts/setup.sh [--mode link|copy] --agent <agent>"
  echo ""
  echo "Agents:"
  echo "  claude-code   Claude Code (CLAUDE.md -> AGENTS.md)"
  echo "  opencode      OpenCode (reads AGENTS.md directly)"
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
  echo "  --mode link           Create a CLAUDE.md symlink for Claude Code (default)"
  echo "  --mode copy           Copy AGENTS.md to CLAUDE.md instead of symlinking"
  echo ""
  echo "Example:"
  echo "  bash .chief-agent-tmp/scripts/setup.sh --agent claude-code"
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

echo "Installing Chief Framework into: $TARGET_DIR"
echo "Agent: $AGENT"
echo "Mode: $MODE"
echo ""

# --- Helper functions ---

CHIEF_FRAMEWORK_MARKER="<!-- chief-framework:begin -->"
CHIEF_FRAMEWORK_END="<!-- chief-framework:end -->"

install_agents_md() {
  local src="$1"
  local dest="$2"

  if [[ ! -f "$dest" ]]; then
    cp "$src" "$dest"
    echo "  WRITE AGENTS.md (fresh)"
    return
  fi

  if grep -qF "$CHIEF_FRAMEWORK_MARKER" "$dest"; then
    echo "  SKIP AGENTS.md (chief framework section already present)"
    return
  fi

  {
    echo ""
    echo "$CHIEF_FRAMEWORK_MARKER"
    cat "$src"
    echo "$CHIEF_FRAMEWORK_END"
  } >> "$dest"
  echo "  APPEND AGENTS.md (chief framework section appended)"
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
    cp "$src" "$dest"
    echo "  COPY $name"
  fi
}

# --- Step 1: Install AGENTS.md ---

echo "Installing AGENTS.md..."
install_agents_md "$TEMPLATE_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
echo ""

# --- Step 2: Agent-specific setup ---

case "$AGENT" in
  claude-code)
    echo "Setting up Claude Code integration..."

    if [[ "$MODE" == "link" ]]; then
      create_symlink "AGENTS.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md -> AGENTS.md"
    else
      copy_to_dest "$TARGET_DIR/AGENTS.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md (copy of AGENTS.md)"
    fi
    ;;

  *)
    echo "Setting up $AGENT integration..."
    echo "  $AGENT reads AGENTS.md directly. No additional file setup needed."
    ;;
esac

echo ""
echo "Done! Chief Framework installed successfully."
echo ""
echo "Next steps:"
echo "  1. Run /chief-init to bootstrap .chief/project.md"
echo "  2. Review AGENTS.md and customize if needed"
echo "  3. Start using: /chief-plan"
