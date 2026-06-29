#!/usr/bin/env bash
#
# One-liner bootstrap — รันในโฟลเดอร์โปรเจกต์ที่มี standards.json
# อ่าน standards.json (source, ref) → ดึงตัวรัน sync-standards.sh จาก repo กลาง → รันประกอบ CLAUDE.md
#
# usage:
#   curl -fsSL https://raw.githubusercontent.com/sasue1994/ai-central-standards/main/consumer/bootstrap.sh | bash
# ต้องมี: git, jq, curl

set -euo pipefail
CONFIG="${1:-./standards.json}"

command -v jq >/dev/null 2>&1 || { echo "ต้องติดตั้ง jq ก่อน" >&2; exit 1; }
[ -f "$CONFIG" ] || { echo "ไม่พบ $CONFIG — สร้าง standards.json ที่ root โปรเจกต์ก่อน" >&2; exit 1; }

SRC=$(jq -r '.source' "$CONFIG")
REF=$(jq -r '.ref // "main"' "$CONFIG")
[ "$SRC" != "null" ] || { echo "standards.json ต้องมี 'source'" >&2; exit 1; }

BASE=$(echo "$SRC" | sed -E 's#\.git$##; s#https://github\.com/#https://raw.githubusercontent.com/#')
SCRIPT_URL="$BASE/$REF/consumer/sync-standards.sh"

RUNNER=$(mktemp)
echo "ดึงตัวรันจาก $SCRIPT_URL ..."
curl -fsSL "$SCRIPT_URL" -o "$RUNNER"
trap 'rm -f "$RUNNER"' EXIT

bash "$RUNNER" "$CONFIG"
