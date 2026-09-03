# Chief ⚔️

![](https://img.shields.io/badge/chief_version-v4.0.0-blue)

**[English](README.md)** | **ไทย**

Workflow ที่มีโครงสร้างสำหรับ AI coding agents ติดตั้งในโปรเจกต์ใดก็ได้ กำหนด rules ครั้งเดียว แล้วหยุดอธิบาย codebase ซ้ำทุก chat

> Chief เป็นส่วนหนึ่งของระบบนิเวศ [chief-tribe](https://github.com/thaitype/chief-tribe) โดยใช้ [sage](https://github.com/thaitype/sage) เป็น behavioral baseline

## ทำไมถึงมี Chief

ทุกโปรเจกต์มี context — การตัดสินใจเมื่อหกเดือนที่แล้ว, workaround ที่แปลกๆ, เหตุผลที่ว่า "ทำไมถึงทำแบบนี้" สิ่งเหล่านี้อยู่ในหัวคุณ ทุก chat ใหม่เริ่มต้นจากศูนย์ คุณก็อธิบายซ้ำ แล้วก็ซ้ำอีก

Chief หยุดสิ่งนั้น ให้ทุกโปรเจกต์มีรูปร่างเดิม — `AGENTS.md` สำหรับ rules, `.chief/_rules/` สำหรับ standards, `.chief/milestone-N/` สำหรับงานปัจจุบัน Agents รู้ว่าจะอ่านที่ไหนและเขียนที่ไหน prompt ของคุณย่อเหลือแค่ประโยคเดียว

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

จะถามว่าใช้ coding agent ตัวไหน จะ symlink หรือ copy และจะติดตั้ง subagents ไหม แค่นั้นเอง

**ขั้นที่ 3 — ตั้งค่า project context (ไม่บังคับ):**

```
/chief-init
```

สัมภาษณ์เรื่อง stack และ dev commands แล้วเขียนไปที่ `.chief/project.md` จะข้ามและเขียนไฟล์เองทีหลังก็ได้

→ [Tutorial เต็ม: milestone แรกของคุณ](docs/manual/tutorials/your-first-story.md)→ [ตัวเลือกการติดตั้งแบบ manual](docs/manual/how-to/install.md)

> **ผู้ใช้ Windows:** Symlink mode ต้องเปิด Developer Mode และตั้ง `git config --global core.symlinks true` install skill จะตรวจจับอัตโนมัติและ fallback เป็น copy mode

## วิธีการทำงานของ Chief

Chief คือไฟล์ markdown ใน 3 ที่:

```
project/
├── AGENTS.md          ← framework + project rules (อำนาจสูงสุด)
└── .chief/
    ├── project.md     ← tech stack, dev commands (เขียนโดย /chief-init)
    ├── _rules/        ← standards ที่ใช้ทุก milestone
    └── milestone-1/   ← งานปัจจุบัน: goals, contracts, tasks
```

`.chief/` ถูกสร้างแบบ lazy — ไม่มีอะไรปรากฏจนกว่าจะต้องการใช้

**ลำดับอำนาจ rules:** `AGENTS.md` > `.chief/_rules/` > `.chief/milestone-N/_goal/` ระดับสูงกว่าชนะเสมอ

→ [Rules hierarchy](docs/manual/reference/rules-hierarchy.md)
→ [โครงสร้างไดเรกทอรี](docs/manual/reference/directory-structure.md)

## รูปแบบการทำงาน

### ควบคุมทุกขั้นตอน — review ทุก step

เหมาะสำหรับ: โปรเจกต์ซับซ้อน, domain ที่ไม่คุ้นเคย, ทำงานเป็นทีม

```
/chief-plan        # grill → goals → contracts → TODO → tasks (อนุมัติทุกขั้นตอน)
builder-agent: implement task-1 from milestone-1
/chief-retro       # ทบทวนและบันทึกบทเรียนเป็น rules
```

### อัตโนมัติ — ให้ AI ขับเคลื่อน

เหมาะสำหรับ: prototyping, goals ที่ชัดเจน, ทำงานคนเดียว

```
/chief-autopilot   # อ่าน goals + contracts แล้วรันทุก tasks
/chief-retro
```

### ผสมผสานทั้งสองแบบ

```
/chief-plan        # วางแผนพร้อม approval gates
/chief-autopilot   # execute แผนที่อนุมัติแล้วแบบอัตโนมัติ
/chief-retro
```

## Skills

| Skill                | ทำอะไร                                                                                    |
| -------------------- | ----------------------------------------------------------------------------------------------- |
| `/chief-init`      | ตั้งค่า `.chief/project.md` ผ่านการสัมภาษณ์                             |
| `/chief-plan`      | วางแผน milestone: grill → goals → contracts → tasks                                    |
| `/chief-autopilot` | รัน milestone แบบอัตโนมัติ                                                       |
| `/chief-grill`     | Stress-test แบบ stateful เชิงลึก; spawn `answer-verifier-agent` ต่อ 1 คำถาม |
| `/chief-rule`      | บันทึกการตัดสินใจเป็น rule ถาวรใน `_rules/`                        |
| `/chief-retro`     | Retrospective + lesson learned + อัปเดต `_rules/`                                       |
| `/grill-design`    | Stress-test design แบบ stateless พร้อม self-critique                                    |
| `/shape-up`        | แปลงไอเดียฟุ้งเป็น spec ที่มีขอบเขต (top-down)                     |
| `/slim-down`       | ตัด scope ที่ใหญ่เกินไปให้พอดีกับ 1 phase                             |
| `/dump-commit`     | Commit เร็วพร้อมข้อความ auto-generated                                          |

→ [Skills reference เต็ม](docs/manual/reference/skills.md)
→ [วิธีเลือก skill ที่เหมาะกับสถานการณ์](docs/manual/how-to/pick-the-right-skill.md)

## Agents

| Agent                     | บทบาท                                                                           |
| ------------------------- | ------------------------------------------------------------------------------------ |
| `chief-agent`           | วางแผน, ประสานงาน, มอบหมาย — ไม่เขียนโค้ด         |
| `builder-agent`         | implement tasks, รัน unit tests, commit                                           |
| `tester-agent`          | Integration/E2E validation — เฉพาะเมื่อคุณร้องขอเท่านั้น |
| `answer-verifier-agent` | Background verifier ที่ถูก spawn โดย `/chief-grill`                       |

→ [Subagents reference](docs/manual/reference/agents.md)

## การอัปเกรด

```bash
# 1. รีเฟรช skills
npx skills@latest add thaitype/chief

# 2. อัปเกรด framework files
/chief-upgrade
```

ระบุ version: `npx skills@latest add thaitype/chief#v4.0.0` / `/chief-upgrade v4.0.0`

→ [วิธีอัปเกรด](docs/manual/how-to/upgrade.md)

## เอกสาร

เอกสารทั้งหมดอยู่ที่ [`docs/manual/`](docs/manual/):

| หมวด                                               | เนื้อหา                                                        |
| ------------------------------------------------------ | --------------------------------------------------------------------- |
| [Tutorial](docs/manual/tutorials/your-first-story.md) | milestone แรกของคุณตั้งแต่ต้นจนจบ              |
| [How-to guides](docs/manual/how-to/)                      | ติดตั้ง, อัปเกรด, เลือก skill, เขียน rules    |
| [Reference](docs/manual/reference/)                       | Skills, agents, โครงสร้างไดเรกทอรี, rules hierarchy |
| [Explanation](docs/manual/explanation/)                   | ทำไมถึงมี Chief, pre-coding first, three-agent model         |

## Compatibility

| Coding agent                                          | Integration                                                             |
| ----------------------------------------------------- | ----------------------------------------------------------------------- |
| Claude Code                                           | `CLAUDE.md → AGENTS.md` symlink + `.claude/` symlinks              |
| GitHub Copilot                                        | `.github/agents/` symlinks หรือ copies                            |
| Cursor, Windsurf, Kiro, Codex, Aider, Amp, Gemini CLI | อ่าน `AGENTS.md` โดยตรง (ยังไม่ได้ทดสอบ ⚠️) |

## Releases

- **v1** — เวอร์ชันแรก รองรับ Claude Code [เอกสาร](https://github.com/thaitype/chief-agent-framework/tree/release/v1)
- **v2** — รองรับ multi-agent เพิ่มระบบ skills [เอกสาร](https://github.com/thaitype/chief-agent-framework/tree/release/v2)
- **v3** — เปลี่ยนชื่อเป็น Chief เปลี่ยน skill prefix เป็น `chief-` ย้าย repo ไป [`thaitype/chief`](https://github.com/thaitype/chief)
- **v4** — ติดตั้ง skills ผ่าน `npx skills` (แยกออกจาก install) `.chief/` แบบ lazy Skills ใหม่: `/chief-init`, `/chief-rule`, `/chief-grill`, `/grill-design`, `/shape-up`, `/slim-down` `answer-verifier-agent` แทนที่ `review-plan-agent` ที่ deprecated แล้ว

## Branches

- `release/v1`, `release/v2` — Stable legacy releases
- `main` — Stable ล่าสุด (v4)
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

- `/grill-design` และ `/chief-grill` ได้แนวคิดจาก [grill-me skill ของ mattpocock](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md)
- Multi-agent architecture ได้แรงบันดาลใจจาก [vercel-labs/skills](https://github.com/vercel-labs/skills)
