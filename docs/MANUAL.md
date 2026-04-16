# Chief Agent Framework

## Builder-Agent

default prompt:

```
current state: <explain what is being worked on>

start builder-agent

Let builder-agent implement and fix issues autonomously.
Escalate to chief-agent only when blocked by design decisions, scope limits, or negative progress.

Chief-agent acts as reviewer and decision-maker when escalation happens.
```

### Current State

Explain what is being worked on e.g.
- the type is error
- Start working on task-1

## Chief-Agent

```
current milestone: milestone-1
current state: <explain what is being worked on>

start chief-agent

Let chief-agent review and plan work.
Escalate to human only when blocked by design decisions, scope limits, or ambiguities.
```

### Current Milestone

explain current milestone e.g. milestone-1

### Current State

explain what is being worked on e.g.
- I've reivewed and recheck the work, it can work as expected
- Start planning next tasks

## Example Prompt

```
current milestone: milestone-1
current state: due to contract is changed, we need to replan the milestone-1 tasks again, please look at the todo file and plan, revise plan to fit the new contract.

start chief-agent

Let chief-agent review and plan work.
Escalate to human only when blocked by design decisions, scope limits, or ambiguities.
```
