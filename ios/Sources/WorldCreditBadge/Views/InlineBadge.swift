import SwiftUI

/// Tiny pill badge that sits inline next to text: [WC logo] 52 · Gold
public struct InlineBadge: View {
    private let handle: String
    private let email: String?
    private let theme: BadgeTheme
    private let size: BadgeSize
    
    @StateObject private var dataModel: BadgeDataModel
    
    /// Initialize with handle and optional customization
    /// - Parameters:
    ///   - handle: User handle to display badge for
    ///   - theme: Visual theme (default: automatic)
    ///   - size: Badge size (default: small)
    public init(
        handle: String = "",
        email: String? = nil,
        theme: BadgeTheme = .automatic,
        size: BadgeSize = .sm
    ) {
        self.handle = handle
        self.email = email
        self.theme = theme
        self.size = size
        self._dataModel = StateObject(wrappedValue: BadgeDataModel(handle: handle, email: email))
    }
    
    /// Initialize with pre-fetched badge data
    /// - Parameters:
    ///   - badgeData: Pre-fetched badge data
    ///   - theme: Visual theme (default: automatic)
    ///   - size: Badge size (default: small)
    public init(
        badgeData: BadgeData,
        theme: BadgeTheme = .automatic,
        size: BadgeSize = .sm
    ) {
        self.handle = badgeData.handle
        self.theme = theme
        self.size = size
        self._dataModel = StateObject(wrappedValue: BadgeDataModel(handle: badgeData.handle))
        
        // Set the pre-fetched data
        DispatchQueue.main.async {
            self.dataModel.badgeData = badgeData
        }
    }
    
    public var body: some View {
        Group {
            if let badgeData = dataModel.badgeData {
                BadgeContent(badgeData: badgeData, theme: theme, size: size)
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
    
    var body: some View {
        HStack(spacing: 4) {
            // World Credit logo
            WorldCreditLogo(size: size.iconSize)
                .opacity(badgeData.isUnverified ? 0.5 : 1.0)
            
            // Score and tier text (or "Not Verified")
            if badgeData.isUnverified {
                Text("Not Verified")
                    .font(.system(size: size.rawValue * 0.6, weight: .medium))
                    .foregroundColor(theme.secondaryTextColor)
                    .lineLimit(1)
            } else {
                Text(badgeData.scoreDisplayText)
                    .font(.system(size: size.rawValue * 0.6, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(theme.backgroundColor)
                .overlay(
                    Capsule()
                        .stroke(
                            badgeData.isUnverified
                                ? Color.gray.opacity(0.3)
                                : badgeData.tierType.color.opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
        .profileTappable(badgeData)
    }
}

private struct LoadingContent: View {
    let theme: BadgeTheme
    let size: BadgeSize
    
    var body: some View {
        HStack(spacing: 4) {
            ProgressView()
                .scaleEffect(0.7)
                .frame(width: size.iconSize, height: size.iconSize)
            
            Text("•••")
                .font(.system(size: size.rawValue * 0.6, weight: .medium))
                .foregroundColor(theme.secondaryTextColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(theme.backgroundColor)
                .overlay(
                    Capsule()
                        .stroke(theme.borderColor, lineWidth: 1)
                )
        )
    }
}

private struct ErrorContent: View {
    let theme: BadgeTheme
    let size: BadgeSize
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: size.iconSize * 0.8))
            
            Text("Error")
                .font(.system(size: size.rawValue * 0.6, weight: .medium))
                .foregroundColor(theme.secondaryTextColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(theme.backgroundColor)
                .overlay(
                    Capsule()
                        .stroke(theme.borderColor, lineWidth: 1)
                )
        )
    }
}

// MARK: - Previews

struct InlineBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Sample usage in text context
            HStack {
                Text("@janedoe")
                    .font(.headline)
                InlineBadge(
                    badgeData: BadgeData(
                        ok: true,
                        handle: "janedoe",
                        displayName: "Jane Doe",
                        worldScore: 52,
                        tier: "Gold",
                        tierColor: "#FFD700",
                        photoUrl: nil,
                        linkedNetworks: nil,
                        profileUrl: "https://world-credit.com/janedoe",
                        categories: nil
                    )
                )
                Spacer()
            }
            
            // Different sizes
            VStack(alignment: .leading, spacing: 8) {
                ForEach(BadgeSize.allCases, id: \.rawValue) { size in
                    HStack {
                        Text("Size \(size.rawValue, specifier: "%.0f"):")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        InlineBadge(
                            badgeData: BadgeData(
                                ok: true,
                                handle: "sarah_k",
                                displayName: "Sarah K.",
                                worldScore: 85,
                                tier: "Platinum",
                                tierColor: "#00FFC8",
                                photoUrl: nil,
                                linkedNetworks: nil,
                                profileUrl: "https://world-credit.com/sarah_k",
                                categories: nil
                            ),
                            size: size
                        )
                        Spacer()
                    }
                }
            }
            
            // Different themes
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Light:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    InlineBadge(
                        badgeData: BadgeData(
                            ok: true,
                            handle: "testuser",
                            displayName: "Test User",
                            worldScore: 25,
                            tier: "Silver",
                            tierColor: "#C0C0C0",
                            photoUrl: nil,
                            linkedNetworks: nil,
                            profileUrl: "https://world-credit.com/testuser",
                            categories: nil
                        ),
                        theme: .light
                    )
                    Spacer()
                }
                
                HStack {
                    Text("Dark:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    InlineBadge(
                        badgeData: BadgeData(
                            ok: true,
                            handle: "testuser",
                            displayName: "Test User",
                            worldScore: 25,
                            tier: "Silver",
                            tierColor: "#C0C0C0",
                            photoUrl: nil,
                            linkedNetworks: nil,
                            profileUrl: "https://world-credit.com/testuser",
                            categories: nil
                        ),
                        theme: .dark
                    )
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding()
    }
}