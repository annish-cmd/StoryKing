/*
 * DEFAULT ICON
 * -----------
 * A reusable app icon component used throughout the application.
 * 
 * Features:
 * - Displays the app's "SK" logo in a circular container
 * - Customizable size parameter for different use cases
 * - Consistent styling with app's branding
 * 
 * UI elements:
 * - Circular shape with gradient background
 * - App initials "SK" displayed in center
 * - Subtle shadow effect for depth
 * - Responsive text sizing based on container size
 */

import 'package:flutter/material.dart';

class DefaultIcon extends StatelessWidget {
  final double size;

  const DefaultIcon({
    Key? key,
    this.size = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C4FFF),
            Color(0xFF4DA7FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'SK',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
