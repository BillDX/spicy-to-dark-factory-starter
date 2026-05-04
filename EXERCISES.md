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

## Exercise 3 — The Architecture Debate (a team-shaped exercise)

**Goal:** experience what makes agent teams *different* from sub-agents — agents with sharp, opposing roles who push back on each other and have to converge.

The exercise: three agents with different architectural priors debate a tiny design problem and have to produce a single recommendation.

> **Honest disclosure.** This is a *team-shaped exercise*, not a true Claude Code agent team. What you'll see is three independent `claude` sessions coordinating through the **filesystem** — each writes to its own worktree and reads the others'. Real Claude Code agent teams (the experimental feature) add native peer messaging on top: an agent can `@-mention` a teammate, who receives the message in their conversation rather than as a file. Same pattern (sharp roles + structured disagreement + converged artifact); different plumbing. We chose filesystem coordination here because it's deterministic, version-stable, and produces visible artifacts you can `cat` mid-debate — which matters more for a workshop than purity does.

### The fast path (one command)

```bash
./scripts/demo3-debate.sh
```

Creates three worktrees on dedicated branches, opens a tmux session named `debate` with three panes, launches Claude in each pane with its persona as the initial message, waits for the personas to acknowledge their roles (~20 seconds), and then **auto-fires the kickoff prompt to all three panes** to start the debate. tmux mouse mode is on, so you can click between panes.

Each Claude session is launched with `--dangerously-skip-permissions` because the agents need to read sibling worktrees (outside their own root), which would otherwise prompt every single time and kill the demo flow. This is the textbook "OK to use" case from the workshop slides: throwaway `debate-*` branches, deny rules in `.claude/settings.json` for the destructive operations, and you watching live.

The kickoff prompt has each agent:

1. Write `IMPL.py` in their worktree (their proposed implementation, with comments).
2. Read the others' `IMPL.py` files.
3. Write `CRITIQUE.md` with their sharpest objections.
4. The Minimalist writes `PROPOSAL.md` synthesizing the team's recommendation; the others append agreement or dissent.

You attach automatically once the kickoff fires. Watch the agents work in their respective worktrees.

Override the wait time if your machine is slower:

```bash
DEMO3_PERSONA_WAIT=30 ./scripts/demo3-debate.sh
```

When you're done:

```bash
./scripts/demo3-debate.sh --cleanup
```

Kills the tmux session, removes the worktrees, deletes the branches.

### The manual path (if you want to see every step)

1. From a fresh terminal:

   ```bash
   tmux new -s debate
   ```

2. Split into three panes (`Ctrl-b %` then `Ctrl-b "`).
3. In each pane, create a worktree and start Claude there:

   ```bash
   # pane 1 — minimalist
   git worktree add ../talkhub-minimalist debate-minimalist && cd ../talkhub-minimalist && claude

   # pane 2 — defensive coder
   git worktree add ../talkhub-defensive debate-defensive && cd ../talkhub-defensive && claude

   # pane 3 — performance hawk
   git worktree add ../talkhub-perf debate-perf && cd ../talkhub-perf && claude
   ```

4. In each pane, set the persona before starting the debate:

   - Pane 1 (minimalist): *"You are a minimalist coder. You believe the simplest correct implementation always wins. Lines of code are a cost. You will defend simplicity even under pushback."*
   - Pane 2 (defensive): *"You are a defensive coder. You believe handling every edge case up front is always right. Silent bugs are the worst bugs. You will defend thoroughness even under pushback."*
   - Pane 3 (perf hawk): *"You are a performance hawk. You believe runtime and memory matter most. You don't ship anything you haven't reasoned about. You will defend efficiency even under pushback."*

5. From any one pane, kick off the debate:

   > Team: we're designing a function that deduplicates a list of strings, case-insensitive, preserving first-seen order.
   >
   > Each of you, propose your version in your worktree. Read the others' proposals. Argue. You may write a counter-version in your own worktree if it makes the point.
   >
   > Converge on PROPOSAL.md: the version you all signed off on (or noted disagreement on), with a one-paragraph rationale and the tradeoffs you weighed.

6. Watch the panes. The minimalist will push for a 3-line list comprehension. The defensive coder will worry about Unicode, None values, empty inputs. The perf hawk will benchmark.

**Cleanup (manual path):**

```bash
git worktree remove ../talkhub-minimalist
git worktree remove ../talkhub-defensive
git worktree remove ../talkhub-perf
tmux kill-session -t debate
```

### What to notice

The disagreement *is* the value. A solo agent would pick one of the three approaches and not surface the tradeoffs. The team is forced to make the tradeoffs explicit — that's the artifact. The PROPOSAL.md is more honest than what any one of them would have written alone.

**If they spin:** they will sometimes get stuck in a politeness loop ("good point, you're right"). If that happens, prompt one of them: *"Be specific about your strongest objection. Don't capitulate yet."*

---

## When you're done

Try the bonus patterns in `BONUS.md`. Or paste the spec from `GASTOWN-DEMO.md` into kilo.ai/Gastown and watch L5 build the bingo game from the workshop slides.
