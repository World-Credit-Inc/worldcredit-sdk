import SwiftUI
import Foundation

/// Main public API for the World Credit Badge SDK
public final class WorldCreditBadge {
    
    /// Shared instance
    public static let shared = WorldCreditBadge()
    
    private let api = BadgeAPI.shared
    
    private init() {}
    
    /// Fetch badge data for a given handle using async/await
    /// - Parameter handle: The user handle to fetch badge data for
    /// - Returns: BadgeData containing user's trust information
    /// - Throws: BadgeError if the request fails
    public static func fetch(handle: String) async throws -> BadgeData {
        try await BadgeAPI.shared.fetchBadgeData(handle: handle)
    }
    
    /// Fetch badge data for a given handle using completion handler
    /// - Parameters:
    ///   - handle: The user handle to fetch badge data for
    ///   - completion: Completion handler with Result containing BadgeData or BadgeError
    public static func fetch(handle: String, completion: @escaping (Result<BadgeData, BadgeError>) -> Void) {
        BadgeAPI.shared.fetchBadgeData(handle: handle, completion: completion)
    }
    
    /// Check if badge data is cached for a handle
    /// - Parameter handle: The user handle to check
    /// - Returns: True if data is cached, false otherwise
    public static func isCached(handle: String) -> Bool {
        BadgeAPI.shared.isCached(handle: handle)
    }
    
    /// Get cached badge data if available
    /// - Parameter handle: The user handle to get cached data for
    /// - Returns: Cached BadgeData if available, nil otherwise
    public static func getCached(handle: String) -> BadgeData? {
        BadgeAPI.shared.getCached(handle: handle)
    }
    
    /// Clear all cached data
    public static func clearCache() {
        BadgeAPI.shared.clearCache()
    }
    
    /// Preload badge data for multiple handles
    /// - Parameter handles: Array of user handles to preload
    public static func preload(handles: [String]) async {
        await BadgeAPI.shared.preloadBadges(handles: handles)
    }
}

/// Observable view model for badge data
@MainActor
public final class BadgeDataModel: ObservableObject {
    @Published public var badgeData: BadgeData?
    @Published public var isLoading: Bool = false
    @Published public var error: BadgeError?
    
    private let handle: String
    private let api = BadgeAPI.shared
    
    public init(handle: String) {
        self.handle = handle
        loadData()
    }
    
    /// Load badge data for the configured handle
    public func loadData() {
        guard !handle.isEmpty else {
            error = .invalidHandle
            return
        }
        
        // Check cache first
        if let cached = api.getCached(handle: handle) {
            badgeData = cached
            return
        }
        
        // Don't reload if already loading
        if api.isLoading(handle: handle) {
            isLoading = true
            return
        }
        
        Task {
            isLoading = true
            error = nil
            
            do {
                let data = try await api.fetchBadgeData(handle: handle)
                badgeData = data
            } catch let badgeError as BadgeError {
                error = badgeError
            } catch {
                error = .networkError(error)
            }
            
            isLoading = false
        }
    }
    
    /// Refresh badge data (force reload from network)
    public func refresh() {
        Task {
            isLoading = true
            error = nil
            
            do {
                let data = try await api.fetchBadgeData(handle: handle)
                badgeData = data
            } catch let badgeError as BadgeError {
                error = badgeError
            } catch {
                error = .networkError(error)
            }
            
            isLoading = false
        }
    }
    
    /// Open the user's World Credit profile in Safari
    public func openProfile() {
        guard let profileUrl = badgeData?.profileUrl,
              let url = URL(string: profileUrl) else { return }
        
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - Convenience Extensions

extension BadgeData {
    /// Open this user's profile in Safari
    public func openProfile() {
        guard let url = URL(string: profileUrl) else { return }
        
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    /// Formatted display text for the score and tier
    public var scoreDisplayText: String {
        "\(worldScore) · \(tierType.rawValue)"
    }
    
    /// Short display name or handle fallback
    public var shortDisplayName: String {
        if let displayName = displayName, !displayName.isEmpty {
            return displayName
        }
        return "@\(handle)"
    }
}

// MARK: - SwiftUI Integration

/// Property wrapper for easy badge data integration in SwiftUI
@propertyWrapper
public struct BadgeStore: DynamicProperty {
    @StateObject private var model: BadgeDataModel
    
    public init(handle: String) {
        self._model = StateObject(wrappedValue: BadgeDataModel(handle: handle))
    }
    
    public var wrappedValue: BadgeDataModel {
        model
    }
    
    public var projectedValue: BadgeDataModel {
        model
    }
}

/// View modifier for making any view tappable to open profile
public struct ProfileTappable: ViewModifier {
    let badgeData: BadgeData?
    
    public func body(content: Content) -> some View {
        content
            .onTapGesture {
                badgeData?.openProfile()
            }
    }
}

extension View {
    /// Make view tappable to open World Credit profile
    public func profileTappable(_ badgeData: BadgeData?) -> some View {
        self.modifier(ProfileTappable(badgeData: badgeData))
    }
}