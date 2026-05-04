# spicy-to-dark-factory-starter

Workshop starter for **From Spicy Autocomplete to Dark Factory: Agentic Coding in Practice**.

The talk was 60 minutes. This repo is the rest of the workshop — same agents, same spec, same Gastown capstone, with self-paced exercises. If you brought a laptop to the talk, this is what you take home.

---

## Quickstart

```bash
git clone https://github.com/BillDX/spicy-to-dark-factory-starter
cd spicy-to-dark-factory-starter
uv sync
uv run pytest        # confirm green baseline
claude               # open Claude Code
```

Then:

```text
> /exercise-1
```

…or just open `EXERCISES.md` and follow along.

---

## What's in here

```text
.
├── CLAUDE.md                # the project brief, auto-loaded by Claude Code
├── SPEC.md                  # feature spec used by the controller-pattern demo
├── EXERCISES.md             # three self-paced exercises mirroring the workshop
├── BONUS.md                 # bug tribunal, TDD pair, full-stack swarm
├── GASTOWN-DEMO.md          # capstone: building Conference Talk Bingo via kilo.ai/Gastown
├── pyproject.toml           # uv-managed FastAPI mini-app
├── src/talkhub/             # the project the agents operate on
│   ├── main.py
│   ├── models.py
│   ├── store.py
│   └── routes/
│       ├── talks.py
│       └── votes.py
├── tests/                   # pytest, with a clean baseline
└── .claude/
    ├── agents/              # six pre-built specialists
    │   ├── reviewer.md
    │   ├── documenter.md
    │   ├── security-reviewer.md
    │   ├── planner.md
    │   ├── coder.md
    │   └── tester.md
    ├── commands/
    │   ├── review.md        # /review — runs reviewer + security-reviewer in parallel
    │   └── ship.md          # /ship — runs the controller pipeline on a SPEC
    └── settings.json        # example permissions allowlist + denylist
```

## Demo seeds

The codebase ships with deliberate problems for the exercises to find. They're documented in `CLAUDE.md` so you don't get sandbagged by them later. If you "fix" them outside the workshop, leave a note — the demos lean on them.

## Prerequisites

- Python 3.11+
- [`uv`](https://docs.astral.sh/uv/) installed
- [Claude Code](https://docs.claude.com/en/docs/claude-code) installed and authenticated
- For Exercise 3: `tmux` (`brew install tmux` on macOS)

## License

GPL-3.0 (copyleft) — see [LICENSE](LICENSE).

## Credits

Workshop and starter by Bill McIntyre · bill.thinkiac@gmail.com · github.com/BillDX
