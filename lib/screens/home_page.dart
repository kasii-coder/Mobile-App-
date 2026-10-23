import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/game.dart';
import '../models/user_profile.dart';
import '../widgets/game_card.dart';
import '../widgets/profile_avatar.dart';
import 'profile_page.dart';

const Color accent = Color(0xFF7DD3FC);
const Color bg = Colors.black;
const Color muted = Color(0xFF94A3B8);
const Color panel = Colors.black;
const Color lightBg = Color(0xFFF4F7FB);
const Color lightPanel = Colors.white;

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
    required this.onOpenGame,
    required this.compactCards,
    required this.showPrices,
    required this.preferredPlatform,
    required this.onPlatformChanged,
    required this.isLightMode,
    required this.onToggleTheme,
    required this.userProfile,
    required this.onProfileUpdated,
  });

  final Set<String> favorites;
  final void Function(String) onToggleFavorite;
  final void Function(Game) onOpenGame;
  final bool compactCards;
  final bool showPrices;
  final String preferredPlatform;
  final ValueChanged<String> onPlatformChanged;
  final bool isLightMode;
  final VoidCallback onToggleTheme;
  final UserProfile userProfile;
  final ValueChanged<UserProfile> onProfileUpdated;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();

  late final AnimationController _glitterController;
  late final PageController _carouselController;

  int _carouselIndex = 0;
  Timer? _carouselTimer;

  String _query = '';
  bool _showGames = true;

  List<Game> get _featuredCarouselGames => gameCatalog.take(4).toList();
  int get _totalCarouselSlides => 2 + _featuredCarouselGames.length;

  @override
  void initState() {
    super.initState();

    _glitterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _carouselController = PageController();
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_carouselController.hasClients) return;
      final next = (_carouselIndex + 1) % _totalCarouselSlides;
      _carouselController.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> _refreshHomePage() async {
    setState(() {
      _showGames = false;
    });

    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    setState(() {
      _showGames = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    _glitterController.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = gameCatalog.where((game) {
      final query = _query.toLowerCase();

      final matchesText =
          game.title.toLowerCase().contains(query) ||
          game.genre.toLowerCase().contains(query);

      final matchesPlatform =
          widget.preferredPlatform == 'All' ||
          game.platform
              .split(',')
              .map((platform) => platform.trim())
              .contains(widget.preferredPlatform);

      return matchesText && matchesPlatform;
    }).toList();

    final pageBg = widget.isLightMode ? lightBg : bg;
    final textColor = widget.isLightMode
        ? const Color(0xFF172033)
        : Colors.white;
    final secondaryText = widget.isLightMode ? const Color(0xFF667085) : muted;
    final searchBg = widget.isLightMode ? lightPanel : Colors.black;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Solid black background.
            Positioned.fill(child: ColoredBox(color: pageBg)),

            RefreshIndicator(
              onRefresh: _refreshHomePage,
              color: accent,
              backgroundColor: widget.isLightMode
                  ? lightPanel
                  : const Color(0xFF252936),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header, banner, and search area.
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        // Animated glitter behind the top section.
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _glitterController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: GamingGlitterPainter(
                                    progress: _glitterController.value,
                                    lightMode: widget.isLightMode,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        Column(
                          children: [
                            // GameVault header.
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sports_esports,
                                    color: accent,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 2),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'GameVault',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.6,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: widget.isLightMode
                                          ? const Color(0xFFE2E8F0)
                                          : const Color(0xFF20232E),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: widget.isLightMode
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF333846),
                                      ),
                                    ),
                                    child: IconButton(
                                      tooltip: widget.isLightMode
                                          ? 'Switch to normal mode'
                                          : 'Switch to light mode',
                                      onPressed: widget.onToggleTheme,
                                      icon: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        transitionBuilder: (child, anim) =>
                                            RotationTransition(
                                              turns: anim,
                                              child: ScaleTransition(
                                                scale: anim,
                                                child: child,
                                              ),
                                            ),
                                        child: Icon(
                                          widget.isLightMode
                                              ? Icons.wb_sunny_rounded
                                              : Icons.nightlight_round,
                                          key: ValueKey(widget.isLightMode),
                                          color: widget.isLightMode
                                              ? const Color(0xFFF59E0B)
                                              : accent,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'You are all caught up!',
                                                style: TextStyle(
                                                  color: widget.isLightMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                    },
                                    icon: Icon(
                                      Icons.notifications_none,
                                      color: textColor,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Tooltip(
                                    message: 'Edit Profile',
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProfilePage(
                                              profile: widget.userProfile,
                                              onProfileUpdated:
                                                  widget.onProfileUpdated,
                                              isLightMode: widget.isLightMode,
                                            ),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(25),
                                      child: ProfileAvatar(
                                        profile: widget.userProfile,
                                        radius: 21,
                                        borderWidth: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Swipeable Game & Brand Banner Carousel
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 10, 4, 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 195,
                                    child: PageView.builder(
                                      controller: _carouselController,
                                      itemCount: _totalCarouselSlides,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _carouselIndex = index;
                                        });
                                        _startCarouselTimer();
                                      },
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                          child: _buildCarouselSlide(
                                            index,
                                            textColor,
                                            secondaryText,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Carousel navigation & indicators
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        icon: Icon(
                                          Icons.chevron_left_rounded,
                                          color: _carouselIndex > 0
                                              ? (widget.isLightMode ? Colors.black54 : Colors.white70)
                                              : (widget.isLightMode ? Colors.black26 : Colors.white24),
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          if (_carouselIndex > 0) {
                                            _carouselController.previousPage(
                                              duration: const Duration(milliseconds: 350),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(_totalCarouselSlides, (i) {
                                          final isSelected = _carouselIndex == i;
                                          return GestureDetector(
                                            onTap: () {
                                              _carouselController.animateToPage(
                                                i,
                                                duration: const Duration(milliseconds: 400),
                                                curve: Curves.easeInOut,
                                              );
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              margin: const EdgeInsets.symmetric(horizontal: 3),
                                              height: 6,
                                              width: isSelected ? 22 : 6,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? accent
                                                    : (widget.isLightMode
                                                        ? const Color(0xFFCBD5E1)
                                                        : const Color(0xFF414858)),
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        icon: Icon(
                                          Icons.chevron_right_rounded,
                                          color: _carouselIndex < _totalCarouselSlides - 1
                                              ? (widget.isLightMode ? Colors.black54 : Colors.white70)
                                              : (widget.isLightMode ? Colors.black26 : Colors.white24),
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          if (_carouselIndex < _totalCarouselSlides - 1) {
                                            _carouselController.nextPage(
                                              duration: const Duration(milliseconds: 350),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Black search bar with white text.
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: TextField(
                                controller: _search,
                                onChanged: (value) {
                                  setState(() {
                                    _query = value;
                                  });
                                },
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                                cursorColor: accent,
                                decoration: InputDecoration(
                                  hintText: 'Search games or genres...',
                                  hintStyle: TextStyle(
                                    color: secondaryText,
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: textColor,
                                    size: 25,
                                  ),
                                  filled: true,
                                  fillColor: searchBg,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 18,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(19),
                                    borderSide: BorderSide(
                                      color: accent,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(19),
                                    borderSide: BorderSide(
                                      color: widget.isLightMode
                                          ? const Color(0xFFB8C7D8)
                                          : const Color(0xFF414858),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(19),
                                    borderSide: const BorderSide(
                                      color: accent,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Explore games and platform filter.
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Explore games',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DropdownButton<String>(
                            value: widget.preferredPlatform,
                            underline: const SizedBox(),
                            dropdownColor: widget.isLightMode
                                ? lightPanel
                                : const Color(0xFF252936),
                            style: TextStyle(color: textColor),
                            items: const ['All', 'PC', 'PS5']
                                .map(
                                  (value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                widget.onPlatformChanged(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Game search results.
                  if (filtered.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(
                          child: Text(
                            'No games found.',
                            style: TextStyle(color: secondaryText),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
                      sliver: SliverOpacity(
                        opacity: _showGames ? 1.0 : 0.0,
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: widget.compactCards
                                    ? 0.68
                                    : 0.62,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final game = filtered[index];

                            return GameCard(
                              game: game,
                              isFavorite: widget.favorites.contains(game.id),
                              onFavorite: () {
                                widget.onToggleFavorite(game.id);
                              },
                              onTap: () {
                                widget.onOpenGame(game);
                              },
                              showPrice: widget.showPrices,
                              compact: widget.compactCards,
                            );
                          }, childCount: filtered.length),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Fade at the bottom edge of the screen, not in the middle.
            // IgnorePointer keeps the bottom area interactive.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 100,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        pageBg.withValues(alpha: 0.0),
                        pageBg.withValues(alpha: 0.7),
                        pageBg,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSlide(
    int index,
    Color textColor,
    Color secondaryText,
  ) {
    if (index == 0) {
      // First slide: No login banner with glitter effect, controller logo in middle & GameVault title
      return _buildBrandGlitterSlide(textColor, secondaryText);
    } else if (index == 1) {
      // Second slide: Find your next game. PC & PlayStation 5
      return _buildFindNextGameSlide(textColor, secondaryText);
    } else {
      // Connected game cards from game catalog
      final gameIndex = index - 2;
      final game = _featuredCarouselGames[gameIndex];
      return _buildGameSlide(game, textColor, secondaryText);
    }
  }

  Widget _buildBrandGlitterSlide(Color textColor, Color secondaryText) {
    final light = widget.isLightMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(29),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(29),
              gradient: LinearGradient(
                colors: light
                    ? [const Color(0xFFE8F1FC), const Color(0xFFD6E6F8)]
                    : [const Color(0xFF1E212B), const Color(0xFF0F1118)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: light
                    ? const Color(0xFFB8C9DC)
                    : const Color(0xFF333B4D),
                width: 1.2,
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glitterController,
              builder: (context, _) => CustomPaint(
                painter: GamingGlitterPainter(
                  progress: _glitterController.value,
                  lightMode: light,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: light ? Colors.white : const Color(0xFF171717),
                    border: Border.all(
                      color: light ? const Color(0xFFCBD5E1) : Colors.white70,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.28),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_esports_rounded,
                    color: accent,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'GAMEVAULT',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'YOUR NEXT ADVENTURE STARTS HERE',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindNextGameSlide(Color textColor, Color secondaryText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(29),
        gradient: LinearGradient(
          colors: widget.isLightMode
              ? [const Color(0xFFE5F4FF), const Color(0xFFD5EAF9)]
              : [const Color(0xFF414858), const Color(0xFF252936)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: widget.isLightMode
              ? const Color(0xFFB8C9DC)
              : const Color(0xFF333B4D),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'LEVEL UP',
                  style: TextStyle(
                    color: accent,
                    letterSpacing: 2,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find your\nnext game.',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 27,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PC & PlayStation 5',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.sports_esports,
            size: 68,
            color: accent,
          ),
        ],
      ),
    );
  }

  Widget _buildGameSlide(Game game, Color textColor, Color secondaryText) {
    return InkWell(
      onTap: () => widget.onOpenGame(game),
      borderRadius: BorderRadius.circular(29),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29),
          border: Border.all(
            color: widget.isLightMode
                ? const Color(0xFFB8C9DC)
                : const Color(0xFF333B4D),
            width: 1.2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                game.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: widget.isLightMode
                      ? const Color(0xFFD5EAF9)
                      : const Color(0xFF252936),
                  child: const Center(
                    child: Icon(Icons.sports_esports, size: 54, color: accent),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.25, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            game.tag,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            game.platform,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              game.price == 0 ? 'FREE TO PLAY' : '₹${game.price}',
                              style: TextStyle(
                                color: game.price == 0
                                    ? const Color(0xFF4ADE80)
                                    : accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'VIEW DETAILS',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Falling glitter with larger gaming-controller icons.
class GamingGlitterPainter extends CustomPainter {
  GamingGlitterPainter({required this.progress, this.lightMode = false});

  final double progress;
  final bool lightMode;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final random = Random(42);

    for (int i = 0; i < 65; i++) {
      final x = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final speed = 0.4 + random.nextDouble() * 1.2;
      final radius = 0.6 + random.nextDouble() * 1.3;
      final baseOpacity = 0.2 + random.nextDouble() * 0.6;

      final y = (startY + progress * size.height * speed) % size.height;

      // Gentle twinkling.
      final twinkle = 0.65 + 0.35 * sin((progress * 2 * pi) + i);
      final opacity = (baseOpacity * twinkle).clamp(0.0, 1.0);

      if (i % 7 == 0) {
        // Larger light-blue gaming-controller-shaped particles.
        final controllerPaint = Paint()
          ..color = accent.withValues(alpha: opacity.toDouble())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, y), width: 14, height: 9),
            const Radius.circular(3),
          ),
          controllerPaint,
        );

        // Controller buttons.
        canvas.drawCircle(Offset(x - 2.5, y), 1.0, controllerPaint);

        canvas.drawCircle(Offset(x + 2.5, y), 1.0, controllerPaint);

        // Tiny directional marks.
        canvas.drawLine(
          Offset(x - 4.5, y),
          Offset(x - 2.5, y),
          controllerPaint,
        );

        canvas.drawLine(
          Offset(x - 3.5, y - 1),
          Offset(x - 3.5, y + 1),
          controllerPaint,
        );
      } else {
        // Small white glitter particles.
        final glitterPaint = Paint()
          ..color = (lightMode ? const Color(0xFF526579) : Colors.white)
              .withValues(alpha: opacity.toDouble())
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), radius, glitterPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GamingGlitterPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lightMode != lightMode;
  }
}
