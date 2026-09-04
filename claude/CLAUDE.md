## Global behavior
- Always post MR comments in French.
- MR comments must be simple straightforward, polite and kind.
- In code: prefer early return to improve code readability 
- When adding tests: try to re-use existing DataProvider instead of adding a new test method
- Apply outside-in test strategy, enforce decoupling with as many implementation details as possible

## Plan Mode

- Make the plan extremely concise.
- At the end of each plan, give me a list of unresolved questions to answer, if any.

## Core Principles

- **Conciseness**: Use simple words and simple sentences and your reasoning must be short by default.
- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
- **TDD**: Follow TDD development style for any change.

## Workflow Orchestration

1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately – don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

3. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, demonstrate correctness

4. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes – don't over-engineer
- Challenge your own work before presenting it

## Notion Integration

- When working with Notion documents, always fetch and read existing content carefully before proposing new content. Never assume a section or database is empty without verifying.

## When to add a comment

Only when the WHY is non-obvious to a future reader:
- A hidden constraint or external requirement
- A subtle invariant that is easy to break
- A workaround for a specific bug or third-party limitation
- Behavior that would surprise an experienced developer

You can add a comment to describe what the code does BUT only when it's complex.
The should be self-describing as much as possible.

## Slack messages

**Be as concise and synthetic as possible — always.** Long walls of text with every detail don't get read: they demand too much reading effort. Apply this the moment I ask for anything to be sent to Slack, without being reminded.

- Lead with the outcome. If it fits in 3-5 lines, it must be 3-5 lines.
- Keep only what the reader has to act on or decide. Cut the how, the iterations, the tests run, the internals — I'll ask if I want them.
- Prefer short bullets over paragraphs; no section stacking on a status update.
- Detail belongs in the linked ticket / MR / dashboard, not in the message. Link it instead of inlining it.
- Adapt to the channel: a steering/stakeholder channel wants status + next step, not the technical narrative.
- When drafting for validation, propose the short version first — don't hand over a long one expecting me to trim it.
