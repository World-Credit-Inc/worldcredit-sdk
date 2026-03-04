package com.worldcredit.badge.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.worldcredit.badge.BadgeTier

/**
 * Theme configuration for World Credit badges
 */
enum class BadgeTheme {
    LIGHT, DARK, AUTO;
    
    @Composable
    fun isDark(): Boolean = when (this) {
        LIGHT -> false
        DARK -> true
        AUTO -> isSystemInDarkTheme()
    }
}

/**
 * Color scheme for badges
 */
object BadgeColors {
    
    // Tier colors (always the same regardless of theme)
    val bronze = Color(0xFFCD7F32)
    val silver = Color(0xFFC0C0C0)
    val gold = Color(0xFFFFD700)
    val platinum = Color(0xFF00FFC8)
    val unrated = Color(0xFF4A5568)
    
    // Dark theme colors
    object Dark {
        val background = Color(0xFF0A1128)
        val surface = Color(0xFF1A1A2E)
        val surfaceVariant = Color(0xFF2A2A3E)
        val onBackground = Color(0xFFFFFFFF)
        val onSurface = Color(0xFFE0E0E0)
        val onSurfaceVariant = Color(0xFFB0B0B0)
        val outline = Color(0xFF404040)
    }
    
    // Light theme colors
    object Light {
        val background = Color(0xFFFFFFFF)
        val surface = Color(0xFFFAFAFA)
        val surfaceVariant = Color(0xFFF5F5F5)
        val onBackground = Color(0xFF1A1A1A)
        val onSurface = Color(0xFF2A2A2A)
        val onSurfaceVariant = Color(0xFF5A5A5A)
        val outline = Color(0xFFE0E0E0)
    }
    
    /**
     * Get tier color for a given tier
     */
    fun getTierColor(tier: BadgeTier): Color = when (tier) {
        BadgeTier.BRONZE -> bronze
        BadgeTier.SILVER -> silver
        BadgeTier.GOLD -> gold
        BadgeTier.PLATINUM -> platinum
        BadgeTier.UNRATED -> unrated
    }
    
    /**
     * Get colors for a given theme
     */
    @Composable
    fun forTheme(theme: BadgeTheme): BadgeColorScheme {
        return if (theme.isDark()) {
            BadgeColorScheme(
                background = Dark.background,
                surface = Dark.surface,
                surfaceVariant = Dark.surfaceVariant,
                onBackground = Dark.onBackground,
                onSurface = Dark.onSurface,
                onSurfaceVariant = Dark.onSurfaceVariant,
                outline = Dark.outline
            )
        } else {
            BadgeColorScheme(
                background = Light.background,
                surface = Light.surface,
                surfaceVariant = Light.surfaceVariant,
                onBackground = Light.onBackground,
                onSurface = Light.onSurface,
                onSurfaceVariant = Light.onSurfaceVariant,
                outline = Light.outline
            )
        }
    }
}

/**
 * Color scheme data class
 */
data class BadgeColorScheme(
    val background: Color,
    val surface: Color,
    val surfaceVariant: Color,
    val onBackground: Color,
    val onSurface: Color,
    val onSurfaceVariant: Color,
    val outline: Color
)

/**
 * Typography and sizing for badges
 */
object BadgeTypography {
    val scoreTextSize = 14.sp
    val tierTextSize = 10.sp
    val displayNameSize = 12.sp
    val labelTextSize = 10.sp
    
    val cardScoreSize = 24.sp
    val cardTierSize = 14.sp
    val cardDisplayNameSize = 16.sp
    val cardLabelSize = 12.sp
}

object BadgeDimensions {
    // Inline badge
    val inlineHeight = 20.dp
    val inlinePadding = 6.dp
    val inlineSpacing = 4.dp
    
    // Pill badge
    val pillHeight = 28.dp
    val pillPadding = 8.dp
    val pillSpacing = 6.dp
    
    // Card badge
    val cardWidth = 200.dp
    val cardHeight = 120.dp
    val cardPadding = 16.dp
    val cardSpacing = 8.dp
    
    // Shield badge
    val shieldSize = 24.dp
    val shieldDotSize = 8.dp
    
    // Common
    val cornerRadius = 12.dp
    val logoSize = 16.dp
    val elevation = 2.dp
}