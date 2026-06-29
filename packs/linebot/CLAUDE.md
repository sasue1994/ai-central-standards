## LINE bot standard

### Scope
ครอบคลุม LINE Messaging API (webhook + push/reply) และ LIFF
ใช้ร่วมกับ pack backend (เช่น `spring-boot`) หรือ Next.js API route ตาม stack ที่โฮสต์ webhook

### Webhook security — บังคับ
- ตรวจ **signature ทุก request** ก่อนประมวลผล: คำนวณ HMAC-SHA256 ของ raw body ด้วย channel secret
  แล้วเทียบกับ header `x-line-signature` (เทียบแบบ constant-time) — ไม่ผ่าน = ตอบ `401` ทันที
- ต้องใช้ **raw body** ในการคำนวณ signature — อย่าให้ framework parse/แก้ body ก่อนตรวจ
- endpoint ต้องเป็น HTTPS เท่านั้น
- ตอบ `200` ให้ LINE platform **เร็วที่สุด** แล้วประมวลผลงานหนักแบบ async (queue/worker) — webhook timeout สั้น
- จัดการ retry: event มี chance ถูกส่งซ้ำ → ออกแบบ handler ให้ idempotent (กันด้วย `webhookEventId` / dedup)

### Token & config
- `LINE_CHANNEL_SECRET`, `LINE_CHANNEL_ACCESS_TOKEN` อยู่ใน secret manager เท่านั้น — ห้าม commit
- ใช้ long-lived / stateless channel access token (v2.1) และหมุนเวียนตามรอบ
- แยก channel ต่อ environment (dev/staging/prod) — อย่าใช้ channel เดียวข้าม env

### Messaging
- ใช้ **reply API** (`replyToken`) เป็นหลัก; ใช้ push API เมื่อจำเป็น (มีโควตา + ค่าใช้จ่าย)
- `replyToken` ใช้ได้ครั้งเดียวและหมดอายุเร็ว — อย่าเก็บไปใช้ภายหลัง
- ส่งได้สูงสุด 5 message object ต่อ 1 reply/push
- ข้อความยาว/รูปแบบซับซ้อนใช้ Flex Message; เก็บ JSON template แยกไฟล์ ไม่ hardcode ใน handler
- รองรับ event type ครบที่ใช้งาน: `message`, `follow`, `unfollow`, `postback`, `join`, `leave` — event ที่ไม่รองรับให้ ack เงียบ ไม่ error

### LIFF
- ตรวจสอบ ID token ฝั่ง server ด้วย LINE endpoint ก่อนเชื่อ user profile — อย่าเชื่อ profile จาก client ตรง ๆ
- ขอ scope เท่าที่จำเป็น (`profile`, `openid`)
- เก็บ LIFF ID ใน env (`NEXT_PUBLIC_LIFF_ID` ฝั่ง client ได้ แต่ห้ามวาง secret ฝั่ง client)

### Structure (แนะนำ)
- `webhook/` — รับ event + verify signature + dispatch
- `handlers/` — หนึ่งไฟล์ต่อ event type
- `messages/` — Flex/template JSON builders
- `liff/` — frontend LIFF (ถ้ามี)

### Testing
- unit test signature verification ด้วย body จริง + secret ทดสอบ (เคสผ่าน/ไม่ผ่าน)
- mock LINE API ในเทสต์ handler; อย่ายิง LINE API จริงใน CI
- ทดสอบ idempotency ของ handler ด้วย event ซ้ำ

### What NOT to do
- ห้ามประมวลผล event ก่อนผ่าน signature check
- ห้าม log access token / user message ที่เป็น PII แบบเต็ม
- ห้ามทำงานหนัก (DB เยอะ, เรียก API ภายนอกหลายตัว) แบบ sync ใน webhook handler
- ห้าม reuse `replyToken`
