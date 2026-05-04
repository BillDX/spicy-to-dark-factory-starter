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

## Exercise 3 — The Architecture Debate (agent teams in tmux)

**Goal:** experience what makes agent teams *different* from sub-agents — agents with sharp, opposing roles who push back on each other and have to converge.

This one is **experimental**. It can break. That's the point.

The exercise: three agents with different architectural priors debate a tiny design problem and have to produce a single recommendation.

Steps:

1. From a fresh terminal:

   ```bash
   tmux new -s debate
   ```

2. Split into three panes (`Ctrl-b %` then `Ctrl-b "`).
3. In each pane, create a worktree and start Claude there:

   ```bash
   # pane 1 — minimalist
   git worktree add ../talkhub-min minimalist && cd ../talkhub-min && claude

   # pane 2 — defensive coder
   git worktree add ../talkhub-def defensive && cd ../talkhub-def && claude

   # pane 3 — performance hawk
   git worktree add ../talkhub-perf perf && cd ../talkhub-perf && claude
   ```

4. In each pane, set the persona before starting the debate:

   - Pane 1 (minimalist): *"You are a minimalist coder. You believe the simplest correct implementation always wins. Lines of code are a cost. You will defend simplicity even under pushback."*
   - Pane 2 (defensive): *"You are a defensive coder. You believe handling every edge case up front is always right. Silent bugs are the worst bugs. You will defend thoroughness even under pushback."*
   - Pane 3 (perf hawk): *"You are a performance hawk. You believe runtime and memory matter most. You don't ship anything you haven't reasoned about. You will defend efficiency even under pushback."*

5. From any one pane (say pane 1), kick off the debate:

   > Team: we're designing a function that deduplicates a list of strings, case-insensitive, preserving first-seen order.
   >
   > Each of you, propose your version in your worktree. Read the others' proposals. Argue. You may write a counter-version in your own worktree if it makes the point.
   >
   > Converge on PROPOSAL.md: the version you all signed off on (or noted disagreement on), with a one-paragraph rationale and the tradeoffs you weighed.

6. Watch the panes. The minimalist will push for a 3-line list comprehension. The defensive coder will worry about Unicode, None values, empty inputs. The perf hawk will benchmark.

**Cleanup:**

```bash
git worktree remove ../talkhub-min
git worktree remove ../talkhub-def
git worktree remove ../talkhub-perf
tmux kill-session -t debate
```

**What to notice:** the disagreement *is* the value. A solo agent would pick one of the three approaches and not surface the tradeoffs. The team is forced to make the tradeoffs explicit — that's the artifact. The PROPOSAL.md is more honest than what any one of them would have written alone.

**If they spin:** they will sometimes get stuck in a politeness loop ("good point, you're right"). If that happens, prompt one of them: *"Be specific about your strongest objection. Don't capitulate yet."*

---

## When you're done

Try the bonus patterns in `BONUS.md`. Or paste the spec from `GASTOWN-DEMO.md` into kilo.ai/Gastown and watch L5 build the bingo game from the workshop slides.
