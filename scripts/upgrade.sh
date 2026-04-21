#!/usr/bin/env bash
set -eo pipefail

# Chief Agent Framework - Upgrade Script
# Overwrites .agents/ (agents + skills) from template,
# preserving user model values and updating coding agent integrations.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$SOURCE_ROOT/template"

# --- Parse arguments ---

PLAN_MODE=false
MODE="link"
AGENT=""

print_usage() {
  echo "Usage: bash .chief-agent-tmp/scripts/upgrade.sh [--plan] --agent <agent> [--mode link|copy]"
  echo ""
  echo "Options:"
  echo "  --plan                Preview changes without applying (dry run)"
  echo "  -a, --agent <agent>   Specify coding agent (required)"
  echo "  --mode link           Create symlinks (default)"
  echo "  --mode copy           Copy files instead of symlinking"
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
  echo "Examples:"
  echo "  bash .chief-agent-tmp/scripts/upgrade.sh --plan --agent copilot --mode link"
  echo "  bash .chief-agent-tmp/scripts/upgrade.sh --agent claude-code"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan)
      PLAN_MODE=true
      shift
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

if ! echo "$SUPPORTED_AGENTS" | grep -qw "$AGENT"; then
  echo "Error: Unsupported agent '$AGENT'."
  echo "Supported: $SUPPORTED_AGENTS"
  exit 1
fi

# --- Detect target directory ---

if [[ "$(basename "$SOURCE_ROOT")" == .chief-agent-tmp ]]; then
  TARGET_DIR="$(dirname "$SOURCE_ROOT")"
else
  TARGET_DIR="$(pwd)"
fi

# --- Verify existing installation ---

if [[ ! -d "$TARGET_DIR/.agents/agents" ]]; then
  echo "Error: No existing installation found at $TARGET_DIR/.agents/agents"
  echo "Run setup.sh for first-time installation."
  exit 1
fi

# --- Helper functions ---

extract_model() {
  local file="$1"
  grep -m1 '^model:' "$file" 2>/dev/null | sed 's/^model:[[:space:]]*//' || echo ""
}

sed_replace() {
  local pattern="$1"
  local replacement="$2"
  local file="$3"
  local tmp
  tmp=$(mktemp "$TARGET_DIR/.chief-agent-tmp-sed-XXXXXX")
  sed "s/$pattern/$replacement/g" "$file" > "$tmp" && mv "$tmp" "$file"
}

# --- Collect changes ---

echo "Chief Agent Framework Upgrade"
echo "Target: $TARGET_DIR"
echo "Agent: $AGENT"
echo "Mode: $MODE"
if [[ "$PLAN_MODE" == true ]]; then
  echo "Plan mode: preview only (no changes will be applied)"
fi
echo ""
echo "========================================"
echo ""

# Track changes
UPDATES=()
NEW_FILES=()

# --- Compare agent files ---

echo "## Agent definitions (.agents/agents/)"
echo ""

