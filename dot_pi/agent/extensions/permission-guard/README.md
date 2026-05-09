# Permission Guard Extension

A Pi extension that acts as a security gatekeeper, preventing the agent from running potentially harmful commands.

## Features

- Blocks dangerous commands (rm -rf, dd, mkfs)
- Requires user confirmation for risky operations (sudo, git reset, etc.)
- Configurable regex-based pattern matching
- Audit trail of approvals
- Interactive commands to manage rules

## Installation

Auto-installed at:
```
~/.pi/agent/extensions/permission-guard/
```

Files:
- `index.ts` - Extension code
- `rules.json` - Permission rules

## Configuration

Edit `~/.pi/agent/extensions/permission-guard/rules.json` to customize rules:

```json
{
  "enabled": true,
  "defaultBehavior": "block",
  "rules": [
    {
      "pattern": "^rm\\s+.*(-r|-R).*",
      "severity": "block",
      "description": "Recursive deletion",
      "reason": "Potentially destructive"
    },
    {
      "pattern": "^sudo\\s+",
      "severity": "confirm",
      "description": "Sudo execution",
      "reason": "Elevated privileges"
    },
    {
      "pattern": "^ls.*",
      "severity": "allow",
      "description": "Safe read commands"
    }
  ]
}
```

### Severity Levels

| Level | Behavior |
|-------|----------|
| block | Command rejected immediately |
| confirm | User prompted for approval |
| allow | Command executes without restriction |

### Pattern Matching

Patterns are JavaScript regular expressions matched against bash commands.

Examples:
```
^rm\\s+.*(-r|-R).*       # rm with -r or -R flag
^sudo\\s+                 # Any sudo command
^(ls|cat|grep)           # Multiple commands
.*\\|\\s*bash            # Pipe to bash
```

## Default Rules

### Blocked Commands
- `rm -r`, `rm -rf` - Recursive deletion
- `dd` - Disk manipulation
- `mkfs` - Filesystem creation

### Require Confirmation
- `sudo` - Elevated privileges
- Destructive package operations
- `git reset --hard`, force push
- Redirects to system paths (`> /`)
- Chmod/chown on system directories
- Pipe to shell (`curl | bash`)

### Allowed
- Read-only commands (ls, cat, grep, find)
- Safe file operations in current directory

## Commands

### /permission-rules
View all active rules:
```
/permission-rules
```

### /permission-check <command>
Test if a command would be allowed:
```
/permission-check rm -rf /tmp/data
/permission-check sudo apt-get update
/permission-check ls -la
```

### /permission-toggle
Temporarily enable/disable protection:
```
/permission-toggle
```

## Customization

### Add Custom Rules

Edit `rules.json`:

```json
{
  "pattern": "^custom-dangerous-cmd",
  "severity": "block",
  "description": "Custom dangerous command",
  "reason": "Reason for blocking"
}
```

### Change Default Behavior

Update `defaultBehavior` in rules.json:

```json
{
  "enabled": true,
  "defaultBehavior": "allow",  // "block" | "confirm" | "allow"
  "rules": [...]
}
```

### Disable Temporarily

```
/permission-toggle
```

Or reload after editing rules.json:

```
/reload
```

## Examples

### Blocked Command
```
Agent: rm -rf /tmp/build
BLOCKED: Force recursive deletion
Reason: Force recursive deletion can cause irreversible data loss
```

### Requires Confirmation
```
Agent: sudo apt-get install build-essential

Permission Required
Sudo execution

Reason: Commands run with elevated privileges

Command:
sudo apt-get install build-essential

Allow this command? [y/n]
```

User declines: Command cancelled
User approves: Command approved, execution continues

### Allowed Command
```
Agent: ls -la
(executes normally)
```

## Troubleshooting

**Extension not loading:**
```bash
ls -la ~/.pi/agent/extensions/permission-guard/
/reload
```

**Rule not working as expected:**

1. Test with `/permission-check`
2. Verify regex syntax
3. Check if rule is `allow` (won't be blocked)
4. Reload: `/reload`

**Safe commands being blocked:**

Add specific `allow` rule before blocking rule in rules.json (rules are matched in order):

```json
{
  "pattern": "^rm\\s+small-test-file\\.txt",
  "severity": "allow",
  "description": "Specific safe deletion"
},
{
  "pattern": "^rm\\s+.*(-r|-R).*",
  "severity": "block",
  "description": "Recursive deletion"
}
```

## Chezmoi Integration

Managed by chezmoi:

```bash
# Apply
chezmoi apply

# Edit and sync back
chezmoi re-add dot_pi/agent/extensions/permission-guard/

# Verify
chezmoi diff
```

## Architecture

The extension intercepts bash commands via the `tool_call` event hook:

1. Agent prepares bash command
2. `tool_call` event fires
3. Permission Guard checks rules in order
4. Match found: apply severity (block/confirm/allow)
5. No match: apply `defaultBehavior`
6. Command executes or is blocked

## Security Notes

- Not a substitute for caution - always review agent commands
- Regex patterns can be bypassed with obfuscation
- Guards pi's agent only, not your system generally
- Approvals logged to session history

## Development

To improve default rules:

1. Edit `index.ts` (DEFAULT_CONFIG) or `rules.json`
2. Test with `/permission-check`
3. Sync back to chezmoi:
```bash
chezmoi re-add dot_pi/agent/extensions/permission-guard/
```
