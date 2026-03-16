import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class RanksScreen extends StatefulWidget {
  const RanksScreen({Key? key}) : super(key: key);

  @override
  State<RanksScreen> createState() => RanksScreenState();
}

class RanksScreenState extends State<RanksScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final List<Map<String, String>> gameCategories = [
    {'title': 'Moto X3M',       'icon': '🏍️'},
    {'title': 'Subway Surfers', 'icon': '🏃'},
    {'title': '8 Ball Pool',    'icon': '🎱'},
    {'title': 'Chess',          'icon': '♟️'},
    {'title': 'Knife Hit',      'icon': '🔪'},
    {'title': 'Temple Run 2',   'icon': '🏛️'},
    {'title': 'Agar.io',        'icon': '🔵'},
    {'title': 'Slope',          'icon': '🎿'},
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: gameCategories.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F3C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFD700), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'RANKINGS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: const Color(0xFF8BA3CC),
          indicatorColor: const Color(0xFFFFD700),
          indicatorWeight: 2,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          tabs: gameCategories.map((g) => Tab(
            child: Row(
              children: [
                Text(g['icon']!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(g['title']!),
              ],
            ),
          )).toList(),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: gameCategories.map((g) =>
          LeaderboardTab(gameTitle: g['title']!, gameIcon: g['icon']!)
        ).toList(),
      ),
    );
  }
}

class LeaderboardTab extends StatelessWidget {
  final String gameTitle;
  final String gameIcon;

  const LeaderboardTab({
    Key? key,
    required this.gameTitle,
    required this.gameIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getLeaderboard(gameTitle),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD700)),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(gameIcon, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                const Text(
                  'No scores yet!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to play $gameTitle\nand claim the #1 spot!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8BA3CC),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        final myUid = FirebaseService.currentUid;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final rank = index + 1;
            final isMe = data['uid'] == myUid;
            final username = data['username'] ?? 'Player';
            final score = data['score'] ?? 0;
            return buildRankCard(rank, username, score, isMe);
          },
        );
      },
    );
  }

  Widget buildRankCard(int rank, String username, int score, bool isMe) {
    Color rankColor;
    String rankIcon;
    if (rank == 1) { rankColor = const Color(0xFFFFD700); rankIcon = '🥇'; }
    else if (rank == 2) { rankColor = const Color(0xFFC0C0C0); rankIcon = '🥈'; }
    else if (rank == 3) { rankColor = const Color(0xFFCD7F32); rankIcon = '🥉'; }
    else { rankColor = const Color(0xFF8BA3CC); rankIcon = '#$rank'; }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFF0066FF).withOpacity(0.08)
            : const Color(0xFF0D1F3C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe
              ? const Color(0xFFFFD700).withOpacity(0.3)
              : rank <= 3
                  ? rankColor.withOpacity(0.2)
                  : const Color(0xFF0066FF).withOpacity(0.1),
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: rank <= 3
                ? Text(rankIcon, style: const TextStyle(fontSize: 22))
                : Text(
                    '#$rank',
                    style: TextStyle(
                      color: rankColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isMe
                    ? [const Color(0xFF0066FF), const Color(0xFF003899)]
                    : [const Color(0xFF0D1F3C), const Color(0xFF1A2A4A)],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: isMe
                    ? const Color(0xFFFFD700).withOpacity(0.4)
                    : const Color(0xFF0066FF).withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isMe ? const Color(0xFFFFD700) : const Color(0xFF8BA3CC),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        color: isMe ? const Color(0xFFFFD700) : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  gameTitle,
                  style: const TextStyle(color: Color(0xFF8BA3CC), fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const Text(
                'pts',
                style: TextStyle(color: Color(0xFF8BA3CC), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}