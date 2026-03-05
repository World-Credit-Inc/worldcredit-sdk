package com.worldcredit.badge.ui

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
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
import com.worldcredit.badge.getShortDisplay
import com.worldcredit.badge.rememberBadgeState
import com.worldcredit.badge.theme.BadgeColors
import com.worldcredit.badge.theme.BadgeDimensions
import com.worldcredit.badge.theme.BadgeTheme
import com.worldcredit.badge.theme.BadgeTypography

/**
 * PillBadge - Compact capsule badge with logo, score, and tier
 * More prominent than inline badge, suitable for user profiles
 * 
 * @param handle User handle to fetch and display badge for
 * @param theme Badge theme (Light, Dark, Auto)
 * @param size Badge size scaling
 * @param modifier Compose modifier
 */
@Composable
fun PillBadge(
    handle: String,
    theme: BadgeTheme = BadgeTheme.AUTO,
    size: BadgeSize = BadgeSize.MEDIUM,
    modifier: Modifier = Modifier
) {
    val badgeState = rememberBadgeState(handle)
    
    PillBadge(
        state = badgeState,
        theme = theme,
        size = size,
        modifier = modifier
    )
}

/**
 * PillBadge with direct state management
 * 
 * @param state Current badge state
 * @param theme Badge theme (Light, Dark, Auto)
 * @param size Badge size scaling
 * @param modifier Compose modifier
 */
@Composable
fun PillBadge(
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
            .clip(RoundedCornerShape(BadgeDimensions.pillHeight * sizeScale / 2))
            .background(colors.surface)
            .border(
                width = 1.dp,
                color = colors.outline,
                shape = RoundedCornerShape(BadgeDimensions.pillHeight * sizeScale / 2)
            )
            .padding(horizontal = BadgeDimensions.pillPadding * sizeScale),
        contentAlignment = Alignment.Center
    ) {
        when (state) {
            is BadgeState.Loading -> {
                PillBadgeLoading(colors = colors, sizeScale = sizeScale)
            }
            is BadgeState.Success -> {
                PillBadgeContent(
                    badgeData = state.data,
                    colors = colors,
                    sizeScale = sizeScale,
                    onClick = { WorldCreditBadge.openProfile(context, state.data) }
                )
            }
            is BadgeState.Error -> {
                PillBadgeError(colors = colors, sizeScale = sizeScale)
            }
        }
    }
}

@Composable
private fun PillBadgeContent(
    badgeData: BadgeData,
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float,
    onClick: () -> Unit
) {
    val tierColor = if (badgeData.isUnverified) Color.Gray else BadgeColors.getTierColor(badgeData.tierEnum)
    
    Row(
        horizontalArrangement = Arrangement.spacedBy(BadgeDimensions.pillSpacing * sizeScale),
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .clickable { onClick() }
            .padding(vertical = 6.dp * sizeScale)
    ) {
        // World Credit Logo
        AsyncImage(
            model = WorldCreditBadge.getLogoUrl(),
            contentDescription = "World Credit Logo",
            modifier = Modifier
                .size((BadgeDimensions.logoSize + 4.dp) * sizeScale)
                .alpha(if (badgeData.isUnverified) 0.5f else 1f)
        )
        
        // Score (or "—" if unverified)
        Text(
            text = if (badgeData.isUnverified) "—" else badgeData.getShortDisplay(),
            fontSize = BadgeTypography.scoreTextSize * sizeScale,
            fontWeight = FontWeight.Bold,
            color = if (badgeData.isUnverified) colors.onSurface.copy(alpha = 0.5f) else colors.onSurface
        )
        
        // Tier tag (or "NOT VERIFIED" if unverified)
        Box(
            modifier = Modifier
                .background(
                    color = tierColor.copy(alpha = 0.2f),
                    shape = RoundedCornerShape(8.dp * sizeScale)
                )
                .border(
                    width = 0.5.dp,
                    color = tierColor.copy(alpha = 0.6f),
                    shape = RoundedCornerShape(8.dp * sizeScale)
                )
                .padding(horizontal = 6.dp * sizeScale, vertical = 2.dp * sizeScale)
        ) {
            Text(
                text = if (badgeData.isUnverified) "NOT VERIFIED" else badgeData.tier.uppercase(),
                fontSize = BadgeTypography.tierTextSize * sizeScale,
                fontWeight = FontWeight.Bold,
                color = tierColor
            )
        }
    }
}

