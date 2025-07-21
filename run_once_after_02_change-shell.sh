#!/bin/bash
# vim: set ft=sh:

# Exit on error
set -e

# Check if Zsh is already the default shell
if [ "$SHELL" = "/usr/bin/zsh" ]; then
  echo "✔ Shell is already Zsh. Skipping."
  exit 0
fi

echo "› Changing default shell to Zsh..."

# Use chsh to change the shell for the current user
# This will prompt for the user's password
chsh -s /usr/bin/zsh

echo "✔ Shell changed successfully. Please log out and back in for the change to take effect."
