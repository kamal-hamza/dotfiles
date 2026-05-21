#!/usr/bin/env bash

# =============================================================================
# Plan Mode Extension - Implementation Guide
# =============================================================================

# ARCHITECTURE EVOLUTION
# ──────────────────────────────────────────────────────────────────────────

# Phase 1: Persistent Artifacts (Implemented)
# • Plan generation in .plan/ directory
# • Task decomposition and tracking
# • Success criteria management
# • Tool restriction layer
# • Execution contract generation
# • Pause/continue/revise workflow

# ──────────────────────────────────────────────────────────────────────────
# What was created:
# ──────────────────────────────────────────────────────────────────────────

# 1. index.ts (~900 lines)
#    - Core extension implementation
#    - Plan artifact generation and management
#    - Task decomposition system
#    - Tool restriction layer
#    - Execution contract formalization
#    - Pause/continue/revise workflow
#    - State machine (EXPLORATION → ... → ARCHIVED)
#    - Commands: /plan, /todos + subcommands
#    - Keyboard shortcut: Ctrl+Alt+P

# 2. README.md (~550 lines)
#    - Complete user guide
#    - Philosophy: plans as artifacts
#    - Artifact structure (.plan/ directory)
#    - Workflow states and transitions
#    - Command reference
#    - Tool restriction explanation
#    - Execution contract details
#    - Pause/resume/revise patterns
#    - Git integration
#    - Best practices

# ──────────────────────────────────────────────────────────────────────────
# Key Features:
# ──────────────────────────────────────────────────────────────────────────

# ✓ Human-driven decision making (agent advises, user decides)
# ✓ Project exploration first (agent analyzes structure)
# ✓ Persistent plan artifacts (.plan/ directory)
# ✓ Task decomposition with progress tracking
# ✓ Success criteria (definition of done)
# ✓ Tool restriction layer (planning vs execution boundaries)
# ✓ Execution contracts (formal handoff)
# ✓ Pause/Continue/Revise workflow (interruptibility)
# ✓ Decision registry with reasoning
# ✓ Constraint tracking and validation
# ✓ Risk management
# ✓ Git-friendly artifact format

# ──────────────────────────────────────────────────────────────────────────
# Core Types:
# ──────────────────────────────────────────────────────────────────────────

# interface Task {
#   id: string;
#   title: string;
#   description?: string;
#   completed: boolean;
#   subtasks?: Task[];
#   dependsOn?: string[];
# }

# interface SuccessCriterion {
#   id: string;
#   criterion: string;
#   verified: boolean;
#   verificationMethod: "manual" | "automated" | "mixed";
# }

# interface Constraint {
#   id: string;
#   constraint: string;
#   priority: "must" | "should" | "nice-to-have";
#   category: "technical" | "business" | "architectural";
# }

# interface ExecutionPolicy {
#   mode: "ask-always" | "ask-per-file" | "auto-approved";
#   allowedTools: string[];
#   blockedTools: string[];
#   requireApprovalFor: string[];
#   autoApprovedFor: string[];
# }

# interface ExecutionContract {
#   planId: string;
#   goal: string;
#   requirements: string[];
#   constraints: Constraint[];
#   tasks: Task[];
#   successCriteria: SuccessCriterion[];
#   executionPolicy: ExecutionPolicy;
#   bannedChanges: string[];
#   approvedAt: number;
#   approvedBy: "human" | "system";
# }

# ──────────────────────────────────────────────────────────────────────────
# File Structure:
# ──────────────────────────────────────────────────────────────────────────

# ~/.plan/
# ├── [session-id]/
# │   └── [plan-id]/
# │       ├── plan.md             # Main document (auto-generated)
# │       ├── decisions.md        # Decision registry (auto-generated)
# │       ├── tasks.md            # Task decomposition (auto-generated)
# │       ├── exploration.md      # Project analysis
# │       ├── contract.md         # Execution contract (after approval)
# │       └── archive/            # Completed plans

# plan.md contains:
#   - Goal
#   - Constraints (MUST/SHOULD/NICE)
#   - Open questions
#   - Risks
#   - Success criteria
#   - Status and progress

# ──────────────────────────────────────────────────────────────────────────
# State Machine:
# ──────────────────────────────────────────────────────────────────────────

# States:
#   IDLE → EXPLORATION → DISCOVERY → CLARIFYING → PLANNING → REVIEWING
#   ↓
#   APPROVED → EXECUTING ↔ PAUSED ↔ REVISING
#   ↓
#   COMPLETED → ARCHIVED

