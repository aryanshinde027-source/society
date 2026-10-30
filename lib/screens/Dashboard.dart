import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:society_management/screens/ai%20complaintscreen.dart';
import 'package:society_management/screens/ai.dart';
import 'package:society_management/screens/Complaints.dart';
import 'package:society_management/screens/residentfacilitybooking.dart';
import 'package:society_management/screens/residentmaintenance.dart';
import 'package:society_management/screens/residentnoticescreen.dart';
import 'package:society_management/screens/visitors.dart';
import 'package:society_management/screens/profile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color navy = Color(0xFF142F50);
  static const Color gold = Color(0xFFD6AC54);
  static const Color background = Color(0xFFF3F6FC);
  static const Color muted = Color(0xFF7C8CA5);

  void navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 55,

        title: const Row(
          children: [
            Icon(Icons.apartment_rounded, color: gold, size: 29),
            SizedBox(width: 10),
            Text(
              'SocietyHub',
              style: TextStyle(
                color: navy,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () => navigate(context, const ProfileScreen()),
            icon: const Icon(
              Icons.account_circle_outlined,
              color: navy,
              size: 27,
            ),
          ),

          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout_rounded, color: navy, size: 25),
          ),

          const SizedBox(width: 8),
        ],
      ),

      // DASHBOARD BODY
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final int columns = width >= 1100 ? 3 : 2;

            final double cardRatio = columns == 3
                ? 5.5
                : width >= 600
                ? 2.8
                : 1.8;

            final double horizontalPadding = width >= 900 ? 24 : 16;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                25,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // WELCOME BANNER
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(width >= 600 ? 25 : 22),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF142F50), Color(0xFF1762A4)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.apartment_rounded,
                            size: width >= 600 ? 115 : 90,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.waving_hand_rounded,
                                color: Color(0xFFFFC94D),
                                size: 29,
                              ),
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'WELCOME BACK',
                              style: TextStyle(
                                color: Color(0xFFFFC94D),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'Society Member',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'Your community, managed in one place.',
                              style: TextStyle(
                                color: Color(0xFFD9E6F7),
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),

                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user_rounded,
                                    color: Color(0xFFFFC94D),
                                    size: 17,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Society Management Portal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
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

                  const SizedBox(height: 30),

                  // QUICK SERVICES HEADING
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Quick Services',
                          style: TextStyle(
                            color: navy,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      Icon(Icons.grid_view_rounded, color: gold, size: 25),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Everything you need to manage your community.',
                    style: TextStyle(color: muted, fontSize: 14),
                  ),

                  const SizedBox(height: 20),

                  // 8 MODULES - RESPONSIVE GRID
                  GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                    childAspectRatio: cardRatio,

                    children: [
                      // 1. COMPLAINTS
                      serviceCard(
                        icon: Icons.report_problem_rounded,
                        title: 'Complaints',
                        subtitle: 'Track complaints',
                        color: const Color(0xFFEB5055),
                        onTap: () =>
                            navigate(context, const ComplaintsScreen()),
                      ),

                      // 2. MAINTENANCE
                      serviceCard(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'Maintenance',
                        subtitle: 'Payments and dues',
                        color: const Color(0xFFC58A22),
                        onTap: () => navigate(
                          context,
                          const ResidentMaintenanceScreen(),
                        ),
                      ),

                      // 3. NOTICES
                      serviceCard(
                        icon: Icons.campaign_rounded,
                        title: 'Notices',
                        subtitle: 'Society announcements',
                        color: const Color(0xFF8652D5),
                        onTap: () =>
                            navigate(context, const ResidentNoticeScreen()),
                      ),

                      // 4. VISITORS
                      serviceCard(
                        icon: Icons.people_alt_rounded,
                        title: 'Visitors',
                        subtitle: 'Visitor records',
                        color: const Color(0xFF139E88),
                        onTap: () => navigate(context, const VisitorsScreen()),
                      ),

                      // 5. MY PROFILE
                      serviceCard(
                        icon: Icons.person_rounded,
                        title: 'My Profile',
                        subtitle: 'View profile details',
                        color: const Color(0xFFD14B91),
                        onTap: () => navigate(context, const ProfileScreen()),
                      ),

                      // 6. AI ASSISTANT
                      serviceCard(
                        icon: Icons.auto_awesome_rounded,
                        title: 'AI Assistant',
                        subtitle: 'Ask society-related questions',
                        color: const Color(0xFF9364B9),
                        onTap: () => navigate(context, const AiChatScreen()),
                      ),

                      // 7. AI COMPLAINT HELP
                      serviceCard(
                        icon: Icons.psychology_rounded,
                        title: 'AI Complaint Help',
                        subtitle: 'Get complaint suggestions',
                        color: const Color(0xFFC05B91),
                        onTap: () =>
                            navigate(context, const AiComplaintScreen()),
                      ),

                      // 8. FACILITY BOOKING
                      serviceCard(
                        icon: Icons.event_available_rounded,
                        title: 'Facility Booking',
                        subtitle: 'Manage bookings',
                        color: const Color(0xFF218A70),
                        onTap: () => navigate(
                          context,
                          const ResidentFacilityBookingScreen(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // BOTTOM INFORMATION CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3DD),
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: const Color(0xFFF0D8A9)),
                    ),

                    child: const Row(
                      children: [
                        Icon(Icons.shield_rounded, color: gold, size: 37),

                        SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Everything in one place',
                                style: TextStyle(
                                  color: navy,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              SizedBox(height: 6),

                              Text(
                                'Access society services and manage daily activities through a single portal.',
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // REUSABLE HORIZONTAL SERVICE CARD

  Widget serviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE9EDF4)),
            boxShadow: [
              BoxShadow(
                color: navy.withOpacity(0.035),
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),

          child: Row(
            children: [
              // ICON
              Container(
                height: 43,
                width: 43,

                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(icon, color: color, size: 23),
              ),

              const SizedBox(width: 9),

              // TITLE AND SUBTITLE
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              // ARROW
              Container(
                height: 25,
                width: 25,

                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E9),
                  borderRadius: BorderRadius.circular(30),
                ),

                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFD39B36),
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
