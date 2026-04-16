#!/bin/bash
# start.sh - Chief Agent autonomous loop for Claude Code
#
# Resumes the same session across iterations to preserve context.
#
# Usage: ./start.sh <milestone-name> [max-iterations] [session-id]
# Example: ./start.sh milestone-1
#          ./start.sh milestone-1 20
#          ./start.sh milestone-1 20 abc12345-...   # resume existing session

set -e

MILESTONE=${1:?"Usage: ./start.sh <milestone-name> [max-iterations] [session-id]"}
MAX_ITERATIONS=${2:-10}
SESSION_ID=${3:-$(uuidgen)}
SIGIL="<promise>GOAL_ACHIEVED</promise>"

CHIEF_DIR=".chief"
MILESTONE_DIR="$CHIEF_DIR/$MILESTONE"
TODO_FILE="$MILESTONE_DIR/_plan/_todo.md"
GOAL_DIR="$MILESTONE_DIR/_goal"

# Validate milestone exists
if [ ! -d "$MILESTONE_DIR" ]; then
  echo "Error: Milestone directory '$MILESTONE_DIR' not found."
  echo "Available milestones:"
  ls -d "$CHIEF_DIR"/milestone-* 2>/dev/null || echo "  (none)"
  exit 1
fi

if [ ! -f "$TODO_FILE" ]; then
  echo "Error: TODO file '$TODO_FILE' not found."
  exit 1
fi

# ─── Helpers ─────────────────────────────────────────────────────────────────

PROMPT_FILE=$(mktemp)
trap 'rm -f "$PROMPT_FILE"' EXIT

# Track whether the first call has been made (to switch from --session-id to --resume)
FIRST_CALL=true

run_claude() {
  local prompt="$1"
  if [ "$FIRST_CALL" = true ]; then
    claude --session-id "$SESSION_ID" --dangerously-skip-permissions -p "$prompt"
    FIRST_CALL=false
  else
    claude --resume "$SESSION_ID" --dangerously-skip-permissions -p "$prompt"
  fi
}

render() {
  if command -v glow &>/dev/null; then
    echo "$1" | glow -
  else
    echo "$1"
  fi
}

# ─── Main loop ───────────────────────────────────────────────────────────────

echo "Starting Chief Agent Loop..."
echo "  Milestone: $MILESTONE"
echo "  Max iterations: $MAX_ITERATIONS"
echo "  Session: $SESSION_ID"
echo ""

for i in $(seq 1 $MAX_ITERATIONS); do
  echo "═══ Iteration $i / $MAX_ITERATIONS ═══"

  if [ "$FIRST_CALL" = true ]; then
    # First iteration: full context prompt
    cat > "$PROMPT_FILE" << PROMPT
You are the chief-agent. Your milestone is: $MILESTONE

Read the project context:
- @CLAUDE.md
- @$CHIEF_DIR/_rules
- @$GOAL_DIR
- @$MILESTONE_DIR/_contract
- @$TODO_FILE

PHASE 1 — Execute ONE pending task:
1. Read CLAUDE.md, rules, goals, contracts, and the TODO list.
2. Find the FIRST unchecked task in $TODO_FILE. Execute ONLY this one task.
3. If a task spec does not exist yet, create it in $MILESTONE_DIR/_plan/.
4. Delegate implementation: implement the task following .chief/_rules/_standard.
5. Run verification (type check, lint, tests) per .chief/_rules/_verification.
6. Mark the task as [x] in $TODO_FILE.
7. COMMIT to git immediately with message: "feat($MILESTONE): complete <task-name>"
   - Stage all changed files related to this task.
   - You MUST commit before doing anything else.
8. If there are still unchecked tasks, stop here. Do NOT proceed to Phase 2.
9. IMPORTANT: Do NOT execute more than one task per iteration. One task = one commit = one iteration.

PHASE 2 — Criticize and iterate (only when ALL tasks in $TODO_FILE are [x]):
1. Re-read the milestone goals in $GOAL_DIR carefully.
2. Review the current codebase and completed work critically.
3. Ask yourself: Does the current state FULLY achieve the milestone goals?
   - Are there gaps, missing edge cases, incomplete features, or quality issues?
   - Is the code robust, tested, and production-ready per the goals?
4. If there are gaps or improvements needed:
   a. Write a critique summary to $MILESTONE_DIR/_report/critique-iteration-$i.md
   b. Add NEW unchecked tasks to $TODO_FILE addressing the gaps.
   c. Stop here — next iteration will execute them.
5. If the goals are truly and fully achieved with no meaningful gaps:
   a. Write a final report to $MILESTONE_DIR/_report/final-report.md
   b. Output exactly: $SIGIL
PROMPT
  else
    # Subsequent iterations: short resume prompt
    cat > "$PROMPT_FILE" << PROMPT
Continue as the chief-agent for milestone: $MILESTONE — iteration $i.

Re-read the current state:
- @$TODO_FILE

Execute the next unchecked task (Phase 1), or if all tasks are done, run Phase 2 (criticize).

Reminder:
- Phase 1: implement ONE task, verify, mark [x], commit, then stop.
- Phase 2 (all [x]): criticize vs goals, add new tasks or output: $SIGIL
PROMPT
  fi

  OUTPUT=$(run_claude "$(cat "$PROMPT_FILE")")
  render "$OUTPUT"

  # Check if the agent signaled goal achieved
  if echo "$OUTPUT" | grep -q "$SIGIL"; then
    echo ""
    echo "Milestone $MILESTONE goal fully achieved."
    exit 0
  fi

  sleep 2
done

echo ""
echo "Reached max iterations ($MAX_ITERATIONS) without full goal achievement."
exit 1
