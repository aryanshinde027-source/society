import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:society_management/screens/maint.dart';
import 'package:society_management/screens/secretaryfacilityapproval.dart';
import 'package:society_management/screens/society.dart';

import 'Complaints.dart';
import 'Registers.dart';
import 'flat.dart';
import 'notice.dart';
import 'profile.dart';
import 'visitors.dart';

class SecretaryDashboard extends StatelessWidget {
  const SecretaryDashboard({super.key});

  static const Color bg = Color(0xFF0B1120);
  static const Color surface = Color(0xFF151F32);
  static const Color blue = Color(0xFF60A5FA);
  static const Color muted = Color(0xFF94A3B8);

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surface,
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: muted),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(
        'Complaints',
        'View and manage complaints',
        Icons.report_problem_rounded,
        const Color(0xFFF87171),
        () => _open(context, const ComplaintsScreen()),
      ),
      _Feature(
        'Booking Approval',
        'Review facility bookings',
        Icons.event_available_rounded,
        const Color(0xFF60A5FA),
        () => _open(context, const SecretaryFacilityManagementScreen()),
      ),
      _Feature(
        'Notices',
        'Add and manage notices',
        Icons.campaign_rounded,
        const Color(0xFFFBBF24),
        () => _open(context, const NoticesScreen()),
      ),
      _Feature(
        'Maintenance',
        'Manage maintenance records',
        Icons.account_balance_wallet_rounded,
        const Color(0xFF34D399),
        () => _open(context, const MaintainceScreen()),
      ),
      _Feature(
        'Visitors',
        'View visitor information',
        Icons.people_alt_rounded,
        const Color(0xFFC084FC),
        () => _open(context, const VisitorsScreen()),
      ),
      _Feature(
        'Residents',
        'View resident records',
        Icons.groups_rounded,
        const Color(0xFF22D3EE),
        () => _open(context, const ResidentScreen()),
      ),
      _Feature(
        'Flats',
        'Manage flat information',
        Icons.apartment_rounded,
        const Color(0xFFFB923C),
        () => _open(context, const FlatScreen()),
      ),
      _Feature(
        'Society',
        'Manage society details',
        Icons.apartment_rounded,
        const Color(0xFFFB923C),
        () => _open(context, const SocietyScreen()),
      ),
      _Feature(
        'My Profile',
        'View your profile',
        Icons.person_rounded,
        const Color(0xFF818CF8),
        () => _open(context, const ProfileScreen()),
      ),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Secretary Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Profile Icon
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              _open(context, const ProfileScreen());
            },
            icon: const Icon(Icons.account_circle_outlined, size: 27),
          ),

          // Logout Icon
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(
              Icons.logout_rounded,
              size: 25,
              color: Colors.redAccent,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1D4ED8),
                      Color(0xFF1E3A8A),
                      Color(0xFF172554),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Welcome, Secretary!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Manage society activities from one place.',
                      style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 14),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 17,
                          color: Color(0xFF86EFAC),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Secretary Access',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Select a section to continue',
                style: TextStyle(color: muted, fontSize: 14),
              ),

              const SizedBox(height: 18),

              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 700 ? 3 : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: features.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: columns == 3 ? 1.05 : 0.88,
                    ),
                    itemBuilder: (context, index) {
                      final item = features[index];

                      return Material(
                        color: surface,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: item.onTap,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(11),
                                  decoration: BoxDecoration(
                                    color: item.color.withValues(alpha: 0.13),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: item.color,
                                    size: 25,
                                  ),
                                ),

                                const Spacer(),

                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  item.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 11,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: item.color,
                                    size: 19,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: blue, size: 25),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Society Administration',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Keep society records organized and up to date.',
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _Feature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _Feature(this.title, this.subtitle, this.icon, this.color, this.onTap);
}