for template_file in "$TEMPLATE_DIR/.agents/agents"/*.md; do
  filename="$(basename "$template_file")"
  local_file="$TARGET_DIR/.agents/agents/$filename"

  if [[ -f "$local_file" ]]; then
    # Strip model: line for content comparison
    local_content=$(grep -v '^model:' "$local_file")
    template_content=$(grep -v '^model:' "$template_file")

    if [[ "$local_content" != "$template_content" ]]; then
      current_model=$(extract_model "$local_file")
      echo "**$filename** — UPDATE (model: preserved as '$current_model')"
      echo ""
      # Show diff excluding model line
      diff <(echo "$local_content") <(echo "$template_content") --label "local/$filename" --label "target/$filename" -u || true
      echo ""
      UPDATES+=("agent:$filename")
    else
      echo "**$filename** — no content changes"
      echo ""
    fi
  else
    echo "**$filename** — NEW"
    echo ""
    NEW_FILES+=("agent:$filename")
  fi
done

# Check for local-only agents
for local_file in "$TARGET_DIR/.agents/agents"/*.md; do
  filename="$(basename "$local_file")"
  template_file="$TEMPLATE_DIR/.agents/agents/$filename"
  if [[ ! -f "$template_file" ]]; then
    echo "**$filename** — local-only (kept)"
    echo ""
  fi
done

# --- Compare skill files ---

echo "========================================"
echo ""
echo "## Skills (.agents/skills/)"
echo ""

# Check template skills
for template_skill_dir in "$TEMPLATE_DIR/.agents/skills"/*/; do
  if [[ ! -d "$template_skill_dir" ]]; then
    continue
  fi
  skill_name="$(basename "$template_skill_dir")"
  local_skill_dir="$TARGET_DIR/.agents/skills/$skill_name"

  if [[ -d "$local_skill_dir" ]]; then
    # Compare all files in the skill
    has_changes=false
    while IFS= read -r -d '' template_file; do
      rel="${template_file#$template_skill_dir}"
      local_file="$local_skill_dir/$rel"
      if [[ -f "$local_file" ]]; then
        if ! diff -q "$local_file" "$template_file" >/dev/null 2>&1; then
          has_changes=true
          echo "**$skill_name/$rel** — UPDATE"
          echo ""
          diff "$local_file" "$template_file" --label "local/$skill_name/$rel" --label "target/$skill_name/$rel" -u || true
          echo ""
          UPDATES+=("skill:$skill_name/$rel")
        fi
      else
        echo "**$skill_name/$rel** — NEW file in existing skill"
        echo ""
        NEW_FILES+=("skill:$skill_name/$rel")
      fi
    done < <(find "$template_skill_dir" -type f -print0)

    if [[ "$has_changes" == false ]]; then
      echo "**$skill_name/** — no changes"
      echo ""
    fi
  else
    echo "**$skill_name/** — NEW skill"
    echo ""
    NEW_FILES+=("skill:$skill_name")
  fi
done

# Check for local-only skills
for local_skill_dir in "$TARGET_DIR/.agents/skills"/*/; do
  if [[ ! -d "$local_skill_dir" ]]; then
    continue
  fi
  skill_name="$(basename "$local_skill_dir")"
  template_skill_dir="$TEMPLATE_DIR/.agents/skills/$skill_name"
  if [[ ! -d "$template_skill_dir" ]]; then
    echo "**$skill_name/** — local-only (kept)"
    echo ""
  fi
done

# --- Summary ---

echo "========================================"
echo ""
echo "## Summary"
echo ""
echo "  Updates: ${#UPDATES[@]}"
echo "  New:     ${#NEW_FILES[@]}"
echo ""

total=$(( ${#UPDATES[@]} + ${#NEW_FILES[@]} ))

if [[ $total -eq 0 ]]; then
  echo "Nothing to upgrade. Already up to date."
  exit 0
fi

# --- Plan mode: stop here ---

if [[ "$PLAN_MODE" == true ]]; then
  echo "Run without --plan to apply these changes."
  exit 0
fi

# --- Apply changes ---

echo "Applying changes..."
echo ""

# Overwrite agent files (preserve model)
for template_file in "$TEMPLATE_DIR/.agents/agents"/*.md; do
  filename="$(basename "$template_file")"
  local_file="$TARGET_DIR/.agents/agents/$filename"

  if [[ -f "$local_file" ]]; then
    current_model=$(extract_model "$local_file")
    cp "$template_file" "$local_file"
    if [[ -n "$current_model" ]]; then
      sed_replace '\${thinking_model}' "$current_model" "$local_file"
      sed_replace '\${coding_model}' "$current_model" "$local_file"
      # Also replace any literal model value from template
      template_model=$(extract_model "$template_file")
      if [[ -n "$template_model" && "$template_model" != "$current_model" ]]; then
        sed_replace "^model:.*" "model: $current_model" "$local_file"
      fi
    fi
    echo "  UPDATE .agents/agents/$filename (model: $current_model)"
  else
    cp "$template_file" "$local_file"
    echo "  ADD .agents/agents/$filename"
  fi
done

# Overwrite/add skills
for template_skill_dir in "$TEMPLATE_DIR/.agents/skills"/*/; do
  if [[ ! -d "$template_skill_dir" ]]; then
    continue
  fi
  skill_name="$(basename "$template_skill_dir")"
  local_skill_dir="$TARGET_DIR/.agents/skills/$skill_name"

  if [[ -d "$local_skill_dir" ]]; then
    rm -rf "$local_skill_dir"
  fi
  cp -r "$template_skill_dir" "$local_skill_dir"
  echo "  UPDATE .agents/skills/$skill_name/"
