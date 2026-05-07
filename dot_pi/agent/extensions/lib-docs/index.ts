#!/usr/bin/env node
/**
 * =============================================================================
 * Universal Documentation Fetcher Tool for Pi
 * =============================================================================
 * 
 * This extension provides the agent with a tool to fetch documentation from
 * any source while implementing code. The agent can automatically use this tool
 * when it needs to reference documentation for libraries, frameworks, APIs, etc.
 *
 * Features:
 * - Fetch docs from any source (PyPI, npm, GitHub, ReadTheDocs, official sites, etc.)
 * - Auto-detect and suggest documentation sources
 * - Smart caching to avoid repeated downloads
 * - Seamless integration with agent's code generation workflow
 * - Supports multiple documentation formats and sources
 * =============================================================================
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";
import * as fs from "node:fs";
import * as path from "node:path";

interface DocCache {
  [key: string]: {
    content: string;
    timestamp: number;
    source: string;
  };
}

// In-memory cache for docs during session
let docCache: DocCache = {};
const CACHE_DIR = path.join(process.env.HOME || "/tmp", ".pi/doc-cache");
const CACHE_DURATION = 24 * 60 * 60 * 1000; // 24 hours

/**
 * Initialize cache directory
 */
function initCacheDir() {
  try {
    if (!fs.existsSync(CACHE_DIR)) {
      fs.mkdirSync(CACHE_DIR, { recursive: true });
    }
  } catch (e) {
    // Silently fail if we can't create cache dir
  }
}

/**
 * Get cache key for a document
 */
function getCacheKey(identifier: string): string {
  return identifier.toLowerCase().replace(/[@\/\:\.]/g, "_");
}

/**
 * Load doc from disk cache if available and fresh
 */
function loadFromDiskCache(key: string): string | null {
  try {
    const cacheFile = path.join(CACHE_DIR, `${key}.md`);
    const metaFile = path.join(CACHE_DIR, `${key}.json`);

    if (!fs.existsSync(cacheFile) || !fs.existsSync(metaFile)) {
      return null;
    }

    const meta = JSON.parse(fs.readFileSync(metaFile, "utf-8"));
    const age = Date.now() - meta.timestamp;

    if (age > CACHE_DURATION) {
      // Cache expired, delete it
      try {
        fs.unlinkSync(cacheFile);
        fs.unlinkSync(metaFile);
      } catch (e) {
        // Ignore cleanup errors
      }
      return null;
    }

    return fs.readFileSync(cacheFile, "utf-8");
  } catch (e) {
    return null;
  }
}

/**
 * Save doc to disk cache
 */
function saveToDiskCache(key: string, content: string, source: string) {
  try {
    const cacheFile = path.join(CACHE_DIR, `${key}.md`);
    const metaFile = path.join(CACHE_DIR, `${key}.json`);

    fs.writeFileSync(cacheFile, content);
    fs.writeFileSync(
      metaFile,
      JSON.stringify({ timestamp: Date.now(), source })
    );
  } catch (e) {
    // Silently fail if we can't write cache
  }
}

/**
 * Fetch documentation from a generic URL
 */
