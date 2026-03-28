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
  static const bg      = Color(0xFF0A1A0F);
  static const surface = Color(0xFF122A1A);
  static const primary = Color(0xFF3A9A5C);
  static const olive   = Color(0xFFA8C878);
  static const muted   = Color(0xFF7AAF8A);
  static const dark    = Color(0xFF1F5C35);

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
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: olive, size: 18),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'RANKINGS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),

        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: olive,
          unselectedLabelColor: muted,
          indicatorColor: olive,
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
            LeaderboardTab(
              gameTitle: g['title']!,
              gameIcon: g['icon']!,
              bg: bg,
              surface: surface,
              primary: primary,
              olive: olive,
              muted: muted,
            )
        ).toList(),
      ),
    );
  }
}

class LeaderboardTab extends StatelessWidget {
  final String gameTitle;
  final String gameIcon;

  final Color bg;
  final Color surface;
  final Color primary;
  final Color olive;
  final Color muted;

  const LeaderboardTab({
    Key? key,
    required this.gameTitle,
    required this.gameIcon,
    required this.bg,
    required this.surface,
    required this.primary,
    required this.olive,
    required this.muted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getLeaderboard(gameTitle),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: olive),
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
                  style: TextStyle(
                    color: muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        final myUid = FirebaseService.currentUid;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
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

    if (rank == 1) {
      rankColor = Colors.amber;
      rankIcon = '🥇';
    } else if (rank == 2) {
      rankColor = Colors.grey;
      rankIcon = '🥈';
    } else if (rank == 3) {
      rankColor = Colors.brown;
      rankIcon = '🥉';
    } else {
      rankColor = muted;
      rankIcon = '#$rank';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: isMe
              ? olive.withOpacity(0.5)
              : rank <= 3
              ? rankColor.withOpacity(0.3)
              : primary.withOpacity(0.15),
          width: isMe ? 1.5 : 1,
        ),

        boxShadow: isMe
            ? [
          BoxShadow(
            color: primary.withOpacity(0.4),
            blurRadius: 12,
          )
        ]
            : [],
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A9A5C), Color(0xFF1F5C35)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.5),
                  blurRadius: 10,
                )
              ],
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
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
                        color: isMe ? olive : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),

                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: olive.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: olive.withOpacity(0.4)),
                        ),
                        child: Text(
                          'YOU',
                          style: TextStyle(
                            color: olive,
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
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),

          /// 🔥 SCORE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  color: olive,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              Text(
                'pts',
                style: TextStyle(color: muted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}