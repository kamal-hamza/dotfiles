#!/usr/bin/env bash
# =============================================================================
# Build Quickshell TypeScript
# =============================================================================
# Type-checks and compiles home/dot_config/quickshell/**/*.mts to sibling *.mjs
# ES modules (what the QML actually imports). The generated .mjs files are
# committed, so `chezmoi apply` never needs Node/TypeScript - run this after
# editing any .mts, then `chezmoi apply`.
#
# Usage:
#   scripts/build-quickshell-ts.sh          # type-check + regenerate .mjs
#   scripts/build-quickshell-ts.sh --check  # fail if committed .mjs is stale
#
# The compiler is pinned (TS_VERSION) and run via bunx so output is
# reproducible across machines regardless of any globally installed tsc.
# =============================================================================
set -euo pipefail

TS_VERSION="7.0.2"
SRC="$(chezmoi source-path)/dot_config/quickshell" # source-path = <repo>/home (.chezmoiroot)

command -v bunx >/dev/null 2>&1 || { echo "error: bun is required (install-lang bun)" >&2; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

bunx --bun --package "typescript@$TS_VERSION" tsc -p "$SRC/tsconfig.json" --outDir "$tmp"

stale=0
while IFS= read -r -d '' out; do
    rel="${out#"$tmp"/}"
    gen="$tmp/$rel.banner"
    {
        echo "// GENERATED from $(basename "${rel%.mjs}").mts by scripts/build-quickshell-ts.sh - do not edit."
        cat "$out"
    } > "$gen"
    if [[ "${1:-}" == "--check" ]]; then
        if ! cmp -s "$gen" "$SRC/$rel"; then
            echo "stale: $rel (run scripts/build-quickshell-ts.sh)" >&2
            stale=1
        fi
    else
        cp "$gen" "$SRC/$rel"
        echo "built: $rel"
    fi
done < <(find "$tmp" -name '*.mjs' -print0)

exit "$stale"
