/// Shield badge widget - minimal logo with colored checkmark dot
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../badge_data.dart';
import '../badge_theme.dart';
import '../world_credit_badge.dart';

/// Minimal shield badge: just logo + colored checkmark dot
/// Perfect for compact spaces where you need verification status only
class WCShieldBadge extends StatefulWidget {
  /// The World Credit handle to display (optional if email is provided)
  final String handle;

  /// Email address for lookup (preferred over handle for B2B integrations)
  final String? email;
  
  /// Badge theme (auto-detects if null)
  final WCBadgeTheme? theme;
  
  /// Badge size
  final WCBadgeSize size;
  
  /// Whether to show a tooltip with score and tier on hover/long press
  final bool showTooltip;
  
  /// Position of the checkmark dot relative to the logo
  final ShieldDotPosition dotPosition;
  
  /// Custom logo URL (uses default World Credit logo if null)
  final String? logoUrl;
  
  /// Called when badge is tapped (overrides default profile URL opening)
  final VoidCallback? onTap;

  const WCShieldBadge({
    super.key,
    this.handle = '',
    this.email,
    this.theme,
    this.size = WCBadgeSize.md,
    this.showTooltip = true,
    this.dotPosition = ShieldDotPosition.bottomRight,
    this.logoUrl,
    this.onTap,
  });

  @override
  State<WCShieldBadge> createState() => _WCShieldBadgeState();
}

/// Position of the verification dot on the shield badge
enum ShieldDotPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _WCShieldBadgeState extends State<WCShieldBadge> {
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
  void didUpdateWidget(WCShieldBadge oldWidget) {
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
    final shimmerDotSize = widget.size.iconSize * 0.35;
    final shimmerOverflow = shimmerDotSize * 0.3;
    return SizedBox(
      width: widget.size.iconSize + shimmerOverflow,
      height: widget.size.iconSize + shimmerOverflow,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.size.iconSize,
            height: widget.size.iconSize,
            decoration: BoxDecoration(
              color: theme.shimmerBaseColor,
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: shimmerDotSize,
              height: shimmerDotSize,
              decoration: BoxDecoration(
                color: theme.shimmerHighlightColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.backgroundColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> getDotPosition() {
    switch (widget.dotPosition) {
      case ShieldDotPosition.topLeft:
        return {'top': 0.0, 'left': 0.0};
      case ShieldDotPosition.topRight:
        return {'top': 0.0, 'right': 0.0};
      case ShieldDotPosition.bottomLeft:
        return {'bottom': 0.0, 'left': 0.0};
      case ShieldDotPosition.bottomRight:
        return {'bottom': 0.0, 'right': 0.0};
    }
  }

  String getTooltipMessage() {
    if (_data == null) return '';
    if (_data!.isUnverified) {
      return '${_data!.displayName.isNotEmpty ? _data!.displayName : '@${_data!.handle}'}\n'
             'Not Verified';
    }
    return '${_data!.displayName.isNotEmpty ? _data!.displayName : '@${_data!.handle}'}\n'
           'World Credit Score: ${_data!.worldScore}\n'
           'Tier: ${_data!.displayTier}';
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
    final logoUrl = widget.logoUrl ?? _defaultLogoUrl;
    final dotPosition = getDotPosition();

    final dotSize = widget.size.iconSize * 0.35;
    final dotOverflow = dotSize * 0.3;

    Widget shieldWidget = GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: widget.size.iconSize + dotOverflow,
        height: widget.size.iconSize + dotOverflow,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main logo
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
                      color: theme.backgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.borderColor,
                        width: theme.borderWidth,
                      ),
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
            
            // Tier-colored verification dot (or "?" if unverified)
            Positioned(
              top: dotPosition['top'] != null ? dotPosition['top']! + dotOverflow / 2 : null,
              right: dotPosition['right'] != null ? dotPosition['right']! + dotOverflow / 2 : null,
              bottom: dotPosition['bottom'] != null ? dotPosition['bottom']! + dotOverflow / 2 : null,
              left: dotPosition['left'] != null ? dotPosition['left']! + dotOverflow / 2 : null,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: tierColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.backgroundColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: isUnverified
                    ? Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            fontSize: dotSize * 0.55,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.check,
                          size: dotSize * 0.55,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    // Wrap with tooltip if enabled
    if (widget.showTooltip) {
      shieldWidget = Tooltip(
        message: getTooltipMessage(),
        textStyle: TextStyle(
          fontSize: widget.size.fontSize * 0.8,
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.size.padding,
          vertical: widget.size.padding * 0.6,
        ),
        child: shieldWidget,
      );
    }

    return shieldWidget;
  }
}