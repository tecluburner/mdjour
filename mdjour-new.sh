#!/usr/bin/env bash
# mdjour-new.sh - Create a journal entry template following the rules in README.md
#
# Rules (from README.md):
#   - Location:    $JOURNAL_DIR/entries/YYYY/YYYY-MM-DD-NN.md (YYYY-MM-DD is the creation date)
#   - id:          YYYYMMDD-NN (string)
#   - Sequence:    the day's highest sequence number + 1 (gaps are not filled)
#   - Front matter: id / title / created / updated / event_date / tags
#   - Attachments: referenced from the body by relative links. Only with -a,
#                  $JOURNAL_DIR/attachments/YYYY/YYYY-MM-DD/ is created
#
# Usage:
#   mdjour-new.sh [-t title] [-e event date YYYY-MM-DD] [-g tag1,tag2] [-a] [-o]
#
#   -t  Title (prompted interactively if omitted)
#   -e  Date the event took place (defaults to today)
#   -g  Tags, comma-separated (defaults to tags: [] if omitted)
#   -a  Also create the same-day attachment directory attachments/YYYY/YYYY-MM-DD/
#   -o  Open the entry in $EDITOR (nano if unset) after creating it
#   -h  Show this help
#
# Environment variables:
#   JOURNAL_DIR  Journal root (default: the directory containing this script)

set -euo pipefail

# Directory of this script (resolves to the real location even when run via a symlink)
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
JOURNAL_DIR="${JOURNAL_DIR:-$SCRIPT_DIR}"

usage() { sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; }

title=""
event_date=""
tags_raw=""
make_attach=0
open_editor=0

while getopts "t:e:g:aoh" opt; do
  case "$opt" in
    t) title="$OPTARG" ;;
    e) event_date="$OPTARG" ;;
    g) tags_raw="$OPTARG" ;;
    a) make_attach=1 ;;
    o) open_editor=1 ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

# Escape for a double-quoted YAML string
yaml_escape() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  printf '%s' "$s"
}

# --- Date and time ------------------------------------------------------
now_date=$(date +%Y-%m-%d)
now_compact=$(date +%Y%m%d)
year=$(date +%Y)
created=$(date +%Y-%m-%dT%H:%M:%S%:z)   # e.g. 2026-10-14T13:52:00+09:00

# --- Input --------------------------------------------------------------
if [[ -z "$title" ]]; then
  read -r -p "Title: " title
fi
if [[ -z "$title" ]]; then
  echo "Error: title is required." >&2
  exit 1
fi

event_date="${event_date:-$now_date}"
if [[ ! "$event_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] \
   || ! date -d "$event_date" +%Y-%m-%d >/dev/null 2>&1 \
   || [[ "$(date -d "$event_date" +%Y-%m-%d)" != "$event_date" ]]; then
  echo "Error: event_date must be a valid date in YYYY-MM-DD format: $event_date" >&2
  exit 1
fi

# --- Tags -> YAML array -------------------------------------------------
tags_yaml="[]"
if [[ -n "$tags_raw" ]]; then
  items=()
  IFS=',' read -r -a parts <<< "$tags_raw"
  for t in "${parts[@]}"; do
    t="${t#"${t%%[![:space:]]*}"}"   # trim leading and trailing whitespace
    t="${t%"${t##*[![:space:]]}"}"
    [[ -z "$t" ]] && continue
    items+=("\"$(yaml_escape "$t")\"")
  done
  if ((${#items[@]} > 0)); then
    joined=$(printf '%s, ' "${items[@]}")
    tags_yaml="[${joined%, }]"
  fi
fi

# --- Sequence number (the day's highest NN + 1; gaps are not filled) ----
entry_dir="$JOURNAL_DIR/entries/$year"
mkdir -p "$entry_dir"

max=0
shopt -s nullglob
for f in "$entry_dir/${now_date}"-[0-9][0-9]*.md; do
  base=${f##*/}
  nn=${base#"${now_date}-"}
  nn=${nn%%.*}
  if [[ "$nn" =~ ^[0-9]+$ ]]; then
    n=$((10#$nn))
    ((n > max)) && max=$n
  fi
done
shopt -u nullglob

next=$((max + 1))
if ((next > 99)); then
  echo "Error: the sequence number for the day would exceed 99." >&2
  exit 1
fi
nn=$(printf '%02d' "$next")

file="$entry_dir/${now_date}-${nn}.md"
id="${now_compact}-${nn}"

# Never overwrite an existing file
if [[ -e "$file" ]]; then
  echo "Error: file already exists: $file" >&2
  exit 1
fi

# --- Write the file -----------------------------------------------------
cat > "$file" <<EOF
---
id: "$id"
title: "$(yaml_escape "$title")"
created: "$created"
updated: "$created"
event_date: "$event_date"
tags: $tags_yaml
---

EOF

echo "$file"

# --- Attachment directory (only with -a; the date is the entry's creation date) ---
if ((make_attach)); then
  attach_dir="$JOURNAL_DIR/attachments/$year/$now_date"
  mkdir -p "$attach_dir"
  echo "Attachment directory: $attach_dir" >&2
  echo "Link example: ![description](../../attachments/$year/$now_date/filename)" >&2
fi

if ((open_editor)); then
  exec "${EDITOR:-nano}" "$file"
fi
