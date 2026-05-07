# Permission Gates - Practical Examples

## Quick Start

### 1. Installation

```bash
mkdir -p ~/.pi/agent/extensions
cp -r permission-gates ~/.pi/agent/extensions/
```

### 2. First Use

```bash
cd ~/my-project
pi

# Pi loads extension
# Status: [PERMISSION GATES] active (strict mode)
```

### 3. Try a Command

```
You: "Remove the old build directory"

Pi: Executes: rm -rf ./build

[Gate Intercepts]
[SEVERE] Destructive operation

Command: rm -rf ./build

[WARNING] Tips:
- This will permanently delete files
- Make sure you have backups
- Double-check the path is what you intend

Allow this command? [Y/n]
```

You decide: `Y` to execute, `N` to block.

---

## Scenario 1: Accidental System Destruction

**Situation:** You ask Pi to clean up a project, but there's a path error.

```bash
# Your request
"Clean up all temp files in the project"

# Pi (incorrectly) generates
rm -rf /tmp/*

# Without Permission Gates:
# -> Deletes everything in /tmp -> Disaster

# With Permission Gates:
# -> CRITICAL Intercepted
#    Command: rm -rf /tmp/*
#    Block required

You: Press 'N'
Result: Command blocked, nothing deleted
```

**Lesson:** Catches agent mistakes before they happen.

---

## Scenario 2: Sudo Awareness

**Situation:** Script needs to install packages.

```bash
# Your request
"Set up the development environment"

# Pi generates
sudo apt-get update && sudo apt-get install -y build-essential

# Gate Intercepts
[ELEVATED] Requires root privilege

Command: sudo apt-get update

[WARNING] Tips:
- Requires root/admin privileges
- Only approve if you trust the command
- Check the full command carefully

Allow this command? [Y/n]
```

**You review:** Is this trustworthy? Yes → Confirm

**Result:** Controlled privilege escalation

---

## Scenario 3: Whitelisted Safe Commands

**Situation:** Frequently clean temp files.

**Setup:** Create config file `~/.pi/permission-gates-config.json`

```json
{
  "dangerLevel": "strict",
  "whitelist": [
    "^rm -f /tmp/build-.*\\.log$",
    "^rm -f /tmp/test-.*\\.tmp$"
  ]
}
```

**Now:**

```bash
# Your request
"Clean temp build logs"

# Pi generates
rm -f /tmp/build-2025-05-06.log

# Gate checks whitelist
# Pattern matches: ^rm -f /tmp/build-.*\.log$

Result: Allowed (no confirmation needed)
```

**Benefit:** Safe patterns skip confirmation, dangerous ones still blocked.

---

## Scenario 4: Development Workflow

### Start Session (Strict Mode)

```bash
cd ~/project
pi

Status: [PERMISSION GATES] active (strict mode)
```

### Work Normally

```
You: "Create the directory structure for the new feature"
Pi: mkdir -p src/feature/{components,utils,types}
Result: Allowed (mkdir is safe)

You: "Install the required packages"
Pi: npm install axios express
Result: Allowed (npm install without -g is safe)
```

### Destructive Operation

```
You: "Remove old dependencies"
Pi: rm -rf node_modules

Gate Intercepts:
[SEVERE] Destructive operation

Command: rm -rf node_modules

[WARNING] Tips:
- This will permanently delete files
- Make sure you have backups
- Double-check the path is what you intend

Allow? [Y/n]
```

