#!/bin/bash

for repo in issues/*; do
  if [[ ! -d "$repo" ]]; then
    continue
  fi
  name=${repo##*/}
  gh issue list -R "allensandiego/$name" -a "@me" --json number --jq '.[].number' | while read -r issue_num; do
    issue_dir="$repo/$issue_num"
    mkdir -p "$issue_dir"
    gh issue view "$issue_num" -R "allensandiego/$name" --json title,author,labels,body > "$issue_dir/issue_details.log"
    # Extract body field from JSON, then find image URLs (handles escaped characters properly)
    jq -r '.body' "$issue_dir/issue_details.log" | grep -oP 'https://github\.com/user-attachments/assets/[^)\s"]+' | while read -r url; do
      filename=$(basename "$url")
      echo "Downloading $filename to $issue_dir..."
      # Get content type from response headers
      content_type=$(curl -s -I -H "Authorization: token $(gh auth token)" -L "$url" | grep -i 'content-type' | cut -d':' -f2 | xargs)
      # Map content type to extension
      case "$content_type" in
        *"image/png"*) ext=".png" ;;
        *"image/jpeg"*) ext=".jpg" ;;
        *"image/gif"*) ext=".gif" ;;
        *"image/webp"*) ext=".webp" ;;
        *"image/svg"*) ext=".svg" ;;
        *) ext=".png" ;; # Default to png
      esac
      # Download with proper extension
      curl -s -H "Authorization: token $(gh auth token)" -L "$url" -o "$issue_dir/$filename$ext"
      if [[ -f "$issue_dir/$filename$ext" ]]; then
        echo "✓ Downloaded: $filename$ext"
      else
        echo "✗ Failed to download: $filename$ext"
      fi
    done
  done
done


