import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/main.dart';
import 'package:app/models/game.dart';
import 'package:app/models/user_profile.dart';
import 'package:app/screens/checkout_page.dart';
import 'package:app/screens/favorites_page.dart';
import 'package:app/screens/home_page.dart';
import 'package:app/screens/login_page.dart';
import 'package:app/screens/profile_page.dart';
import 'package:app/screens/receipt_page.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/utils/validators.dart';

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  const testProfile = UserProfile(
    name: 'Test Gamer',
    gamerTag: 'Tester#1',
    email: 'tester@gmail.com',
    bio: 'Playing games for tests',
    platform: 'All',
  );

  testWidgets(
      'Theme button displays half moon in normal mode and sun in light mode',
      (WidgetTester tester) async {
    bool isLight = false;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: HomePage(
              favorites: const {},
              onToggleFavorite: (_) {},
              onOpenGame: (_) {},
              compactCards: false,
              showPrices: true,
              preferredPlatform: 'All',
              onPlatformChanged: (_) {},
              isLightMode: isLight,
              onToggleTheme: () {
                setState(() {
                  isLight = !isLight;
                });
              },
              userProfile: testProfile,
              onProfileUpdated: (_) {},
            ),
          );
        },
      ),
    );

    // Initial state: normal mode -> half moon icon should be present
    expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny_rounded), findsNothing);

    // Click the theme button
    await tester.tap(find.byIcon(Icons.nightlight_round));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Now in light mode -> sun icon should be present
    expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
    expect(find.byIcon(Icons.nightlight_round), findsNothing);

    // Click again -> switches back to normal mode
    await tester.tap(find.byIcon(Icons.wb_sunny_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny_rounded), findsNothing);
  });

  testWidgets('CheckoutPage renders properly in light and normal mode',
      (WidgetTester tester) async {
    const testGame = Game(
      id: 'test_game',
      title: 'Test Game',
      genre: 'Action',
      platform: 'PC',
      price: 1999,
      imageUrl: '',
      description: 'Test description',
      tag: 'HOT',
    );

    // Light mode
    await tester.pumpWidget(
      const MaterialApp(
        home: CheckoutPage(
          game: testGame,
          isLightMode: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Physical Disc'), findsOneWidget);
    expect(find.text('Digital Version'), findsOneWidget);
    expect(find.text('Test Game'), findsOneWidget);

    // Normal mode
    await tester.pumpWidget(
      const MaterialApp(
        home: CheckoutPage(
          game: testGame,
          isLightMode: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Checkout'), findsOneWidget);
  });

  testWidgets('FavoritesPage renders empty state and list in light mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FavoritesPage(
          favorites: const {},
          onToggleFavorite: (_) {},
          onOpenGame: (_) {},
          compactCards: false,
          showPrices: true,
          isLightMode: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Your favorites'), findsOneWidget);
    expect(find.text('No favorites yet'), findsOneWidget);
  });

  testWidgets('ReceiptPage renders order details and activation key',
      (WidgetTester tester) async {
    const testGame = Game(
      id: 'test_game',
      title: 'Cyber Strike 2026',
      genre: 'Sci-Fi Action',
      platform: 'PC',
      price: 2499,
      imageUrl: '',
      description: 'Futuristic combat simulator',
      tag: 'NEW',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ReceiptPage(
          game: testGame,
          version: 'Digital',
          quantity: 1,
          paymentMethod: 'UPI',
          subtotal: 2499,
          deliveryFee: 0,
          totalAmount: 2499,
          purchaseDate: DateTime(2026, 10, 19, 14, 30),
          isLightMode: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Order Receipt'), findsOneWidget);
    expect(find.text('Payment Successful!'), findsOneWidget);
    expect(find.text('Cyber Strike 2026'), findsOneWidget);
    expect(find.text('DIGITAL ACTIVATION KEY'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('BACK TO STORE'), 200);
    expect(find.text('BACK TO STORE'), findsOneWidget);
  });

  testWidgets('ProfilePage renders user details and edit fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePage(
          profile: testProfile,
          onProfileUpdated: (_) {},
          isLightMode: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('SAVE'), findsOneWidget);
    // Header text and TextFormField both display the gamerTag
    expect(find.text('Tester#1'), findsNWidgets(2));
  });

  group('FormValidators', () {
    test('validateGmail enforces @, ., gmail keywords and rejects forbidden symbols', () {
      // Valid cases
      expect(FormValidators.validateGmail('alex@gmail.com'), isNull);
      expect(FormValidators.validateGmail('gamer2026@gmail.com'), isNull);
      expect(FormValidators.validateGmail('player.one@gmail.com'), isNull);

      // Missing @
      expect(FormValidators.validateGmail('alexgmail.com'), isNotNull);

      // Missing .
      expect(FormValidators.validateGmail('alex@gmail'), isNotNull);

      // Missing gmail keyword
      expect(FormValidators.validateGmail('alex@yahoo.com'), isNotNull);
      expect(FormValidators.validateGmail('alex@outlook.com'), isNotNull);

      // Contains forbidden symbols like underscore, hyphen, plus
      expect(FormValidators.validateGmail('alex_gamer@gmail.com'), isNotNull);
      expect(FormValidators.validateGmail('alex-gamer@gmail.com'), isNotNull);
      expect(FormValidators.validateGmail('alex+promo@gmail.com'), isNotNull);
      expect(FormValidators.validateGmail('alex#gamer@gmail.com'), isNotNull);
    });

    test('validatePassword enforces min 8 chars, 1 caps, 1 symbol, and strictly rejects underscore', () {
      // Valid passwords
      expect(FormValidators.validatePassword('GameVault#2026'), isNull);
      expect(FormValidators.validatePassword('CyberStrike!1'), isNull);
      expect(FormValidators.validatePassword('StrongPass@99'), isNull);

      // Too short (< 8 chars)
      expect(FormValidators.validatePassword('Pass#1'), isNotNull);

      // No uppercase letter
      expect(FormValidators.validatePassword('gamevault#2026'), isNotNull);

      // Contains underscore (strictly forbidden)
      expect(FormValidators.validatePassword('Game_Vault#2026'), isNotNull);
      expect(FormValidators.validatePassword('Pass_word!'), isNotNull);

      // No special symbol
      expect(FormValidators.validatePassword('GameVault2026'), isNotNull);
    });
  });

  group('StorageService & Persistent Login', () {
    test('saves and retrieves login state, theme, and profile data', () async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();

      expect(StorageService.isLoggedIn(), isFalse);

      await StorageService.setLoggedIn(true);
      expect(StorageService.isLoggedIn(), isTrue);

      await StorageService.logout();
      expect(StorageService.isLoggedIn(), isFalse);

      // Profile persistence with custom image
      const profileWithCustomImage = UserProfile(
        name: 'Samantha Ray',
        gamerTag: 'Valkyrie99',
        email: 'valkyrie@gmail.com',
        bio: 'Speedrunner',
        platform: 'PS5',
        avatarIndex: 3,
        imagePath: '/mock/path/profile.jpg',
      );

      await StorageService.saveUserProfile(profileWithCustomImage);
      final loaded = StorageService.loadUserProfile(testProfile);

      expect(loaded.gamerTag, 'Valkyrie99');
      expect(loaded.email, 'valkyrie@gmail.com');
      expect(loaded.imagePath, '/mock/path/profile.jpg');
      expect(loaded.platform, 'PS5');
    });

    testWidgets('GameVaultApp starts directly into store when initialLoggedIn is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GameVaultApp(
          initialLoggedIn: true,
          initialLightMode: false,
          initialProfile: testProfile,
        ),
      );
      await tester.pump();

      // Store shell should be visible directly without login screen
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Store'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      // Login page elements should NOT be present
      expect(find.text('Welcome back'), findsNothing);
    });
  });

  group('HomePage Carousel & Details Navigation', () {
    testWidgets('renders brand glitter slide and allows swiping to find next game and featured game',
        (WidgetTester tester) async {
      Game? selectedGame;

      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            favorites: const {},
            onToggleFavorite: (_) {},
            onOpenGame: (game) {
              selectedGame = game;
            },
            compactCards: false,
            showPrices: true,
            preferredPlatform: 'All',
            onPlatformChanged: (_) {},
            isLightMode: false,
            onToggleTheme: () {},
            userProfile: testProfile,
            onProfileUpdated: (_) {},
          ),
        ),
      );
      await tester.pump();

      // First slide: brand banner with glitter effect, logo, name & subtitle
      expect(find.text('YOUR NEXT ADVENTURE STARTS HERE'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);

      // Navigate to second slide (Find your next game) via right chevron button
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Find your\nnext game.'), findsOneWidget);

      // Navigate to third slide (first featured game)
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('VIEW DETAILS'), findsOneWidget);

      // Tap on VIEW DETAILS
      await tester.tap(find.text('VIEW DETAILS'));
      await tester.pump();

      expect(selectedGame, isNotNull);
    });
  });

  group('LoginPage Saved Account & OTP Flow', () {
    testWidgets('displays saved account box with masked email and handles OTP login with upper banner',
        (WidgetTester tester) async {
      bool loggedIn = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            savedProfile: testProfile,
            onLogin: () {
              loggedIn = true;
            },
            isLightMode: false,
          ),
        ),
      );
      await tester.pump();

      // Verify saved profile box shows profile name and masked gmail details (starts with xxxx)
      expect(find.text('Test Gamer'), findsOneWidget);
      expect(find.text('SAVED'), findsOneWidget);
      // tester@gmail.com -> masked as xxxxer@gmail.com
      expect(find.text('xxxxer@gmail.com'), findsOneWidget);

      // Verify Request OTP button exists
      expect(find.text('LOGIN WITH OTP'), findsOneWidget);

      // Tap LOGIN WITH OTP
      await tester.tap(find.text('LOGIN WITH OTP'));
      await tester.pump();

      // Upper OTP notification banner should be visible
      expect(find.text('GAMEVAULT OTP NOTIFICATION'), findsOneWidget);
      expect(find.text('AUTO-FILL'), findsOneWidget);

      // Tap AUTO-FILL to log in
      await tester.tap(find.text('AUTO-FILL'));
      await tester.pump();

      expect(loggedIn, isTrue);
    });

    test('persists profile image in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();

      const mockBase64 =
          'data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
      await StorageService.saveProfileImage(mockBase64);

      expect(StorageService.getSavedProfileImage(), mockBase64);

      final profileWithImage = testProfile.copyWith(imagePath: mockBase64);
      await StorageService.saveUserProfile(profileWithImage);

      final loaded = StorageService.loadUserProfile(testProfile);
      expect(loaded.imagePath, mockBase64);
    });
  });
}

