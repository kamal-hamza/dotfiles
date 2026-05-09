#!/usr/bin/env node

/**
 * =============================================================================
 * File Edit Mode Extension for Pi
 * =============================================================================
 * 
 * Control how the agent handles file creation and editing:
 * - auto: edit files without requiring permission
 * - strict: ask for confirmation before creating/editing files
 * 
 * Usage:
 *   /file-mode auto     - Switch to auto mode (no confirmation)
 *   /file-mode strict   - Switch to strict mode (confirmation required)
 *   /file-mode status   - Show current mode
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type FileEditMode = "auto" | "strict";

interface ModeState {
  mode: FileEditMode;
  lastChanged: number;
}

const DEFAULT_STATE: ModeState = {
  mode: "auto",
  lastChanged: Date.now(),
};

export default function (pi: ExtensionAPI) {
  let state = DEFAULT_STATE;

  // Restore mode from session on startup
  pi.on("session_start", async (event, ctx) => {
    // Look for previous file-edit-mode state in session
    for (const entry of ctx.sessionManager.getEntries()) {
      if (entry.type === "custom" && entry.customType === "file-edit-mode-state") {
        try {
          const savedState = entry.data as ModeState;
          state = savedState;
          break;
        } catch {
          // If parsing fails, use default
        }
      }
    }

    // On session start (not just reload), reset to auto for safety
    if (event.reason === "new" || event.reason === "fork" || event.reason === "startup") {
      state = DEFAULT_STATE;
    }

    ctx.ui.notify(`File Edit Mode: ${state.mode.toUpperCase()}`, "info");
  });

  // Intercept file write and edit operations
  pi.on("tool_call", async (event, ctx) => {
    if (state.mode === "auto") {
      // In auto mode, allow all file operations
      return;
    }

    // In strict mode, ask for confirmation
    if (event.toolName === "write") {
      const path = event.input.path as string;
      const content = event.input.content as string;
      const preview = content.length > 200 ? content.slice(0, 200) + "..." : content;

      const confirmed = await ctx.ui.confirm(
        "File Write",
        `Create/overwrite file:\n${path}\n\nContent preview:\n${preview}\n\nAllow?`
      );

      if (!confirmed) {
        ctx.ui.notify("File write cancelled by user", "warning");
        return { block: true, reason: "User declined file write" };
      }

      ctx.ui.notify(`File write approved: ${path}`, "success");

      // Log to session
      pi.appendEntry("file-edit-approval", {
        tool: "write",
        path,
        timestamp: Date.now(),
        approved: true,
      });

      return;
    }

    if (event.toolName === "edit") {
      const path = event.input.path as string;
      const edits = event.input.edits as Array<{ oldText: string; newText: string }>;

      const editCount = edits?.length || 0;
      const previewEdits = edits
        ?.slice(0, 2)
        .map((e) => `  - Replace: "${e.oldText.slice(0, 50)}${e.oldText.length > 50 ? "..." : ""}"`)
        .join("\n") || "";

      const confirmed = await ctx.ui.confirm(
        "File Edit",
        `Edit file:\n${path}\n\nEdits: ${editCount}\n${previewEdits}\n\nAllow?`
      );

      if (!confirmed) {
        ctx.ui.notify("File edit cancelled by user", "warning");
        return { block: true, reason: "User declined file edit" };
      }

      ctx.ui.notify(`File edit approved: ${path}`, "success");

      // Log to session
      pi.appendEntry("file-edit-approval", {
        tool: "edit",
        path,
        editCount,
        timestamp: Date.now(),
        approved: true,
      });

      return;
    }
  });

  // Command to change file edit mode
  pi.registerCommand("file-mode", {
    description: "Control file editing mode (auto/strict)",
    getArgumentCompletions: (prefix: string) => {
      const modes = ["auto", "strict", "status"];
      return modes
        .filter((m) => m.startsWith(prefix.toLowerCase()))
        .map((m) => ({ value: m, label: m }));
    },
    handler: async (args, ctx) => {
      const arg = (args || "").toLowerCase().trim();

      if (!arg || arg === "status") {
        ctx.ui.notify(
          `Current File Edit Mode: ${state.mode.toUpperCase()}\n\nAuto: Files edited without confirmation\nStrict: User confirmation required for each file operation`,
          "info"
        );
        return;
      }

      if (arg === "auto") {
        if (state.mode === "auto") {
          ctx.ui.notify("Already in auto mode", "info");
          return;
        }

        state = { mode: "auto", lastChanged: Date.now() };
        pi.appendEntry("file-edit-mode-state", state);
        ctx.ui.notify("File Edit Mode: AUTO (no confirmation required)", "success");
        return;
      }

      if (arg === "strict") {
        if (state.mode === "strict") {
          ctx.ui.notify("Already in strict mode", "info");
          return;
        }

        state = { mode: "strict", lastChanged: Date.now() };
        pi.appendEntry("file-edit-mode-state", state);
        ctx.ui.notify("File Edit Mode: STRICT (confirmation required)", "success");
        return;
      }

      ctx.ui.notify(
        `Invalid mode: ${arg}\n\nValid modes: auto, strict, status`,
        "warning"
      );
    },
  });
}
