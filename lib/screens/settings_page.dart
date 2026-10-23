import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../utils/validators.dart';
import '../widgets/profile_avatar.dart';
import 'privacy_policy_page.dart';
import 'profile_page.dart';
import 'terms_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.onLogout,
    this.isLightMode,
    this.onToggleTheme,
    required this.userProfile,
    required this.onProfileUpdated,
  });

  final VoidCallback onLogout;
  final bool? isLightMode;
  final VoidCallback? onToggleTheme;
  final UserProfile userProfile;
  final ValueChanged<UserProfile> onProfileUpdated;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _cacheSizeMb = 142;

  void _clearCache() {
    setState(() {
      _cacheSizeMb = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache successfully cleared! Freed 142 MB storage.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showChangePasswordDialog(
    Color panelBg,
    Color textColor,
    Color subtextColor,
    Color accentColor,
    Color borderColor,
  ) {
    final currentPass = TextEditingController();
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: panelBg,
          title: Text(
            'Change Password',
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPass,
                    obscureText: true,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Current password',
                      labelStyle: TextStyle(color: subtextColor),
                      prefixIcon: Icon(Icons.lock_outline, color: accentColor),
                    ),
                    validator: (v) =>
                        (v ?? '').isEmpty ? 'Enter current password' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPass,
                    obscureText: true,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'New password',
                      helperText: 'Min 8 chars, 1 caps, 1 symbol, no _',
                      helperStyle: TextStyle(color: subtextColor, fontSize: 11),
                      labelStyle: TextStyle(color: subtextColor),
                      prefixIcon: Icon(Icons.vpn_key_outlined, color: accentColor),
                    ),
                    validator: FormValidators.validatePassword,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPass,
                    obscureText: true,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Confirm new password',
                      labelStyle: TextStyle(color: subtextColor),
                      prefixIcon: Icon(Icons.check_circle_outline, color: accentColor),
                    ),
                    validator: (v) =>
                        v != newPass.text ? 'Passwords do not match' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Cancel', style: TextStyle(color: subtextColor)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('UPDATE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = widget.isLightMode ??
        (theme.brightness == Brightness.light);
    final pageBg = light ? const Color(0xFFF4F7FB) : Colors.black;
    final panelBg = light ? Colors.white : const Color(0xFF1E212B);
    final textColor = light ? const Color(0xFF0F172A) : Colors.white;
    final subtextColor = light
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);
    final accentColor =
        light ? const Color(0xFF0284C7) : const Color(0xFF7DD3FC);
    final borderColor = light ? const Color(0xFFE2E8F0) : const Color(0xFF2E3342);

    final avatarColor = UserProfile.avatarColors[
        widget.userProfile.avatarIndex % UserProfile.avatarColors.length];

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your preferences and GameVault account.',
              style: TextStyle(color: subtextColor),
            ),

            const SizedBox(height: 20),

            // Profile summary card
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      profile: widget.userProfile,
                      onProfileUpdated: widget.onProfileUpdated,
                      isLightMode: light,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panelBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                  boxShadow: light
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    ProfileAvatar(
                      profile: widget.userProfile,
                      radius: 27,
                      borderWidth: 2,
                      borderColor: avatarColor,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userProfile.gamerTag,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.userProfile.name,
                            style: TextStyle(fontSize: 13, color: subtextColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: accentColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _sectionHeader('THEME & DISPLAY', accentColor),

            Material(
              color: panelBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                value: light,
                activeThumbColor: const Color(0xFFF59E0B),
                activeTrackColor: const Color(0xFFFDE68A),
                title: Text(
                  'Light mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  light
                      ? 'Clean daylight theme active'
                      : 'Immersive dark theme active',
                  style: TextStyle(color: subtextColor, fontSize: 12),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (light ? const Color(0xFFF59E0B) : accentColor)
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    light ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: light ? const Color(0xFFF59E0B) : accentColor,
                    size: 20,
                  ),
                ),
                onChanged: widget.onToggleTheme != null
                    ? (_) => widget.onToggleTheme!()
                    : null,
              ),
            ),

            const SizedBox(height: 22),

            _sectionHeader('ACCOUNT & SECURITY', accentColor),

            Material(
              color: panelBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person_outline, color: accentColor),
                    title: Text('Edit Profile', style: TextStyle(color: textColor)),
                    subtitle: Text(
                      'Avatar, display name and gamer bio',
                      style: TextStyle(color: subtextColor, fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subtextColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(
                            profile: widget.userProfile,
                            onProfileUpdated: widget.onProfileUpdated,
                            isLightMode: light,
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: borderColor),
                  ListTile(
                    leading: Icon(Icons.lock_reset, color: accentColor),
                    title: Text('Change Password', style: TextStyle(color: textColor)),
                    subtitle: Text(
                      'Update your login credentials',
                      style: TextStyle(color: subtextColor, fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subtextColor),
                    onTap: () => _showChangePasswordDialog(
                      panelBg,
                      textColor,
                      subtextColor,
                      accentColor,
                      borderColor,
                    ),
                  ),
                  Divider(height: 1, color: borderColor),
                  ListTile(
                    leading: Icon(Icons.cleaning_services_outlined, color: accentColor),
                    title: Text('Clear App Cache', style: TextStyle(color: textColor)),
                    subtitle: Text(
                      _cacheSizeMb > 0
                          ? '$_cacheSizeMb MB cached image data'
                          : 'Cache is empty (0 MB)',
                      style: TextStyle(color: subtextColor, fontSize: 12),
                    ),
                    trailing: TextButton(
                      onPressed: _cacheSizeMb > 0 ? _clearCache : null,
                      child: Text(
                        'CLEAR',
                        style: TextStyle(
                          color: _cacheSizeMb > 0 ? accentColor : subtextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            _sectionHeader('LEGAL & ABOUT', accentColor),

            Material(
              color: panelBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.description_outlined, color: accentColor),
                    title: Text(
                      'Terms & Conditions',
                      style: TextStyle(color: textColor),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subtextColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TermsPage(isLightMode: light),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: borderColor),
                  ListTile(
                    leading: Icon(Icons.privacy_tip_outlined, color: accentColor),
                    title: Text(
                      'Privacy Policy',
                      style: TextStyle(color: textColor),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subtextColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PrivacyPolicyPage(isLightMode: light),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: borderColor),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: accentColor),
                    title: Text('App Version', style: TextStyle(color: textColor)),
                    trailing: Text(
                      'v2.4.0 (Build 2026)',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      light ? const Color(0xFFDC2626) : Colors.redAccent,
                  side: BorderSide(
                    color: light
                        ? const Color(0xFFFCA5A5)
                        : Colors.redAccent.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      backgroundColor: panelBg,
                      title: Text(
                        'Log out?',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'Return to the login screen?',
                        style: TextStyle(color: subtextColor),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, false),
                          child: Text('Cancel', style: TextStyle(color: subtextColor)),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          child: const Text('Log out'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) widget.onLogout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('LOG OUT'),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                'GAMEVAULT • OFFICIAL DEMO 2026',
                style: TextStyle(
                  color: subtextColor,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}
