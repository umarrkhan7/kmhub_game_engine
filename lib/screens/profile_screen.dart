import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // 🔥 SAME COLORS AS HOME
  static const bg      = Color(0xFF0A1A0F);
  static const surface = Color(0xFF122A1A);
  static const primary = Color(0xFF3A9A5C);
  static const olive   = Color(0xFFA8C878);
  static const dark    = Color(0xFF1F5C35);
  static const muted   = Color(0xFF7AAF8A);

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
          'PROFILE',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 2),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseService.streamUserProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: olive));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final username = data['username'] ?? 'Player';
          final xp = data['xp'] ?? 0;
          final coins = data['coins'] ?? 0;
          final level = data['level'] ?? 1;
          final games = data['gamesPlayed'] ?? 0;
          final wins = data['wins'] ?? 0;
          final streak = data['streak'] ?? 0;

          final xpToNext = (level + 1) * 500;
          final progress = (xp / xpToNext).clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F5C35), Color(0xFF0D2015)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.4),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3A9A5C), Color(0xFF1F5C35)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.6),
                              blurRadius: 20,
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text('🎮', style: TextStyle(fontSize: 36)),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(username,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),

                      const SizedBox(height: 4),

                      Text("LEVEL $level",
                          style: TextStyle(
                              color: olive,
                              fontWeight: FontWeight.w700)),

                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: bg,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(primary),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text("$xp / $xpToNext XP",
                          style: TextStyle(color: muted, fontSize: 11)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    statCard("🎮", "$games", "PLAYED"),
                    statCard("🏆", "$wins", "WINS"),
                    statCard("🪙", "$coins", "COINS"),
                    statCard("🔥", "$streak", "STREAK"),
                  ],
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("BADGES",
                      style: TextStyle(
                          color: olive,
                          fontWeight: FontWeight.w900)),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  children: [
                    badge("🎮 Newbie"),
                    badge("🔥 Active"),
                    badge("🏆 Winner"),
                  ],
                ),

                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => confirmSignOut(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3A9A5C), Color(0xFF1F5C35)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text("SIGN OUT",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget statCard(String icon, String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: olive,
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
          Text(label,
              style: TextStyle(color: muted, fontSize: 10)),
        ],
      ),
    );
  }
  Widget badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Text(text,
          style: TextStyle(color: olive, fontWeight: FontWeight.w700)),
    );
  }

  void confirmSignOut(BuildContext context) async {
    await FirebaseService.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const AuthScreen()));
  }
}