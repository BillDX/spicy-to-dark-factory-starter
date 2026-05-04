---
description: Run the controller pipeline on a SPEC: planner → coder + tester in parallel worktrees.
---

Run the controller pipeline on the spec the user names (default: `SPEC.md`).

1. Spawn the `planner` agent — read the spec, produce a numbered implementation plan.
2. After the plan is approved (show it to the user first), spawn the `coder` and `tester` agents in parallel:
   - `coder` implements the plan in its worktree.
   - `tester` writes tests for the new behavior in its worktree.
3. When both finish, show:
   - The diff from the coder
   - The new tests + their pass/fail status
   - Any issues either agent flagged
4. Stop. Do not auto-merge. The user reviews.
