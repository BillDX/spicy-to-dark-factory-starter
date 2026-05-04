#!/usr/bin/env bash
# scripts/demo3-debate.sh — set up and initiate Demo 3: The Architecture Debate.
#
# Creates three git worktrees on dedicated branches, opens a 3-pane tmux
# session, launches Claude Code in each pane, and pre-loads each pane
# with a different debate persona (Minimalist / Defensive / Perf Hawk).
#
# When the script attaches you to tmux, the three agents are loading
# their roles. Once they finish, paste the kickoff prompt printed to
# the terminal into ANY pane to start the debate.
#
# Requirements (assumed present): git, tmux, claude.
# Tested on macOS with Apple Silicon, default zsh + system bash 3.2.
#
# Usage:
#   ./scripts/demo3-debate.sh             # set up, launch, attach
#   ./scripts/demo3-debate.sh --cleanup   # tear down (kill session, remove worktrees, delete branches)
#   ./scripts/demo3-debate.sh --help

set -euo pipefail

SESSION="debate"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WT_PARENT="$(dirname "$REPO_ROOT")"

# Persona slugs match worktree dir suffix (../talkhub-<slug>) and branch name (debate-<slug>).
PERSONAS=("minimalist" "defensive" "perf")

# Single-line persona prompts. Kept on one line so tmux send-keys delivers them
# as a single user message (newlines would be sent as Enter and break the message).
PROMPT_MIN="You are the Minimalist on a 3-agent debate team. Your role: defend the simplest correct implementation. Lines of code are a cost. When the human posts the design problem in another pane, write your version in this worktree, read the others' proposals, and argue specifically and respectfully — but do not capitulate to politeness. Acknowledge the role and wait for the problem."
PROMPT_DEF="You are the Defensive Coder on a 3-agent debate team. Your role: defend handling edge cases, input validation, and explicit error paths. Silent bugs are the worst bugs. When the human posts the design problem, write your version in this worktree, read the others', and argue your case from concrete failure modes — do not concede just to be agreeable. Acknowledge the role and wait for the problem."
PROMPT_PERF="You are the Performance Hawk on a 3-agent debate team. Your role: defend runtime cost, memory, and big-O analysis. Don't ship code you haven't reasoned about. When the human posts the design problem, write your version in this worktree, read the others', and argue from data and complexity — do not capitulate without evidence. Acknowledge the role and wait for the problem."
PROMPTS=("$PROMPT_MIN" "$PROMPT_DEF" "$PROMPT_PERF")

KICKOFF_PROMPT='Team: we'\''re designing a function that deduplicates a list of strings, case-insensitive, preserving first-seen order. Each of you, propose your version in your worktree. Read the others'\'' proposals. Argue. You may write a counter-version in your own worktree if it makes the point. Converge on PROPOSAL.md: the version you all signed off on (or noted disagreement on), with a one-paragraph rationale and the tradeoffs you weighed.'

usage() {
  sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

cleanup() {
  echo "Tearing down Demo 3..."
  if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux kill-session -t "$SESSION"
    echo "  ✓ killed tmux session '$SESSION'"
  fi
  cd "$REPO_ROOT"
  for persona in "${PERSONAS[@]}"; do
    wt="$WT_PARENT/talkhub-$persona"
    branch="debate-$persona"
    if [[ -d "$wt" ]]; then
      git worktree remove --force "$wt" >/dev/null 2>&1 || rm -rf "$wt"
      echo "  ✓ removed worktree $wt"
    fi
    if git show-ref --verify --quiet "refs/heads/$branch"; then
      git branch -D "$branch" >/dev/null 2>&1 || true
      echo "  ✓ deleted branch $branch"
    fi
  done
  echo "Done."
}

case "${1:-}" in
  --help|-h)    usage ;;
  --cleanup)    cleanup; exit 0 ;;
  "" )          : ;;
  * )           echo "Unknown option: $1"; echo "Try --help"; exit 1 ;;
esac

# ─── preflight ────────────────────────────────────────────────────────
command -v tmux   >/dev/null 2>&1 || { echo "ERROR: tmux not found on PATH";   exit 1; }
command -v claude >/dev/null 2>&1 || { echo "ERROR: claude not found on PATH"; exit 1; }
[[ -d "$REPO_ROOT/.git" ]] || { echo "ERROR: $REPO_ROOT is not a git repo"; exit 1; }

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "ERROR: tmux session '$SESSION' already exists."
  echo "       Run: $0 --cleanup"
  exit 1
fi

for persona in "${PERSONAS[@]}"; do
  wt="$WT_PARENT/talkhub-$persona"
  if [[ -d "$wt" ]]; then
    echo "ERROR: worktree already exists: $wt"
    echo "       Run: $0 --cleanup"
    exit 1
  fi
done

# ─── create worktrees ─────────────────────────────────────────────────
cd "$REPO_ROOT"
echo "Creating worktrees..."
for persona in "${PERSONAS[@]}"; do
  wt="$WT_PARENT/talkhub-$persona"
  branch="debate-$persona"
  # If the branch already exists from a previous failed run, reuse it.
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$wt" "$branch" >/dev/null
  else
    git worktree add "$wt" -b "$branch" >/dev/null
  fi
  echo "  ✓ $wt (branch: $branch)"
done

# ─── tmux layout: 3 panes (top single, bottom two side-by-side) ───────
echo "Starting tmux session '$SESSION'..."
tmux new-session   -d -s "$SESSION"        -c "$WT_PARENT/talkhub-${PERSONAS[0]}"
tmux split-window  -v -t "$SESSION":0.0   -c "$WT_PARENT/talkhub-${PERSONAS[1]}"
tmux split-window  -h -t "$SESSION":0.1   -c "$WT_PARENT/talkhub-${PERSONAS[2]}"
tmux select-layout -t "$SESSION" main-horizontal >/dev/null

# Pane titles (visible at the top of each pane)
tmux set-option -t "$SESSION" pane-border-status top   >/dev/null
tmux set-option -t "$SESSION" pane-border-format " #{pane_title} " >/dev/null
for i in 0 1 2; do
  tmux select-pane -t "$SESSION":0.$i -T " ${PERSONAS[$i]} "
done

# ─── launch Claude in each pane ───────────────────────────────────────
for i in 0 1 2; do
  tmux send-keys -t "$SESSION":0.$i "claude" Enter
done

echo "Waiting for Claude to initialize (5s)..."
sleep 5

# ─── deliver each persona prompt as a single message ──────────────────
for i in 0 1 2; do
  tmux send-keys -t "$SESSION":0.$i "${PROMPTS[$i]}" Enter
done

# ─── instructions for the user ────────────────────────────────────────
cat <<EOF

═══════════════════════════════════════════════════════════════════
  DEMO 3 IS LIVE — three Claude agents are loading their personas.
═══════════════════════════════════════════════════════════════════

  Panes (tile layout):
    top         — minimalist
    bottom-left — defensive
    bottom-right — perf hawk

  Wait until each agent acknowledges its role, then switch to ANY
  pane and paste this kickoff prompt to start the debate:

───────────────────────────────────────────────────────────────────
$KICKOFF_PROMPT
───────────────────────────────────────────────────────────────────

  tmux:
    Switch panes  Ctrl-b ←/→/↑/↓
    Zoom one pane Ctrl-b z
    Detach        Ctrl-b d
    Reattach      tmux attach -t $SESSION

  Tear down (when done):
    $0 --cleanup

Attaching to tmux in 3 seconds...
EOF

sleep 3
tmux attach -t "$SESSION"
