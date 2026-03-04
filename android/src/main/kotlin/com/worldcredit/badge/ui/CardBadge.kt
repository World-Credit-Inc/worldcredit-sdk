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
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.worldcredit.badge.BadgeData
import com.worldcredit.badge.BadgeSize
import com.worldcredit.badge.BadgeState
import com.worldcredit.badge.BadgeTier
import com.worldcredit.badge.WorldCreditBadge
import com.worldcredit.badge.hasPhoto
import com.worldcredit.badge.rememberBadgeState
import com.worldcredit.badge.theme.BadgeColors
import com.worldcredit.badge.theme.BadgeDimensions
import com.worldcredit.badge.theme.BadgeTheme
import com.worldcredit.badge.theme.BadgeTypography

/**
 * CardBadge - Rich card with logo, World Credit label, large score, and tier
 * Suitable for sidebars, profile pages, and detailed views
 * 
 * @param handle User handle to fetch and display badge for
 * @param theme Badge theme (Light, Dark, Auto)
 * @param size Badge size scaling
 * @param modifier Compose modifier
 */
@Composable
fun CardBadge(
    handle: String,
    theme: BadgeTheme = BadgeTheme.AUTO,
    size: BadgeSize = BadgeSize.MEDIUM,
    modifier: Modifier = Modifier
) {
    val badgeState = rememberBadgeState(handle)
    
    CardBadge(
        state = badgeState,
        theme = theme,
        size = size,
        modifier = modifier
    )
}

/**
 * CardBadge with direct state management
 * 
 * @param state Current badge state
 * @param theme Badge theme (Light, Dark, Auto)
 * @param size Badge size scaling
 * @param modifier Compose modifier
 */
@Composable
fun CardBadge(
    state: BadgeState,
    theme: BadgeTheme = BadgeTheme.AUTO,
    size: BadgeSize = BadgeSize.MEDIUM,
    modifier: Modifier = Modifier
) {
    val colors = BadgeColors.forTheme(theme)
    val context = LocalContext.current
    val sizeScale = size.scale
    
    Card(
        modifier = modifier
            .width(BadgeDimensions.cardWidth * sizeScale)
            .height(BadgeDimensions.cardHeight * sizeScale),
        colors = CardDefaults.cardColors(
            containerColor = colors.surface
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = BadgeDimensions.elevation
        ),
        shape = RoundedCornerShape(BadgeDimensions.cornerRadius * sizeScale)
    ) {
        when (state) {
            is BadgeState.Loading -> {
                CardBadgeLoading(colors = colors, sizeScale = sizeScale)
            }
            is BadgeState.Success -> {
                CardBadgeContent(
                    badgeData = state.data,
                    colors = colors,
                    sizeScale = sizeScale,
                    onClick = { WorldCreditBadge.openProfile(context, state.data) }
                )
            }
            is BadgeState.Error -> {
                CardBadgeError(colors = colors, sizeScale = sizeScale)
            }
        }
    }
}

