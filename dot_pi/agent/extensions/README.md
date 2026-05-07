# Pi Extensions

Custom extensions for the Pi coding agent, organized by feature.

## 📁 Structure

```
extensions/
├── README.md                    # This file
├── lib-docs/                    # Library documentation fetcher
│   ├── index.ts                # Main extension (auto-discovered by Pi)
│   ├── package.json            # Dependencies
│   ├── README.md               # Full documentation
│   ├── QUICK-REFERENCE.md      # Command cheat sheet
│   ├── EXAMPLES.md             # Real-world usage
│   ├── INSTALL.md              # Setup guide
│   ├── ARCHITECTURE.md         # Design & internals
│   ├── INDEX.md                # Documentation index
│   ├── SUMMARY.md              # Project overview
│   └── setup.sh                # Automated installer
│
└── [other-extensions]/         # Add more extensions here
    ├── index.ts
    ├── package.json
    └── README.md
```

## 🚀 Quick Start

### lib-docs: Library Documentation Fetcher

Fetch and inject documentation for Python/JavaScript libraries into Pi context.

```bash
# Install
cd lib-docs && ./setup.sh --global

# Use in Pi
pi
/fetch-docs requests

# Ask agent to use docs
# "Write a function using requests with retry logic"
```

**Learn more:** [lib-docs/QUICK-REFERENCE.md](lib-docs/QUICK-REFERENCE.md)

## 📚 Available Extensions

### 1. permission-gates (72KB)

**Purpose:** Gate dangerous bash commands with user confirmation

**Features:**
- ✅ Intercepts dangerous commands (rm -rf, sudo, mkfs, etc.)
- ✅ Three threat levels (strict, moderate, permissive)
- ✅ Whitelist support for safe patterns
- ✅ Audit logging of all decisions
- ✅ Smart risk assessment and tips

**For:** System safety, preventing accidental destruction

**Files:**
| File | Size | Purpose |
|------|------|----------|
| [README.md](permission-gates/README.md) | 11KB | Feature overview |
| [QUICK-REFERENCE.md](permission-gates/QUICK-REFERENCE.md) | 5KB | Command reference |
| [EXAMPLES.md](permission-gates/EXAMPLES.md) | 11KB | Real scenarios |
| [INSTALL.md](permission-gates/INSTALL.md) | 9KB | Setup guide |

**Quick Links:**
- 📖 [Full README](permission-gates/README.md)
- ⚡ [Quick Start](permission-gates/QUICK-REFERENCE.md)
- 💡 [Examples](permission-gates/EXAMPLES.md)
- 🔧 [Install Guide](permission-gates/INSTALL.md)

---

### 3. file-approval (64KB)

**Purpose:** Require user approval before any files are written or modified

**Features:**
- ✅ Intercepts all file write operations (create, modify, delete)
- ✅ Shows unified diff format for changes
- ✅ Line-by-line change highlighting
- ✅ Content preview for new files
- ✅ Bash command detection (cp, mv, rm, etc.)
- ✅ Per-file approval workflow
- ✅ Audit trail of all decisions

**For:** Preventing accidental file modifications, data loss prevention

**Files:**
| File | Size | Purpose |
|------|------|----------|
| [README.md](file-approval/README.md) | 11KB | Feature overview |
| [QUICK-REFERENCE.md](file-approval/QUICK-REFERENCE.md) | 5KB | Command reference |
| [EXAMPLES.md](file-approval/EXAMPLES.md) | 12KB | Real scenarios |
| [INSTALL.md](file-approval/INSTALL.md) | 8KB | Setup guide |

**Quick Links:**
- 📖 [Full README](file-approval/README.md)
- ⚡ [Quick Start](file-approval/QUICK-REFERENCE.md)
- 💡 [Examples](file-approval/EXAMPLES.md)
- 🔧 [Install Guide](file-approval/INSTALL.md)

---

### 4. lib-docs (112KB)

**Purpose:** Fetch library documentation from PyPI, npm, ReadTheDocs

**Features:**
- ✅ Auto-detects Python/JavaScript dependencies
- ✅ Fetches docs from multiple sources
- ✅ Smart 24h caching
- ✅ LLM-callable tool
- ✅ `/fetch-docs` command

**For:** Python & JavaScript developers needing API reference during coding

