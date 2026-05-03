---
name: chief-plan
description: Plan a new milestone or extend an existing one step-by-step with review gates. Starts with a grill-design session to clarify requirements, then walks through goal → contract → todo → task specs, pausing for user approval at each step.
---

You are planning a milestone. Follow this process strictly, one phase at a time. **Never skip ahead.**

---

## Before You Start: New vs Existing Milestone

Determine whether you are:

- **Creating a new milestone** — no existing `_goal/`, `_contract/`, or `_plan/` files exist yet.
- **Extending an existing milestone** — files already exist in the milestone directory.

If extending an existing milestone:
1. Read all existing `_goal/`, `_contract/`, and `_plan/` files first.
2. During each phase, decide whether the new content is:
   - **Partial overlap** with an existing file → **update** that file (add/modify sections).
   - **Different scope** from all existing files → **create a new file** alongside existing ones.
3. After writing, verify there are **no conflicts** between the new and existing content within the same bucket. If a conflict exists, resolve it before presenting to the user.
4. Verify the new content **respects the rules hierarchy**: AGENTS.md > `.chief/_rules` > milestone goals. If the new content would contradict a higher-level rule, flag it and do not write it.

---

## Phase 0: Grill-Me Session

**NEVER SKIP THIS PHASE.** Even if goals or contracts already exist, you must grill the user first. Existing files do not substitute for a grill-design session — they may contain outdated or wrong assumptions that only surface through questioning.

Before writing anything, run a grill-design session to clarify requirements:

- Interview the user relentlessly about every aspect of this milestone until you reach a shared understanding.
- Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.
- For each question, provide your recommended answer.
- Ask the questions one at a time.
- If a question can be answered by exploring the codebase, explore the codebase instead.

When extending an existing milestone, include questions about:
- How the new work relates to existing goals and contracts.
- Whether any existing goals or contracts need revision.
- Whether existing tasks are affected or should be re-prioritized.

When the grill-design session is complete, summarize the key decisions and confirm with the user before moving on.

---

## Phase 1: Review and Write Goals

**NEVER SKIP THIS PHASE.** Even if goal files already exist, you must present them to the user for review and approval before moving to contracts.

Based on the grill-design session, write or update milestone goal files under `.chief/<milestone>/_goal/`.

If goals already exist:
- Read each goal file and verify it still matches the decisions from Phase 0.
- If the grill-design session revealed that an existing goal is wrong or incomplete, update it now.
- Present both existing and new/modified goals to the user.

If extending:
- Update existing goal files when the new scope overlaps.
- Create new goal files when the scope is distinct.
- Verify: no goal contradicts another goal in the same milestone, and no goal contradicts `.chief/_rules/_goal/` or `AGENTS.md`.

**STOP.** Present the goals (new and modified) to the user. Highlight what changed vs what already existed. Wait for explicit approval before proceeding.

---

## Phase 2: Write Contracts

Write or update milestone contracts under `.chief/<milestone>/_contract/`.

If extending:
- Update existing contract files when the new scope overlaps (e.g., adding fields to an existing schema).
- Create new contract files when the scope is distinct (e.g., a new API endpoint).
- Verify: no contract contradicts another contract in the same milestone, and no contract contradicts `.chief/_rules/_contract/` or `AGENTS.md`.

**STOP.** Present the contracts (new and modified) to the user. Highlight what changed vs what already existed. Wait for explicit approval before proceeding.

---

## Phase 3: Write TODO

Write or update `.chief/<milestone>/_plan/_todo.md` with 3–5 new tasks.

If extending:
- Append new tasks below existing ones (do not remove or reorder completed tasks).
- If new work invalidates or supersedes an existing uncompleted task, mark it clearly (e.g., `- [ ] ~~task-2: old scope~~ → superseded by task-5`).
- Task numbering continues from the last existing task number.

**STOP.** Present the updated todo list to the user. Highlight new and modified entries. Wait for explicit approval before proceeding.

---

## Phase 4: Write Task Specs (optional)

Ask the user: "Write detailed task specs, or skip?"

If **skip** → skill ends. Builder-agent will work from the TODO + goals + contracts.

If **write** → write detailed task specs under `.chief/<milestone>/_plan/task-<n>.md`.

If extending:
- Only write specs for newly added tasks.
- If a new task modifies behavior covered by an existing task spec, reference that spec and explain how it differs.

**STOP.** Present the task specs to the user. Wait for explicit approval before delegating to builder-agent.

---

## Conflict Resolution Rules

At every phase, before presenting to the user, verify:

1. **Intra-bucket consistency** — no two files within the same bucket (`_goal/`, `_contract/`, `_plan/`) contradict each other.
2. **Cross-bucket consistency** — goals, contracts, and tasks align with each other (e.g., a task doesn't reference a contract that doesn't exist).
3. **Hierarchy compliance** — nothing contradicts a higher-level rule:
   - `AGENTS.md` overrides everything.
   - `.chief/_rules/**` overrides milestone-level content.
   - Milestone `_goal/` is the lowest authority.

If a conflict is detected:
- Flag it explicitly to the user with both sides of the conflict.
- Propose a resolution.
- Do not proceed until the conflict is resolved.

---

## Backtrack Rule

If user feedback during a later phase reveals that an earlier phase's output is wrong or incomplete, you MUST go back and fix the earlier phase first. Do NOT patch the current phase to work around a broken earlier phase.

Examples:
- Contract review reveals a goal assumption is wrong → go back to Phase 1, fix the goal, get approval, then return to Phase 2.
- TODO review reveals a contract is missing a field → go back to Phase 2, fix the contract, get approval, then return to Phase 3.

The phase order is strict in both directions: forward (never skip ahead) and backward (always fix upstream first).

---

## General Rules

- Follow the rules hierarchy: AGENTS.md > .chief/_rules > milestone goals.
- If the user rejects or modifies anything at a gate, revise before proceeding.
- Do not delegate to builder-agent or tester-agent during this skill. This skill is planning only.
