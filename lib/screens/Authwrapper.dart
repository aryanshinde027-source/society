import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:society_management/screens/Dashboard.dart';
import 'package:society_management/screens/login/login_screen.dart';
import 'package:society_management/screens/secretaryDashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  static const Color bg = Color(0xFF0B1120);
  static const Color blue = Color(0xFF60A5FA);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Authentication loading
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // User is not logged in
        final user = authSnapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        // Fetch the logged-in user's role from Firestore
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (roleSnapshot.hasError) {
              return _ErrorScreen(
                message: 'Unable to load your account details.',
                onRetry: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                  );
                },
              );
            }

            if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
              return _ErrorScreen(
                message:
                    'User profile not found. Please contact the administrator.',
                onRetry: () async {
                  await FirebaseAuth.instance.signOut();
                },
              );
            }

            final data = roleSnapshot.data!.data();
            final role = (data?['role'] ?? '').toString().trim().toLowerCase();

            // Secretary dashboard
            if (role == 'secretary') {
              return const SecretaryDashboard();
            }

            // Resident dashboard
            if (role == 'resident') {
              return const DashboardScreen();
            }

            // Unknown or missing role
            return _ErrorScreen(
              message:
                  'Invalid account role. Please contact the administrator.',
              onRetry: () async {
                await FirebaseAuth.instance.signOut();
              },
            );
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AuthWrapper.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AuthWrapper.blue),
            SizedBox(height: 16),
            Text(
              'Loading your dashboard...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorScreen({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthWrapper.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.orangeAccent,
                size: 55,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry / Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
