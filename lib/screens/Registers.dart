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

  static const Color primary = Color(0xFF2563EB);

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
      barrierDismissible: !saving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Resident' : 'Add Resident'),
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
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
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
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(),
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
                  child: const Text('Cancel'),
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
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
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
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Future<void> confirmDelete(Map<String, dynamic> resident) async {
    final id = (resident['residentid'] as num).toInt();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resident?'),
        content: Text('Delete ${resident['residentName'] ?? 'this resident'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    final visibleResidents = filteredResidents;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Resident Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadResidents,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showResidentForm(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Resident'),
      ),
      body: RefreshIndicator(
        onRefresh: loadResidents,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Residents',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Manage resident profiles and details.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Total Residents',
                    '${residents.length}',
                    Icons.people_alt_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    'Showing',
                    '${visibleResidents.length}',
                    Icons.filter_list,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchText = value),
              decoration: InputDecoration(
                hintText: 'Search name, email, mobile or ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchText.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchText = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(35),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off, size: 42, color: Colors.red),
                      const SizedBox(height: 8),
                      const Text('Could not load residents'),
                      const SizedBox(height: 8),
                      SelectableText(
                        error!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      TextButton(
                        onPressed: loadResidents,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            else if (visibleResidents.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Icon(Icons.person_search, size: 48, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('No residents found'),
                    ],
                  ),
                ),
              )
            else
              ...visibleResidents.map((resident) {
                final id = resident['residentid'] ?? '-';
                final name = resident['residentName'] ?? 'Unnamed Resident';
                final email = resident['email'] ?? 'No email';
                final phone = resident['mobilenumber'] ?? 'No mobile';
                final role = resident['role'] ?? 'Resident';

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFFDBEAFE),
                          child: Text(
                            name.toString().isNotEmpty
                                ? name.toString()[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'ID: $id • $role',
                                style: const TextStyle(
                                  color: primary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                email.toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                phone.toString(),
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
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
                              child: Text('View Details'),
                            ),
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primary),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

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
          title: Text(
            resident['residentName']?.toString() ?? 'Resident Details',
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
              child: const Text('Close'),
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
      padding: const EdgeInsets.only(bottom: 9),
      child: Text('$label: ${value ?? '-'}'),
    );
  }
}
