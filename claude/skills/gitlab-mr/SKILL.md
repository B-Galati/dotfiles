---
name: gitlab-mr
description: Create GitLab merge requests with intelligent title and description generation from git commits. Use when you want to create an MR and need to generate a clear title following git conventions and auto-populate the description from commit messages. Supports single and multiple commits, with configurable assignee, labels, reviewer, and target branch.
model: haiku
context: fork
---

# GitLab Merge Request

## Overview

This skill automates GitLab merge request creation by inspecting git commits on the current branch and generating a clear, conventional title and description. It eliminates manual typing and ensures consistency with your team's conventions.

## How It Works

1. **Inspect commits**: Analyzes all commits on the current branch (compared to target branch)
2. **Generate title**: Creates a clear title following git commit conventions
   - Single commit: Uses the commit subject line
   - Multiple commits: Generates a summary from commit types/subjects
3. **Generate description**: Focuses on **behavior changes**, not implementation details
   - Describe what changed from the user's or system's perspective, not how the code was modified
   - Keep it concise, straight to the point, and easy to understand
   - Avoid mentioning class names, method names, or internal refactoring details
4. **Create MR**: Runs `glab mr create` with generated content and your configuration

## Configuration

Default values can be customized when invoking the skill. Current defaults:

| Option | Default | Description |
|--------|---------|-------------|
| `--assignee` | `bgalati` | GitLab username to assign the MR |
| `--labels` | *(dynamic, see below)* | Comma-separated labels |
| `--reviewer` | `sa_ai_user` | Reviewer username |
| `--target` | `main` | Target/base branch |

### Labels

The label `ai-generated` is **always** included. Additional labels depend on the current branch name:

| Branch prefix | Labels |
|---------------|--------|
| `back-` | `ai-generated,Back,guild-back` |
| `expand-` | `ai-generated,Back,squad-expand` |
| *(other)* | `ai-generated` |

If a review app should be deployed, add the label `"deploy::review-app"`.

Determine the branch name with `git branch --show-current` before building the label list.

### Custom Git Commit Conventions

- Avoid overly verbose descriptions or unnecessary details.
- The commit message should follow the following structure inspired by Conventional Commit format:

```
<type>[(<Optional branch name>)]: <title>

<Optional body>
```

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

Examples:
- fix(back-1023): resolve N+1 query in WorkflowFormSubmissionGenerator
- fix: execute db-migration on live and sandbox
- feat(dx-1593): Add feature flag to use new messager
- chore(dx-1610): Run php using yousign user (2000:2000) in cloud native docker images


## Workflow

### 1. Analyze Commits

Get commits between target branch and current branch:

```bash
git log main..HEAD --pretty=format:"%s%n%b"
```

### 2. Generate Title and Description

**Title:**
- Single commit: Use the commit subject line directly
- Multiple commits: Primary type prefix + "multiple improvements" (e.g., `feat(expand-100): multiple improvements`)

**Description:**
- Focus on **behavior changes**: what the MR changes from the user's or system's perspective
- Do **not** describe implementation details (class names, method names, internal refactoring)
- Keep it concise and straight to the point
- Single commit: Rewrite the commit body as a behavior-focused summary (do not copy verbatim if it contains implementation details)
- Multiple commits: Bullet-point list summarizing the behavior change of each commit

### 3. Create MR

```bash
glab mr create \
  -a "<TODO>" \
  -l "LABELS" \
  --reviewer "sa_ai_user" \
  --remove-source-branch \
  --push \
  -b "main" \
  -t "TITLE" \
  -d "$(cat <<'EOF'
DESCRIPTION
EOF
)" \
  -y
```

Where `LABELS` is resolved from the branch name (see [Labels](#labels)).

## Requirements

- Git repository with commits ready to merge
- `glab` CLI installed and authenticated
