import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'checkout_page.dart';
import '../models/game.dart';

const Color detailDarkBg = Color(0xFF171923);
const Color detailDarkAccent = Color(0xFFE8F38B);
const Color detailDarkPanel = Color(0xFF232633);

class GameDetailPage extends StatelessWidget {
  const GameDetailPage({
    super.key,
    required this.game,
    required this.isFavorite,
    required this.onFavorite,
    this.isLightMode,
  });

  final Game game;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final bool? isLightMode;

  @override
  Widget build(BuildContext context) {
    final light =
        isLightMode ?? (Theme.of(context).brightness == Brightness.light);
    final pageBg = light ? const Color(0xFFF4F7FB) : detailDarkBg;
    final panelBg = light ? Colors.white : detailDarkPanel;
    final textColor = light ? const Color(0xFF0F172A) : Colors.white;
    final subtextColor = light ? const Color(0xFF64748B) : Colors.white70;
    final accentColor = light ? const Color(0xFF0284C7) : detailDarkAccent;
    final tagBg = light ? const Color(0xFFE2E8F0) : detailDarkPanel;
    final borderColor = light ? const Color(0xFFE2E8F0) : Colors.white12;

    final trailer = game.trailerId?.trim();

    return Scaffold(
      backgroundColor: pageBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: pageBg,
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.pinkAccent : textColor,
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                game.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  shadows: light
                      ? null
                      : const [Shadow(color: Colors.black87, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    game.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: panelBg,
                      child: Icon(
                        Icons.videogame_asset,
                        size: 80,
                        color: accentColor,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, pageBg],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _tag(
                        Icons.devices,
                        game.platform,
                        tagBg,
                        accentColor,
                        textColor,
                      ),
                      _tag(
                        Icons.category_outlined,
                        game.genre,
                        tagBg,
                        accentColor,
                        textColor,
                      ),
                      _tag(
                        Icons.local_offer_outlined,
                        game.tag,
                        tagBg,
                        accentColor,
                        textColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  Text(
                    'GAME TRAILER',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Watch the official gameplay or cinematic trailer.',
                    style: TextStyle(color: subtextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 14),

                  if (trailer != null && trailer.isNotEmpty)
                    _TrailerPlayer(videoSource: trailer, panelColor: panelBg)
                  else
                    _trailerMessage(
                      Icons.movie_outlined,
                      'Trailer coming soon',
                      'A trailer has not been added for this game.',
                      panelBg,
                      borderColor,
                      accentColor,
                      textColor,
                      subtextColor,
                    ),

                  const SizedBox(height: 28),

                  Text(
                    'PRICE',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    game.price == 0 ? 'Free to play' : '₹${game.price}',
                    style: TextStyle(
                      fontSize: 30,
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'About this game',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    game.description,
                    style: TextStyle(
                      color: subtextColor,
                      height: 1.7,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 26),

                  Text(
                    'Game information',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(
                    'Game title',
                    game.title,
                    borderColor,
                    subtextColor,
                    textColor,
                  ),
                  _infoRow(
                    'Platform',
                    game.platform,
                    borderColor,
                    subtextColor,
                    textColor,
                  ),
                  _infoRow(
                    'Category',
                    game.genre,
                    borderColor,
                    subtextColor,
                    textColor,
                  ),
                  _infoRow(
                    'Availability',
                    game.tag.toUpperCase() == 'COMING SOON'
                        ? 'Coming soon'
                        : 'Demo listing',
                    borderColor,
                    subtextColor,
                    textColor,
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: light ? Colors.white : detailDarkBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (game.tag.toUpperCase() == 'COMING SOON') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'This game is coming soon and is not available yet.',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 3, 0, 0),
                                ),
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CheckoutPage(game: game, isLightMode: light),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text(
                        'BUY GAME',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: onFavorite,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentColor,
                        side: BorderSide(color: accentColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      label: Text(
                        isFavorite
                            ? 'Remove from Favorites'
                            : 'Add to Favorites',
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(
    IconData icon,
    String text,
    Color bg,
    Color iconColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value,
    Color borderColor,
    Color subtextColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(title, style: TextStyle(color: subtextColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _trailerMessage(
  IconData icon,
  String title,
  String subtitle,
  Color panelBg,
  Color borderColor,
  Color accentColor,
  Color textColor,
  Color subtextColor,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: panelBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: accentColor, size: 40),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: subtextColor, fontSize: 12, height: 1.4),
        ),
      ],
    ),
  );
}

class _TrailerPlayer extends StatefulWidget {
  const _TrailerPlayer({required this.videoSource, required this.panelColor});

  final String videoSource;
  final Color panelColor;

  @override
  State<_TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<_TrailerPlayer> {
  YoutubePlayerController? _controller;
  bool _invalidVideo = false;

  static String? _extractVideoId(String source) {
    var value = source.trim();

    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1).trim();
    }

    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(value)) {
      return value;
    }

    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      if (value.startsWith('youtu.be/') ||
          value.startsWith('www.youtu.be/') ||
          value.startsWith('youtube.com/') ||
          value.startsWith('www.youtube.com/') ||
          value.startsWith('m.youtube.com/')) {
        value = 'https://$value';
      }
    }

    final uri = Uri.tryParse(value);
    if (uri != null) {
      final host = uri.host.toLowerCase();
      String? id;

      if (host == 'youtu.be' || host == 'www.youtu.be') {
        if (uri.pathSegments.isNotEmpty) {
          id = uri.pathSegments.first;
        }
      } else if (host.contains('youtube.com')) {
        id = uri.queryParameters['v'];

        if (id == null && uri.pathSegments.length >= 2) {
          final first = uri.pathSegments.first;
          if (first == 'embed' || first == 'shorts' || first == 'live') {
            id = uri.pathSegments[1];
          }
        }
      }

      if (id != null && RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id)) {
        return id;
      }
    }

    final regexMatches = [
      RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtu\.be\/([a-zA-Z0-9_-]{11})'),
      RegExp(r'\/(?:embed|shorts|live)\/([a-zA-Z0-9_-]{11})'),
    ];

    for (final reg in regexMatches) {
      final match = reg.firstMatch(value);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }

    return null;
  }

  String _getInvalidVideoReason(String source) {
    final value = source.trim();
    if (value.length == 16 || value.startsWith('si=')) {
      return 'The value "$value" is a YouTube share tracking token (?si=...), not the video ID.\n'
          'Example valid ID: QdBZY2fkU-0 (or paste the complete YouTube URL) in game_data.dart.';
    }
    return 'Add a valid 11-character YouTube video ID (e.g. QdBZY2fkU-0) or complete URL in game_data.dart.';
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant _TrailerPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoSource != widget.videoSource) {
      _controller?.close();
      _controller = null;
      _initPlayer();
    }
  }

  void _initPlayer() {
    final videoId = _extractVideoId(widget.videoSource);

    if (videoId == null) {
      _invalidVideo = true;
      return;
    }

    _invalidVideo = false;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      params: const YoutubePlayerParams(
        mute: false,
        enableCaption: true,
        showFullscreenButton: true,
        showControls: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_invalidVideo || _controller == null) {
      return _trailerMessage(
        Icons.error_outline,
        'Invalid trailer link',
        _getInvalidVideoReason(widget.videoSource),
        widget.panelColor,
        Colors.redAccent.withValues(alpha: 0.3),
        Colors.redAccent,
        Colors.redAccent,
        const Color(0xFF64748B),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: widget.panelColor,
        child: YoutubePlayer(
          controller: _controller!,
          aspectRatio: 16 / 9,
          backgroundColor: widget.panelColor,
        ),
      ),
    );
  }
}
