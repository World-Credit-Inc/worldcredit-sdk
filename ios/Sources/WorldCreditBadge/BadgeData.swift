import SwiftUI

/// Represents a user's World Credit badge data
public struct BadgeData: Codable, Sendable {
    public let ok: Bool
    public let handle: String
    public let displayName: String?
    public let worldScore: Int
    public let tier: String
    public let tierColor: String
    public let photoUrl: String?
    public let linkedNetworks: [String]?
    public let profileUrl: String
    public let categories: [String]?
    
    /// Computed tier type for easier handling
    public var tierType: TierType {
        TierType.from(score: worldScore)
    }
    
    /// Computed tier color as SwiftUI Color
    public var color: Color {
        Color(hex: tierColor) ?? tierType.color
    }
}

/// World Credit tier types with associated colors and score ranges
public enum TierType: String, CaseIterable {
    case unrated = "Unrated"
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"
    
    /// Create tier type from score
    public static func from(score: Int) -> TierType {
        switch score {
        case 0:
            return .unrated
        case 1...19:
            return .bronze
        case 20...49:
            return .silver
        case 50...79:
            return .gold
        case 80...:
            return .platinum
        default:
            return .unrated
        }
    }
    
    /// Default tier colors
    public var color: Color {
        switch self {
        case .unrated:
            return Color(hex: "#4A5568") ?? .gray
        case .bronze:
            return Color(hex: "#CD7F32") ?? .brown
        case .silver:
            return Color(hex: "#C0C0C0") ?? .gray
        case .gold:
            return Color(hex: "#FFD700") ?? .yellow
        case .platinum:
            return Color(hex: "#00FFC8") ?? .green
        }
    }
    
    /// Hex color string for the tier
    public var hexColor: String {
        switch self {
        case .unrated: return "#4A5568"
        case .bronze: return "#CD7F32"
        case .silver: return "#C0C0C0"
        case .gold: return "#FFD700"
        case .platinum: return "#00FFC8"
        }
    }
}

/// Badge size options
public enum BadgeSize: CGFloat, CaseIterable {
    case xs = 16
    case sm = 20
    case md = 24
    case lg = 32
    case xl = 40
    
    public var iconSize: CGFloat {
        return self.rawValue * 0.6
    }
}

/// Error types for the World Credit Badge SDK
public enum BadgeError: Error, LocalizedError {
    case invalidHandle
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData
    case invalidResponse
    
    public var errorDescription: String? {
        switch self {
        case .invalidHandle:
            return "Invalid handle provided"
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}

// MARK: - Color Extension

extension Color {
    /// Initialize Color from hex string
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}