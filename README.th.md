# Chief Agent Framework

**[English](README.md)** | **ไทย**

> คุณกำลังอ่านเอกสาร v2 ซึ่งรองรับ coding agent หลายตัว หากคุณติดตั้ง v1 อยู่ ให้ทำตาม[คำแนะนำการอัปเกรด](#การอัปเกรด)ด้านล่าง หรือดู[เอกสาร v1](https://github.com/thaitype/chief-agent-framework/tree/release/v1)

เวลาใช้ AI coding agent ในโปรเจกต์จริง งานไม่ได้จบที่ prompt เดียว มีหลายฟีเจอร์ที่ต้องสร้าง หลายการตัดสินใจที่ต้องติดตาม และ progress ที่ต้องดูแลข้ามหลาย session

AI ไม่ได้ลดความพยายาม — มันเปลี่ยนประเภทของความพยายาม จากงาน routine อย่างการเขียน syntax และ debug กลายเป็นการตัดสินใจตลอดเวลา: จะใช้ architecture แบบไหน, pattern อะไร, จะไปทิศทางไหนต่อ ทุกครั้งที่คุยกับ AI คือการตัดสินใจ ยิ่งรีบ ยิ่งข้ามการตัดสินใจ ยิ่งสร้าง tech debt

**Chief Agent Framework** ย้ายการตัดสินใจเหล่านั้นออกจากหัวคุณเข้าสู่ระบบ

- คุณกำหนด rules และ goals ครั้งเดียว
- Planning agent แบ่งงานเป็น milestones และ tasks
- Builder agent ลงมือทำ
- Tester agent ตรวจสอบผลลัพธ์
- Review agent ตรวจ plan หาข้อขัดแย้งเมื่อคุณต้องการความเห็นที่สอง

คุณให้ prompt สั้น ๆ agent จัดการวางแผน ลงมือทำ และตรวจสอบ

สร้างมาสำหรับนักพัฒนาที่ใช้ AI coding agent อยู่แล้ว และต้องการ workflow ที่มีโครงสร้างแทนการ prompt แบบ ad-hoc

## สามเสาหลักของการทำงานกับ AI

การพัฒนาด้วย AI ที่มีประสิทธิภาพต้องอาศัยสามองค์ประกอบทำงานร่วมกัน:

- **Human** — กำหนดเป้าหมาย ตั้งทิศทาง และตัดสินใจ design ที่สำคัญ ยิ่งเป้าหมายชัด ยิ่งลดการถาม-ตอบ Template และ rules ที่มีโครงสร้างช่วยลดจำนวนการตัดสินใจที่คุณต้องทำ
- **Rules** — เข้ารหัส standards, contracts และ constraints เพื่อให้ AI รู้ว่าควรทำตัวอย่างไรในโปรเจกต์ของคุณ Architecture patterns, type safety, verification steps — เขียนครั้งเดียว บังคับใช้ทุก session
- **AI** — ใช้เทคนิค AI engineering เพื่อทำงานได้ดีขึ้น: agentic coding, multi-agent orchestration และ automatic feedback loops จากระบบภายนอก (type checkers, linters, tests) เทคนิคที่ดีกว่าหมายถึงผลลัพธ์ที่แม่นยำกว่า

Framework นี้ให้โครงสร้าง prompt และ context การเลือก coding agent และ model เป็นการตัดสินใจของคุณ

## Coding Agents ที่รองรับ

| Coding Agent                                                    | Integration                                           | หมายเหตุ                                |
| --------------------------------------------------------------- | ----------------------------------------------------- | --------------------------------------- |
| Claude Code                                                     | `CLAUDE.md → AGENTS.md` symlink + `.claude/` symlinks | รองรับเต็มรูปแบบ (agents + skills)       |
| GitHub Copilot                                                  | `.github/agents/` symlinks หรือ copies                | รองรับเต็มรูปแบบ (agents)                |
| OpenCode, Codex, Cursor, Gemini CLI, Amp, Windsurf, Kiro, Aider | อ่าน `AGENTS.md` โดยตรง                               | ควรใช้งานได้ทันที (ยังไม่ได้ทดสอบ ⚠️ — [เปิด issue](https://github.com/thaitype/chief-agent-framework/issues) หากพบปัญหา) |

## การติดตั้ง

เวอร์ชันปัจจุบันคือ v2 ซึ่งรองรับ coding agent หลายตัว หากคุณติดตั้ง v1 อยู่ ให้ทำตาม[คำแนะนำการอัปเกรด](#การอัปเกรด)ด้านล่าง

```bash
npx skills@latest add thaitype/chief-agent-framework --skill install-chief
```

```
/install-chief
```

Skill จะถามว่าคุณใช้ coding agent ตัวไหน เลือกโหมดติดตั้ง คัดลอกไฟล์ framework และตั้งค่าทุกอย่าง

สำหรับการติดตั้งแบบ manual (shell script, git clone) ดู [docs/manual-install.md](docs/manual-install.md)

> **ผู้ใช้ Windows:** โหมด Link ต้องเปิด Developer Mode และตั้ง `git config --global core.symlinks true` สคริปต์ตั้งค่าจะตรวจจับอัตโนมัติ — ถ้า symlinks ใช้ไม่ได้จะ fallback เป็นโหมด copy

## โครงสร้างไดเรกทอรี

หลังติดตั้ง โปรเจกต์ของคุณจะมี:

```
project/
├── AGENTS.md               # กฎของ framework — ไฟล์หลัก (อำนาจสูงสุด)
├── CLAUDE.md → AGENTS.md   # Symlink (เฉพาะ Claude Code)
├── .github/agents/        # Agent definitions สำหรับ Copilot (symlinks หรือ copies)
├── .agents/               # Agent definitions หลัก (ไม่ผูกกับ coding agent ใดตัวหนึ่ง)
│   ├── agents/            # คำนิยามบทบาทของ agent
│   │   ├── chief-agent.md
│   │   ├── builder-agent.md
│   │   ├── tester-agent.md
│   │   └── review-plan-agent.md
│   └── skills/            # Skills ที่ติดตั้งได้
│       └── grill-me/
├── .chief/                # Plans, rules, milestones
│   ├── project.md         # Config เฉพาะโปรเจกต์ (tech stack, commands)
│   ├── MANUAL.md          # คู่มือการใช้งาน framework
│   ├── _rules/            # กฎกลาง
│   └── milestone-1/       # Milestone แรก
├── .claude/               # Claude Code integration (symlinks)
│   ├── agents/ → .agents/agents/*
│   └── skills/ → .agents/skills/*
```

## วิธีการทำงาน

- `.agents/` คือตำแหน่ง **หลักที่ไม่ผูกกับ coding agent ใด** สำหรับ agent definitions และ skills
- `.chief/` เก็บ planning, rules, milestones และ project configuration
- `AGENTS.md` กำหนดกฎของ framework ที่มีอำนาจสูงสุด
- `CLAUDE.md` คือ symlink ไปยัง `AGENTS.md` (เฉพาะ Claude Code)
- `.github/agents/` เก็บ symlinks หรือ copies สำหรับ GitHub Copilot
- ไดเรกทอรีเฉพาะ agent (`.claude/`, `.github/agents/` ฯลฯ) ถูกสร้างผ่าน symlinks หรือ copies ที่ชี้กลับไปยัง `.agents/`

## เริ่มต้นใช้งาน

หลังติดตั้ง ตั้งค่า context โปรเจกต์ใน `.chief/project.md` (ไม่ใช่ `AGENTS.md` — ไฟล์นั้นเก็บกฎของ framework เท่านั้น):

```
chief-agent: use grill-me to help me fill in project.md
```

Chief-agent จะสัมภาษณ์คุณเกี่ยวกับ tech stack, architecture และ dev commands แล้วกรอก `.chief/project.md` ให้ หรือจะแก้ไขเองก็ได้

Milestones สามารถเป็นแบบง่าย (`milestone-1`, `milestone-2`) หรืออ้างอิง project tracker (`milestone-JIRA-123`, `milestone-CU-456`)

## Agents ในภาพรวม

| Agent             | เมื่อไหร่ที่ทำงาน                                       | เมื่อไหร่ที่ควรเรียกเอง                                     |
| ----------------- | ------------------------------------------------------- | ----------------------------------------------------------- |
| chief-agent       | เริ่มจากตรงนี้ ให้เป้าหมายมัน                             | วางแผน, ดู progress หรือเปลี่ยนทิศทาง                        |
| review-plan-agent | ไม่บังคับ ไม่ได้เป็นส่วนของ flow อัตโนมัติ                  | เมื่อต้องการตรวจ plan หาข้อขัดแย้ง                            |
| builder-agent     | Chief มอบหมาย task หลังจาก plan ถูก review แล้ว           | เมื่อ task พร้อมและต้องการเริ่มสร้าง                          |
| tester-agent      | ทำงานหลัง builder เสร็จ                                   | เมื่อต้องการ integration/E2E testing นอกเหนือจาก unit tests   |

## ตัวอย่าง Quick Start

คุณกำลังสร้าง CLI ที่แปลง markdown เป็น PDF นี่คือ workflow ทั้งหมด:

**1. เริ่ม milestone**

```
chief-agent: plan milestone-1, goal is to build a CLI that converts markdown to PDF with support for custom templates
```

Chief-agent อ่าน rules ของคุณ ถามคำถาม design ที่สำคัญ (เช่น "ใช้ PDF library ตัวไหน?") สร้าง contracts และแบ่งงานเป็น tasks

**2. สร้าง**

```
builder-agent: implement task-1 from milestone-1
```

Builder ลงมือทำ รัน tests แก้ lint errors และ commit

**3. ดู progress**

```
chief-agent: review milestone-1 progress and plan next tasks
```

Chief ทบทวนงานที่เสร็จแล้ว วางแผน tasks ชุดถัดไป

**4. ทำซ้ำจนเสร็จ**

## Prompts ที่ใช้บ่อย

| สิ่งที่ต้องการ                                  | สิ่งที่ต้องพิมพ์                                            |
| ---------------------------------------------- | --------------------------------------------------------- |
| เริ่ม milestone ใหม่                             | `chief-agent: plan milestone-1, goal is to ...`           |
| ดู progress                                     | `chief-agent: review milestone-1 progress`                |
| เริ่มสร้าง task                                  | `builder-agent: implement task-1 from milestone-1`        |
| ตรวจ plan หาข้อขัดแย้ง (ไม่บังคับ)                | `review-plan-agent: review milestone-1 plan`              |
| รัน integration tests                           | `tester-agent: validate milestone-1`                      |
| เปลี่ยนทิศทางกลาง milestone                      | `chief-agent: update milestone-1, new goal is to ...`     |
| ตั้งค่า project config ด้วยความช่วยเหลือ          | `chief-agent: use grill-me to help me fill in project.md` |

## ตัวอย่างเพิ่มเติม

**TypeScript SDK สำหรับ payment API**

```
chief-agent: plan milestone-1, goal is to create a TypeScript SDK for our payment API with typed request/response and error handling
```

Chief-agent จะถามการตัดสินใจสำคัญ (เช่น "fetch หรือ axios?", "class-based หรือ functional?") แล้ววางแผน tasks เช่น: generate types จาก OpenAPI spec, implement client methods, เขียน tests, เพิ่ม docs

**React component library พร้อม Storybook**

```
chief-agent: plan milestone-1, goal is to build a React component library with Button, Input, and Modal components, documented in Storybook
```

Chief-agent จัดการวางแผน — task breakdown, component contracts, verification steps คุณตอบคำถาม design สองสามข้อ builder ทำที่เหลือ

## การอัปเกรด

> จะถูกอัปเกรดเป็น v2

ติดตั้ง upgrade skill:

```bash
npx skills@latest add thaitype/chief-agent-framework --skill upgrade-chief
```

จากนั้นรัน:

```
/upgrade-chief
```

ถ้าไม่ระบุ argument จะอัปเกรดเป็นเวอร์ชัน stable ล่าสุด หรือระบุเวอร์ชัน:

```
/upgrade-chief canary
/upgrade-chief v2.0.0
```

Skill จะเปรียบเทียบไฟล์ปัจจุบันกับเวอร์ชันเป้าหมาย สร้าง upgrade plan และรอการอนุมัติจากคุณก่อนทำการเปลี่ยนแปลง

## Release

- v1 เป็นเวอร์ชันแรก เน้นรองรับ Claude Code ดู[เอกสาร](https://github.com/thaitype/chief-agent-framework/tree/release/v1)สำหรับรายละเอียด

## Branches
- `release/v1` — Stable v1 release เน้นรองรับ Claude Code
- `main` - latest stable release (ปัจจุบันคือ v2)
- `canary` - active development branch อาจไม่เสถียร

## การพัฒนา

ทดสอบการเปลี่ยนแปลง locally ก่อน submit PR:

1. Push feature branch ไป GitHub
2. ใน **โปรเจกต์ทดสอบแยกต่างหาก** (ไม่ใช่ใน repo นี้) ติดตั้ง skill จาก branch ของคุณ:

```bash
npx skills@latest add thaitype/chief-agent-framework#<your-branch> --skill install-chief
```

3. ทดสอบ:

```
/install-chief <your-branch>
```

Pattern เดียวกันใช้ได้กับ skills อื่น เช่น `upgrade-chief`

## การ Contribute

1. Fork repo และแตก branch จาก `canary`
2. ทำการเปลี่ยนแปลง
3. ทดสอบ locally ตาม workflow [การพัฒนา](#การพัฒนา)ด้านบน
4. Push และเปิด PR ไปที่ `canary`
5. ใช้ commit style ที่มีอยู่: `type: description` (เช่น `fix: resolve merge issue`, `feat: add kiro agent support`)

## Acknowledgement

- Grill me Skill จาก [mattpocock](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md)
- Multi-agent architecture ได้แรงบันดาลใจจาก [vercel-labs/skills](https://github.com/vercel-labs/skills)
