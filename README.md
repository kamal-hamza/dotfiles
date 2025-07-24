# My Dotfiles

These are my personal dotfiles, which I use to configure my development environment across macOS, Arch Linux, and Windows. They are managed with `chezmoi`, which allows for easy installation and management of configuration files across multiple machines.

# Install

To install and apply the dotfiles to your system, run this one-liner:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kamal-hamza
```

# Features

- **Cross-Platform Support:** These dotfiles are designed to be compatible with macOS, Arch Linux, and Windows, with platform-specific configurations handled by `chezmoi`.
- **Automated Setup:** The installation scripts automate the setup process by installing necessary packages and applications for each operating system.
- **Terminal-Based Music Player:** The configuration includes `mpd` and `ncmpcpp` for a terminal-based music player experience, with features like a visualizer and album art display.
- **Custom Neovim Configuration:** A comprehensive Neovim setup with a wide range of plugins for a better development experience. This includes LSP support, a debugger, and a variety of other tools.
- **Script Management:** A collection of scripts to automate common tasks, such as creating and deleting projects.

# Shell Customizations

My shell is customized for a more efficient and user-friendly experience. Here are some of the key features:

- **Aliases:** I use a variety of aliases to shorten common commands. For example, `l` is an alias for `ls -la`.
- **Autosuggestions:** The shell provides autosuggestions based on your command history, which can be completed by pressing the right arrow key.
- **Syntax Highlighting:** Commands and their arguments are highlighted in different colors, making it easier to read and debug commands.

Here are some of the custom aliases I use:

| Alias | Command      | Description                                          |
| :---- | :----------- | :--------------------------------------------------- |
| `l`   | `ls -la`     | List files in a long format, including hidden files. |
| `..`  | `cd ..`      | Go up one directory.                                 |
| `...` | `cd ../..`   | Go up two directories.                               |
| `g`   | `git`        | Git command.                                         |
| `ga`  | `git add`    | Add file contents to the index.                      |
| `gc`  | `git commit` | Record changes to the repository.                    |
| `gp`  | `git push`   | Update remote refs along with associated objects.    |

# Supported OS

- Arch Linux
- macOS
- Windows
