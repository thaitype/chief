---
name: chief-grill
description: Deep grill that interviews the user one question at a time AND verifies each answer against the codebase via background `answer-verifier-agent` calls. Catches factual conflicts, contradictions with prior decisions, and unfounded assumptions inline. Persists the session to `.chief/_grill/opened/NNNN-topic.md` so it survives context compaction. Use when the user wants a stress-tested grill — when stakes are high, when claims must be cross-checked against actual repo state, or when the topic spans many decisions. Heavier than `/grill-me`; prefer this when correctness matters more than speed.
---

You are running a verified grill session. This is `/grill-me` with two extra things bolted on:

1. **Per-question self-review (in-skill).** Before recommending an answer, you critique your own pick. After the user answers, you stress-test their answer.
2. **Per-question background verification by `answer-verifier-agent`.** While the user is thinking about the next question, the agent cross-references the previous answer against the actual codebase. Findings surface as a sidebar.
3. **Persistent session log.** All state lives in `.chief/_grill/opened/NNNN-topic.md`. Survives compaction and `/clear`.

Ask one question at a time. Wait for the user. Provide a recommended answer with each question.

## Steps

### 1. Pre-flight

Inspect (do not create yet):

- `.chief/` — exists?
- `.chief/_grill/` — exists?
- `.chief/_grill/opened/` and `.chief/_grill/closed/` — exist?
- Any unresolved sessions in `.chief/_grill/opened/`?

### 2. Resume or start fresh

If `.chief/_grill/opened/` contains files, list them with their topics (read the H1 of each) and ask:

> Found N open grill session(s). Resume one, or start fresh?
> 1. Resume `0003-payment-sdk` (12 resolved, 3 open)
> 2. Resume `0007-auth` (5 resolved, 0 open — ready for final review)
> 3. Start fresh

If the user picks resume → load that file as the session log, jump to step 5.
If the user picks fresh → continue to step 3.
If `opened/` is empty or missing → continue to step 3.

### 3. Topic and slug

Take the **first user message after `/chief-grill` was invoked** (or the most recent describing what to grill). Derive a kebab-case topic slug from it (3–5 words max). Show it to the user:

> Topic: `payment-sdk`. Continue, or pick a different slug?

If the user overrides, use their slug.

### 4. Create session log (deferred scaffolding)

Now scaffold the directories that don't exist yet:

1. Create `.chief/_grill/`, `.chief/_grill/opened/`, `.chief/_grill/closed/` as needed.
2. Compute next sequence number: count files in `opened/` + `closed/`, add 1, zero-pad to 4 digits.
3. Create `.chief/_grill/opened/NNNN-<slug>.md` with this initial content:

   ```markdown
   # Grill: <topic title-cased>

   ## Open Questions

   ## Resolved

   ## Final Review
   ```

### 5. Grill loop

For each question, do this:

#### 5a. Pick the next question

Pick from the **Open Questions** section if anything is queued; otherwise generate the next question by walking the design tree from where you are.

#### 5b. Self-critique your recommendation

Before showing the question to the user, internally:

- Form a recommended answer.
- Ask yourself: what assumptions am I making? what could be wrong with this pick? what alternatives exist?
- Surface the recommendation **with** the self-critique. Format:

  > **Q<n>: <question>**
  >
  > Options:
  > - (A) ...
  > - (B) ...
  >
  > **Recommendation:** (A) — <one-line reason>.
  >
  > **Self-check:** <one-sentence honest critique of the recommendation, e.g. "Assumes the team has Postgres ops experience — confirm before locking.">
  >
  > Pick A/B/C, override, or push back?

#### 5c. Render any pending sidebar

If the previous question's background verification has returned a finding (verdict `concern` or `conflict`), render it as a sidebar **before** the new question:

> **Sidebar (Q<prev>):** <finding>
> *Suggested action:* <suggested-action>
> *Evidence:*
> - <evidence line>
>
> Address now, or continue?

If the user picks "address now," reopen Q<prev>. Otherwise carry on.

If verdict was `ok`, do not render anything.

#### 5d. User answers

Wait for the user. Accept their pick or override.

#### 5e. Stress-test the answer (in-skill, immediate)

Before writing to the log, briefly stress-test:

- Does this conflict with any prior resolved decision in the session log?
- Does it close off branches we might still need?
- Are there hidden assumptions to call out?

If something is off, raise it inline before recording. Otherwise proceed.

#### 5f. Record in the session log

Update the session log:

- Move the question to **Resolved** with: `Q<n>: <question> → <decision>. Why: <reason>.`
- Add any newly opened follow-up questions to **Open Questions** with `(depends on: Q<n>)` notes if relevant.

#### 5g. Fire background verifier

Spawn `answer-verifier-agent` in the background with:

- **question:** the question text
- **answer:** the user's resolved decision
- **prior-context:** the **Resolved** section of the log (excluding the question just asked)
- **session-log-path:** the full path to the session log file

Use the Agent tool with `subagent_type: "answer-verifier-agent"` and `run_in_background: true`. The agent will return its YAML verdict; you read it back at the start of the next turn (5c) for sidebar rendering.

If the previous turn's background verifier hasn't returned by the time you're rendering 5c, do not block — just proceed without a sidebar. Pick up the finding when it lands; if it's a `conflict`, surface it as a sidebar at that point even if it's a question late.

#### 5h. Loop

Go back to 5a unless the user asks to wrap up.

### 6. Closing the session (explicit)

When the user says "done" / "close this grill" / "wrap up" / similar:

1. Run **final review**: invoke `answer-verifier-agent` with `mode: final` and the session log path. Wait for its verdict (foreground this one).
2. Append the verdict's `finding` and `evidence` to the **Final Review** section of the log.
3. If the final-review verdict is `concern` or `conflict`, surface it and ask: "Address this and stay open, or close anyway?" — respect the user's choice.
4. On close confirmation: move `.chief/_grill/opened/NNNN-<slug>.md` → `.chief/_grill/closed/NNNN-<slug>.md`.
5. Tell the user the closed path. Stop.

If the user says "stop" / "pause" / leaves without closing → leave the file in `opened/`. They can resume later.

## Important rules

- ALWAYS recommend an answer. Never ask without proposing.
- ALWAYS show a self-check next to the recommendation.
- ONE question at a time. Compound questions are forbidden.
- NEVER skip the session log update — that file is the source of truth, not the conversation.
- NEVER block on the background verifier. If it hasn't returned, continue without the sidebar.
- NEVER auto-close a session. Closing is always user-initiated.
- NEVER move stale opened sessions. They sit until the user closes or deletes them manually.
- The agent's verdict is YAML — parse it, don't paraphrase. Render sidebars only for `concern` and `conflict`.

## Differences from `/grill-me`

- `/grill-me` is single-pass, in-context only, no verification. Light and fast.
- `/chief-grill` adds self-critique, codebase verification, and a persistent log. Heavier — use when stakes are high or the topic spans many cross-checked decisions.
