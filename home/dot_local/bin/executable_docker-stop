#!/bin/bash
#
# docker-stop.sh
#
# Interactively select and stop running Docker containers using fzf.
# You can select multiple containers by pressing Tab or Shift+Tab.
#
# Dependencies: fzf, docker

# Ensure fzf and docker are installed.
if ! command -v fzf &> /dev/null; then
    echo "Error: Required command 'fzf' not found. Please install it to continue." >&2
    exit 1
fi
if ! command -v docker &> /dev/null; then
    echo "Error: Required command 'docker' not found. Please install it to continue." >&2
    exit 1
fi

# Get the list of running containers, formatted with headers for clarity.
# Pipe this list into fzf for interactive selection.
# The --multi flag allows selecting multiple containers.
# The --header-lines=1 flag tells fzf to treat the first line as a static header.
containers_to_stop=$(docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}" | \
fzf --height 40% --border --multi --header-lines=1 --prompt="Select containers to STOP > ")

# If no containers were selected (e.g., user pressed Esc), exit gracefully.
if [[ -z "$containers_to_stop" ]]; then
    echo "No containers selected to stop."
    exit 0
fi

# Extract just the container IDs from the selected lines.
# awk '{print $1}' prints the first column of each selected line.
container_ids=$(echo "$containers_to_stop" | awk '{print $1}')

# Stop the selected containers.
# The container_ids are passed as arguments to `docker stop`.
echo "Stopping the following containers:"
echo "$container_ids"
echo "$container_ids" | xargs docker stop