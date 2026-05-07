# Permission Gates - Quick Reference

## Installation (One-time)

```bash
mkdir -p ~/.pi/agent/extensions
cp -r permission-gates ~/.pi/agent/extensions/
# Extension auto-loads on next Pi session
```

## How It Works

When you ask Pi to run a dangerous command:
1. Command is intercepted
2. Risk assessment shown
3. User confirmation required
4. Action logged

## Common Commands

### Check Status
```bash
/permission-gates status
# Shows: Mode (strict/moderate/permissive), Audit status, Whitelist status
```

### Change Threat Level
```bash
/permission-gates level strict        # Most protective
/permission-gates level moderate      # Balanced
/permission-gates level permissive    # Least restrictive
```

### View Activity
```bash
/permission-gates log                 # Show recent commands
/permission-gates audit-file          # Show log file location
```

### Help
```bash
/permission-gates help                # Show all commands
```

## Threat Levels

| Level | What's Blocked | Use For |
|-------|---|---|
| **strict** | All dangerous ops | Default, safe development |
| **moderate** | High-risk ops | Experienced users |
| **permissive** | Only system-destroying | System admins |

## What Gets Blocked?

### CRITICAL (Always)
- `rm -rf /` - Delete from root
- `mkfs`, `dd` to filesystem
- `shred /` - Shred directories
- `wipefs` - Wipe partitions

### SEVERE
- `rm -r <path>` - Recursive delete
- `find . -delete` - Find delete
- `rsync --delete` - Sync delete
- `git clean -f` - Force clean

### ELEVATED
- `sudo <cmd>` - Any sudo
- `sudo -i`, `sudo -s` - Interactive

### SYSTEM
- `reboot`, `shutdown`, `poweroff`
- `halt`, `init 0`
- `killall -9` - Kill all processes

### NETWORK
- `iptables -F` - Flush firewall
- `ip rule del` - Delete routes
- `firewall-cmd` - Firewall changes

### PACKAGE
- `apt remove -y` - Force remove
- `npm uninstall -g npm` - Uninstall npm
- `pacman -Rc` - Remove package

### DATABASE
- `DROP DATABASE` - Delete database
- `DROP TABLE` - Delete table

## Confirmation Dialog

When blocked:
```
[DANGER_LEVEL] Description

Command: <your-command>

[WARNING] Tips:
- Specific risk assessment
- Action recommendations
- What could go wrong

Allow this command? [Y/n]
```

Choose:
- `Y` (or Enter) - Execute command
- `N` (or Escape) - Block command

## Whitelist

Create `~/.pi/permission-gates-config.json`:

```json
{
  "dangerLevel": "strict",
  "whitelist": [
    "^rm -f /tmp/.*\\.log$",
    "^sudo apt update$",
    "^docker rm -f test-.*$"
  ]
}
```

Whitelisted commands skip confirmation.

## Configuration File

Location: `~/.pi/permission-gates-config.json`

Options:
```json
{
  "dangerLevel": "strict",           // strict|moderate|permissive
  "auditLog": true,                  // Log all commands
  "auditFile": "~/.pi/permission-gates-audit.log",
  "enableWhitelist": true,           // Use whitelist patterns
  "whitelist": [                     // Regex patterns to allow
    "^rm -f /tmp/.*$"
  ]
}
```

## Audit Log

Location: `~/.pi/permission-gates-audit.log`

View:
```bash
tail -20 ~/.pi/permission-gates-audit.log
/permission-gates log
```

Format:
```
TIMESTAMP [STATUS] COMMAND (REASON)
2025-05-06T15:23:45.123Z [ALLOWED] rm -rf /tmp/old (Confirmed by user)
2025-05-06T15:24:12.456Z [DENIED] sudo reboot (User rejected)
```

## Examples

### Scenario 1: Delete Recursive

```
User: Delete /tmp/build

Pi: Runs rm -rf /tmp/build

Gate: Intercepts (SEVERE)
  Command: rm -rf /tmp/build
  Tips:
  - This will permanently delete files
  - Make sure you have backups
  - Double-check the path
  
User: Confirms → Executes
```

### Scenario 2: Sudo Install

```
User: Install nodejs

Pi: Runs sudo apt-get install nodejs

Gate: Intercepts (ELEVATED)
  Command: sudo apt-get install nodejs
  Tips:
  - Requires root privilege
  - Check if you trust this
  
User: Confirms → Executes
```

### Scenario 3: Whitelisted

```
User: Clean temp logs

Pi: Runs rm -f /tmp/build.log

Gate: Checks whitelist
  Pattern: ^rm -f /tmp/.*\.log$
  
Result: Allowed (no prompt)
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Command not blocked | Check level: `/permission-gates status` |
| Too many prompts | Add to whitelist in config |
| Audit log too large | `tail -1000 file > tmp && mv tmp file` |
| Extension not loading | Verify: `~/.pi/agent/extensions/permission-gates/` |

## Status Indicators

In Pi, watch for:
- `[PERMISSION GATES] active` - Extension loaded
- `[WAITING] Confirmation...` - Awaiting your choice
- `[BLOCKED]` or `[ALLOWED]` - Action taken

## Pro Tips

1. **Start strict** - Begin with "strict", relax only if needed
2. **Review confirmations** - Read the tips carefully
3. **Use whitelist** - Exempt genuinely safe patterns
4. **Check audit log** - Review what was allowed/blocked
5. **Trust but verify** - Always check commands before approving

## Quick Scenarios

### Development
```bash
/permission-gates level strict
# Protects against accidents while coding
```

### System Administration
```bash
/permission-gates level moderate
# Allows common sudo commands, blocks dangerous ops
```

### Scripting
```bash
/permission-gates level permissive
# Use with caution - only CRITICAL blocked
```

## Related Files

- Main: `permission-gates/index.ts`
- Docs: `permission-gates/README.md`
- Config: `~/.pi/permission-gates-config.json`
- Logs: `~/.pi/permission-gates-audit.log`

---

**TL;DR:** Extension blocks dangerous bash commands. When Pi tries `rm -rf /` or `sudo reboot`, you must confirm. Keeps your system safe from accidental destruction.
