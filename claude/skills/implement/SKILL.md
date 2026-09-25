---
name: implement
description: "Implement a spec, design doc or Linear ticket(s) test-first, stopping to align with the user on every design decision. Use when the user says 'implement X', 'implémente BACK-123', 'go on this ticket', or points to a spec/DD to build — prefer this over /tdd alone when the input is a ticket or spec."
---

Implement the work described in the spec or tickets.

## Before coding
- Fetch the spec (Linear `get_issue`, DD link, file). Check out the branch per CLAUDE.md.
- Build a shared view of what the system should do, seen from outside as a black box:
  entry points (API, CLI, events, UI), inputs, outputs, side effects, error cases, and
  the key scenarios with their expected results. No internals. Present it short and
  wait for my agreement. These scenarios become the first outside-in tests.
- List ambiguities and unresolved design choices. Ask them now, not mid-cycle.
- Several tickets: do them one at a time, and wait for GO between each.

## Build
Use /tdd at the seams agreed in the spec or with me.

We build iteratively so the design emerges from the tests (Kent Beck style) and we both
understand it, technically and functionally. So when a cycle needs a design decision
that wasn't agreed — a new public interface, abstraction, data model change, dependency,
or a change to existing behaviour — stop. Give 2–3 options with your recommendation,
and wait for my choice. Local naming and internal refactors don't need this.

Find the typecheck and test commands in AGENTS.md / Makefile / composer.json / package.json.
Run typecheck and the touched test file often. Run the full suite once at the end.

## Finish
- Run /code-review-mp against the merge-base with the target branch.
- Show me the findings. Don't fix them without asking.
- Wait for my GO before committing anything.
