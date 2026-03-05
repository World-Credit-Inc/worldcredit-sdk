package com.worldcredit.badge.ui

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.worldcredit.badge.BadgeData
import com.worldcredit.badge.BadgeSize
import com.worldcredit.badge.BadgeState
import com.worldcredit.badge.BadgeTier
import com.worldcredit.badge.WorldCreditBadge
import com.worldcredit.badge.getScoreDisplay
import com.worldcredit.badge.rememberBadgeState
import com.worldcredit.badge.theme.BadgeColors
import com.worldcredit.badge.theme.BadgeDimensions
import com.worldcredit.badge.theme.BadgeTheme
import com.worldcredit.badge.theme.BadgeTypography

/**
 * InlineBadge - Tiny pill badge that sits inline next to text
 * Format: [WC logo] 52 · Gold
 * 
 * @param handle User handle to fetch and display badge for
 * @param theme Badge theme (Light, Dark, Auto)
 * @param size Badge size scaling
 * @param modifier Compose modifier
 */
@Composable
fun InlineBadge(
    handle: String,
    theme: BadgeTheme = BadgeTheme.AUTO,
    size: BadgeSize = BadgeSize.MEDIUM,
    modifier: Modifier = Modifier
) {
    val badgeState = rememberBadgeState(handle)
    
    InlineBadge(
        state = badgeState,
        theme = theme,
        size = size,
        modifier = modifier
    )
}

/**
 * InlineBadge with direct state management
 * 
 * @param state Current badge state
 * @param theme Badge theme (Light, Dark, Auto)
 * @param size Badge size scaling
 * @param modifier Compose modifier
 */
@Composable
fun InlineBadge(
    state: BadgeState,
    theme: BadgeTheme = BadgeTheme.AUTO,
    size: BadgeSize = BadgeSize.MEDIUM,
    modifier: Modifier = Modifier
) {
    val colors = BadgeColors.forTheme(theme)
    val context = LocalContext.current
    val sizeScale = size.scale
    
    Box(
        modifier = modifier
            .height(BadgeDimensions.inlineHeight * sizeScale)
            .clip(RoundedCornerShape(BadgeDimensions.cornerRadius * sizeScale))
            .background(colors.surface)
            .padding(horizontal = BadgeDimensions.inlinePadding * sizeScale),
        contentAlignment = Alignment.Center
    ) {
        when (state) {
            is BadgeState.Loading -> {
                InlineBadgeLoading(colors = colors, sizeScale = sizeScale)
            }
            is BadgeState.Success -> {
                InlineBadgeContent(
                    badgeData = state.data,
                    colors = colors,
                    sizeScale = sizeScale,
                    onClick = { WorldCreditBadge.openProfile(context, state.data) }
                )
            }
            is BadgeState.Error -> {
                InlineBadgeError(colors = colors, sizeScale = sizeScale)
            }
        }
    }
}

@Composable
private fun InlineBadgeContent(
    badgeData: BadgeData,
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float,
    onClick: () -> Unit
) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(BadgeDimensions.inlineSpacing * sizeScale),
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.clickable { onClick() }
    ) {
        // World Credit Logo
        AsyncImage(
            model = WorldCreditBadge.getLogoUrl(),
            contentDescription = "World Credit Logo",
            modifier = Modifier
                .size(BadgeDimensions.logoSize * sizeScale)
                .alpha(if (badgeData.isUnverified) 0.5f else 1f)
        )
        
        if (badgeData.isUnverified) {
            // "Not Verified" text in muted color
            Text(
                text = "Not Verified",
                fontSize = BadgeTypography.scoreTextSize * sizeScale,
                fontWeight = FontWeight.Medium,
                color = colors.onSurfaceVariant
            )
        } else {
            // Score and tier text
            Text(
                text = badgeData.getScoreDisplay(),
                fontSize = BadgeTypography.scoreTextSize * sizeScale,
                fontWeight = FontWeight.Medium,
                color = colors.onSurface
            )
            
            // Tier color indicator
            Box(
                modifier = Modifier
                    .size(6.dp * sizeScale)
                    .background(
                        color = BadgeColors.getTierColor(badgeData.tierEnum),
                        shape = RoundedCornerShape(50)
                    )
            )
        }
    }
}

@Composable
private fun InlineBadgeLoading(
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float
) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(BadgeDimensions.inlineSpacing * sizeScale),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Placeholder for logo
        Box(
            modifier = Modifier
                .size(BadgeDimensions.logoSize * sizeScale)
                .background(
                    color = colors.surfaceVariant,
                    shape = RoundedCornerShape(4.dp * sizeScale)
                )
        )
        
        // Loading indicator
        CircularProgressIndicator(
            modifier = Modifier.size(12.dp * sizeScale),
            strokeWidth = 1.5.dp * sizeScale,
            color = colors.onSurfaceVariant
        )
        
        // Animated placeholder text
        val infiniteTransition = rememberInfiniteTransition(label = "loading")
        val alpha by infiniteTransition.animateFloat(
            initialValue = 0.3f,
            targetValue = 0.8f,
            animationSpec = infiniteRepeatable(
                animation = tween(1000, easing = LinearEasing),
                repeatMode = RepeatMode.Reverse
            ),
            label = "alpha"
        )
        
        Text(
            text = "Loading...",
            fontSize = BadgeTypography.scoreTextSize * sizeScale,
            color = colors.onSurfaceVariant.copy(alpha = alpha)
        )
    }
}

@Composable
private fun InlineBadgeError(
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float
) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(BadgeDimensions.inlineSpacing * sizeScale),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Error icon placeholder
        Box(
            modifier = Modifier
                .size(BadgeDimensions.logoSize * sizeScale)
                .background(
                    color = Color(0xFFFF6B6B),
                    shape = RoundedCornerShape(4.dp * sizeScale)
                )
        )
        
        Text(
            text = "Error",
            fontSize = BadgeTypography.scoreTextSize * sizeScale,
            color = Color(0xFFFF6B6B)
        )
    }
}

@Preview(name = "Inline Badge Success")
@Composable
private fun InlineBadgeSuccessPreview() {
    InlineBadge(
        state = BadgeState.Success(
            BadgeData(
                ok = true,
                handle = "janedoe",
                displayName = "Jane Doe",
                worldScore = 75,
                tier = "Gold",
                tierColor = "#FFD700",
                photoUrl = null,
                linkedNetworks = listOf("twitter", "linkedin"),
                profileUrl = "https://worldcredit.com/janedoe",
                categories = listOf("tech", "finance")
            )
        ),
        theme = BadgeTheme.LIGHT
    )
}

@Preview(name = "Inline Badge Loading")
@Composable
private fun InlineBadgeLoadingPreview() {
    InlineBadge(
        state = BadgeState.Loading,
        theme = BadgeTheme.LIGHT
    )
}

@Preview(name = "Inline Badge Error")
@Composable
private fun InlineBadgeErrorPreview() {
    InlineBadge(
        state = BadgeState.Error("Network error"),
        theme = BadgeTheme.LIGHT
    )
}

@Preview(name = "Inline Badge Dark")
@Composable
private fun InlineBadgeDarkPreview() {
    InlineBadge(
        state = BadgeState.Success(
            BadgeData(
                ok = true,
                handle = "sarahk",
                displayName = "Sarah K.",
                worldScore = 89,
                tier = "Platinum",
                tierColor = "#00FFC8",
                photoUrl = null,
                linkedNetworks = listOf("github"),
                profileUrl = "https://worldcredit.com/sarahk",
                categories = listOf("opensource")
            )
        ),
        theme = BadgeTheme.DARK
    )
}