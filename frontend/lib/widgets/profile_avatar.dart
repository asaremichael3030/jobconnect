import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String initials;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;
  final VoidCallback? onEditTap;

  const ProfileAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = 96,
    this.backgroundColor,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildContent(),
          ),
          if (onEditTap != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onEditTap,
                child: Container(
                  width: size * 0.32,
                  height: size * 0.32,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: size * 0.16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) => _initialsContent(),
      );
    }
    return _initialsContent();
  }

  Widget _initialsContent() {
    return Container(
      alignment: Alignment.center,
      color: backgroundColor ?? AppColors.primary,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}