import 'package:flutter/material.dart';

class SmartProductImage extends StatelessWidget {
  final String? imageUrl;
  final String category;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double borderRadius;

  const SmartProductImage({
    super.key,
    required this.imageUrl,
    this.category = 'General',
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Determine Fallback Data (Icon & Color) based on Category
    final fallback = _getFallbackData(context, category);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: width,
        color: fallback.backgroundColor, // Background while loading or if fails
        child: Image.network(
          imageUrl ?? '',
          fit: fit,
          height: height,
          width: width,
          // 2. Smooth Fade-in on Load
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: child,
            );
          },
          // 3. Loading Builder (show fallback behind)
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: Icon(
                fallback.icon,
                color: fallback.iconColor.withValues(alpha: 0.5),
                size: (width != null) ? width! * 0.4 : 30, // Scale icon
              ),
            );
          },
          // 4. Error Builder (show fallback)
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    fallback.icon,
                    color: fallback.iconColor,
                    size: (width != null) ? width! * 0.5 : 40,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _FallbackData _getFallbackData(BuildContext context, String category) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Normalize category string
    final cat = category.toLowerCase();

    IconData icon = Icons.medication; // Default
    Color baseColor = Colors.blue;

    if (cat.contains('medicine') ||
        cat.contains('tablet') ||
        cat.contains('syrup')) {
      icon = Icons.medication_liquid;
      baseColor = Colors.teal;
    } else if (cat.contains('device') ||
        cat.contains('equipment') ||
        cat.contains('thermometer')) {
      icon = Icons.medical_services_outlined;
      baseColor = Colors.indigo;
    } else if (cat.contains('baby') || cat.contains('care')) {
      icon = Icons.child_care;
      baseColor = Colors.pink;
    } else if (cat.contains('vitamin') || cat.contains('supplement')) {
      icon = Icons.local_florist;
      baseColor = Colors.orange;
    } else if (cat.contains('personal') || cat.contains('hygiene')) {
      icon = Icons.clean_hands;
      baseColor = Colors.cyan;
    }

    // Adapt colors for Dark/Light mode
    return _FallbackData(
      icon: icon,
      iconColor: isDark ? baseColor.withValues(alpha: 0.8) : baseColor,
      backgroundColor: isDark
          ? baseColor.withValues(alpha: 0.15)
          : baseColor.withValues(alpha: 0.1),
    );
  }
}

class _FallbackData {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  _FallbackData({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}
