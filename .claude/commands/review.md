---
description: Review the current branch diff using the code-reviewer agent
---
## Branch Changes
!`git diff --name-only main...HEAD`

## Detailed Diff
!`git diff main...HEAD`

## Review
Adopt the **code-reviewer** agent persona (see `.claude/agents/code-reviewer.md`).
Analyze the above diff using that agent's full expertise and review criteria.

Provide specific, actionable feedback per file with severity: CRITICAL / WARNING / SUGGESTION.
