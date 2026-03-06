import SwiftUI

/// Rich card badge showing logo, "World Credit" label, large score, and tier
public struct CardBadge: View {
    private let handle: String
    private let email: String?
    private let theme: BadgeTheme
    private let width: CGFloat?
    private let showUserInfo: Bool
    
    @StateObject private var dataModel: BadgeDataModel
    
    /// Initialize with handle and optional customization
    /// - Parameters:
    ///   - handle: User handle to display badge for
    ///   - theme: Visual theme (default: automatic)
    ///   - width: Fixed width for the card (default: adaptive)
    ///   - showUserInfo: Whether to show user display name and handle (default: true)
    public init(
        handle: String = "",
        email: String? = nil,
        theme: BadgeTheme = .automatic,
        width: CGFloat? = nil,
        showUserInfo: Bool = true
    ) {
        self.handle = handle
        self.theme = theme
        self.width = width
        self.showUserInfo = showUserInfo
        self._dataModel = StateObject(wrappedValue: BadgeDataModel(handle: handle))
    }
    
    /// Initialize with pre-fetched badge data
    /// - Parameters:
    ///   - badgeData: Pre-fetched badge data
    ///   - theme: Visual theme (default: automatic)
    ///   - width: Fixed width for the card (default: adaptive)
    ///   - showUserInfo: Whether to show user display name and handle (default: true)
    public init(
        badgeData: BadgeData,
        theme: BadgeTheme = .automatic,
        width: CGFloat? = nil,
        showUserInfo: Bool = true
    ) {
        self.handle = badgeData.handle
        self.theme = theme
        self.width = width
        self.showUserInfo = showUserInfo
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
                    width: width,
                    showUserInfo: showUserInfo
                )
            } else if dataModel.isLoading {
                LoadingContent(theme: theme, width: width)
            } else if dataModel.error != nil {
                ErrorContent(theme: theme, width: width, error: dataModel.error)
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
    let width: CGFloat?
    let showUserInfo: Bool
    
    private var style: BadgeStyle {
        BadgeStyle(theme: theme, tierType: badgeData.tierType)
    }
    
    private var effectiveTierColor: Color {
        badgeData.isUnverified ? .gray : style.tierColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with logo and branding
            HStack(spacing: 8) {
                WorldCreditLogo(size: 24)
                    .opacity(badgeData.isUnverified ? 0.5 : 1.0)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("World Credit")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(theme.textColor)
                    
                    Text(badgeData.isUnverified ? "Unverified" : "Trust Score")
                        .font(.caption2)
                        .foregroundColor(theme.secondaryTextColor)
                }
                
                Spacer()
                
                // Tier badge (or "GET VERIFIED →" if unverified)
                if badgeData.isUnverified {
                    Text("GET VERIFIED →")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.gray)
                        )
                } else {
                    Text(badgeData.tierType.rawValue.uppercased())
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(badgeData.tierType.color)
                        )
                }
            }
            
            // Large score display (or "Not Verified" if unverified)
            VStack(alignment: .leading, spacing: 4) {
                if badgeData.isUnverified {
                    Text("Not Verified")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textColor.opacity(0.5))
                } else {
                    Text("\(badgeData.worldScore)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(effectiveTierColor)
                    
                    Text("out of 100")
                        .font(.caption)
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
            
            if !badgeData.isUnverified {
                // Tier indicator bar (only for verified users)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(badgeData.tierType.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(theme.textColor)
                        
                        Spacer()
                        
                        Text(tierRange(for: badgeData.tierType))
                            .font(.caption)
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.borderColor)
                                .frame(height: 4)
                            
                            // Progress fill
                            RoundedRectangle(cornerRadius: 2)
                                .fill(badgeData.tierType.color)
                                .frame(
                                    width: geometry.size.width * progressPercentage(for: badgeData),
                                    height: 4
                                )
                        }
                    }
                    .frame(height: 4)
                }
            }
            
            if showUserInfo {
                Divider()
                    .background(theme.borderColor)
                
                // User info
                VStack(alignment: .leading, spacing: 2) {
                    if let displayName = badgeData.displayName, !displayName.isEmpty {
                        Text(displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(theme.textColor)
                            .lineLimit(1)
                    }
                    
                    Text("@\(badgeData.handle)")
                        .font(.caption)
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .frame(width: width)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(theme.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .stroke(effectiveTierColor.opacity(0.2), lineWidth: theme.borderWidth)
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
    
    private func tierRange(for tierType: TierType) -> String {
        switch tierType {
        case .unrated:
            return "0"
        case .bronze:
            return "1-19"
        case .silver:
            return "20-49"
        case .gold:
            return "50-79"
        case .platinum:
            return "80+"
        }
    }
    
    private func progressPercentage(for badgeData: BadgeData) -> CGFloat {
        let score = CGFloat(badgeData.worldScore)
        let tierType = badgeData.tierType
        
        switch tierType {
        case .unrated:
            return 0.0
        case .bronze:
            return score / 19.0
        case .silver:
            return (score - 20.0) / 29.0
        case .gold:
            return (score - 50.0) / 29.0
        case .platinum:
            return min(1.0, (score - 80.0) / 20.0)
        }
    }
}

private struct LoadingContent: View {
    let theme: BadgeTheme
    let width: CGFloat?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header skeleton
            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 1) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.secondaryTextColor.opacity(0.3))
                        .frame(width: 80, height: 12)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.secondaryTextColor.opacity(0.2))
                        .frame(width: 60, height: 10)
                }
                
                Spacer()
            }
            
            // Score skeleton
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(theme.secondaryTextColor.opacity(0.3))
                    .frame(width: 80, height: 36)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.secondaryTextColor.opacity(0.2))
                    .frame(width: 60, height: 12)
            }
            
            // Progress bar skeleton
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.secondaryTextColor.opacity(0.2))
                    .frame(width: 100, height: 14)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.borderColor)
                    .frame(height: 4)
            }
        }
        .padding(16)
        .frame(width: width)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(theme.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .stroke(theme.borderColor, lineWidth: theme.borderWidth)
                )
        )
    }
}

