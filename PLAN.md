# PochiDoku engagement MVP

## Objective

Add a small, offline engagement layer to the existing Sudoku loop without new
dependencies, accounts, tracking, or backend infrastructure.

## Scope

1. Show a live score, a fixed three-mistake limit, difficulty, timer, and daily
   streak above the board.
2. Add one deterministic Medium daily challenge shared by calendar date.
3. Persist completed daily dates and calculate a local consecutive-day streak.
4. Celebrate completion with score, streak, personal best, and an honest
   percentile against the player's own prior games of the same difficulty.
5. Surface daily completions and streaks in Home/Stats while preserving the
   existing local-only privacy model.

## Non-goals

- No login, remote leaderboard, analytics, notifications, virtual currency, or
  streak purchases.
- No claim about other players until a real aggregate data source exists.
- No new third-party dependency or persistence framework.

## Verification

- `git diff --check`.
- GitHub Actions `iOS build` succeeds.
- GitHub Actions simulator screenshot succeeds and is inspected visually.
- Existing regular game, resume, score history, and screenshot seed continue to
  work with backward-compatible decoding of saved games.
