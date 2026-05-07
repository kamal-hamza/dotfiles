#!/usr/bin/env node
/**
 * =============================================================================
 * Permission Gates Extension for Pi
 * =============================================================================
 * 
 * Protects your system by intercepting and gating dangerous commands before
 * they execute. Requires explicit user confirmation for risky operations.
 *
 * Features:
 * - Block destructive commands (rm -rf, mkfs, dd, etc.)
 * - Require sudo confirmation for privilege escalation
 * - Gate mass deletion patterns
 * - Configurable danger levels (strict, moderate, permissive)
 * - Audit log of blocked/allowed commands
 * - Whitelist safe patterns
 * - Smart detection (e.g., rm with -r and / flags)
 * =============================================================================
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";

interface CommandAudit {
  timestamp: string;
  command: string;
  status: "blocked" | "allowed" | "denied";
  reason?: string;
  userConfirmed?: boolean;
}

interface PermissionGatesConfig {
  dangerLevel: "strict" | "moderate" | "permissive";
  auditLog: boolean;
  auditFile: string;
  enableWhitelist: boolean;
  whitelist: string[];
}

// Default configuration
const DEFAULT_CONFIG: PermissionGatesConfig = {
  dangerLevel: "strict",
  auditLog: true,
  auditFile: path.join(process.env.HOME || "/tmp", ".pi/permission-gates-audit.log"),
  enableWhitelist: true,
  whitelist: [
    "# Safe patterns (regexes) - add your own",
    "^rm -f /tmp/[a-z0-9_-]+\\.(tmp|log)$",
    "^mkdir -p .*$",
    "^ls .*$",
    "^cat .*$",
    "^echo .*$",
  ],
};

// Audit log instance
let auditLog: CommandAudit[] = [];
let config: PermissionGatesConfig = { ...DEFAULT_CONFIG };

/**
 * Dangerous command patterns by category
 */
const DANGER_PATTERNS = {
  // Filesystem destruction
  critical: [
    /^\s*rm\s+.*(-r|-R|--recursive).*\/\s*$/,  // rm -rf /
    /^\s*rm\s+.*(-r|-R|--recursive).*\/.*\*\s*$/,  // rm -rf /*/*
    /^\s*mkfs/,  // mkfs.* (format filesystem)
    /^\s*dd\s+.*if=\/dev\/(zero|random)/,  // dd to filesystem
    /^\s*dd\s+of=\/dev\/(zero|random)/,
    /^\s*shred\s+.*\/\s*$/,  // shred /
    /^\s*format\s+\/dev\//,  // format drives
    /^\s*wipefs\s+\/dev\//,  // wipefs
    /^\s*parted\s+.*rm\s+/,  // parted rm partitions
  ],

  // Destructive operations
  severe: [
    /^\s*rm\s+.*(-r|-R|--recursive)/,  // any rm -r
    /^\s*rm\s+.*-f.*\/[^/]/,  // rm -f paths
    /^\s*find\s+.*-delete/,  // find -delete
    /^\s*rsync\s+.*--delete/,  // rsync --delete
    /^\s*git\s+.*-f.*--all/,  // git -f --all
    /^\s*git\s+clean\s+.*-f/,  // git clean -f
    /^\s*truncate\s+.*-s\s+0/,  // truncate to zero
    /^\s*cp\s+\/dev\/(zero|urandom).*\//,  // cp from /dev/*
  ],

  // Privilege escalation
  sudo: [
    /^\s*sudo\s+/,  // any sudo command
    /^\s*sudo\s+-s/,  // sudo shell
    /^\s*sudo\s+-i/,  // sudo login shell
  ],

  // Dangerous utilities
  system: [
    /^\s*reboot\s*$/,
    /^\s*shutdown\s+/,
    /^\s*halt\s*$/,
    /^\s*poweroff\s*$/,
    /^\s*init\s+[06]/,  // init 0 or 6
    /^\s*systemctl\s+(reboot|shutdown|poweroff|halt)/,
    /^\s*killall\s+-9/,  // killall -9
    /^\s*kill\s+-9\s+-1/,  // kill -9 -1
  ],

  // Network/security dangerous
  network: [
    /^\s*iptables\s+.*-F/,  // iptables -F (flush)
    /^\s*firewall-cmd\s+.*--set-default-zone/,
    /^\s*ip\s+rule\s+del\s+/,
    /^\s*route\s+del\s+/,
  ],

  // Package manager dangers
  package: [
    /^\s*(apt|apt-get|yum|pacman|brew)\s+.*-y.*remove\s+/,  // Force remove
    /^\s*(apt|apt-get)\s+autoremove\s+-y/,
    /^\s*npm\s+uninstall\s+-g\s+(node|npm)/,  // Uninstall npm/node itself
  ],

  // Database dangers (moderate)
  database: [
    /^\s*(mysql|psql|sqlite3)\s+.*DROP\s+DATABASE/,
    /^\s*(mysql|psql|sqlite3)\s+.*DROP\s+TABLE/,
  ],
};

