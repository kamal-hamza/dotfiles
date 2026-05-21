#!/usr/bin/env node

/**
 * =============================================================================
 * Plan Mode Extension - Collaborative Planning & Execution System
 * =============================================================================
 *
 * Purpose:
 * Collaborative architectural planning with persistent artifacts, task tracking,
 * tool restrictions, and execution contracts.
 *
 * Core Philosophy:
 * - Agent and user collaborate on architecture
 * - Plans are persistent, inspectable, editable artifacts
 * - Tool restrictions enforce planning discipline
 * - Success criteria are explicit and measurable
 * - Execution is bounded and resumable
 *
 * Workflow:
 * EXPLORATION → DISCOVERY → CLARIFYING → PLANNING → REVIEWING →
 * APPROVED → EXECUTING → PAUSED/CONTINUED → COMPLETED
 *
 * Commands:
 *   /plan                    Start planning workflow
 *   /plan status             Show current state
 *   /plan show               Display active plan
 *   /plan questions          Show open/resolved questions
 *   /plan decisions          Show all decisions
 *   /plan pause              Pause execution, return to planning
 *   /plan continue           Resume from paused state
 *   /plan revise             Re-enter planning mode during execution
 *   /plan approve            Approve plan for execution
 *   /plan contract           Show execution contract
 *   /plan archive            Archive and reset
 */

import type {
  AssistantMessage,
  TextContent,
} from "@earendil-works/pi-ai";
import type {
  AgentMessage,
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Key } from "@earendil-works/pi-tui";
import * as fs from "fs";
import * as path from "path";

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Types
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

type WorkflowState =
  | "idle"
  | "exploration"
  | "discovery"
  | "clarifying"
  | "planning"
  | "reviewing"
  | "approved"
  | "executing"
  | "paused"
  | "completed"
  | "archived";

type ExecutionMode = "ask-always" | "ask-per-file" | "auto-approved";

interface Question {
  id: string;
  title: string;
  status: "pending" | "resolved";
  question: string;
  options?: Array<{ label: string; description?: string }>;
  suggestion?: string;
  decision?: string;
  createdAt: number;
  resolvedAt?: number;
}

interface Decision {
  id: string;
  title: string;
  decision: string;
  reasoning: string[];
  tradeoffs: Array<{ benefit: string; cost: string }>;
  alternativesConsidered: Array<{ name: string; reason: string }>;
  createdAt: number;
}

interface Task {
  id: string;
  title: string;
  description?: string;
  completed: boolean;
  subtasks?: Task[];
  dependsOn?: string[];
  createdAt: number;
  completedAt?: number;
}

interface SuccessCriterion {
  id: string;
  criterion: string;
  verified: boolean;
  verificationMethod: "manual" | "automated" | "mixed";
}

interface Constraint {
  id: string;
  constraint: string;
  priority: "must" | "should" | "nice-to-have";
  category: "technical" | "business" | "architectural";
}

interface ExecutionPolicy {
  mode: ExecutionMode;
  allowedTools: string[];
  blockedTools: string[];
  requireApprovalFor: string[];
  autoApprovedFor: string[];
}

interface ExecutionContract {
  planId: string;
  goal: string;
  requirements: string[];
  constraints: Constraint[];
  tasks: Task[];
  successCriteria: SuccessCriterion[];
  executionPolicy: ExecutionPolicy;
  bannedChanges: string[];
  approvedAt: number;
  approvedBy: "human" | "system";
}

interface PlanState {
  state: WorkflowState;
  sessionId: string;
  planId: string;
  startedAt: number;
  updatedAt: number;
  pausedAt?: number;
  pauseReason?: string;
  goal?: string;
  projectContext?: string;
  phases: Array<{ name: string; completed: boolean }>;
  risks: string[];
  constraints: Constraint[];
  questions: Question[];
  decisions: Decision[];
  tasks: Task[];
  successCriteria: SuccessCriterion[];
  riskLevel: "low" | "medium" | "high";
  executionPolicy: ExecutionPolicy;
  executionContract?: ExecutionContract;
  gitBranch?: string;
  gitStrategy?: string;
  currentTask?: string;
  completedTasks: number;
  totalTasks: number;
  planDirectory: string;
}

