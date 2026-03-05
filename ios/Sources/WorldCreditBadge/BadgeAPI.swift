import Foundation
import SwiftUI
import Combine

/// API client for fetching World Credit badge data
public final class BadgeAPI: ObservableObject {
    public static let shared = BadgeAPI()
    
    private let baseURL = "https://badgeapi-czne44luta-uc.a.run.app"
    private let session: URLSession
    private let imageCache = NSCache<NSString, UIImage>()
    
    /// API key for authenticated access
    private(set) var apiKey: String = ""
    
    /// Cache for badge data (handle -> BadgeData)
    @Published private var badgeCache: [String: BadgeData] = [:]
    
    /// Cache for loading states
    @Published private var loadingStates: [String: Bool] = [:]
    
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadRevalidatingCacheData
        config.timeoutIntervalForRequest = 15.0
        self.session = URLSession(configuration: config)
        
        // Configure image cache
        imageCache.countLimit = 100
        imageCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    /// Check if badge data is cached for a handle
    public func isCached(handle: String) -> Bool {
        badgeCache[handle] != nil
    }
    
    /// Get cached badge data if available
    public func getCached(handle: String) -> BadgeData? {
        badgeCache[handle]
    }
    
    /// Check if currently loading badge data for a handle
    public func isLoading(handle: String) -> Bool {
        loadingStates[handle] == true
    }
    
    /// Fetch badge data for a given handle
    public func fetchBadgeData(handle: String) async throws -> BadgeData {
        // Return cached data if available
        if let cached = badgeCache[handle] {
            return cached
        }
        
        // Set loading state
        await MainActor.run {
            loadingStates[handle] = true
        }
        
        defer {
            Task { @MainActor in
                loadingStates[handle] = false
            }
        }
        
        guard !handle.isEmpty else {
            throw BadgeError.invalidHandle
        }
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw BadgeError.invalidURL
        }
        
        var queryItems = [
            URLQueryItem(name: "handle", value: handle)
        ]
        if !apiKey.isEmpty {
            queryItems.append(URLQueryItem(name: "key", value: apiKey))
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw BadgeError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw BadgeError.invalidResponse
            }
            
            guard !data.isEmpty else {
                throw BadgeError.noData
            }
            
            let badgeData = try JSONDecoder().decode(BadgeData.self, from: data)
            
            // Cache the result
            await MainActor.run {
                badgeCache[handle] = badgeData
            }
            
            return badgeData
            
        } catch let error as DecodingError {
            throw BadgeError.decodingError(error)
        } catch {
            throw BadgeError.networkError(error)
        }
    }
    
    /// Fetch badge data with completion handler (for backward compatibility)
    public func fetchBadgeData(handle: String, completion: @escaping (Result<BadgeData, BadgeError>) -> Void) {
        Task {
            do {
                let data = try await fetchBadgeData(handle: handle)
                await MainActor.run {
                    completion(.success(data))
                }
            } catch let error as BadgeError {
                await MainActor.run {
                    completion(.failure(error))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(.networkError(error)))
                }
            }
        }
    }
    
    /// Load and cache the World Credit logo image
    public func loadLogo() async -> UIImage? {
        let logoURL = "https://worldcredit-c266e.web.app/WorldCreditAppLogo.png"
        let cacheKey = NSString(string: "worldcredit_logo")
        
        // Return cached image if available
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        guard let url = URL(string: logoURL) else {
            return nil
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else {
                return nil
            }
            
            // Cache the image
            imageCache.setObject(image, forKey: cacheKey)
            return image
            
        } catch {
            return nil
        }
    }
    
    /// Clear all caches
    public func clearCache() {
        badgeCache.removeAll()
        loadingStates.removeAll()
        imageCache.removeAllObjects()
    }
    
    /// Preload badge data for multiple handles
    public func preloadBadges(handles: [String]) async {
        await withTaskGroup(of: Void.self) { group in
            for handle in handles {
                group.addTask {
                    try? await self.fetchBadgeData(handle: handle)
                }
            }
        }
    }
}

/// SwiftUI wrapper for async image loading
struct AsyncImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private let api = BadgeAPI.shared
    
    func loadLogo() {
        guard image == nil && !isLoading else { return }
        
        isLoading = true
        
        Task { @MainActor in
            let loadedImage = await api.loadLogo()
            self.image = loadedImage
            self.isLoading = false
        }
    }
}

/// View for displaying the World Credit logo
struct WorldCreditLogo: View {
    let size: CGFloat
    @StateObject private var imageLoader = AsyncImageLoader()
    
    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if imageLoader.isLoading {
                ProgressView()
                    .scaleEffect(0.5)
            } else {
                // Fallback icon
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.blue)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            imageLoader.loadLogo()
        }
    }
}