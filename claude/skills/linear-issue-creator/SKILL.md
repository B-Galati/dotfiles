---
name: linear-issue-creator
description: Create Linear issues using Linear MCP with default team "Expand" and label "V3". Use when creating issues, requesting features, or logging bugs.
---

# Linear Issue Creator

This skill provides practical guidance for creating Linear issues via the Linear MCP with sensible defaults: team "Expand" and label "V3".

## When to Use This Skill

Use this skill when:
- Creating a new Linear issue programmatically
- Logging bugs discovered during development
- Adding feature requests or technical debt
- Creating issues as part of planning or review
- Managing issues as part of your workflow

## Typical Workflow

### 1. Determine Issue Type

Identify what kind of issue you're creating:

- **Bug**: Something is broken, needs reproduction steps
- **Feature**: New capability or enhancement
- **Technical Debt**: Refactoring, cleanup, or architectural work
- **Task**: Work item without specific bug or feature scope

### 2. Gather Information

Collect the essentials:

| Field | Required? | Notes |
|-------|-----------|-------|
| **Title** | ✅ Yes | Clear, action-oriented (max 100 chars) |
| **Description** | ⚠️ Often | More detail for bugs/features, minimal for simple tasks |
| **Priority** | ⚠️ Often | 1=Urgent, 2=High, 3=Medium, 4=Low, 0=None |
| **Estimate** | ❌ Optional | Story points (1,2,3,5,8,13) |
| **Assignee** | ❌ Optional | Specific developer or leave unassigned |

### 3. Create via Linear MCP

Use the Linear MCP to create the issue with:
- Title (required)
- Team: `Expand` (default)
- Labels: `V3` (default)
- Optional fields based on issue type

## Issue Type Examples

### ✅ Bug Report

```
Title: Fix user sign-up form validation error
Description:
The email field validation doesn't reject invalid formats.

Steps to reproduce:
1. Go to /signup
2. Enter "notanemail" in email field
3. Click submit
4. Form submits without validation error

Expected: Form shows validation error
Actual: Form submits with invalid email

Browser: Chrome 120
```

**Metadata:**
- Priority: 2 (High) - Blocks user registration
- Estimate: 3 points
- Assignee: Frontend developer

### ✅ Feature Request

```
Title: Add export-to-PDF functionality
Description:
Users need to export their documents to PDF format for distribution.

Acceptance criteria:
- [ ] Users can click "Export" button on document view
- [ ] PDF includes document content and metadata
- [ ] PDF naming matches document title
- [ ] Works for all document types (forms, templates, etc.)

Technical notes:
- Consider using pdf-utils microservice
- Add new API endpoint: POST /documents/{id}/export
```

**Metadata:**
- Priority: 3 (Medium)
- Estimate: 8 points
- Assignee: Backend engineer

### ✅ Technical Debt

```
Title: Refactor authentication middleware for clarity
Description:
Current auth middleware has grown to 300+ lines and handles multiple concerns.

Improvement areas:
- Separate token validation logic
- Extract permission checking into dedicated function
- Add comprehensive test coverage
- Document authentication flow

Related issues: EXPAND-1234
```

**Metadata:**
- Priority: 4 (Low) - Non-critical
- Estimate: 5 points
- No specific assignee (team picks up)

### ✅ Simple Task

```
Title: Update user documentation for new dashboard
```

**Metadata:**
- Priority: 3 (Medium)
- Estimate: 2 points (minimal work)

## Best Practices

### ✅ DO: Write Clear Titles

```
✅ "Fix login page redirect on mobile devices"
✅ "Add dark mode toggle to user settings"
✅ "Refactor database query performance in reports"

❌ "Fix bug"
❌ "It's broken"
❌ "Do the thing"
```

### ✅ DO: Provide Context in Descriptions

For bugs, include:
- What were you doing?
- What happened?
- What should have happened?

For features, include:
- Why is this needed?
- Acceptance criteria
- Any technical considerations

### ✅ DO: Set Appropriate Priority

- **1 (Urgent)**: Production outage, security issue, blocks release
- **2 (High)**: Significant feature, blocking multiple users
- **3 (Medium)**: Normal feature work, non-critical bugs
- **4 (Low)**: Nice-to-have, technical debt, polish

