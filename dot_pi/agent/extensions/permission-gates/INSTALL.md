# Permission Gates - Installation & Setup

## Prerequisites

- Pi coding agent (v0.70+)
- Node.js 18+ (included with Pi)
- Bash or sh for command execution

## Installation Methods

### Method 1: Global Installation (Recommended)

Install for all your projects:

```bash
# 1. Create extensions directory
mkdir -p ~/.pi/agent/extensions

# 2. Copy extension
cp -r permission-gates ~/.pi/agent/extensions/

# 3. Verify
ls -la ~/.pi/agent/extensions/permission-gates/
```

**Verify Installation:**

Start Pi in any project:
```bash
pi

# You should see:
# [PERMISSION GATES] active (strict mode)
```

### Method 2: Project-Local Installation

Install for a specific project:

```bash
# 1. In your project directory
cd /path/to/your/project

# 2. Create local extensions directory
mkdir -p .pi/extensions

# 3. Copy extension
cp -r /path/to/permission-gates .pi/extensions/

# 4. Verify
ls -la .pi/extensions/permission-gates/
```

**Verify Installation:**

```bash
# In the project directory
pi

# Should see the notification
```

### Method 3: Using Pi Packages

Add to `~/.pi/settings.json`:

```json
{
  "extensions": [
    "~/.pi/agent/extensions/permission-gates"
  ]
}
```

## First Run

### Step 1: Start Pi

```bash
cd ~/my-project
pi
```

### Step 2: Check Extension Loaded

Look for:
```
[PERMISSION GATES] active (strict mode)
```

### Step 3: Test Basic Command

```bash
# Safe command (should work immediately)
ls -la

# Dangerous command (should prompt)
```

### Step 4: Verify Gates Work

Try a dangerous command and confirm it prompts:

```
You: Run "rm -rf /tmp/test"

Expected:
[SEVERE] Destructive operation

Command: rm -rf /tmp/test

[WARNING] Tips:
- This will permanently delete files
- Make sure you have backups
- Double-check the path

Allow? [Y/n]
```

## Configuration

### Default Configuration

The extension works out-of-the-box with defaults:

```json
{
  "dangerLevel": "strict",
  "auditLog": true,
  "auditFile": "~/.pi/permission-gates-audit.log",
  "enableWhitelist": true,
  "whitelist": [
    "^rm -f /tmp/[a-z0-9_-]+\\.(tmp|log)$",
    "^mkdir -p .*$",
    "^ls .*$"
  ]
}
```

### Custom Configuration

Create or edit `~/.pi/permission-gates-config.json`:

```json
{
  "dangerLevel": "moderate",
  "auditLog": true,
  "auditFile": "~/.pi/permission-gates-audit.log",
  "enableWhitelist": true,
  "whitelist": [
    "^rm -f /tmp/.*\\.log$",
    "^docker rm -f test-.*$",
    "^sudo apt update$"
  ]
}
```

**Options:**

| Option | Values | Default |
|--------|--------|---------|
| `dangerLevel` | strict, moderate, permissive | strict |
| `auditLog` | true, false | true |
| `auditFile` | path | ~/.pi/permission-gates-audit.log |
| `enableWhitelist` | true, false | true |
| `whitelist` | regex patterns | [see defaults] |

### Apply Configuration

The extension loads config on every session start. Just edit the file:

```bash
# 1. Edit config
nano ~/.pi/permission-gates-config.json

# 2. Save

# 3. Start new Pi session
pi

# New config takes effect
```

## Chezmoi Integration

If using dotfiles with chezmoi:

### 1. Add to Chezmoi Source

```bash
cd ~/.local/share/chezmoi

# Create extension directory
mkdir -p dot_pi/extensions

# Copy extension
cp -r /path/to/permission-gates dot_pi/extensions/
```

### 2. Update .gitignore

```bash
# Don't version the audit log
echo ".pi/permission-gates-audit.log" >> .gitignore
```

### 3. Create Config Template

```bash
# Create config template for chezmoi
cat > dot_pi/dot_permission-gates-config.json.tmpl << 'EOF'
{
  "dangerLevel": {{ .dangerLevel | default "strict" | tojson }},
  "auditLog": true,
  "auditFile": "~/.pi/permission-gates-audit.log",
  "enableWhitelist": true,
  "whitelist": [
    "^rm -f /tmp/.*\\.log$",
    "^mkdir -p .*$",
    "^ls .*$"
  ]
}
EOF
```

### 4. Apply

```bash
chezmoi apply

# Extension installed globally
# Config will be at ~/.permission-gates-config.json
```

## Verification

### Check Installation

```bash
# Verify files exist
test -f ~/.pi/agent/extensions/permission-gates/index.ts && echo "OK" || echo "FAILED"

# Verify permissions
ls -l ~/.pi/agent/extensions/permission-gates/index.ts
# Should be: -rw-r--r--
```

### Check Cache Directories

```bash
# Create audit directory
mkdir -p ~/.pi

# Verify writable
touch ~/.pi/test.txt && rm ~/.pi/test.txt && echo "OK" || echo "FAILED"
```

### Test Extension

```bash
# Start Pi with debug
pi

# In session, test command
/permission-gates status

# Should show current configuration
```

### Verify Gates Work

