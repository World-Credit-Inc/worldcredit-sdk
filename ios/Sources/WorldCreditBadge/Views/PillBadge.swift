import SwiftUI

/// Compact pill badge with logo, score, and tier tag in a capsule
public struct PillBadge: View {
    private let handle: String
    private let email: String?
    private let theme: BadgeTheme
    private let size: BadgeSize
    private let showTierTag: Bool
    
    @StateObject private var dataModel: BadgeDataModel
    
    /// Initialize with handle and optional customization
    /// - Parameters:
    ///   - handle: User handle to display badge for
    ///   - theme: Visual theme (default: automatic)
    ///   - size: Badge size (default: medium)
    ///   - showTierTag: Whether to show colored tier tag (default: true)
    public init(
        handle: String = "",
        email: String? = nil,
        theme: BadgeTheme = .automatic,
        size: BadgeSize = .md,
        showTierTag: Bool = true
    ) {
        self.handle = handle
        self.theme = theme
        self.size = size
        self.showTierTag = showTierTag
        self._dataModel = StateObject(wrappedValue: BadgeDataModel(handle: handle))
    }
    
    /// Initialize with pre-fetched badge data
    /// - Parameters:
    ///   - badgeData: Pre-fetched badge data
    ///   - theme: Visual theme (default: automatic)
    ///   - size: Badge size (default: medium)
    ///   - showTierTag: Whether to show colored tier tag (default: true)
    public init(
        badgeData: BadgeData,
        theme: BadgeTheme = .automatic,
        size: BadgeSize = .md,
        showTierTag: Bool = true
    ) {
        self.handle = badgeData.handle
        self.theme = theme
        self.size = size
        self.showTierTag = showTierTag
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
                    showTierTag: showTierTag
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
    let showTierTag: Bool
    
    private var style: BadgeStyle {
        BadgeStyle(theme: theme, tierType: badgeData.tierType)
    }
    
    private var effectiveTierColor: Color {
        badgeData.isUnverified ? .gray : style.tierColor
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // World Credit logo
            WorldCreditLogo(size: size.rawValue)
                .opacity(badgeData.isUnverified ? 0.5 : 1.0)
            
            VStack(alignment: .leading, spacing: 2) {
                // Score (or "—" if unverified)
                Text(badgeData.isUnverified ? "—" : "\(badgeData.worldScore)")
                    .font(.system(size: size.rawValue * 0.7, weight: .bold))
                    .foregroundColor(badgeData.isUnverified
                        ? theme.textColor.opacity(0.5)
                        : theme.textColor)
                
                // Tier name (or "NOT VERIFIED" if unverified)
                Text(badgeData.isUnverified
                    ? "NOT VERIFIED"
                    : badgeData.tierType.rawValue.uppercased())
                    .font(.system(size: size.rawValue * 0.4, weight: .medium))
                    .foregroundColor(badgeData.isUnverified ? .gray : theme.secondaryTextColor)
            }
            
            if showTierTag {
                // Tier color indicator
                Capsule()
                    .fill(effectiveTierColor)
                    .frame(width: 4, height: size.rawValue * 0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius * 2)
                .fill(theme.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius * 2)
                        .stroke(effectiveTierColor.opacity(0.3), lineWidth: theme.borderWidth)
                )
                .shadow(
                    color: theme.shadowColor,
                    radius: style.shadowRadius,
                    x: 0,
                    y: style.shadowOffset.height
                )
        )
        .profileTappable(badgeData)
    }
}

private struct LoadingContent: View {
    let theme: BadgeTheme
    let size: BadgeSize
    
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
                .frame(width: size.rawValue, height: size.rawValue)
            
            VStack(alignment: .leading, spacing: 2) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.secondaryTextColor.opacity(0.3))
                    .frame(width: 20, height: size.rawValue * 0.3)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.secondaryTextColor.opacity(0.2))
                    .frame(width: 35, height: size.rawValue * 0.25)
            }
            
            Capsule()
                .fill(theme.secondaryTextColor.opacity(0.2))
                .frame(width: 4, height: size.rawValue * 0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius * 2)
                .fill(theme.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius * 2)
                        .stroke(theme.borderColor, lineWidth: theme.borderWidth)
                )
        )
    }
}

private struct ErrorContent: View {
    let theme: BadgeTheme
    let size: BadgeSize
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: size.rawValue * 0.8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Error")
                    .font(.system(size: size.rawValue * 0.5, weight: .medium))
                    .foregroundColor(theme.textColor)
                
                Text("FAILED")
                    .font(.system(size: size.rawValue * 0.35, weight: .medium))
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius * 2)
                .fill(theme.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius * 2)
                        .stroke(Color.orange.opacity(0.3), lineWidth: theme.borderWidth)
                )
        )
    }
}

// MARK: - Previews

struct PillBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Different tier examples
            HStack(spacing: 12) {
                PillBadge(
                    badgeData: BadgeData(
                        ok: true,
                        handle: "bronze_user",
                        displayName: "Bronze User",
                        worldScore: 15,
                        tier: "Bronze",
                        tierColor: "#CD7F32",
                        photoUrl: nil,
                        linkedNetworks: nil,
                        profileUrl: "https://world-credit.com/bronze_user",
                        categories: nil
                    ),
                    size: .md
                )
                
                PillBadge(
                    badgeData: BadgeData(
                        ok: true,
                        handle: "silver_user",
                        displayName: "Silver User",
                        worldScore: 35,
                        tier: "Silver",
                        tierColor: "#C0C0C0",
                        photoUrl: nil,
                        linkedNetworks: nil,
                        profileUrl: "https://world-credit.com/silver_user",
                        categories: nil
                    ),
                    size: .md
                )
            }
            
            HStack(spacing: 12) {
                PillBadge(
                    badgeData: BadgeData(
                        ok: true,
                        handle: "gold_user",
                        displayName: "Gold User",
                        worldScore: 65,
                        tier: "Gold",
                        tierColor: "#FFD700",
                        photoUrl: nil,
                        linkedNetworks: nil,
                        profileUrl: "https://world-credit.com/gold_user",
                        categories: nil
                    ),
                    size: .md
                )
                
                PillBadge(
                    badgeData: BadgeData(
                        ok: true,
                        handle: "platinum_user",
                        displayName: "Platinum User",
                        worldScore: 95,
                        tier: "Platinum",
                        tierColor: "#00FFC8",
                        photoUrl: nil,
                        linkedNetworks: nil,
                        profileUrl: "https://world-credit.com/platinum_user",
                        categories: nil
                    ),
                    size: .md
                )
            }
            
            // Different sizes
            VStack(alignment: .leading, spacing: 12) {
                Text("Sizes:")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach([BadgeSize.sm, BadgeSize.md, BadgeSize.lg], id: \.rawValue) { size in
                    HStack {
                        Text("Size \(size.rawValue, specifier: "%.0f"):")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        
                        PillBadge(
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
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            
            // Without tier tag
            VStack(alignment: .leading, spacing: 8) {
                Text("Without tier tag:")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack {
                    PillBadge(
                        badgeData: BadgeData(
                            ok: true,
                            handle: "minimal_user",
                            displayName: "Minimal User",
                            worldScore: 42,
                            tier: "Silver",
                            tierColor: "#C0C0C0",
                            photoUrl: nil,
                            linkedNetworks: nil,
                            profileUrl: "https://world-credit.com/minimal_user",
                            categories: nil
                        ),
                        showTierTag: false
                    )
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}