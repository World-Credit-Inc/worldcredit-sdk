/// Inline badge widget - tiny pill that sits next to text
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../badge_data.dart';
import '../badge_theme.dart';
import '../world_credit_badge.dart';

/// Tiny inline badge: [WC logo] 52 · Gold
/// Designed to sit inline next to usernames or text
class WCInlineBadge extends StatefulWidget {
  /// The World Credit handle to display
  final String handle;
  
  /// Badge theme (auto-detects if null)
  final WCBadgeTheme? theme;
  
  /// Badge size
  final WCBadgeSize size;
  
  /// Whether to show the tier name
  final bool showTier;
  
  /// Custom logo URL (uses default World Credit logo if null)
  final String? logoUrl;
  
  /// Called when badge is tapped (overrides default profile URL opening)
  final VoidCallback? onTap;

  const WCInlineBadge({
    super.key,
    required this.handle,
    this.theme,
    this.size = WCBadgeSize.sm,
    this.showTier = true,
    this.logoUrl,
    this.onTap,
  });

  @override
  State<WCInlineBadge> createState() => _WCInlineBadgeState();
}

class _WCInlineBadgeState extends State<WCInlineBadge> {
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
  void didUpdateWidget(WCInlineBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.handle != widget.handle) {
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
      final data = await WorldCreditBadge.fetch(widget.handle);
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
      height: widget.size.iconSize,
      padding: EdgeInsets.symmetric(
        horizontal: widget.size.padding,
        vertical: widget.size.padding * 0.5,
      ),
      decoration: BoxDecoration(
        color: theme.shimmerBaseColor,
        borderRadius: BorderRadius.circular(widget.size.iconSize / 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.size.iconSize * 0.7,
            height: widget.size.iconSize * 0.7,
            decoration: BoxDecoration(
              color: theme.shimmerHighlightColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: widget.size.padding * 0.5),
          Container(
            width: 24,
            height: widget.size.fontSize,
            decoration: BoxDecoration(
              color: theme.shimmerHighlightColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (widget.showTier) ...[
            SizedBox(width: widget.size.padding * 0.5),
            Text(
              '·',
              style: TextStyle(
                fontSize: widget.size.fontSize,
                color: theme.textColor.withOpacity(0.3),
              ),
            ),
            SizedBox(width: widget.size.padding * 0.5),
            Container(
              width: 32,
              height: widget.size.fontSize,
              decoration: BoxDecoration(
                color: theme.shimmerHighlightColor,
                borderRadius: BorderRadius.circular(2),
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

    final tierColor = _data!.tierColorAsColor;
    final logoUrl = widget.logoUrl ?? _defaultLogoUrl;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.size.padding,
          vertical: widget.size.padding * 0.5,
        ),
        decoration: BoxDecoration(
          color: theme.backgroundColor.withOpacity(0.8),
          border: Border.all(
            color: theme.borderColor.withOpacity(0.5),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(widget.size.iconSize / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(theme.isDark ? 0.2 : 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // World Credit logo
            SizedBox(
              width: widget.size.iconSize * 0.7,
              height: widget.size.iconSize * 0.7,
              child: CachedNetworkImage(
                imageUrl: logoUrl,
                fadeInDuration: const Duration(milliseconds: 200),
                errorWidget: (context, url, error) => Icon(
                  Icons.verified,
                  size: widget.size.iconSize * 0.7,
                  color: tierColor,
                ),
                fit: BoxFit.contain,
              ),
            ),
            
            SizedBox(width: widget.size.padding * 0.5),
            
            // World score or "Not Verified"
            if (_data!.isUnverified) ...[
              Text(
                'Not Verified',
                style: TextStyle(
                  fontSize: widget.size.fontSize * 0.9,
                  fontWeight: FontWeight.w500,
                  color: theme.textColor.withOpacity(0.5),
                  height: 1.0,
                ),
              ),
            ] else ...[
              Text(
                _data!.worldScore.toString(),
                style: TextStyle(
                  fontSize: widget.size.fontSize,
                  fontWeight: FontWeight.w600,
                  color: theme.textColor,
                  height: 1.0,
                ),
              ),
              
              if (widget.showTier) ...[
                SizedBox(width: widget.size.padding * 0.5),
                
                // Separator dot
                Text(
                  '·',
                  style: TextStyle(
                    fontSize: widget.size.fontSize,
                    color: theme.textColor.withOpacity(0.4),
                    height: 1.0,
                  ),
                ),
                
                SizedBox(width: widget.size.padding * 0.5),
                
                // Tier name
                Text(
                  _data!.displayTier,
                  style: TextStyle(
                    fontSize: widget.size.fontSize * 0.9,
                    fontWeight: FontWeight.w500,
                    color: theme.getTierTextColor(tierColor),
                    height: 1.0,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}