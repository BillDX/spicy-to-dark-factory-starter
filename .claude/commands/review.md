---
description: Run the reviewer and security-reviewer agents on the current branch's diff vs main, in parallel.
---

Run two agents in parallel against the changes on this branch:

1. The `reviewer` agent — find correctness, style, and maintainability issues in the changed files.
2. The `security-reviewer` agent — find security issues (injection, untrusted input, info disclosure).

Use `git diff main...HEAD --name-only` to find changed files and pass them to both agents.

When both agents return, combine their findings into a single report grouped by file. Critical findings first.
