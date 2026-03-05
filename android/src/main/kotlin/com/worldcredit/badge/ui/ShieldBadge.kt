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
import androidx.compose.foundation.shape.CircleShape
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
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.worldcredit.badge.BadgeData
import com.worldcredit.badge.BadgeSize
import com.worldcredit.badge.BadgeState
import com.worldcredit.badge.BadgeTier
import com.worldcredit.badge.WorldCreditBadge
import com.worldcredit.badge.rememberBadgeState
import com.worldcredit.badge.theme.BadgeColors
import com.worldcredit.badge.theme.BadgeDimensions
import com.worldcredit.badge.theme.BadgeTheme

/**
 * ShieldBadge - Minimal badge with just logo and colored checkmark dot
 * Most compact option, suitable for tight spaces and lists
 * 
 * @param handle User handle to fetch and display badge for
 * @param theme Badge theme (Light, Dark, Auto)
 * @param size Badge size scaling
 * @param modifier Compose modifier
 */
@Composable
fun ShieldBadge(
    handle: String = "",
    email: String? = null,
    theme: BadgeTheme = BadgeTheme.AUTO,
    size: BadgeSize = BadgeSize.MEDIUM,
    modifier: Modifier = Modifier
) {
    val badgeState = rememberBadgeState(handle)
    
    ShieldBadge(
        state = badgeState,
        theme = theme,
        size = size,
        modifier = modifier
    )
}

/**
 * ShieldBadge with direct state management
 * 
 * @param state Current badge state
 * @param theme Badge theme (Light, Dark, Auto)
 * @param size Badge size scaling
 * @param modifier Compose modifier
 */
@Composable
fun ShieldBadge(
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
            .size(BadgeDimensions.shieldSize * sizeScale)
            .clip(CircleShape)
            .background(colors.surface)
            .border(
                width = 1.dp,
                color = colors.outline,
                shape = CircleShape
            ),
        contentAlignment = Alignment.Center
    ) {
        when (state) {
            is BadgeState.Loading -> {
                ShieldBadgeLoading(colors = colors, sizeScale = sizeScale)
            }
            is BadgeState.Success -> {
                ShieldBadgeContent(
                    badgeData = state.data,
                    colors = colors,
                    sizeScale = sizeScale,
                    onClick = { WorldCreditBadge.openProfile(context, state.data) }
                )
            }
            is BadgeState.Error -> {
                ShieldBadgeError(colors = colors, sizeScale = sizeScale)
            }
        }
    }
}

@Composable
private fun ShieldBadgeContent(
    badgeData: BadgeData,
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float,
    onClick: () -> Unit
) {
    val tierColor = if (badgeData.isUnverified) Color.Gray else BadgeColors.getTierColor(badgeData.tierEnum)
    
    Box(
        modifier = Modifier
            .clickable { onClick() }
            .padding(4.dp * sizeScale),
        contentAlignment = Alignment.Center
    ) {
        // World Credit Logo as background
        AsyncImage(
            model = WorldCreditBadge.getLogoUrl(),
            contentDescription = "World Credit Logo",
            modifier = Modifier
                .size(16.dp * sizeScale)
                .clip(CircleShape)
                .alpha(if (badgeData.isUnverified) 0.5f else 1f)
        )
        
        // Tier color dot indicator positioned on top-right (or "?" if unverified)
        Box(
            modifier = Modifier
                .size(BadgeDimensions.shieldDotSize * sizeScale)
                .background(
                    color = tierColor,
                    shape = CircleShape
                )
                .border(
                    width = 1.dp,
                    color = colors.surface,
                    shape = CircleShape
                )
                .align(Alignment.TopEnd),
            contentAlignment = Alignment.Center
        ) {
            if (badgeData.isUnverified) {
                Text(
                    text = "?",
                    fontSize = (6 * sizeScale).sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }
        }
    }
}

@Composable
private fun ShieldBadgeLoading(
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float
) {
    CircularProgressIndicator(
        modifier = Modifier.size(12.dp * sizeScale),
        strokeWidth = 1.5.dp * sizeScale,
        color = colors.onSurfaceVariant
    )
}

@Composable
private fun ShieldBadgeError(
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float
) {
    Box(
        modifier = Modifier
            .size(16.dp * sizeScale)
            .background(
                color = Color(0xFFFF6B6B),
                shape = CircleShape
            ),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "!",
            fontSize = (10 * sizeScale).sp,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )
    }
}

