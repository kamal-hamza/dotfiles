#!/bin/bash

# Album Art Display Script for ncmpcpp (Unix-like systems)
# Requires: mpc, ffmpeg, chafa

# --- Configuration ---
# IMPORTANT: This MPD_MUSIC_DIR MUST match the 'music_directory' in your mpd.conf
# It needs to be the absolute path that MPD uses internally.
# For WSL, this might be something like "/mnt/c/Users/YourUser/Music" if your music is on the Windows C: drive.
# If MPD and your music are both inside WSL, then "$HOME/Music" is fine.
MPD_MUSIC_DIR="${XDG_MUSIC_DIR:-$HOME/Music}"
TEMP_ART_PATH="${XDG_CACHE_HOME:-$HOME/.cache}/ncmpcpp_album_art.png"

# Common album art filenames to look for in the music directory
ALBUM_ART_FILENAMES=("cover.jpg" "cover.png" "folder.jpg" "folder.png" "albumart.jpg" "albumart.png")

# Chafa command options
CHAFA_CMD=(chafa --clear --colors full --fill auto --dither none)
# Alternative chafa command for higher contrast on dark backgrounds or fewer colors:
# CHAFA_CMD=(chafa --clear --colors 256 --fill auto --dither none)

# --- Functions ---

clear_terminal_image() {
    # Send clear screen command if your terminal requires it, otherwise chafa --clear handles it.
    # For example, for Kitty terminal, you might use `kitty @ --clear`.
    # For general purpose, relying on chafa's --clear is usually enough.
    # If chafa fails or no art, clear with newlines to push old image off screen.
    printf "\n%.0s" {1..$(tput lines)} >&2 # Print newlines to stderr to clear previous output
    tput cuu $(tput lines) # Move cursor up to the top
    tput el # Clear to end of line
}

display_art() {
    local image_path="$1"
    if [[ -f "$image_path" ]]; then
        # Use chafa to display the image
        "${CHAFA_CMD[@]}" "$image_path" 2>/dev/null || true
    fi
}

get_current_song_file() {
    # Get current song file path from mpc
    mpc --format "%file%" current 2>/dev/null
}

extract_embedded_art() {
    local song_path="$1"
    # Extract embedded album art using ffmpeg
    # Output to stdout, then redirect to the temp file
    ffmpeg -i "$song_path" -map 0:v -map -0:V -c copy -y -f image2pipe "${TEMP_ART_PATH}" 2>/dev/null
    if [[ -s "${TEMP_ART_PATH}" ]]; then # Check if the output file is not empty
        echo "${TEMP_ART_PATH}"
    else
        rm -f "${TEMP_ART_PATH}" # Clean up empty file
        return 1
    fi
}

find_external_art() {
    local song_dir="$1"
    for filename in "${ALBUM_ART_FILENAMES[@]}"; do
        local art_path="${song_dir}/${filename}"
        if [[ -f "$art_path" ]]; then
            echo "$art_path"
            return 0
        fi
    done
    return 1
}

# --- Main Logic ---

# Ensure cache directory exists
mkdir -p "$(dirname "${TEMP_ART_PATH}")"

CURRENT_SONG_REL_PATH=$(get_current_song_file)

if [[ -z "$CURRENT_SONG_REL_PATH" ]]; then
    # No song playing, clear the image
    clear_terminal_image
    exit 0
fi

FULL_SONG_PATH="${MPD_MUSIC_DIR}/${CURRENT_SONG_REL_PATH}"

ART_TO_DISPLAY=""

# 1. Try to extract embedded art
if extract_embedded_art "$FULL_SONG_PATH"; then
    ART_TO_DISPLAY="${TEMP_ART_PATH}"
else
    # 2. If no embedded art, try to find external art in the directory
    SONG_DIR=$(dirname "$FULL_SONG_PATH")
    if find_external_art "$SONG_DIR"; then
        ART_TO_DISPLAY=$(find_external_art "$SONG_DIR")
    fi
fi

if [[ -n "$ART_TO_DISPLAY" ]]; then
    display_art "$ART_TO_DISPLAY"
else
    clear_terminal_image
fi

# Clean up temporary art file if it was extracted (not an external file)
if [[ "$ART_TO_DISPLAY" == "${TEMP_ART_PATH}" ]]; then
    rm -f "${TEMP_ART_PATH}"
fi

exit 0
