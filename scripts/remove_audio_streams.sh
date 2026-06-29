#!/bin/bash

# Interactively remove one or more audio streams from a video file.
# Uses fuzzy search (fzf) to find the file recursively from the current directory.

set -euo pipefail

# ── Find file ────────────────────────────────────────────────────────────────
read -rp "Enter search term (file name or partial name): " query

echo ""
echo "Searching for '$query' recursively..."

mapfile -d '' all_videos < <(
    find . -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" \
        -o -iname "*.mov" -o -iname "*.m4v" -o -iname "*.webm" \) -print0 2>/dev/null
)

if [[ ${#all_videos[@]} -eq 0 ]]; then
    echo "Error: No video files found in current directory tree."
    exit 1
fi

# Use fzf for fuzzy matching if available, else fall back to grep -i
if command -v fzf &>/dev/null; then
    input=$(printf '%s\n' "${all_videos[@]}" | fzf --query="$query" --select-1 --exit-0 \
        --prompt="Select file: " --height=40% --layout=reverse \
        --header="Type to filter | Enter to select | Esc to cancel")
else
    mapfile -t matches < <(printf '%s\n' "${all_videos[@]}" | grep -i "$query" || true)
    if [[ ${#matches[@]} -eq 0 ]]; then
        echo "Error: No video files matching '$query' found."
        exit 1
    elif [[ ${#matches[@]} -eq 1 ]]; then
        input="${matches[0]}"
        echo "Found: $input"
    else
        echo "Multiple matches found:"
        for j in "${!matches[@]}"; do
            echo "  $((j+1))) ${matches[$j]}"
        done
        echo ""
        read -rp "Select file number: " pick
        if ! [[ "$pick" =~ ^[0-9]+$ ]] || (( pick < 1 || pick > ${#matches[@]} )); then
            echo "Error: Invalid selection."
            exit 1
        fi
        input="${matches[$((pick-1))]}"
    fi
fi

if [[ -z "$input" ]]; then
    echo "No file selected. Exiting."
    exit 0
fi

ext="${input##*.}"
echo ""
echo "Scanning audio streams in: $input"

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

declare -A stream_index_map
i=1
for line in "${stream_lines[@]}"; do
    IFS=',' read -r idx codec channels lang title <<< "$line"
    lang="${lang:-unknown}"; title="${title:-}"; codec="${codec:-unknown}"; channels="${channels:-?}"
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

declare -A to_remove
for sel in "${selections[@]}"; do
    if ! [[ "$sel" =~ ^[0-9]+$ ]] || [[ -z "${stream_index_map[$sel]+x}" ]]; then
        echo "Error: Invalid selection '$sel'."
        exit 1
    fi
    to_remove[$sel]=1
done

if [[ ${#to_remove[@]} -eq $count ]]; then
    echo "Error: Cannot remove all audio streams."
    exit 1
fi

# ── Build ffmpeg map args ─────────────────────────────────────────────────────
map_args=(-map 0)
for sel in "${!to_remove[@]}"; do
    map_args+=(-map "-0:${stream_index_map[$sel]}")
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
