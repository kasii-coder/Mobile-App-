import 'package:flutter_test/flutter_test.dart';
import 'package:app/data/game_data.dart';

void main() {
  test('All games in gameCatalog have valid trailer IDs', () {
    for (final game in gameCatalog) {
      expect(
        game.trailerId,
        isNotNull,
        reason: '${game.title} is missing trailerId',
      );
      expect(
        game.trailerId!.length,
        equals(11),
        reason: '${game.title} trailerId "${game.trailerId}" should be an 11-character YouTube video ID',
      );
      expect(
        RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(game.trailerId!),
        isTrue,
        reason: '${game.title} trailerId "${game.trailerId}" has invalid characters',
      );
    }
  });

  test('GTA 6 trailer ID is QdBZY2fkU-0', () {
    final gta6 = gameCatalog.firstWhere((g) => g.id == 'gta6');
    expect(gta6.trailerId, equals('QdBZY2fkU-0'));
  });
}