private struct ErrorContent: View {
    let theme: BadgeTheme
    let width: CGFloat?
    let error: BadgeError?
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            Text("Unable to load")
                .font(.headline)
                .foregroundColor(theme.textColor)
            
            if let error = error {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .frame(width: width)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(theme.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .stroke(Color.orange.opacity(0.3), lineWidth: theme.borderWidth)
                )
        )
    }
}

// MARK: - Previews

struct CardBadge_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Different tiers
                HStack(spacing: 16) {
                    CardBadge(
                        badgeData: BadgeData(
                            ok: true,
                            handle: "gold_user",
                            displayName: "Jane Doe",
                            worldScore: 72,
                            tier: "Gold",
                            tierColor: "#FFD700",
                            photoUrl: nil,
                            linkedNetworks: nil,
                            profileUrl: "https://world-credit.com/gold_user",
                            categories: nil
                        ),
                        width: 180
                    )
                    
                    CardBadge(
                        badgeData: BadgeData(
                            ok: true,
                            handle: "platinum_user",
                            displayName: "Alex Chen",
                            worldScore: 95,
                            tier: "Platinum",
                            tierColor: "#00FFC8",
                            photoUrl: nil,
                            linkedNetworks: nil,
                            profileUrl: "https://world-credit.com/platinum_user",
                            categories: nil
                        ),
                        width: 180
                    )
                }
                
                // Without user info
                CardBadge(
                    badgeData: BadgeData(
                        ok: true,
                        handle: "minimal_user",
                        displayName: "Sarah K.",
                        worldScore: 45,
                        tier: "Silver",
                        tierColor: "#C0C0C0",
                        photoUrl: nil,
                        linkedNetworks: nil,
                        profileUrl: "https://world-credit.com/minimal_user",
                        categories: nil
                    ),
                    width: 200,
                    showUserInfo: false
                )
                
                // Different themes
                HStack(spacing: 16) {
                    CardBadge(
                        badgeData: BadgeData(
                            ok: true,
                            handle: "theme_test",
                            displayName: "Light Theme",
                            worldScore: 60,
                            tier: "Gold",
                            tierColor: "#FFD700",
                            photoUrl: nil,
                            linkedNetworks: nil,
                            profileUrl: "https://world-credit.com/theme_test",
                            categories: nil
                        ),
                        theme: .light,
                        width: 180
                    )
                    
                    CardBadge(
                        badgeData: BadgeData(
                            ok: true,
                            handle: "theme_test",
                            displayName: "Dark Theme",
                            worldScore: 60,
                            tier: "Gold",
                            tierColor: "#FFD700",
                            photoUrl: nil,
                            linkedNetworks: nil,
                            profileUrl: "https://world-credit.com/theme_test",
                            categories: nil
                        ),
                        theme: .dark,
                        width: 180
                    )
                }
                
                Spacer()
            }
            .padding()
        }
    }
}