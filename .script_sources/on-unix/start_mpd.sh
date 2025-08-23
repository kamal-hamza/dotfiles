#!/bin/bash

# Check if MPD is already responsive.
# The 'mpc' command will fail if it can't connect.
if ! mpc status > /dev/null 2>&1; then
  echo "MPD not running. Starting it now..."
  # Start mpd in the background
  mpd &
fi