// Type guards
function isAssistantMessage(m: AgentMessage): m is AssistantMessage {
  return m.role === "assistant" && Array.isArray(m.content);
}

function getTextContent(message: AssistantMessage): string {
  return message.content
    .filter((block): block is TextContent => block.type === "text")
    .map((block) => block.text)
    .join("\n");
}

const DEFAULT_EXECUTION_POLICY: ExecutionPolicy = {
  mode: "ask-always",
  allowedTools: ["read", "grep", "search", "plan-artifacts"],
  blockedTools: ["write", "bash", "git-commit", "delete"],
  requireApprovalFor: ["edit", "execute"],
  autoApprovedFor: ["read", "grep"],
};

const DEFAULT_STATE: PlanState = {
  state: "idle",
  sessionId: `plan-${Date.now()}`,
  planId: `plan-${Date.now()}`,
  startedAt: Date.now(),
  updatedAt: Date.now(),
  phases: [],
  risks: [],
  constraints: [],
  questions: [],
  decisions: [],
  tasks: [],
  successCriteria: [],
  riskLevel: "medium",
  executionPolicy: DEFAULT_EXECUTION_POLICY,
  completedTasks: 0,
  totalTasks: 0,
  planDirectory: "",
};

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plan Artifact Management
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function getPlanDirectory(sessionId: string, planId: string): string {
  const homeDir = process.env.HOME || process.env.USERPROFILE || "";
  return path.join(homeDir, ".plan", sessionId, planId);
}

function initializePlanDirectory(sessionId: string, planId: string): string {
  const planDir = getPlanDirectory(sessionId, planId);
  const dirs = [
    planDir,
    path.join(planDir, "archive"),
  ];

  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }

  return planDir;
}

function writePlanFile(planDir: string, filename: string, content: string): void {
  try {
    const filepath = path.join(planDir, filename);
    fs.writeFileSync(filepath, content, "utf-8");
  } catch (e) {
    // Graceful fail for filesystem errors
  }
}

function readPlanFile(planDir: string, filename: string): string {
  try {
    const filepath = path.join(planDir, filename);
    if (fs.existsSync(filepath)) {
      return fs.readFileSync(filepath, "utf-8");
    }
  } catch (e) {
    // Graceful fail
  }
  return "";
}

function formatPlanMarkdown(state: PlanState): string {
  const lines: string[] = [
    "# Plan: " + (state.goal || "Untitled"),
    "",
    "## Status",
    `- State: ${state.state.toUpperCase()}`,
    `- Progress: ${state.completedTasks}/${state.totalTasks} tasks`,
    `- Risk Level: ${state.riskLevel}`,
    `- Last Updated: ${new Date(state.updatedAt).toISOString()}`,
    "",
  ];

  if (state.goal) {
    lines.push("## Goal");
    lines.push(state.goal);
    lines.push("");
  }

  if (state.constraints.length > 0) {
    lines.push("## Constraints");
    for (const c of state.constraints) {
      lines.push(
        `- [${c.priority.toUpperCase()}] ${c.constraint} (${c.category})`
      );
    }
    lines.push("");
  }

  if (state.questions.length > 0) {
    const pending = state.questions.filter((q) => q.status === "pending");
    if (pending.length > 0) {
      lines.push("## Open Questions");
      for (const q of pending) {
        lines.push(`- [ ] ${q.title}`);
      }
      lines.push("");
    }
  }

  if (state.risks.length > 0) {
    lines.push("## Identified Risks");
    for (const risk of state.risks) {
      lines.push(`- ${risk}`);
    }
    lines.push("");
  }

  if (state.successCriteria.length > 0) {
    lines.push("## Success Criteria");
    for (const sc of state.successCriteria) {
      const status = sc.verified ? "✓" : "○";
      lines.push(`- [${status}] ${sc.criterion}`);
    }
    lines.push("");
  }

  if (state.decisions.length > 0) {
    lines.push("## Key Decisions");
    lines.push("See decisions.md for details.");
    lines.push("");
  }

  lines.push("---");
  lines.push(`Session: ${state.sessionId}`);

  return lines.join("\n");
}

