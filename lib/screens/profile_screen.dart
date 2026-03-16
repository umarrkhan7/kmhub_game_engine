import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static const bg      = Color(0xFF050A18);
  static const surface = Color(0xFF0D1F3C);
  static const primary = Color(0xFF0066FF);
  static const gold    = Color(0xFFFFD700);
  static const muted   = Color(0xFF8BA3CC);
  static const red     = Color(0xFFFF4C6A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFD700), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('PROFILE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900,
              fontSize: 16, letterSpacing: 2)),
        actions: [
          TextButton.icon(
            onPressed: () => confirmSignOut(context),
            icon: const Icon(Icons.logout, color: Color(0xFFFF4C6A), size: 18),
            label: const Text('Sign Out',
              style: TextStyle(color: Color(0xFFFF4C6A), fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: gold.withOpacity(0.15)),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseService.streamUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Profile not found', style: TextStyle(color: muted)));
          }
          final data    = snapshot.data!.data() as Map<String, dynamic>;
          final username    = data['username']    ?? 'Player';
          final gameId      = data['gameId']      ?? 'N/A';
          final xp          = data['xp']          ?? 0;
          final coins       = data['coins']       ?? 0;
          final streak      = data['streak']      ?? 0;
          final level       = data['level']       ?? 1;
          final gamesPlayed = data['gamesPlayed'] ?? 0;
          final wins        = data['wins']        ?? 0;
          final badges      = List<String>.from(data['badges'] ?? ['🎮 Newcomer']);
          final xpToNext    = (level + 1) * 500;
          final xpProgress  = (xp / xpToNext).clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                buildPlayerCard(context, username, gameId, level, xp, xpToNext, xpProgress),
                const SizedBox(height: 14),
                buildStatsRow(gamesPlayed, coins, streak, wins),
                const SizedBox(height: 20),
                sectionTitle('BADGES'),
                const SizedBox(height: 10),
                buildBadges(badges),
                const SizedBox(height: 24),
                buildSignOutBtn(context),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildPlayerCard(BuildContext context, String username, String gameId,
      int level, int xp, int xpToNext, double xpProgress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0D1F3C), const Color(0xFF050A18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF003899)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withOpacity(0.4), width: 2),
              boxShadow: [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 20)],
            ),
            child: const Center(child: Text('🎮', style: TextStyle(fontSize: 34))),
          ),
          const SizedBox(height: 12),
          Text(username,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 4),
          Text('LEVEL $level GAMER',
            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11,
                letterSpacing: 2, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: gameId));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Game ID $gameId copied!',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                backgroundColor: surface,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: gold.withOpacity(0.4)),
                ),
              ));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gold.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.games, color: Color(0xFFFFD700), size: 14),
                  const SizedBox(width: 6),
                  Text('Game ID: $gameId',
                    style: const TextStyle(color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                  const SizedBox(width: 6),
                  const Icon(Icons.copy, color: Color(0xFFFFD700), size: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: xpProgress,
              backgroundColor: bg,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0066FF)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text('$xp / $xpToNext XP to Level ${level + 1}',
            style: TextStyle(color: muted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget buildStatsRow(int gamesPlayed, int coins, int streak, int wins) {
    return Row(
      children: [
        statBox('🎮', '$gamesPlayed', 'PLAYED', primary),
        const SizedBox(width: 10),
        statBox('🪙', '$coins', 'COINS', gold),
        const SizedBox(width: 10),
        statBox('🔥', '$streak', 'STREAK', Colors.orange),
        const SizedBox(width: 10),
        statBox('🏆', '$wins', 'WINS', Colors.green),
      ],
    );
  }

  Widget buildBadges(List<String> badges) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges.map((badge) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: gold.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withOpacity(0.3)),
        ),
        child: Text(badge,
          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w700)),
      )).toList(),
    );
  }

  Widget buildSignOutBtn(BuildContext context) {
    return GestureDetector(
      onTap: () => confirmSignOut(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: red.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFFFF4C6A), size: 18),
            SizedBox(width: 8),
            Text('SIGN OUT',
              style: TextStyle(color: Color(0xFFFF4C6A),
                  fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  void confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: red.withOpacity(0.2)),
        ),
        title: const Text('Sign Out?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        content: const Text('Are you sure you want to sign out?',
          style: TextStyle(color: Color(0xFF8BA3CC), fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(color: muted, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (c) => const AuthScreen()), (r) => false);
              }
            },
            child: const Text('SIGN OUT',
              style: TextStyle(color: Color(0xFFFF4C6A), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget statBox(String icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: muted, fontSize: 8, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3, height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFF0066FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900,
              fontSize: 13, letterSpacing: 1.5)),
      ],
    );
  }
}