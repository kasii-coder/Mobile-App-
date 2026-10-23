import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key, this.isLightMode});

  final bool? isLightMode;

  @override
  Widget build(BuildContext context) {
    final light =
        isLightMode ?? (Theme.of(context).brightness == Brightness.light);
    final pageBg = light ? const Color(0xFFF4F7FB) : Colors.black;
    final textColor = light ? const Color(0xFF0F172A) : Colors.white;
    final subtextColor = light ? const Color(0xFF475569) : Colors.white70;
    final accent = light
        ? const Color(0xFF0284C7)
        : Theme.of(context).colorScheme.primary;
    final borderColor = light ? const Color(0xFFCBD5E1) : Colors.white24;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        foregroundColor: textColor,
        title: Text(
          'Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: const EdgeInsets.all(22),
                  children: [
                    Text(
                      'GameVault Demo Terms',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _termSection(
                      '1. Account use',
                      'Keep your sign-in details private. This sample app uses a local demo login and does not create a real account.',
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 18),
                    _termSection(
                      '2. Game information',
                      'Game descriptions, platform labels, availability, and displayed prices are sample content and may not reflect current store listings. Check the official store before buying.',
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 18),
                    _termSection(
                      '3. Payments and purchases',
                      'No payment is taken in this demo. Buy buttons only show a message and do not complete a transaction.',
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 18),
                    _termSection(
                      '4. Favorites and settings',
                      'Favorites and settings are temporary and may reset when the app closes.',
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 18),
                    _termSection(
                      '5. Respectful use',
                      'Use the app lawfully and do not attempt to disrupt its operation. This demo is provided as-is for learning and prototyping.',
                      textColor,
                      subtextColor,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: subtextColor,
                        side: BorderSide(color: borderColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _termSection(
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
        Text(body, style: TextStyle(color: bodyColor, height: 1.5)),
      ],
    );
  }
}
