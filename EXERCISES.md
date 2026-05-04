# Exercises

Three self-paced exercises that mirror the workshop demos. Run them in order — each builds on the harness the prior one set up.

Setup (once):

```bash
uv sync
uv run pytest    # should be green
uv run uvicorn talkhub.main:app --reload   # in another terminal, smoke-check the API
```

---

## Exercise 1 — Sub-agents in parallel

**Goal:** prove to yourself that two sub-agents can run in parallel, with isolated context, against the same file.

The agents you need are already in `.claude/agents/`:
- `reviewer` — read-only critique
- `documenter` — adds docstrings

Steps:

1. Open Claude Code in this repo: `claude`
2. Prompt:

   > Use two sub-agents on `src/talkhub/routes/talks.py`:
   > 1. The reviewer agent — find any issues
   > 2. The documenter agent — add Google-style docstrings to every public route handler
   >
   > Run them in parallel.

3. Watch for two agent boxes spinning at once.
4. Read the reviewer's findings. Read the diff the documenter produced.
5. Run `uv run pytest` — the documenter shouldn't have broken anything.

**What to notice:** the reviewer cannot write files (its `tools:` field forbids it). The documenter ran on `haiku` — cheaper, fine for this job. Both finished before either could finish alone.

---

## Exercise 2 — The controller pipeline

**Goal:** ship a feature from a spec, with a planner, coder, and tester running in worktrees.

The spec is `SPEC.md` — adding a `/leaderboard` endpoint.
The agents you need are already in `.claude/agents/`:
- `planner` (opus, read-only)
- `coder` (sonnet, isolation: worktree)
- `tester` (sonnet, isolation: worktree)

Steps:

1. Open Claude Code: `claude`
2. Prompt:

   > Run the controller pipeline on SPEC.md:
   >
   > 1. Use the planner agent to read SPEC.md and produce a step-by-step plan.
   > 2. Show me the plan and stop. I'll approve it.

3. After approving the plan:

   > Now spawn the coder and tester agents in parallel.
   > The coder implements the plan in its worktree.
   > The tester writes tests for the new endpoint in its worktree.
   > When both finish, show me the diffs and the test results.

4. While they run, peek at `git worktree list` in another terminal — you should see three worktrees.
5. Review the coder's diff. Review the tester's tests. Merge if both look good.

**What to notice:** the planner used opus, the workers used sonnet. Worktrees mean you could keep running other commands in your main checkout. The pipeline produced a structured artifact (the plan) before any code was written.

**Shortcut:** `/ship SPEC.md` runs the same pipeline as a single slash command.

---

## Exercise 3 — Agent teams in tmux

**Goal:** see peer-to-peer agent coordination — agents messaging each other directly, not just back through a parent.

This one is **experimental**. It can break. That's the point.

Steps:

1. From a fresh terminal:

   ```bash
   tmux new -s team
   ```

2. Split into three panes (`Ctrl-b %` then `Ctrl-b "`).
3. In each pane, create a worktree and start Claude there:

   ```bash
   # pane 1 — lead
   git worktree add ../talkhub-lead lead && cd ../talkhub-lead && claude

   # pane 2 — coder
   git worktree add ../talkhub-coder coder && cd ../talkhub-coder && claude

   # pane 3 — tester
   git worktree add ../talkhub-tester tester && cd ../talkhub-tester && claude
   ```

4. In the lead pane, give a task that requires negotiation, e.g.:

   > Coordinate with the coder and tester teammates to add a `DELETE /talks/{id}` endpoint.
   > The tester should write the tests first; the coder implements to satisfy them.
   > You decide the API shape.

5. Watch the panes. Agents should @-mention each other and respond directly.

**Cleanup:**

```bash
git worktree remove ../talkhub-lead
git worktree remove ../talkhub-coder
git worktree remove ../talkhub-tester
tmux kill-session -t team
```

**What to notice:** the conversation is the artifact. There's no controller telling them what to do — they negotiate. This is also where it's easy to get stuck in a loop. If they spin, kill the session and start over with a tighter prompt.

---

## When you're done

Try the bonus patterns in `BONUS.md`. Or paste the spec from `GASTOWN-DEMO.md` into kilo.ai/Gastown and watch L5 build the bingo game from the workshop slides.
