# Plan Mode Extension - Persistent Artifacts & Execution System

A collaborative planning system that generates persistent plan artifacts, enforces tool restrictions, defines execution contracts, and enables resumable execution.

## Philosophy

Plan Mode is not just a prompt convention—it's an **execution-oriented engineering system** that:

- **Externalizes reasoning** into persistent artifacts (plan.md, tasks.md, decisions.md)
- **Enforces boundaries** through tool restrictions in planning mode
- **Formalizes handoff** via explicit execution contracts
- **Enables resumability** through pausing, pausing, and revising workflows
- **Creates accountability** by making decisions inspectable and editable

The plan becomes the **source of truth**, not chat history.

## Key Features

### Core Artifacts

All plans live in persistent files under `.plan/`:

```
~/.plan/
├── [session-id]/
│   └── [plan-id]/
│       ├── plan.md              # Main plan document
│       ├── decisions.md         # Technical decisions
│       ├── tasks.md             # Granular task list
│       ├── contract.md          # Execution contract (after approval)
│       ├── exploration.md       # Project analysis findings
│       └── archive/
```

### Plan.md (Main Document)

```markdown
# Plan: Feature Name

## Status
- State: [planning/approved/executing]
- Progress: X/Y tasks
- Last Updated: ISO timestamp

## Goal
[1-2 sentences of what we're building]

## Constraints
- [MUST] Speed to market
- [SHOULD] Maintainability
- [NICE-TO-HAVE] Performance

## Open Questions
- [ ] Question 1
- [ ] Question 2

## Success Criteria
- [ ] Works offline
- [ ] Startup under 100ms
- [ ] Backward compatible

## Identified Risks
- Performance regression
- User confusion with new UI
```

### Task Decomposition

Tasks are granular and ordered:

```markdown
# Tasks

Progress: 3/7 complete

- [✓] Create extension manifest
  - Add workflow state machine
  - Add persistence layer
- [○] Wire up to Pi API
  - Depends on: Create extension manifest
- [○] Add review phase UI
```

### Decisions Registry

Every meaningful decision is recorded with reasoning and tradeoffs:

```markdown
# Decisions

## Use session persistence over filesystem

**Decision:** Store plan state in Pi session, not filesystem

**Reasoning:**
- Simpler initially
- Avoids sync issues
- Fits Pi session architecture

**Tradeoffs:**
- Benefit: Simpler implementation
- Cost: Less portability
```

### Execution Contract

After approval, the system generates a formal execution contract:

```markdown
# Execution Contract

## Approved Plan
Goal: Add collaborative planning extension

## Must Follow Constraints
- [MUST] Human-driven (never autonomous)
- [MUST] Preserve existing APIs
- [SHOULD] Session persistence

## Do Not Do
- Introduce dependencies
- Refactor unrelated code
- Change persistence format

## Success Criteria
- [ ] /plan command works
- [ ] State persists across reloads
- [ ] Plans survive /reload

## Execution Permissions
- Mode: ask-always
- Allowed Tools: read, grep, search, plan-artifacts
- Blocked Tools: write, bash, git commit, delete
```

## Workflow States

```
IDLE
  ↓ (/plan)
EXPLORATION
  ↓ (agent analyzes project)
DISCOVERY
  ↓ (you describe goals)
CLARIFYING
  ↓ (agent asks questions)
PLANNING
  ↓ (agent builds architecture)
REVIEWING
  ↓ (review before committing)
APPROVED
  ↓ (/plan approve)
EXECUTING
  ↓ (implementation in progress)
PAUSED ←→ REVISING
  ↓ (/plan continue)
COMPLETED
  ↓
ARCHIVED
```

## Commands

### Planning Commands

```bash
/plan                    # Start new planning session
/plan status             # Show current state and progress
/plan show              # Display plan.md
/plan tasks             # Show task decomposition
/plan decisions         # Show all decisions
/plan questions         # Show open/resolved questions
/plan contract          # Show execution contract
```

### Execution Commands

```bash
/plan pause             # Pause execution, return to planning
/plan continue          # Resume from paused state
/plan revise            # Re-enter planning during execution
/plan approve           # Approve plan for execution
```

### Lifecycle Commands

```bash
/plan archive           # Archive session and reset
Ctrl+Alt+P             # Toggle plan mode (quick menu)
```

### Alias

```bash
/todos                  # Show tasks (alias for /plan tasks)
```

## Tool Restriction Layer

**Plan Mode = Read-Only Reasoning**

Allowed tools:
- `read` - Browse files
- `grep` - Search code
- `search` - Full-text search
- `analyze` - Code analysis
- `plan-artifacts` - Edit plan files

Blocked tools:
- `write` - Create/modify application files
- `bash` - Execute scripts
- `git commit` - Make commits
- `delete` - Remove files

This keeps planning focused on decision-making, not implementation.

### Execution Mode

After approval, execution agents receive the contract with specific permissions:

