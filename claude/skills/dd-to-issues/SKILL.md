---
name: dd-to-issues
description: Break a Design-Document (DD) into independently-grabbable Linear issues using tracer-bullet vertical slices. Use when user wants to convert a DD to issues, create implementation tickets, or break down a DD into work items.
---

# DD to Issues

Break a DD into independently-grabbable Linear issues using vertical slices (tracer bullets).

## Process

### 1. Locate the DD

Ask the user for the DD location. A DD is either:

- **A Notion document** — the user provides a Notion URL or page title.
- **A Markdown file** — the user provides a file path.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Extract or draft vertical slices

The DD may already contain vertical slices in a section called **"Elephant carpaccio"**. Check for it first:

- **If the section exists and is filled**: use those slices as the starting point. Verify they comply with the vertical-slice-rules below, and propose adjustments if needed.
- **If the section exists but is empty, or does not exist**: draft the slices yourself following the rules below.

Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

**Coverage check**: verify that the union of all slices covers the entire scope of the DD (all user stories, acceptance criteria, and non-functional requirements). Flag any gaps to the user.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories from the DD this addresses

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?

Iterate until the user approves the breakdown.

### 5. Create the Linear issues

For each approved slice, create a Linear issue. Use the issue body template below.

Create issues in dependency order (blockers first) so you can reference real issue identifiers in the `blockedBy` field. 
Ask the user which team and project to use if not obvious from the DD.

<issue-template>
## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation. Reference specific sections of the parent DD rather than duplicating content.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Implementation hints

A concise description of some of the important implementation details that have been decided in the DD.

## References (optional)

Any links that might be useful to implement this issue or better understand the context.

## Blocked by

- Blocked by <issue-identifier> (if any)

Or "None - can start immediately" if no blockers.

</issue-template>

### 6. Update the DD's Elephant carpaccio section

After all issues are created, add (or fill in) the **Elephant carpaccio** section in the DD with links to the newly created Linear issues.
