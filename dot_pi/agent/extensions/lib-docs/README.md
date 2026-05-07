# Universal Documentation Fetcher Tool for Pi

A powerful Pi extension that provides the agent with a tool to fetch documentation from any source while implementing code. The agent automatically uses this tool when it needs reference documentation for libraries, frameworks, APIs, and more.

## Features

✅ **Automatic Tool Usage** - Agent automatically fetches docs when needed during implementation  
✅ **Universal Sources** - Works with PyPI, npm, GitHub, ReadTheDocs, and any public documentation URL  
✅ **Smart Auto-Detection** - Finds documentation even for unfamiliar libraries  
✅ **Smart Caching** - Caches documentation locally (24h) to avoid repeated downloads  
✅ **Flexible Input** - Library name, package name, or direct documentation URL  
✅ **Context Injection** - Suggests documentation when agent detects implementation tasks  
✅ **Version Support** - Fetch docs for specific versions when needed  
✅ **Zero Slash Commands** - No manual commands needed - everything via tool calls  

## How It Works

The extension registers a `fetch_documentation` tool that the Pi agent can call automatically:

1. **Agent detects implementation task** - You ask to implement/write/build something
2. **Agent identifies needed libraries** - Parses your request for library mentions
3. **Agent calls the tool** - Automatically fetches relevant documentation
4. **Agent uses docs** - Implements code with accurate syntax and best practices

## Installation

### Global Installation (All Projects)

```bash
cd ~/.local/share/chezmoi/dot_pi
chezmoi apply

# Or manually:
mkdir -p ~/.pi/agent/extensions
cp agent/extensions/lib-docs ~/.pi/agent/extensions/ -r
```

### Project-Local Installation

```bash
mkdir -p .pi/extensions
cp -r agent/extensions/lib-docs .pi/extensions/
```

## Usage Examples

### Example 1: Python HTTP Library

**You ask:**
> "Write a Python function that fetches data from an API with proper error handling and retries"

**Pi automatically:**
1. Recognizes "fetches data from an API" = HTTP library needed
2. Calls `fetch_documentation` with `query: "requests"`
3. Gets documentation for the requests library
4. Implements the function with correct syntax and best practices

### Example 2: Express Framework

**You ask:**
> "Create an Express.js middleware that logs all requests with timestamp and HTTP method"

**Pi automatically:**
1. Recognizes Express mentioned
2. Calls `fetch_documentation` with `query: "express"` and `source: "npm"`
3. Gets Express documentation
4. Implements the middleware correctly

### Example 3: Direct URL

**You ask:**
> "Using the documentation at https://docs.example.com/api, write a client that handles authentication"

**Pi will:**
1. Call `fetch_documentation` with the URL
2. Parse the documentation
3. Implement the client based on the docs

### Example 4: Specific Version

**You ask:**
> "I need to use async/await patterns with Node 14. Show me how to handle promise rejection properly"

**Pi will:**
1. Call `fetch_documentation` with appropriate version info
2. Fetch version-specific documentation
3. Implement with correct patterns for that version

## Tool Parameters

### `fetch_documentation` Tool

```typescript
{
  query: string;           // Library name (e.g., "requests") or documentation URL
  version?: string;        // Specific version (default: "latest")
  source?: string;         // "auto", "pypi", "npm", "github", "url" (default: "auto")
}
```

**Returns:**
- Documentation in Markdown format
- Source information (PyPI, npm, GitHub, etc.)
- Cached status
- Auto-detected sources if not found

## Advanced Usage

### Specifying Documentation Source

If you want to be explicit about the source:

**You ask:**
> "Using the npm documentation for jest@latest, show me how to set up a test configuration"

**Or in Python:**
> "Using PyPI docs for pandas, write code to read a CSV file and group by column"

Pi will:
1. Recognize the explicit source preference
2. Call the tool with `source: "npm"` or `source: "pypi"`
3. Fetch from the specified source
4. Implement accordingly

### Working with Unknown Libraries

**You ask:**
> "I found this library called 'hyx' and want to use it. Can you show me how to initialize it?"

**Pi will:**
1. Call `fetch_documentation` with `source: "auto"`
2. Check PyPI, npm, GitHub, ReadTheDocs in parallel
3. Find the documentation and show you how to use it

### Combining Multiple Libraries

**You ask:**
> "Write a data pipeline that reads from a Postgres database with psycopg2, processes with pandas, and writes results to S3 with boto3"

**Pi will:**
1. Identify three libraries: psycopg2, pandas, boto3
2. Fetch documentation for each (in parallel, cached efficiently)
3. Write integrated code using all three with correct syntax

## Cache Management

Documentation is cached at: `~/.pi/doc-cache/`

### View cached docs
```bash
ls ~/.pi/doc-cache/
```

### Clear all cached documentation
```bash
rm -rf ~/.pi/doc-cache/
```

