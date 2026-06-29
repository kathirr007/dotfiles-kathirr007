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

# --- convert ---
output="${input%.*}.converted.${ext}"
echo ""
echo "Converting: $input -> $output"
ffmpeg -i "$input" "$output" && echo "Done: $output"