function formatDecisionsMarkdown(state: PlanState): string {
  if (state.decisions.length === 0) {
    return "# Decisions\n\nNo decisions recorded yet.\n";
  }

  const lines: string[] = ["# Decisions", ""];

  for (const d of state.decisions) {
    lines.push(`## ${d.title}`);
    lines.push(`**Decision:** ${d.decision}`);
    lines.push("");
    lines.push("**Reasoning:**");
    for (const r of d.reasoning) {
      lines.push(`- ${r}`);
    }
    lines.push("");

    if (d.tradeoffs.length > 0) {
      lines.push("**Tradeoffs:**");
      for (const t of d.tradeoffs) {
        lines.push(`- Benefit: ${t.benefit}`);
        lines.push(`- Cost: ${t.cost}`);
      }
      lines.push("");
    }

    if (d.alternativesConsidered.length > 0) {
      lines.push("**Alternatives Considered:**");
      for (const a of d.alternativesConsidered) {
        lines.push(`- ${a.name}: ${a.reason}`);
      }
      lines.push("");
    }

    lines.push("---");
    lines.push("");
  }

  return lines.join("\n");
}

function formatTasksMarkdown(state: PlanState): string {
  if (state.tasks.length === 0) {
    return "# Tasks\n\nNo tasks defined yet.\n";
  }

  const lines: string[] = [
    "# Tasks",
    "",
    `Progress: ${state.completedTasks}/${state.totalTasks}`,
    "",
  ];

  function formatTask(task: Task, indent: number): void {
    const prefix = "  ".repeat(indent);
    const status = task.completed ? "✓" : "○";
    lines.push(`${prefix}- [${status}] ${task.title}`);
    if (task.description) {
      lines.push(`${prefix}  ${task.description}`);
    }
    if (task.dependsOn && task.dependsOn.length > 0) {
      lines.push(`${prefix}  Depends on: ${task.dependsOn.join(", ")}`);
    }
    if (task.subtasks) {
      for (const subtask of task.subtasks) {
        formatTask(subtask, indent + 1);
      }
    }
  }

  for (const task of state.tasks) {
    formatTask(task, 0);
  }

  return lines.join("\n");
}