@Composable
private fun PillBadgeLoading(
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float
) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(BadgeDimensions.pillSpacing * sizeScale),
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.padding(vertical = 6.dp * sizeScale)
    ) {
        // Placeholder for logo
        Box(
            modifier = Modifier
                .size((BadgeDimensions.logoSize + 4.dp) * sizeScale)
                .background(
                    color = colors.surfaceVariant,
                    shape = RoundedCornerShape(4.dp * sizeScale)
                )
        )
        
        // Loading indicator
        CircularProgressIndicator(
            modifier = Modifier.size(14.dp * sizeScale),
            strokeWidth = 2.dp * sizeScale,
            color = colors.onSurfaceVariant
        )
        
        // Animated placeholder for tier
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
        
        Box(
            modifier = Modifier
                .background(
                    color = colors.surfaceVariant.copy(alpha = alpha),
                    shape = RoundedCornerShape(8.dp * sizeScale)
                )
                .padding(horizontal = 12.dp * sizeScale, vertical = 4.dp * sizeScale)
        ) {
            Text(
                text = "...",
                fontSize = BadgeTypography.tierTextSize * sizeScale,
                color = Color.Transparent
            )
        }
    }
}

@Composable
private fun PillBadgeError(
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float
) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(BadgeDimensions.pillSpacing * sizeScale),
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.padding(vertical = 6.dp * sizeScale)
    ) {
        // Error icon placeholder
        Box(
            modifier = Modifier
                .size((BadgeDimensions.logoSize + 4.dp) * sizeScale)
                .background(
                    color = Color(0xFFFF6B6B),
                    shape = RoundedCornerShape(4.dp * sizeScale)
                )
        )
        
        Text(
            text = "Error",
            fontSize = BadgeTypography.scoreTextSize * sizeScale,
            fontWeight = FontWeight.Medium,
            color = Color(0xFFFF6B6B)
        )
        
        Box(
            modifier = Modifier
                .background(
                    color = Color(0xFFFF6B6B).copy(alpha = 0.2f),
                    shape = RoundedCornerShape(8.dp * sizeScale)
                )
                .padding(horizontal = 6.dp * sizeScale, vertical = 2.dp * sizeScale)
        ) {
            Text(
                text = "ERROR",
                fontSize = BadgeTypography.tierTextSize * sizeScale,
                fontWeight = FontWeight.Bold,
                color = Color(0xFFFF6B6B)
            )
        }
    }
}

@Preview(name = "Pill Badge Success - Gold")
@Composable
private fun PillBadgeGoldPreview() {
    PillBadge(
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

@Preview(name = "Pill Badge Success - Platinum")
@Composable
private fun PillBadgePlatinumPreview() {
    PillBadge(
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

@Preview(name = "Pill Badge Loading")
@Composable
private fun PillBadgeLoadingPreview() {
    PillBadge(
        state = BadgeState.Loading,
        theme = BadgeTheme.LIGHT
    )
}

@Preview(name = "Pill Badge Error")
@Composable
private fun PillBadgeErrorPreview() {
    PillBadge(
        state = BadgeState.Error("Network error"),
        theme = BadgeTheme.LIGHT
    )
}

@Preview(name = "Pill Badge Small Size")
@Composable
private fun PillBadgeSmallPreview() {
    PillBadge(
        state = BadgeState.Success(
            BadgeData(
                ok = true,
                handle = "alexb",
                displayName = "Alex B.",
                worldScore = 45,
                tier = "Silver",
                tierColor = "#C0C0C0",
                photoUrl = null,
                linkedNetworks = listOf("twitter"),
                profileUrl = "https://worldcredit.com/alexb",
                categories = listOf("design")
            )
        ),
        theme = BadgeTheme.LIGHT,
        size = BadgeSize.SMALL
    )
}