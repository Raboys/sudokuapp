# PochiDoku engagement

This document records the engagement features agreed for PochiDoku, their
current behaviour, and the boundary between local results and future global
comparisons.

## Product goal

Make each Sudoku session feel rewarding and give the player a reason to return
daily, while keeping the app calm, lightweight, private, and honest.

The core loop is:

1. Choose a difficulty or open today's challenge.
2. See score, difficulty, mistakes, streak, and elapsed time while playing.
3. Finish the puzzle and receive a clear result: points, personal best, streak,
   and comparison with previous games.
4. Return the next day to continue the daily streak.

Engagement should support the puzzle rather than compete with it. PochiDoku
does not use virtual currency, ads, forced accounts, artificial scarcity, or
punitive streak recovery.

## Current feature set

### Difficulty

Regular games offer four difficulty levels. Difficulty controls the number of
starting clues, the base score, and the par time used for the speed bonus.

| Difficulty | Starting clues | Base score | Par time |
|---|---:|---:|---:|
| Easy | 45 | 1,000 | 5 minutes |
| Medium | 36 | 2,000 | 10 minutes |
| Hard | 30 | 3,500 | 15 minutes |
| Expert | 25 | 5,000 | 25 minutes |

The active difficulty remains visible above the board so the challenge has
context throughout the game.

### Points

The score is visible during play and updates from actual board progress. A
correctly completed board receives its difficulty's base score plus a speed
bonus. Hints and mistakes lower both the live and final score.

```text
live score = base score × correct playable cells / playable cells
             − (150 × hints) − (100 × mistakes)

final score = base score + max(0, par time − solve time)
              − (150 × hints) − (100 × mistakes)
```

The live score cannot be negative. The final score has a minimum of 50 points,
so every completed puzzle records a result. Re-entering a number cannot farm
points because live progress counts correct cells, not input actions.

### Three-mistake limit

Every puzzle allows three incorrect entries. The current count is always shown
as `mistakes / 3`. A third mistake ends the puzzle and discards that active
game; only solved games enter score history.

### Daily challenge

There is one Medium daily puzzle identified by the player's local calendar
date. Its deterministic seed is derived on-device from `YYYY-MM-DD`, so the
same app version generates the same puzzle for players on the same local date
without downloading content from a server.

- A daily game can be left and resumed.
- Completing it records that date once.
- Replaying it is allowed but does not add another daily completion or extend
  the streak again.
- Daily results still enter normal score history.

Because generation is local, preserving the puzzle-generation algorithm is
important: changing it may produce a different puzzle for the same date in a
future app version.

### Daily streak

The streak counts consecutive completed daily dates. It remains active when
the player has completed today's challenge, or when yesterday is complete and
today is still available. Missing a full calendar day resets the current
streak to zero.

The streak appears on Home, above the board, in the completion result, and in
Statistics. It is based solely on local completion records and is not tied to
an account.

### Completion feedback

After a solve, the result screen shows:

- Final score.
- Difficulty and solve time.
- Hints and mistakes.
- Daily streak when applicable.
- A new-personal-best message when the score beats all previous games of the
  same difficulty.
- A personal percentile after enough comparable history exists.

This gives immediate reward without interrupting play with extra screens or
claim flows.

### Personal comparison

The current percentage is deliberately personal, not global. After at least
three prior completed games at the same difficulty, PochiDoku reports the
percentage of those scores strictly beaten by the new score, capped at 99%.

For example, `Better than 78% of your Medium games` means exactly that. It must
never be presented as `better than 78% of players`.

## Where each signal appears

| Surface | Engagement signals |
|---|---|
| Home | Daily challenge status, current streak, resumable game, difficulty choices |
| Game | Streak, daily label, mistakes, live score, difficulty, timer |
| Completion | Final score, streak, personal best, personal percentile, time, hints, mistakes |
| Statistics | Games solved, best and total score, daily completions, current streak, best time and history by difficulty |

## Storage and privacy

All engagement data is stored on the device in `UserDefaults`:

- Up to 200 completed game sessions.
- One active resumable game.
- Completed daily date identifiers.
- Settings and age confirmation.

There is no account, analytics SDK, tracking, leaderboard, or network request.
Deleting score history also clears the locally recorded daily completions.

## Deferred: global player percentile

The reference experience includes a message such as `better than X% of
players`. PochiDoku should only add that claim when it has a real aggregate data
source. Until then, the personal comparison is the honest lightweight version.

A future global percentile requires:

1. Anonymous result submission with an explicit privacy decision and updated
   App Store privacy disclosure.
2. Comparable cohorts, at minimum separated by difficulty; daily challenges
   should be compared by challenge date.
3. A minimum sample size before displaying a percentage.
4. Server-side validation or abuse resistance so fabricated scores do not make
   the result meaningless.
5. Clear wording and a local fallback whenever no reliable cohort is available.

This backend work is intentionally outside the current offline MVP.

## Product constraints

- Keep the board as the visual priority.
- Keep scoring understandable and deterministic.
- Never invent social proof or imply a global comparison from local data.
- Preserve offline play and graceful local-only behaviour.
- Add no dependency or backend until a feature clearly requires one.
- Prefer a few durable signals over a large achievement or reward system.

## Implementation map

| Concern | Source |
|---|---|
| Score formulas | `SudokuApp/Utilities/ScoreCalculator.swift` |
| Daily IDs, streaks, history, comparisons | `SudokuApp/Utilities/ScoreStore.swift` |
| Game lifecycle and engagement state | `SudokuApp/ViewModels/GameViewModel.swift` |
| Difficulty constants | `SudokuApp/Models/Difficulty.swift` |
| Home, game, completion, and stats presentation | `SudokuApp/Views/` |