**Files:**
| File | Size | Purpose |
|------|------|---------|
| [README.md](lib-docs/README.md) | 9KB | Feature overview |
| [QUICK-REFERENCE.md](lib-docs/QUICK-REFERENCE.md) | 4KB | Command reference |
| [EXAMPLES.md](lib-docs/EXAMPLES.md) | 10KB | Real scenarios |
| [INSTALL.md](lib-docs/INSTALL.md) | 8KB | Setup guide |
| [ARCHITECTURE.md](lib-docs/ARCHITECTURE.md) | 14KB | System design |
| [SUMMARY.md](lib-docs/SUMMARY.md) | 10KB | Project overview |

**Quick Links:**
- 📖 [Full README](lib-docs/README.md)
- ⚡ [Quick Start](lib-docs/QUICK-REFERENCE.md)
- 💡 [Examples](lib-docs/EXAMPLES.md)
- 🔧 [Install Guide](lib-docs/INSTALL.md)
- 🏗️ [Architecture](lib-docs/ARCHITECTURE.md)
- 📑 [Documentation Index](lib-docs/INDEX.md)

---

## 🔌 Auto-Discovery

Pi automatically loads extensions from:

**Global (all projects):**
```
~/.pi/agent/extensions/*/index.ts
```

**Project-local:**
```
.pi/extensions/*/index.ts
```

You can also manually load with: `pi -e path/to/extension.ts`

## 📝 Adding New Extensions

### Minimal Extension

1. Create directory:
```bash
mkdir my-extension
cd my-extension
```

2. Create `index.ts`:
```typescript
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (event, ctx) => {
    ctx.ui.notify("My extension loaded!", "info");
  });
}
```

3. Optional: Add `package.json`, `README.md`, etc.

4. Pi auto-discovers on reload!

### Full Extension Template

See `lib-docs` as a reference implementation with:
- Type definitions
- Error handling
- Caching
- Multiple event types
- Custom tools
- CLI commands
- Comprehensive documentation

## 🛠️ Extension Development

### Pi Extension API

Refer to Pi's official documentation:
- [Extension Guide](https://github.com/mariozechner/pi-coding-agent/blob/main/docs/extensions.md)
- [SDK Reference](https://github.com/mariozechner/pi-coding-agent/blob/main/docs/sdk.md)

### Using lib-docs as Template

The lib-docs extension is a complete reference implementation:

```bash
# Study the source
cat lib-docs/index.ts

# Read the design docs
cat lib-docs/ARCHITECTURE.md

# See examples
cat lib-docs/EXAMPLES.md
```

## 📋 Extension Checklist

When creating a new extension:

- [ ] `index.ts` - Main extension code
- [ ] `package.json` - Dependencies (if needed)
- [ ] `README.md` - What it does
- [ ] `QUICK-REFERENCE.md` - Command cheat sheet
- [ ] `EXAMPLES.md` - Real-world usage
- [ ] `INSTALL.md` - Setup instructions
- [ ] `setup.sh` - Automated installer (optional)

## 🎯 Next Steps

### First Time Here?

1. **Quick overview:** [lib-docs/SUMMARY.md](lib-docs/SUMMARY.md)
2. **Get started:** [lib-docs/QUICK-REFERENCE.md](lib-docs/QUICK-REFERENCE.md)
3. **Try examples:** [lib-docs/EXAMPLES.md](lib-docs/EXAMPLES.md)

### Want to Build?

1. **Understand extensions:** [Pi docs](https://github.com/mariozechner/pi-coding-agent/blob/main/docs/extensions.md)
2. **Study reference:** [lib-docs/ARCHITECTURE.md](lib-docs/ARCHITECTURE.md)
3. **Create new:** Subdirectory with `index.ts`

### Need Help?

- **lib-docs issues:** [lib-docs/INSTALL.md#troubleshooting](lib-docs/INSTALL.md#troubleshooting-installation)
- **Extension development:** [lib-docs/ARCHITECTURE.md](lib-docs/ARCHITECTURE.md)
- **Pi questions:** Pi documentation

---

**Pro Tip:** Each extension is self-contained. New extensions can coexist without conflicts—Pi discovers and loads them independently.

**Total Extensions:** 3 (permission-gates, file-approval, lib-docs) | **Total Size:** 248KB | **Last Updated:** 2025-05-06
