---
name: implement-spec
description: "Implement behaviors from a specification file produced by the local-create-spec skill. Use when the user says 'implement behaviors from ...', 'implement the spec', 'implement spec ...', or wants to implement a .specs/ markdown file containing Given/When/Then behaviors with checkboxes."
---

# Implement Spec

Sequentially implement each unchecked behavior from a spec file using TDD. Mark each behavior as done in the spec file after successful implementation.

## Workflow

### 1. Load and parse the spec file

Read the spec file provided by the user. Extract all behaviors — lines matching `- [ ] **<title>**` followed by a Given/When/Then description. Skip already-checked behaviors (`- [x]`).

### 2. Present the plan

List the unchecked behaviors to the user and ask for confirmation before starting. Example:

```
Found 5 unchecked behaviors in .specs/AMP-3166.md:

1. Create a workflow with a single signer
2. Reject workflow without signers
3. ...

Implement all of them sequentially?
```

### 3. Implement each behavior

For each unchecked behavior, in order:

1. **Announce** which behavior is being implemented (e.g., "Implementing behavior 2/5: Reject workflow without signers")
2. **Launch the software-engineer agent** with a prompt containing:
   - The full behavior (title + Given/When/Then)
   - The spec's Context, Goal, and References sections for background
   - Instruction to follow the red-green-refactor cycle
   - The agent MUST NOT run the full TDD cycle autonomously — it must pause and get user input between phases.
3. **Wait** for the agent to complete
4. **Mark the behavior as done** in the spec file: change `- [ ]` to `- [x]` on the corresponding line
5. **Move to the next behavior**

### 4. Summary

After all behaviors are implemented, report:
- How many behaviors were implemented
- Any that were skipped or already done

## Spec file format reference

Behaviors in the spec file follow this structure:

```markdown
## Behaviors

### <Group name>

- [ ] **<Short behavior title>**
  Given <precondition>, when <action>, then <expected outcome>

- [x] **<Already implemented title>**
  Given <precondition>, when <action>, then <expected outcome>
```

To mark a behavior as done, replace `- [ ]` with `- [x]` on the checkbox line only.
