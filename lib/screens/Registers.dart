import 'package:flutter/material.dart';
import 'package:society_management/services/residenservice.dart';

class ResidentScreen extends StatefulWidget {
  const ResidentScreen({super.key});

  @override
  State<ResidentScreen> createState() => _ResidentScreenState();
}

class _ResidentScreenState extends State<ResidentScreen> {
  final ResidentService service = ResidentService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> residents = [];
  bool loading = false;
  String? error;
  String searchText = '';

  // PROFESSIONAL THEME
  static const Color navy = Color(0xFF142E51);
  static const Color navyLight = Color(0xFF244777);
  static const Color gold = Color(0xFFD9B66F);
  static const Color background = Color(0xFFF3F5FA);
  static const Color muted = Color(0xFF8290A0);

  @override
  void initState() {
    super.initState();
    loadResidents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // LOAD RESIDENTS
  Future<void> loadResidents() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await service.getAllResidents();

      if (!mounted) return;

      setState(() {
        residents = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  // SEARCH
  List<Map<String, dynamic>> get filteredResidents {
    final query = searchText.toLowerCase().trim();

    if (query.isEmpty) return residents;

    return residents.where((resident) {
      final name = (resident['residentName'] ?? '').toString().toLowerCase();
      final email = (resident['email'] ?? '').toString().toLowerCase();
      final phone = (resident['mobilenumber'] ?? '').toString().toLowerCase();
      final id = (resident['residentid'] ?? '').toString();

      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query) ||
          id.contains(query);
    }).toList();
  }

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // FORM DECORATION
  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted),
      prefixIcon: Icon(icon, color: gold),
      filled: true,
      fillColor: background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE3E8EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: navy, width: 1.5),
      ),
    );
  }

  // ADD / EDIT RESIDENT
  Future<void> showResidentForm({Map<String, dynamic>? resident}) async {
    final isEdit = resident != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: resident?['residentName']?.toString() ?? '',
    );

    final phoneController = TextEditingController(
      text: resident?['mobilenumber']?.toString() ?? '',
    );

    final emailController = TextEditingController(
      text: resident?['email']?.toString() ?? '',
    );

    final ageController = TextEditingController(
      text: resident?['age']?.toString() ?? '',
    );

    final flat = resident?['flat'];

    final flatIdController = TextEditingController(
      text: flat is Map
          ? (flat['flatId'] ?? flat['flatid'] ?? '').toString()
          : '',
    );

    String gender = resident?['gender']?.toString() ?? 'Male';
    String role = resident?['role']?.toString() ?? 'RESIDENT';
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                isEdit ? 'Edit Resident' : 'Add Resident',
                style: const TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w900,
                  fontSize: 21,
                ),
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _formField(
                          nameController,
                          'Resident Name',
                          Icons.person_outline,
                        ),
                        _formField(
                          phoneController,
                          'Mobile Number',
                          Icons.phone_outlined,
                          keyboard: TextInputType.phone,
                        ),
                        _formField(
                          emailController,
                          'Email Address',
                          Icons.email_outlined,
                          keyboard: TextInputType.emailAddress,
                        ),
                        _formField(
                          ageController,
                          'Age',
                          Icons.cake_outlined,
                          keyboard: TextInputType.number,
                        ),
                        _formField(
                          flatIdController,
                          'Flat ID',
                          Icons.home_outlined,
                          keyboard: TextInputType.number,
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: gender,
                          decoration: inputDecoration(
                            'Gender',
                            Icons.person_outline,
                          ),
                          items: ['Male', 'Female', 'Other']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => gender = value);
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: role,
                          decoration: inputDecoration(
                            'Role',
                            Icons.badge_outlined,
                          ),
                          items: ['RESIDENT', 'ADMIN', 'OWNER', 'TENANT']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => role = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: muted)),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          final age = int.tryParse(ageController.text.trim());

                          final flatId = int.tryParse(
                            flatIdController.text.trim(),
                          );

                          if (age == null || flatId == null) {
                            showMessage(
                              'Enter valid age and Flat ID',
                              isError: true,
                            );
                            return;
                          }

                          setDialogState(() => saving = true);

                          try {
                            final data = {
                              'residentName': nameController.text.trim(),
                              'mobilenumber': phoneController.text.trim(),
                              'email': emailController.text.trim(),
                              'gender': gender,
                              'age': age,
                              'role': role,
                              'flatId': flatId,
                            };

                            if (isEdit) {
                              await service.updateResident(
                                residentId: (resident['residentid'] as num)
                                    .toInt(),
                                residentName: data['residentName'] as String,
                                mobilenumber: data['mobilenumber'] as String,
                                email: data['email'] as String,
                                gender: gender,
                                age: age,
                                role: role,
                                flatId: flatId,
                              );
                            } else {
                              await service.addResident(
                                residentName: data['residentName'] as String,
                                mobilenumber: data['mobilenumber'] as String,
                                email: data['email'] as String,
                                gender: gender,
                                age: age,
                                role: role,
                                flatId: flatId,
                              );
                            }

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            showMessage(
                              isEdit
                                  ? 'Resident updated successfully'
                                  : 'Resident added successfully',
                            );

                            await loadResidents();
                          } catch (e) {
                            setDialogState(() => saving = false);
                            showMessage(e.toString(), isError: true);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEdit ? 'Save Changes' : 'Add Resident'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    ageController.dispose();
    flatIdController.dispose();
  }

  Widget _formField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: navy),
        decoration: inputDecoration(label, icon),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  // DELETE RESIDENT
  Future<void> confirmDelete(Map<String, dynamic> resident) async {
    final id = (resident['residentid'] as num).toInt();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Resident?',
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Delete ${resident['residentName'] ?? 'this resident'}?',
          style: const TextStyle(color: muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await service.deleteResident(id);

      if (!mounted) return;

      showMessage('Resident deleted successfully');
      await loadResidents();
    } catch (e) {
      if (!mounted) return;
      showMessage(e.toString(), isError: true);
    }
  }

  // STATISTICS CARD
  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E8EF)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: navy, size: 25),
          ),
          const SizedBox(height: 17),
          Text(
            value,
            style: const TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w900,
              color: navy,
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: muted, fontSize: 14)),
        ],
      ),
    );
  }

  // RESIDENT CARD
  Widget residentCard(Map<String, dynamic> resident) {
    final id = resident['residentid'] ?? '-';
    final name = resident['residentName'] ?? 'Unnamed Resident';
    final email = resident['email'] ?? 'No email';
    final phone = resident['mobilenumber'] ?? 'No mobile';
    final role = resident['role'] ?? 'Resident';

    final nameText = name.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE3E8EF)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFFFF3DC),
            child: Text(
              nameText.isNotEmpty ? nameText[0].toUpperCase() : '?',
              style: const TextStyle(
                color: navy,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameText,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'ID: $id  •  $role',
                  style: const TextStyle(
                    color: Color(0xFFB18B45),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, color: muted, size: 14),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        email.toString(),
                        style: const TextStyle(color: muted, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, color: muted, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      phone.toString(),
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: navy),
            onSelected: (value) {
              if (value == 'edit') {
                showResidentForm(resident: resident);
              } else if (value == 'delete') {
                confirmDelete(resident);
              } else if (value == 'details') {
                showResidentDetails(id);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined, color: navy),
                    SizedBox(width: 9),
                    Text('View Details'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: navy),
                    SizedBox(width: 9),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 9),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // RESIDENT DETAILS
  Future<void> showResidentDetails(dynamic residentId) async {
    try {
      final resident = await service.getResidentById(
        (residentId as num).toInt(),
      );

      if (!mounted) return;

      final flat = resident['flat'];

      final flatLabel = flat is Map
          ? (flat['flatId'] ?? flat['flatid'] ?? 'Not available').toString()
          : 'Not available';

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            resident['residentName']?.toString() ?? 'Resident Details',
            style: const TextStyle(color: navy, fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail('Resident ID', resident['residentid']),
              _detail('Mobile', resident['mobilenumber']),
              _detail('Email', resident['email']),
              _detail('Gender', resident['gender']),
              _detail('Age', resident['age']),
              _detail('Role', resident['role']),
              _detail('Flat ID', flatLabel),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: navy)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) showMessage(e.toString(), isError: true);
    }
  }

  Widget _detail(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(color: muted, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              '${value ?? '-'}',
              style: const TextStyle(color: navy, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // WELCOME BANNER
  Widget residentBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [navy, navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.09),
                borderRadius: BorderRadius.circular(23),
              ),
              child: const Icon(Icons.groups_rounded, size: 55, color: gold),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Community Residents',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Manage resident profiles and details.',
                style: TextStyle(
                  color: Color(0xFFD4DFEF),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MAIN UI
  @override
  Widget build(BuildContext context) {
    final visibleResidents = filteredResidents;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 8,
        title: const Text(
          'Resident Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadResidents,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 7),
        ],
      ),

      // ADD RESIDENT BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showResidentForm(),
        backgroundColor: gold,
        foregroundColor: navy,
        elevation: 7,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Add Resident',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadResidents,
          color: navy,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(17, 20, 17, 110),
            children: [
              // BANNER
              residentBanner(),

              const SizedBox(height: 22),

              // STATISTICS
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      'Total Residents',
                      '${residents.length}',
                      Icons.people_alt_outlined,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: _statCard(
                      'Showing',
                      '${visibleResidents.length}',
                      Icons.filter_list_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 27),

              // DIRECTORY HEADING
              const Text(
                'Resident Directory',
                style: TextStyle(
                  color: navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 18),

              // SEARCH
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: const Color(0xFFE3E8EF)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => searchText = value);
                  },
                  style: const TextStyle(color: navy, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search name, email, mobile or ID',
                    hintStyle: const TextStyle(color: muted, fontSize: 14),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: navy,
                      size: 28,
                    ),
                    suffixIcon: searchText.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => searchText = '');
                            },
                            icon: const Icon(Icons.close, color: muted),
                          ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 22),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LOADING
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(35),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: navy,
                      strokeWidth: 3,
                    ),
                  ),
                )
              // ERROR
              else if (error != null)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 45,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load residents',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        error!,
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                      TextButton(
                        onPressed: loadResidents,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              // EMPTY
              else if (visibleResidents.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.person_search_rounded,
                        size: 52,
                        color: gold,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        searchText.isEmpty
                            ? 'No residents found'
                            : 'No matching residents found',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              // RESIDENT LIST
              else
                ...visibleResidents.map(residentCard),
            ],
          ),
        ),
      ),
    );
  }
}
