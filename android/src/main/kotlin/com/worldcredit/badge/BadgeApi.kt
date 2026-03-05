package com.worldcredit.badge

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder

/**
 * Network layer for World Credit Badge API
 * Uses HttpURLConnection to keep dependencies minimal
 */
class BadgeApi {
    
    companion object {
        private const val TAG = "BadgeApi"
        private const val BASE_URL = "https://badgeapi-czne44luta-uc.a.run.app"
        private const val TIMEOUT_MS = 10000 // 10 seconds
        
        private val cache = mutableMapOf<String, BadgeData>()
        
        /** API key for authenticated access */
        internal var apiKey: String = ""
        
        /**
         * Fetch badge data for a given handle
         */
        suspend fun fetchBadgeData(handle: String): BadgeResult<BadgeData> = withContext(Dispatchers.IO) {
            try {
                // Check cache first
                cache[handle]?.let { cachedData ->
                    Log.d(TAG, "Returning cached data for handle: $handle")
                    return@withContext BadgeResult.Success(cachedData)
                }
                
                val encodedHandle = URLEncoder.encode(handle, "UTF-8")
                var urlString = "$BASE_URL?handle=$encodedHandle"
                if (apiKey.isNotEmpty()) {
                    urlString += "&key=${URLEncoder.encode(apiKey, "UTF-8")}"
                }
                
                Log.d(TAG, "Fetching badge data from: $urlString")
                
                val url = URL(urlString)
                val connection = url.openConnection() as HttpURLConnection
                
                try {
                    connection.apply {
                        requestMethod = "GET"
                        connectTimeout = TIMEOUT_MS
                        readTimeout = TIMEOUT_MS
                        setRequestProperty("User-Agent", "WorldCredit-Android-SDK/1.0")
                        setRequestProperty("Accept", "application/json")
                    }
                    
                    val responseCode = connection.responseCode
                    Log.d(TAG, "Response code: $responseCode")
                    
                    if (responseCode == HttpURLConnection.HTTP_OK) {
                        val response = connection.inputStream.use { inputStream ->
                            BufferedReader(InputStreamReader(inputStream)).use { reader ->
                                reader.readText()
                            }
                        }
                        
                        Log.d(TAG, "Response: $response")
                        
                        val badgeData = parseJsonResponse(response)
                        if (badgeData.ok) {
                            // Cache successful response
                            cache[handle] = badgeData
                            BadgeResult.Success(badgeData)
                        } else {
                            BadgeResult.Error(Exception("API returned ok: false"), "Failed to fetch badge data")
                        }
                    } else {
                        val errorStream = connection.errorStream
                        val errorMessage = if (errorStream != null) {
                            BufferedReader(InputStreamReader(errorStream)).use { reader ->
                                reader.readText()
                            }
                        } else {
                            "HTTP $responseCode"
                        }
                        
                        Log.e(TAG, "API error: $errorMessage")
                        BadgeResult.Error(Exception("HTTP $responseCode: $errorMessage"), "Network error: $responseCode")
                    }
                } finally {
                    connection.disconnect()
                }
                
            } catch (e: IOException) {
                Log.e(TAG, "Network error", e)
                BadgeResult.Error(e, "Network connection failed")
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error", e)
                BadgeResult.Error(e, "Unexpected error occurred")
            }
        }
        
        /**
         * Parse JSON response into BadgeData
         */
        private fun parseJsonResponse(jsonString: String): BadgeData {
            val json = JSONObject(jsonString)
            
            return BadgeData(
                ok = json.optBoolean("ok", false),
                handle = json.optString("handle", ""),
                displayName = json.optString("displayName", ""),
                worldScore = json.optInt("worldScore", 0),
                tier = json.optString("tier", "Unrated"),
                tierColor = json.optString("tierColor", "#4A5568"),
                photoUrl = json.optString("photoUrl").takeIf { it.isNotEmpty() },
                linkedNetworks = parseJsonArray(json.optJSONArray("linkedNetworks")),
                profileUrl = json.optString("profileUrl", ""),
                categories = parseJsonArray(json.optJSONArray("categories"))
            )
        }
        
        /**
         * Helper to parse JSON array to List<String>
         */
        private fun parseJsonArray(jsonArray: JSONArray?): List<String> {
            if (jsonArray == null) return emptyList()
            
            return (0 until jsonArray.length()).map { index ->
                jsonArray.optString(index, "")
            }.filter { it.isNotEmpty() }
        }
        
        /**
         * Clear the cache (useful for testing or memory management)
         */
        fun clearCache() {
            cache.clear()
            Log.d(TAG, "Cache cleared")
        }
        
        /**
         * Get current cache size
         */
        fun getCacheSize(): Int = cache.size
    }
}