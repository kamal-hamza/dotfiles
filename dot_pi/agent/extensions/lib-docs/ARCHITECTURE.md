# Architecture & Advanced Configuration

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Pi Agent Session                          │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Extension Events
                              │
┌─────────────────────────────┴─────────────────────────────────────┐
│                   lib-docs Extension                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────┐         ┌──────────────────────────┐  │
│  │  Event Handlers      │         │  Registered Tools        │  │
│  ├──────────────────────┤         ├──────────────────────────┤  │
│  │ • session_start      │         │ • fetch_library_docs     │  │
│  │ • user_message       │         │                          │  │
│  │ • tool_call          │         │  Callable by LLM during  │  │
│  │                      │         │  reasoning                │  │
│  └──────────────────────┘         └──────────────────────────┘  │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Commands                                                │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │ /fetch-docs <library> [version]                          │   │
│  │   Interactive documentation fetching with UI prompts    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Core Processing                                         │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                           │   │
│  │  parseDependencies() ──> Detect project type              │   │
│  │        │                                                  │   │
│  │        ├─> requirements.txt (Python)                      │   │
│  │        ├─> pyproject.toml (Python)                        │   │
│  │        └─> package.json (JavaScript)                      │   │
│  │                                                           │   │
│  │  fetchLibraryDocs() ──> Orchestrate fetching               │   │
│  │        │                                                  │   │
│  │        ├─> Check Memory Cache (docCache)                  │   │
│  │        ├─> Check Disk Cache (~/.pi/doc-cache/)            │   │
│  │        ├─> Fetch from Web (if not cached)                 │   │
│  │        └─> Save to Cache                                  │   │
│  │                                                           │   │
│  │  Fetch Functions:                                         │   │
│  │        ├─> fetchPythonDocsPyPI()                          │   │
│  │        ├─> fetchPythonDocsReadTheDocs()                   │   │
│  │        └─> fetchNodePackageDocs()                         │   │
│  │                                                           │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP Requests
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              External Documentation Sources                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  PyPI Registry          npm Registry        ReadTheDocs          │
│  ├─ api/v1/...          ├─ registry.json    ├─ HTML pages       │
│  └─ /json endpoints     └─ package info    └─ API endpoints     │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ HTTPS Requests
                              │
                 (Automatic, Transparent to User)
```

## Data Flow

### Initialization Flow

```
Extension Loaded
        │
        ├─> initCacheDir()
        │   └─> Create ~/.pi/doc-cache/ if needed
        │
        ├─> Subscribe to Events
        │   └─> session_start, user_message, etc.
        │
        ├─> Register Tools
        │   └─> fetch_library_docs tool
        │
        └─> Register Commands
            └─> /fetch-docs command
```

### Documentation Fetch Flow

```
User triggers fetch (command or LLM tool call)
        │
        ├─> getCacheKey(lib, version, type)
        │   └─> Generate unique identifier
        │
        ├─> Check Memory Cache (docCache map)
        │   ├─> HIT: Return immediately
        │   └─> MISS: Continue
        │
        ├─> Check Disk Cache (~/.pi/doc-cache/)
        │   ├─> File exists AND fresh (< 24h old)
        │   ├─> HIT: Load to memory, return
        │   └─> MISS: Continue
        │
        ├─> Fetch from Web
        │   │
        │   ├─> Type: python?
        │   │   ├─> Try fetchPythonDocsPyPI()
        │   │   │   └─> Query: https://pypi.org/pypi/{lib}/{version}/json
        │   │   ├─> If failed, try fetchPythonDocsReadTheDocs()
        │   │   │   └─> Try multiple ReadTheDocs URL patterns
        │   │   └─> If failed, return null
        │   │
        │   └─> Type: javascript?
        │       ├─> Try fetchNodePackageDocs()
        │       │   └─> Query: https://registry.npmjs.org/{lib}/{version}
        │       └─> If failed, return null
        │
        ├─> Success: Save Results
        │   ├─> Add to Memory Cache (docCache)
        │   ├─> Save to Disk Cache (~/.pi/doc-cache/)
        │   └─> Format for display
        │
        └─> Return to User/LLM
            └─> Display in UI or include in context
