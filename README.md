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

**คุณมีแค่ `standards.json` ไฟล์เดียวก็พอ** — ตัวรันจะถูกดึงจาก repo กลางอัตโนมัติ

**1. สร้าง `standards.json` ที่ root โปรเจกต์** (ก๊อปจาก `consumer/standards.example.json`):
```json
{
  "source": "https://github.com/sasue1994/ai-central-standards.git",
  "ref": "main",
  "packs": ["nextjs-seo", "spring-boot", "linebot", "cicd-security"],
  "output": "CLAUDE.md"
}
```
- `source` — URL ของ repo กลางนี้
- `ref` — branch/tag ที่ pin ไว้ (เช่น `v1.0.0`) เพื่อล็อกเวอร์ชันมาตรฐาน
- `packs` — เลือกเฉพาะ pack ที่โปรเจกต์ใช้

**2. รัน bootstrap one-liner** (ในโฟลเดอร์ที่มี `standards.json`):
```powershell
# Windows PowerShell
irm https://raw.githubusercontent.com/sasue1994/ai-central-standards/main/consumer/bootstrap.ps1 | iex
```
```bash
# macOS / Linux (ต้องมี git, jq, curl)
curl -fsSL https://raw.githubusercontent.com/sasue1994/ai-central-standards/main/consumer/bootstrap.sh | bash
```

bootstrap จะอ่าน `standards.json` → ดึงตัวรัน `sync-standards` จาก repo กลางตาม `ref` → ประกอบ
`core/` + `packs/` ที่เลือก เขียนลง `CLAUDE.md` ภายในบล็อก `<!-- BEGIN central-standards (generated) -->`

> ต้องมี **git** ในเครื่อง (ใช้ clone repo กลาง)

### ทางเลือก: รันตัวรันตรง ๆ (ถ้า vendor สคริปต์ไว้ในโปรเจกต์เอง)
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./sync-standards.ps1 -Config ./standards.json
```
```bash
./sync-standards.sh ./standards.json
```

## หลักการ

- **Idempotent** — รันซ้ำได้ เนื้อในบล็อก generated ถูกสร้างใหม่ทุกครั้ง ส่วนที่คุณเขียนเองนอกบล็อกไม่ถูกแตะ
- **Pinned** — pin ด้วย git ref/tag → ทุกโปรเจกต์ได้มาตรฐานเวอร์ชันเดียวกัน อัปเดตเมื่อพร้อม (เปลี่ยน `ref` แล้ว sync ใหม่)
- **Composable** — เลือกเฉพาะ pack ที่ใช้ ไม่แบกมาตรฐานที่ไม่เกี่ยว

## การเพิ่ม / แก้มาตรฐาน

1. แก้ไฟล์ใน `core/` หรือ `packs/<pack>/CLAUDE.md`
2. อัป `version` ใน `manifest.yaml` และ `packs/<pack>/pack.yaml`
3. tag เวอร์ชันใหม่ (`git tag v1.1.0`) เพื่อให้โปรเจกต์ปลายทาง pin ได้