/**
 * Determine danger level of command
 */
function assessDanger(command: string): {
  level: "critical" | "severe" | "sudo" | "system" | "network" | "package" | "database" | null;
  match: string | null;
} {
  const trimmed = command.trim();

  for (const [level, patterns] of Object.entries(DANGER_PATTERNS)) {
    for (const pattern of patterns) {
      if (pattern.test(trimmed)) {
        return { level: level as any, match: trimmed };
      }
    }
  }

  return { level: null, match: null };
}

/**
 * Check if command is whitelisted
 */
function isWhitelisted(command: string): boolean {
  if (!config.enableWhitelist) return false;

  const trimmed = command.trim();
  return config.whitelist.some((pattern) => {
    if (pattern.startsWith("#")) return false;  // Skip comments
    try {
      return new RegExp(pattern).test(trimmed);
    } catch {
      return false;
    }
  });
}

/**
 * Should gate this command based on config?
 */
function shouldGate(command: string): boolean {
  const { level } = assessDanger(command);

  if (!level) return false;

  // Check whitelist first
  if (isWhitelisted(command)) {
    return false;
  }

  // Check against danger level
  switch (config.dangerLevel) {
    case "strict":
      // Gate everything except database
      return level !== null;

    case "moderate":
      // Gate critical, severe, sudo, system
      return ["critical", "severe", "sudo", "system"].includes(level);

    case "permissive":
      // Only gate critical
      return level === "critical";

    default:
      return true;
  }
}

/**
 * Add command to audit log
 */
function auditCommand(
  command: string,
  status: "blocked" | "allowed" | "denied",
  reason?: string
): void {
  const audit: CommandAudit = {
    timestamp: new Date().toISOString(),
    command,
    status,
    reason,
  };

  auditLog.push(audit);

  if (config.auditLog) {
    try {
      const logEntry = `${audit.timestamp} [${audit.status.toUpperCase()}] ${audit.command}${
        audit.reason ? ` (${audit.reason})` : ""
      }\n`;
      fs.appendFileSync(config.auditFile, logEntry);
    } catch (e) {
      // Silently fail if can't write audit log
    }
  }
}

/**
 * Format danger assessment for display
 */
function formatDangerAssessment(level: string): string {
  const levels = {
    critical: "[CRITICAL] System-destroying command",
    severe: "[SEVERE] Destructive operation",
    sudo: "[ELEVATED] Requires root privilege",
    system: "[SYSTEM] System control",
    network: "[NETWORK] Network configuration",
    package: "[PACKAGE] Package management",
    database: "[DATABASE] Data loss risk",
  };
  return levels[level as keyof typeof levels] || "[WARNING] UNKNOWN";
}

/**
 * Get danger tips for the command
 */
function getDangerTips(command: string, level: string): string[] {
  const tips: { [key: string]: string[] } = {
    critical: [
      "This will destroy your filesystem.",
      "There is NO recovery from this.",
      "Consider running outside of an agent.",
    ],
    severe: [
      "This will permanently delete files.",
      "Make sure you have backups.",
      "Double-check the path is what you intend.",
    ],
    sudo: [
      "This requires root/admin privileges.",
      "Only approve if you trust the command.",
      "Check the full command carefully.",
    ],
    system: [
      "This will affect your entire system.",
      "Make sure it's the right time to do this.",
      "Close important work first.",
    ],
    network: [
      "This modifies network settings.",
      "This could disconnect you.",
      "Have recovery plan ready.",
    ],
    package: [
      "This will remove packages.",
      "Check dependencies first.",
      "Have rollback plan ready.",
    ],
    database: [
      "This will destroy database content.",
      "Make sure backups exist.",
      "Double-check database name.",
    ],
  };

  return tips[level] || ["Be very careful with this command."];
}

/**
 * Initialize audit directory
 */
function initAuditDir(): void {
  try {
    const dir = path.dirname(config.auditFile);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  } catch (e) {
    // Silently fail
  }
}

/**
 * Load configuration from file
 */
