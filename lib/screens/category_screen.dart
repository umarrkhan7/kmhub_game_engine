import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../widgets/game_card.dart';
import 'game_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String category;
  final String categoryIcon;
  final List<Game> games;
  final Player player;

  const CategoryScreen({
    Key? key,
    required this.category,
    required this.categoryIcon,
    required this.games,
    required this.player,
  }) : super(key: key);

  static const bg      = Color(0xFF0A1A0F);
  static const surface = Color(0xFF122A1A);
  static const primary = Color(0xFF3A9A5C);
  static const olive   = Color(0xFFA8C878);
  static const dark    = Color(0xFF1F5C35);
  static const muted   = Color(0xFF7AAF8A);

  @override
  Widget build(BuildContext context) {
    final filteredGames = games.where((game) => game.category == category).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFA8C878), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(categoryIcon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              category.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: olive.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                '${filteredGames.length} Games',
                style: const TextStyle(
                  color: Color(0xFFA8C878),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: olive.withOpacity(0.15)),
        ),
      ),
      body: filteredGames.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(categoryIcon, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  const Text(
                    'No games yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No games in this category yet.',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: filteredGames.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final game = filteredGames[index];
                  return GameCard(
                    game: game,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => GameScreen(game: game, player: player),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}