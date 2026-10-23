class Game {
  const Game({
    required this.id,
    required this.title,
    required this.platform,
    required this.genre,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.tag = 'POPULAR',
    this.trailerId,
  });

  final String id;
  final String title;
  final String platform;
  final String genre;
  final int price;
  final String description;
  final String imageUrl;
  final String tag;

  // YouTube video ID for the game's trailer.
  // Null means no trailer has been assigned.
  final String? trailerId;
}