# Key transitions:
#   exploration → discovery (automatic, after agent explores)
#   planning → reviewing (user chooses to review)
#   reviewing → approved (user approves, contract generated)
#   approved → executing (execution begins)
#   executing ↔ paused (user pause/continue)
#   executing → revising (user revise, re-enter planning)

# ──────────────────────────────────────────────────────────────────────────
# Status Bar Indicators:
# ──────────────────────────────────────────────────────────────────────────

# 🔎 EXPLORATION (exploring project)
# 🔍 DISCOVERY (gathering requirements)
# ❓ CLARIFYING (asking questions)
# 📋 PLANNING (structuring tasks)
# 👀 REVIEWING (review before approval)
# ✓ APPROVED (ready for execution)
# ⚡ EXECUTING (implementation)
# ⏸ PAUSED (execution paused)
# 🎉 COMPLETED (plan execution complete)
# 📦 ARCHIVED (session archived)

# ──────────────────────────────────────────────────────────────────────────
# Pi Extension APIs Used:
# ──────────────────────────────────────────────────────────────────────────

# Session & State:
#   - pi.on("session_start", ...) - Restore plan state
#   - pi.appendEntry() - Persist state
#   - ctx.sessionManager - Access session

# Agent Integration:
#   - pi.on("before_agent_start", ...) - Inject context
#   - pi.on("agent_end", ...) - Track progress
#   - pi.sendMessage() - Inject guidance
#   - pi.sendUserMessage() - Programmatic messages

# Commands & Shortcuts:
#   - pi.registerCommand() - /plan commands
#   - pi.registerShortcut() - Ctrl+Alt+P

# UI:
#   - ctx.ui.notify() - Toast notifications
#   - ctx.ui.setStatus() - Footer indicator
#   - ctx.ui.setWidget() - Sidebar widget
#   - ctx.ui.select() - Menu choices
#   - ctx.ui.confirm() - Yes/no dialogs
#   - ctx.ui.editor() - Text editing

# Filesystem:
#   - fs module - Plan artifact management

# ──────────────────────────────────────────────────────────────────────────
# Usage Flow:
# ──────────────────────────────────────────────────────────────────────────

# 1. /plan
#    → Creates .plan/[session]/[plan]/ directory
#    → State = exploration
#    → Agent receives exploration guidance

# 2. Agent explores project
#    → Writes findings to exploration.md
#    → agent_end event triggers

# 3. Automatic transition to discovery
#    → State = discovery
#    → Agent now informed about project
#    → User describes goals

# 4. Clarification phase
#    → Agent asks contextual questions
#    → User answers
#    → State = clarifying

# 5. Planning phase
#    → Agent structures plan.md
#    → Decomposes tasks
#    → Identifies risks
#    → State = planning

# 6. User triggers review
#    → State = reviewing
#    → Agent reviews for completeness
#    → Artifacts written to disk

# 7. User approves
#    → /plan approve
#    → ExecutionContract generated
#    → contract.md written
#    → State = approved

# 8. Execution begins
#    → State = executing
#    → Agent follows execution contract

# 9. User can pause/continue/revise
#    → /plan pause → PAUSED state
#    → /plan continue → EXECUTING state
#    → /plan revise → PLANNING state

# 10. Completion
#    → State = completed
#    → /plan archive → ARCHIVED state

# ──────────────────────────────────────────────────────────────────────────
# Tool Restrictions:
# ──────────────────────────────────────────────────────────────────────────

# Plan Mode (DISCOVERY/CLARIFYING/PLANNING/REVIEWING):

# ALLOWED:
#   - read          (browse files)
#   - grep          (search code)
#   - search        (full-text search)
#   - analyze       (code analysis)
#   - plan-artifacts (read/write .plan/ files)

# BLOCKED:
#   - write         (create/modify files)
#   - bash          (execute scripts)
#   - git commit    (make commits)
#   - delete        (remove files)

# Enforcement:
#   - Agent checks tools before using
#   - Blocks restricted operations
#   - Explains why tools are restricted
#   - Maintains focus on reasoning

# Execution Mode (after /plan approve):
#   - Execution policy specified in contract
#   - Can be "ask-always", "ask-per-file", or "auto-approved"
#   - Execution agent respects boundaries

# ──────────────────────────────────────────────────────────────────────────
# Plan Artifact Format:
# ──────────────────────────────────────────────────────────────────────────

