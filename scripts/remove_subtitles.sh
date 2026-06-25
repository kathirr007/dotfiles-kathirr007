#!/bin/bash

mapfile -d '' files < <(find . -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.m4v" \) -print0)

total=${#files[@]}

if [[ $total -eq 0 ]]; then
    echo "No video files found."
    exit 0
fi

echo "Found $total video file(s). Starting..."
done=0
failed=0

for file in "${files[@]}"; do
    done=$((done + 1))
    ext="${file##*.}"
    tmp="${file}.tmp.${ext}"
    echo "[$done/$total] Processing: $file"
    if ffmpeg -i "$file" -map 0 -map -0:s -c copy "$tmp" -y -loglevel error; then
        mv "$tmp" "$file"
        echo "[$done/$total] Done: $file"
    else
        rm -f "$tmp"
        failed=$((failed + 1))
        echo "[$done/$total] Failed: $file"
    fi
done

echo ""
echo "Finished. Success: $((total - failed))/$total. Failed: $failed/$total."