function loadConfig(): void {
  try {
    const configFile = path.join(
      process.env.HOME || "/tmp",
      ".pi/permission-gates-config.json"
    );

    if (fs.existsSync(configFile)) {
      const fileConfig = JSON.parse(fs.readFileSync(configFile, "utf-8"));
      config = { ...DEFAULT_CONFIG, ...fileConfig };
    } else {
      config = { ...DEFAULT_CONFIG };
    }
  } catch (e) {
    config = { ...DEFAULT_CONFIG };
  }

  initAuditDir();
}

/**
 * Format command for display (truncate if too long)
 */
function formatCommand(command: string, maxLength: number = 120): string {
  if (command.length <= maxLength) {
    return command;
  }
  return command.substring(0, maxLength - 3) + "...";
}

/**
 * Main extension function
 */
export default function (pi: ExtensionAPI) {
  // Initialize
  loadConfig();

  // On session start, notify about gates
  pi.on("session_start", async (event, ctx) => {
    ctx.ui.notify(
      `[PERMISSION GATES] Active (${config.dangerLevel} mode)`,
      "info"
    );
  });

  // Intercept tool calls to bash
  pi.on("tool_call", async (event, ctx) => {
    // Only care about bash tool
    if (event.toolName !== "bash") {
      return;
    }

    const command = (event.input as { command?: string }).command;
    if (!command || typeof command !== "string") {
      return;
    }

    // Check if command should be gated
    if (!shouldGate(command)) {
      return;
    }

    // Command is dangerous - ask for confirmation
    const { level, match } = assessDanger(command);

    ctx.ui.setStatus(
      "permission-gates",
      `[WAITING] Permission confirmation required...`
    );

    // Build confirmation message
    let message = `${formatDangerAssessment(level!)}\n\n`;
    message += `Command: ${formatCommand(command)}\n\n`;
    message += "[WARNING] Tips:\n";
    getDangerTips(command, level!).forEach((tip) => {
      message += `  - ${tip}\n`;
    });

    // Ask user
    const confirmed = await ctx.ui.confirm(
      "Dangerous Command Gate",
      message + "\nAllow this command?"
    );

    ctx.ui.setStatus("permission-gates", "");

    if (confirmed) {
      auditCommand(command, "allowed", `Confirmed by user`);
      // Allow execution
      return;
    } else {
      auditCommand(command, "denied", `User rejected`);
      // Block execution
      return {
        block: true,
        reason: `Command blocked by permission gates (${level} level). User denied execution.`,
      };
    }
  });

  // Register /permission-gates command for management
  pi.registerCommand("permission-gates", {
    description: "Manage permission gates configuration",
    handler: async (args, ctx) => {
      const [subcommand] = (args || "").split(" ");

      switch (subcommand) {
        case "status":
          ctx.ui.notify(
            `Permission Gates Status:\n  Mode: ${config.dangerLevel}\n  Audit: ${
              config.auditLog ? "enabled" : "disabled"
            }\n  Whitelist: ${config.enableWhitelist ? "enabled" : "disabled"}`,
            "info"
          );
          break;

        case "level":
          const newLevel = (args || "").split(" ")[1] as
            | "strict"
            | "moderate"
            | "permissive";
          if (["strict", "moderate", "permissive"].includes(newLevel)) {
            config.dangerLevel = newLevel;
            ctx.ui.notify(`Permission gates level set to: ${newLevel}`, "success");
          } else {
            ctx.ui.notify(
              "Usage: /permission-gates level [strict|moderate|permissive]",
              "warn"
            );
          }
          break;

        case "log":
          if (auditLog.length === 0) {
            ctx.ui.notify("No commands logged yet", "info");
          } else {
            const logLines = auditLog
              .slice(-10)  // Last 10
              .map(
                (a) =>
                  `[${a.status.toUpperCase()}] ${a.command.substring(0, 80)}`
              );
            ctx.ui.notify(`Recent Activity:\n${logLines.join("\n")}`, "info");
          }
          break;

        case "audit-file":
          ctx.ui.notify(`Audit log: ${config.auditFile}`, "info");
          break;

        case "help":
        default:
          ctx.ui.notify(
            `Permission Gates - Commands:\n
  /permission-gates status         - Show current configuration\n  /permission-gates level [mode]   - Change level (strict|moderate|permissive)\n  /permission-gates log            - Show recent command log\n  /permission-gates audit-file     - Show audit log file location\n  /permission-gates help           - Show this help`,
            "info"
          );
          break;
      }
    },
  });
}
