# Chief Agent Framework

**[English](README.md)** | **ไทย**

Framework ที่ช่วยลดภาระทางสมองจากการใช้ AI coding agents — โดย���ม่ทิ้งคุณภาพหรือความเร็วในการทำงาน

> เบื้องหลังของ Chief Agent Framework เป็นแค่ไฟล์ markdown มันแค่กำหนดโครงสร้างให้ AI agents ของคุณทำตาม ลองดูไดเรกทอรี [`template/`](template/) เพื่อดูว่าอะไรถูกติดตั้ง

> คุณกำลังอ่านเอกสาร v2 ซึ่งรองรับ coding agent หลายตัว หากคุณติดตั้ง v1 อยู่ ให้ทำตาม[คำแนะนำการอัปเกรด](#การอัปเกรด)ด้านล่าง หรือดู[เอกสาร v1](https://github.com/thaitype/chief-agent-framework/tree/release/v1)

Chief Agent Framework คือ structured workflow สำหรับ AI coding agents คุณกำหนด rules และ goals ครั้งเดียว แล้ว agents จัดการวางแผน สร้าง และตรวจสอบข้ามหลาย session — ทีละ milestone

เวลาใช้ AI ในโปรเจกต์จริง ความท้าทายไม่ใช่การเขียนโค้ด — แต่เป็นการตัดสินใจตลอดเวลา จะใช้ architecture แบบไหน, pattern อะไร, จะไปทิศทางไหนต่อ ทุกครั้งที่คุยกับ AI คือการตัดสินใจ ยิ่งรีบ ยิ่งข้าม ยิ่งสร้าง tech debt

Framework นี้ย้ายการตัดสินใจเหล่านั้นเข้าสู่ระบบ:

- Planning agent แบ่งงานเป็น milestones และ tasks
- Builder agent ลงมือทำ
- Tester agent ตรวจสอบผลลัพธ์
- Review agent ตรวจ plan หาข้อขัดแย้งเมื่อคุณต้องการความเห็นที่สอง

สร้างมาสำหรับนักพัฒนาที่ใช้ AI coding agent อยู่แล้ว และต้องการ workflow ที่มีโครงสร้างแทนการ prompt แบบ ad-hoc อ่านเพิ่มเติมเกี่ยวกับ[ปรัชญาการออกแบบ](docs/philosophy.md)

## Coding Agents ที่รองรับ

| Coding Agent                                                    | Integration                                           | หมายเหตุ                                |
| --------------------------------------------------------------- | ----------------------------------------------------- | --------------------------------------- |
| Claude Code                                                     | `CLAUDE.md → AGENTS.md` symlink + `.claude/` symlinks | รองรับเต็มรูปแบบ (agents + skills)       |
| GitHub Copilot                                                  | `.github/agents/` symlinks หรือ copies                | รองรับเต็มรูปแบบ (agents)                |
| OpenCode, Codex, Cursor, Gemini CLI, Amp, Windsurf, Kiro, Aider | อ่าน `AGENTS.md` โดยตรง                               | ควรใช้งานได้ทันที (ยังไม่ได้ทดสอบ ⚠️ — [เปิด issue](https://github.com/thaitype/chief-agent-framework/issues) หากพบปัญหา) |

## การติดตั้ง

เวอร์ชันปัจจุบันคือ v2 ซึ่งรองรับ coding agent หลายตัว หากคุณติดตั้ง v1 อยู่ ให้ทำตาม[คำแนะนำการอัปเกรด](#การอัปเกรด)ด้านล่าง

```bash
npx skills@latest add thaitype/chief-agent-framework --skill chief-install
```

```
/chief-install
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
│       ├── grill-me/
│       ├── chief-plan/
│       ├── chief-autopilot/
│       ├── chief-retro/
│       └── dump-commit/
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
| tester-agent      | เฉพาะเมื่อคุณร้องขอเท่านั้น — ไม่ได้เป็นส่วนของ flow อัตโนมัติ | เมื่อต้องการ integration/E2E testing นอกเหนือจาก unit tests   |

## Quick Start — เลือกสไตล์ของคุณ

มีสองวิธีในการทำงาน เลือกแบบที่เหมาะกับสถานการณ์

### Option A: ควบคุมทุกขั้นตอน (review ทุก step)

เหมาะสำหรับ: โปรเจกต์ซับซ้อน, domain ที่ไม่คุ้นเคย, ทำงานเป็นทีม

```
/chief-plan              # กริล → goals → contracts → TODO → specs (อนุมัติทุกขั้นตอน)
builder-agent: implement task-1 from milestone-1   # มอบหมาย tasks ทีละตัว
/chief-retro                 # ทบทวน coverage และเสนอการอัปเดต rules
```

คุณควบคุมทุกอย่าง ทุก goal, contract และ task ถูก review ก่อน execution

### Option B: อัตโนมัติ (ให้ AI ขับเคลื่อน)

เหมาะสำหรับ: prototyping, goals ที่ชัดเจน, ทำงานคนเดียว

```
/chief-autopilot             # อ่าน goals + contracts, สร้าง TODO, รันทุก tasks
/chief-retro                 # ทบทวนสิ่งที่เกิดขึ้น
```

ต้องมี goals และ contracts อยู่แล้ว ใช้ `/chief-plan` ก่อนถ้ายังไม่มี หรือเขียนเอง

### ผสมผสานทั้งสองแบบ

ใช้ทั้งสองแบบร่วมกันได้ วางแผนแบบมี review gates แล้วสลับเป็น autopilot สำหรับ execution:

```
/chief-plan              # วางแผนอย่างรอบคอบพร้อม approval gates
/chief-autopilot             # execute แผนที่อนุมัติแล้วแบบอัตโนมัติ
/chief-retro                 # ทบทวนและเรียนรู้
```

## Prompts ที่ใช้บ่อย

| สิ่งที่ต้องการ                              | สิ่งที่ต้องพิมพ์                                            |
| ------------------------------------------ | --------------------------------------------------------- |
| วางแผน milestone ทีละขั้น                    | `/chief-plan`                                         |
| รัน milestone แบบ autopilot                  | `/chief-autopilot`                                        |
| รัน milestone แบบ autopilot (safe mode)      | `/chief-autopilot safe`                                   |
| รัน retrospective                           | `/chief-retro`                                            |
| Quick commit ทุกไฟล์                         | `/dump-commit`                                            |
| Quick commit พร้อมข้อความ                    | `/dump-commit fix auth flow`                              |
| กริลแผนหรือ design                           | `/grill-me`                                               |
| เริ่มสร้าง task แบบ manual                    | `builder-agent: implement task-1 from milestone-1`        |
| ตรวจ plan หาข้อขัดแย้ง                        | `review-plan-agent: review milestone-1 plan`              |
| รัน integration tests (user-triggered)       | `tester-agent: validate milestone-1`                      |
| ตั้งค่า project config                        | `chief-agent: use grill-me to help me fill in project.md` |

## ตัวอย่างเพิ่มเติม

**TypeScript SDK สำหรับ payment API**

```
/chief-plan
```

Skill จะกริลคุณเรื่องการตัดสินใจ (เช่น "fetch หรือ axios?", "class-based หรือ functional?") เขียน goals และ contracts แล้วแบ่งงานเป็น tasks เมื่อพร้อม:

```
/chief-autopilot
```

Chief-agent รันทุก tasks อัตโนมัติ เมื่อเสร็จ:

```
/chief-retro
```

ทบทวนสิ่งที่ทำได้เทียบกับแผน และอัปเดต rules สำหรับครั้งถัดไป

**Prototyping แบบเร็ว**

```
/chief-autopilot
```

ข้ามการวางแผนละเอียด — ให้ chief สร้าง TODO และมอบหมายให้ builder ทันที เมื่อทำเสร็จวันนั้น:

```
/dump-commit wip: payment SDK progress
```

## การอัปเกรด

> จะถูกอัปเกรดเป็น v2

ติดตั้ง upgrade skill:

```bash
npx skills@latest add thaitype/chief-agent-framework --skill chief-upgrade
```

จากนั้นรัน:

```
/chief-upgrade
```

ถ้าไม่ระบุ argument จะอัปเกรดเป็นเวอร์ชัน stable ล่าสุด หรือระบุเวอร์ชัน:

```
/chief-upgrade canary
/chief-upgrade v2.0.0
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
npx skills@latest add thaitype/chief-agent-framework#<your-branch> --skill chief-install
```

3. ทดสอบ:

```
/chief-install <your-branch>
```

Pattern เดียวกันใช้ได้กับ skills อื่น เช่น `chief-upgrade`

## การ Contribute

1. Fork repo และแตก branch จาก `canary`
2. ทำการเปลี่ยนแปลง
3. ทดสอบ locally ตาม workflow [การพัฒนา](#การพัฒนา)ด้านบน
4. Push และเปิด PR ไปที่ `canary`
5. ใช้ commit style ที่มีอยู่: `type: description` (เช่น `fix: resolve merge issue`, `feat: add kiro agent support`)

## Acknowledgement

- Grill me Skill จาก [mattpocock](https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md)
- Multi-agent architecture ได้แรงบันดาลใจจาก [vercel-labs/skills](https://github.com/vercel-labs/skills)
