#!/bin/sh
# Legger ett ferdig SoMe-bilde i det offentlige repoet evenifar-cmd/venstre-some-bilder
# og skriver ut en offentlig https-URL som Native kan hente (upload_image --sourceUrl).
#
#   sh last_opp.sh <bildefil> <kortnavn>
#   sh last_opp.sh ../2026-09-25-sofiemyr/sofiemyr-frist-1080x1350.png sofiemyr-frist
#
# ⚠️ Alt som havner her er OFFENTLIG, også i git-historikken. Kjør skriptet først
# ETTER at Even har godkjent innlegget, rett før schedule_post. Aldri UTKAST-bilder,
# aldri plassholdere, aldri logofiler.
# Laget 2026-09-25 for ukesradarens godkjenningsflyt (se ~/.claude/scheduled-tasks/ukesradar).
set -eu

HER=$(cd "$(dirname "$0")" && pwd)
KILDE=${1:?"bruk: sh last_opp.sh <bildefil> <kortnavn>"}
NAVN=${2:?"bruk: sh last_opp.sh <bildefil> <kortnavn>"}

case "$KILDE" in *UTKAST*|*utkast*) echo "⛔ Nekter: filnavnet sier UTKAST." >&2; exit 1 ;; esac

ENDELSE=$(echo "${KILDE##*.}" | tr 'A-Z' 'a-z')
MAPPE=$(date +%Y)
FIL="$MAPPE/$(date +%m-%d)-$NAVN.$ENDELSE"

mkdir -p "$HER/$MAPPE"
cp "$KILDE" "$HER/$FIL"
cd "$HER"
git add "$FIL"
git commit -q -m "Bilde: $FIL"
git push -q origin main

URL="https://raw.githubusercontent.com/evenifar-cmd/venstre-some-bilder/main/$FIL"
# raw.githubusercontent.com kan bruke noen sekunder før en ny fil svarer 200.
i=0
until curl -sfI "$URL" >/dev/null 2>&1; do
  i=$((i + 1))
  [ "$i" -ge 30 ] && { echo "⚠️ URL svarer ikke etter 60 s: $URL" >&2; exit 1; }
  sleep 2
done
echo "$URL"
