#!/bin/bash

# -----------------------------------------------------
# Themed Screen Locker
# -----------------------------------------------------
# Description: This script locks the screen using swaylock, with colors
# dynamically sourced from the current pywal theme.
#
# Dependencies: swaylock, pywal
# -----------------------------------------------------

# Get colors from pywal cache
source "$HOME/.cache/wal/colors.sh"

swaylock \
    --screenshots \
    --clock \
    --indicator \
    --indicator-radius 100 \
    --indicator-thickness 7 \
    --effect-blur 7x5 \
    --effect-vignette 0.5:0.5 \
    --ring-color "$background" \
    --key-hl-color "$color2" \
    --line-color "$background" \
    --inside-color "$color1" \
    --separator-color "$background" \
    --grace 2 \
    --fade-in 0.2
