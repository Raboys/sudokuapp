import Foundation

/// Converts a finished game into a score. Faster solves with no hints and no
/// mistakes score highest; the result is floored so every win is worth something.
enum ScoreCalculator {

    static let hintPenalty = 150
    static let mistakePenalty = 100
    static let minimumScore = 50

    /// Score earned by the board's current correct progress. It starts at zero,
    /// cannot be inflated by re-entering a value, and uses the same penalties as
    /// the final score. The speed bonus is intentionally reserved for completion.
    static func liveScore(difficulty: Difficulty,
                          puzzle: [Int],
                          values: [Int],
                          solution: [Int],
                          hintsUsed: Int,
                          mistakes: Int) -> Int {
        guard puzzle.count == values.count, values.count == solution.count else { return 0 }
        let playable = puzzle.indices.filter { puzzle[$0] == 0 }
        guard !playable.isEmpty else { return 0 }
        let correct = playable.filter { values[$0] == solution[$0] }.count
        let progress = difficulty.baseScore * correct / playable.count
        return max(0, progress - hintsUsed * hintPenalty - mistakes * mistakePenalty)
    }

    static func score(difficulty: Difficulty,
                      seconds: Int,
                      hintsUsed: Int,
                      mistakes: Int) -> Int {
        // Beating par time earns a one-point-per-second bonus; going over par costs
        // nothing beyond losing the bonus.
        let speedBonus = max(0, difficulty.parSeconds - seconds)
        let raw = difficulty.baseScore
            + speedBonus
            - hintsUsed * hintPenalty
            - mistakes * mistakePenalty
        return max(minimumScore, raw)
    }
}
