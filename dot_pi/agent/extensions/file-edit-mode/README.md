# File Edit Mode Extension

Control how the agent handles file creation and editing operations.

## Installation

Auto-installed at:
```
~/.pi/agent/extensions/file-edit-mode/
```

## Modes

### Auto Mode (default)
Files are created and edited without requiring confirmation. The agent can modify files freely.

### Strict Mode
User is prompted to confirm every file creation and edit operation, with a content preview.

## Usage

### /file-mode auto
Switch to auto mode (no confirmation needed):
```
/file-mode auto
```

### /file-mode strict
Switch to strict mode (confirmation required):
```
/file-mode strict
```

### /file-mode status
Show current mode:
```
/file-mode status
```

### /file-mode
Without arguments, shows status:
```
/file-mode
```

## Examples

### Auto Mode
```
/file-mode auto
File Edit Mode: AUTO (no confirmation required)

Agent: I'll create a new config file
$ write: ~/config.yaml
(file created without confirmation)
```

### Strict Mode
```
/file-mode strict
File Edit Mode: STRICT (confirmation required)

Agent: Let me update that file
$ edit: ~/src/main.ts

File Edit
Edit file:
~/src/main.ts

Edits: 3
  - Replace: "const x = 1"
  - Replace: "return false"

Allow? [y/n]
```

User approves: File edit approved, operation continues
User declines: File edit cancelled by user, operation blocked

## Behavior

### In Auto Mode
- All file write operations execute without prompts
- All file edit operations execute without prompts
- Use when you trust the agent's file modifications

### In Strict Mode
- User prompted before creating new files
- User prompted before editing existing files
- Shows content preview for writes
- Shows edit count and first 2 edits for multi-edit operations
- All confirmations logged to session history

## Session Behavior

- Mode is saved to session history
- New sessions start in auto mode (safe default)
- Forked or resumed sessions inherit previous mode
- Mode persists for current session only (resets on new session)

## Approvals

All confirmed file operations are logged to the session with:
- Tool name (write/edit)
- File path
- Timestamp
- Approval status

View approval history in session entries.

## Integration with Permission Guard

This extension works independently but can be used alongside the Permission Guard extension:

- **Permission Guard**: Controls which bash commands can be run
- **File Edit Mode**: Controls file creation/editing operations

Use both to comprehensively control the agent's file system access.

## Chezmoi Integration

Managed by chezmoi:

```bash
# Apply
chezmoi apply

# Verify
chezmoi diff
```

## Notes

- Default mode is auto for new sessions
- Mode changes apply immediately to new file operations
- Content previews are truncated at 200 characters for writes
- Edit previews show up to 2 edits by default
- All confirmations are user-interactive (requires TTY in interactive mode)
