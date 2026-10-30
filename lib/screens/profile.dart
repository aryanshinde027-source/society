import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();

  bool isEditing = false;
  bool isSaving = false;

  static const Color navy = Color(0xFF14294E);
  static const Color navyLight = Color(0xFF203D6B);
  static const Color gold = Color(0xFFDDBB70);
  static const Color bg = Color(0xFFF4F6FB);
  static const Color muted = Color(0xFF8490A0);

  @override
  void initState() {
    super.initState();
    nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    setState(() => isSaving = true);

    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);

      await FirebaseAuth.instance.currentUser?.reload();

      if (!mounted) return;

      setState(() {
        isEditing = false;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Update failed')));
    }
  }

  // PROFILE HEADER
  Widget profileHeader(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [navy, navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 2.5),
            ),
            child: const CircleAvatar(
              radius: 67,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: navy, size: 78),
            ),
          ),

          const SizedBox(height: 35),

          Text(
            user.displayName?.isNotEmpty == true
                ? user.displayName!
                : 'Society Resident',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 13),

          Text(
            user.email ?? 'No email available',
            style: const TextStyle(color: Color(0xFFD0D9E8), fontSize: 16),
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: gold.withOpacity(0.7)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_outlined, color: gold, size: 23),
                SizedBox(width: 10),
                Text(
                  'Society Member',
                  style: TextStyle(
                    color: gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // INFORMATION CARD
  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E8EF)),
      ),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EEDF),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, color: navy, size: 30),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: muted, fontSize: 15)),

                const SizedBox(height: 7),

                Text(
                  value,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // EDIT NAME FIELD
  Widget editNameField() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E8EF)),
      ),
      child: TextField(
        controller: nameController,
        style: const TextStyle(color: navy, fontWeight: FontWeight.w700),
        decoration: const InputDecoration(
          labelText: 'Full Name',
          prefixIcon: Icon(Icons.person_outline, color: navy),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // LOGOUT
  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  // MAIN BUILD
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: navy,
        toolbarHeight: 65,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: navy,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: user == null
          ? const Center(child: Text('Please login first'))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 25, 18, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PROFILE HEADER
                  profileHeader(user),

                  const SizedBox(height: 55),

                  // PERSONAL INFORMATION
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      color: navy,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Manage your account details',
                    style: TextStyle(color: muted, fontSize: 16),
                  ),

                  const SizedBox(height: 25),

                  // INFORMATION CONTAINER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(color: const Color(0xFFE6EAF0)),
                    ),
                    child: Column(
                      children: [
                        if (isEditing)
                          editNameField()
                        else
                          infoCard(
                            icon: Icons.person_outline,
                            title: 'Full Name',
                            value: user.displayName?.isNotEmpty == true
                                ? user.displayName!
                                : 'Society Resident',
                          ),

                        const SizedBox(height: 17),

                        infoCard(
                          icon: Icons.mail_outline,
                          title: 'Email Address',
                          value: user.email ?? 'No email available',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 23),

                  // EDIT PROFILE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () {
                              if (isEditing) {
                                saveProfile();
                              } else {
                                nameController.text = user.displayName ?? '';
                                setState(() {
                                  isEditing = true;
                                });
                              }
                            },
                      icon: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: navy,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isEditing
                                  ? Icons.save_outlined
                                  : Icons.edit_outlined,
                            ),
                      label: Text(
                        isSaving
                            ? 'Saving...'
                            : isEditing
                            ? 'Save Changes'
                            : 'Edit Profile',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: navy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(19),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // ACCOUNT SETTINGS
                  const Text(
                    'Account Settings',
                    style: TextStyle(
                      color: navy,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LOGOUT CARD
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6EAF0)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                        ),
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: const Text(
                        'Sign out from your account',
                        style: TextStyle(color: muted),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: muted,
                        size: 17,
                      ),
                      onTap: logout,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
