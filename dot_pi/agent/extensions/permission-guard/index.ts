#!/usr/bin/env node

/**
 * =============================================================================
 * Permission Guard Extension for Pi
 * =============================================================================
 * 
 * Blocks potentially harmful commands from execution. Can be configured to:
 * - Block commands completely
 * - Require user confirmation before execution
 * - Allow commands on a whitelist
 * 
 * Usage:
 *   Automatically loaded from ~/.pi/agent/extensions/permission-guard/
 *   Configure rules in ~/.pi/agent/extensions/permission-guard/rules.json
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "node:fs";
import { join } from "node:path";

interface PermissionRule {
  pattern: string;
  severity: "block" | "confirm" | "allow";
  description: string;
  reason?: string;
}

interface PermissionConfig {
  enabled: boolean;
  defaultBehavior: "block" | "confirm" | "allow";
  rules: PermissionRule[];
}

// Default rules for dangerous commands
const DEFAULT_CONFIG: PermissionConfig = {
  enabled: true,
  defaultBehavior: "block",
  rules: [
    // Filesystem destruction
    {
      pattern: "^rm\\s+.*(-r|-R|--recursive).*",
      severity: "block",
      description: "Recursive deletion (rm -r/R)",
      reason: "Recursive file deletion is potentially destructive",
    },
    {
      pattern: "^rm\\s+.*(-f|--force).*(-r|-R|--recursive).*",
      severity: "block",
      description: "Force recursive deletion (rm -rf)",
      reason: "Force recursive deletion can cause irreversible data loss",
    },
    {
      pattern: "^dd\\s+",
      severity: "block",
      description: "Disk/device manipulation (dd)",
      reason: "dd can destroy partitions or disk contents",
    },
    {
      pattern: "^mkfs",
      severity: "block",
      description: "Filesystem creation (mkfs)",
      reason: "mkfs destroys all data on a device",
    },

    // Privilege escalation
    {
      pattern: "^sudo\\s+",
      severity: "confirm",
      description: "Sudo execution",
      reason: "Commands run with elevated privileges",
    },

    // Package manager with force/purge (potentially destructive)
    {
      pattern: "^(brew|apt-get|pacman)\\s+.*--(force-all|purge).*",
      severity: "confirm",
      description: "Destructive package manager operation",
      reason: "This could remove important system packages",
    },

    // Git operations that rewrite history (risky)
    {
      pattern: "^git\\s+(reset|rebase|force-push|push\\s+.*--force).*--hard.*",
      severity: "confirm",
      description: "Destructive git operation (hard reset/rebase)",
      reason: "Hard reset can lose uncommitted changes permanently",
    },

    // Shell operations that could be dangerous
    {
      pattern: "^(>|>>)\\s*/",
      severity: "confirm",
      description: "Redirect to system path",
      reason: "Writing to system directories could break the system",
    },

    {
      pattern: "^chmod.*\\s+000\\s+/",
      severity: "confirm",
      description: "Remove all permissions from system path",
      reason: "Removing all permissions could break the system",
    },

    {
      pattern: "^chown.*\\s+root:root.*",
      severity: "confirm",
      description: "Change ownership to root",
      reason: "Changing ownership could affect system operation",
    },

    // Shell script execution from untrusted sources
    {
      pattern: "^(curl|wget|python)\\s+.*\\|\\s*(bash|sh|python).*",
      severity: "confirm",
      description: "Pipe to shell interpreter (curl|wget|python | bash)",
      reason: "Executing downloaded scripts can be a security risk",
    },

    // Allow safe operations
    {
      pattern: "^(ls|cd|pwd|cat|echo|grep|find|locate).*",
      severity: "allow",
      description: "Safe read-only commands",
    },
    {
      pattern: "^(mkdir|touch|cp|mv)\\s+[^/~].*",
      severity: "allow",
      description: "Safe file operations in current directory",
    },
  ],
};

