import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  String selectedRole = 'resident';

  bool loading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  static const Color navy = Color(0xFF142B50);
  static const Color blue = Color(0xFF245DA5);
  static const Color gold = Color(0xFFD9B66E);
  static const Color background = Color(0xFFF3F5FA);
  static const Color muted = Color(0xFF8993A2);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  // REGISTER USER
  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    User? user;

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      user = credential.user;

      if (user == null) {
        throw Exception('Account creation failed');
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await user.updateDisplayName(nameController.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to login screen.
      // AuthWrapper can handle the signed-in user if configured.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (user != null) {
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ROLE CARD
  Widget roleCard({
    required String title,
    required String role,
    required IconData icon,
  }) {
    final selected = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: loading
            ? null
            : () {
                setState(() {
                  selectedRole = role;
                });
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF0FA) : const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? blue : const Color(0xFFE0E4EB),
              width: selected ? 1.7 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? blue : muted, size: 27),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 7),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? blue : muted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TEXT FIELD
  Widget inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool password = false,
    bool hide = false,
    VoidCallback? toggle,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: password && hide,
      keyboardType: keyboard,
      validator: validator,
      style: const TextStyle(color: navy, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: muted, fontSize: 16),
        prefixIcon: Icon(icon, color: navy, size: 26),
        suffixIcon: password
            ? IconButton(
                onPressed: toggle,
                icon: Icon(
                  hide
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: muted,
                  size: 25,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE1E5EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE1E5EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: navy, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // LOGO
                    Container(
                      height: 115,
                      width: 115,
                      decoration: BoxDecoration(
                        color: navy,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: navy.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.apartment_rounded,
                            color: Colors.white,
                            size: 68,
                          ),
                          Positioned(
                            bottom: 12,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: gold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: navy,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Join Your Society',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: navy,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Create your account to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, fontSize: 17),
                    ),

                    const SizedBox(height: 48),

                    // FORM CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(23),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(color: const Color(0xFFE7EAF0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Details',
                            style: TextStyle(
                              color: navy,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Enter your details below.',
                            style: TextStyle(color: muted, fontSize: 16),
                          ),

                          const SizedBox(height: 28),

                          // ROLE SELECTION
                          const Text(
                            'SELECT YOUR ROLE',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 13),

                          Row(
                            children: [
                              roleCard(
                                title: 'Resident',
                                role: 'resident',
                                icon: Icons.person_rounded,
                              ),
                              const SizedBox(width: 12),
                              roleCard(
                                title: 'Secretary',
                                role: 'secretary',
                                icon: Icons.admin_panel_settings_rounded,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // FULL NAME
                          inputField(
                            controller: nameController,
                            hint: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // EMAIL
                          inputField(
                            controller: emailController,
                            hint: 'Email Address',
                            icon: Icons.email_outlined,
                            keyboard: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null ||
                                  !RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(v.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // PASSWORD
                          inputField(
                            controller: passwordController,
                            hint: 'Password',
                            icon: Icons.lock_outline,
                            password: true,
                            hide: hidePassword,
                            toggle: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            validator: (v) {
                              if (v == null || v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // CONFIRM PASSWORD
                          inputField(
                            controller: confirmController,
                            hint: 'Confirm Password',
                            icon: Icons.lock_reset_rounded,
                            password: true,
                            hide: hideConfirmPassword,
                            toggle: () {
                              setState(() {
                                hideConfirmPassword = !hideConfirmPassword;
                              });
                            },
                            validator: (v) {
                              if (v != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          // CREATE ACCOUNT BUTTON
                          SizedBox(
                            height: 65,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loading ? null : register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: navy,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'CREATE ACCOUNT',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 25,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // SECURE REGISTRATION
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  'SECURE REGISTRATION',
                                  style: TextStyle(
                                    color: muted,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    // SIGN IN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: muted, fontSize: 15),
                        ),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
