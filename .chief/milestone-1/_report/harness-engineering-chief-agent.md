# Harness Engineering & Chief Agent Framework

**สรุปบทเรียนจากการย้าย Chief Framework ออกนอก Claude Code และแนวทางการปรับใช้**

---

## Part 1: Harness Engineering คืออะไร

### นิยามหลัก

```
Agent  = Harness + Model
Harness = Agent − Model
```

**Harness** คือทุกอย่างที่ห่อหุ้มโมเดลไว้ เพื่อให้โมเดลทำงานเป็น agent ได้ — ประกอบด้วย system prompt, tools, agent loop, context management, UI, session management, permission layer และ integrations ทั้งหมด

### วิวัฒนาการของวงการ AI Engineering

1. **Prompt Engineering** — แต่ง prompt ให้โมเดลเข้าใจ task
2. **Context Engineering** — จัดการว่าจะใส่อะไรเข้า context window
3. **Harness Engineering** — ออกแบบทั้งระบบรอบโมเดล (ระดับที่กำลังมาแรงในปี 2025-2026)

### ทำไมสำคัญ

โมเดลเดียวกัน (เช่น Claude Sonnet 4.5) ใส่ใน harness ต่างกัน ให้ผลลัพธ์ต่างกันคนละเรื่อง:

| Harness | System Prompt | Tools | Behavior |
|---------|---------------|-------|----------|
| Claude Code | ~10,000 tokens | เยอะ, มี plan mode, todo, sub-agent | ครบเครื่อง แต่มี opinion เยอะ |
| Cursor | ปานกลาง | เน้น inline edit + codebase indexing | ดีสำหรับ IDE workflow |
| Copilot Chat | ปานกลาง | ผูกกับ VS Code context | ตอบสั้น เน้น snippet |
| pi | <1,000 tokens | แค่ 4 tools: read/write/edit/bash | Minimal, user ควบคุมเอง |

### บทเรียนสำคัญ 3 ข้อ

1. **เลือก harness สำคัญพอๆ กับเลือก model** — benchmark แค่ model ไม่พอ ต้อง benchmark harness+model รวมกัน
2. **Framework ที่ผูกกับ harness เฉพาะ ย้ายยาก** — ควรออกแบบให้ harness-agnostic ตั้งแต่แรก
3. **System prompt เป็น interface ของ user กับ model** — harness ที่ดีไม่ควรยึดครองพื้นที่นี้ทั้งหมด

---

## Part 2: กรณีศึกษา pi — Minimal Harness Philosophy

pi (pi.dev โดย Mario Zechner) เป็นตัวอย่าง harness ที่ออกแบบตรงข้ามกับ Claude Code

### หลักการออกแบบของ pi

- **System prompt < 1,000 tokens** — แค่บอกว่ามี 4 tools อะไร ใช้ยังไง จบ
- **4 tools เท่านั้น**: read, write, edit, bash
- **ไม่มี plan mode, ไม่มี todo, ไม่มี sub-agent, ไม่มี MCP, ไม่มี permission popup**
- **YOLO by default** — ให้ user รับผิดชอบเอง (sandbox ใน container เองถ้ากังวล)
- **Extensions + Skills + Prompt Templates + SYSTEM.md** — user ออกแบบทุกอย่างเอง

### ข้อโต้แย้งของ Mario

Frontier models ถูก RL-trained มาหนักจนเข้าใจ concept ของ coding agent อยู่แล้ว — ไม่จำเป็นต้อง hand-hold ด้วย system prompt 10,000 tokens และผลการ benchmark บน Terminal-Bench 2.0 ยืนยันว่า minimal approach แข่งกับ harness ที่ซับซ้อนกว่าได้

### กลไกปรับแต่งของ pi (3 ระดับ)

1. **AGENTS.md** — inject ต่อท้าย default system prompt (global + per-project, โหลดแบบ hierarchical)
2. **SYSTEM.md** — replace หรือ append system prompt ทั้งก้อนแบบ per-project
3. **Extensions (TypeScript)** — inject dynamic context, filter messages, ทำ custom compaction/RAG/memory

---

