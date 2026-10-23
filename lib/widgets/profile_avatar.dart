import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/user_profile.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    this.radius = 24,
    this.borderWidth = 1.5,
    this.borderColor,
    this.showEditBadge = false,
    this.onTap,
  });

  final UserProfile profile;
  final double radius;
  final double borderWidth;
  final Color? borderColor;
  final bool showEditBadge;
  final VoidCallback? onTap;

  bool _isBase64Image(String path) {
    return path.startsWith('data:image') ||
        path.startsWith('base64:') ||
        (path.length > 250 &&
            !path.startsWith('http') &&
            !path.startsWith('/') &&
            !path.contains(r'\'));
  }

  Uint8List? _decodeBase64(String path) {
    try {
      final clean = path.contains(',') ? path.split(',').last : path;
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  bool _hasCustomImage() {
    final path = profile.imagePath;
    if (path == null || path.isEmpty) return false;
    if (_isBase64Image(path)) return true;
    if (path.startsWith('http://') || path.startsWith('https://')) return true;
    if (kIsWeb) return true;
    try {
      final file = File(path);
      return file.existsSync();
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarIcon = UserProfile.avatarIcons[
        profile.avatarIndex % UserProfile.avatarIcons.length];
    final avatarColor = UserProfile.avatarColors[
        profile.avatarIndex % UserProfile.avatarColors.length];

    final diameter = radius * 2;
    final effectiveBorderColor = borderColor ?? avatarColor;

    Widget avatarContent;

    if (_hasCustomImage()) {
      final path = profile.imagePath!;
      if (_isBase64Image(path)) {
        final bytes = _decodeBase64(path);
        if (bytes != null) {
          avatarContent = ClipOval(
            child: Image.memory(
              bytes,
              width: diameter,
              height: diameter,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallback(avatarIcon, avatarColor, diameter),
            ),
          );
        } else {
          avatarContent = _buildFallback(avatarIcon, avatarColor, diameter);
        }
      } else if (path.startsWith('http://') || path.startsWith('https://')) {
        avatarContent = ClipOval(
          child: Image.network(
            path,
            width: diameter,
            height: diameter,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallback(avatarIcon, avatarColor, diameter),
          ),
        );
      } else {
        avatarContent = ClipOval(
          child: kIsWeb
              ? Image.network(
                  path,
                  width: diameter,
                  height: diameter,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallback(avatarIcon, avatarColor, diameter),
                )
              : Image.file(
                  File(path),
                  width: diameter,
                  height: diameter,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallback(avatarIcon, avatarColor, diameter),
                ),
        );
      }
    } else {
      avatarContent = _buildFallback(avatarIcon, avatarColor, diameter);
    }

    final avatarWidget = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
      ),
      child: avatarContent,
    );

    if (!showEditBadge && onTap == null) {
      return avatarWidget;
    }

    Widget result = avatarWidget;

    if (showEditBadge) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: effectiveBorderColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                size: radius * 0.35,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius + 4),
        child: result,
      );
    }

    return result;
  }

  Widget _buildFallback(IconData icon, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.22),
      ),
      child: Icon(
        icon,
        size: size * 0.52,
        color: color,
      ),
    );
  }
}
