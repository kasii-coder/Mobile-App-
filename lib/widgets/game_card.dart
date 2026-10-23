import 'package:flutter/material.dart';

import '../models/game.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
    required this.showPrice,
    this.compact = false,
  });

  final Game game;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final bool showPrice;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final cardColor = isLight ? Colors.white : const Color(0xFF171923);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final accentColor = isLight
        ? const Color(0xFF0284C7)
        : theme.colorScheme.primary;
    final titleColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final mutedColor = isLight
        ? const Color(0xFF64748B)
        : (theme.textTheme.bodySmall?.color?.withValues(alpha: 0.72) ??
              Colors.white70);
    final borderColor = isLight
        ? const Color(0xFFE2E8F0)
        : const Color.fromARGB(255, 92, 191, 249).withValues(alpha: 0.08);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(1),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(1),
          border: Border.all(color: borderColor),
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: compact ? 125 : 145,
                  width: double.infinity,
                  child: Image.network(
                    game.imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.videogame_asset,
                          size: 42,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 9,
                  left: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFF1F5F9)
                          : backgroundColor.withValues(alpha: .88),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isLight
                            ? const Color(0xFFE2E8F0)
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      game.tag,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton.filledTonal(
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.pinkAccent
                          : (isLight ? const Color(0xFF64748B) : Colors.white),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: isLight
                          ? Colors.white.withValues(alpha: .92)
                          : backgroundColor.withValues(alpha: .8),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${game.platform}  •  ${game.genre}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: mutedColor),
                  ),
                  if (showPrice) ...[
                    const SizedBox(height: 9),
                    Text(
                      game.price == 0 ? 'Free to play' : '₹${game.price}',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
