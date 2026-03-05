package com.worldcredit.badge

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.browser.customtabs.CustomTabsIntent
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * Main public API for World Credit Badge SDK
 * 
 * Provides methods to fetch badge data and utilities for displaying badges.
 */
object WorldCreditBadge {
    
    private const val TAG = "WorldCreditBadge"
    
    /**
     * Configure the SDK with your API key. Call this before using any badge features.
     * Typically called in Application.onCreate().
     *
     * @param apiKey Your World Credit API key (e.g. "wc_live_xxx")
     */
    fun configure(apiKey: String) {
        BadgeApi.apiKey = apiKey
        Log.d(TAG, "SDK configured with API key")
    }
    
    /**
     * Fetch badge data for a given handle asynchronously
     * 
     * @param handle The user handle to fetch badge data for
     * @param callback Result callback with BadgeResult<BadgeData>
     */
    fun fetch(handle: String, callback: (BadgeResult<BadgeData>) -> Unit) {
        if (handle.isBlank()) {
            callback(BadgeResult.Error(IllegalArgumentException("Handle cannot be blank"), "Invalid handle"))
            return
        }
        
        CoroutineScope(Dispatchers.Main).launch {
            val result = BadgeApi.fetchBadgeData(handle)
            callback(result)
        }
    }
    
    /**
     * Fetch badge data for a given handle as suspend function
     * 
     * @param handle The user handle to fetch badge data for
     * @return BadgeResult<BadgeData>
     */
    suspend fun fetchSuspend(handle: String): BadgeResult<BadgeData> {
        if (handle.isBlank()) {
            return BadgeResult.Error(IllegalArgumentException("Handle cannot be blank"), "Invalid handle")
        }
        
        return BadgeApi.fetchBadgeData(handle)
    }
    
    /**
     * Open user profile URL in browser
     * Uses Chrome Custom Tabs if available, falls back to default browser
     * 
     * @param context Android context
     * @param badgeData Badge data containing the profile URL
     */
    fun openProfile(context: Context, badgeData: BadgeData) {
        openProfile(context, badgeData.profileUrl)
    }
    
    /**
     * Open a profile URL in browser
     * Uses Chrome Custom Tabs if available, falls back to default browser
     * 
     * @param context Android context
     * @param profileUrl The profile URL to open
     */
    fun openProfile(context: Context, profileUrl: String) {
        if (profileUrl.isBlank()) {
            Log.w(TAG, "Profile URL is blank, cannot open")
            return
        }
        
        try {
            val uri = Uri.parse(profileUrl)
            
            // Try to use Chrome Custom Tabs for better user experience
            try {
                val customTabsIntent = CustomTabsIntent.Builder()
                    .setShowTitle(true)
                    .setStartAnimations(context, android.R.anim.slide_in_left, android.R.anim.slide_out_right)
                    .setExitAnimations(context, android.R.anim.slide_in_left, android.R.anim.slide_out_right)
                    .build()
                
                customTabsIntent.launchUrl(context, uri)
                Log.d(TAG, "Opened profile URL in Custom Tab: $profileUrl")
            } catch (e: Exception) {
                // Fallback to default browser
                val intent = Intent(Intent.ACTION_VIEW, uri).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(intent)
                Log.d(TAG, "Opened profile URL in default browser: $profileUrl")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open profile URL: $profileUrl", e)
        }
    }
    
    /**
     * Clear the API cache
     * Useful for testing or memory management
     */
    fun clearCache() {
        BadgeApi.clearCache()
    }
    
    /**
     * Get current cache size
     * 
     * @return Number of cached badge entries
     */
    fun getCacheSize(): Int {
        return BadgeApi.getCacheSize()
    }
    
    /**
     * Validate a user handle format
     * 
     * @param handle The handle to validate
     * @return true if handle appears to be valid format
     */
    fun isValidHandle(handle: String): Boolean {
        return handle.isNotBlank() && 
               handle.length >= 3 && 
               handle.length <= 50 && 
               handle.matches(Regex("^[a-zA-Z0-9._-]+$"))
    }
    
    /**
     * Get the World Credit logo URL
     * 
     * @return Logo URL string
     */
    fun getLogoUrl(): String {
        return "https://worldcredit-c266e.web.app/WorldCreditAppLogo.png"
    }
}

/**
 * Composable hook for fetching badge data with loading state management
 * 
 * @param handle The user handle to fetch badge data for
 * @return BadgeState representing the current state (Loading, Success, Error)
 */
@Composable
fun rememberBadgeState(handle: String): BadgeState {
    var badgeState by remember(handle) { mutableStateOf<BadgeState>(BadgeState.Loading) }
    
    LaunchedEffect(handle) {
        if (handle.isBlank()) {
            badgeState = BadgeState.Error("Handle cannot be blank")
            return@LaunchedEffect
        }
        
        badgeState = BadgeState.Loading
        
        when (val result = WorldCreditBadge.fetchSuspend(handle)) {
            is BadgeResult.Success -> {
                badgeState = BadgeState.Success(result.data)
            }
            is BadgeResult.Error -> {
                badgeState = BadgeState.Error(result.message)
            }
        }
    }
    
    return badgeState
}

/**
 * Extension functions for easier usage
 */

/**
 * Get display text for score with tier
 */
fun BadgeData.getScoreDisplay(): String {
    return "$worldScore · $tier"
}

/**
 * Get short display text (just score)
 */
fun BadgeData.getShortDisplay(): String {
    return worldScore.toString()
}

/**
 * Check if badge has a photo
 */
fun BadgeData.hasPhoto(): Boolean {
    return !photoUrl.isNullOrBlank()
}