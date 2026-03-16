import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  @override
  State<AuthScreen> createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  bool isLoading = false;
  bool passVisible = false;
  bool confirmPassVisible = false;
  String? errorMsg;
  String? successMsg;

  final usernameCtrl    = TextEditingController();
  final emailCtrl       = TextEditingController();
  final passwordCtrl    = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final signInEmailCtrl = TextEditingController();
  final signInPassCtrl  = TextEditingController();

  static const bg      = Color(0xFF050A18);
  static const surface = Color(0xFF0D1F3C);
  static const primary = Color(0xFF0066FF);
  static const gold    = Color(0xFFFFD700);
  static const muted   = Color(0xFF8BA3CC);
  static const red     = Color(0xFFFF4C6A);

  @override
  void dispose() {
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPassCtrl.dispose();
    signInEmailCtrl.dispose();
    signInPassCtrl.dispose();
    super.dispose();
  }

  void showError(String msg) {
    setState(() { errorMsg = msg; successMsg = null; });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => errorMsg = null);
    });
  }

  void showSuccess(String msg) {
    setState(() { successMsg = msg; errorMsg = null; });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => successMsg = null);
    });
  }

  void goHome() => Navigator.pushReplacement(
    context, MaterialPageRoute(builder: (c) => const HomeScreen()));

  Future<void> handleSignIn() async {
    final email = signInEmailCtrl.text.trim();
    final pass  = signInPassCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      showError('Please fill all fields');
      return;
    }
    if (!isValidEmail(email)) {
      showError('Please enter a valid email address');
      return;
    }
    setState(() => isLoading = true);
    final result = await FirebaseService.signIn(email: email, password: pass);
    setState(() => isLoading = false);
    if (result['success']) {
      await NotificationService.showLocalNotification(
        title: 'Arcade Hub 🎮',
        body: 'Welcome back to Arcade Hub!',
        id: 1,
      );
      await Future.delayed(const Duration(milliseconds: 800));
      goHome();
    } else {
      await NotificationService.showLocalNotification(
        title: 'Arcade Hub ❌',
        body: result['message'],
        id: 2,
      );
      showError(result['message']);
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  Future<void> showNotification(String msg, bool success) async {
    await NotificationService.showLocalNotification(
      title: success ? 'Arcade Hub 🎮' : 'Arcade Hub ❌',
      body: msg,
      id: success ? 1 : 2,
    );
  }

  Future<void> handleSignUp() async {
    final username = usernameCtrl.text.trim();
    final email    = emailCtrl.text.trim();
    final pass     = passwordCtrl.text.trim();
    final confirm  = confirmPassCtrl.text.trim();

    if (username.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      showError('Please fill all fields');
      return;
    }
    if (username.length < 3) {
      showError('Username must be at least 3 characters');
      return;
    }
    if (!isValidEmail(email)) {
      showError('Please enter a valid email e.g. name@gmail.com');
      return;
    }
    if (pass != confirm) {
      showError('Passwords do not match');
      return;
    }
    if (pass.length < 6) {
      showError('Password must be at least 6 characters');
      return;
    }
    setState(() => isLoading = true);
    final result = await FirebaseService.signUp(username: username, email: email, password: pass);
    setState(() => isLoading = false);
    if (result['success']) {
      await NotificationService.showLocalNotification(
        title: 'Arcade Hub 🎮',
        body: 'Account created successfully! Welcome to Arcade Hub',
        id: 3,
      );
      await Future.delayed(const Duration(milliseconds: 1000));
      goHome();
    } else {
      await NotificationService.showLocalNotification(
        title: 'Arcade Hub ❌',
        body: result['message'],
        id: 4,
      );
      showError(result['message']);
    }
  }

  Future<void> handleGoogle() async {
    setState(() => isLoading = true);
    final result = await FirebaseService.signInWithGoogle();
    setState(() => isLoading = false);
    if (result['success']) goHome(); else showError(result['message']);
  }

  Future<void> handleForgotPass() async {
    if (signInEmailCtrl.text.trim().isEmpty) {
      showError('Enter your email first');
      return;
    }
    final result = await FirebaseService.resetPassword(signInEmailCtrl.text);
    if (result['success']) showSuccess(result['message']);
    else showError(result['message']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  primary.withOpacity(0.18),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  gold.withOpacity(0.10),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0066FF), Color(0xFF003899)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: gold.withOpacity(0.4), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(child: Text('🎮', style: TextStyle(fontSize: 34))),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 3),
                            children: [
                              TextSpan(text: 'ARCADE', style: TextStyle(color: Color(0xFFFFD700))),
                              TextSpan(text: 'HUB',    style: TextStyle(color: Color(0xFF0066FF))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('PLAY · COMPETE · DOMINATE',
                          style: TextStyle(color: muted.withOpacity(0.7), fontSize: 11, letterSpacing: 2.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        toggleBtn('Sign In', isSignIn, () => setState(() => isSignIn = true)),
                        toggleBtn('Sign Up', !isSignIn, () => setState(() => isSignIn = false)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (errorMsg != null) alertBox(errorMsg!, false),
                  if (successMsg != null) alertBox(successMsg!, true),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: isSignIn ? buildSignInForm() : buildSignUpForm(),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: Divider(color: primary.withOpacity(0.15))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR', style: TextStyle(color: muted.withOpacity(0.5), fontSize: 10, letterSpacing: 2)),
                      ),
                      Expanded(child: Divider(color: primary.withOpacity(0.15))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  googleBtn(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.65),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 2.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSignInForm() {
    return Column(
      key: const ValueKey('signin'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldLabel('EMAIL ADDRESS'),
        const SizedBox(height: 6),
        inputField(controller: signInEmailCtrl, hint: 'your@email.com',
            icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),
        fieldLabel('PASSWORD'),
        const SizedBox(height: 6),
        inputField(controller: signInPassCtrl, hint: '••••••••',
            icon: Icons.lock_outline, isPassword: true,
            isVisible: passVisible, onToggle: () => setState(() => passVisible = !passVisible)),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: handleForgotPass,
            child: const Text('Forgot Password?',
              style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 22),
        primaryBtn('SIGN IN', handleSignIn),
      ],
    );
  }

  Widget buildSignUpForm() {
    return Column(
      key: const ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldLabel('USERNAME'),
        const SizedBox(height: 6),
        inputField(controller: usernameCtrl, hint: 'Your gamer tag', icon: Icons.person_outline),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: gold.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Text('🎮', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Expanded(child: Text(
                'Auto-generates your unique Game ID',
                style: TextStyle(color: muted.withOpacity(0.8), fontSize: 10),
              )),
            ],
          ),
        ),
        const SizedBox(height: 14),
        fieldLabel('EMAIL ADDRESS'),
        const SizedBox(height: 6),
        inputField(controller: emailCtrl, hint: 'your@email.com',
            icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),
        fieldLabel('PASSWORD'),
        const SizedBox(height: 6),
        inputField(controller: passwordCtrl, hint: 'Min 6 characters',
            icon: Icons.lock_outline, isPassword: true,
            isVisible: passVisible, onToggle: () => setState(() => passVisible = !passVisible)),
        const SizedBox(height: 14),
        fieldLabel('CONFIRM PASSWORD'),
        const SizedBox(height: 6),
        inputField(controller: confirmPassCtrl, hint: 'Repeat password',
            icon: Icons.lock_outline, isPassword: true,
            isVisible: confirmPassVisible,
            onToggle: () => setState(() => confirmPassVisible = !confirmPassVisible)),
        const SizedBox(height: 22),
        primaryBtn('CREATE ACCOUNT', handleSignUp),
      ],
    );
  }

  Widget toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: active ? const LinearGradient(
              colors: [Color(0xFF0066FF), Color(0xFF003899)],
            ) : null,
            borderRadius: BorderRadius.circular(10),
            border: active ? Border.all(color: gold.withOpacity(0.3)) : null,
            boxShadow: active ? [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 10)] : null,
          ),
          child: Center(
            child: Text(label,
              style: TextStyle(
                color: active ? Colors.white : muted,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget fieldLabel(String text) => Text(text,
    style: TextStyle(color: muted.withOpacity(0.7), fontSize: 10,
        fontWeight: FontWeight.w700, letterSpacing: 1.5));

  Widget inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: muted.withOpacity(0.35), fontSize: 13),
        prefixIcon: Icon(icon, color: muted, size: 18),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: muted, size: 18),
          onPressed: onToggle,
        ) : null,
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primary.withOpacity(0.15))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primary.withOpacity(0.15))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: gold.withOpacity(0.6), width: 1.5)),
      ),
    );
  }

  Widget primaryBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFE6A800)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: gold.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(child: Text(label,
          style: const TextStyle(color: Color(0xFF050A18),
              fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2))),
      ),
    );
  }

  Widget googleBtn() {
    return GestureDetector(
      onTap: isLoading ? null : handleGoogle,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4285F4)),
              child: const Center(child: Text('G',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13))),
            ),
            const SizedBox(width: 10),
            const Text('Continue with Google',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget alertBox(String msg, bool isSuccess) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSuccess ? gold.withOpacity(0.07) : red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSuccess ? gold.withOpacity(0.3) : red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(isSuccess ? '✅ ' : '❌ ', style: const TextStyle(fontSize: 13)),
          Expanded(child: Text(msg,
            style: TextStyle(color: isSuccess ? gold : red, fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}