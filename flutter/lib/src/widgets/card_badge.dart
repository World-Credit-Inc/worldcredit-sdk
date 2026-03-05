/// Card badge widget - rich card with detailed badge information
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../badge_data.dart';
import '../badge_theme.dart';
import '../world_credit_badge.dart';

/// Rich card badge: logo, "World Credit" label, large score, tier, and display name
/// Suitable for profile pages, sidebars, and detailed views
class WCCardBadge extends StatefulWidget {
  /// The World Credit handle to display (optional if email is provided)
  final String handle;

  /// Email address for lookup (preferred over handle for B2B integrations)
  final String? email;
  
  /// Badge theme (auto-detects if null)
  final WCBadgeTheme? theme;
  
  /// Badge size
  final WCBadgeSize size;
  
  /// Whether to show linked networks
  final bool showLinkedNetworks;
  
  /// Whether to show categories
  final bool showCategories;
  
  /// Maximum width of the card (null for unlimited)
  final double? maxWidth;
  
  /// Custom logo URL (uses default World Credit logo if null)
  final String? logoUrl;
  
  /// Called when badge is tapped (overrides default profile URL opening)
  final VoidCallback? onTap;

  const WCCardBadge({
    super.key,
    this.handle = '',
    this.email,
    this.theme,
    this.size = WCBadgeSize.lg,
    this.showLinkedNetworks = true,
    this.showCategories = false,
    this.maxWidth,
    this.logoUrl,
    this.onTap,
  });

  @override
  State<WCCardBadge> createState() => _WCCardBadgeState();
}

class _WCCardBadgeState extends State<WCCardBadge> {
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
  void didUpdateWidget(WCCardBadge oldWidget) {
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
      width: widget.maxWidth,
      padding: EdgeInsets.all(widget.size.padding * 1.5),
      decoration: BoxDecoration(
        color: theme.shimmerBaseColor,
        borderRadius: theme.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: widget.size.iconSize * 1.5,
                height: widget.size.iconSize * 1.5,
                decoration: BoxDecoration(
                  color: theme.shimmerHighlightColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: widget.size.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: widget.size.fontSize,
                      decoration: BoxDecoration(
                        color: theme.shimmerHighlightColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: widget.size.padding * 0.5),
                    Container(
                      width: 60,
                      height: widget.size.fontSize * 0.8,
                      decoration: BoxDecoration(
                        color: theme.shimmerHighlightColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: widget.size.padding * 1.5),
          // Score
          Container(
            width: 80,
            height: widget.size.fontSize * 2,
            decoration: BoxDecoration(
              color: theme.shimmerHighlightColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: widget.size.padding),
          // Tier
          Container(
            width: 60,
            height: widget.size.fontSize * 1.2,
            decoration: BoxDecoration(
              color: theme.shimmerHighlightColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
    final logoUrl = widget.logoUrl ?? _defaultLogoUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: theme.borderRadius,
        child: Container(
          width: widget.maxWidth,
          padding: EdgeInsets.all(widget.size.padding * 1.5),
          decoration: theme.containerDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row - logo and branding
              Row(
                children: [
                  // World Credit logo
                  Opacity(
                    opacity: isUnverified ? 0.5 : 1.0,
                    child: SizedBox(
                      width: widget.size.iconSize * 1.5,
                      height: widget.size.iconSize * 1.5,
                      child: CachedNetworkImage(
                        imageUrl: logoUrl,
                        fadeInDuration: const Duration(milliseconds: 200),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            color: tierColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.verified,
                            size: widget.size.iconSize,
                            color: tierColor,
                          ),
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  SizedBox(width: widget.size.padding),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display name
                        Text(
                          _data!.displayName.isNotEmpty 
                              ? _data!.displayName 
                              : '@${_data!.handle}',
                          style: theme.getScoreTextStyle(widget.size).copyWith(
                            fontSize: widget.size.fontSize * 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        SizedBox(height: widget.size.padding * 0.3),
                        
                        // World Credit label
                        Text(
                          'World Credit',
                          style: theme.getSecondaryTextStyle(widget.size),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: widget.size.padding * 1.5),
              
              // Score section
              Row(
                children: [
                  Text(
                    isUnverified ? 'Not Verified' : _data!.worldScore.toString(),
                    style: theme.getScoreTextStyle(widget.size).copyWith(
                      fontSize: widget.size.fontSize * 2.2,
                      fontWeight: FontWeight.w800,
                      color: isUnverified
                          ? theme.getScoreTextStyle(widget.size).color?.withOpacity(0.5)
                          : tierColor,
                    ),
                  ),
                  
                  SizedBox(width: widget.size.padding),
                  
                  // Tier badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.size.padding,
                      vertical: widget.size.padding * 0.5,
                    ),
                    decoration: isUnverified
                        ? theme.getTierDecoration(Colors.grey)
                        : theme.getTierDecoration(tierColor),
                    child: Text(
                      isUnverified ? 'GET VERIFIED →' : _data!.displayTier,
                      style: isUnverified
                          ? theme.getTierTextStyle(Colors.grey, widget.size)
                          : theme.getTierTextStyle(tierColor, widget.size),
                    ),
                  ),
                ],
              ),
              
              // Linked networks (if enabled and available)
              if (widget.showLinkedNetworks && _data!.linkedNetworks > 0) ...[
                SizedBox(height: widget.size.padding * 1.2),
                
                Text(
                  '${_data!.linkedNetworks} Linked Networks',
                  style: theme.getSecondaryTextStyle(widget.size).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              
              // Categories (if enabled and available)
              if (widget.showCategories && _data!.categories.isNotEmpty) ...[
                SizedBox(height: widget.size.padding * 1.2),
                
                Text(
                  'Categories',
                  style: theme.getSecondaryTextStyle(widget.size).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                SizedBox(height: widget.size.padding * 0.5),
                
                Wrap(
                  spacing: widget.size.padding * 0.5,
                  runSpacing: widget.size.padding * 0.3,
                  children: _data!.categories.map((category) {
                    final label = category['label']?.toString() ?? '';
                    final score = category['score'];
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.size.padding * 0.7,
                        vertical: widget.size.padding * 0.3,
                      ),
                      decoration: BoxDecoration(
                        color: tierColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(widget.size.padding),
                      ),
                      child: Text(
                        score != null ? '$label: $score' : label,
                        style: theme.getTierTextStyle(tierColor, widget.size).copyWith(
                          fontSize: widget.size.fontSize * 0.8,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}