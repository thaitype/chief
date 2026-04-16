#!/bin/bash
# setup.sh - Chief Agent framework setup for a new milestone
#
# Scaffolds the milestone structure, populates goals/contracts/rules/tasks
# via chief-agent, then criticizes until the plan is ready to code.
#
# Uses --allowedTools so allowed tools run automatically, human is prompted for the rest.
# Resumes the same session across iterations to preserve context.
#
# Usage: ./setup.sh <milestone-name> [max-iterations] [session-id]
# Example: ./setup.sh milestone-1
#          ./setup.sh milestone-1 5
#          ./setup.sh milestone-1 5 abc12345-...   # resume existing session

set -e

MILESTONE=${1:?"Usage: ./setup.sh <milestone-name> [max-iterations] [session-id]"}
MAX_ITERATIONS=${2:-5}
SESSION_ID=${3:-$(uuidgen)}

CHIEF_DIR=".chief"
MILESTONE_DIR="$CHIEF_DIR/$MILESTONE"
TODO_FILE="$MILESTONE_DIR/_plan/_todo.md"
GOAL_DIR="$MILESTONE_DIR/_goal"
CONTRACT_DIR="$MILESTONE_DIR/_contract"
PLAN_DIR="$MILESTONE_DIR/_plan"
REPORT_DIR="$MILESTONE_DIR/_report"

ALLOWED_TOOLS="Read,Write,Edit,Glob,Grep,Bash,Agent,AskUserQuestion"

# ─── Helpers ─────────────────────────────────────────────────────────────────

PROMPT_FILE=$(mktemp)
trap 'rm -f "$PROMPT_FILE"' EXIT

# Track whether the first call has been made (to switch from --session-id to --resume)
FIRST_CALL=true

run_claude() {
  local prompt="$1"
  if [ "$FIRST_CALL" = true ]; then
    claude --session-id "$SESSION_ID" --allowedTools "$ALLOWED_TOOLS" -p "$prompt"
    FIRST_CALL=false
  else
    claude --resume "$SESSION_ID" --allowedTools "$ALLOWED_TOOLS" -p "$prompt"
  fi
}

render() {
  if command -v glow &>/dev/null; then
    echo "$1" | glow -
  else
    echo "$1"
  fi
}

# ─── Step 0: Scaffold directories ───────────────────────────────────────────

echo "═══ Step 0: Scaffold milestone directory ═══"

mkdir -p "$GOAL_DIR" "$CONTRACT_DIR" "$PLAN_DIR" "$REPORT_DIR"

if [ ! -f "$TODO_FILE" ]; then
  cat > "$TODO_FILE" << 'EOF'
# TODO List

- [ ] Add later
EOF
fi

echo "  Created: $MILESTONE_DIR"
echo "  Session: $SESSION_ID"
echo ""

# ─── Step 1: Populate goals, contracts, rules, and tasks ────────────────────

echo "═══ Step 1: Populate milestone goals, contracts, and plan ═══"

cat > "$PROMPT_FILE" << PROMPT
You are the chief-agent setting up milestone: $MILESTONE

Read the project context:
- @CLAUDE.md
- @$CHIEF_DIR/_rules (global rules, standards, contracts, verification)
- @$MILESTONE_DIR (current milestone state)

Your job is to set up this milestone for execution. Do the following:

1. ASK THE HUMAN (via AskUserQuestion) what the goal of this milestone is,
   unless goal files already exist in $GOAL_DIR with real content.

2. Based on the goal, populate:
   a. $GOAL_DIR/ — write clear, concise goal files describing what this milestone must achieve.
   b. $CONTRACT_DIR/ — write any API contracts, data models, or schema definitions needed.
   c. $CHIEF_DIR/_rules/_standard/ — add or update coding standards if the milestone requires new ones.
   d. $CHIEF_DIR/_rules/_verification/ — add or update verification rules (test commands, lint, build).

3. Break the goal into small, actionable tasks (3-5 tasks max for first batch).
   Write each task spec to $PLAN_DIR/task-N.md with:
   - Clear scope
   - Acceptance criteria
   - Which files to create/modify

4. Update $TODO_FILE with the task checklist.

5. Commit the setup to git with message: "chore($MILESTONE): scaffold goals, contracts, and plan"

If anything is unclear or multiple valid approaches exist, ASK THE HUMAN via AskUserQuestion.
Do NOT guess on architectural decisions.
PROMPT

OUTPUT=$(run_claude "$(cat "$PROMPT_FILE")")
render "$OUTPUT"
echo ""

# ─── Step 2: Criticize loop — is the template ready to code? ────────────────

