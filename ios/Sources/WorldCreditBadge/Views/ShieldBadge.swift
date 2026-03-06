import SwiftUI

/// Minimal shield badge with just logo and colored checkmark dot
public struct ShieldBadge: View {
    private let handle: String
    private let email: String?
    private let theme: BadgeTheme
    private let size: BadgeSize
    private let showCheckmark: Bool
    
    @StateObject private var dataModel: BadgeDataModel
    
    /// Initialize with handle and optional customization
    /// - Parameters:
    ///   - handle: User handle to display badge for
    ///   - theme: Visual theme (default: automatic)
    ///   - size: Badge size (default: medium)
    ///   - showCheckmark: Whether to show tier-colored checkmark dot (default: true)
    public init(
        handle: String = "",
        email: String? = nil,
        theme: BadgeTheme = .automatic,
        size: BadgeSize = .md,
        showCheckmark: Bool = true
    ) {
        self.handle = handle
        self.theme = theme
        self.size = size
        self.showCheckmark = showCheckmark
        self._dataModel = StateObject(wrappedValue: BadgeDataModel(handle: handle))
    }
    
    /// Initialize with pre-fetched badge data
    /// - Parameters:
    ///   - badgeData: Pre-fetched badge data
    ///   - theme: Visual theme (default: automatic)
    ///   - size: Badge size (default: medium)
    ///   - showCheckmark: Whether to show tier-colored checkmark dot (default: true)
    public init(
        badgeData: BadgeData,
        theme: BadgeTheme = .automatic,
        size: BadgeSize = .md,
        showCheckmark: Bool = true
    ) {
        self.handle = badgeData.handle
        self.theme = theme
        self.size = size
        self.showCheckmark = showCheckmark
        self._dataModel = StateObject(wrappedValue: BadgeDataModel(handle: badgeData.handle))
        
        // Set the pre-fetched data
        DispatchQueue.main.async {
            self.dataModel.badgeData = badgeData
        }
    }
    
    public var body: some View {
        Group {
            if let badgeData = dataModel.badgeData {
                BadgeContent(
                    badgeData: badgeData,
                    theme: theme,
                    size: size,
                    showCheckmark: showCheckmark
                )
            } else if dataModel.isLoading {
                LoadingContent(theme: theme, size: size)
            } else if dataModel.error != nil {
                ErrorContent(theme: theme, size: size)
            } else {
                EmptyView()
            }
        }
        .onAppear {
            if dataModel.badgeData == nil && !dataModel.isLoading {
                dataModel.loadData()
            }
        }
    }
}

private struct BadgeContent: View {
    let badgeData: BadgeData
    let theme: BadgeTheme
    let size: BadgeSize
    let showCheckmark: Bool
    
    private var effectiveTierColor: Color {
        badgeData.isUnverified ? .gray : badgeData.tierType.color
    }
    
    var body: some View {
        ZStack {
            // Main logo/shield background
            Circle()
                .fill(theme.backgroundColor)
                .overlay(
                    Circle()
                        .stroke(effectiveTierColor.opacity(0.3), lineWidth: 2)
                )
                .frame(width: size.rawValue, height: size.rawValue)
            
            // World Credit logo
            WorldCreditLogo(size: size.rawValue * 0.6)
                .opacity(badgeData.isUnverified ? 0.5 : 1.0)
            
            if showCheckmark {
                // Tier-colored checkmark dot (or "?" if unverified) in top-right corner
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(effectiveTierColor)
                                .frame(width: size.rawValue * 0.35, height: size.rawValue * 0.35)
                            
                            if badgeData.isUnverified {
                                Text("?")
                                    .font(.system(size: size.rawValue * 0.15, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.system(size: size.rawValue * 0.15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .offset(x: size.rawValue * 0.1, y: -size.rawValue * 0.1)
                    }
                    
                    Spacer()
                }
                .frame(width: size.rawValue, height: size.rawValue)
            }
        }
        .profileTappable(badgeData)
    }
}

private struct LoadingContent: View {
    let theme: BadgeTheme
    let size: BadgeSize
    
    var body: some View {
        ZStack {
            Circle()
                .fill(theme.backgroundColor)
                .overlay(
                    Circle()
                        .stroke(theme.borderColor, lineWidth: 2)
                )
                .frame(width: size.rawValue, height: size.rawValue)
            
            ProgressView()
                .scaleEffect(0.6)
        }
    }
}

private struct ErrorContent: View {
    let theme: BadgeTheme
    let size: BadgeSize
    
    var body: some View {
        ZStack {
            Circle()
                .fill(theme.backgroundColor)
                .overlay(
                    Circle()
                        .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                )
                .frame(width: size.rawValue, height: size.rawValue)
            
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: size.rawValue * 0.4))
        }
    }
}

