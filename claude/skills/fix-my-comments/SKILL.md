---
name: 'fix-my-comments'
description: 'This skill should be used when the user asks to handle inline instructions they left in the code as `@claude` comments. Scans the git diff for `@claude` markers, carries out each instruction, removes the marker, and verifies. Trigger examples: "fix the comment I have added with // @claude", "handle the @claude comments", "apply my inline comments", "traite mes commentaires @claude".'
---

# Fix My Comments

The user reviews code and leaves instructions for Claude as comments prefixed with `@claude`, placed directly above or inside the code they concern. Each marker is an instruction addressed to you — never documentation.

## 1. Scan the diff

Markers only live in work in progress, so scan the changed files (staged + unstaged):

```bash
git diff HEAD --name-only --diff-filter=ACMR | xargs -r rg -n '@claude'
```

Matches every comment syntax: `// @claude`, `# @claude`, `<!-- @claude -->`, `/* @claude */`.

If nothing is found, say so and stop — do not widen the search to the whole tree unless the user asks.

## 2. Track progress

Create one task per marker with `TaskCreate` (label it `file:line — <instruction gist>`). Set it `in_progress` when you start it and `completed` once handled, so the user can follow a long round.

## 3. Handle each marker

1. Read the enclosing method or class, not just the flagged line — the instruction is relative to that code.
2. Carry it out. Instructions are terse and vary in kind.
3. Delete the `@claude` line once handled. Keep any adjacent comment the user wrote alongside it — that one is real documentation.
4. If the instruction is genuinely ambiguous, or carrying it out would break behaviour, ask instead of guessing. Never leave a marker silently unhandled.

## 4. Verify

Run only what the changes affect: the specific tests touched, plus the repo's fast lint/static-analysis command. Follow the repo's own `CLAUDE.md` for the exact commands. Never run the full test suite.

## 5. Re-scan and report

Re-run the scan from step 1 — the user often adds markers while you work. Handle anything new before reporting.

Then report one line per marker:

```
<file>:<line> — <instruction> → <what was done>
```

Flag any behavioural trade-off an instruction introduces (lost test coverage, weaker error reporting, changed transaction semantics) rather than silently accepting it.
