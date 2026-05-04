# Bonus Patterns

Three more patterns to try once the core exercises feel familiar. Each one extends a pattern from the workshop:

- **Bug Tribunal** — agent team variant (disagreement → consensus)
- **Red/Green Pair** — agent team variant (sharp opposing roles)
- **Full-Stack Pipeline** — controller pattern variant (Plan → Execute → Review at scale)

---

## Bug Tribunal *(team)*

**Idea:** when a bug is contested, run multiple agents who *start from different assumptions* about where the bug is. They argue. A judge picks.

This is the same DNA as Exercise 3's Architecture Debate — different priors, forced disagreement — applied to debugging.

**Setup:** create three sub-agent definitions or tmux personas, each biased toward a different failure mode:

- `theorist-data` — "the bug is in the store/data layer. Start there."
- `theorist-protocol` — "the bug is in the request/response cycle. Start there."
- `theorist-tests` — "the bug is in test setup or fixtures. Start there."

**Run:** prompt all three on the same failing test or surprising behavior. Each writes a diagnosis. Then have them read each other's diagnoses and argue. Finally, a `judge` agent (or you) picks the most likely cause.

**Try it on:** `store.increment_votes` in this repo — the deliberate off-by-one. See which theorist finds it first, and watch the others push back.

**What you learn:** divergent priors produce different findings. The disagreement surfaces evidence none of them would have surfaced alone. The judge isn't always right, but the spread of opinions is itself informative.

---

## Red/Green Pair *(team)*

**Idea:** two agents in tmux with sharp, non-overlapping roles. One writes failing tests. The other makes them pass. They never trespass.

This is an agent team — the value isn't parallelism, it's the *discipline* the role-separation enforces.

**Setup:**

- `red` agent — system prompt: *"You write failing tests for behavior that doesn't yet exist. Never write implementation. Run pytest after each test to confirm it fails. Then @-mention green."*
- `green` agent — system prompt: *"You make failing tests pass with minimal implementation. Never modify tests. Run pytest after each change. Then @-mention red for the next test."*

**Run:** in tmux, kick `red` off with a feature description. The pair will iterate, test by test, until the feature is built.

**Try it on:** the missing `/leaderboard` endpoint from `SPEC.md`, but feature-by-feature instead of all at once.

**What you learn:** the role-separation makes small-step discipline mechanical. The commit history is cleaner than either agent would produce alone. And the tests can't drift to fit the implementation, because the implementer can't touch them.

---

## Full-Stack Pipeline *(controller)*

**Idea:** scale Exercise 2's Plan → Execute → Review across multiple workstreams. One PLAN.md fans out to N parallel workers in N worktrees. One unified REVIEW.md ties them back together.

**Setup (extend the starter with a tiny frontend):** add a `web/` directory with a single-page HTML app that calls the talkhub API. Then run a controller pipeline that spawns:

- `api-coder` — Python, in the FastAPI service worktree
- `web-coder` — HTML/JS, in a `web/` worktree
- `api-tester` — pytest for the API
- `e2e-tester` — Playwright (or a curl script) for the integration

**Run:** kickoff prompt asks for PLAN.md first (with sections per workstream). After you approve, the workstreams execute in parallel. After they finish, REVIEW.md diffs the result against the plan and lists deviations per workstream.

**Try it on:** *"Add a 'remove vote' button to the web UI, with the corresponding API endpoint and tests."*

**What you learn:** the Plan → Execute → Review discipline scales — but parallelism has a ceiling. Past three or four parallel workers, coordination cost starts to dominate. Find yours.

---

## A note on cost

These bonus patterns burn tokens. The Bug Tribunal alone is 3–5x a normal session because of the cross-talk. Run them once for the experience; default back to the simpler patterns for daily work.
