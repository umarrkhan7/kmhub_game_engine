import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060812),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1224),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF00F5D4), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('PROFILE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 2,
            )),
        actions: [
          // SIGN OUT BUTTON
          TextButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout, color: Color(0xFFF72585), size: 18),
            label: const Text('Sign Out',
                style: TextStyle(
                  color: Color(0xFFF72585),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                )),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF00F5D4).withOpacity(0.15)),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseService.streamUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00F5D4)),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Profile not found',
                  style: TextStyle(color: Color(0xFF8892B0))),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final username = data['username'] ?? 'Player';
          final gameId = data['gameId'] ?? 'N/A';
          final xp = data['xp'] ?? 0;
          final coins = data['coins'] ?? 0;
          final streak = data['streak'] ?? 0;
          final level = data['level'] ?? 1;
          final gamesPlayed = data['gamesPlayed'] ?? 0;
          final wins = data['wins'] ?? 0;
          final badges = List<String>.from(data['badges'] ?? ['🎮 Newcomer']);
          final xpToNext = (level + 1) * 500;
          final xpProgress = (xp / xpToNext).clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── PLAYER CARD ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7209B7).withOpacity(0.2),
                        const Color(0xFF0D1224),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF00F5D4).withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7209B7), Color(0xFFF72585)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7209B7).withOpacity(0.4),
                              blurRadius: 20,
                            )
                          ],
                        ),
                        child: const Center(
                            child: Text('🎮', style: TextStyle(fontSize: 32))),
                      ),
                      const SizedBox(height: 10),

                      // Username
                      Text(username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          )),
                      const SizedBox(height: 4),

                      // Level
                      Text('LEVEL $level · GAMER',
                          style: const TextStyle(
                            color: Color(0xFF00F5D4),
                            fontSize: 12,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 14),

                      // Game ID — tap to copy
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: gameId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Game ID $gameId copied!',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                              backgroundColor: const Color(0xFF0D1224),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Color(0xFF00F5D4)),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F5D4).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF00F5D4).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.games,
                                  color: Color(0xFF00F5D4), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Game ID: $gameId',
                                style: const TextStyle(
                                  color: Color(0xFF00F5D4),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.copy,
                                  color: Color(0xFF00F5D4), size: 12),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // XP Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: xpProgress,
                          backgroundColor: const Color(0xFF131828),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF00F5D4)),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$xp / $xpToNext XP to Level ${level + 1}',
                        style: const TextStyle(
                            color: Color(0xFF8892B0), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── STATS ────────────────────────────────
                Row(
                  children: [
                    _statBox('🎮', '$gamesPlayed', 'PLAYED', const Color(0xFF00F5D4)),
                    const SizedBox(width: 10),
                    _statBox('🪙', '$coins', 'COINS', const Color(0xFFFFD700)),
                    const SizedBox(width: 10),
                    _statBox('🔥', '$streak', 'STREAK', const Color(0xFFFF6B35)),
                    const SizedBox(width: 10),
                    _statBox('🏆', '$wins', 'WINS', const Color(0xFFB48EFF)),
                  ],
                ),
                const SizedBox(height: 20),

                // ── BADGES ───────────────────────────────
                _sectionTitle('BADGES'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: badges.map((badge) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1224),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.4)),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ── SIGN OUT BUTTON ──────────────────────
                GestureDetector(
                  onTap: () => _confirmSignOut(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF72585).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFF72585).withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Color(0xFFF72585), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'SIGN OUT',
                          style: TextStyle(
                            color: Color(0xFFF72585),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1224),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF00F5D4).withOpacity(0.2)),
        ),
        title: const Text('Sign Out?',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Color(0xFF8892B0), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL',
                style: TextStyle(
                    color: Color(0xFF8892B0), fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('SIGN OUT',
                style: TextStyle(
                    color: Color(0xFFF72585), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1224),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: const Color(0xFF00F5D4).withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF8892B0),
                    fontSize: 8,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00F5D4), Color(0xFFF72585)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.5,
            )),
      ],
    );
  }
}