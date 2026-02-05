import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 90});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [const Color(0xFF4CA6A8), const Color(0xFF2C5354)] // More vibrant in dark mode
              : [const Color(0xFF6AA39B), const Color(0xFF4CA6A8)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF6AA39B) : const Color(0xFF6AA39B)).withValues(alpha: isDark ? 0.4 : 0.3),
            blurRadius: isDark ? 20 : 15, // Glow effect in dark mode
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glassmorphism overlay
          if (isDark)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.25),
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          // Subtle background pattern
          Positioned(
            right: -size * 0.1,
            top: -size * 0.1,
            child: Icon(
              Icons.health_and_safety,
              size: size * 0.8,
              color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.05),
            ),
          ),
          // Main Icon with glow
          Center(
            child: Container(
              padding: EdgeInsets.all(size * 0.2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.4 : 0.2),
                  width: 1.5,
                ),
                boxShadow: isDark ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 10,
                  )
                ] : [],
              ),
              child: Icon(
                Icons.medical_services_rounded,
                size: size * 0.45,
                color: Colors.white,
              ),
            ),
          ),
          // Reflective highlight
          Positioned(
            left: size * 0.1,
            top: size * 0.1,
            child: Container(
              width: size * 0.4,
              height: size * 0.05,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.5 : 0.3),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