function formatExecutionContractMarkdown(
  contract: ExecutionContract
): string {
  const lines: string[] = [
    "# Execution Contract",
    "",
    "## Approved Plan",
    `Goal: ${contract.goal}`,
    "",
    "## Must Follow Constraints",
  ];

  for (const c of contract.constraints) {
    lines.push(`- [${c.priority.toUpperCase()}] ${c.constraint}`);
  }

  lines.push("");
  lines.push("## Do Not Do");
  for (const banned of contract.bannedChanges) {
    lines.push(`- ${banned}`);
  }

  lines.push("");
  lines.push("## Success Criteria");
  for (const sc of contract.successCriteria) {
    const status = sc.verified ? "✓" : "○";
    lines.push(`- [${status}] ${sc.criterion}`);
  }

  lines.push("");
  lines.push("## Execution Permissions");
  lines.push(`- Mode: ${contract.executionPolicy.mode}`);
  lines.push(`- Allowed Tools: ${contract.executionPolicy.allowedTools.join(", ")}`);
  lines.push(
    `- Blocked Tools: ${contract.executionPolicy.blockedTools.join(", ")}`
  );

  lines.push("");
  lines.push(`Approved: ${new Date(contract.approvedAt).toISOString()}`);
  lines.push(`By: ${contract.approvedBy}`);

  return lines.join("\n");
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Extension
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

export default function planModeExtension(pi: ExtensionAPI): void {
  let state: PlanState = { ...DEFAULT_STATE };

  // ─────────────────────────────────────────────────────────────────────────
  // Session Management
  // ─────────────────────────────────────────────────────────────────────────

  pi.on("session_start", async (_event, ctx) => {
    // Restore state from previous session
    for (const entry of ctx.sessionManager.getEntries()) {
      if (entry.type === "custom" && entry.customType === "plan-mode-state") {
        try {
          const savedState = entry.data as PlanState;
          state = savedState;
          break;
        } catch {
          // Use default state
        }
      }
    }

    // Show status if planning is active
    if (state.state !== "idle" && state.state !== "archived") {
      const status =
        state.state === "paused"
          ? `PAUSED: ${state.pauseReason}`
          : state.goal || "untitled";
      ctx.ui.notify(
        `Plan Mode: ${state.state.toUpperCase()} — ${status}`,
        "info"
      );
      updateStatusBar(ctx, state);
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Display & Status
  // ─────────────────────────────────────────────────────────────────────────

  function updateStatusBar(ctx: ExtensionContext, state: PlanState): void {
    if (state.state === "idle" || state.state === "archived") {
      ctx.ui.setStatus("plan-mode", undefined);
      ctx.ui.setWidget("plan-info", undefined);
      return;
    }

    const stateEmoji: Record<WorkflowState, string> = {
      exploration: "🔎",
      discovery: "🔍",
      clarifying: "❓",
      planning: "📋",
      reviewing: "👀",
      approved: "✓",
      executing: "⚡",
      paused: "⏸",
      completed: "🎉",
      idle: "—",
      archived: "📦",
    };

    const emoji = stateEmoji[state.state] || "—";
    const pendingQuestions = state.questions.filter(
      (q) => q.status === "pending"
    ).length;
    const details =
      state.state === "paused"
        ? `${state.pauseReason}`
        : state.state === "executing"
          ? `${state.completedTasks}/${state.totalTasks} tasks`
          : pendingQuestions > 0
            ? `${pendingQuestions} Q`
            : state.state;

    ctx.ui.setStatus(
      "plan-mode",
      ctx.ui.theme.fg(
        state.state === "reviewing" ? "accent" : "warning",
        `${emoji} ${details}`
      )
    );

    // Widget showing plan summary
    if (state.state !== "idle") {
      const lines: string[] = [];
      lines.push(`Goal: ${state.goal || "(pending)"}`);

      if (state.state === "executing" || state.state === "paused") {
        lines.push(
          `Progress: ${state.completedTasks}/${state.totalTasks} tasks`
        );
      }

      if (pendingQuestions > 0) {
        lines.push(
          `${ctx.ui.theme.fg("warning", `${pendingQuestions} open questions`)}`
        );
      }

      if (state.riskLevel === "high") {
        lines.push(`${ctx.ui.theme.fg("error", "⚠️  High risk")}`);
      }

      if (state.state === "paused") {
        lines.push(
          `${ctx.ui.theme.fg("warning", `Paused: ${state.pauseReason}`)}`
        );
      }

      ctx.ui.setWidget("plan-info", lines);
    }
  }

  function showStatus(ctx: ExtensionContext, state: PlanState): void {
    const lines = [
      "Plan Mode Status",
      "════════════════",
      `State: ${state.state.toUpperCase()}`,
      `Goal: ${state.goal || "(not set)"}`,
      `Session: ${state.sessionId}`,
      `Plan ID: ${state.planId}`,
      `Open Questions: ${state.questions.filter((q) => q.status === "pending").length}`,
      `Decisions Made: ${state.decisions.length}`,
      `Tasks: ${state.completedTasks}/${state.totalTasks}`,
      `Risk Level: ${state.riskLevel}`,
    ];

    if (state.state === "paused") {
      lines.push(`Paused Reason: ${state.pauseReason}`);
    }

    if (state.gitBranch) {
      lines.push(`Git Branch: ${state.gitBranch}`);
    }

    ctx.ui.notify(lines.join("\n"), "info");
  }

  function showPlan(ctx: ExtensionContext, state: PlanState): void {
    if (state.state === "idle") {
      ctx.ui.notify("No active plan. Use `/plan` to start.", "warning");
      return;
    }

    const planContent = formatPlanMarkdown(state);
    ctx.ui.notify(planContent, "info");
  }

  function showDecisions(ctx: ExtensionContext, state: PlanState): void {
    if (state.decisions.length === 0) {
      ctx.ui.notify("No decisions recorded yet.", "info");
      return;
    }

    const content = formatDecisionsMarkdown(state);
    ctx.ui.notify(content, "info");
  }

  function showTasks(ctx: ExtensionContext, state: PlanState): void {
    if (state.tasks.length === 0) {
      ctx.ui.notify("No tasks defined yet.", "info");
      return;
    }

    const content = formatTasksMarkdown(state);
    ctx.ui.notify(content, "info");
  }

  function showQuestions(ctx: ExtensionContext, state: PlanState): void {
    if (state.questions.length === 0) {
      ctx.ui.notify("No questions recorded yet.", "info");
      return;
    }

    const lines = ["# Questions"];
    const pending = state.questions.filter((q) => q.status === "pending");
    const resolved = state.questions.filter((q) => q.status === "resolved");

    if (pending.length > 0) {
      lines.push("## Open Questions", "");
      for (const q of pending) {
        lines.push(`**${q.title}**`);
        lines.push(q.question);
        if (q.options) {
          for (const opt of q.options) {
            lines.push(
              `  - ${opt.label}${opt.description ? `: ${opt.description}` : ""}`
            );
          }
        }
        if (q.suggestion) {
          lines.push(`Suggestion: ${q.suggestion}`);
        }
        lines.push("");
      }
    }

    if (resolved.length > 0) {
      lines.push("## Resolved", "");
      for (const q of resolved) {
        lines.push(`✓ **${q.title}**`);
        lines.push(`  Decision: ${q.decision}`);
        lines.push("");
      }
    }

    ctx.ui.notify(lines.join("\n"), "info");
  }

  function showContract(ctx: ExtensionContext, state: PlanState): void {
    if (!state.executionContract) {
      ctx.ui.notify(
        "No execution contract generated yet. Approve the plan first.",
        "warning"
      );
      return;
    }

    const content = formatExecutionContractMarkdown(state.executionContract);
    ctx.ui.notify(content, "info");
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Commands
  // ─────────────────────────────────────────────────────────────────────────

  pi.registerCommand("plan", {
    description: "Collaborative planning workflow with persistent artifacts",
    handler: async (args, ctx) => {
      const subcommand = (args || "").trim().toLowerCase();

      switch (subcommand) {
        case "status":
          showStatus(ctx, state);
          break;
        case "show":
          showPlan(ctx, state);
          break;
        case "tasks":
          showTasks(ctx, state);
          break;
        case "questions":
          showQuestions(ctx, state);
          break;
        case "decisions":
          showDecisions(ctx, state);
          break;
        case "contract":
          showContract(ctx, state);
          break;
        case "pause":
          if (state.state !== "executing") {
            ctx.ui.notify(
              "Can only pause during execution. Current state: " + state.state,
              "warning"
            );
          } else {
            const reason = await ctx.ui.editor(
              "Why pause planning?",
              "Pausing to reconsider approach"
            );
            state.state = "paused";
            state.pausedAt = Date.now();
            state.pauseReason = reason || "User pause";
            state.updatedAt = Date.now();
            persistState(pi, state);
            updateStatusBar(ctx, state);
            ctx.ui.notify(
              `Plan paused: ${state.pauseReason}`,
              "info"
            );
          }
          break;
        case "continue":
          if (state.state !== "paused") {
            ctx.ui.notify(
              "Plan is not paused. Current state: " + state.state,
              "warning"
            );
          } else {
            state.state = "executing";
            state.pausedAt = undefined;
            state.pauseReason = undefined;
            state.updatedAt = Date.now();
            persistState(pi, state);
            updateStatusBar(ctx, state);
            ctx.ui.notify("Plan resumed", "success");

            // Inject continuation context
            await pi.sendMessage(
              {
                customType: "plan-resumed",
                content:
                  "Plan execution resumed. Continue with the current task and approved architecture.",
                display: false,
              },
              { triggerTurn: false, deliverAs: "nextTurn" }
            );
          }
          break;
        case "revise":
          if (state.state !== "executing" && state.state !== "paused") {
            ctx.ui.notify(
              "Can only revise during execution. Current state: " + state.state,
              "warning"
            );
          } else {
            state.state = "planning";
            state.pausedAt = Date.now();
            state.updatedAt = Date.now();
            persistState(pi, state);
            updateStatusBar(ctx, state);

            await pi.sendMessage(
              {
                customType: "plan-revise",
                content:
                  "Returning to planning mode. Review and revise the plan as needed.",
                display: true,
              },
              { triggerTurn: true }
            );
          }
          break;
        case "approve":
          if (state.state === "reviewing") {
            // Generate execution contract
            state.executionContract = {
              planId: state.planId,
              goal: state.goal || "Untitled",
              requirements: state.questions
                .filter((q) => q.status === "resolved")
                .map((q) => q.decision || ""),
              constraints: state.constraints,
              tasks: state.tasks,
              successCriteria: state.successCriteria,
              executionPolicy: state.executionPolicy,
              bannedChanges: [
                "Refactor unrelated code",
                "Change persistence format",
                "Introduce unauthorized dependencies",
              ],
              approvedAt: Date.now(),
              approvedBy: "human",
            };

            state.state = "approved";
            state.updatedAt = Date.now();
            persistState(pi, state);
            updateStatusBar(ctx, state);

            // Write contract to artifacts
            if (state.planDirectory) {
              writePlanFile(
                state.planDirectory,
                "contract.md",
                formatExecutionContractMarkdown(state.executionContract)
              );
            }

            ctx.ui.notify(
              `Plan approved. Ready for execution: ${state.goal}`,
              "success"
            );

            await pi.sendMessage(
              {
                customType: "plan-approved",
                content: `Plan approved for execution.

Execution Contract:
- Goal: ${state.goal}
- Tasks: ${state.tasks.length}
- Success Criteria: ${state.successCriteria.length}
- Constraints: ${state.constraints.length}

Proceed with implementation following the approved plan.`,
                display: false,
              },
              { triggerTurn: false, deliverAs: "nextTurn" }
            );
          } else {
            ctx.ui.notify(
              "Plan must be in REVIEWING state. Use `/plan show` to check.",
              "warning"
            );
          }
          break;
        case "archive":
          if (state.state === "idle") {
            ctx.ui.notify("No active session to archive.", "warning");
          } else {
            const archiveId = `${state.planId}-archived-${Date.now()}`;
            ctx.ui.notify(
              `Session archived: ${archiveId}\n${state.questions.length} questions, ${state.decisions.length} decisions`,
              "success"
            );
            state = { ...DEFAULT_STATE };
            persistState(pi, state);
            updateStatusBar(ctx, state);
          }
          break;
        default:
          // Start new planning session
          await startPlanning(ctx, pi, state);
          break;
      }
    },
  });

  pi.registerCommand("todos", {
    description: "Show plan progress and tasks",
    handler: async (_args, ctx) => {
      showTasks(ctx, state);
    },
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Keyboard Shortcut
  // ─────────────────────────────────────────────────────────────────────────

  pi.registerShortcut(Key.ctrlAlt("p"), {
    description: "Toggle plan mode",
    handler: async (ctx) => {
      if (state.state === "idle") {
        await startPlanning(ctx, pi, state);
      } else {
        const choice = await ctx.ui.select("Plan Mode", [
          "Show current plan",
          "Show tasks",
          "Pause/Continue",
          "Archive and restart",
        ]);

        if (choice === "Show current plan") {
          showPlan(ctx, state);
        } else if (choice === "Show tasks") {
          showTasks(ctx, state);
        } else if (choice === "Pause/Continue") {
          if (state.state === "executing") {
            const reason = await ctx.ui.editor(
              "Why pause?",
              "Pausing for re-evaluation"
            );
            state.state = "paused";
            state.pausedAt = Date.now();
            state.pauseReason = reason || "User pause";
            persistState(pi, state);
            updateStatusBar(ctx, state);
          } else if (state.state === "paused") {
            state.state = "executing";
            state.pausedAt = undefined;
            persistState(pi, state);
            updateStatusBar(ctx, state);
          }
        } else if (choice === "Archive and restart") {
          state = { ...DEFAULT_STATE };
          persistState(pi, state);
          await startPlanning(ctx, pi, state);
        }
      }
    },
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Workflow Functions
  // ─────────────────────────────────────────────────────────────────────────

  async function startPlanning(
    ctx: ExtensionContext,
    pi: ExtensionAPI,
    state: PlanState
  ): Promise<void> {
    if (state.state !== "idle") {
      const resume = await ctx.ui.confirm(
        "Active Planning Session",
        `Resume "${state.goal}" or start new session?`
      );
      if (resume) {
        ctx.ui.notify(
          `Resumed: ${state.state.toUpperCase()} - ${state.goal}`,
          "info"
        );
        updateStatusBar(ctx, state);
        return;
      } else {
        state = { ...DEFAULT_STATE };
      }
    }

    // Initialize plan directory
    state.planDirectory = initializePlanDirectory(state.sessionId, state.planId);
    state.state = "exploration";
    state.startedAt = Date.now();
    state.updatedAt = Date.now();

    // Inject exploration guidance
    await pi.sendMessage(
      {
        customType: "plan-mode-exploration-start",
        content: `[EXPLORATION PHASE]

Before we plan, let's understand this project.

Please explore and analyze:

1. **Project Structure** - Directory layout, main files/folders
2. **Project Type** - What kind of project is this? (dotfiles, app, library, etc.)
3. **Current Purpose** - What does it currently do?
4. **Technologies & Tools** - Languages, frameworks, tools being used
5. **Configuration Files** - package.json, cargo.toml, .yaml files, etc.
6. **Key Scripts/Executables** - Important commands or entry points
7. **Documentation** - README, AGENTS.md, or other docs

Look at the file structure and understand what this project is about. Summarize your findings.`,
        display: true,
      },
      { triggerTurn: false, deliverAs: "nextTurn" }
    );

    ctx.ui.notify(
      "Plan Mode: EXPLORATION\n\nLet's explore the project first...",
      "info"
    );

    updateStatusBar(ctx, state);
    persistState(pi, state);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Agent Context Injection
  // ─────────────────────────────────────────────────────────────────────────

  pi.on("before_agent_start", async (_event, ctx) => {
    if (state.state === "exploration") {
      return {
        message: {
          customType: "plan-mode-exploration",
          content: `[EXPLORATION PHASE]

Analyze this project to understand its structure and purpose.

What to look for:
1. Project organization
2. Technology stack
3. Existing patterns and conventions
4. Build/setup process
5. Documentation
6. Key files and components

Provide a concise summary of what this project is and how it works.`,
          display: false,
        },
      };
    }

    if (state.state === "discovery" || state.state === "clarifying") {
      const projectInfo = state.projectContext
        ? `\n\n**Project Context from Exploration:**\n${state.projectContext}`
        : "";

      return {
        message: {
          customType: "plan-mode-context",
          content: `[PLAN MODE: THINKING PHASE]

You are in planning mode. Your role is to:

1. **Ask great clarifying questions** - Expose hidden complexity
2. **Identify constraints** - Understand technical and business limitations
3. **Surface tradeoffs** - Show benefit vs. cost
4. **Help decompose tasks** - Break into concrete implementation steps
5. **Define success criteria** - How do we know we're done?
6. **Preserve user agency** - Guide, don't decide for them
7. **Be collaborative** - Like a thoughtful senior engineer

TOOL RESTRICTIONS (Plan Mode):
- Allowed: read, grep, search, analyze
- Blocked: write, bash, delete, git commit
- The plan itself is the artifact, not code yet

FOCUS AREAS:
- Requirements and constraints
- Success criteria (what "done" looks like)
- Task decomposition (concrete steps)
- Technical decisions and tradeoffs
- Risks and mitigation${projectInfo}`,
          display: false,
        },
      };
    }

    if (state.state === "approved" || state.state === "executing") {
      return {
        message: {
          customType: "plan-execution-context",
          content: `[EXECUTION PHASE]

The plan has been approved. Proceed with implementation.

EXECUTION CONTRACT:
${state.executionContract ? `- Goal: ${state.executionContract.goal}` : ""}
- Constraints: ${state.constraints.map((c) => c.constraint).join(", ")}
- Tasks: ${state.tasks.length}
- Success Criteria: ${state.successCriteria.length}

TOOL POLICY (Execution):
- Use restricted tools appropriately
- Ask for approval on sensitive operations
- Track progress against tasks

DO NOT:
- Violate approved constraints
- Make changes outside approved scope
- Introduce unauthorized dependencies`,
          display: false,
        },
      };
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Progress Tracking
  // ─────────────────────────────────────────────────────────────────────────

  pi.on("agent_end", async (event, ctx) => {
    // After exploration, capture findings and move to discovery
    if (state.state === "exploration") {
      const lastAssistant = [...event.messages]
        .reverse()
        .find(isAssistantMessage);
      if (lastAssistant) {
        const text = getTextContent(lastAssistant);
        state.projectContext = text;

        // Write exploration findings
        if (state.planDirectory) {
          writePlanFile(state.planDirectory, "exploration.md", text);
        }
      }

      state.state = "discovery";
      state.updatedAt = Date.now();
      persistState(pi, state);
      updateStatusBar(ctx, state);

      await pi.sendMessage(
        {
          customType: "plan-mode-discovery",
          content: `Great! Now that I understand this project, let's plan what you want to build.

**Tell me:**
1. What's the goal? (1-2 sentences)
2. What problem does it solve?
3. Who will use it?
4. What constraints matter most? (speed, scalability, simplicity, etc.)

Take your time. Good planning saves implementation time and reduces regret.`,
          display: true,
        },
        { triggerTurn: true }
      );
    }

    // After planning phase, offer review
    if (state.state === "planning" && ctx.hasUI) {
      const action = await ctx.ui.select("Planning Complete", [
        "Review plan before approval",
        "Continue refining",
        "Cancel and restart",
      ]);

      if (action === "Review plan before approval") {
        state.state = "reviewing";
        state.updatedAt = Date.now();
        persistState(pi, state);
        updateStatusBar(ctx, state);

        // Update plan artifacts
        if (state.planDirectory) {
          writePlanFile(
            state.planDirectory,
            "plan.md",
            formatPlanMarkdown(state)
          );
          writePlanFile(
            state.planDirectory,
            "tasks.md",
            formatTasksMarkdown(state)
          );
          writePlanFile(
            state.planDirectory,
            "decisions.md",
            formatDecisionsMarkdown(state)
          );
        }

        await pi.sendMessage(
          {
            customType: "plan-review-request",
            content: `The plan is complete. Let me review it thoroughly for:
- Completeness and clarity
- Tradeoffs and hidden complexity
- Risks and mitigation
- Success criteria

Review findings:`,
            display: true,
          },
          { triggerTurn: true }
        );
      } else if (action === "Continue refining") {
        await pi.sendUserMessage(
          "Let's refine the plan further. What needs adjustment?"
        );
      } else if (action === "Cancel and restart") {
        state = { ...DEFAULT_STATE };
        persistState(pi, state);
        updateStatusBar(ctx, state);
      }
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Persistence
  // ─────────────────────────────────────────────────────────────────────────

  function persistState(pi: ExtensionAPI, state: PlanState): void {
    pi.appendEntry("plan-mode-state", state);
  }
}
