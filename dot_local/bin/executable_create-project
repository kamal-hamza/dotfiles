#!/usr/bin/env bash

# ==============================================================================
#
#          Advanced Project Creator & Tmux Session Manager
#
#  This script prompts for a project name, parent directory, and project type,
#  then creates the directory, initializes a project template, and opens it
#  in a new tmux session.
#
#  Dependencies: fzf, tmux, and the build tools for your chosen languages
#                (e.g., dotnet, node, python, rustc, go).
#
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Project Initialization Functions ---

# Each function is responsible for setting up a specific project type.
# They assume the current directory is the newly created project root.

init_dotnet_console() {
  echo "Initializing .NET Console App..."
  dotnet new console
}

init_react_vite() {
  echo "Initializing React (Vite) App..."
  # Use '.' to initialize in the current directory
  npm create vite@latest . -- --template react
}

init_c() {
  echo "Creating C boilerplate..."
  cat <<EOF > main.c
#include <stdio.h>

int main() {
    printf("Hello, C World!\\n");
    return 0;
}
EOF
  cat <<EOF > Makefile
CC=gcc
CFLAGS=-Wall -Wextra -std=c11
TARGET=main

all: \$(TARGET)

\$(TARGET): main.c
	\$(CC) \$(CFLAGS) -o \$(TARGET) main.c

clean:
	rm -f \$(TARGET)
EOF
}

init_cpp() {
  echo "Creating C++ boilerplate..."
  cat <<EOF > main.cpp
#include <iostream>

int main() {
    std::cout << "Hello, C++ World!" << std::endl;
    return 0;
}
EOF
  cat <<EOF > Makefile
CXX=g++
CXXFLAGS=-Wall -Wextra -std=c++17
TARGET=main

all: \$(TARGET)

\$(TARGET): main.cpp
	\$(CXX) \$(CXXFLAGS) -o \$(TARGET) main.cpp

clean:
	rm -f \$(TARGET)
EOF
}

init_python() {
  echo "Creating Python project with virtual environment..."
  python3 -m venv .venv
  echo ".venv/" > .gitignore
  echo "__pycache__/" >> .gitignore
  cat <<EOF > main.py
def main():
    print("Hello from Python!")

if __name__ == "__main__":
    main()
EOF
}

init_node() {
  echo "Initializing basic Node.js project..."
  npm init -y > /dev/null
  touch index.js
  echo "node_modules/" > .gitignore
}

init_go() {
  echo "Initializing Go module..."
  # The module path is simply the project name for local development
  go mod init "$PROJECT_NAME"
  cat <<EOF > main.go
package main

import "fmt"

func main() {
	fmt.Println("Hello, Go World!")
}
EOF
}

init_rust() {
  echo "Initializing Rust project with Cargo..."
  # Cargo needs to initialize into a directory, but we are already inside it.
  # We create it in a temp dir and move contents here.
  cargo init --quiet --name "$PROJECT_NAME" temp_rust_project
  # Move all files (including hidden ones) from the temp dir to the current dir
  mv temp_rust_project/* temp_rust_project/.[!.]* .
  rmdir temp_rust_project
}

init_django() {
  echo "Initializing Django project..."
  python3 -m venv .venv
  # Note: This requires manual activation of venv after setup
  # On Linux/macOS: source .venv/bin/activate
  # On Windows: .\.venv\Scripts\activate
  .venv/bin/pip install django > /dev/null
  .venv/bin/django-admin startproject "$PROJECT_NAME" .
  echo ".venv/" > .gitignore
  echo "db.sqlite3" >> .gitignore
}

init_expressjs() {
  echo "Initializing Express.js project..."
  npm init -y > /dev/null
  npm install express > /dev/null
  cat <<EOF > index.js
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from Express!');
});

app.listen(port, () => {
  console.log(\`Server listening at http://localhost:\${port}\`);
});
EOF
  echo "node_modules/" > .gitignore
}

init_nestjs() {
  echo "Initializing NestJS project..."
  # Nest CLI creates a new folder, so we create it and move contents up.
  npx --yes @nestjs/cli new temp_nest_project --skip-git --package-manager npm > /dev/null
  mv temp_nest_project/* temp_nest_project/.[!.]* .
  rmdir temp_nest_project
}

init_flask() {
  echo "Initializing Flask project..."
  python3 -m venv .venv
  .venv/bin/pip install Flask > /dev/null
  cat <<EOF > app.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

if __name__ == '__main__':
    app.run(debug=True)
EOF
  echo ".venv/" > .gitignore
}

init_generic() {
  echo "Created a generic project folder. No template applied."
}


# --- Main Script Logic ---

# 1. Get Project Name
read -rp "Project Name: " PROJECT_NAME
if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: Project name cannot be empty." >&2
  exit 1
fi

# 2. Select Parent Directory
# Use find and fzf to select a parent folder from ~/Code
# You can change ~/Code to whatever your main development directory is.
TARGET_DIR=$(find ~/Code -type d -mindepth 1 -maxdepth 1 | fzf --height 40% --reverse --prompt="Select parent folder: ")
if [[ -z "$TARGET_DIR" ]]; then
  echo "No directory selected. Exiting."
  exit 1
fi

# 3. Select Project Type
# Define a list of available project types.
project_types=(
  "dotnet-console"
  "react-vite"
  "expressjs"
  "nestjs"
  "django"
  "flask"
  "python"
  "rust"
  "c"
  "cpp"
  "go"
  "node"
  "generic"
)

# Use printf and fzf to present the selection menu
PROJECT_TYPE=$(printf "%s\n" "${project_types[@]}" | fzf --height 40% --reverse --prompt="Select project type: ")
if [[ -z "$PROJECT_TYPE" ]]; then
  echo "No project type selected. Exiting."
  exit 1
fi

# 4. Create Project Directory & Initialize Template
PROJECT_PATH="$TARGET_DIR/$PROJECT_NAME"

if [[ -d "$PROJECT_PATH" ]]; then
  echo "Directory '$PROJECT_PATH' already exists."
else
  mkdir -p "$PROJECT_PATH"
  echo "✅ Created project folder at: $PROJECT_PATH"
fi

# Change into the new directory to run initialization commands
cd "$PROJECT_PATH"

echo "⚙️  Initializing a '$PROJECT_TYPE' project..."

# Call the appropriate function based on the selected project type
case $PROJECT_TYPE in
  "dotnet-console") init_dotnet_console ;;
  "react-vite")     init_react_vite ;;
  "c")              init_c ;;
  "cpp")            init_cpp ;;
  "python")         init_python ;;
  "node")           init_node ;;
  "go")             init_go ;;
  "rust")           init_rust ;;
  "django")         init_django ;;
  "expressjs")      init_expressjs ;;
  "nestjs")         init_nestjs ;;
  "flask")          init_flask ;;
  "generic")        init_generic ;;
  *)
    echo "Unknown project type. Creating a generic folder." >&2
    init_generic
    ;;
esac

echo "🚀 Project setup complete!"

# 5. Open in Tmux
if tmux has-session -t "$PROJECT_NAME" 2>/dev/null; then
  echo "Tmux session '$PROJECT_NAME' already exists. Attaching..."
else
  # Create the session in detached mode (-d) pointing to the new project path
  tmux new-session -s "$PROJECT_NAME" -c "$PROJECT_PATH" -d
  echo "Created and detached new tmux session '$PROJECT_NAME'."
fi

# Attach to the session, whether it was new or existing
tmux attach-session -t "$PROJECT_NAME"