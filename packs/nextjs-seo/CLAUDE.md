## Next.js + SEO/AISEO standard

### Tech stack
- Next.js 14+ App Router, TypeScript strict, Tailwind CSS
- Zustand (client state), React Query (server state)
- Vitest + React Testing Library, Playwright (E2E)
- pnpm (ไม่ใช่ npm/yarn)

### Commands
```bash
pnpm dev          # dev server (port 3000)
pnpm build        # production build
pnpm test         # vitest
pnpm lint         # eslint + tsc --noEmit
pnpm test:e2e     # playwright
```
รัน `pnpm lint` และ `pnpm test` หลังทุกชุดการแก้ไขก่อนถือว่าเสร็จ

### Rendering — เลือกตามชนิดเนื้อหา
| Content | Method |
|---|---|
| Marketing, blog, docs | SSG (`generateStaticParams`) |
| Product listings, search | ISR (`revalidate`) |
| Dashboard, account | SSR หรือ client |
| Realtime data | Client-side fetch |

IMPORTANT: ห้ามใส่ `"use client"` ใน page.tsx หรือ layout.tsx — ดัน interactivity ลงไปที่ leaf component

### SEO — บังคับทุกหน้า public
- `generateMetadata` ต้อง export จากทุกหน้าใน `(marketing)/`
- `title`: 50–60 ตัวอักษร รูปแบบ `Page Title | Brand Name`
- `description`: 150–160 ตัวอักษร
- `alternates.canonical` ต้องตั้งเสมอ
- OG image: 1200×630px และต้องมี `alt`
- `app/sitemap.ts` และ `app/robots.ts` ต้องมีและอัปเดตเสมอ
- block `/api/` และ `/dashboard/` ใน robots.ts disallow

### AISEO — JSON-LD structured data
เพิ่ม JSON-LD ผ่าน `components/seo/JsonLd.tsx` (server component, render ใน `<head>`)

| Page | Schema types |
|---|---|
| Home | `Organization` + `WebSite` (with `SearchAction`) |
| Blog/article | `Article` + `BreadcrumbList` + `Person` |
| Product | `Product` + `AggregateRating` + `Offer` |
| FAQ | `FAQPage` |
| How-to | `HowTo` |

ทุก article ต้องมี: ชื่อผู้เขียนที่ลิงก์ไปหน้า author, `<time dateTime="ISO8601">` สำหรับ publish/updated,
outbound link อย่างน้อย 1 ไปแหล่งต้นทาง (`rel="noopener"`), ชื่อ brand/org ในย่อหน้าแรก

### Core Web Vitals targets
- LCP < 2.5s — ใช้ `<Image priority>` กับรูป above-fold
- CLS < 0.1 — ตั้ง `width`+`height` บน `<Image>` เสมอ
- INP < 200ms — bundle เล็ก, defer JS ที่ไม่จำเป็น
- ฟอนต์ผ่าน `next/font` เท่านั้น ห้ามโหลดจาก Google Fonts CDN ตรง ๆ

### Project rules
- component ใหม่ → `src/components/` ห้ามไว้ใน `app/`
- SEO helpers → `lib/seo/`
- API route folder เป็น kebab-case: `app/api/blog-posts/route.ts`
- ใช้ `notFound()` / `redirect()` จาก `next/navigation`

### What NOT to do
- ห้าม `<img>` ดิบ — ใช้ `next/image`
- ห้าม `<a href>` สำหรับลิงก์ภายใน — ใช้ `next/link`
- ห้าม hardcode site URL — ใช้ `process.env.NEXT_PUBLIC_SITE_URL`
- ห้าม ship หน้า public ที่ไม่มี `generateMetadata` + JSON-LD
