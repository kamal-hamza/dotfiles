#!/bin/bash
#
# fzf-run.sh
#
# Fuzzy-find a Docker image, choose a command, and run the container.
# This command is executed directly by the script.
#
# Dependencies: fzf, docker
#
# Alias example:
#   alias r='/path/to/fzf-run.sh'

# Ensure fzf and docker are installed.
if ! command -v fzf &> /dev/null; then
    echo "Error: Required command 'fzf' not found. Please install it to continue." >&2
    exit 1
fi
if ! command -v docker &> /dev/null; then
    echo "Error: Required command 'docker' not found. Please install it to continue." >&2
    exit 1
fi

# Step 1: Select a Docker image using fzf.
image=$(docker images --format "{{.Repository}}:{{.Tag}}" | fzf --height 40% --border --prompt="Select Docker Image > ")

# Exit if no image was selected.
if [[ -z "$image" ]]; then
    echo "No image selected." >&2
    exit 1
fi

# Step 2: Provide a list of common commands for selection.
commands=("bash" "sh" "ash" "zsh" "powershell" "cmd" "ls -la" "top" "ps aux")
command=$(printf "%s\n" "${commands[@]}" | fzf --height 40% --border --prompt="Select or type command > ")

# Exit if no command was provided.
if [[ -z "$command" ]]; then
    echo "No command provided." >&2
    exit 1
fi

# Step 3: Run the container.
echo "Executing: docker run -it --rm \"$image\" $command"
# The <&1 redirects the container's stdin to the script's stdin, making it interactive.
docker run -it --rm "$image" $command <&1
