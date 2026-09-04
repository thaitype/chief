# Chief ⚔️

![](https://img.shields.io/badge/chief_version-v5.0.0-blue)

**[English](README.md)** | **ไทย**

Workflow ที่มีโครงสร้างสำหรับ AI coding agents ติดตั้งในโปรเจกต์ใดก็ได้ กำหนด rules ครั้งเดียว แล้วหยุดอธิบาย codebase ซ้ำทุก chat

> Chief เป็นส่วนหนึ่งของระบบนิเวศ [chief-tribe](https://github.com/thaitype/chief-tribe) โดยใช้ [sage](https://github.com/thaitype/sage) เป็น behavioral baseline

## ทำไมถึงมี Chief

ทุกโปรเจกต์มี context — การตัดสินใจเมื่อหกเดือนที่แล้ว, workaround ที่แปลกๆ, เหตุผลที่ว่า "ทำไมถึงทำแบบนี้" สิ่งเหล่านี้อยู่ในหัวคุณ ทุก chat ใหม่เริ่มต้นจากศูนย์ คุณก็อธิบายซ้ำ แล้วก็ซ้ำอีก

Chief หยุดสิ่งนั้น ให้ทุกโปรเจกต์มีรูปร่างเดิม — `AGENTS.md` สำหรับ rules, `.chief/_rules/` สำหรับ standards, `.chief/story-N/` สำหรับงานปัจจุบัน Agents รู้ว่าจะอ่านที่ไหนและเขียนที่ไหน prompt ของคุณย่อเหลือแค่ประโยคเดียว

→ [ทำไมถึงมี Chief](docs/manual/explanation/why-chief.md)

## เริ่มต้นด่วน

**ขั้นที่ 1 — ติดตั้ง skills:**

```bash
npx skills@latest add thaitype/chief
```

เลือก skills ที่ต้องการ ต้องมี `chief-install` รวมอยู่ด้วย

**ขั้นที่ 2 — รัน `/chief-install` ใน agent ของคุณ:**

```
/chief-install
```

จะถามว่าใช้ coding agent ตัวไหน และถ้าเป็น Claude Code จะ symlink หรือ copy แค่นั้นเอง — v5 ไม่มี subagent roster ให้ต้อง wire แล้ว

**ขั้นที่ 3 — ตั้งค่า project context (ไม่บังคับ):**

```
/chief-init
```

สัมภาษณ์เรื่อง stack และ dev commands แล้วเขียนไปที่ `.chief/project.md` พร้อมยืนยันว่าจะเก็บ planning artifact ไว้ที่ไหน (ปกติใช้ `.chief/` default ไปเลยก็พอ) จะข้ามและเขียนไฟล์เองทีหลังก็ได้

→ [Tutorial เต็ม: story แรกของคุณ](docs/manual/tutorials/your-first-story.md)
→ [ตัวเลือกการติดตั้งแบบ manual](docs/manual/how-to/install.md)

> **ผู้ใช้ Windows:** Symlink mode ต้องเปิด Developer Mode และตั้ง `git config --global core.symlinks true` install skill จะตรวจจับอัตโนมัติและ fallback เป็น copy mode

## วิธีการทำงานของ Chief

Chief คือไฟล์ markdown ใน 3 ที่:

```
project/
├── AGENTS.md          ← framework + project rules (อำนาจสูงสุด)
└── .chief/
    ├── project.md     ← tech stack, dev commands (เขียนโดย /chief-init)
    ├── _rules/        ← standards ที่ใช้ทุก story
    └── story-1/       ← งานปัจจุบัน: goal, contract, tickets
```

`.chief/` ถูกสร้างแบบ lazy — ไม่มีอะไรปรากฏจนกว่าจะต้องการใช้ **story** คือหน่วยงานของ Chief ขนาดเท่ากับ 1 issue/ticket ใน tracker ทั่วไป (GitHub, Jira, ClickUp) — ไม่ใช่ขนาด "Milestone" หลายสัปดาห์แบบชื่อเดิมใน v4

**ลำดับอำนาจ rules:** `AGENTS.md` > `.chief/_rules/` > `.chief/story-N/_goal/` ระดับสูงกว่าชนะเสมอ

→ [Rules hierarchy](docs/manual/reference/rules-hierarchy.md)
→ [โครงสร้างไดเรกทอรี](docs/manual/reference/directory-structure.md)

## รูปแบบการทำงาน

### ควบคุมทุกขั้นตอน — review ทุก step

เหมาะสำหรับ: โปรเจกต์ซับซ้อน, domain ที่ไม่คุ้นเคย, ทำงานเป็นทีม

```
/chief-plan        # grill (หรือ /chief-wayfinder) → goal → contract → tickets (อนุมัติทุกขั้นตอน)
/chief-build 1   # build ทีละ ticket
/chief-retro       # ทบทวนและบันทึกบทเรียนเป็น rules
```

### อัตโนมัติ — ให้ AI ขับเคลื่อน

เหมาะสำหรับ: prototyping, goal ที่ชัดเจน, ทำงานคนเดียว

```
/chief-autopilot   # อ่าน goal + contract แล้วทำงานตาม ticket frontier ผ่าน /chief-build
/chief-retro
```

### ผสมผสานทั้งสองแบบ

```
/chief-plan        # วางแผนพร้อม approval gates
/chief-autopilot   # execute แผนที่อนุมัติแล้วแบบอัตโนมัติ
/chief-retro
```

## Skills

| Skill                 | ทำอะไร                                                                            |
| --------------------- | ------------------------------------------------------------------------------------- |
| `/chief-init`         | ตั้งค่า `.chief/project.md` ผ่านการสัมภาษณ์ พร้อมยืนยัน storage location |
| `/chief-wayfinder`    | (ไม่บังคับ) แผนผัง decision ที่ยังค้างของ story เป็น map แล้วไล่แก้ทีละอัน |
| `/chief-plan`         | วางแผน story: grill หรือ wayfinder → goal → contract → tickets           |
| `/chief-build`        | build ทีละ ticket: TDD, typecheck, test, review, commit                        |
| `/chief-test`         | ตรวจสอบแบบ long-running/integration/UI/API เฉพาะเมื่อร้องขอ            |
| `/chief-review-code`  | review diff สองมุม (Standards + Spec)                                          |
| `/chief-autopilot`    | รัน ticket frontier ของ story แบบอัตโนมัติ                              |
| `/chief-loop`         | ทำงานทั้ง story ข้ามหลายรอบ ticket จนกว่าจะเสร็จ รายงานทีละ ticket |
| `/chief-grill`        | Stress-test แบบ stateful เชิงลึก; ตรวจคำตอบกับ codebase จริง            |
| `/chief-rule`         | บันทึกการตัดสินใจเป็น rule ถาวรใน `_rules/`                             |
| `/chief-retro`        | Retrospective + lesson learned + อัปเดต `_rules/`                                |
| `/grill-design`       | Stress-test design แบบ stateless พร้อม self-critique                             |
| `/shape-up`           | แปลงไอเดียฟุ้งเป็น spec ที่มีขอบเขต (top-down)                          |
| `/slim-down`          | ตัด scope ที่ใหญ่เกินไปให้พอดีกับ 1 phase                                  |
| `/loop-readiness`     | ตรวจว่าแผนพร้อมรันแบบ unattended loop หรือยัง                       |
| `/dump-commit`        | Commit เร็วพร้อมข้อความ auto-generated                                          |

→ [Skills reference เต็ม](docs/manual/reference/skills.md)
→ [วิธีเลือก skill ที่เหมาะกับสถานการณ์](docs/manual/how-to/pick-the-right-skill.md)

## ไม่มี subagent roster อีกต่อไป

v4 มี subagent ถาวร 4 ตัว (`chief-agent`, `builder-agent`, `tester-agent`, `answer-verifier-agent`) ที่ `/chief-install` wire เข้า `.agents/agents/` ให้ v5 ไม่มีสิ่งนี้แล้ว — `/chief-build` กับ `/chief-test` เป็น skill ที่ spawn throwaway subagent ของตัวเองเวลาต้องการ context แยก ส่วน `chief-agent`/`answer-verifier-agent` ถูกพับเข้าไปในตัว skill ที่ใช้งานมันแทน ไม่มีอะไรต้องติดตั้งแยก ไม่มีอะไรต้อง sync

→ [chief-* execution skills reference](docs/manual/reference/agents.md)

## การอัปเกรด

```bash
# 1. รีเฟรช skills
npx skills@latest add thaitype/chief

# 2. อัปเกรด AGENTS.md
/chief-upgrade
```

ระบุ version: `npx skills@latest add thaitype/chief#v5.0.0` / `/chief-upgrade v5.0.0`

มาจาก v4? `/chief-upgrade` จะตรวจจับและอธิบาย breaking change ก่อนแตะไฟล์ใดๆ — ดู [วิธีอัปเกรด](docs/manual/how-to/upgrade.md#upgrading-from-v4)

## เอกสาร

เอกสารทั้งหมดอยู่ที่ [`docs/manual/`](docs/manual/):

| หมวด                                               | เนื้อหา                                                        |
| ------------------------------------------------------ | --------------------------------------------------------------------- |
| [Tutorial](docs/manual/tutorials/your-first-story.md) | story แรกของคุณตั้งแต่ต้นจนจบ              |
| [How-to guides](docs/manual/how-to/)                      | ติดตั้ง, อัปเกรด, เลือก skill, เขียน rules    |
| [Reference](docs/manual/reference/)                       | Skills, execution skills, โครงสร้างไดเรกทอรี, rules hierarchy |
| [Explanation](docs/manual/explanation/)                   | ทำไมถึงมี Chief, pre-coding first, การแยกหน้าที่รับผิดชอบ |

## Compatibility

| Coding agent                                          | Integration                                                             |
| ----------------------------------------------------- | ----------------------------------------------------------------------- |
| Claude Code                                           | `CLAUDE.md → AGENTS.md` symlink                                         |
| GitHub Copilot                                        | อ่าน `AGENTS.md` โดยตรง                                          |
| Cursor, Windsurf, Kiro, Codex, Aider, Amp, Gemini CLI | อ่าน `AGENTS.md` โดยตรง (ยังไม่ได้ทดสอบ ⚠️) |

## Releases

- **v1** — เวอร์ชันแรก รองรับ Claude Code [เอกสาร](https://github.com/thaitype/chief-agent-framework/tree/release/v1)
- **v2** — รองรับ multi-agent เพิ่มระบบ skills [เอกสาร](https://github.com/thaitype/chief-agent-framework/tree/release/v2)
- **v3** — เปลี่ยนชื่อเป็น Chief เปลี่ยน skill prefix เป็น `chief-` ย้าย repo ไป [`thaitype/chief`](https://github.com/thaitype/chief)
- **v4** — ติดตั้ง skills ผ่าน `npx skills` (แยกออกจาก install) `.chief/` แบบ lazy Skills ใหม่: `/chief-init`, `/chief-rule`, `/chief-grill`, `/grill-design`, `/shape-up`, `/slim-down`, `/chief-loop`, `/loop-readiness` `answer-verifier-agent` แทนที่ `review-plan-agent` ที่ deprecated แล้ว [เอกสาร](https://github.com/thaitype/chief/tree/release/v4)
- **v5** — เปลี่ยนชื่อ "milestone" เป็น "story" (ขนาดเท่า 1 tracker issue ไม่ใช่ Milestone หลายสัปดาห์) เลิกใช้ `_plan/_todo.md` + task spec เปลี่ยนเป็น `_tickets/` แบบ frontier (vertical-slice ticket ที่มี blocking edges) Skill ใหม่: `/chief-wayfinder` (แผนผัง decision ที่ยังค้างก่อนวางแผน), `/chief-build` กับ `/chief-test` (แทนที่ `builder-agent`/`tester-agent` ด้วย skill), `/chief-review-code` (review diff สองมุม) ตัด `.agents/agents/` subagent roster ทิ้งทั้งหมด — `chief-agent` กับ `answer-verifier-agent` ถูกพับเข้า skill ที่ใช้งานมันแทน storage location ไม่ fix เป็น `.chief/` ตายตัวอีกต่อไป (ดู `.chief.config.md` ใน directory structure reference) อ่านเหตุผลเต็มได้ที่ [design doc](docs/design/v5-ai-workflow.md)

## Branches

- `release/v1`, `release/v2`, `release/v4` — Stable legacy releases
- `main` — Stable ล่าสุด (v5)
- `canary` — Active development อาจไม่เสถียร

## การพัฒนา

ทดสอบการเปลี่ยนแปลง locally:

```bash
# ติดตั้งจาก branch ของคุณในโปรเจกต์ทดสอบแยกต่างหาก
npx skills@latest add thaitype/chief#<your-branch> --skill chief-install

# จากนั้นทดสอบ:
/chief-install <your-branch>
```

## การ Contribute

1. Fork และแตก branch จาก `canary`
2. ทำการเปลี่ยนแปลง
3. ทดสอบด้วย workflow การพัฒนาด้านบน
4. PR ไปที่ `canary`
5. Commit style: `type: description` (เช่น `feat: add kiro support`)

## Acknowledgements

- `/grill-design` และ `/chief-grill` ได้แนวคิดจาก [grill-me skill ของ mattpocock](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md)
- `/chief-wayfinder`, `/chief-build`, และ `/chief-review-code` ใน v5 ได้แนวคิดจาก
  [mattpocock/skills](https://github.com/mattpocock/skills) — `wayfinder`, `implement`, และ
  `code-review` — ปรับให้เข้ากับโมเดล story/goal/contract/ticket ของ Chief ไม่ได้ใช้ตรงๆ
  ดูสิ่งที่เปลี่ยนและเหตุผลได้ที่ [design doc](docs/design/v5-ai-workflow.md)
- Multi-agent architecture ได้แรงบันดาลใจจาก [vercel-labs/skills](https://github.com/vercel-labs/skills)