```bash
# Ask Pi to run something dangerous
# In Pi:

You: "Show me what happens with: rm -rf /tmp/test-dir"

# Should prompt with [SEVERE] level confirmation dialog
```

## Troubleshooting

### Extension Not Loading

**Symptom:** No "[PERMISSION GATES]" notification on session start

**Check 1: File location**
```bash
ls -la ~/.pi/agent/extensions/permission-gates/index.ts
# Should exist and be readable
```

**Check 2: Permissions**
```bash
ls -l ~/.pi/agent/extensions/permission-gates/index.ts
# Should show: -rw-r--r-- (or -rwxr-xr-x)
# If not, run: chmod 644 index.ts
```

**Check 3: Syntax**
```bash
# Try loading directly
pi -e ~/.pi/agent/extensions/permission-gates/index.ts

# Should start without errors
```

**Check 4: Pi version**
```bash
pi --version
# Should be 0.70 or higher
```

### Commands Not Being Gated

**Symptom:** Dangerous commands run without confirmation

**Check 1: Threat level**
```bash
/permission-gates status

# Should show: Mode: strict (or your chosen level)
```

**Check 2: Command matches pattern**
```bash
# Try a clearly dangerous command
rm -rf /tmp/test

# Should prompt with [SEVERE]
```

**Check 3: Not in whitelist**
```bash
# Check if accidentally whitelisted
cat ~/.pi/permission-gates-config.json | grep whitelist

# Your command shouldn't match any patterns
```

**Solution:**
```bash
/permission-gates level strict
# Changes to strict mode
```

### Too Many Confirmations

**Symptom:** Safe commands prompt unnecessarily

**Solution 1: Adjust threat level**
```bash
/permission-gates level moderate
# Only gates high-risk operations
```

**Solution 2: Add to whitelist**

Edit `~/.pi/permission-gates-config.json`:

```json
{
  "whitelist": [
    "^ls .*$",
    "^mkdir -p .*$",
    "^cat .*$"
  ]
}
```

Whitelisted patterns skip confirmation.

### Configuration Not Loading

**Symptom:** Changes to config file don't take effect

**Solution:**
```bash
# Restart Pi session
exit
pi

# New config loads on session start
```

**Check config file:**
```bash
# Verify syntax is valid JSON
python3 -m json.tool ~/.pi/permission-gates-config.json

# Should show formatted JSON without errors
```

### Audit Log Not Writing

**Symptom:** Commands not recorded in audit log

**Check 1: Log location**
```bash
ls -l ~/.pi/permission-gates-audit.log
# Should exist and be writable
```

**Check 2: Directory exists**
```bash
mkdir -p ~/.pi
# Ensure directory exists
```

**Check 3: Audit enabled**
```bash
cat ~/.pi/permission-gates-config.json | grep auditLog
# Should show: "auditLog": true
```

**Check 4: Permissions**
```bash
# Make directory writable
chmod 755 ~/.pi
```

## Updates

### Manual Update

```bash
# Get latest version
cd /tmp
git clone https://github.com/your-repo/pi-extensions
cp -r pi-extensions/permission-gates ~/.pi/agent/extensions/

# Restart Pi
```

### Via Chezmoi

```bash
# In your dotfiles source
cd ~/.local/share/chezmoi

# Copy updated files
cp -r /path/to/permission-gates dot_pi/extensions/

# Apply
chezmoi apply
```

## Uninstallation

### Remove Global Installation

```bash
rm -rf ~/.pi/agent/extensions/permission-gates
```

### Remove Project Installation

```bash
cd /path/to/project
rm -rf .pi/extensions/permission-gates
```

### Clear Audit Log

```bash
rm ~/.pi/permission-gates-audit.log
rm ~/.pi/permission-gates-config.json
```

## Performance Tuning

### Reduce Confirmation Overhead

```bash
# Use moderate or permissive level
/permission-gates level moderate

# Or adjust whitelist to skip safe commands
```

### Large Projects

For large codebases with many commands:

```json
{
  "dangerLevel": "moderate",
  "whitelist": [
    "^ls .*$",
    "^cat .*$",
    "^find .*$",
    "^grep .*$",
    "^git status.*$",
    "^npm list.*$"
  ]
}
```

Reduces non-destructive prompts.

## Security Hardening

### Audit Log Rotation

```bash
# Keep last 1000 lines
tail -1000 ~/.pi/permission-gates-audit.log > /tmp/audit.tmp && mv /tmp/audit.tmp ~/.pi/permission-gates-audit.log
```

### Restrict Config File

```bash
# Lock config to owner only
chmod 600 ~/.pi/permission-gates-config.json
```

### Disable Audit Logging

```json
{
  "auditLog": false
}
```

(Not recommended - audit trail is security feature)

## Next Steps

1. **Read Quick Reference:** `QUICK-REFERENCE.md`
2. **See Examples:** `EXAMPLES.md`
3. **Try It Out:** Run dangerous command in Pi
4. **Adjust Settings:** Create config file
5. **Whitelist Patterns:** Add safe patterns

## Support

**Configuration Help:** See README.md for option details

**Extension Issues:** Check troubleshooting above

**General Pi Issues:** See Pi documentation

---

**Status:** Installation verified and ready to use!
