---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: Create a git commit
model: haiku
context: fork
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single git commit.

## Commit Format

- Avoid overly verbose descriptions or unnecessary details.

- The commit message should follow the following structure inspired by Conventional Commit format:

```
<type>[(<Optional branch name>)]: <title>

<Optional body>
```

- Only include the branch name in the commit type if it contains a number (e.g., a ticket/issue number like `back-1023`, `dx-1593`). If the branch name has no number, omit it.

- Types (required):
  - `build`: "🏗️ Builds"
  - `chore`: "🛠️ Chores"
  - `ci`: "👷 CI"
  - `docs`: "📚 Documentations"
  - `feat`: "✨ Features"
  - `fix`: "🐛 Fixes"
  - `other`: "❓ Others"
  - `perf`: "🚀 Performance Improvements"
  - `refactor`: "📦 Code Refactoring"
  - `revert`: "🗑️ Reverts"
  - `style`: "💄 UI"
    - `test`: "🧪 Tests"

## Examples

- fix(back-1023): resolve N+1 query in WorkflowFormSubmissionGenerator
- fix: execute db-migration on live and sandbox
- feat(dx-1593): Add feature flag to use new messager
- chore(dx-1610): Run php using yousign user (2000:2000) in cloud native docker images
