#!/bin/bash

# Usage: ./remove_audio_streams.sh [video_file]
# Interactively remove one or more audio streams from a video file.

set -euo pipefail

# ── Input ────────────────────────────────────────────────────────────────────
if [[ $# -ge 1 ]]; then
    input="$1"
else
    read -rp "Enter video file path: " input
fi

if [[ ! -f "$input" ]]; then
    echo "Error: File not found: $input"
    exit 1
fi

ext="${input##*.}"
echo ""
echo "Scanning: $input"

# ── Probe audio streams ───────────────────────────────────────────────────────
mapfile -t stream_lines < <(
    ffprobe -v error \
        -select_streams a \
        -show_entries stream=index,codec_name,channels:stream_tags=language,title \
        -of csv=p=0 \
        "$input" 2>/dev/null
)

count=${#stream_lines[@]}

if [[ $count -eq 0 ]]; then
    echo "Error: No audio streams found in '$input'."
    exit 1
fi

if [[ $count -eq 1 ]]; then
    echo "Error: Only one audio stream found. Nothing to remove."
    exit 1
fi

echo "Found $count audio stream(s):"
echo ""

declare -A stream_index_map   # display_num -> actual stream index
i=1
for line in "${stream_lines[@]}"; do
    IFS=',' read -r idx codec channels lang title <<< "$line"
    lang="${lang:-unknown}"
    title="${title:-}"
    codec="${codec:-unknown}"
    channels="${channels:-?}"
    label="Stream $i  [index=$idx]  codec=$codec  channels=$channels  lang=$lang"
    [[ -n "$title" ]] && label+="  title=\"$title\""
    echo "  $i) $label"
    stream_index_map[$i]=$idx
    ((i++))
done

echo ""
echo "Enter stream number(s) to REMOVE (space-separated, e.g. 1 3):"
read -rp "> " -a selections

if [[ ${#selections[@]} -eq 0 ]]; then
    echo "No selection made. Exiting."
    exit 0
fi

# Validate selections
declare -A to_remove
for sel in "${selections[@]}"; do
    if ! [[ "$sel" =~ ^[0-9]+$ ]] || [[ -z "${stream_index_map[$sel]+x}" ]]; then
        echo "Error: Invalid selection '$sel'."
        exit 1
    fi
    if [[ ${#to_remove[@]} -eq $((count - 1)) ]]; then
        echo "Error: Cannot remove all audio streams."
        exit 1
    fi
    to_remove[$sel]=1
done

# ── Build ffmpeg map args ─────────────────────────────────────────────────────
map_args=(-map 0)
for sel in "${!to_remove[@]}"; do
    idx="${stream_index_map[$sel]}"
    map_args+=(-map "-0:$idx")
done

tmp="${input%.*}.tmp.${ext}"

echo ""
echo "Removing stream(s): ${!to_remove[*]}"
echo "Processing: $input  →  $tmp"
echo ""

ffmpeg -i "$input" "${map_args[@]}" -c copy "$tmp" -y

echo ""
echo "Replacing original file..."
mv "$tmp" "$input"
echo "Done: $input"
