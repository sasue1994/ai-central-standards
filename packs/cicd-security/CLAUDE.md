## CI/CD + Security standard

### Pipeline stages (ลำดับบังคับ)
1. **lint + typecheck** — fail fast ถ้าไม่ผ่าน
2. **unit test** — มี coverage gate ขั้นต่ำที่ทีมตกลง
3. **build** — สร้าง artifact / container image ที่ reproducible
4. **SAST + secret scan + dependency scan** — ดูด้านล่าง
5. **integration / E2E test**
6. **container scan** (ถ้า build image)
7. **deploy** — staging อัตโนมัติ, production ต้อง manual approval

ทุก stage ที่เป็น security gate ต้อง **block merge** เมื่อพบ severity สูง (high/critical) ไม่ใช่แค่ warn

### Security scanning
- **SAST** — สแกนโค้ดทุก PR (เช่น CodeQL / Semgrep) บล็อก finding ระดับ high+
- **Secret scanning** — สแกน commit/PR หา key/token หลุด (เช่น gitleaks / trufflehog) — บล็อกถ้าเจอ
- **Dependency scanning (SCA)** — ตรวจ CVE ของ dependency (เช่น Dependabot / Trivy / OWASP DC); pin เวอร์ชัน, ห้าม floating range ใน lock
- **DAST** — สแกน endpoint ที่รันจริงใน staging (เช่น OWASP ZAP) สำหรับ public-facing service
- **Container scan** — สแกน image หา OS/lib CVE (เช่น Trivy/Grype) ก่อน push registry

### Secret management
- secret ไม่อยู่ในโค้ด/ไฟล์ที่ commit — ใช้ CI secret store / vault / cloud secret manager
- inject ตอน runtime ผ่าน env หรือ mounted secret เท่านั้น
- หมุนเวียน secret ตามรอบ และเมื่อมีคนออกจากทีม
- least privilege: token ของ CI ให้สิทธิ์เท่าที่ stage นั้นต้องใช้

### Build & artifact
- image แบบ multi-stage, base image pin ด้วย digest (`@sha256:...`) ไม่ใช่ `latest`
- รัน container แบบ non-root, read-only filesystem ถ้าทำได้
- สร้าง SBOM และเก็บไว้กับ artifact
- เซ็น artifact/image (เช่น cosign) สำหรับ supply chain integrity

### Deploy
- promote artifact เดิมข้าม env — ห้าม rebuild ต่อ env (build once, deploy many)
- production deploy ต้องมี approval + rollback plan
- ใช้ strategy ที่ลด downtime (rolling / blue-green / canary) ตามความเสี่ยง
- เก็บ deployment history + ผูก commit SHA กับสิ่งที่ deploy

### Branch protection
- ห้าม push ตรงเข้า `main` — ผ่าน PR + review อย่างน้อย 1 คน
- required status checks: lint, test, security gates ต้องเขียวก่อน merge
- ห้าม bypass / `--no-verify` เว้นแต่ผู้ใช้สั่งและบันทึกเหตุผล

### What NOT to do
- ห้ามมี security finding ระดับ high/critical ค้างโดยไม่มี ticket + เหตุผล waiver
- ห้าม echo/print secret ใน log ของ pipeline
- ห้ามใช้ image tag `latest` ใน production
- ห้าม deploy ตรงจากเครื่อง dev ข้าม pipeline