```

## File Structure Details

```
lib-docs.ts (15KB)
│
├─ Imports & Type Definitions
│  ├─ ExtensionAPI type from Pi
│  ├─ Type utilities from typebox
│  └─ Node.js fs, path modules
│
├─ Type Definitions
│  ├─ DocCache interface
│  │  └─ Typed storage for cached docs
│  └─ ProjectDependencies interface
│     ├─ python: { [pkg]: version }
│     └─ javascript: { [pkg]: version }
│
├─ Global State
│  ├─ docCache: DocCache - In-memory cache
│  ├─ CACHE_DIR: string - Disk cache location
│  └─ CACHE_DURATION: number - 24h expiration
│
├─ Cache Management Functions
│  ├─ initCacheDir() - Create cache directory
│  ├─ getCacheKey() - Generate cache key
│  ├─ loadFromDiskCache() - Read from disk
│  └─ saveToDiskCache() - Write to disk
│
├─ Fetching Functions
│  ├─ fetchPythonDocsPyPI() - PyPI API
│  ├─ fetchPythonDocsReadTheDocs() - ReadTheDocs
│  ├─ fetchNodePackageDocs() - npm API
│  └─ fetchLibraryDocs() - Main orchestrator
│
├─ Parsing Functions
│  └─ parseDependencies() - Detect project type
│
└─ Main Extension Function
   ├─ session_start event handler
   ├─ user_message event handler
   ├─ /fetch-docs command registration
   └─ fetch_library_docs tool registration
```

## Cache Structure

```
~/.pi/doc-cache/
│
├─ python-requests-latest.md
├─ python-requests-latest.json
│
├─ python-requests-2.28.0.md
├─ python-requests-2.28.0.json
│
├─ javascript-express-4.18.0.md
├─ javascript-express-4.18.0.json
│
└─ ...other cached packages
```

**File Format:**

`.md` files: Formatted documentation (Markdown)
```markdown
# Library v1.0.0

**Summary:** Brief description

## Overview
Full documentation content...

**Links:** Official docs, repository...
```

`.json` files: Metadata
```json
{
  "timestamp": 1704067200000,
  "source": "pypi|npm|readthedocs"
}
```

## Integration Points

### With Pi's LLM

When the LLM has access to the `fetch_library_docs` tool:

```typescript
// LLM can call during reasoning:
await pi.tools.fetch_library_docs({
  library: "requests",
  version: "2.31.0",
  type: "python"
});
```

The tool returns Markdown-formatted documentation that the LLM can reason about and cite.

### With Pi's UI

```typescript
// Status updates during fetch
ctx.ui.setStatus("fetch-docs", "Fetching documentation...");

// Display documentation in widget
ctx.ui.setWidget("fetch-docs", docLines);

// Notifications
ctx.ui.notify("✓ Fetched docs for requests", "success");
```

### With Project Detection

```typescript
// On session start, auto-detect:
const deps = await parseDependencies(cwd);

// Notify user
if (deps.python || deps.javascript) {
  ctx.ui.notify(`Found ${count} dependencies...`, "info");
}
```

## Extension Points for Developers

### Adding New Language Support

To add Ruby, Elixir, Go, etc., follow this pattern:

```typescript
// 1. Create fetching function
async function fetchRubyGemsDoc(
  packageName: string,
  version: string
): Promise<string | null> {
  try {
    const url = `https://rubygems.org/api/v1/gems/${packageName}.json`;
    const response = await fetch(url);
    
    if (!response.ok) return null;
    
    const data = (await response.json()) as { /* type */ };
    
    let doc = `# ${packageName} v${version}\n\n`;
    // ... format documentation
    
    return doc;
  } catch (e) {
    return null;
  }
}

// 2. Update fetchLibraryDocs()
async function fetchLibraryDocs(
  library: string,
  version: string = "latest",
  type: "python" | "javascript" | "ruby"  // Add here
): Promise<string | null> {
  // ... existing code ...
  
  if (type === "ruby") {
    content = await fetchRubyGemsDoc(library, version);
  }
}

// 3. Update parseDependencies()
async function parseDependencies(cwd: string): Promise<ProjectDependencies> {
  // ... existing code ...
  
  // Add Ruby support
  try {
    const gemfilePath = path.join(cwd, "Gemfile");
    if (fs.existsSync(gemfilePath)) {
      const content = fs.readFileSync(gemfilePath, "utf-8");
      deps.ruby = {};
      // Parse Gemfile format...
    }
  } catch (e) {
    // Silently fail
  }
}

