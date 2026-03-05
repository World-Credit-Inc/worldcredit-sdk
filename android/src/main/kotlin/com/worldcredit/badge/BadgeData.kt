package com.worldcredit.badge

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

/**
 * Badge data response from the World Credit Badge API
 */
@Parcelize
data class BadgeData(
    val ok: Boolean,
    val verified: Boolean = true,
    val handle: String,
    val displayName: String,
    val worldScore: Int,
    val tier: String,
    val tierColor: String,
    val photoUrl: String?,
    val linkedNetworks: List<String>,
    val profileUrl: String,
    val categories: List<String>
) : Parcelable {
    
    /**
     * Whether the user is unverified (no World Credit account)
     */
    val isUnverified: Boolean
        get() = !verified
    
    /**
     * Get the tier enum based on the score
     */
    val tierEnum: BadgeTier
        get() = when (worldScore) {
            in 80..Int.MAX_VALUE -> BadgeTier.PLATINUM
            in 50..79 -> BadgeTier.GOLD
            in 20..49 -> BadgeTier.SILVER
            in 1..19 -> BadgeTier.BRONZE
            else -> BadgeTier.UNRATED
        }
}

/**
 * Badge tier with associated colors and score ranges
 */
enum class BadgeTier(
    val tierName: String,
    val colorHex: String,
    val scoreRange: IntRange
) {
    BRONZE("Bronze", "#CD7F32", 1..19),
    SILVER("Silver", "#C0C0C0", 20..49),
    GOLD("Gold", "#FFD700", 50..79),
    PLATINUM("Platinum", "#00FFC8", 80..Int.MAX_VALUE),
    UNRATED("Unrated", "#4A5568", 0..0);
    
    companion object {
        fun fromScore(score: Int): BadgeTier {
            return when (score) {
                in PLATINUM.scoreRange -> PLATINUM
                in GOLD.scoreRange -> GOLD
                in SILVER.scoreRange -> SILVER
                in BRONZE.scoreRange -> BRONZE
                else -> UNRATED
            }
        }
    }
}

/**
 * Badge size options
 */
enum class BadgeSize(val scale: Float) {
    SMALL(0.8f),
    MEDIUM(1.0f),
    LARGE(1.2f)
}

/**
 * Loading state for async badge operations
 */
sealed class BadgeState {
    object Loading : BadgeState()
    data class Success(val data: BadgeData) : BadgeState()
    data class Error(val message: String) : BadgeState()
}

/**
 * Result wrapper for badge API calls
 */
sealed class BadgeResult<out T> {
    data class Success<T>(val data: T) : BadgeResult<T>()
    data class Error(val exception: Throwable, val message: String = exception.message ?: "Unknown error") : BadgeResult<Nothing>()
}