echo "═══ Step 2: Criticize — is the plan ready to code? ═══"

for i in $(seq 1 $MAX_ITERATIONS); do
  echo "── Critique iteration $i / $MAX_ITERATIONS ──"

  cat > "$PROMPT_FILE" << PROMPT
Continue as the chief-agent reviewing milestone: $MILESTONE

Re-read the current state of:
- @$GOAL_DIR
- @$CONTRACT_DIR
- @$PLAN_DIR
- @$TODO_FILE

CRITICIZE whether this milestone is READY TO CODE. Check:

1. COMPLETENESS
   - Are goals clear and specific enough for a builder-agent to implement without guessing?
   - Are contracts (API, data models) defined where needed?
   - Does each task in $TODO_FILE have a corresponding task spec in $PLAN_DIR/?
   - Does each task spec have clear acceptance criteria?

2. CLARITY
   - Is there any ambiguity that would force a builder-agent to make architectural decisions?
   - Are verification steps defined so the builder knows how to check its own work?

3. MINIMALISM
   - Are there unnecessary tasks that don't serve the goal?
   - Are task specs over-specified with implementation details that should be left to the builder?

If issues are found:
  a. Write critique to $REPORT_DIR/setup-critique-$i.md
  b. Fix the issues directly (update goals, contracts, task specs, todo).
  c. If any fix requires a human decision, ASK via AskUserQuestion.
  d. Commit fixes: "chore($MILESTONE): address setup critique round $i"
  e. Output: NEEDS_ANOTHER_PASS

If the plan is ready to code with no meaningful issues:
  a. Output exactly: READY_TO_CODE
PROMPT

  OUTPUT=$(run_claude "$(cat "$PROMPT_FILE")")
  render "$OUTPUT"

  if echo "$OUTPUT" | grep -q "READY_TO_CODE"; then
    echo ""
    echo "Plan is ready to code."
    break
  fi

  sleep 1
done

echo ""

# ─── Step 3: Criticize — is the design good and not over-engineered? ────────

echo "═══ Step 3: Criticize — design quality check ═══"

for i in $(seq 1 $MAX_ITERATIONS); do
  echo "── Design critique iteration $i / $MAX_ITERATIONS ──"

  cat > "$PROMPT_FILE" << PROMPT
Continue as the chief-agent performing a DESIGN REVIEW for milestone: $MILESTONE

Re-read the current state of:
- @$GOAL_DIR
- @$CONTRACT_DIR
- @$PLAN_DIR
- @$TODO_FILE

Critically review the DESIGN QUALITY. You must be harsh and honest:

1. OVER-ENGINEERING
   - Are there abstractions, patterns, or layers that aren't justified by the goal?
   - Are there tasks that add configurability, extensibility, or flexibility beyond what's needed?
   - Could any task be simplified or removed without hurting the goal?
   - Rule: 3 similar lines of code is better than a premature abstraction.

2. GOAL ALIGNMENT
   - Does every task directly serve the milestone goal?
   - Are there tasks that are "nice to have" but not required?
   - Is the scope minimal — doing exactly what's needed, nothing more?

3. ARCHITECTURE FIT
   - Do the contracts and patterns match CLAUDE.md's architectural rules?
   - Are there conflicts between milestone contracts and global rules?
   - Is the tech stack appropriate for the goal, or is it overkill?

4. PRACTICAL READINESS
   - Can a builder-agent pick up task-1 right now and start coding?
   - Are dependencies between tasks clear?
   - Is the task order logical?

If issues are found:
  a. Write critique to $REPORT_DIR/design-critique-$i.md
  b. Fix: simplify tasks, remove over-engineering, tighten scope.
  c. If simplification requires a human decision, ASK via AskUserQuestion.
  d. Commit: "chore($MILESTONE): simplify design, critique round $i"
  e. Output: NEEDS_ANOTHER_PASS

If the design is clean, minimal, goal-aligned, and not over-engineered:
  a. Write $REPORT_DIR/design-approval.md with a brief summary of why the design is approved.
  b. Commit: "chore($MILESTONE): design approved"
  c. Output exactly: DESIGN_APPROVED
PROMPT

  OUTPUT=$(run_claude "$(cat "$PROMPT_FILE")")
  render "$OUTPUT"

  if echo "$OUTPUT" | grep -q "DESIGN_APPROVED"; then
    echo ""
    echo "Design approved. Milestone $MILESTONE is ready for ./start.sh $MILESTONE"
    exit 0
  fi

  sleep 1
done

echo ""
echo "Design review did not converge after $MAX_ITERATIONS iterations."
echo "Run ./setup.sh $MILESTONE again or review manually."
exit 1
