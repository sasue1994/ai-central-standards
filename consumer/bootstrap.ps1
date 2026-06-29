<#
.SYNOPSIS
  One-liner bootstrap — รันในโฟลเดอร์โปรเจกต์ที่มี standards.json

.DESCRIPTION
  อ่าน standards.json (source, ref) → ดึงตัวรัน sync-standards.ps1 จาก repo กลางตาม ref
  → รันเพื่อประกอบ CLAUDE.md  ผู้ใช้มีแค่ standards.json ก็พอ

.EXAMPLE
  irm https://raw.githubusercontent.com/sasue1994/ai-central-standards/main/consumer/bootstrap.ps1 | iex
#>
[CmdletBinding()]
param(
  [string]$Config = "./standards.json"
)
$ErrorActionPreference = "Stop"

if (-not (Test-Path $Config)) {
  throw "ไม่พบ $Config — สร้าง standards.json ที่ root โปรเจกต์ก่อน (ดูตัวอย่างใน repo กลาง consumer/standards.example.json)"
}

$cfg = Get-Content -Raw -Path $Config | ConvertFrom-Json
if (-not $cfg.source) { throw "standards.json ต้องมี 'source' (URL ของ repo กลาง)" }
$ref = if ($cfg.ref) { $cfg.ref } else { "main" }

# แปลง github .git URL → raw URL ของตัวรัน
$base = ($cfg.source -replace '\.git$', '') -replace 'https://github\.com/', 'https://raw.githubusercontent.com/'
$scriptUrl = "$base/$ref/consumer/sync-standards.ps1"

$runner = Join-Path ([System.IO.Path]::GetTempPath()) ("sync-standards-" + [guid]::NewGuid().ToString("N") + ".ps1")
Write-Host "ดึงตัวรันจาก $scriptUrl ..."
Invoke-RestMethod -Uri $scriptUrl -OutFile $runner

try {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $runner -Config (Resolve-Path $Config).Path
  if ($LASTEXITCODE -ne 0) { throw "sync ล้มเหลว (exit $LASTEXITCODE)" }
}
finally {
  if (Test-Path $runner) { Remove-Item -Force $runner }
}