/**
 * Alternative ShieldBadge that shows score on hover/press
 * More interactive version for contexts where space allows
 */
@Composable
fun InteractiveShieldBadge(
    handle: String = "",
    email: String? = null,
    theme: BadgeTheme = BadgeTheme.AUTO,
    size: BadgeSize = BadgeSize.MEDIUM,
    showScore: Boolean = false,
    modifier: Modifier = Modifier
) {
    val badgeState = rememberBadgeState(handle)
    val colors = BadgeColors.forTheme(theme)
    val context = LocalContext.current
    val sizeScale = size.scale
    
    when (badgeState) {
        is BadgeState.Success -> {
            if (showScore) {
                // Expanded view with score
                Row(
                    horizontalArrangement = Arrangement.spacedBy(4.dp * sizeScale),
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = modifier
                        .clip(RoundedCornerShape(12.dp * sizeScale))
                        .background(colors.surface)
                        .border(
                            width = 1.dp,
                            color = colors.outline,
                            shape = RoundedCornerShape(12.dp * sizeScale)
                        )
                        .clickable { WorldCreditBadge.openProfile(context, badgeState.data) }
                        .padding(horizontal = 6.dp * sizeScale, vertical = 4.dp * sizeScale)
                ) {
                    AsyncImage(
                        model = WorldCreditBadge.getLogoUrl(),
                        contentDescription = "World Credit Logo",
                        modifier = Modifier.size(16.dp * sizeScale)
                    )
                    
                    Text(
                        text = badgeState.data.worldScore.toString(),
                        fontSize = (12 * sizeScale).sp,
                        fontWeight = FontWeight.Bold,
                        color = BadgeColors.getTierColor(badgeState.data.tierEnum)
                    )
                }
            } else {
                // Compact shield view
                ShieldBadge(
                    state = badgeState,
                    theme = theme,
                    size = size,
                    modifier = modifier
                )
            }
        }
        else -> {
            // Loading or error state - always use compact view
            ShieldBadge(
                state = badgeState,
                theme = theme,
                size = size,
                modifier = modifier
            )
        }
    }
}

@Preview(name = "Shield Badge Success - Gold")
@Composable
private fun ShieldBadgeGoldPreview() {
    ShieldBadge(
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

@Preview(name = "Shield Badge Success - Platinum")
@Composable
private fun ShieldBadgePlatinumPreview() {
    ShieldBadge(
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

@Preview(name = "Shield Badge Success - Bronze")
@Composable
private fun ShieldBadgeBronzePreview() {
    ShieldBadge(
        state = BadgeState.Success(
            BadgeData(
                ok = true,
                handle = "mikej",
                displayName = "Mike J.",
                worldScore = 15,
                tier = "Bronze",
                tierColor = "#CD7F32",
                photoUrl = null,
                linkedNetworks = listOf("linkedin"),
                profileUrl = "https://worldcredit.com/mikej",
                categories = listOf("business")
            )
        ),
        theme = BadgeTheme.LIGHT
    )
}

@Preview(name = "Shield Badge Loading")
@Composable
private fun ShieldBadgeLoadingPreview() {
    ShieldBadge(
        state = BadgeState.Loading,
        theme = BadgeTheme.LIGHT
    )
}

@Preview(name = "Shield Badge Error")
@Composable
private fun ShieldBadgeErrorPreview() {
    ShieldBadge(
        state = BadgeState.Error("Network error"),
        theme = BadgeTheme.LIGHT
    )
}

@Preview(name = "Interactive Shield Badge - Expanded")
@Composable
private fun InteractiveShieldBadgeExpandedPreview() {
    InteractiveShieldBadge(
        handle = "janedoe",
        showScore = true,
        theme = BadgeTheme.LIGHT
    )
}

@Preview(name = "Interactive Shield Badge - Compact")
@Composable
private fun InteractiveShieldBadgeCompactPreview() {
    InteractiveShieldBadge(
        handle = "janedoe",
        showScore = false,
        theme = BadgeTheme.LIGHT
    )
}