// MARK: - Shield Variants

extension ShieldBadge {
    /// Create a verification badge style (green checkmark, regardless of tier)
    public static func verification(
        handle: String,
        theme: BadgeTheme = .automatic,
        size: BadgeSize = .md
    ) -> some View {
        ShieldBadge(handle: handle, theme: theme, size: size)
            .overlay(
                // Override with green verification checkmark
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(.green)
                                .frame(width: size.rawValue * 0.35, height: size.rawValue * 0.35)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: size.rawValue * 0.15, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .offset(x: size.rawValue * 0.1, y: -size.rawValue * 0.1)
                    }
                    
                    Spacer()
                }
                .frame(width: size.rawValue, height: size.rawValue)
            )
    }
    
    /// Create a minimal version without checkmark
    public static func minimal(
        handle: String,
        theme: BadgeTheme = .automatic,
        size: BadgeSize = .md
    ) -> some View {
        ShieldBadge(handle: handle, theme: theme, size: size, showCheckmark: false)
    }
}

// MARK: - Previews

struct ShieldBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            // Different tiers in a row
            HStack(spacing: 16) {
                ForEach([
                    (tier: TierType.bronze, score: 15, handle: "bronze_user"),
                    (tier: TierType.silver, score: 35, handle: "silver_user"),
                    (tier: TierType.gold, score: 65, handle: "gold_user"),
                    (tier: TierType.platinum, score: 95, handle: "platinum_user")
                ], id: \.handle) { tierData in
                    VStack(spacing: 4) {
                        ShieldBadge(
                            badgeData: BadgeData(
                                ok: true,
                                handle: tierData.handle,
                                displayName: "\(tierData.tier.rawValue) User",
                                worldScore: tierData.score,
                                tier: tierData.tier.rawValue,
                                tierColor: tierData.tier.hexColor,
                                photoUrl: nil,
                                linkedNetworks: nil,
                                profileUrl: "https://world-credit.com/\(tierData.handle)",
                                categories: nil
                            ),
                            size: .lg
                        )
                        
                        Text(tierData.tier.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Different sizes
            VStack(alignment: .leading, spacing: 12) {
                Text("Sizes:")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    ForEach([BadgeSize.sm, BadgeSize.md, BadgeSize.lg, BadgeSize.xl], id: \.rawValue) { size in
                        VStack(spacing: 4) {
                            ShieldBadge(
                                badgeData: BadgeData(
                                    ok: true,
                                    handle: "test_user",
                                    displayName: "Test User",
                                    worldScore: 75,
                                    tier: "Gold",
                                    tierColor: "#FFD700",
                                    photoUrl: nil,
                                    linkedNetworks: nil,
                                    profileUrl: "https://world-credit.com/test_user",
                                    categories: nil
                                ),
                                size: size
                            )
                            
                            Text("\(size.rawValue, specifier: "%.0f")")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Variants
            VStack(alignment: .leading, spacing: 12) {
                Text("Variants:")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        ShieldBadge.verification(handle: "verified_user", size: .lg)
                        Text("Verification")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        ShieldBadge.minimal(handle: "minimal_user", size: .lg)
                        Text("Minimal")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Theme variants
            VStack(alignment: .leading, spacing: 12) {
                Text("Themes:")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        ShieldBadge(
                            badgeData: BadgeData(
                                ok: true,
                                handle: "light_theme",
                                displayName: "Light Theme",
                                worldScore: 85,
                                tier: "Platinum",
                                tierColor: "#00FFC8",
                                photoUrl: nil,
                                linkedNetworks: nil,
                                profileUrl: "https://world-credit.com/light_theme",
                                categories: nil
                            ),
                            theme: .light,
                            size: .lg
                        )
                        Text("Light")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        ShieldBadge(
                            badgeData: BadgeData(
                                ok: true,
                                handle: "dark_theme",
                                displayName: "Dark Theme",
                                worldScore: 85,
                                tier: "Platinum",
                                tierColor: "#00FFC8",
                                photoUrl: nil,
                                linkedNetworks: nil,
                                profileUrl: "https://world-credit.com/dark_theme",
                                categories: nil
                            ),
                            theme: .dark,
                            size: .lg
                        )
                        Text("Dark")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}