```typescript
ExecutionPolicy {
  mode: "ask-always" | "ask-per-file" | "auto-approved";
  allowedTools: [...];
  blockedTools: [...];
  requireApprovalFor: [...];
  autoApprovedFor: [...];
}
```

## Execution Contracts

Formal handoff from planning to execution:

```bash
/plan contract
```

Shows:

- **Approved goal** - Exact plan being executed
- **Must-follow constraints** - Non-negotiable rules
- **Success criteria** - Definition of done
- **Banned changes** - What NOT to do
- **Execution permissions** - What tools are available
- **Approval timestamp** - When this was approved

Execution agents read this contract before starting.

## Pausability & Resumability

### Pause During Execution

```bash
/plan pause
# Why pause? → User provides reason
# State: EXECUTING → PAUSED
```

Execution agent stops. User can:
- Review progress
- Edit the plan
- Decide to continue or revise

### Continue

```bash
/plan continue
# State: PAUSED → EXECUTING
```

Execution resumes with original plan.

### Revise

```bash
/plan revise
# State: EXECUTING → PLANNING
```

Return to planning mode while keeping execution history. Make architectural changes if needed.

## Plan Artifacts in Git

Plans are naturally git-friendly:

```bash
git diff .plan/
```

Shows:
- Changed constraints
- New risks identified
- Revised success criteria
- Scope expansion
- Decision evolution

Encourages version control of architecture decisions.

## Example Session

### Starting Plan

```bash
User: /plan

🔎 EXPLORATION
Agent explores project structure...
→ Writes to exploration.md

🔍 DISCOVERY
User: I want to add dark mode support
Agent: Questions about constraints, scope, etc.

📋 PLANNING
Agent structures plan.md with:
- Goal
- Constraints
- Tasks
- Success criteria

👀 REVIEWING
Agent reviews for completeness
→ Writes decisions.md, tasks.md

User: /plan approve
✓ Execution contract generated
```

### During Execution

```bash
Agent: Starting implementation...
[TASK 1] Create UI component
  ✓ Complete

[TASK 2] Add theme switching
  ⚠ Performance issue detected

User: /plan pause
# Pause reason: Need to reconsider theme approach

User: /plan revise
# Return to planning mode
Agent: What approach would you prefer?
# User makes decision
# Plan updated

User: /plan continue
Agent: Resuming implementation...
```

## File Locations

Plans are stored in user home directory:

```
~/.plan/
├── sessions.yaml              # Session index
└── [session-id]/
    ├── [plan-id]/
    │   ├── plan.md           # Current plan
    │   ├── decisions.md      # Decision registry
    │   ├── tasks.md          # Task list
    │   ├── exploration.md    # Project analysis
    │   ├── contract.md       # Execution contract (after approval)
    │   └── archive/
    └── [archived plans...]
```

## Why Persistent Artifacts Matter

### Without Artifacts
- Plans disappear into context windows
- Decisions become fuzzy
- Reasoning gets lost
- Execution drifts
- Hard to resume

### With Artifacts
- Plans are the source of truth
- Decisions are traceable
- Reasoning is explicit
- Execution stays bounded
- Easy to pause/resume/revise
- Human can inspect and edit
- Git tracks evolution
- Other tools can consume

The artifact transforms planning from "smart conversation" to "engineering workflow."

## Integration with Execution Agents

After approval, the execution contract becomes the execution agent's context:

```typescript
executeAgainstPlan({
  plan: approvedPlan,
  contract: executionContract,
  onTaskChange: (task) => updateUI(),
  onConstraintViolation: (violation) => askApproval(),
  onUnexpectedChange: (change) => flagDrift(),
})
```

Execution stays bounded and intentional.

## Best Practices

1. **Plan Early** - Start with `/plan` before implementing
2. **Keep Tasks Granular** - Break into concrete steps
3. **Define Success Clearly** - Success criteria are mandatory
4. **Document Constraints** - Constraints guide decisions
5. **Explain Tradeoffs** - Every decision has costs
6. **Inspect Artifacts** - Read plan.md, decisions.md, contract.md
7. **Use Pause/Revise** - Don't hesitate to adjust mid-execution
8. **Git Track Plans** - Commit .plan/ directory

## Key Design Principles

- **Artifact-First** - Plans exist in files, not just chat
- **Human-Editable** - Users can edit plans directly
- **Resumable** - Pause, revise, continue at any time
- **Bounded Execution** - Explicit contracts prevent drift
- **Tool Restricted** - Planning mode blocks premature implementation
- **Transparent Decisions** - All choices are recorded with reasoning
- **Collaborative** - Agent and human both contribute

## Related Commands

```bash
/todos              # Show tasks (short form)
Ctrl+Alt+P         # Quick toggle (shows menu)
```

## Notes

- Plan artifacts persist across sessions
- State survives `/reload`
- All decisions are permanent (for architectural memory)
- Tasks track progress automatically
- Execution contracts formalize handoff
- Pausing is always available during execution

## See Also

- Plan Mode source: `index.ts`
- Implementation details: `IMPLEMENTATION.md`
- CHECKLIST: `CHECKLIST.md`
