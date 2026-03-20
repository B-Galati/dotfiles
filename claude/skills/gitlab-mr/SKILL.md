---
name: gitlab-mr
description: Create GitLab merge requests with intelligent title and description generation from git commits. Supports stacked MRs by targeting the parent branch (falls back to main). Use when you want to create an MR and need to generate a clear title following git conventions and auto-populate the description from commit messages.
model: haiku
context: fork
---

# GitLab Merge Request

## Context

- Current branch: !`git branch --show-current`
- Parent branches: !`git parents`
- Current glab user: !`glab api user | jq -r .username`

## Configuration

Default values can be customized when invoking the skill. Current defaults:

| Option           | Default                | Description                      |
|------------------|------------------------|----------------------------------|
| `--assignee`     | *(current glab user)*  | GitLab username to assign the MR |
| `--labels`       | *(dynamic, see below)* | Comma-separated labels           |
| `--reviewer`     | `sa_ai_user`           | Reviewer username                |
| `--target`       | *(dynamic, see below)* | Target/base branch               |

### Target Branch

Use the **first parent branch** from the Context section. Fall back to `main` if there are no parents. This enables **stacked merge requests**.

### Labels

The label `ai-generated` is **always** included. Additional labels depend on the current branch name:

| Branch prefix | Labels                         |
|---------------|--------------------------------|
| `back-`       | `ai-generated,Back,guild-back` |
| `expand-`     | `ai-generated,Back,squad-expand` |
| *(other)*     | `ai-generated`                 |

If a review app should be deployed, add the label `"deploy::review-app"`.

## Commit Conventions

Commit messages follow a Conventional Commit-inspired format:

```
<type>[(<Optional branch name>)]: <title>

<Optional body>
```

Types (required):
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

### 1. Get commits for this MR

Get commits between the target branch and HEAD:

```bash
git log TARGET_BRANCH..HEAD --pretty=format:"%s%n%b"
```

### 2. Generate Title and Description

**Title:**
- Single commit: Use the commit subject line directly
- Multiple commits: Primary type prefix + summary (e.g., `feat(expand-100): multiple improvements`)

**Description:**
- Focus on **behavior changes**: what the MR changes from the user's or system's perspective
- Do **not** describe implementation details (class names, method names, internal refactoring)
- Keep it concise and straight to the point
- Single commit: Rewrite the commit body as a behavior-focused summary (do not copy verbatim if it contains implementation details)
- Multiple commits: Bullet-point list summarizing the behavior change of each commit

### 3. Create MR

```bash
glab mr create \
  -a "ASSIGNEE" \
  -l "LABELS" \
  --reviewer "sa_ai_user" \
  --remove-source-branch \
  --push \
  -b "TARGET_BRANCH" \
  -t "TITLE" \
  -d "$(cat <<'EOF'
DESCRIPTION
EOF
)" \
  -y
```

## Requirements

- Git repository with commits ready to merge
- `glab` CLI installed and authenticated