@Composable
private fun CardBadgeContent(
    badgeData: BadgeData,
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float,
    onClick: () -> Unit
) {
    val tierColor = BadgeColors.getTierColor(badgeData.tierEnum)
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(BadgeDimensions.cardPadding * sizeScale),
        verticalArrangement = Arrangement.spacedBy(BadgeDimensions.cardSpacing * sizeScale)
    ) {
        // Header: Logo + World Credit label
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp * sizeScale),
            verticalAlignment = Alignment.CenterVertically
        ) {
            AsyncImage(
                model = WorldCreditBadge.getLogoUrl(),
                contentDescription = "World Credit Logo",
                modifier = Modifier.size(24.dp * sizeScale)
            )
            
            Text(
                text = "World Credit",
                fontSize = BadgeTypography.cardLabelSize * sizeScale,
                fontWeight = FontWeight.Medium,
                color = colors.onSurfaceVariant
            )
        }
        
        Spacer(modifier = Modifier.height(4.dp * sizeScale))
        
        // Main content: Score and tier
        Column(
            verticalArrangement = Arrangement.spacedBy(6.dp * sizeScale)
        ) {
            // Large score display
            Text(
                text = badgeData.worldScore.toString(),
                fontSize = BadgeTypography.cardScoreSize * sizeScale,
                fontWeight = FontWeight.Bold,
                color = colors.onSurface
            )
            
            // Tier badge
            Box(
                modifier = Modifier
                    .background(
                        color = tierColor.copy(alpha = 0.15f),
                        shape = RoundedCornerShape(12.dp * sizeScale)
                    )
                    .border(
                        width = 1.dp,
                        color = tierColor.copy(alpha = 0.4f),
                        shape = RoundedCornerShape(12.dp * sizeScale)
                    )
                    .padding(horizontal = 10.dp * sizeScale, vertical = 4.dp * sizeScale)
            ) {
                Text(
                    text = badgeData.tier.uppercase(),
                    fontSize = BadgeTypography.cardTierSize * sizeScale,
                    fontWeight = FontWeight.Bold,
                    color = tierColor
                )
            }
        }
        
        Spacer(modifier = Modifier.weight(1f))
        
        // Footer: User info
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp * sizeScale),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // User photo or placeholder
            if (badgeData.hasPhoto()) {
                AsyncImage(
                    model = badgeData.photoUrl,
                    contentDescription = "User photo",
                    modifier = Modifier
                        .size(24.dp * sizeScale)
                        .clip(CircleShape)
                )
            } else {
                Box(
                    modifier = Modifier
                        .size(24.dp * sizeScale)
                        .background(
                            color = tierColor.copy(alpha = 0.3f),
                            shape = CircleShape
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = badgeData.displayName.take(1).uppercase(),
                        fontSize = (BadgeTypography.cardTierSize * sizeScale),
                        fontWeight = FontWeight.Bold,
                        color = tierColor
                    )
                }
            }
            
            // Display name
            Text(
                text = badgeData.displayName,
                fontSize = BadgeTypography.cardDisplayNameSize * sizeScale,
                fontWeight = FontWeight.Medium,
                color = colors.onSurface,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
private fun CardBadgeLoading(
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float
) {
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
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(BadgeDimensions.cardPadding * sizeScale),
        verticalArrangement = Arrangement.spacedBy(BadgeDimensions.cardSpacing * sizeScale)
    ) {
        // Header placeholder
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp * sizeScale),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(24.dp * sizeScale)
                    .background(
                        color = colors.surfaceVariant.copy(alpha = alpha),
                        shape = RoundedCornerShape(4.dp * sizeScale)
                    )
            )
            
            Box(
                modifier = Modifier
                    .width(80.dp * sizeScale)
                    .height(12.dp * sizeScale)
                    .background(
                        color = colors.surfaceVariant.copy(alpha = alpha),
                        shape = RoundedCornerShape(6.dp * sizeScale)
                    )
            )
        }
        
        Spacer(modifier = Modifier.height(4.dp * sizeScale))
        
        // Main content placeholder
        Column(
            verticalArrangement = Arrangement.spacedBy(6.dp * sizeScale),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            CircularProgressIndicator(
                modifier = Modifier.size(32.dp * sizeScale),
                strokeWidth = 3.dp * sizeScale,
                color = colors.onSurfaceVariant
            )
            
            Text(
                text = "Loading...",
                fontSize = BadgeTypography.cardTierSize * sizeScale,
                color = colors.onSurfaceVariant.copy(alpha = alpha)
            )
        }
        
        Spacer(modifier = Modifier.weight(1f))
        
        // Footer placeholder
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp * sizeScale),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(24.dp * sizeScale)
                    .background(
                        color = colors.surfaceVariant.copy(alpha = alpha),
                        shape = CircleShape
                    )
            )
            
            Box(
                modifier = Modifier
                    .width(60.dp * sizeScale)
                    .height(16.dp * sizeScale)
                    .background(
                        color = colors.surfaceVariant.copy(alpha = alpha),
                        shape = RoundedCornerShape(8.dp * sizeScale)
                    )
            )
        }
    }
}

@Composable
private fun CardBadgeError(
    colors: BadgeColors.BadgeColorScheme,
    sizeScale: Float
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(BadgeDimensions.cardPadding * sizeScale),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Error icon
        Box(
            modifier = Modifier
                .size(48.dp * sizeScale)
                .background(
                    color = Color(0xFFFF6B6B),
                    shape = RoundedCornerShape(12.dp * sizeScale)
                ),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "!",
                fontSize = BadgeTypography.cardScoreSize * sizeScale,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
        }
        
        Spacer(modifier = Modifier.height(12.dp * sizeScale))
        
        Text(
            text = "Failed to load",
            fontSize = BadgeTypography.cardDisplayNameSize * sizeScale,
            fontWeight = FontWeight.Medium,
            color = Color(0xFFFF6B6B)
        )
        
        Text(
            text = "Tap to retry",
            fontSize = BadgeTypography.cardLabelSize * sizeScale,
            color = colors.onSurfaceVariant
        )
    }
}

@Preview(name = "Card Badge Success - Gold")
@Composable
private fun CardBadgeGoldPreview() {
    CardBadge(
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

@Preview(name = "Card Badge Success - Platinum Dark")
@Composable
private fun CardBadgePlatinumDarkPreview() {
    CardBadge(
        state = BadgeState.Success(
            BadgeData(
                ok = true,
                handle = "sarahk",
                displayName = "Sarah K.",
                worldScore = 92,
                tier = "Platinum",
                tierColor = "#00FFC8",
                photoUrl = "https://example.com/photo.jpg",
                linkedNetworks = listOf("github", "twitter"),
                profileUrl = "https://worldcredit.com/sarahk",
                categories = listOf("opensource", "ai")
            )
        ),
        theme = BadgeTheme.DARK
    )
}

@Preview(name = "Card Badge Loading")
@Composable
private fun CardBadgeLoadingPreview() {
    CardBadge(
        state = BadgeState.Loading,
        theme = BadgeTheme.LIGHT
    )
}

@Preview(name = "Card Badge Error")
@Composable
private fun CardBadgeErrorPreview() {
    CardBadge(
        state = BadgeState.Error("Network error"),
        theme = BadgeTheme.LIGHT
    )
}