## Part 3: วิเคราะห์ Chief Framework ปัจจุบัน

### ปัญหาที่เจอตอนย้ายออกนอก Claude Code

Chief Framework ถูกออกแบบโดยอิงกับ assumption ของ Claude Code ที่จัดการให้ฟรี:

- Permission model (Read/Edit/Bash แยกชัดเจน)
- Sub-agent pattern พร้อม context isolation
- SKILL.md convention และ progressive disclosure
- Context compaction strategy ของ Claude Code
- File system access ที่ consistent

พอย้ายไป harness อื่น → assumption หายไป → framework logic ตีกับ harness ใหม่

### สมการปัจจุบันของ Chief Framework

```
Chief Agent = (Claude Code harness + Chief Framework) + Sonnet 4.5
```

Chief Framework จริงๆ คือ **harness layer เสริม** ที่วางบน Claude Code อีกที — ไม่ใช่ pure framework ที่ portable

### เป้าหมายที่ควรเป็น

```
Chief Agent = (Any harness + Chief Framework portable) + Any model
```

ทำให้ Chief Framework **harness-agnostic** และ **model-agnostic** ให้มากที่สุด

---

## Part 4: คำแนะนำสำหรับ Chief Agent Framework

### คำแนะนำที่ 1: แยก Chief Framework ออกเป็น 3 ชั้น

**ชั้น A: Core Philosophy (harness-agnostic)**
- Chief/Builder/Tester role definition
- Milestone-based file organization
- Human-AI-Rule triangle principles
- เก็บเป็น markdown ล้วนๆ — port ได้ทุก harness

**ชั้น B: Harness Adapter**
- Claude Code adapter: ใช้ SKILL.md, Task tool, TodoWrite
- pi adapter: ใช้ SYSTEM.md, extension สำหรับ sub-agent, TODO.md file
- Copilot adapter: ใช้ custom instructions, chat participant
- ชั้นนี้คือที่ๆ harness-specific code อยู่

**ชั้น C: Project-Specific Config**
- AGENTS.md หรือ CLAUDE.md per project
- Milestone folder structure
- Project-specific skills

### คำแนะนำที่ 2: เลือก pi เป็น Reference Harness

pi เหมาะเป็น testbed เพราะ:

- Harness บางที่สุด → ถ้า framework work บน pi ได้ แปลว่าไม่ได้พึ่ง harness magic
- SYSTEM.md ให้ replace ทั้งก้อนได้ → เทียบกับ Claude Code ที่ inject ทับไม่ได้
- Extension system เป็น TypeScript → เข้ากับ Bun stack ที่ใช้อยู่
- RPC + SDK mode → integrate กับ HuskClaw/PicoClaw ได้ตรง (OpenClaw ใช้ pi เป็น example อยู่แล้ว)

### คำแนะนำที่ 3: เขียน Chief Framework Spec แบบ Minimal

ตามหลัก "models ฉลาดพอแล้ว ไม่ต้อง prompt ยาว":

- ตัด boilerplate ที่ Claude Code ให้ฟรีออก (ไม่ต้องอธิบายว่า read tool ทำอะไร)
- เน้น role, workflow, และ convention ของ Chief Framework เท่านั้น
- เป้า: SYSTEM.md ของ Chief Framework ควรอยู่ใน 2,000-3,000 tokens

### คำแนะนำที่ 4: Sub-Agent Pattern แบบ Portable

Claude Code ใช้ Task tool ภายใน — pi ไม่มี แต่แก้ได้ด้วย pattern ที่ Mario แนะนำ:

```bash
# Sub-agent = spawn ตัวเองผ่าน bash
pi --print --provider anthropic --model sonnet \
   "Review this code for bugs: $CODE"
```

Chief Framework ควรเปลี่ยนจาก "Task tool" เป็น abstract primitive เช่น `spawn_worker(role, context)` แล้วให้แต่ละ adapter แปลงเป็น native call ของ harness นั้น

### คำแนะนำที่ 5: Observability First

บทเรียนจาก Mario: Claude Code sub-agent เป็น black box — ไม่เห็นว่า worker ทำอะไร

