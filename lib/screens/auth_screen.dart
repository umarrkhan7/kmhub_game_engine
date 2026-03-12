import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isSignIn = true;
  bool _isLoading = false;
  bool _passVisible = false;
  bool _confirmPassVisible = false;
  String? _errorMsg;
  String? _successMsg;

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _signInEmailCtrl = TextEditingController();
  final _signInPassCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    _signInEmailCtrl.dispose();
    _signInPassCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    setState(() { _errorMsg = msg; _successMsg = null; });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _errorMsg = null);
    });
  }

  void _showSuccess(String msg) {
    setState(() { _successMsg = msg; _errorMsg = null; });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _successMsg = null);
    });
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _handleSignIn() async {
    final email = _signInEmailCtrl.text.trim();
    final pass = _signInPassCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      _showError('Please fill all fields');
      return;
    }
    setState(() => _isLoading = true);
    final result = await FirebaseService.signIn(email: email, password: pass);
    setState(() => _isLoading = false);
    if (result['success']) {
      _goHome();
    } else {
      _showError(result['message']);
    }
  }

  Future<void> _handleSignUp() async {
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();
    final confirm = _confirmPassCtrl.text.trim();

    if (username.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showError('Please fill all fields');
      return;
    }
    if (username.length < 3) {
      _showError('Username must be at least 3 characters');
      return;
    }
    if (pass != confirm) {
      _showError('Passwords do not match');
      return;
    }
    if (pass.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    final result = await FirebaseService.signUp(
      username: username,
      email: email,
      password: pass,
    );
    setState(() => _isLoading = false);

    if (result['success']) {
      _goHome();
    } else {
      _showError(result['message']);
    }
  }

  Future<void> _handleGoogle() async {
    setState(() => _isLoading = true);
    final result = await FirebaseService.signInWithGoogle();
    setState(() => _isLoading = false);
    if (result['success']) {
      _goHome();
    } else {
      _showError(result['message']);
    }
  }

  Future<void> _handleForgotPass() async {
    final email = _signInEmailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Enter your email first then tap forgot password');
      return;
    }
    final result = await FirebaseService.resetPassword(email);
    if (result['success']) {
      _showSuccess(result['message']);
    } else {
      _showError(result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060812),
      body: Stack(
        children: [
          // ── BACKGROUND ────────────────────────────
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7209B7).withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00F5D4).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── CONTENT ───────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),

                    // Logo
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00F5D4), Color(0xFF7209B7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00F5D4).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🎮', style: TextStyle(fontSize: 30)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                              children: [
                                TextSpan(
                                  text: 'ARCADE',
                                  style: TextStyle(color: Color(0xFF00F5D4)),
                                ),
                                TextSpan(
                                  text: 'HUB',
                                  style: TextStyle(color: Color(0xFFF72585)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Play · Compete · Win',
                            style: TextStyle(
                              color: Color(0xFF8892B0),
                              fontSize: 13,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── TOGGLE SIGN IN / SIGN UP ───────
                    Container(
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1224),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF00F5D4).withOpacity(0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          _toggleBtn('Sign In', _isSignIn, () {
                            setState(() => _isSignIn = true);
                          }),
                          _toggleBtn('Sign Up', !_isSignIn, () {
                            setState(() => _isSignIn = false);
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── ERROR / SUCCESS MESSAGE ────────
                    if (_errorMsg != null)
                      _alertBox(_errorMsg!, false),
                    if (_successMsg != null)
                      _alertBox(_successMsg!, true),

                    // ── FORMS ─────────────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _isSignIn
                          ? _buildSignInForm()
                          : _buildSignUpForm(),
                    ),
                    const SizedBox(height: 24),

                    // ── DIVIDER ───────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: const Color(0xFF00F5D4).withOpacity(0.12),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: TextStyle(
                              color: const Color(0xFF8892B0).withOpacity(0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: const Color(0xFF00F5D4).withOpacity(0.12),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── GOOGLE BUTTON ─────────────────
                    _googleBtn(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // ── LOADING OVERLAY ───────────────────────
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF00F5D4),
                      strokeWidth: 2.5,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Please wait...',
                      style: TextStyle(
                        color: Color(0xFF8892B0),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── SIGN IN FORM ──────────────────────────────────
  Widget _buildSignInForm() {
    return Column(
      key: const ValueKey('signin'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('EMAIL ADDRESS'),
        const SizedBox(height: 6),
        _field(
          controller: _signInEmailCtrl,
          hint: 'your@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _label('PASSWORD'),
        const SizedBox(height: 6),
        _field(
          controller: _signInPassCtrl,
          hint: '••••••••',
          icon: Icons.lock_outline,
          isPassword: true,
          isVisible: _passVisible,
          onToggle: () => setState(() => _passVisible = !_passVisible),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _handleForgotPass,
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: Color(0xFF00F5D4),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _primaryBtn('SIGN IN', _handleSignIn),
      ],
    );
  }

  // ── SIGN UP FORM ──────────────────────────────────
  Widget _buildSignUpForm() {
    return Column(
      key: const ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('USERNAME'),
        const SizedBox(height: 6),
        _field(
          controller: _usernameCtrl,
          hint: 'Your gamer name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 6),
        // Game ID hint
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00F5D4).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color(0xFF00F5D4).withOpacity(0.12)),
          ),
          // child: Row(
          //   children: [
          //     const Text('🎮', style: TextStyle(fontSize: 12)),
          //     const SizedBox(width: 6),
          //     Expanded(
          //       child: Text(
          //       ,
          //         style: TextStyle(
          //           color: const Color(0xFF8892B0).withOpacity(0.8),
          //           fontSize: 10,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ),
        const SizedBox(height: 14),
        _label('EMAIL ADDRESS'),
        const SizedBox(height: 6),
        _field(
          controller: _emailCtrl,
          hint: 'your@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _label('PASSWORD'),
        const SizedBox(height: 6),
        _field(
          controller: _passwordCtrl,
          hint: 'Min 6 characters',
          icon: Icons.lock_outline,
          isPassword: true,
          isVisible: _passVisible,
          onToggle: () => setState(() => _passVisible = !_passVisible),
        ),
        const SizedBox(height: 14),
        _label('CONFIRM PASSWORD'),
        const SizedBox(height: 6),
        _field(
          controller: _confirmPassCtrl,
          hint: 'Repeat password',
          icon: Icons.lock_outline,
          isPassword: true,
          isVisible: _confirmPassVisible,
          onToggle: () => setState(() => _confirmPassVisible = !_confirmPassVisible),
        ),
        const SizedBox(height: 24),
        _primaryBtn('CREATE ACCOUNT', _handleSignUp),
      ],
    );
  }

  // ── REUSABLE WIDGETS ──────────────────────────────

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF00F5D4).withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active
                ? Border.all(color: const Color(0xFF00F5D4).withOpacity(0.4))
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFF00F5D4) : const Color(0xFF8892B0),
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

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8892B0),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _field({
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
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF8892B0).withOpacity(0.5),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF8892B0), size: 18),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF8892B0),
                  size: 18,
                ),
                onPressed: onToggle,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF0D1224),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF00F5D4).withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF00F5D4).withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00F5D4), width: 1.5),
        ),
      ),
    );
  }

  Widget _primaryBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00F5D4), Color(0xFF00B4CC)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F5D4).withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF060812),
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleBtn() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleGoogle,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4285F4),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Continue with Google',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertBox(String msg, bool isSuccess) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSuccess
            ? const Color(0xFF00F5D4).withOpacity(0.08)
            : const Color(0xFFF72585).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSuccess
              ? const Color(0xFF00F5D4).withOpacity(0.3)
              : const Color(0xFFF72585).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(isSuccess ? '✅ ' : '❌ ', style: const TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: isSuccess ? const Color(0xFF00F5D4) : const Color(0xFFF72585),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}