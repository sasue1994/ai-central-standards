## Spring Boot backend standard

### Tech stack
- Spring Boot 4.0, Java 25 (ใช้ records, sealed types, pattern matching, virtual threads)
- Postgres + Flyway (plain SQL migrations, ไม่ใช้ Hibernate ddl-auto)
- Build: Gradle (Kotlin DSL) หรือ Maven — pin เวอร์ชันใน wrapper
- Test: JUnit 5 + Testcontainers + RestAssured/MockMvc

### Commands
```bash
./gradlew build          # compile + test
./gradlew test           # unit + integration
./gradlew flywayMigrate  # apply migrations
./gradlew bootRun        # local run
```
รัน `./gradlew build` ก่อนถือว่าเสร็จ — ต้องผ่าน test + spotless/checkstyle

### Architecture
- หนึ่ง service = หนึ่ง bounded context. แยก `guest-api` / `admin-api` เป็นคนละ deployable
- เลเยอร์: `web` (controller/DTO) → `application` (service/use-case) → `domain` → `infrastructure` (repo/adapters)
- controller รับ/คืนเฉพาะ DTO (record) — ห้ามให้ entity หลุดออก API
- map DTO↔entity ในเลเยอร์ application ไม่ใช่ใน controller

### REST API
- ใช้ noun พหูพจน์ + kebab-case path: `POST /api/v1/events`, `GET /api/v1/event-configs/{id}`
- version ที่ path (`/api/v1`)
- validate body ด้วย `@Valid` + Bean Validation; คืน `400` พร้อม problem detail (RFC 9457 `ProblemDetail`)
- ใช้ HTTP status ให้ถูก: 201 + `Location` ตอนสร้าง, 204 ตอนลบ, 409 ตอน conflict
- pagination: `?page=&size=` คืน metadata (total, page) — อย่าคืน list เปล่าไม่มี bound

### Persistence
- migration ทุกครั้งเป็นไฟล์ Flyway `V<n>__<desc>.sql` — ห้ามแก้ migration ที่ apply แล้ว เพิ่มไฟล์ใหม่เสมอ
- ระวัง N+1 — ใช้ `@EntityGraph` หรือ fetch join สำหรับ aggregate ที่โหลดพร้อมกัน
- ธุรกรรมที่ขอบ service ด้วย `@Transactional`; read-only query ใส่ `@Transactional(readOnly = true)`
- ห้าม native query เว้นแต่จำเป็นด้าน performance และมี comment อธิบาย

### Security / auth
- รองรับหลาย realm: แยก `SecurityFilterChain` ต่อ API (เช่น guest = token เบา, admin = OAuth2/OIDC)
- ตรวจ authz ที่ method ด้วย `@PreAuthorize` ไม่พึ่งแค่ route matching
- ห้ามเก็บ secret ใน `application.yml` ที่ commit — ใช้ env / config server / vault
- เปิด CORS แบบ allowlist origin ที่ชัดเจน ไม่ใช้ `*` กับ credentials

### Observability
- logging แบบ structured (JSON) + correlation id ผ่าน MDC
- expose `/actuator/health`, `/actuator/prometheus`; ปิด actuator endpoint ที่ sensitive ต่อ public
- ห้าม log secret/PII

### Testing
- unit test สำหรับ domain/application logic (ไม่ต้องยก context)
- integration test ยก Postgres จริงด้วย Testcontainers — ห้าม mock repository ในเทสต์ที่ต้องพิสูจน์ SQL
- ทุก endpoint ใหม่ต้องมี test ครอบ happy path + validation error อย่างน้อย

### What NOT to do
- ห้าม `ddl-auto: update` — schema คุมด้วย Flyway เท่านั้น
- ห้ามคืน entity ดิบจาก controller
- ห้าม field injection (`@Autowired` บน field) — ใช้ constructor injection
- ห้าม catch `Exception` กว้าง ๆ แล้วกลืน — จัดการที่ `@RestControllerAdvice`
