import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static String get currentUid => _auth.currentUser?.uid ?? '';
  static String get currentName => _auth.currentUser?.displayName ?? 'Anonymous';
  static String get currentEmail => _auth.currentUser?.email ?? '';
  static bool get isLoggedIn => _auth.currentUser != null;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await credential.user!.updateDisplayName(username.trim());
      final String gameId = _generateGameId(username.trim());
      await _db.collection('game_players').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'username': username.trim(),
        'email': email.trim(),
        'gameId': gameId,
        'avatar': '',
        'authProvider': 'email',
        'xp': 0,
        'coins': 100,
        'streak': 0,
        'level': 1,
        'gamesPlayed': 0,
        'wins': 0,
        'losses': 0,
        'challengesSent': 0,
        'challengesWon': 0,
        'badges': ['🎮 Newcomer'],
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('SUCCESS - User saved: ${credential.user!.uid} GameID: $gameId');
      return {'success': true, 'message': 'Account created!', 'gameId': gameId};
    } on FirebaseAuthException catch (e) {
      print('AUTH ERROR: ${e.code}');
      return {'success': false, 'message': _getAuthError(e.code)};
    } catch (e) {
      print('FIRESTORE ERROR: $e');
      return {'success': false, 'message': 'Error saving profile: $e'};
    }
  }

  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (currentUid.isNotEmpty) {
        await _db.collection('game_players').doc(currentUid).update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      return {'success': true, 'message': 'Welcome back!'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthError(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return {'success': false, 'message': 'Cancelled.'};
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        final String gameId = _generateGameId(userCredential.user!.displayName ?? 'Player');
        await _db.collection('game_players').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'username': userCredential.user!.displayName ?? 'Player',
          'email': userCredential.user!.email ?? '',
          'gameId': gameId,
          'avatar': userCredential.user!.photoURL ?? '',
          'authProvider': 'google',
          'xp': 0, 'coins': 100, 'streak': 0, 'level': 1,
          'gamesPlayed': 0, 'wins': 0, 'losses': 0,
          'challengesSent': 0, 'challengesWon': 0,
          'badges': ['🎮 Newcomer'],
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return {'success': true, 'message': 'Welcome!'};
    } catch (e) {
      return {'success': false, 'message': 'Google sign in failed: $e'};
    }
  }

  static Future<void> signOut() async {
    try {
      if (currentUid.isNotEmpty) {
        await _db.collection('game_players').doc(currentUid).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {'success': true, 'message': 'Reset email sent!'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthError(e.code)};
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile([String? uid]) async {
    try {
      final doc = await _db.collection('game_players').doc(uid ?? currentUid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      return null;
    }
  }

  static Stream<DocumentSnapshot> streamUserProfile() {
    return _db.collection('game_players').doc(currentUid).snapshots();
  }

  static Future<void> addXPAndCoins({required int xp, required int coins}) async {
    await _db.collection('game_players').doc(currentUid).update({
      'xp': FieldValue.increment(xp),
      'coins': FieldValue.increment(coins),
      'gamesPlayed': FieldValue.increment(1),
    });
  }

  static Future<void> saveScore({required String gameTitle, required int score}) async {
    final ref = _db.collection('leaderboard').doc(gameTitle).collection('scores').doc(currentUid);
    final existing = await ref.get();
    if (!existing.exists || (existing.data()?['score'] ?? 0) < score) {
      await ref.set({
        'uid': currentUid,
        'username': currentName,
        'score': score,
        'gameTitle': gameTitle,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Stream<QuerySnapshot> getLeaderboard(String gameTitle) {
    return _db.collection('leaderboard').doc(gameTitle).collection('scores')
        .orderBy('score', descending: true).limit(20).snapshots();
  }

  static Future<void> sendChallenge({
    required String toUid,
    required String toUsername,
    required String gameTitle,
    required int scoreToBeat,
  }) async {
    await _db.collection('challenges').add({
      'fromUid': currentUid,
      'fromUsername': currentName,
      'toUid': toUid,
      'toUsername': toUsername,
      'gameTitle': gameTitle,
      'scoreToBeat': scoreToBeat,
      'opponentScore': null,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
    });
    await _db.collection('game_players').doc(currentUid).update({
      'challengesSent': FieldValue.increment(1),
    });
  }

  static Stream<QuerySnapshot> getIncomingChallenges() {
    return _db.collection('challenges')
        .where('toUid', isEqualTo: currentUid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  static Future<Map<String, dynamic>?> searchByGameId(String gameId) async {
    final result = await _db.collection('game_players')
        .where('gameId', isEqualTo: gameId.toUpperCase().trim())
        .limit(1).get();
    if (result.docs.isEmpty) return null;
    return result.docs.first.data();
  }

  static String _generateGameId(String username) {
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    final clean = username.replaceAll(' ', '').toUpperCase();
    final prefix = clean.length >= 4 ? clean.substring(0, 4) : clean;
    return '$prefix#$random';
  }

  static String _getAuthError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'This email is already registered.';
      case 'invalid-email': return 'Please enter a valid email address.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password. Try again.';
      case 'too-many-requests': return 'Too many attempts. Try again later.';
      case 'network-request-failed': return 'No internet connection.';
      default: return 'Authentication failed. Try again.';
    }
  }
}