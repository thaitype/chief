# Chief Agent Framework

**Chief Agent Framework** is an agnostic framework agent to enable goal-driven autonomous development with minimal human intervention.

## Setup

```
npx degit thaitype/chief-agent-framework/.chief#v1.0.0 .chief
npx degit thaitype/chief-agent-framework/.claude#v1.0.0 .claude
npx degit thaitype/chief-agent-framework/CLAUDE.md#v1.0.0 CLAUDE.md
```

## Release

- `main` is active usage branch, and `v1.0.0` is the first stable release,

DO NOT USE `main` branch for production, please use tagged release version, e.g. `v1.0.0`.

## Note
- this framework design is first class citizen for Claude Code, however, it should be adaptable to other LLMs with minimal changes.

## Prerequisite

- define clear `CLAUDE.md` as high level rules for chief-agent to follow, checkout template the [CLAUDE.md](./CLAUDE.md)
- define clear highest rules called in `.chief/_rules/_goal/` dir, this is the main goal for chief-agent to achieve.
  - this is optional, it's nice to have, but not required.
- in each milestone dir, define clear `.cheif/_goal/` to specify the milestone goal,

## Usage

1. Ask `chief-agent` to create the contract in rules levels e.g. contract, if exist (optional)
2. Ask `chief-agent` to create the contract in milestone levels
3. Human review contract, and ask `chief-agent` review and revise the contract until satisfied.
4. Ask `chief-agent` to create plan and tasks based on the contract
5. Ask `builder-agent` to implement tasks based on the plan
6. Ask `chief-agent` to review the work, and plan next tasks until milestone goal achieved.
7. Repeat step 2-6 until all milestones are achieved.