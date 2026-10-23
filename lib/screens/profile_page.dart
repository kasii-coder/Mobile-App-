import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../utils/validators.dart';
import '../widgets/profile_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    this.isLightMode,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileUpdated;
  final bool? isLightMode;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _gamerTagController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;

  late int _selectedAvatarIndex;
  late String _selectedPlatform;
  String? _customImagePath;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _gamerTagController = TextEditingController(text: widget.profile.gamerTag);
    _emailController = TextEditingController(text: widget.profile.email);
    _bioController = TextEditingController(text: widget.profile.bio);
    _selectedAvatarIndex = widget.profile.avatarIndex;
    _selectedPlatform = widget.profile.platform;
    _customImagePath = widget.profile.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gamerTagController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _customImagePath = base64Image;
        });

        // Persist the selected image directly to SharedPreferences
        await StorageService.saveProfileImage(base64Image);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image saved to storage! Tap SAVE to apply to profile.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access image picker: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.profile.copyWith(
      name: _nameController.text.trim(),
      gamerTag: _gamerTagController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      platform: _selectedPlatform,
      avatarIndex: _selectedAvatarIndex,
      imagePath: _customImagePath,
      clearImagePath: _customImagePath == null,
    );

    widget.onProfileUpdated(updated);
    await StorageService.saveUserProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated & saved to device storage!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showAvatarOptionsSheet(
    bool light,
    Color panelBg,
    Color textColor,
    Color subtextColor,
    Color accentColor,
    Color borderColor,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: panelBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Profile Picture Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose a photo from your device or select a gamer avatar',
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                    const SizedBox(height: 16),

                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.photo_library_outlined, color: accentColor),
                      ),
                      title: Text(
                        'Choose from Device Gallery',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Pick an image stored on this phone/computer',
                        style: TextStyle(color: subtextColor, fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(modalContext);
                        _pickImage(ImageSource.gallery);
                      },
                    ),

                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.camera_alt_outlined, color: accentColor),
                      ),
                      title: Text(
                        'Take Photo with Camera',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Capture a fresh selfie or avatar picture',
                        style: TextStyle(color: subtextColor, fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(modalContext);
                        _pickImage(ImageSource.camera);
                      },
                    ),

                    if (_customImagePath != null)
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        ),
                        title: const Text(
                          'Remove Custom Photo',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Revert back to gamer preset avatar',
                          style: TextStyle(color: subtextColor, fontSize: 12),
                        ),
                        onTap: () {
                          setState(() {
                            _customImagePath = null;
                          });
                          Navigator.pop(modalContext);
                        },
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: borderColor),
                    ),

                    Text(
                      'Or Pick a Preset Gamer Icon',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: List.generate(
                        UserProfile.avatarIcons.length,
                        (index) {
                          final isSelected =
                              _customImagePath == null && _selectedAvatarIndex == index;
                          final avatarColor = UserProfile.avatarColors[
                              index % UserProfile.avatarColors.length];

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _customImagePath = null;
                                _selectedAvatarIndex = index;
                              });
                              Navigator.pop(modalContext);
                            },
                            borderRadius: BorderRadius.circular(35),
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: avatarColor.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: isSelected
                                      ? accentColor
                                      : Colors.transparent,
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                              child: Icon(
                                UserProfile.avatarIcons[index],
                                color: avatarColor,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final light = widget.isLightMode ??
        (Theme.of(context).brightness == Brightness.light);
    final pageBg = light ? const Color(0xFFF4F7FB) : Colors.black;
    final panelBg = light ? Colors.white : const Color(0xFF1E212B);
    final textColor = light ? const Color(0xFF0F172A) : Colors.white;
    final subtextColor = light ? const Color(0xFF64748B) : Colors.white70;
    final accentColor =
        light ? const Color(0xFF0284C7) : const Color(0xFF7DD3FC);
    final borderColor = light ? const Color(0xFFE2E8F0) : const Color(0xFF2E3342);
    final inputFill = light ? const Color(0xFFF8FAFC) : const Color(0xFF161922);

    final previewProfile = widget.profile.copyWith(
      name: _nameController.text,
      gamerTag: _gamerTagController.text,
      avatarIndex: _selectedAvatarIndex,
      imagePath: _customImagePath,
      clearImagePath: _customImagePath == null,
    );

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        foregroundColor: textColor,
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'SAVE',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          children: [
            // Avatar section with interactive image picker
            Center(
              child: ProfileAvatar(
                profile: previewProfile,
                radius: 50,
                borderWidth: 2.5,
                borderColor: accentColor,
                showEditBadge: true,
                onTap: () => _showAvatarOptionsSheet(
                  light,
                  panelBg,
                  textColor,
                  subtextColor,
                  accentColor,
                  borderColor,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: OutlinedButton.icon(
                onPressed: () => _showAvatarOptionsSheet(
                  light,
                  panelBg,
                  textColor,
                  subtextColor,
                  accentColor,
                  borderColor,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentColor,
                  side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                label: Text(
                  _customImagePath != null ? 'Change Custom Photo' : 'Upload Device Photo',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                _gamerTagController.text.isEmpty
                    ? 'Gamer Profile'
                    : _gamerTagController.text,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Center(
              child: Text(
                _emailController.text,
                style: TextStyle(fontSize: 13, color: subtextColor),
              ),
            ),

            const SizedBox(height: 24),

            // Gamer stats row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: panelBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('LEVEL', '42', accentColor, textColor),
                  Container(width: 1, height: 32, color: borderColor),
                  _statItem('LIBRARY', '14 Games', accentColor, textColor),
                  Container(width: 1, height: 32, color: borderColor),
                  _statItem('STATUS', 'ONLINE', const Color(0xFF10B981), textColor),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _sectionLabel('PERSONAL INFORMATION', accentColor),

            const SizedBox(height: 12),

            _inputField(
              controller: _nameController,
              label: 'Display Name',
              icon: Icons.badge_outlined,
              inputFill: inputFill,
              borderColor: borderColor,
              accentColor: accentColor,
              textColor: textColor,
              subtextColor: subtextColor,
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Please enter your name';
                return null;
              },
            ),

            const SizedBox(height: 14),

            _inputField(
              controller: _gamerTagController,
              label: 'Gamer Tag / Username',
              icon: Icons.sports_esports_outlined,
              inputFill: inputFill,
              borderColor: borderColor,
              accentColor: accentColor,
              textColor: textColor,
              subtextColor: subtextColor,
              validator: (v) {
                if ((v ?? '').trim().isEmpty) {
                  return 'Please enter a gamer tag';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            _inputField(
              controller: _emailController,
              label: 'Gmail Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              helperText: 'Must be a valid @gmail.com address (letters & numbers only)',
              inputFill: inputFill,
              borderColor: borderColor,
              accentColor: accentColor,
              textColor: textColor,
              subtextColor: subtextColor,
              validator: FormValidators.validateGmail,
            ),

            const SizedBox(height: 14),

            _inputField(
              controller: _bioController,
              label: 'Gamer Bio',
              icon: Icons.notes_outlined,
              maxLines: 3,
              inputFill: inputFill,
              borderColor: borderColor,
              accentColor: accentColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),

            const SizedBox(height: 20),

            _sectionLabel('PREFERRED GAMING PLATFORM', accentColor),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              children: ['All', 'PC', 'PS5'].map((platform) {
                final isSelected = _selectedPlatform == platform;
                return ChoiceChip(
                  label: Text(platform),
                  selected: isSelected,
                  selectedColor: accentColor.withValues(alpha: 0.2),
                  backgroundColor: panelBg,
                  labelStyle: TextStyle(
                    color: isSelected ? accentColor : subtextColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? accentColor : borderColor,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedPlatform = platform);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saveProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: light ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'SAVE CHANGES',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color accent, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: accent,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color inputFill,
    required Color borderColor,
    required Color accentColor,
    required Color textColor,
    required Color subtextColor,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subtextColor, fontSize: 13),
        helperText: helperText,
        helperStyle: TextStyle(color: subtextColor.withValues(alpha: 0.8), fontSize: 11),
        helperMaxLines: 2,
        prefixIcon: Icon(icon, color: accentColor, size: 20),
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}
