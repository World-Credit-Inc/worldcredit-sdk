/// Pill badge widget - compact capsule with logo, score, and tier
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../badge_data.dart';
import '../badge_theme.dart';
import '../world_credit_badge.dart';

/// Compact pill badge: [logo] [score] [tier tag]
/// More prominent than inline, suitable for profiles and cards
class WCPillBadge extends StatefulWidget {
  /// The World Credit handle to display (optional if email is provided)
  final String handle;

  /// Email address for lookup (preferred over handle for B2B integrations)
  final String? email;
  
  /// Badge theme (auto-detects if null)
  final WCBadgeTheme? theme;
  
  /// Badge size
  final WCBadgeSize size;
  
  /// Whether to show the tier tag
  final bool showTier;
  
  /// Whether to show the display name
  final bool showDisplayName;
  
  
  /// Called when badge is tapped (overrides default profile URL opening)
  final VoidCallback? onTap;

  const WCPillBadge({
    super.key,
    this.handle = '',
    this.email,
    this.theme,
    this.size = WCBadgeSize.md,
    this.showTier = true,
    this.showDisplayName = false,
    this.onTap,
  });

  @override
  State<WCPillBadge> createState() => _WCPillBadgeState();
}

class _WCPillBadgeState extends State<WCPillBadge> {
  BadgeData? _data;
  bool _isLoading = true;
  bool _hasError = false;

  static const String _defaultLogoUrl = 'https://worldcredit-c266e.web.app/WorldCreditAppLogo.png';

  @override
  void initState() {
    super.initState();
    _loadBadgeData();
  }

  @override
  void didUpdateWidget(WCPillBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.handle != widget.handle || oldWidget.email != widget.email) {
      _loadBadgeData();
    }
  }

  Future<void> _loadBadgeData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await WorldCreditBadge.fetch(widget.handle, email: widget.email);
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (_data?.profileUrl.isNotEmpty == true) {
      launchUrl(Uri.parse(_data!.profileUrl));
    }
  }

  Widget _buildShimmer(WCBadgeTheme theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.size.padding,
        vertical: widget.size.padding * 0.7,
      ),
      decoration: BoxDecoration(
        color: theme.shimmerBaseColor,
        borderRadius: BorderRadius.circular(widget.size.iconSize),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.size.iconSize,
            height: widget.size.iconSize,
            decoration: BoxDecoration(
              color: theme.shimmerHighlightColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: widget.size.padding),
          Container(
            width: 32,
            height: widget.size.fontSize,
            decoration: BoxDecoration(
              color: theme.shimmerHighlightColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (widget.showTier) ...[
            SizedBox(width: widget.size.padding),
            Container(
              width: 48,
              height: widget.size.fontSize * 1.2,
              decoration: BoxDecoration(
                color: theme.shimmerHighlightColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? WCBadgeTheme.auto(context);
    
    // Return empty widget on error to not break host app UI
    if (_hasError) return const SizedBox.shrink();
    
    // Show shimmer while loading
    if (_isLoading || _data == null) {
      return _buildShimmer(theme);
    }

    final isUnverified = _data!.isUnverified;
    final tierColor = isUnverified ? Colors.grey : _data!.tierColorAsColor;
    const logoUrl = _defaultLogoUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(widget.size.iconSize),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.size.padding,
            vertical: widget.size.padding * 0.7,
          ),
          decoration: theme.containerDecoration.copyWith(
            borderRadius: BorderRadius.circular(widget.size.iconSize),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // World Credit logo
              Opacity(
                opacity: isUnverified ? 0.5 : 1.0,
                child: SizedBox(
                  width: widget.size.iconSize,
                  height: widget.size.iconSize,
                  child: CachedNetworkImage(
                    imageUrl: logoUrl,
                    fadeInDuration: const Duration(milliseconds: 200),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified,
                        size: widget.size.iconSize * 0.6,
                        color: tierColor,
                      ),
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              SizedBox(width: widget.size.padding),
              
              // Content column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display name (if enabled)
                  if (widget.showDisplayName && _data!.displayName.isNotEmpty) ...[
                    Text(
                      _data!.displayName,
                      style: theme.getSecondaryTextStyle(widget.size),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: widget.size.padding * 0.2),
                  ],
                  
                  // Score and tier row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // World score (or "—" if unverified)
                      Text(
                        isUnverified ? '—' : _data!.worldScore.toString(),
                        style: theme.getScoreTextStyle(widget.size).copyWith(
                          color: isUnverified
                              ? theme.getScoreTextStyle(widget.size).color?.withValues(alpha: 0.5)
                              : null,
                        ),
                      ),
                      
                      if (widget.showTier) ...[
                        SizedBox(width: widget.size.padding),
                        
                        // Tier tag (or "NOT VERIFIED" if unverified)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.size.padding * 0.8,
                            vertical: widget.size.padding * 0.3,
                          ),
                          decoration: isUnverified
                              ? theme.getTierDecoration(Colors.grey)
                              : theme.getTierDecoration(tierColor),
                          child: Text(
                            isUnverified ? 'NOT VERIFIED' : _data!.displayTier,
                            style: isUnverified
                                ? theme.getTierTextStyle(Colors.grey, widget.size)
                                : theme.getTierTextStyle(tierColor, widget.size),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}