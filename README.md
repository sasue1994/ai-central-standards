# central-standards

คลังมาตรฐานกลาง (single source of truth) สำหรับทุกโปรเจกต์ในทีม
เก็บแนวทางการทำงาน + มาตรฐานต่อ stack เป็น **markdown** ให้ AI agent / นักพัฒนาในโปรเจกต์ปลายทาง
"ดึง" มาประกอบเป็น `CLAUDE.md` ของโปรเจกต์ตัวเอง ทุกคนจะได้ baseline เดียวกัน

## โครงสร้าง

```
central-standards/
├─ manifest.yaml         # ดัชนีรวมทุก pack + เวอร์ชัน
├─ core/                 # กฎกลางที่ใช้ทุก stack
│  ├─ workflow.md
│  └─ conventions.md
├─ packs/                # มาตรฐานแยกตาม stack (เลือกใช้เฉพาะที่ต้องการ)
│  ├─ nextjs-seo/
│  ├─ spring-boot/
│  ├─ linebot/
│  └─ cicd-security/
└─ consumer/             # เครื่องมือให้โปรเจกต์ปลายทางดึงมาตรฐานไปใช้
   ├─ standards.example.json
   ├─ sync-standards.ps1
   └─ sync-standards.sh
```

## วิธีใช้ (โปรเจกต์ปลายทาง)

1. ก๊อปปี้ `consumer/standards.example.json` ไปไว้ที่ root โปรเจกต์ของคุณ ตั้งชื่อ `standards.json`
2. แก้ค่า:
   - `source` — URL ของ git repo กลางนี้ (หรือ path ในเครื่องตอนทดสอบ)
   - `ref` — branch/tag ที่ pin ไว้ (เช่น `v1.0.0`) เพื่อล็อกเวอร์ชันมาตรฐาน
   - `packs` — รายชื่อ pack ที่โปรเจกต์ใช้ เช่น `["nextjs-seo","spring-boot"]`
3. รัน sync:
   ```powershell
   pwsh ./consumer/sync-standards.ps1 -Config ./standards.json    # Windows
   ```
   ```bash
   ./consumer/sync-standards.sh ./standards.json                  # macOS/Linux
   ```
4. สคริปต์จะ clone repo กลางตาม `ref` แล้วประกอบ `core/` + `packs/` ที่เลือก เขียนลง `CLAUDE.md`
   ภายในบล็อก marker `<!-- BEGIN central-standards (generated) -->`

## หลักการ

- **Idempotent** — รันซ้ำได้ เนื้อในบล็อก generated ถูกสร้างใหม่ทุกครั้ง ส่วนที่คุณเขียนเองนอกบล็อกไม่ถูกแตะ
- **Pinned** — pin ด้วย git ref/tag → ทุกโปรเจกต์ได้มาตรฐานเวอร์ชันเดียวกัน อัปเดตเมื่อพร้อม (เปลี่ยน `ref` แล้ว sync ใหม่)
- **Composable** — เลือกเฉพาะ pack ที่ใช้ ไม่แบกมาตรฐานที่ไม่เกี่ยว

## การเพิ่ม / แก้มาตรฐาน

1. แก้ไฟล์ใน `core/` หรือ `packs/<pack>/CLAUDE.md`
2. อัป `version` ใน `manifest.yaml` และ `packs/<pack>/pack.yaml`
3. tag เวอร์ชันใหม่ (`git tag v1.1.0`) เพื่อให้โปรเจกต์ปลายทาง pin ได้
