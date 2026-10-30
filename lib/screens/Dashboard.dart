import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:society_management/screens/ai%20complaintscreen.dart';
import 'package:society_management/screens/ai.dart';

import 'package:society_management/screens/maint.dart';

import 'package:society_management/screens/Complaints.dart';

import 'package:society_management/screens/notice.dart';
import 'package:society_management/screens/residentfacilitybooking.dart';
import 'package:society_management/screens/residentmaintenance.dart';
import 'package:society_management/screens/residentnoticescreen.dart';

import 'package:society_management/screens/visitors.dart';

import 'package:society_management/screens/profile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color background = Color(0xFF0B1120);
  static const Color surface = Color(0xFF151F32);
  static const Color primaryBlue = Color(0xFF60A5FA);
  static const Color muted = Color(0xFF94A3B8);

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surface,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.apartment_rounded, color: primaryBlue, size: 30),
            SizedBox(width: 10),
            Text(
              'SocietyHub',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'My Profile',
            onPressed: () {
              _navigate(context, const ProfileScreen());
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 5),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1D4ED8),
                      Color(0xFF2563EB),
                      Color(0xFF0F766E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.waving_hand_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user?.displayName?.isNotEmpty == true
                          ? user!.displayName!
                          : 'Society Member',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Manage your society, residents, facilities '
                      'and daily activities from one place.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white,
                            size: 17,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Society Management Portal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Section heading
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Quick Services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.grid_view_rounded, color: primaryBlue),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Select a service to get started',
                style: TextStyle(color: muted, fontSize: 13),
              ),

              const SizedBox(height: 20),

              // Service cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.91,
                children: [
                  _serviceCard(
                    context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Maintenance',
                    subtitle: 'Manage payments and dues',
                    color: const Color(0xFFFBBF24),
                    onTap: () =>
                        _navigate(context, const ResidentMaintenanceScreen()),
                  ),

                  _serviceCard(
                    context,
                    icon: Icons.report_problem_rounded,
                    title: 'Complaints',
                    subtitle: 'Track complaints',
                    color: const Color(0xFFFB7185),
                    onTap: () => _navigate(context, const ComplaintsScreen()),
                  ),

                  _serviceCard(
                    context,
                    icon: Icons.campaign_rounded,
                    title: 'Notices',
                    subtitle: 'Society announcements',
                    color: const Color(0xFFA78BFA),
                    onTap: () =>
                        _navigate(context, const ResidentNoticeScreen()),
                  ),

                  _serviceCard(
                    context,
                    icon: Icons.directions_walk_rounded,
                    title: 'Visitors',
                    subtitle: 'Visitor records',
                    color: const Color(0xFF22D3EE),
                    onTap: () => _navigate(context, const VisitorsScreen()),
                  ),

                  _serviceCard(
                    context,
                    icon: Icons.person_rounded,
                    title: 'My Profile',
                    subtitle: 'View profile details',
                    color: const Color(0xFFF472B6),
                    onTap: () => _navigate(context, const ProfileScreen()),
                  ),

                  _serviceCard(
                    context,
                    icon: Icons.auto_awesome_rounded,
                    title: 'AI Assistant',
                    subtitle: 'Ask society-related questions',
                    color: const Color(0xFFC084FC),
                    onTap: () => _navigate(context, const AiChatScreen()),
                  ),

                  _serviceCard(
                    context,
                    icon: Icons.psychology_rounded,
                    title: 'AI Complaint Help',
                    subtitle: 'Get complaint suggestions',
                    color: const Color(0xFFF472B6),
                    onTap: () => _navigate(context, const AiComplaintScreen()),
                  ),
                  _serviceCard(
                    context,
                    icon: Icons.event_available_rounded,
                    title: 'Facility Booking',
                    subtitle: 'Manage bookings',
                    color: const Color(0xFF34D399),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ResidentFacilityBookingScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Information card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF263449)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: primaryBlue, size: 30),
                    SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Everything in one place',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Access society services and manage '
                            'daily activities through a single portal.',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: Text(
                  'SocietyHub • Society Management System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted.withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable service card
  Widget _serviceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF263449)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 27),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: muted, fontSize: 11, height: 1.4),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.arrow_forward_rounded, size: 18, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
