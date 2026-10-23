import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/game.dart';
import '../widgets/game_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
    required this.onOpenGame,
    required this.compactCards,
    required this.showPrices,
    this.isLightMode,
  });

  final Set<String> favorites;
  final void Function(String) onToggleFavorite;
  final void Function(Game) onOpenGame;
  final bool compactCards;
  final bool showPrices;
  final bool? isLightMode;

  @override
  Widget build(BuildContext context) {
    final light =
        isLightMode ?? (Theme.of(context).brightness == Brightness.light);
    final pageBg = light ? const Color(0xFFF4F7FB) : Colors.black;
    final textColor = light ? const Color(0xFF0F172A) : Colors.white;
    final secondaryText = light
        ? const Color(0xFF64748B)
        : const Color(0xFF8A98A8);

    final games = gameCatalog.where((g) => favorites.contains(g.id)).toList();

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Your favorites',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                if (games.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 58,
                              color: secondaryText,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No favorites yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap the heart on a game to save it here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 2, 12, 110),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: compactCards ? .83 : .72,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final game = games[index];
                        return GameCard(
                          game: game,
                          isFavorite: true,
                          onFavorite: () => onToggleFavorite(game.id),
                          onTap: () => onOpenGame(game),
                          showPrice: showPrices,
                          compact: compactCards,
                        );
                      }, childCount: games.length),
                    ),
                  ),
              ],
            ),

            // Fade at the bottom edge of the screen, not in the middle.
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
}
