# Permission Gates Extension for Pi

A protective security extension that intercepts and gates dangerous bash commands before execution. Requires explicit user confirmation for risky operations like `rm -rf /`, `sudo`, filesystem formatting, and system shutdowns.

## Features

- **Command Interception** - Catches dangerous bash commands before execution
- **Graduated Security** - Three threat levels: strict, moderate, permissive
- **Smart Detection** - Recognizes dangerous patterns (e.g., `rm -r /`, `sudo`, `mkfs`)
- **Whitelist Support** - Exempt safe patterns with regex
- **Audit Logging** - Records all gated commands and decisions
- **User Confirmation** - Clear UI prompts with risk assessment and tips
- **Runtime Configuration** - Change settings via `/permission-gates` command

## Installation

### Global Installation

```bash
mkdir -p ~/.pi/agent/extensions
cp -r permission-gates ~/.pi/agent/extensions/
```

### Project-Local Installation

```bash
mkdir -p .pi/extensions
cp -r permission-gates .pi/extensions/
```

## Quick Start

### Usage

The extension works automatically. When you ask Pi to run a dangerous command:

```
You: Run "rm -rf /tmp/old-project"

Pi: [PERMISSION GATES] Confirm dangerous command?
    [SEVERE] Destructive operation
    
    Command: rm -rf /tmp/old-project
    
    [WARNING] Tips:
    - This will permanently delete files
    - Make sure you have backups
    - Double-check the path is what you intend
    
    Allow this command?
```

You can then:
- **YES** - Allow the command to execute
- **NO** - Block the command

### Commands

```bash
/permission-gates status           # Show current settings
/permission-gates level strict     # Change threat level
/permission-gates log              # Show recent blocked commands
/permission-gates audit-file       # Show audit log location
/permission-gates help             # Show all commands
```

## Threat Levels

### Strict (Default)

Blocks all dangerous operations:
- Filesystem destruction (`rm -rf /`, `mkfs`, `dd` to fs)
- Recursive deletions (`find -delete`, `rm -r`)
- System control (`reboot`, `shutdown`, `poweroff`)
- Privilege escalation (`sudo`)
- Package removal
- Network configuration changes
- Database operations

**Use for:** Regular development, safety-first approach

### Moderate

Blocks high-risk operations:
- Filesystem destruction
- Recursive deletions
- System control
- Privilege escalation
- All critical operations

**Allows:** Simple sudo commands, package updates

**Use for:** Experienced users who run sudo frequently

### Permissive

Blocks only critical system-destroying operations:
- Filesystem destruction to root
- Format commands
- Multi-level recursion

**Use for:** System administration, automation

## Danger Categories

### CRITICAL (Always Blocked)

Commands that destroy filesystems:
```bash
rm -rf /                    # Recursive delete from root
mkfs /dev/sda              # Format disk
dd if=/dev/zero of=/dev/sda  # Overwrite disk
shred /                    # Shred root directory
wipefs /dev/sda            # Wipe filesystem
```

### SEVERE

Destructive file operations:
```bash
rm -rf <any path>          # Recursive deletion
find . -delete             # Find delete
rsync --delete             # Rsync delete
git clean -f               # Force git clean
cp /dev/zero ./file        # Overwrite with zeros
```

### ELEVATED

Privilege escalation:
```bash
sudo <any command>         # Any sudo
sudo -i                    # Interactive sudo
sudo -s                    # Sudo shell
```

### SYSTEM

System control:
```bash
reboot                     # Reboot system
shutdown -h now            # Shutdown
poweroff                   # Power off
halt                       # Halt system
init 0                     # Init runlevel 0
killall -9                 # Kill all processes
```

### NETWORK

Network changes:
```bash
iptables -F                # Flush firewall
ip rule del                # Delete routing rules
route del                  # Delete routes
firewall-cmd --set-default-zone  # Change firewall zone
```

### PACKAGE

Package management:
```bash
apt remove -y <pkg>        # Force remove package
npm uninstall -g npm       # Uninstall npm
pacman -Rc <pkg>           # Remove with dependencies
```

### DATABASE

Data operations:
```bash
mysql> DROP DATABASE prod;
psql=> DROP TABLE users;
```

## Whitelist

Exempt safe patterns using regex. Default whitelist includes:

```
^rm -f /tmp/[a-z0-9_-]+\.(tmp|log)$    # Remove temp files
^mkdir -p .*$                           # Create directories
^ls .*$                                 # List files
^cat .*$                                # Read files
^echo .*$                               # Echo commands
```

### Add Custom Whitelist

Edit `~/.pi/permission-gates-config.json`:

```json
{
  "dangerLevel": "strict",
  "enableWhitelist": true,
  "whitelist": [
    "^rm -f /tmp/build-.*\\.log$",
    "^docker rm -f test-.*$",
    "^rm -rf ~/.cache/pip$"
  ]
}
```

## Configuration

### Default Config

```json
{
  "dangerLevel": "strict",
  "auditLog": true,
  "auditFile": "~/.pi/permission-gates-audit.log",
  "enableWhitelist": true,
  "whitelist": [...]
}
```

### Custom Config File

Create `~/.pi/permission-gates-config.json`:

```json
{
  "dangerLevel": "moderate",
  "auditLog": true,
  "auditFile": "~/.pi/permission-gates-audit.log",
  "enableWhitelist": true,
  "whitelist": [
    "^sudo apt update$",
    "^sudo apt upgrade$",
    "^rm -rf /tmp/.*$"
  ]
}
```

The extension loads config automatically on startup.

