import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final List<Color>? gradientColors;
  final double height;
  final double borderRadius;
  final double fontSize;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.gradientColors,
    this.height = 52,
    this.borderRadius = 16,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        const [
          AppTheme.primaryDark,
          AppTheme.primary,
        ];
    final bool isEnabled = onPressed != null && !isLoading;

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(colors: colors)
            : null,
        color: isEnabled ? null : const Color(0xFF1E1E26),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? const SpinKitThreeBounce(
                color: Colors.white,
                size: 20,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: isEnabled ? Colors.white : Colors.grey[600], size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: isEnabled ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
