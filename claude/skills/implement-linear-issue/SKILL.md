---
name: implement-linear-issue
description: "Implement a Linear issue by breaking its acceptance criteria into tasks, implementing each with TDD, and updating the Linear issue status when done. Use when the user says 'implement issue ...', 'implement TEAM-123', or wants to implement a Linear issue."
---

# Implement Linear Issue

Implement a Linear issue by breaking its acceptance criteria into internal tasks, implementing each sequentially using TDD, and updating the Linear issue only after all tasks are complete.

## Workflow

### 1. Load the Linear issue

Ask the user for the Linear issue identifier (e.g., TEAM-123). Fetch the issue and extract:

- **Title and description** (the "What to build" section)
- **Acceptance criteria** (the checklist items)
- **Implementation hints** (if present)
- **References** (if present)
- **Blocked by** (if present — verify blockers are resolved before proceeding)

### 2. Create an internal task list

Break the acceptance criteria into an ordered list of implementation tasks. Use `TaskCreate` to track each one internally. Do NOT update the Linear issue yet.

Present the task list to the user and ask for confirmation before starting. Example:

```
Implementing TEAM-456: Add email validation to signer creation

Tasks:
1. Validate email format on signer creation
2. Return 422 with error details for invalid email
3. Reject duplicate emails within the same workflow

Implement all sequentially?
```

### 3. Implement each task

For each task, in order:

1. **Mark the task as in_progress** via `TaskUpdate`
2. **Announce** which task is being implemented (e.g., "Implementing task 2/3: Return 422 with error details for invalid email")
3. **Launch the software-engineer agent** with a prompt containing:
   - The full task description
   - The issue's description, implementation hints, and references for background
   - Instruction to follow the red-green-refactor cycle
   - The agent MUST NOT run the full TDD cycle autonomously — it must pause and get user input between phases.
4. **Mark the task as completed** via `TaskUpdate`
5. **Move to the next task**

### 4. Update the Linear issue

Only after ALL tasks are successfully implemented:

1. **Check off the acceptance criteria** in the Linear issue
2. **Report** to the user:
   - How many tasks were implemented
   - Any that were skipped or already done
