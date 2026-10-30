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

  static const Color bg = Color(0xFFF4F7FC);
  static const Color surface = Colors.white;
  static const Color blue = Color(0xFF153B65);
  static const Color muted = Color(0xFF718096);

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Logout', style: TextStyle(color: blue)),
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
        const Color(0xFFE34F4F),
        const Color(0xFFFFE8E8),
        () => _open(context, const ComplaintsScreen()),
      ),
      _Feature(
        'Booking Approval',
        'Review facility bookings',
        Icons.event_available_rounded,
        const Color(0xFF2467B5),
        const Color(0xFFE4F0FF),
        () => _open(context, const SecretaryFacilityManagementScreen()),
      ),
      _Feature(
        'Notices',
        'Add and manage notices',
        Icons.campaign_rounded,
        const Color(0xFF7846C8),
        const Color(0xFFF0E6FF),
        () => _open(context, const NoticesScreen()),
      ),
      _Feature(
        'Maintenance',
        'Manage maintenance records',
        Icons.account_balance_wallet_rounded,
        const Color(0xFFC38B27),
        const Color(0xFFFFF1D9),
        () => _open(context, const MaintainceScreen()),
      ),
      _Feature(
        'Visitors',
        'View visitor information',
        Icons.people_alt_rounded,
        const Color(0xFF159B85),
        const Color(0xFFDDF7F0),
        () => _open(context, const VisitorsScreen()),
      ),
      _Feature(
        'Residents',
        'View resident records',
        Icons.groups_rounded,
        const Color(0xFF148C79),
        const Color(0xFFDDF7F0),
        () => _open(context, const ResidentScreen()),
      ),
      _Feature(
        'Flats',
        'Manage flat information',
        Icons.apartment_rounded,
        const Color(0xFF2563B5),
        const Color(0xFFE4EEFF),
        () => _open(context, const FlatScreen()),
      ),
      _Feature(
        'Society',
        'Manage society details',
        Icons.apartment_rounded,
        const Color(0xFFB78A32),
        const Color(0xFFFFF2D9),
        () => _open(context, const SocietyScreen()),
      ),
      _Feature(
        'My Profile',
        'View your profile',
        Icons.person_rounded,
        const Color(0xFFCA478A),
        const Color(0xFFFFE6F1),
        () => _open(context, const ProfileScreen()),
      ),
    ];

    return Scaffold(
      backgroundColor: bg,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: blue,
        elevation: 0,
        surfaceTintColor: Colors.white,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.apartment_rounded, color: Color(0xFFD5A94F), size: 30),
            SizedBox(width: 10),
            Text(
              'SocietyHub',
              style: TextStyle(
                color: blue,
                fontWeight: FontWeight.w800,
                fontSize: 21,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              _open(context, const ProfileScreen());
            },
            icon: const Icon(Icons.account_circle_outlined, size: 27),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded, size: 25),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // BODY
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // WELCOME BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF102F52), Color(0xFF145BA1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Icon(
                        Icons.apartment_rounded,
                        size: 120,
                        color: Colors.white.withOpacity(0.09),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.waving_hand_rounded,
                            color: Color(0xFFFFD36A),
                            size: 30,
                          ),
                        ),

                        const SizedBox(height: 17),

                        const Text(
                          'WELCOME BACK',
                          style: TextStyle(
                            color: Color(0xFFFFD36A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.4,
                          ),
                        ),

                        const SizedBox(height: 7),

                        const Text(
                          'Secretary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Your community, managed in one place.',
                          style: TextStyle(
                            color: Color(0xFFDCEAFF),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 19),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: Color(0xFFFFD36A),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Society Management Portal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 27),

              // QUICK SERVICES
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Quick Services',
                      style: TextStyle(
                        color: blue,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.grid_view_rounded,
                    color: Color(0xFFD5A94F),
                    size: 25,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                'Everything you need to manage your community.',
                style: TextStyle(color: muted, fontSize: 13),
              ),

              const SizedBox(height: 17),

              // COMPACT 9 MODULE GRID
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 700 ? 3 : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: features.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 78,
                    ),
                    itemBuilder: (context, index) {
                      final item = features[index];

                      return _serviceTile(item);
                    },
                  );
                },
              ),

              const SizedBox(height: 22),

              // FOOTER BANNER
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8EA), Color(0xFFFFF0D7)],
                  ),
                  border: Border.all(color: const Color(0xFFEADBB9)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      size: 40,
                      color: Color(0xFFD0A346),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Everything in one place',
                            style: TextStyle(
                              color: blue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Access society services and manage daily activities through a single portal.',
                            style: TextStyle(
                              color: muted,
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 23),

              // FOOTER
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.apartment_rounded,
                      color: Color(0xFFD5A94F),
                      size: 23,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'SocietyHub',
                      style: TextStyle(
                        color: blue,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Society Management System',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // COMPACT SERVICE TILE
  static Widget _serviceTile(_Feature item) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0xFF183B63).withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(item.icon, color: item.color, size: 21),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF173253),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: muted, fontSize: 9),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 2),

              Container(
                height: 23,
                width: 23,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EC),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFC4933B),
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NAVIGATION
  static void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// FEATURE MODEL
class _Feature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _Feature(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.bgColor,
    this.onTap,
  );
}