### Clear specific library cache
```bash
# Remove requests library docs
rm ~/.pi/doc-cache/*requests*.md ~/.pi/doc-cache/*requests*.json
```

### Cache details
- Expires after 24 hours of inactivity
- Stored as Markdown files with metadata
- Typically 5-500KB per library depending on documentation size

## What Gets Documented

### Python Packages
- **PyPI** - Package metadata, README, homepage
- **ReadTheDocs** - Full documentation sites
- **GitHub** - README files and documentation

### JavaScript Packages
- **npm Registry** - Package metadata, README, repository info
- **GitHub Pages** - Official documentation sites
- **ReadTheDocs** - JavaScript frameworks with full docs

### Any Public URL
- HTML documentation sites (cleaned and extracted)
- Markdown files (raw)
- JSON APIs (formatted)
- GitHub READMEs

## Performance

- **First fetch**: 1-3 seconds (depends on doc size)
- **Cached fetches**: <10ms (memory) or <100ms (disk)
- **Parallel fetches**: Efficient, multiple docs loaded simultaneously
- **Doc size**: 5-500KB depending on library
- **Total cache size**: ~100MB for typical development stack

## Security

✅ **HTTPS Only** - All requests use secure connections  
✅ **No Credentials** - Uses only public APIs  
✅ **Sandboxed** - Runs in Pi's secure extension context  
✅ **Read-Only** - Only downloads and caches, never modifies  
✅ **Network Safe** - Uses Node.js built-in modules  

## Troubleshooting

### "Could not fetch documentation"

**Check your internet:**
```bash
curl https://pypi.org/pypi/requests/latest/json
curl https://registry.npmjs.org/express/latest
```

**Try the full package name:**
- PyPI: `Pillow` not `PIL`
- npm: Check exact package name on npmjs.com

**Provide the documentation URL directly:**
> "Using documentation from https://docs.example.com, implement..."

### Documentation seems outdated

**Fetch a specific version:**
> "Using version 2.28.0 of requests (fetch the docs), show me how to..."

**Or clear cache and retry:**
```bash
rm ~/.pi/doc-cache/
```

### Library name has special characters

**Provide the URL directly:**
> "Using https://raw.githubusercontent.com/user/repo/main/README.md, implement..."

## File Structure

```
lib-docs/
├── index.ts              # Main extension (850 lines)
├── package.json          # Minimal dependencies
├── tsconfig.json         # TypeScript config
└── README.md             # This file
```

## Architecture

### Key Functions

| Function | Purpose |
|----------|---------|
| `fetchFromUrl()` | Generic URL fetching (HTML/MD/JSON) |
| `fetchPythonDocsPyPI()` | PyPI API for Python packages |
| `fetchNodePackageDocs()` | npm registry API for JS packages |
| `findDocumentationSources()` | Auto-detect docs for unknown libraries |
| `getCacheKey()` | Generate consistent cache identifiers |
| `fetch_documentation` tool | Main LLM-callable tool |

### Event Hooks

- **`session_start`** - Initialize cache, ready to fetch
- **`user_message`** - Detect implementation keywords and suggest docs
- **`tool_result`** - Notify user when docs are fetched

## Extension for Other Languages

To add support for a new language/registry:

```typescript
// 1. Add fetch function
async function fetchRubyGemsDocs(packageName: string): Promise<string | null> {
  const url = `https://rubygems.org/api/v1/gems/${packageName}.json`;
  // Fetch and format
}

// 2. Update findDocumentationSources
const urlsToTry = [
  { url: `https://rubygems.org/gems/${normalized}`, source: "RubyGems" },
  // ...
];

// 3. Update main tool logic
if (source === "rubygems") {
  docs = await fetchRubyGemsDocs(query);
}
```

## Performance Tips

- **First time:** Agent fetches docs, they're cached for 24 hours
- **Subsequent requests:** Uses cache automatically (milliseconds)
- **Multiple libraries:** Fetches in parallel, all get cached
- **Token savings:** Docs persist in session - use `/compact` to clean up later

## Related Extensions

- **file-diff-and-approval** - Review changes before applying
- **permission-gates** - Approve dangerous commands
- **lib-docs** - This extension (you're reading it!)

## Extending This Extension

The extension is modular. To customize:

1. **Add new documentation sources** - Implement `fetchX()` functions
2. **Change cache duration** - Modify `CACHE_DURATION` constant
3. **Add logging** - Implement console output in fetch functions
4. **Filter documentation** - Modify text extraction in `fetchFromUrl()`

---

**Pro Tip:** This tool works best when combined with Pi's other features:
- Use with `/edit` tool to implement with automatic docs
- Combine with file-diff-and-approval for reviewed changes
- Stack with multiple tools for complete workflows

The agent now has instant access to any documentation while coding! 🚀
