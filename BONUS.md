# Bonus Patterns

Three more patterns to try once the core exercises feel familiar. Each is a riff on the same primitives — sub-agents, worktrees, tmux teams — but with a different shape.

---

## Bug Tribunal

**Idea:** when a bug is contested, run multiple agents to diagnose it independently, then have a final agent collate and decide.

**Setup:** create three sub-agent definitions — `theorist-a`, `theorist-b`, `theorist-c`. Same tools, same model, **different system prompts** that bias them toward different failure modes:

- `theorist-a` — "the bug is in the data layer"
- `theorist-b` — "the bug is in the request/response cycle"
- `theorist-c` — "the bug is in test setup or fixtures"

**Run:** prompt the parent to spawn all three on the same failing test. Read their three diagnoses. Then prompt a `judge` agent to read all three reports and pick the most likely cause.

**Try it on:** `store.increment_votes` — the deliberate off-by-one in the starter.

**What you learn:** divergent priors produce different findings. The judge isn't perfect, but the spread is informative. Useful when one agent keeps gaslighting itself.

---

## TDD Red/Green Pair

**Idea:** two agents in tmux. One only writes failing tests. The other only makes them pass. They never overlap.

**Setup:**

- `red` agent — system prompt: "You write failing tests for behavior that doesn't yet exist. Never write implementation. Run pytest after each test to confirm it fails."
- `green` agent — system prompt: "You make failing tests pass with minimal implementation. Never modify tests. Run pytest after each change."

**Run:** in tmux, lead pane gives `red` a feature description. `red` writes a failing test, commits, @-mentions `green`. `green` reads the test, writes the smallest implementation that passes, commits, @-mentions `red` for the next test.

**Try it on:** the missing `/leaderboard` endpoint from `SPEC.md`, but feature-by-feature instead of all at once.

**What you learn:** the discipline of small steps becomes mechanical. The pair produces a much cleaner commit history than either agent alone.

---

## Full-Stack Swarm

**Idea:** four agents, four worktrees, one feature. Each agent owns a layer.

**Setup (extend the starter with a tiny frontend):** add a `web/` directory with a single-page HTML app that calls the talkhub API. Then create four agent worktrees:

- `api-coder` — Python, in the FastAPI service
- `web-coder` — HTML/JS, in `web/`
- `tester` — pytest for the API
- `e2e-tester` — Playwright (or just curl in a script) for the integration

**Run:** controller hands the spec to all four. They work in their own worktrees. The controller merges the four branches at the end.

**Try it on:** "Add a 'remove vote' button to the web UI, with the corresponding API endpoint and tests."

**What you learn:** parallelism scales until coordination cost dominates. Past three or four parallel agents, you spend more time merging than building. There's a real ceiling — find yours.

---

## A note on cost

These bonus patterns burn tokens. The Bug Tribunal alone is 3-5x a normal session. Run them once for the experience; default back to the simpler patterns for daily work.