You: `Y` (You verified it's safe)

---

## Scenario 5: Multi-Stage Protection

### Stage 1: Detection

```bash
You: "Reset the database"
Pi: mysql -u root -p drop database prod;

Gate: DETECTED - DATABASE category
```

### Stage 2: Assessment

```
[DATABASE] Data loss risk

Command: mysql -u root -p drop database prod;

[WARNING] Tips:
- This will destroy database content
- Make sure backups exist
- Double-check database name
```

### Stage 3: Confirmation Required

```
User sees the command and realizes:
- "prod" - This is the PRODUCTION database!
- Not what I wanted

User: Press 'N'

Result: BLOCKED - Database saved
```

**Outcome:** Prevented production database destruction.

---

## Scenario 6: System Administration

### Task: Update System

```
Your request: "Update the system packages"

Pi: sudo apt update && sudo apt upgrade -y

Gate (Strict Mode):
[ELEVATED] Requires root privilege

You review:
- apt update - Safe, just checks updates
- apt upgrade - Safe, updates packages
- Approved for your system

You: Press 'Y'
Result: Executed
```

### Task: Change Firewall

```
Your request: "Open port 8080 for the dev server"

Pi: sudo ufw allow 8080

Gate:
[NETWORK] Network configuration

Command: sudo ufw allow 8080

[WARNING] Tips:
- This modifies network settings
- Could affect security
- Have recovery plan ready

You: Verify port 8080 is correct
Result: Press 'Y' to proceed
```

---

## Scenario 7: Git Operations

### Safe Git Operation

```
You: "Stash uncommitted changes"
Pi: git stash

Result: Allowed (git stash is safe)
```

### Dangerous Git Operation

```
You: "Remove all local changes"
Pi: git clean -fd

Gate Intercepts:
[SEVERE] Destructive operation

Command: git clean -fd

[WARNING] Tips:
- This will permanently delete files
- Make sure you have backups
- Double-check the path

You: Review untracked files
Result: Press 'Y' to proceed (or 'N' to keep files)
```

---

## Scenario 8: Docker Operations

### Safe Docker

```
You: "List all containers"
Pi: docker ps -a

Result: Allowed (read-only)
```

### Dangerous Docker (Whitelisted)

**Setup whitelist:**

```json
{
  "whitelist": [
    "^docker rm -f test-.*$",
    "^docker system prune -f$"
  ]
}
```

**Usage:**

```
You: "Clean up test containers"
Pi: docker rm -f test-service-123

Result: Allowed (matches whitelist pattern)
```

### Dangerous Docker (Not Whitelisted)

```
You: "Remove all images"
Pi: docker rmi $(docker images -q)

Gate Intercepts:
[SEVERE] Destructive operation

Command: docker rmi $(docker images -q)

You: Think about it
Result: Press 'Y' or 'N'
```

---

## Scenario 9: Threat Level Changes

### Start Strict

```bash
/permission-gates status
# Mode: strict

Your tasks:
- Regular development (all safe commands work)
- Dangerous commands require confirmation (protected)
```

### Relax for Maintenance

```bash
/permission-gates level moderate

Now runs: sudo apt update
Result: Allowed (moderate level allows simple sudo)

But still blocks:
- rm -rf / → CRITICAL blocked
- mkfs /dev/sda → CRITICAL blocked
- sudo reboot → SYSTEM blocked
```

### Return to Strict

```bash
/permission-gates level strict

Now requires confirmation for:
- sudo commands again
- All package removals
- Destructive operations
```

---

## Scenario 10: Audit Trail Review

### During Session

```bash
/permission-gates log

Recent Activity:
[ALLOWED] rm -rf ./build (Confirmed by user)
[ALLOWED] sudo apt-get install nodejs (Confirmed by user)
[DENIED] rm -rf / (User rejected)
[ALLOWED] mkdir -p src/components (Auto-allowed)
```

### Historical Review

```bash
# View full audit log
tail -50 ~/.pi/permission-gates-audit.log

2025-05-06T10:15:23.456Z [ALLOWED] npm install (Confirmed by user)
2025-05-06T10:16:45.789Z [DENIED] rm -rf node_modules (User rejected)
2025-05-06T10:17:12.123Z [ALLOWED] git clean -f (Confirmed by user)
2025-05-06T10:18:34.456Z [BLOCKED] sudo reboot (Critical danger level)
```

---

## Workflow Patterns

### Pattern 1: Discovery & Confirmation

```
1. Ask Pi to do something
2. Gate intercepts if dangerous
3. Read confirmation message
4. Make informed decision
5. Approve or reject
6. Action taken or blocked
```

### Pattern 2: Safe by Default

```
1. Set level to "strict"
2. Normal work (99% of commands allowed)
3. Dangerous commands require confirmation
4. Learn what's considered dangerous
5. Whitelist genuinely safe patterns
```

### Pattern 3: Audit & Trust

```
1. Enable audit logging (default)
2. Review what was allowed/blocked
3. Adjust whitelist based on your workflows
4. Build confidence in the system
5. Relax to "moderate" if appropriate
```

---

## Real-World Tips

### Tip 1: Read the Tips

When you see a confirmation:
```
[WARNING] Tips:
- This will permanently delete files
- Make sure you have backups
- Double-check the path
```

Actually read these. They highlight risks specific to the operation.

### Tip 2: Verify the Command

Always check the exact command shown:
```
Command: rm -rf /tmp/old-project
                ^-- Verify this path
```

Not just "rm -rf something" but the exact path.

### Tip 3: Trust Your Gut

If you're unsure:
- Press 'N' first
- Ask why the command is needed
- Understand it better
- Then approve if safe

### Tip 4: Whitelist Smart

Good whitelist patterns:
```
"^rm -f /tmp/.*\\.log$"      # Only temp logs
"^docker rm -f test-.*$"     # Only test containers
"^sudo apt update$"           # Only update, not upgrade
```

Bad whitelist patterns:
```
"^rm -rf .*$"                 # Allows all deletes
"^sudo.*$"                    # Allows all sudo
```

### Tip 5: Different Levels for Different Tasks

```bash
# During development - strict
/permission-gates level strict

# During system maintenance - moderate
/permission-gates level moderate

# After maintenance - back to strict
/permission-gates level strict
```

---

## Common Questions

**Q: Does this slow me down?**
A: Only for dangerous commands. Normal development is unaffected.

**Q: Can the agent bypass this?**
A: No. The gate is at Pi's extension level, not the agent's.

**Q: What if I accidentally press 'Y'?**
A: The command runs. That's why you should read the confirmation message before pressing.

**Q: Can I disable this?**
A: Yes, but not recommended. You can whitelist patterns or relax the threat level instead.

**Q: What about non-bash tools?**
A: This only gates bash commands. Other tools aren't protected (by design - too broad).

---

## Practice Scenarios

### Exercise 1: Safe vs Dangerous

```
Command: ls -la /home
Result: Allowed (read-only)

Command: rm -f /home/file.txt
Result: Gate intercepts (destructive)

Command: sudo ls /root
Result: Gate intercepts (sudo, even though read-only)
```

### Exercise 2: Whitelist Creation

Create config for your workflow:
```json
{
  "dangerLevel": "strict",
  "whitelist": [
    "^rm -f /tmp/.*$",
    "^rm -rf ./build$",
    "^rm -rf ./dist$"
  ]
}
```

Test:
```bash
rm -f /tmp/test.log              # Allowed (whitelisted)
rm -f /tmp/test.txt              # Allowed (whitelisted)
rm -f ~/.bashrc                  # BLOCKED (not in whitelist)
```

---

## Migration Guide

If switching from manual command review:

### Before
```bash
You: "Run: rm -rf /tmp/old"
You manually review and type it
Risk: You might miss the typo (rm -rf / tmp)
```

### After
```bash
You: "Delete old temp files"
Pi: rm -rf /tmp/old
Gate: Shows command in dialog
You: Verify it's correct before confirming
Risk: Much lower (gate reviews too)
```

---

**Next Steps:**
1. Install the extension
2. Try it with a safe command first
3. Test with a dangerous command to see the flow
4. Adjust threat level for your workflow
5. Add whitelist patterns for your safe operations

Happy protecting!