async function fetchFromUrl(url: string): Promise<string | null> {
  try {
    const response = await fetch(url, {
      headers: {
        "User-Agent": "Pi-Documentation-Fetcher/1.0",
      },
      timeout: 10000,
    });

    if (!response.ok) {
      return null;
    }

    const contentType = response.headers.get("content-type") || "";

    // Handle markdown files
    if (url.endsWith(".md") || contentType.includes("text/markdown")) {
      return await response.text();
    }

    // Handle HTML
    if (contentType.includes("text/html")) {
      const html = await response.text();

      // Extract title
      const titleMatch = html.match(/<title>(.*?)<\/title>/i);
      let doc = titleMatch ? `# ${titleMatch[1]}\n\n` : "# Documentation\n\n";

      // Try to extract main content from common patterns
      const contentMatch =
        html.match(/<main[^>]*>(.*?)<\/main>/is) ||
        html.match(/<article[^>]*>(.*?)<\/article>/is) ||
        html.match(/<div\s+(?:class|id)=["']content["'][^>]*>(.*?)<\/div>/is) ||
        html.match(/<body[^>]*>(.*?)<\/body>/is);

      if (contentMatch) {
        // Basic HTML to text conversion
        let text = contentMatch[1]
          .replace(/<script[^>]*>.*?<\/script>/gs, "")
          .replace(/<style[^>]*>.*?<\/style>/gs, "")
          .replace(/<[^>]+>/g, " ")
          .replace(/&nbsp;/g, " ")
          .replace(/&lt;/g, "<")
          .replace(/&gt;/g, ">")
          .replace(/&amp;/g, "&")
          .replace(/\s+/g, " ")
          .trim();

        // Limit to first 10000 chars
        text = text.substring(0, 10000);
        doc += text;

        if (contentMatch[1].length > 10000) {
          doc += "\n\n*(Documentation truncated - view full docs at provided URL)*\n";
        }
      }

      return doc;
    }

    // Handle JSON
    if (contentType.includes("application/json")) {
      const json = await response.json();
      return JSON.stringify(json, null, 2).substring(0, 20000);
    }

    // Fallback: return as plain text
    const text = await response.text();
    return text.substring(0, 20000);
  } catch (e) {
    return null;
  }
}

/**
 * Fetch Python package info from PyPI
 */
async function fetchPythonDocsPyPI(
  packageName: string,
  version: string
): Promise<string | null> {
  try {
    const url = `https://pypi.org/pypi/${packageName}/${version || "latest"}/json`;
    const response = await fetch(url);

    if (!response.ok) {
      return null;
    }

    const data = (await response.json()) as {
      info: {
        summary: string;
        description: string;
        home_page: string;
        project_urls?: { Documentation?: string };
      };
    };

    const info = data.info;
    let doc = `# ${packageName} v${version || "latest"}\n\n`;
    doc += `**Summary:** ${info.summary}\n\n`;

    if (info.description) {
      doc += `## Overview\n\n${info.description}\n\n`;
    }

    if (info.project_urls?.Documentation) {
      doc += `**📚 Full Documentation:** ${info.project_urls.Documentation}\n\n`;
    }

    if (info.home_page) {
      doc += `**🏠 Homepage:** ${info.home_page}\n\n`;
    }

    return doc;
  } catch (e) {
    return null;
  }
}

/**
 * Fetch npm package docs
 */
async function fetchNodePackageDocs(
  packageName: string,
  version: string
): Promise<string | null> {
  try {
    const url = `https://registry.npmjs.org/${packageName}/${version || "latest"}`;
    const response = await fetch(url);

    if (!response.ok) {
      return null;
    }

    const data = (await response.json()) as {
      description: string;
      version: string;
      homepage?: string;
      repository?: { url: string };
      readme?: string;
    };

    let doc = `# ${packageName} v${data.version}\n\n`;
    doc += `**Description:** ${data.description}\n\n`;

    if (data.homepage) {
      doc += `**🏠 Homepage:** ${data.homepage}\n\n`;
    }

    if (data.repository?.url) {
      doc += `**📦 Repository:** ${data.repository.url}\n\n`;
    }

    if (data.readme) {
      doc += `## README\n\n${data.readme.substring(0, 15000)}\n\n`;
      if (data.readme.length > 15000) {
        doc += `*(Truncated - see npmjs.org for full documentation)*\n`;
      }
    }

    return doc;
  } catch (e) {
    return null;
  }
}

/**
 * Auto-detect documentation sources for a library
 */
async function findDocumentationSources(
  libraryName: string
): Promise<{ url: string; source: string }[]> {
  const sources: { url: string; source: string }[] = [];
  const normalized = libraryName.toLowerCase().replace(/[\s_]/g, "-");

  // Try common documentation hosting services
  const urlsToTry = [
    // ReadTheDocs
    {
      url: `https://${normalized}.readthedocs.io/en/latest/`,
      source: "ReadTheDocs",
    },
    // Official GitHub Pages
    {
      url: `https://${normalized}.github.io/`,
      source: "GitHub Pages",
    },
    // NPM package page
    {
      url: `https://www.npmjs.com/package/${normalized}`,
      source: "npm",
    },
    // GitHub README
    {
      url: `https://raw.githubusercontent.com/${normalized}/${normalized}/main/README.md`,
      source: "GitHub",
    },
    // PyPI
    {
      url: `https://pypi.org/project/${normalized}/`,
      source: "PyPI",
    },
  ];

  // Test each URL (non-blocking, just collect valid ones)
  for (const { url, source } of urlsToTry) {
    try {
      const response = await fetch(url, {
        method: "HEAD",
        timeout: 3000,
      }).catch(
        () =>
          fetch(url, {
            timeout: 3000,
          })
      );

      if (response && response.ok) {
        sources.push({ url, source });
      }
    } catch (e) {
      // Skip this source
    }
  }

  return sources;
}

/**
 * Main extension function
 */
export default function (pi: ExtensionAPI) {
  initCacheDir();

  // Register the documentation fetcher tool
  pi.registerTool({
    name: "fetch_documentation",
    label: "Fetch Documentation",
    description:
      "Fetch and retrieve documentation from any source. Use this when implementing code that requires reference documentation. Supports PyPI, npm, GitHub, ReadTheDocs, and any public documentation URL.",
    parameters: Type.Object({
      query: Type.String({
        description:
          "Library name, project name, or documentation URL (e.g., 'requests', 'express', 'https://docs.example.com')",
      }),
      version: Type.Optional(
        Type.String({
          description:
            "Specific version to fetch (optional, defaults to latest). For URLs, this is ignored.",
          default: "latest",
        })
      ),
      source: Type.Optional(
        Type.String({
          description:
            "Preferred documentation source: 'pypi', 'npm', 'github', 'url', or 'auto' to auto-detect",
          default: "auto",
        })
      ),
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const { query, version = "latest", source = "auto" } = params;

      if (!query) {
        return {
          content: [
            {
              type: "text",
              text: "Please provide a library name or documentation URL",
            },
          ],
          details: { error: "missing_query" },
        };
      }

      const cacheKey = getCacheKey(`${query}-${version}`);
      const cached = docCache[cacheKey] || loadFromDiskCache(cacheKey);

      if (cached) {
        onUpdate?.({
          type: "status",
          text: `Found cached documentation for ${query}`,
        });

        return {
          content: [
            {
              type: "text",
              text: cached,
            },
          ],
          details: {
            query,
            version,
            cached: true,
            source: "cache",
          },
        };
      }

      onUpdate?.({
        type: "status",
        text: `Fetching documentation for ${query}...`,
      });

      try {
        let docs: string | null = null;
        let docSource = "unknown";

        // If query looks like a URL, fetch directly
        if (query.startsWith("http://") || query.startsWith("https://")) {
          docs = await fetchFromUrl(query);
          docSource = "url";
        } else if (source === "auto" || source === "pypi") {
          // Try PyPI first for auto-detect
          docs = await fetchPythonDocsPyPI(query, version);
          docSource = "pypi";

          // If not found, try npm
          if (!docs && (source === "auto" || source === "npm")) {
            docs = await fetchNodePackageDocs(query, version);
            docSource = "npm";
          }

          // If still not found and auto-detect, try finding docs online
          if (!docs && source === "auto") {
            const sources = await findDocumentationSources(query);
            if (sources.length > 0) {
              docs = await fetchFromUrl(sources[0].url);
              docSource = sources[0].source;
            }
          }
        } else if (source === "npm") {
          docs = await fetchNodePackageDocs(query, version);
          docSource = "npm";
        } else if (source === "github") {
          const sources = await findDocumentationSources(query);
          const ghSource = sources.find((s) => s.source === "GitHub");
          if (ghSource) {
            docs = await fetchFromUrl(ghSource.url);
            docSource = "GitHub";
          }
        } else if (source === "url") {
          docs = await fetchFromUrl(query);
          docSource = "url";
        }

        if (docs) {
          // Cache the result
          docCache[cacheKey] = {
            content: docs,
            timestamp: Date.now(),
            source: docSource,
          };
          saveToDiskCache(cacheKey, docs, docSource);

          onUpdate?.({
            type: "status",
            text: `✓ Documentation loaded from ${docSource}`,
          });

          return {
            content: [
              {
                type: "text",
                text: docs,
              },
            ],
            details: {
              query,
              version,
              source: docSource,
              cached: false,
            },
          };
        } else {
          // Try to suggest where documentation might be found
          const suggestions: string[] = [];
          const searchUrl = `https://www.google.com/search?q=${encodeURIComponent(query + " documentation")}`;
          suggestions.push(`Search online: ${searchUrl}`);

          // Try to auto-detect sources
          try {
            const sources = await findDocumentationSources(query);
            if (sources.length > 0) {
              suggestions.push(
                "Found potential documentation sources:\n" +
                  sources
                    .map((s) => `- ${s.source}: ${s.url}`)
                    .join("\n")
              );
            }
          } catch (e) {
            // Auto-detect failed
          }

          const suggestion =
            suggestions.length > 0
              ? suggestions.join("\n\n")
              : "Could not find documentation. Try providing the full documentation URL.";

          return {
            content: [
              {
                type: "text",
                text: `Could not fetch documentation for "${query}". ${suggestion}`,
              },
            ],
            details: { error: "not_found", suggestions },
          };
        }
      } catch (error) {
        return {
          content: [
            {
              type: "text",
              text: `Error fetching documentation: ${error instanceof Error ? error.message : String(error)}`,
            },
          ],
          details: { error: "fetch_failed" },
        };
      }
    },
  });

  // Monitor user messages for library mentions and offer context
  pi.on("user_message", async (event, ctx) => {
    const userText = event.message.content
      .filter((c) => c.type === "text")
      .map((c) => (c as { type: "text"; text: string }).text)
      .join(" ");

    // Look for implementation-related keywords
    const implementationKeywords = [
      "implement",
      "write",
      "create",
      "build",
      "use",
      "with",
      "using",
      "import",
      "require",
    ];

    const isImplementationTask = implementationKeywords.some((kw) =>
      userText.toLowerCase().includes(kw)
    );

    if (isImplementationTask) {
      // Extract potential library names (common naming patterns)
      const libPatterns = [
        /\b(?:using|with|import|require)\s+([a-z0-9\-_]+)\b/gi,
        /\b([a-z0-9\-_]+)\s+(?:library|package|framework|module)\b/gi,
      ];

      const mentionedLibs = new Set<string>();
      libPatterns.forEach((pattern) => {
        let match;
        while ((match = pattern.exec(userText)) !== null) {
          mentionedLibs.add(match[1]);
        }
      });

      if (mentionedLibs.size > 0) {
        const libs = Array.from(mentionedLibs).slice(0, 3);
        const message =
          libs.length === 1
            ? `💡 I can fetch documentation for ${libs[0]} using the fetch_documentation tool to help with your implementation.`
            : `💡 I can fetch documentation for these libraries: ${libs.join(", ")} using the fetch_documentation tool.`;

        ctx.ui.setWidget("doc-helper", [message]);
      }
    }
  });

  // Optional: Provide feedback when documentation is fetched
  pi.on("tool_result", async (event, ctx) => {
    if (event.toolResult.toolCall.name === "fetch_documentation") {
      const details = event.toolResult.details as { source?: string; query?: string };
      if (details.source && details.query) {
        ctx.ui.notify(
          `📚 Loaded docs for ${details.query} from ${details.source}`,
          "info"
        );
      }
    }
  });
}
