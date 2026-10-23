import 'package:flutter/material.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.gamerTag,
    required this.email,
    required this.bio,
    required this.platform,
    this.avatarIndex = 0,
    this.imagePath,
  });

  final String name;
  final String gamerTag;
  final String email;
  final String bio;
  final String platform;
  final int avatarIndex;
  final String? imagePath;

  UserProfile copyWith({
    String? name,
    String? gamerTag,
    String? email,
    String? bio,
    String? platform,
    int? avatarIndex,
    String? imagePath,
    bool clearImagePath = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gamerTag: gamerTag ?? this.gamerTag,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      platform: platform ?? this.platform,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gamerTag': gamerTag,
      'email': email,
      'bio': bio,
      'platform': platform,
      'avatarIndex': avatarIndex,
      'imagePath': imagePath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Alex Mercer',
      gamerTag: json['gamerTag'] as String? ?? 'ShadowVault#77',
      email: json['email'] as String? ?? 'gamer@gmail.com',
      bio: json['bio'] as String? ?? 'Casual & competitive gamer. PC & PS5 collector.',
      platform: json['platform'] as String? ?? 'All',
      avatarIndex: (json['avatarIndex'] as num?)?.toInt() ?? 0,
      imagePath: json['imagePath'] as String?,
    );
  }

  static const List<IconData> avatarIcons = [
    Icons.person,
    Icons.sports_esports,
    Icons.shield_outlined,
    Icons.flash_on,
    Icons.military_tech,
    Icons.smart_toy,
    Icons.rocket_launch,
    Icons.videogame_asset,
  ];

  static const List<Color> avatarColors = [
    Color(0xFF0284C7),
    Color(0xFF7DD3FC),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF6366F1),
  ];
}
