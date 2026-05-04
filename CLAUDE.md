# talkhub

Workshop starter for "From Spicy Autocomplete to Dark Factory". A small FastAPI service for submitting and voting on conference talks. Intentionally small so the focus stays on the agent harness, not the domain.

## Stack

- Python 3.11+, managed with `uv`
- FastAPI + Pydantic v2
- pytest, ruff
- In-memory store (no DB) — keeps demos fast and reset-friendly

## Conventions

- Source lives in `src/talkhub/`, tests in `tests/`
- Use `uv` for everything: `uv sync`, `uv run pytest`, `uv run uvicorn talkhub.main:app --reload`
- Type hints on every public function
- Routes in `src/talkhub/routes/`, one file per resource
- The store is a module, not a class. `store.reset()` clears it.

## Don't

- Add a database. The in-memory store is the demo's point.
- Reach across modules into private state. Use `store.*` functions.
- Skip the test suite when you ship — `uv run pytest` is the gate.

## Demo seeds (intentional)

This codebase ships with deliberate problems for the workshop demos to find:

- `store.search_talks` uses `eval()` on user input — security-reviewer should flag.
- `store.increment_votes` has an off-by-one — reviewer + tests should catch.
- Route handlers in `routes/talks.py` have no docstrings — documenter agent fills them.
- There is no `/leaderboard` endpoint — `SPEC.md` asks the controller pipeline to add one.

If you fix these outside the workshop, leave a note — the demos lean on them.

## Helpful

- Run the API: `uv run uvicorn talkhub.main:app --reload`
- Run tests: `uv run pytest`
- Format: `uv run ruff format .`
- Lint: `uv run ruff check .`