Chief Framework ควรออกแบบให้ builder/tester agent **เขียน log เป็นไฟล์** (เช่น `.chief/runs/<timestamp>.md`) ทุก session เพื่อ:

- Debug ได้เมื่อ agent ทำผิด
- Review ได้ว่า context ที่ส่งให้ worker ครบไหม
- แชร์ session ข้าม harness ได้

### คำแนะนำที่ 6: Benchmark Chief Framework แบบใหม่

สร้าง benchmark suite ที่วัด **framework + harness + model** ร่วมกัน:

| Test Case | Claude Code + Sonnet | pi + Sonnet | pi + GLM | Copilot + GPT-5 |
|-----------|---------------------|-------------|----------|-----------------|
| Build Next.js feature | ? | ? | ? | ? |
| Fix bug in Azure Function | ? | ? | ? | ? |
| Refactor with tests | ? | ? | ? | ? |

ผลลัพธ์จะบอกว่า Chief Framework พึ่ง harness แค่ไหน — ถ้าคะแนนต่างกันมากระหว่าง harness แสดงว่ายังไม่ portable พอ

### คำแนะนำที่ 7: เผยแพร่เป็น npm package

ถ้า Chief Framework portable แล้ว ปรับเป็น `@thaitype/chief-framework` ที่:

- มี core markdown bundle สำหรับทุก harness
- มี adapter แยก: `@thaitype/chief-claude-code`, `@thaitype/chief-pi`
- ติดตั้งด้วย `pi install npm:@thaitype/chief-pi` หรือ symlink เข้า `.claude/skills/`
- เข้ากับ ecosystem `thaitype.dev` และ community ที่มีอยู่

---

## Part 5: Roadmap แนะนำ

### Phase 1: Audit (1-2 สัปดาห์)
- ระบุทุกจุดใน Chief Framework ที่พึ่ง Claude Code เฉพาะ
- แยกเป็น core logic vs harness adapter
- เขียน spec ของ Chief Framework แบบ harness-agnostic

### Phase 2: pi Port (2-3 สัปดาห์)
- สร้าง SYSTEM.md สำหรับ Chief Framework บน pi
- เขียน extension สำหรับ sub-agent pattern ผ่าน bash spawn
- ทดสอบกับ project จริง เทียบกับรันบน Claude Code

### Phase 3: Generalize (2-4 สัปดาห์)
- สร้าง adapter pattern formal
- Port ไป Copilot CLI และ OpenCode ด้วย
- เก็บ benchmark ข้าม harness

### Phase 4: Publish (1-2 สัปดาห์)
- Package เป็น npm
- เขียน blog post สรุปบทเรียน (เหมาะเป็น talk ต่อยอดจาก JS meetup)
- Open source บน GitHub `thaitype/chief-framework`

---

## สรุป

Harness Engineering กำลังกลายเป็นทักษะสำคัญถัดจาก prompt engineering และ context engineering การมี Chief Framework ที่ harness-agnostic จะทำให้:

- ไม่ถูกล็อกกับ vendor ใดvendor หนึ่ง
- ทดลองโมเดลใหม่ๆ ได้อิสระ (สำคัญมากเมื่อเรื่อง RunPod+Ollama vs OpenRouter ที่กำลังคิดอยู่)
- แชร์ให้ community ใช้ต่อได้ (ตรงกับ thaitype.dev open source strategy)
- เป็น talk ที่ต่อยอดจาก Global Azure และ JS meetup ได้ดี

pi เป็น harness ที่เหมาะสำหรับใช้เป็น reference implementation เพราะ minimalism ทำให้เห็นชัดว่า framework logic อยู่ที่ไหน และ harness magic อยู่ที่ไหน — เป็นเครื่องมือคัด "signal" ออกจาก "noise" ในการออกแบบ framework

**คำถามหลักที่ควรถามตัวเองหลังอ่าน report นี้:**
Chief Framework ของคุณ ถ้า strip Claude Code harness ออกไปเหลือแค่ 4 tools + 1,000 tokens system prompt — ยังทำงานได้อยู่ไหม? ถ้าใช่ = portable แล้ว ถ้าไม่ = ยังต้อง refactor
