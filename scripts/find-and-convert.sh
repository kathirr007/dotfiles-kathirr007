#!/usr/bin/env bash

# --- fuzzy match without fzf ---
fuzzy_match() {
  local pattern="${1,,}" str="${2,,}"
  local i=0
  for (( j=0; j<${#str}; j++ )); do
    [[ "${str:$j:1}" == "${pattern:$i:1}" ]] && (( i++ ))
    [[ $i -eq ${#pattern} ]] && return 0
  done
  return 1
}

# --- ensure fzf available ---
use_fzf=false
if command -v fzf &>/dev/null; then
  use_fzf=true
else
  echo "fzf is not installed."
  read -rp "Install fzf? [y/n]: " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    if command -v brew &>/dev/null; then
      brew install fzf && use_fzf=true
    elif command -v apt-get &>/dev/null; then
      sudo apt-get install -y fzf && use_fzf=true
    elif command -v pacman &>/dev/null; then
      sudo pacman -S --noconfirm fzf && use_fzf=true
    elif command -v winget &>/dev/null; then
      winget install junegunn.fzf && use_fzf=true
    else
      echo ""
      echo "Could not auto-install. Install fzf manually:"
      echo "  brew:    brew install fzf"
      echo "  apt:     sudo apt-get install fzf"
      echo "  pacman:  sudo pacman -S fzf"
      echo "  winget:  winget install junegunn.fzf"
      echo "  manual:  https://github.com/junegunn/fzf#installation"
      echo ""
      echo "Falling back to built-in fuzzy search."
    fi
  else
    echo "Using built-in fuzzy search."
  fi
fi

# --- collect all videos ---
mapfile -t all_videos < <(find . -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" -o -iname "*.flv" -o -iname "*.wmv" -o -iname "*.m4v" \) 2>/dev/null)

if [[ ${#all_videos[@]} -eq 0 ]]; then
  echo "No videos found."
  exit 1
fi

# --- select file ---
if $use_fzf; then
  input=$(printf '%s\n' "${all_videos[@]}" | fzf --prompt="Search video: ")
  [[ -z "$input" ]] && { echo "No file selected."; exit 1; }
else
  read -rp "Enter filename to search: " query
  mapfile -t files < <(for f in "${all_videos[@]}"; do
    fuzzy_match "$query" "$(basename "$f")" && echo "$f"
  done)

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No videos found matching '$query'."
    exit 1
  fi

  echo ""
  for i in "${!files[@]}"; do echo "  $((i+1))) ${files[$i]}"; done
  echo ""
  read -rp "Select file number: " sel
  [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#files[@]} )) || { echo "Invalid selection."; exit 1; }
  input="${files[$((sel-1))]}"
fi

# --- select format ---
echo ""
echo "Select output format:"
formats=(mp4 mkv avi mov webm flv wmv)
if $use_fzf; then
  ext=$(printf '%s\n' "${formats[@]}" | fzf --prompt="Select output format: ")
  [[ -z "$ext" ]] && { echo "No format selected."; exit 1; }
else
  for i in "${!formats[@]}"; do echo "  $((i+1))) ${formats[$i]}"; done
  echo ""
  read -rp "Select format number: " fmt
  [[ "$fmt" =~ ^[0-9]+$ ]] && (( fmt >= 1 && fmt <= ${#formats[@]} )) || { echo "Invalid selection."; exit 1; }
  ext="${formats[$((fmt-1))]}"
fi

# --- select resolution ---
echo ""
echo "Select output resolution:"
resolutions=(
  "3840x2160 (4K UHD)"
  "2560x1440 (2K QHD)"
  "1920x1080 (1080p FHD)"
  "1280x720  (720p HD)"
  "854x480   (480p SD)"
  "640x360   (360p)"
  "426x240   (240p)"
  "Keep original"
)
if $use_fzf; then
  res_choice=$(printf '%s\n' "${resolutions[@]}" | fzf --prompt="Select resolution: ")
  [[ -z "$res_choice" ]] && { echo "No resolution selected."; exit 1; }
else
  for i in "${!resolutions[@]}"; do echo "  $((i+1))) ${resolutions[$i]}"; done
  echo ""
  read -rp "Select resolution number: " res_num
  [[ "$res_num" =~ ^[0-9]+$ ]] && (( res_num >= 1 && res_num <= ${#resolutions[@]} )) || { echo "Invalid selection."; exit 1; }
  res_choice="${resolutions[$((res_num-1))]}"
fi

# Map choice to ffmpeg scale filter
case "$res_choice" in
  "3840x2160 (4K UHD)")  scale_filter="scale=3840:2160:force_original_aspect_ratio=decrease,pad=3840:2160:-1:-1:color=black" ;;
  "2560x1440 (2K QHD)")  scale_filter="scale=2560:1440:force_original_aspect_ratio=decrease,pad=2560:1440:-1:-1:color=black" ;;
  "1920x1080 (1080p FHD)") scale_filter="scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black" ;;
  "1280x720  (720p HD)")  scale_filter="scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:-1:-1:color=black" ;;
  "854x480   (480p SD)")  scale_filter="scale=854:480:force_original_aspect_ratio=decrease,pad=854:480:-1:-1:color=black" ;;
  "640x360   (360p)")     scale_filter="scale=640:360:force_original_aspect_ratio=decrease,pad=640:360:-1:-1:color=black" ;;
  "426x240   (240p)")     scale_filter="scale=426:240:force_original_aspect_ratio=decrease,pad=426:240:-1:-1:color=black" ;;
  "Keep original")        scale_filter="" ;;
  *)                      scale_filter="" ;;
esac

# --- build ffmpeg options per format ---
# Priority: speed > compression, quality must remain good
#   H.264 CRF: 18=visually lossless, 23=default good, 26=acceptable
#   H.265 CRF: 24=visually lossless, 28=default good, 30=acceptable
#   VP9  CRF:  31=good quality, 33=default balance
#   Presets: ultrafast/superfast/veryfast/faster/fast/medium/slow/slower/veryslow
#   Faster preset = quicker encode, slightly larger file, same visual quality at same CRF
get_ffmpeg_opts() {
  local fmt="$1"
  case "$fmt" in
    mp4)
      # H.264 + AAC — fast preset keeps encode quick; CRF 22 still looks great
      echo "-c:v libx264 -crf 22 -preset fast -profile:v high -level 4.1 \
            -movflags +faststart \
            -c:a aac -b:a 192k -ar 48000"
      ;;
    mkv)
      # H.265/HEVC + AAC — medium preset; H.265 is slower to encode so medium is the speed/quality sweet spot
      echo "-c:v libx265 -crf 26 -preset medium -tag:v hvc1 \
            -c:a aac -b:a 192k -ar 48000"
      ;;
    webm)
      # VP9 + Opus — cpu-used 4 is fast mode; deadline good balances speed and quality
      echo "-c:v libvp9 -crf 33 -b:v 0 -deadline good -cpu-used 4 \
            -row-mt 1 \
            -c:a libopus -b:a 128k -ar 48000"
      ;;
    avi)
      # MPEG-4 + MP3 — legacy format; q:v 5 is fast and still decent quality
      echo "-c:v mpeg4 -q:v 5 -vtag xvid \
            -c:a libmp3lame -q:a 2 -ar 48000"
      ;;
    mov)
      # H.264 + AAC — Apple QuickTime; fast preset same as mp4
      echo "-c:v libx264 -crf 22 -preset fast -profile:v high \
            -c:a aac -b:a 192k -ar 48000"
      ;;
    flv)
      # H.264 + AAC — Flash legacy; faster preset suits this low-priority format
      echo "-c:v libx264 -crf 23 -preset faster \
            -c:a aac -b:a 128k -ar 44100"
      ;;
    wmv)
      # WMV2 + WMA — Windows Media; q:v 5 encodes quickly with acceptable quality
      echo "-c:v wmv2 -q:v 5 \
            -c:a wmav2 -b:a 192k -ar 48000"
      ;;
    *)
      echo ""
      ;;
  esac
}

# --- assemble and run ffmpeg ---
output="${input%.*}.converted.${ext}"
codec_opts=$(get_ffmpeg_opts "$ext")

echo ""
echo "Input:      $input"
echo "Output:     $output"
echo "Format:     $ext"
echo "Resolution: $res_choice"
echo ""

# Build filter chain
if [[ -n "$scale_filter" ]]; then
  vf_opts=(-vf "$scale_filter")
else
  vf_opts=()
fi

# shellcheck disable=SC2086
ffmpeg -i "$input" \
  "${vf_opts[@]}" \
  $codec_opts \
  "$output" \
  && echo "" \
  && echo "Done: $output"