# plan.md:
#   - Auto-generated from PlanState
#   - Markdown format (human-readable)
#   - Updated before approval
#   - Users can edit between turns
#   - Agent re-reads after user edits

# decisions.md:
#   - Each decision with reasoning
#   - Tradeoffs documented
#   - Alternatives considered
#   - Growing record of architectural choices

# tasks.md:
#   - Hierarchical task list
#   - Progress tracking (completed/total)
#   - Dependencies noted
#   - Subtasks supported
#   - Current task indicator

# contract.md:
#   - Generated at approval
#   - Formal execution handoff
#   - Tool restrictions encoded
#   - Success criteria listed
#   - Constraints enumerated

# exploration.md:
#   - Agent's analysis of project
#   - Used for context in later phases

# ──────────────────────────────────────────────────────────────────────────
# Pause/Continue/Revise Pattern:
# ──────────────────────────────────────────────────────────────────────────

# Pause:
#   - /plan pause
#   - User provides reason
#   - State: executing → paused
#   - Agent stops immediately
#   - Plan artifacts preserved

# Continue:
#   - /plan continue
#   - State: paused → executing
#   - Resumes with original plan
#   - No re-approval needed

# Revise:
#   - /plan revise
#   - State: executing → planning
#   - Re-enter planning mode
#   - Can modify plan/contract
#   - Requires re-approval to continue execution

# ──────────────────────────────────────────────────────────────────────────
# Design Philosophy:
# ──────────────────────────────────────────────────────────────────────────

# This IS:
# ✓ Artifact-first planning system
# ✓ Formal execution contracts
# ✓ Tool-restricted planning mode
# ✓ Persistent decision registry
# ✓ Resumable execution workflow
# ✓ Human-inspectable artifacts
# ✓ Git-friendly documentation
# ✓ Collaborative engineering system

# This is NOT:
# ❌ Approval gate or permission system
# ❌ Autonomous execution engine
# ❌ "Best practices" enforcer
# ❌ Code generation system

# ──────────────────────────────────────────────────────────────────────────
# Testing & Validation:
# ──────────────────────────────────────────────────────────────────────────

# To test in Pi:

# 1. Apply dotfiles:
#    chezmoi apply

# 2. Start Pi:
#    pi

# 3. Try planning:
#    /plan

# 4. Follow workflow (exploration → discovery → planning → approval)

# 5. Check artifacts:
#    cat ~/.plan/[session]/[plan]/plan.md
#    cat ~/.plan/[session]/[plan]/tasks.md
#    cat ~/.plan/[session]/[plan]/decisions.md

# 6. Test pause/continue:
#    /plan pause
#    /plan continue

# 7. Test revise:
#    /plan revise

# ──────────────────────────────────────────────────────────────────────────
# Future Enhancements:
# ──────────────────────────────────────────────────────────────────────────

# Phase 2: Advanced Features
#   - Context compression/summarization
#   - Multi-agent collaboration on plans
#   - Plan queries (/plan query "risks")
#   - Automatic drift detection
#   - Git branch integration
#   - Rollback-to-plan on divergence
#   - Plan merging
#   - Agent memory across projects

# Phase 3: Execution Integration
#   - Execution agents consume contracts
#   - Progress synchronization
#   - Constraint validation during execution
#   - Automatic success criteria checking

# ──────────────────────────────────────────────────────────────────────────
# Key Insight:
# ──────────────────────────────────────────────────────────────────────────

# The shift from "smart conversation" to "engineering system" happens
# the moment plans become:

# • Persistent (saved to disk)
# • Inspectable (human can read)
# • Editable (human can modify)
# • Executable (agent follows them)
# • Versionable (git tracks evolution)

# That's when planning becomes engineering.

echo "✓ Plan Mode Phase 1 Implementation Complete"
echo ""
echo "Features Implemented:"
echo "  ✓ Persistent plan artifacts (.plan/ directory)"
echo "  ✓ Task decomposition with progress tracking"
echo "  ✓ Success criteria management"
echo "  ✓ Tool restriction layer"
echo "  ✓ Execution contract generation"
echo "  ✓ Pause/Continue/Revise workflow"
echo "  ✓ Decision registry with reasoning"
echo "  ✓ Constraint tracking"
echo ""
echo "Files:"
echo "  - index.ts (~900 lines)"
echo "  - README.md (~550 lines)"
echo "  - IMPLEMENTATION.md (this file)"
echo ""
echo "Artifact Location: ~/.plan/"
echo ""
echo "Try it: pi → /plan"