// 4. Update command to include ruby option
```

### Custom Documentation Formatters

To customize how docs are formatted:

```typescript
// Create formatter for specific library
function formatRequestsDoc(rawData: any): string {
  let formatted = `# requests\n\n`;
  
  // Custom formatting logic
  formatted += `**Quick Start:**\n`;
  formatted += rawData.description + "\n\n";
  
  return formatted;
}
```

### Adding Alternative Sources

For libraries with multiple documentation sources:

```typescript
async function fetchLibraryDocsAlternative(
  library: string,
  source: "github-wiki" | "dev-docs" | "gitbook"
): Promise<string | null> {
  const sourceUrls = {
    "github-wiki": `https://github.com/${library}/wiki`,
    "dev-docs": `https://devdocs.io/search?q=${library}`,
    "gitbook": `https://${library}.gitbook.io/`
  };
  
  // Implement source-specific fetching
}
```

## Performance Characteristics

### Time Complexity

| Operation | Time | Notes |
|-----------|------|-------|
| Memory cache hit | O(1) | <1ms |
| Disk cache hit | O(1) | 10-50ms (file I/O) |
| First fetch | O(n) | 1-5s depending on doc size |
| Parse dependencies | O(n) | 10-50ms for typical projects |

### Space Complexity

| Item | Size | Notes |
|------|------|-------|
| Single doc cache | 5-500KB | Typical 50-200KB |
| metadata | 200B | JSON per doc |
| In-memory cache | ~50MB max | Configurable |
| Session docs | Variable | Grows with usage |

### Network Characteristics

- **Parallel fetches**: Limited by Node.js (typically 6 concurrent)
- **Timeout**: 5 seconds per request
- **Retry**: None (fails fast)
- **Bandwidth**: Minimal (~100KB typical per fetch)

## Security Model

### Threat Model

```
User System
    │
    ├─> Extension Code (Trusted)
    │   └─> Pi Extension API (Trusted)
    │
    ├─> Local Filesystem Access
    │   └─> ~/.pi/doc-cache/ (Local Only)
    │
    └─> Network Requests (HTTPS Only)
        ├─> pypi.org (Public, no auth)
        ├─> npm registry (Public, no auth)
        └─> readthedocs.io (Public, no auth)

No:
- Code execution from fetched content
- Credential storage or transmission
- Authenticated requests
- Private data collection
```

### Safety Measures

1. **HTTPS Only** - All requests encrypted
2. **Read-Only** - No modifications to external systems
3. **Sandboxed** - Runs in Pi's extension context
4. **No Execution** - Documentation is parsed as text only
5. **Local Storage** - Cache on user's machine only

## Testing the Extension

### Manual Testing

```typescript
// Load extension in test mode
pi -e ./lib-docs.ts

// Test commands
/fetch-docs requests
/fetch-docs express
/fetch-docs numpy

// Verify cache
ls -la ~/.pi/doc-cache/
```

### Testing New Language Support

```typescript
// Create test project with new language
mkdir test-project
cd test-project

# Create Gemfile for Ruby testing
cat > Gemfile <<EOF
source 'https://rubygems.org'
gem 'rails', '~> 7.0'
gem 'sinatra', '~> 3.0'
EOF

pi -e ./lib-docs.ts

# Test detection
# Should show: "Found 2 dependencies"

/fetch-docs rails
/fetch-docs sinatra
```

## Optimization Opportunities

### Future Improvements

1. **Parallel Fetching**
   - Queue multiple doc requests
   - Use Promise.all() for concurrent fetches

2. **Incremental Parsing**
   - Stream large docs
   - Show partial results while loading

3. **Smart Cache Invalidation**
   - Detect new library versions
   - Auto-update outdated caches

4. **Full-Text Search**
   - Index cached docs
   - Quick keyword search across library docs

5. **Offline Mode**
   - Queue requested docs when offline
   - Fetch when connection restored

---

**For Contributors:** This extension is designed to be extended. Follow the patterns shown above to add new language support, sources, or features.
