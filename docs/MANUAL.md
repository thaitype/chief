# Chief Agent Framework — Quick Reference

## Skills (Recommended)

| Skill | Description |
|-------|-------------|
| `/chief-plan` | Plan a milestone step-by-step with review gates |
| `/chief-autopilot` | Run milestone on full autopilot (auto mode) |
| `/chief-autopilot safe` | Run milestone with stops on ambiguity |
| `/chief-retro` | Retrospective — check coverage, summarize, propose rules |
| `/dump-commit` | Quick commit all files with 1-line message |
| `/dump-commit fix auth` | Quick commit with custom message |
| `/grill-design` | Stress-test a design, idea, or decision tree |
| `/chief-grill` | Deep grill with codebase verification + session log |
| `/chief-rule` | Add a rule to `.chief/_rules/` |
| `/chief-init` | Bootstrap `.chief/project.md` |

## Manual Agent Prompts

### Builder-Agent

```
current state: <explain what is being worked on>

start builder-agent

Let builder-agent implement and fix issues autonomously.
Escalate to chief-agent only when blocked by design decisions, scope limits, or negative progress.

Chief-agent acts as reviewer and decision-maker when escalation happens.
```

### Chief-Agent

```
current milestone: milestone-1
current state: <explain what is being worked on>

start chief-agent

Let chief-agent review and plan work.
Escalate to human only when blocked by design decisions, scope limits, or ambiguities.
```

### Tester-Agent (user-triggered only)

```
current milestone: milestone-1
current state: builder finished task-1, need integration testing

start tester-agent

Validate the implementation against real environment behavior.
Report findings back — do not fix code.
```

> Tester-agent is ONLY used when you explicitly request it. It is not part of the automatic flow.

## Example Workflows

**Full planning + autopilot:**
```
/chief-plan          → goals → contracts → TODO → approve
/chief-autopilot         → runs all tasks
/chief-retro             → review + propose rule updates
```

**Quick prototyping:**
```
/chief-autopilot         → chief figures out tasks from goals/contracts
/dump-commit wip: progress
```

**Replan mid-milestone:**
```
current milestone: milestone-1
current state: contract changed, need to replan

start chief-agent
```
