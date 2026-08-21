import Foundation

/// Lightweight on-device persistence of completed games and the in-progress game,
/// stored as JSON in `UserDefaults`. Kept deliberately simple — no Core Data — and
/// nothing ever leaves the device. Mirrors the storage style of the rest of the app.
final class ScoreStore {

    private let defaults: UserDefaults
    private let sessionsKey = "SudokuApp.sessions"
    private let activeKey = "SudokuApp.activeGame"
    private let dailyCompletionsKey = "SudokuApp.dailyCompletions"
    private let maxStored = 200

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Completed sessions

    /// All saved games, most recent first.
    func allSessions() -> [GameSession] {
        guard let data = defaults.data(forKey: sessionsKey) else { return [] }
        let sessions = (try? JSONDecoder().decode([GameSession].self, from: data)) ?? []
        return sessions.sorted { $0.date > $1.date }
    }

    /// Appends a finished game and trims history to `maxStored`.
    func save(_ session: GameSession) {
        var sessions = allSessions()
        sessions.removeAll { $0.id == session.id }
        sessions.insert(session, at: 0)
        persistSessions(Array(sessions.prefix(maxStored)))
    }

    func delete(_ id: UUID) {
        persistSessions(allSessions().filter { $0.id != id })
    }

    func clearSessions() {
        defaults.removeObject(forKey: sessionsKey)
        defaults.removeObject(forKey: dailyCompletionsKey)
    }

    private func persistSessions(_ sessions: [GameSession]) {
        if let data = try? JSONEncoder().encode(sessions) {
            defaults.set(data, forKey: sessionsKey)
        }
    }

    // MARK: - Active (resumable) game

    func loadActiveGame() -> ActiveGame? {
        guard let data = defaults.data(forKey: activeKey) else { return nil }
        return try? JSONDecoder().decode(ActiveGame.self, from: data)
    }

    func saveActiveGame(_ game: ActiveGame) {
        if let data = try? JSONEncoder().encode(game) {
            defaults.set(data, forKey: activeKey)
        }
    }

    func clearActiveGame() {
        defaults.removeObject(forKey: activeKey)
    }

    // MARK: - Daily challenge

    /// A local calendar identifier that is also stable input for puzzle generation.
    static func dayID(for date: Date = Date(), calendar: Calendar = .autoupdatingCurrent) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// FNV-1a turns the day identifier into a stable seed without platform hashing.
    static func challengeSeed(for dayID: String) -> UInt64 {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in dayID.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return hash
    }

    func isDailyCompleted(_ dayID: String) -> Bool {
        completedDailyIDs().contains(dayID)
    }

    /// Records a date once and returns the resulting current streak.
    @discardableResult
    func markDailyCompleted(_ dayID: String) -> Int {
        var completed = completedDailyIDs()
        completed.insert(dayID)
        defaults.set(Array(completed).sorted(), forKey: dailyCompletionsKey)
        return currentStreak()
    }

    func dailyCompletionCount() -> Int {
        completedDailyIDs().count
    }

    /// A streak remains active through today, or through yesterday until today's
    /// challenge is completed. Calendar arithmetic handles daylight-saving changes.
    func currentStreak(asOf date: Date = Date(), calendar: Calendar = .autoupdatingCurrent) -> Int {
        let completed = completedDailyIDs()
        var cursor = calendar.startOfDay(for: date)

        if !completed.contains(Self.dayID(for: cursor, calendar: calendar)) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor),
                  completed.contains(Self.dayID(for: yesterday, calendar: calendar)) else {
                return 0
            }
            cursor = yesterday
        }

        var streak = 0
        while completed.contains(Self.dayID(for: cursor, calendar: calendar)) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    private func completedDailyIDs() -> Set<String> {
        Set(defaults.stringArray(forKey: dailyCompletionsKey) ?? [])
    }

    // MARK: - Personal comparison

    /// Honest local comparison until PochiDoku has a real aggregate player source.
    /// Three prior games avoids presenting a noisy percentage after the first solve.
    func personalPercentile(score: Int, difficulty: Difficulty) -> Int? {
        let prior = allSessions().filter { $0.difficulty == difficulty }
        guard prior.count >= 3 else { return nil }
        let beaten = prior.filter { score > $0.score }.count
        return min(99, Int((Double(beaten) / Double(prior.count) * 100).rounded()))
    }

    func isPersonalBest(score: Int, difficulty: Difficulty) -> Bool {
        let priorBest = allSessions()
            .filter { $0.difficulty == difficulty }
            .map(\.score)
            .max()
        return priorBest.map { score > $0 } ?? true
    }

    // MARK: - Derived stats

    struct Stats {
        var gamesPlayed: Int
        var totalScore: Int
        var bestScore: Int
        var bestTimeByDifficulty: [Difficulty: Int]
        var countByDifficulty: [Difficulty: Int]
        var dailyChallengesSolved: Int
        var currentStreak: Int
    }

    func stats() -> Stats {
        let sessions = allSessions()
        var bestTime: [Difficulty: Int] = [:]
        var counts: [Difficulty: Int] = [:]
        for s in sessions {
            counts[s.difficulty, default: 0] += 1
            if let existing = bestTime[s.difficulty] {
                bestTime[s.difficulty] = min(existing, s.durationSeconds)
            } else {
                bestTime[s.difficulty] = s.durationSeconds
            }
        }
        return Stats(
            gamesPlayed: sessions.count,
            totalScore: sessions.reduce(0) { $0 + $1.score },
            bestScore: sessions.map(\.score).max() ?? 0,
            bestTimeByDifficulty: bestTime,
            countByDifficulty: counts,
            dailyChallengesSolved: dailyCompletionCount(),
            currentStreak: currentStreak()
        )
    }
}
