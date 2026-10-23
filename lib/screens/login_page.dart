import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../utils/validators.dart';
import '../widgets/profile_avatar.dart';
import 'terms_page.dart';

const Color muted = Color(0xFFBDBDBD);

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onLogin,
    this.isLightMode,
    this.savedProfile,
  });

  final VoidCallback onLogin;
  final bool? isLightMode;
  final UserProfile? savedProfile;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _otpController = TextEditingController();

  UserProfile? _savedProfile;
  bool _acceptedTerms = false;
  bool _hidePassword = true;
  bool _showManualPasswordForm = false;

  String? _generatedOtp;
  bool _showOtpBanner = false;
  Timer? _otpDismissTimer;

  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();

    _savedProfile = widget.savedProfile ??
        StorageService.getLastLoggedAccount() ??
        StorageService.loadUserProfile(
          const UserProfile(
            name: 'Alex Mercer',
            gamerTag: 'ShadowVault#77',
            email: 'gamer@gmail.com',
            bio: 'Casual & competitive gamer. PC & PS5 collector.',
            platform: 'All',
            avatarIndex: 0,
          ),
        );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _otpDismissTimer?.cancel();
    _backgroundController.dispose();
    _email.dispose();
    _password.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _requestOtp() {
    final code = (1000 + Random().nextInt(9000)).toString();
    setState(() {
      _generatedOtp = code;
      _showOtpBanner = true;
    });

    _otpDismissTimer?.cancel();
    _otpDismissTimer = Timer(const Duration(seconds: 25), () {
      if (mounted) {
        setState(() {
          _showOtpBanner = false;
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Security OTP generated! Check upper notification banner.'),
        backgroundColor: Color(0xFF0284C7),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _autoFillAndLogin() {
    if (_generatedOtp != null) {
      _otpController.text = _generatedOtp!;
      _verifyOtp();
    }
  }

  void _verifyOtp() {
    final input = _otpController.text.trim();
    if (_generatedOtp == null) {
      _requestOtp();
      return;
    }

    if (input == _generatedOtp) {
      setState(() {
        _showOtpBanner = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP Verified! Welcome back, ${_savedProfile?.name ?? "Gamer"}!'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 1),
        ),
      );

      widget.onLogin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP code. Please enter the 4-digit code shown above.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _formatMaskedGmail(String email) {
    if (email.isEmpty) return 'xxxx@gmail.com';
    final atIndex = email.indexOf('@');
    final domain = atIndex != -1 ? email.substring(atIndex) : '@gmail.com';
    final name = atIndex != -1 ? email.substring(0, atIndex) : email;
    if (name.length <= 2) {
      return 'xxxx$domain';
    }
    final suffix = name.substring(max(0, name.length - 2));
    return 'xxxx$suffix$domain';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept Terms & Conditions first.'),
          backgroundColor: Color(0xFF202020),
        ),
      );
      return;
    }

    final enteredEmail = _email.text.trim();
    if (_savedProfile != null && enteredEmail.isNotEmpty) {
      final updated = _savedProfile!.copyWith(email: enteredEmail);
      StorageService.saveUserProfile(updated);
    }

    widget.onLogin();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    required bool light,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: light ? const Color(0xFF94A3B8) : Colors.black54,
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: light ? const Color(0xFF0284C7) : Colors.black,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: light ? const Color(0xFFF1F5F9) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: light ? const Color(0xFFCBD5E1) : Colors.transparent,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: light ? const Color(0xFFCBD5E1) : Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: light ? const Color(0xFF0284C7) : Colors.white,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final light =
        widget.isLightMode ??
        (Theme.of(context).brightness == Brightness.light);
    final pageBg = light ? const Color(0xFFF4F7FB) : const Color(0xFF000000);
    final textColor = light ? const Color(0xFF0F172A) : Colors.white;
    final subtextColor = light ? const Color(0xFF475569) : Colors.white70;
    final panelBg = light
        ? Colors.white.withValues(alpha: 0.96)
        : const Color(0xFF101010).withValues(alpha: 0.96);
    final panelBorder = light
        ? const Color(0xFFE2E8F0)
        : Colors.white.withValues(alpha: 0.25);
    final logoBg = light ? Colors.white : const Color(0xFF171717);
    final logoBorder = light ? const Color(0xFFCBD5E1) : Colors.white70;
    final logoIconColor = light ? const Color(0xFF0284C7) : Colors.white;

    final accentColor =
        light ? const Color(0xFF0284C7) : const Color(0xFF7DD3FC);

    return Scaffold(
      backgroundColor: pageBg,
      body: Stack(
        children: [
          // Background gradient.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: light
                      ? [
                          const Color(0xFFF8FAFC),
                          const Color(0xFFEDF2F7),
                          const Color(0xFFE2E8F0),
                        ]
                      : [
                          const Color(0xFF000000),
                          const Color(0xFF181818),
                          const Color(0xFF050505),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Falling controllers and glitter.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _backgroundController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: GamingGlitterPainter(
                      progress: _backgroundController.value,
                      lightMode: light,
                    ),
                  );
                },
              ),
            ),
          ),

          // Login content.
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        // Gaming logo.
                        Center(
                          child: Container(
                            height: 88,
                            width: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: logoBg,
                              border: Border.all(color: logoBorder, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: light
                                      ? const Color(0xFF0284C7)
                                            .withValues(alpha: 0.18)
                                      : Colors.white.withValues(alpha: 0.12),
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.sports_esports_rounded,
                              color: logoIconColor,
                              size: 48,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'GAMEVAULT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'YOUR NEXT ADVENTURE STARTS HERE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 11,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Saved Account Detail Box OR Standard Email/Password Login
                        if (_savedProfile != null && !_showManualPasswordForm)
                          _buildSavedAccountBox(
                            light,
                            panelBg,
                            panelBorder,
                            textColor,
                            subtextColor,
                            accentColor,
                          )
                        else
                          _buildManualLoginForm(
                            light,
                            panelBg,
                            panelBorder,
                            textColor,
                            subtextColor,
                            accentColor,
                          ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_esports,
                              size: 15,
                              color: light
                                  ? const Color(0xFF0284C7)
                                  : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LEVEL UP YOUR GAMING EXPERIENCE',
                              style: TextStyle(
                                color: light
                                    ? const Color(0xFF64748B)
                                    : Colors.white54,
                                fontSize: 9,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Upper side OTP Banner in same design
          if (_showOtpBanner && _generatedOtp != null)
            Positioned(
              top: 10,
              left: 14,
              right: 14,
              child: SafeArea(
                child: _buildUpperOtpBanner(
                  light,
                  textColor,
                  subtextColor,
                  accentColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSavedAccountBox(
    bool light,
    Color panelBg,
    Color panelBorder,
    Color textColor,
    Color subtextColor,
    Color accentColor,
  ) {
    final profile = _savedProfile!;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: panelBorder),
        boxShadow: [
          BoxShadow(
            color: light
                ? Colors.black.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.5),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Welcome back',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() {
                    _showManualPasswordForm = true;
                  });
                },
                child: Text(
                  'Switch account',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Continue to your GameVault profile',
            style: TextStyle(
              color: light ? const Color(0xFF64748B) : muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // Logged details card: Photo + Name + xxxx Gmail details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: light ? const Color(0xFFF1F5F9) : const Color(0xFF161922),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.45),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                ProfileAvatar(
                  profile: profile,
                  radius: 28,
                  borderWidth: 2,
                  borderColor: accentColor,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              profile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SAVED',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.mail_outline_rounded,
                            size: 14,
                            color: subtextColor,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _formatMaskedGmail(profile.email),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.gamerTag,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // OTP Section inside the box
          if (_generatedOtp == null) ...[
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _requestOtp,
                icon: const Icon(Icons.lock_clock_outlined),
                label: const Text(
                  'LOGIN WITH OTP',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: light
                      ? const Color(0xFF0284C7)
                      : accentColor,
                  foregroundColor: light ? Colors.white : Colors.black,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Instant OTP will appear on the upper screen for demo verification.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subtextColor,
                  fontSize: 11,
                ),
              ),
            ),
          ] else ...[
            Text(
              'Enter 4-digit OTP:',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: light ? const Color(0xFFF1F5F9) : const Color(0xFF1E212B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor, width: 1.5),
              ),
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 14,
                ),
                cursorColor: accentColor,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: '• • • •',
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _verifyOtp,
                      icon: const Icon(Icons.login_rounded),
                      label: const Text(
                        'VERIFY & LOG IN',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: light
                            ? const Color(0xFF0284C7)
                            : accentColor,
                        foregroundColor: light ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _requestOtp,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: panelBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Resend'),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          TextButton.icon(
            onPressed: () {
              setState(() {
                _showManualPasswordForm = true;
              });
            },
            icon: const Icon(Icons.lock_outline, size: 16),
            label: const Text(
              'Sign in with password instead',
              style: TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualLoginForm(
    bool light,
    Color panelBg,
    Color panelBorder,
    Color textColor,
    Color subtextColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: panelBorder),
        boxShadow: [
          BoxShadow(
            color: light
                ? Colors.black.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.5),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_savedProfile != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showManualPasswordForm = false;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      ProfileAvatar(profile: _savedProfile!, radius: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Switch back to ${_savedProfile!.name} (OTP Login)',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 12, color: accentColor),
                    ],
                  ),
                ),
              ),
            ),

          Text(
            'Welcome back',
            style: TextStyle(
              color: textColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Sign in to explore PC and PS5 games.',
            style: TextStyle(
              color: light ? const Color(0xFF64748B) : muted,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 26),

          // Email field.
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
            decoration: _inputDecoration(
              hint: 'Gmail (e.g. user@gmail.com)',
              icon: Icons.mail_outline,
              light: light,
            ),
            validator: FormValidators.validateGmail,
          ),

          const SizedBox(height: 16),

          // Password field.
          TextFormField(
            controller: _password,
            obscureText: _hidePassword,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
            decoration: _inputDecoration(
              hint: 'Password (min 8, 1 caps, 1 symbol, no _)',
              icon: Icons.lock_outline,
              light: light,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.black,
                ),
              ),
            ),
            validator: FormValidators.validatePassword,
          ),

          const SizedBox(height: 14),

          // Terms checkbox.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _acceptedTerms,
                activeColor: light
                    ? const Color(0xFF0284C7)
                    : Colors.white,
                checkColor: light ? Colors.white : Colors.black,
                side: BorderSide(
                  color: light
                      ? const Color(0xFF64748B)
                      : Colors.white70,
                ),
                onChanged: (value) {
                  setState(() {
                    _acceptedTerms = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    children: [
                      Text(
                        'I agree to the ',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final accepted =
                              await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TermsPage(
                                    isLightMode: light,
                                  ),
                                ),
                              );

                          if (!mounted) return;

                          if (accepted == true) {
                            setState(() {
                              _acceptedTerms = true;
                            });
                          }
                        },
                        child: Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            color: light
                                ? const Color(0xFF0284C7)
                                : Colors.white,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Login button.
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: light
                    ? const Color(0xFF0284C7)
                    : Colors.white,
                foregroundColor: light ? Colors.white : Colors.black,
                elevation: 5,
                shadowColor: light
                    ? const Color(0xFF0284C7).withValues(alpha: 0.3)
                    : Colors.white24,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_rounded),
                  SizedBox(width: 10),
                  Text(
                    'LOGIN',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Demo login: enter any valid email and a password of 8+ characters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: light ? const Color(0xFF64748B) : muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpperOtpBanner(
    bool light,
    Color textColor,
    Color subtextColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: light ? Colors.white : const Color(0xFF161922),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.35),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.18),
            ),
            child: Icon(
              Icons.sports_esports_rounded,
              color: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'GAMEVAULT OTP NOTIFICATION',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 9.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(color: textColor, fontSize: 13),
                    children: [
                      const TextSpan(text: 'Code: '),
                      TextSpan(
                        text: _generatedOtp ?? '',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Tap to auto-fill',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton.icon(
            onPressed: _autoFillAndLogin,
            icon: const Icon(Icons.flash_on, size: 13),
            label: const Text(
              'AUTO-FILL',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              minimumSize: const Size(48, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            onPressed: () {
              setState(() {
                _showOtpBanner = false;
              });
            },
            icon: Icon(Icons.close, size: 16, color: subtextColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
          ),
        ],
      ),
    );
  }
}

// Animated falling gaming controllers and glitter.
class GamingGlitterPainter extends CustomPainter {
  GamingGlitterPainter({required this.progress, this.lightMode = false})
    : particles = List.generate(
        75,
        (index) => GlitterParticle(
          x: Random(index * 17 + 3).nextDouble(),
          y: Random(index * 29 + 7).nextDouble(),
          size: 1 + Random(index * 11 + 5).nextDouble() * 2.5,
          speed: 0.18 + Random(index * 13 + 9).nextDouble() * 0.55,
          drift: (Random(index * 19 + 2).nextDouble() - 0.5) * 0.035,
          isController: index % 5 == 0,
        ),
      );

  final double progress;
  final bool lightMode;
  final List<GlitterParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final yFraction = (particle.y + progress * particle.speed) % 1.0;
      final xFraction = (particle.x + progress * particle.drift) % 1.0;

      final dx = xFraction * size.width;
      final dy = yFraction * size.height;

      if (particle.isController) {
        _drawController(canvas, Offset(dx, dy), particle.size * 6);
      } else {
        final glowColor = lightMode
            ? const Color(0xFF0284C7).withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.55);
        final glowPaint = Paint()
          ..color = glowColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.drawCircle(Offset(dx, dy), particle.size, glowPaint);

        final centerColor = lightMode
            ? const Color(0xFF0284C7).withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.9);
        final centerPaint = Paint()..color = centerColor;

        canvas.drawCircle(Offset(dx, dy), particle.size * 0.35, centerPaint);
      }
    }
  }

  void _drawController(Canvas canvas, Offset center, double size) {
    final controllerColor = lightMode
        ? const Color(0xFF0284C7).withValues(alpha: 0.75)
        : Colors.white.withValues(alpha: 0.85);

    final controllerPaint = Paint()
      ..color = controllerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size * 1.65, height: size * 0.85),
      Radius.circular(size * 0.28),
    );

    canvas.drawRRect(body, controllerPaint);

    // D-pad.
    canvas.drawLine(
      center.translate(-size * 0.48, -size * 0.12),
      center.translate(-size * 0.48, size * 0.12),
      controllerPaint,
    );

    canvas.drawLine(
      center.translate(-size * 0.60, 0),
      center.translate(-size * 0.36, 0),
      controllerPaint,
    );

    // Controller buttons.
    final buttonColor = lightMode
        ? const Color(0xFF0284C7).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.9);
    final buttonPaint = Paint()
      ..color = buttonColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center.translate(size * 0.42, -size * 0.12),
      size * 0.065,
      buttonPaint,
    );

    canvas.drawCircle(
      center.translate(size * 0.57, size * 0.10),
      size * 0.065,
      buttonPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GamingGlitterPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lightMode != lightMode;
  }
}

class GlitterParticle {
  const GlitterParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.isController,
  });

  final double x;
  final double y;
  final double size;
  final double speed;
  final double drift;
  final bool isController;
}
