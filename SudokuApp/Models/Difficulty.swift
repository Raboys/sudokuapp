import SwiftUI

/// The four selectable difficulty levels. Each level maps to a target number of
/// givens (clues) plus the scoring constants used when a puzzle is completed.
enum Difficulty: String, CaseIterable, Codable, Identifiable {
    case easy
    case medium
    case hard
    case expert

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy:   return L10n.text("Easy")
        case .medium: return L10n.text("Medium")
        case .hard:   return L10n.text("Hard")
        case .expert: return L10n.text("Expert")
        }
    }

    var subtitle: String {
        switch self {
        case .easy:   return L10n.text("Gentle warm-up")
        case .medium: return L10n.text("A balanced challenge")
        case .hard:   return L10n.text("For seasoned solvers")
        case .expert: return L10n.text("Ruthless. Good luck.")
        }
    }

    var symbol: String {
        switch self {
        case .easy:   return "leaf.fill"
        case .medium: return "flame.fill"
        case .hard:   return "bolt.fill"
        case .expert: return "crown.fill"
        }
    }

    var tint: Color {
        switch self {
        case .easy:   return .green
        case .medium: return .blue
        case .hard:   return .orange
        case .expert: return .purple
        }
    }

    /// Target number of starting clues. Fewer clues ⇒ harder puzzle.
    var targetClues: Int {
        switch self {
        case .easy:   return 45
        case .medium: return 36
        case .hard:   return 30
        case .expert: return 25
        }
    }

    /// "Par" solve time in seconds — beating it earns a speed bonus.
    var parSeconds: Int {
        switch self {
        case .easy:   return 300
        case .medium: return 600
        case .hard:   return 900
        case .expert: return 1500
        }
    }

    /// Base points awarded for completing a puzzle of this level.
    var baseScore: Int {
        switch self {
        case .easy:   return 1000
        case .medium: return 2000
        case .hard:   return 3500
        case .expert: return 5000
        }
    }
}
