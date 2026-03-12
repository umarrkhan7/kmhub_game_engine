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

  @override
  Widget build(BuildContext context) {
    final filteredGames =
        games.where((game) => game.category == category).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF060812),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1224),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF00F5D4), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(categoryIcon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF00F5D4).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFF00F5D4).withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                '${filteredGames.length} Games',
                style: const TextStyle(
                  color: Color(0xFF00F5D4),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1,
              color: const Color(0xFF00F5D4).withOpacity(0.15)),
        ),
      ),
      body: filteredGames.isEmpty
          ? const Center(
              child: Text(
                'No games in this category yet.',
                style: TextStyle(color: Color(0xFF8892B0), fontSize: 14),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            game: game,
                            player: player,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}