export default function (pi: ExtensionAPI) {
  let config = DEFAULT_CONFIG;

  // Try to load custom config
  try {
    const configPath = join(
      process.env.HOME || "/root",
      ".pi/agent/extensions/permission-guard/rules.json"
    );
    const rawConfig = readFileSync(configPath, "utf-8");
    const loadedConfig = JSON.parse(rawConfig) as PermissionConfig;
    config = { ...DEFAULT_CONFIG, ...loadedConfig };
  } catch {
    // Use default config if custom config doesn't exist or fails to parse
  }

  // Session startup notification
  pi.on("session_start", async (_event, ctx) => {
    if (config.enabled) {
      ctx.ui.notify("Permission Guard active", "info");
    }
  });

  // Tool call interception
  pi.on("tool_call", async (event, ctx) => {
    if (!config.enabled || event.toolName !== "bash") {
      return;
    }

    const command = event.input.command as string;
    if (!command) {
      return;
    }

    const matchedRule = config.rules.find((rule) => {
      const regex = new RegExp(rule.pattern, "m");
      return regex.test(command);
    });

    if (!matchedRule) {
      // No matching rule - use default behavior
      if (config.defaultBehavior === "block") {
        return {
          block: true,
          reason: "Command not in whitelist (default: block unknown commands)",
        };
      }
      return;
    }

    // Handle based on severity
    if (matchedRule.severity === "block") {
      ctx.ui.notify(
        `BLOCKED: ${matchedRule.description}\nReason: ${matchedRule.reason || "Dangerous command"}`,
        "error"
      );
      return { block: true, reason: matchedRule.reason };
    }

    if (matchedRule.severity === "confirm") {
      const confirmMsg = `${matchedRule.description}\n\nReason: ${matchedRule.reason || "Potentially dangerous"}\n\nCommand:\n${command}\n\nAllow this command?`;
      const ok = await ctx.ui.confirm("Permission Required", confirmMsg);

      if (!ok) {
        ctx.ui.notify("Command cancelled by user", "warning");
        return { block: true, reason: "User declined" };
      }

      // Log the permission grant for audit trail
      pi.appendEntry("permission-guard-approval", {
        command,
        rule: matchedRule.description,
        timestamp: Date.now(),
        approved: true,
      });

      ctx.ui.notify("Command approved by user", "success");
    }

    // severity === "allow" - do nothing, let command execute
  });

  // Optional: Add a command to view current rules
  pi.registerCommand("permission-rules", {
    description: "Show active permission guard rules",
    handler: async (_args, ctx) => {
      let output = `Permission Guard Configuration\n\n`;
      output += `Enabled: ${config.enabled}\n`;
      output += `Default Behavior: ${config.defaultBehavior}\n`;
      output += `Total Rules: ${config.rules.length}\n\n`;

      config.rules.forEach((rule) => {
        output += `[${rule.severity.toUpperCase()}] ${rule.description}\n`;
        output += `  Pattern: ${rule.pattern}\n`;
        if (rule.reason) {
          output += `  Reason: ${rule.reason}\n`;
        }
        output += `\n`;
      });

      ctx.ui.notify(output, "info");
    },
  });

  // Optional: Add a command to check if a command would be blocked
  pi.registerCommand("permission-check", {
    description: "Check if a command would be allowed",
    handler: async (args, ctx) => {
      if (!args) {
        ctx.ui.notify("Usage: /permission-check <command>", "warning");
        return;
      }

      const testCommand = args;
      const matchedRule = config.rules.find((rule) => {
        const regex = new RegExp(rule.pattern, "m");
        return regex.test(testCommand);
      });

      if (!matchedRule) {
        const status =
          config.defaultBehavior === "block"
            ? "BLOCKED (not in whitelist)"
            : "ALLOWED (no matching rule)";
        ctx.ui.notify(`Command: ${testCommand}\nStatus: ${status}`, "info");
        return;
      }

      let status = "";
      if (matchedRule.severity === "block") {
        status = "BLOCKED";
      } else if (matchedRule.severity === "confirm") {
        status = "REQUIRES CONFIRMATION";
      } else {
        status = "ALLOWED";
      }

      ctx.ui.notify(
        `Command: ${testCommand}\nRule: ${matchedRule.description}\nStatus: ${status}\nReason: ${matchedRule.reason || "N/A"}\nPattern: ${matchedRule.pattern}`,
        "info"
      );
    },
  });

  // Optional: Add a command to toggle permission guard
  pi.registerCommand("permission-toggle", {
    description: "Toggle permission guard on/off",
    handler: async (_args, ctx) => {
      config.enabled = !config.enabled;
      const status = config.enabled ? "ENABLED" : "DISABLED";
      ctx.ui.notify(`Permission Guard: ${status}`, "info");
    },
  });
}