## Audit Logging

All gated commands are logged to `~/.pi/permission-gates-audit.log`:

```
2025-05-06T15:23:45.123Z [ALLOWED] rm -rf /tmp/old-project (Confirmed by user)
2025-05-06T15:24:12.456Z [DENIED] sudo reboot (User rejected)
2025-05-06T15:25:30.789Z [BLOCKED] dd if=/dev/zero of=/dev/sda (Critical danger level)
```

View recent activity:
```bash
/permission-gates log

# Or manually:
tail -20 ~/.pi/permission-gates-audit.log
```

## How It Works

### Architecture

```
User asks Pi to run command
    |
    v
Pi attempts bash tool call
    |
    v
Permission Gates extension intercepts
    |
    +-- Check if dangerous? ---> Not dangerous --> Allow execution
    |
    +-- Check whitelist? ---> Whitelisted --> Allow execution
    |
    +-- Check threat level? ---> Below threshold --> Allow execution
    |
    v
Show confirmation dialog
    |
    +-- User confirms --> Log [ALLOWED] --> Execute
    |
    +-- User denies --> Log [DENIED] --> Block execution
    |
    v
Command blocked or executed
```

### Detection

Commands are analyzed via regex patterns matching:
- Command name
- Dangerous flags (e.g., `-r`, `-f`)
- Target paths (e.g., `/`, `/dev/*`)
- Combined patterns (e.g., `rm -rf /`)

### Confirmation UI

When a dangerous command is caught:

1. **Status message** - Shows danger level
2. **Command display** - Shows exact command (truncated if long)
3. **Risk assessment** - Specific warnings for this category
4. **Action tips** - Actionable advice
5. **Confirmation prompt** - Yes/No choice

## Examples

### Scenario 1: Rm Recursive

```
You: "Delete the old-project directory"

Pi: [SYSTEM] Executes:
    rm -rf ~/old-project

Permission Gates: Intercepts
    [SEVERE] Destructive operation
    
    Command: rm -rf ~/old-project
    
    [WARNING] Tips:
    - This will permanently delete files
    - Make sure you have backups
    - Double-check the path is what you intend
    
    Allow this command? [Y/n]
```

You review and confirm or deny.

### Scenario 2: Sudo Command

```
You: "Install nodejs globally"

Pi: [SYSTEM] Executes:
    sudo apt-get install -y nodejs

Permission Gates: Intercepts
    [ELEVATED] Requires root privilege
    
    Command: sudo apt-get install -y nodejs
    
    [WARNING] Tips:
    - This requires root/admin privileges
    - Only approve if you trust the command
    - Check the full command carefully
    
    Allow this command? [Y/n]
```

### Scenario 3: Whitelisted Command

```
You: "Clean up temp logs"

Pi: [SYSTEM] Executes:
    rm -f /tmp/build-2025-05-06.log

Permission Gates: Checks whitelist
    Pattern matches: ^rm -f /tmp/[a-z0-9_-]+\.(tmp|log)$
    
    -> Execution allowed (no confirmation needed)
```

## Troubleshooting

### Commands Not Being Gated

**Check threat level:**
```bash
/permission-gates status
```

**If set to "permissive":** Only CRITICAL commands are blocked.

**Solution:** Change level:
```bash
/permission-gates level strict
```

### False Positives (Blocking Safe Commands)

**Check whitelist:**
```bash
cat ~/.pi/permission-gates-config.json
```

**Add to whitelist:**
```json
{
  "whitelist": [
    "^rm -f /tmp/my-safe-file.txt$"
  ]
}
```

### Can't See Command Tips

**Verify extension loaded:**
```bash
pi -e ./index.ts
```

**Check command syntax:**
```bash
/permission-gates help
```

### Audit Log Growing Too Large

**Clear old entries:**
```bash
# Keep last 1000 lines
tail -1000 ~/.pi/permission-gates-audit.log > /tmp/audit.log && mv /tmp/audit.log ~/.pi/permission-gates-audit.log
```

**Disable audit logging:**
```json
{
  "auditLog": false
}
```

## Security Considerations

### What It Protects Against

- **Accidental destruction** - Catches typos before execution
- **Automated agent mistakes** - Stops LLM from running risky commands blindly
- **Cascading failures** - Breaks command chains at risky points
- **Cross-project pollution** - Prevents one project's deletion script from running in wrong place

### What It Doesn't Protect Against

- **Deliberate malice** - User can still approve dangerous commands
- **Blind approvals** - Doesn't prevent "click OK" without reading
- **Other tools** - Only protects bash tool, not direct filesystem access
- **Logic bombs** - Can't detect intent, only pattern

### Best Practices

1. **Read confirmation messages** - Don't blindly approve
2. **Use strict mode by default** - Relax only when needed
3. **Verify command text** - Check exact flags and paths
4. **Review audit log** - Check what was allowed/blocked
5. **Trust but verify** - Confirm agent commands manually

## Performance

- **Overhead:** <1ms per bash command
- **Pattern matching:** Regex compilation cached
- **Confirmation:** 1-5 seconds (user input)
- **Audit logging:** <10ms per entry

## Version History

### v1.0.0 (2025-05-06)

Initial release:
- Command interception
- Three threat levels
- Whitelist support
- Audit logging
- Runtime configuration

## License

Same as Pi extension framework. See Pi documentation.

## Related

- [Pi Extension Documentation](https://github.com/mariozechner/pi-coding-agent)
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- Linux/Unix command safety guides

---

**Protect your system:** Use Permission Gates to prevent destructive commands from running without confirmation.
