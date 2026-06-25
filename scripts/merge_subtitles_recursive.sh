#!/bin/bash

# Enable recursive globbing (**), null globbing, and extended pattern matching (@(ext1|ext2))
shopt -s globstar nullglob extglob

# Arrays to keep track of file statuses for the summary
ready_to_process=()
missing_subs=()
processed_success=0
processed_failed=0

echo "=================================================="
echo "🎬  STAGE 1: Scanning Directory Recursively (All Video Formats)"
echo "=================================================="
echo "Starting folder: $(pwd)"
echo "--------------------------------------------------"

# Scan for common video formats recursively
# You can add more extensions inside the @(...) separated by | if needed
video_files=(**/*.@(mp4|mkv|avi|mov|flv|wmv|m4v))

if [ ${#video_files[@]} -eq 0 ]; then
    echo "❌ No supported video files found in this directory or any subdirectories."
    shopt -u globstar nullglob extglob
    exit 0
fi

# Scan files and group them by status
for video in "${video_files[@]}"; do
    # Strip the extension dynamically (handles .mp4, .mkv, etc. flawlessly)
    ext="${video##*.}"
    base="${video%.*}"
    sub="${base}.srt"
    
    if [[ -f "$sub" ]]; then
        ready_to_process+=("$video")
    else
        missing_subs+=("$video")
    fi
done

# Print findings
if [ ${#ready_to_process[@]} -gt 0 ]; then
    echo "🟢 Found matching subtitles for:"
    for video in "${ready_to_process[@]}"; do
        echo "   • $video -> ${video%.*}.srt"
    done
fi

if [ ${#missing_subs[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  Missing subtitles (.srt) for:"
    for video in "${missing_subs[@]}"; do
        echo "   • $video"
    done
fi

# If nothing can be processed, stop here
if [ ${#ready_to_process[@]} -eq 0 ]; then
    echo ""
    echo "❌ No files are ready for merging (all matching .srt files are missing)."
    shopt -u globstar nullglob extglob
    exit 0
fi

echo ""
echo "--------------------------------------------------"
read -p "Press [Enter] to begin merging subtitles (or Ctrl+C to abort)..."
echo "--------------------------------------------------"

echo ""
echo "=================================================="
echo "⚙️  STAGE 2: Processing Files"
echo "=================================================="

# Process the valid files
for video in "${ready_to_process[@]}"; do
    ext="${video##*.}"
    base="${video%.*}"
    sub="${base}.srt"
    
    # Keeps the output container format identical to the input container
    temp_output="${base}_temp.${ext}"
    
    echo "▶️  Processing: $video"
    
    # Run ffmpeg inside the nested folder structure
    ffmpeg -y -v error -stats -i "$video" -i "$sub" -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 title="English" "$temp_output"
    
    if [[ $? -eq 0 ]]; then
        mv "$temp_output" "$video"
        echo "✅ Successfully merged: $video"
        ((processed_success++))
    else
        echo "❌ Error processing: $video (Original file kept)"
        rm -f "$temp_output"
        ((processed_failed++))
    fi
    echo "--------------------------------------------------"
done

# Clean up bash environment options
shopt -u globstar nullglob extglob

echo ""
echo "=================================================="
echo "📊  STAGE 3: Final Progress Report"
echo "=================================================="
echo "Total video files analyzed recursively: ${#video_files[@]}"
echo "🟩 Successfully processed              : $processed_success"
echo "🟥 Failed to process                    : $processed_failed"
echo "⚠️  Skipped (No matching .srt found)    : ${#missing_subs[@]}"
echo "=================================================="