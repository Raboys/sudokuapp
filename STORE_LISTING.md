# App Store listing — PochiDoku

Everything needed to fill in the App Store Connect product page. Credentials/contact live in
the gitignored `.env`; this file holds the public-facing copy and asset locations.

## Identity

| Field | Value |
|---|---|
| App name | PochiDoku |
| Bundle ID | `com.raboys.pochidoku` |
| Team | Configure the Raboys Apple Developer team in Xcode |
| Apple account | Configure in App Store Connect |
| Platform | iOS 16+, iPhone only (portrait) |
| Primary category | Games → Puzzle (secondary: Board) |
| Price | Free |
| **Age rating** | **13+** — set via API (`ageRatingOverrideV2 = THIRTEEN_PLUS` on the appInfo ageRatingDeclaration); the app also shows a one-time in-app 14+ gate (single tap, no ID/verification) |

## Marketing copy

**Subtitle** (≤30): `Classic number puzzles`

**Keywords** (≤100, CSV): `sudoku,puzzle,number,logic,brain,board game,grid,classic,offline,hints`

**Promotional text** (≤170):
> Daily Sudoku challenges, streaks, live scores, smart hints, and four difficulty levels — private, focused, and completely offline.

**Description** (≤4000):
> PochiDoku is a clean, offline number-puzzle game. Every puzzle is generated on your device with a guaranteed unique solution. Choose from four difficulty levels — Easy, Medium, Hard, and Expert — or return for one shared daily challenge generated from the calendar date.
>
> • Four difficulty levels, from gentle warm-ups to ruthless Expert grids
> • Smart hints whenever you ask — reveal the right number for any cell
> • Pencil notes (candidates) with optional auto-cleanup
> • Conflict and same-number highlighting you can toggle on or off
> • Three-strike games with clear mistake tracking
> • Daily challenges and consecutive-day streaks
> • Live points, personal bests, and comparisons against your own past games
> • A timer, scoring, and full game history kept entirely on your iPhone
> • 100% offline and private — nothing ever leaves your device
>
> Track your best times and scores per difficulty, resume any game you leave, and build a daily streak one grid at a time.

## App Privacy

**Data Not Collected.** No tracking, no network, no permissions. Scores and history live in
`UserDefaults` on-device. (Set in the ASC UI: App Privacy → "No, we do not collect data" → Publish.)

## App Review notes

> Offline Sudoku puzzle game. No login required, no permissions requested. A one-time 14+ age
> gate appears on first launch — tap "I am 14 or older" to reach the game (no ID or
> verification). Bottom navigation adds Stats (local score/time history), Feedback (opens
> WhatsApp), and About tabs. All scores/history are stored locally on device.

## Assets

| Asset | Path | Size |
|---|---|---|
| App icon (1024, no alpha) | `SudokuApp/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` | 1024×1024 |
| Screenshot 1 — Home | `screenshots/appstore/1-home.png` | 1320×2868 (6.9") |
| Screenshot 2 — Game | `screenshots/appstore/2-game.png` | 1320×2868 (6.9") |
| Screenshot 3 — Completion | `screenshots/appstore/3-completion.png` | 1320×2868 (6.9") |
| Raw (unframed) captures | `screenshots/raw/*.png` | 1320×2868 |

Regenerate:
- Icon: `swift .claude/skills/app-store-submission/scripts/make_sudoku_icon.swift <out.png>` then flatten alpha.
- Screenshots: build for the 6.9" simulator and launch with `SIMCTL_CHILD_SUDOKU_SCREENSHOT=home|game|completion` (DEBUG-only hook), then frame with `scripts/frame_screenshot.swift <in> <out> "Caption"`.

## Submission

Driven by the `app-store-submission` skill. The 6.9" set (`APP_IPHONE_67`, 1290×2796 or
1320×2868) is the only required screenshot size. **Age rating is API-settable** (PATCH the
appInfo's ageRatingDeclaration with `ageRatingOverrideV2`); only **App Privacy is UI-only**.
