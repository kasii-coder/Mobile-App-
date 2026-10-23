import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key, this.isLightMode});

  final bool? isLightMode;

  @override
  Widget build(BuildContext context) {
    final light =
        isLightMode ?? (Theme.of(context).brightness == Brightness.light);
    final pageBg = light ? const Color(0xFFF4F7FB) : Colors.black;
    final textColor = light ? const Color(0xFF0F172A) : Colors.white;
    final subtextColor = light ? const Color(0xFF475569) : Colors.white70;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        foregroundColor: textColor,
        title: Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Text(
                'GameVault Privacy Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: October 2026',
                style: TextStyle(color: subtextColor, fontSize: 13),
              ),
              const SizedBox(height: 20),
              _policySection(
                '1. Data Collection & Usage',
                'GameVault respects your gaming privacy. This app collects only necessary profile information (such as your display name, gamer tag, and local preference settings) to provide a tailored store experience.',
                textColor,
                subtextColor,
              ),
              const SizedBox(height: 18),
              _policySection(
                '2. Local Storage',
                'Your favorite games, checkout preferences, and personalized profile are stored locally on your device. We do not sell or monetize personal gaming telemetry or usage records to third-party data brokers.',
                textColor,
                subtextColor,
              ),
              const SizedBox(height: 18),
              _policySection(
                '3. Demo Payments & Financial Privacy',
                'GameVault is a demonstration showcase. No real credit card, UPI credentials, or bank authentication keys are retained or processed on remote payment servers.',
                textColor,
                subtextColor,
              ),
              const SizedBox(height: 18),
              _policySection(
                '4. YouTube Trailer Embeds',
                'Game trailers are displayed through the official YouTube player embed API. Interaction with trailers is subject to Google & YouTube Terms of Service and Privacy Guidelines.',
                textColor,
                subtextColor,
              ),
              const SizedBox(height: 18),
              _policySection(
                '5. Your Rights & Cache Clearing',
                'You may reset your profile, remove cached thumbnails, or purge your local session at any time from the GameVault Settings menu.',
                textColor,
                subtextColor,
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'GameVault Security & Privacy Team',
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
      ),
    );
  }

  Widget _policySection(
    String title,
    String body,
    Color titleColor,
    Color bodyColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: TextStyle(color: bodyColor, height: 1.6, fontSize: 14),
        ),
      ],
    );
  }
}
