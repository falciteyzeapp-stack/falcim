import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CoralButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;
  final double? width;

  const CoralButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary,
            side: const BorderSide(color: AppTheme.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _buildChild(),
        ),
      );
    }
    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? AppTheme.coralGradient
              : const LinearGradient(
                  colors: [Color(0xFF5D3030), Color(0xFF3D2020)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: Size(width ?? double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _buildChild(),
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Text(text),
        ],
      );
    }
    return Text(text);
  }
}

class SocialButton extends StatelessWidget {
  final String text;
  final Widget logo;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.text,
    required this.logo,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF2D1515),
          foregroundColor: AppTheme.textPrimary,
          side: const BorderSide(color: Color(0xFF5D3030)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logo,
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Cinzel',
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
