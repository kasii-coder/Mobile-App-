import 'package:flutter/material.dart';

import 'models/game.dart';
import 'models/user_profile.dart';
import 'screens/favorites_page.dart';
import 'screens/game_detail_page.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/settings_page.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  final initialLoggedIn = StorageService.isLoggedIn();
  final initialLightMode = StorageService.isLightMode(defaultValue: false);
  final initialProfile = StorageService.loadUserProfile(
    const UserProfile(
      name: 'Alex Mercer',
      gamerTag: 'ShadowVault#77',
      email: 'gamer@gmail.com',
      bio: 'Casual & competitive gamer. PC & PS5 collector.',
      platform: 'All',
      avatarIndex: 0,
    ),
  );

  runApp(GameVaultApp(
    initialLoggedIn: initialLoggedIn,
    initialLightMode: initialLightMode,
    initialProfile: initialProfile,
  ));
}

const Color darkBg = Colors.black;
const Color darkPanel = Color(0xFF20232E);
const Color lightBg = Color(0xFFF4F7FB);
const Color lightPanel = Colors.white;
const Color accent = Color(0xFF7DD3FC);
const Color lightAccent = Color(0xFF0284C7);
const Color muted = Color(0xFF969BAB);

class GameVaultApp extends StatefulWidget {
  const GameVaultApp({
    super.key,
    this.initialLoggedIn = false,
    this.initialLightMode = false,
    this.initialProfile,
  });

  final bool initialLoggedIn;
  final bool initialLightMode;
  final UserProfile? initialProfile;

  @override
  State<GameVaultApp> createState() => _GameVaultAppState();
}

class _GameVaultAppState extends State<GameVaultApp> {
  late bool _loggedIn;
  late bool _isLightMode;
  late UserProfile _userProfile;

  final Set<String> _favorites = <String>{};

  final bool _compactCards = false;
  final bool _showPrices = true;
  String _preferredPlatform = 'All';

  @override
  void initState() {
    super.initState();
    _loggedIn = widget.initialLoggedIn;
    _isLightMode = widget.initialLightMode;
    _userProfile = widget.initialProfile ??
        const UserProfile(
          name: 'Alex Mercer',
          gamerTag: 'ShadowVault#77',
          email: 'gamer@gmail.com',
          bio: 'Casual & competitive gamer. PC & PS5 collector.',
          platform: 'All',
          avatarIndex: 0,
        );
  }

  void _toggleTheme() {
    setState(() {
      _isLightMode = !_isLightMode;
    });
    StorageService.setLightMode(_isLightMode);
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (!_favorites.add(id)) {
        _favorites.remove(id);
      }
    });
  }

  void _updateProfile(UserProfile newProfile) {
    setState(() {
      _userProfile = newProfile;
    });
    StorageService.saveUserProfile(newProfile);
  }

  ThemeData _buildTheme(bool light) {
    final background = light ? lightBg : darkBg;
    final surface = light ? lightPanel : darkPanel;
    final foreground = light ? const Color(0xFF0F172A) : Colors.white;
    final secondaryText =
        light ? const Color(0xFF64748B) : const Color(0xFF969BAB);
    final themeAccent = light ? lightAccent : accent;

    return ThemeData(
      useMaterial3: true,
      brightness: light ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: surface,
      colorScheme: ColorScheme(
        brightness: light ? Brightness.light : Brightness.dark,
        primary: themeAccent,
        onPrimary: light ? Colors.white : Colors.black,
        secondary: themeAccent,
        onSecondary: light ? Colors.white : Colors.black,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
        surface: surface,
        onSurface: foreground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: themeAccent.withValues(alpha: light ? 0.15 : 0.25),
        elevation: light ? 8 : 0,
        shadowColor: light ? const Color(0x1F000000) : Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: foreground,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? themeAccent
                : secondaryText,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: light ? const Color(0xFFE8EDF5) : const Color(0xFF20232E),
        hintStyle: TextStyle(color: secondaryText),
        labelStyle: TextStyle(color: foreground),
        prefixIconColor: foreground,
        suffixIconColor: foreground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: themeAccent, width: 1.5),
        ),
      ),
      textTheme: ThemeData(
        brightness: light ? Brightness.light : Brightness.dark,
      ).textTheme.apply(bodyColor: foreground, displayColor: foreground),
      dividerColor: light ? const Color(0xFFDCE3ED) : const Color(0xFF303542),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GameVault',
      themeMode: _isLightMode ? ThemeMode.light : ThemeMode.dark,
      theme: _buildTheme(true),
      darkTheme: _buildTheme(false),
      home: _loggedIn
          ? _StoreShell(
              isLightMode: _isLightMode,
              onToggleTheme: _toggleTheme,
              favorites: _favorites,
              onToggleFavorite: _toggleFavorite,
              userProfile: _userProfile,
              onProfileUpdated: _updateProfile,
              compactCards: _compactCards,
              showPrices: _showPrices,
              preferredPlatform: _preferredPlatform,
              onPlatformChanged: (value) {
                setState(() => _preferredPlatform = value);
              },
              onLogout: () async {
                await StorageService.logout();
                setState(() => _loggedIn = false);
              },
            )
          : LoginPage(
              savedProfile: _userProfile,
              onLogin: () async {
                await StorageService.setLoggedIn(true);
                setState(() => _loggedIn = true);
              },
              isLightMode: _isLightMode,
            ),
    );
  }
}

class _StoreShell extends StatefulWidget {
  const _StoreShell({
    required this.isLightMode,
    required this.onToggleTheme,
    required this.favorites,
    required this.onToggleFavorite,
    required this.userProfile,
    required this.onProfileUpdated,
    required this.compactCards,
    required this.showPrices,
    required this.preferredPlatform,
    required this.onPlatformChanged,
    required this.onLogout,
  });

  final bool isLightMode;
  final VoidCallback onToggleTheme;

  final Set<String> favorites;
  final void Function(String) onToggleFavorite;

  final UserProfile userProfile;
  final ValueChanged<UserProfile> onProfileUpdated;

  final bool compactCards;
  final bool showPrices;
  final String preferredPlatform;
  final ValueChanged<String> onPlatformChanged;
  final VoidCallback onLogout;

  @override
  State<_StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends State<_StoreShell> {
  int _index = 0;

  void _openGame(Game game) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (detailContext) => GameDetailPage(
          game: game,
          isFavorite: widget.favorites.contains(game.id),
          onFavorite: () {
            widget.onToggleFavorite(game.id);
            setState(() {});
          },
          isLightMode: widget.isLightMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(
        favorites: widget.favorites,
        onToggleFavorite: widget.onToggleFavorite,
        onOpenGame: _openGame,
        compactCards: widget.compactCards,
        showPrices: widget.showPrices,
        preferredPlatform: widget.preferredPlatform,
        onPlatformChanged: widget.onPlatformChanged,
        isLightMode: widget.isLightMode,
        onToggleTheme: widget.onToggleTheme,
        userProfile: widget.userProfile,
        onProfileUpdated: widget.onProfileUpdated,
      ),
      FavoritesPage(
        favorites: widget.favorites,
        onToggleFavorite: widget.onToggleFavorite,
        onOpenGame: _openGame,
        compactCards: widget.compactCards,
        showPrices: widget.showPrices,
        isLightMode: widget.isLightMode,
      ),
      SettingsPage(
        onLogout: widget.onLogout,
        isLightMode: widget.isLightMode,
        onToggleTheme: widget.onToggleTheme,
        userProfile: widget.userProfile,
        onProfileUpdated: widget.onProfileUpdated,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Store',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
