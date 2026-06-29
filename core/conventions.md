## Cross-stack conventions (ใช้ทุกโปรเจกต์)

### Naming
- โฟลเดอร์/route แบบ URL ใช้ kebab-case
- ตัวแปร/ฟังก์ชันตามภาษา: camelCase (JS/TS/Java), แต่ค่าคงที่ env เป็น UPPER_SNAKE_CASE
- ชื่อ branch: `feature/<scope>`, `fix/<scope>`, `chore/<scope>`

### Git
- commit เล็ก โฟกัสเดียว, ข้อความขึ้นต้นด้วย verb (`add`, `fix`, `refactor`)
- อย่า commit/push เว้นแต่ผู้ใช้สั่ง; ถ้าอยู่บน branch หลักให้แตก branch ก่อน
- อย่าใช้ `--no-verify` หรือข้าม hook เว้นแต่ผู้ใช้สั่งชัดเจน

### Environment & secrets
- secret อยู่ใน `.env.local` / secret manager เท่านั้น — ห้าม commit
- commit `.env.example` ที่มีคีย์ค่าว่างเพื่อ document ตัวแปรที่ต้องมี
- validate env ทั้งหมดตอน startup (zod ฝั่ง TS, `@ConfigurationProperties` + validation ฝั่ง Spring)
- ห้ามนำ secret ใส่ตัวแปรที่ client เห็น (`NEXT_PUBLIC_*` ฯลฯ)

### Security baseline (ทุก stack)
- validate input ทุกขอบเขตที่รับจากภายนอก (body, query, header, webhook)
- ปฏิเสธ default-allow — allowlist ดีกว่า denylist
- log ห้ามมี secret/PII; ใส่ correlation id เพื่อ trace
- dependency ต้อง pin เวอร์ชัน และผ่าน scan ก่อน merge (ดู pack `cicd-security`)

### Definition of done
- ผ่าน lint + test + typecheck ของ stack นั้น
- ไม่มี TODO ค้างที่กระทบ behavior หลัก
- รายงานผลด้วยหลักฐาน (output จริง) ไม่ใช่คำยืนยันลอย ๆ