### ✅ DO: Always Apply Defaults

- **Team**: Always `Expand` (primary dev team)
- **Label**: Always `V3` (version tracking)

### ❌ DON'T: Skip the Title

The title is what appears in lists. Make it searchable and clear:

```
❌ "Issue"
❌ "Can't do X"
❌ "Something with the API"

✅ "Authentication fails for users in EU timezone"
✅ "API rate limiting not returning 429 status"
```

### ❌ DON'T: Over-estimate Story Points

Be realistic. A 21-point task should be broken down:

```
❌ Single 21-point issue for "Build entire dashboard"

✅ Separate issues:
  - Data visualization components (5 points)
  - Dashboard layout (3 points)
  - Performance optimization (5 points)
  - Testing and polish (3 points)
```

### ❌ DON'T: Create Vague Descriptions

```
❌ "Performance is slow"

✅ "Dashboard loads in 5+ seconds with 1000+ items
  - Query takes 3s (add indexing)
  - Component rendering takes 2s (virtualize list)
  - Expected: < 1 second load time"
```

## Common Patterns

### Bug from Code Review

When you find a bug during code review:

1. **Create issue immediately** - Capture it before you forget
2. **Reference the code** - Link to the problematic file/line
3. **Set priority 2+** - Bugs should be visible
4. **Include reproduction steps** - Future developer needs to verify
5. **Don't assign yet** - Let team triage it

**Title pattern:** "Fix [component/feature] [what's broken]"

Example: `Fix signature request state update race condition`

### Feature Discovered During Implementation

When you discover a needed feature while coding:

1. **Create as separate issue** - Don't expand current work scope
2. **Link to parent issue** - Show relationship
3. **Set lower priority** - It's discovered work
4. **Add to backlog** - Plan for later iteration
5. **Move forward** - Focus on current task

**Title pattern:** "[Feature name] for [context]"

Example: `Add bulk export option for signed documents`

### Technical Debt Accumulated

When technical debt accumulates:

1. **Create tracking issue** - Document the problem
2. **Include current impact** - How does it slow us down?
3. **Suggest solution** - What approach would fix it?
4. **Set priority based on impact** - Not urgency
5. **Estimate realistically** - Refactoring takes time

**Title pattern:** "Refactor [what] to improve [aspect]"

Example: `Refactor database queries to use prepared statements`

## Linear MCP Tools

The Linear MCP provides:

- **createIssue()** - Create new issue with all metadata
- **queryTeams()** - Look up team IDs (e.g., "Expand" → team_id)
- **queryLabels()** - Find available labels (verify "V3" exists)
- **queryUsers()** - Find team members for assignment
- **updateIssue()** - Modify existing issue

## Quick Reference Checklist

When creating an issue:

- [ ] **Title**: Clear, specific, searchable (avoid "Fix bug")
- [ ] **Team**: Set to "Expand" (default)
- [ ] **Label**: Add "V3" (default)
- [ ] **Description**: Includes context, reproduction steps, or acceptance criteria
- [ ] **Priority**: Set if known (1-4, 0 for none)
- [ ] **Estimate**: Added if scope is clear (optional)
- [ ] **Assignee**: Set only if you know who should do it (optional)
- [ ] **Due Date**: Added for time-sensitive work (optional)

For bugs specifically:
- [ ] Steps to reproduce included
- [ ] Expected vs. actual behavior stated
- [ ] Environment details if relevant

For features specifically:
- [ ] Acceptance criteria defined
- [ ] Related issues linked
- [ ] Technical approach considered

## Summary

Creating effective Linear issues:

1. **Use the Linear MCP** - Access integrated tools, no external setup
2. **Apply defaults** - Always use "Expand" team and "V3" label
3. **Write clear titles** - Make issues searchable and self-documenting
4. **Include context** - Bugs need reproduction steps, features need acceptance criteria
5. **Set realistic estimates** - Break down large work into smaller issues
6. **Priority matches impact** - Not urgency or current priority
7. **Verify before creating** - Query teams/labels if unsure they exist
