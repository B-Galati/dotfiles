---
name: create-spec
description: 'This skill should be used when the user asks to create a spec, a specification, or to formalize requirements. It accepts any input (Linear issue, free text, file, URL, etc.), explores the codebase to identify impacts and required changes, then collaboratively produces a behavior-driven specification with toggleable behaviors that map directly to automated tests.'
---

# Create Spec

Transform any input — a Linear issue, free-text description, file, or conversation — into a behavior-driven specification by analyzing the codebase and collaborating with the user. The output is a document with context, a goal, and a list of small, toggleable behaviors that each map to an automated test.

## Accepted Inputs

The user can provide the spec source in any form:

- **Linear issue**: an identifier like `AMP-3117` — fetch it via the Linear MCP tool `get_issue`
- **Free text**: the user describes the feature/change directly in chat
- **File**: a path to a document containing requirements
- **URL**: a link to a page with context (fetch via `WebFetch`)
- **Conversation context**: requirements already discussed in the current session

If the input is unclear or missing, ask the user what they want to spec.

## Spec Log

**Throughout the entire workflow, every step, interaction, reflection, decision, and finding MUST be logged to the spec file created in the Configuration step.**

After each step, append a section to the `.specs/<SPEC-ID>.md` file documenting:
- What was done
- What was learned or decided
- Key findings, user answers, or agent outputs
- Timestamps are not required, but step numbers must match the workflow

This file serves as a persistent trace of the spec creation process and can be consulted in future sessions.

## Workflow

### 0. Configuration

Determine a `<SPEC-ID>` for the log file:
- If the input is a Linear issue: use the issue identifier (e.g., `AMP-3166`)
- Otherwise: derive a short kebab-case slug from the topic (e.g., `add-webhook-retry`, `fix-pdf-export`)

Create a spec log file at `.specs/<SPEC-ID>.md`.

Initialize the file with:

```markdown
# Spec Log: <SPEC-ID>

## Step 1: Collect Input
```

All subsequent steps will append their findings and decisions to this file.

### 1. Collect Input

Gather the raw material based on the input type:

- **Linear issue**: fetch via `get_issue`, extract title and description
- **Free text / conversation**: capture the user's description as-is
- **File**: read the file contents
- **URL**: fetch and extract relevant content

This raw input is the draft containing the user's initial intent.

**Log**: Append a summary of the raw input to the spec file.

### 2. Analyse the Draft

Read and understand the input. Identify:

- What feature or area of the codebase is concerned
- What the user wants to achieve
- Any constraints, risks, or open questions mentioned

Summarise your understanding back to the user in a few sentences to confirm alignment before exploring the codebase.

**Log**: Append your analysis summary to the spec file.

### 3. Gather Reference Merge Requests

Ask the user whether they have reference merge requests (branches) that the implementation should follow or be inspired by. Use `AskUserQuestion` with a free-text option so the user can provide branch names.

- If the user provides one or more branch names: launch the `local-mr-diff-summarizer` subagent **in parallel** (one Task per branch) to retrieve and summarize each MR diff. Pass the branch name as the prompt.
- If the user has no references: skip to step 4.

Once all summaries are returned, synthesize the key patterns, conventions, and architectural decisions observed across the reference MRs. Use these insights — combined with the draft from step 2 — to guide a more focused codebase exploration in step 4.

**Log**: Append the branch names provided, each MR summary, and the synthesized insights to the spec file.

### 4. Explore the Codebase

Use the available tools (Glob, Grep, Read, Task with `deep-explore` subagent) to investigate the codebase and identify:

- Which files, classes, and modules are impacted
- Existing patterns and conventions relevant to the change
- Potential side effects or constraints imposed by the current architecture
- Related tests that may need updating
- Any dependencies or cross-cutting concerns

If reference MR summaries were gathered in step 3, use them to focus and refine the exploration — you already know which patterns to look for and which areas of the codebase are likely impacted.

Be thorough but focused — only explore what is relevant to the issue at hand.

**Log**: Append key files discovered, patterns identified, and any architectural constraints to the spec file.

### 5. Clarify with the User

If the codebase exploration reveals ambiguities, trade-offs, or missing information, ask the user targeted questions using `AskUserQuestion`. Common topics:

- Multiple valid approaches — which one to prefer?
- Unclear scope — should X be included or not?
- Edge cases discovered during exploration
- Constraints not mentioned in the draft

Do not proceed to drafting until you have enough information to write all behaviors.

**Log**: Append each question asked and the user's answer to the spec file.

### 6. Draft the Spec

Compose the formalized specification using the template below. The content must be:

- Written in **English**
- Informed by the codebase exploration (reference specific files, classes, or patterns when relevant)
- Clear and human-readable (avoid unnecessary jargon)

**Behavior rules:**
- Each behavior is a small, atomic unit of functionality — one test case
- Use `Given / When / Then` format so each behavior is directly translatable to an automated test
- **Behaviors describe what the user sees, not how it's built.** Never mention implementation details (classes, files, database columns, internal services, etc.) in behaviors. Focus on observable outcomes: API responses, UI changes, error messages, side effects visible to the user. Implementation details belong in the Context or References sections.
- Each behavior has a checkbox (`- [ ]`) so it can be toggled on/off during implementation (e.g., to defer or descope a behavior)
- Group behaviors logically (e.g., by sub-feature, by actor, by happy path vs error cases)
- Order behaviors from most essential to least essential within each group

**Spec template:**

```markdown
## Context

<What area/feature is concerned, background information, relevant existing code/patterns>

## Goal

<The objective of this spec — what should be true when this is done>

## Behaviors

### <Group name>

- [ ] **<Short behavior title>**
  Given <precondition>, when <action>, then <expected outcome>

- [ ] **<Short behavior title>**
  Given <precondition>, when <action>, then <expected outcome>

### <Group name>

- [ ] ...

## References

- <URL, link to codebase example, documentation, or related MR>
- <e.g., `src/Domain/Workflow/Handler/CreateWorkflowHandler.php` — existing pattern to follow>
- <e.g., https://docs.example.com/api/webhooks — external documentation>
- ...
```

Also propose a title. Title rules:
- Keep it simple and short
- Describe the intention clearly
- Do not prefix with type indicators like `[feat]`, `[fix]`, etc.

**Log**: Append the full draft (title + description) to the spec file.

### 7. Confirm and Deliver

Present the full draft (title + description) to the user for review.

- If the user **requests changes**: iterate on the draft and present again until satisfied.
- If the user **accepts**:
  - If the input was a **Linear issue**: update it using `save_issue` with the new title and description. Preserve all other existing fields (team, project, priority, assignee, labels, state). Display the issue identifier and confirm the update.
  - Otherwise: the spec is finalized in the spec log file. Inform the user where to find it (`.specs/<SPEC-ID>.md`).

**Log**: Append the final outcome (accepted/iterated) and delivery confirmation to the spec file.
