#!/usr/bin/env bash
# Compile translate/*.po → contents/locale/<lang>/LC_MESSAGES/plasma_applet_org.kde.plasma.tradingview.mo
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOMAIN="plasma_applet_org.kde.plasma.tradingview"

for po in "$ROOT"/translate/*.po; do
  [ -f "$po" ] || continue
  lang="$(basename "$po" .po)"
  outdir="$ROOT/contents/locale/$lang/LC_MESSAGES"
  mkdir -p "$outdir"
  msgfmt -o "$outdir/${DOMAIN}.mo" "$po"
  echo "OK $lang → contents/locale/$lang/LC_MESSAGES/${DOMAIN}.mo"
done