done


# --- Model replacement for new agent files ---

for local_file in "$TARGET_DIR/.agents/agents"/*.md; do
  if grep -q '\${thinking_model}\|\${coding_model}' "$local_file" 2>/dev/null; then
    filename="$(basename "$local_file")"
    if [[ "$AGENT" == "claude-code" ]]; then
      sed_replace '\${thinking_model}' "opus" "$local_file"
      sed_replace '\${coding_model}' "sonnet" "$local_file"
      echo "  MODEL .agents/agents/$filename: opus/sonnet (auto)"
    else
      echo ""
      echo "  New agent file '$filename' has model placeholders."
      echo "  Please edit manually or re-run setup to configure models."
    fi
  fi
done

# --- Update coding agent integration ---

echo ""
echo "Updating $AGENT integration..."

case "$AGENT" in
  claude-code)
    mkdir -p "$TARGET_DIR/.claude/agents"
    mkdir -p "$TARGET_DIR/.claude/skills"

    if [[ "$MODE" == "link" ]]; then
      # Re-create agent symlinks
      for agent_file in "$TARGET_DIR/.agents/agents"/*.md; do
        filename="$(basename "$agent_file")"
        link_path="$TARGET_DIR/.claude/agents/$filename"
        rm -f "$link_path"
        ln -s "../../.agents/agents/$filename" "$link_path"
        echo "  LINK .claude/agents/$filename"
      done

      # Re-create skill symlinks
      for skill_dir in "$TARGET_DIR/.agents/skills"/*/; do
        if [[ -d "$skill_dir" ]]; then
          skill_name="$(basename "$skill_dir")"
          link_path="$TARGET_DIR/.claude/skills/$skill_name"
          rm -rf "$link_path"
          ln -s "../../.agents/skills/$skill_name" "$link_path"
          echo "  LINK .claude/skills/$skill_name"
        fi
      done

    else
      # Re-copy agent files
      for agent_file in "$TARGET_DIR/.agents/agents"/*.md; do
        filename="$(basename "$agent_file")"
        cp "$agent_file" "$TARGET_DIR/.claude/agents/$filename"
        echo "  COPY .claude/agents/$filename"
      done

      # Re-copy skills
      for skill_dir in "$TARGET_DIR/.agents/skills"/*/; do
        if [[ -d "$skill_dir" ]]; then
          skill_name="$(basename "$skill_dir")"
          rm -rf "$TARGET_DIR/.claude/skills/$skill_name"
          cp -r "$skill_dir" "$TARGET_DIR/.claude/skills/$skill_name"
          echo "  COPY .claude/skills/$skill_name"
        fi
      done

    fi
    ;;

  copilot)
    mkdir -p "$TARGET_DIR/.github/agents"

    if [[ "$MODE" == "link" ]]; then
      for agent_file in "$TARGET_DIR/.agents/agents"/*.md; do
        filename="$(basename "$agent_file")"
        link_path="$TARGET_DIR/.github/agents/$filename"
        rm -f "$link_path"
        ln -s "../../.agents/agents/$filename" "$link_path"
        echo "  LINK .github/agents/$filename"
      done
    else
      for agent_file in "$TARGET_DIR/.agents/agents"/*.md; do
        filename="$(basename "$agent_file")"
        cp "$agent_file" "$TARGET_DIR/.github/agents/$filename"
        echo "  COPY .github/agents/$filename"
      done
    fi
    ;;

  *)
    echo "  $AGENT reads .agents/ directly. No integration files to update."
    ;;
esac

echo ""
echo "Upgrade complete."
