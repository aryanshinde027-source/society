import 'package:flutter/material.dart';
import 'package:society_management/services/visitorservice.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  final VisitorService service = VisitorService();

  static const Color background = Color(0xFF0B1120);
  static const Color surface = Color(0xFF151F32);
  static const Color blue = Color(0xFF60A5FA);
  static const Color muted = Color(0xFF94A3B8);

  List<Map<String, dynamic>> visitors = [];
  bool loading = true;
  String? error;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadVisitors();
  }

  Future<void> loadVisitors() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await service.getAllVisitors();
      if (!mounted) return;

      setState(() {
        visitors = data;
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

  String currentDateTime() {
    return DateTime.now().toIso8601String().split('.').first;
  }

  String formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return '-';

    try {
      final date = DateTime.parse(value.toString()).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(date.day)}/${two(date.month)}/${date.year} '
          '${two(date.hour)}:${two(date.minute)}';
    } catch (_) {
      return value.toString();
    }
  }

  List<Map<String, dynamic>> get filteredVisitors {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return visitors;

    return visitors.where((v) {
      return [
        v['name'],
        v['mobile'],
        v['email'],
        v['purpose'],
        v['visid'],
        v['flatId'],
        v['residentId'],
      ].any((value) => value.toString().toLowerCase().contains(query));
    }).toList();
  }

  InputDecoration decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted),
      prefixIcon: Icon(icon, color: blue),
      filled: true,
      fillColor: background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: muted.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: blue),
      ),
    );
  }

  Widget field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: decoration(label, icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Future<void> openForm({Map<String, dynamic>? visitor}) async {
    final formKey = GlobalKey<FormState>();

    final name = TextEditingController(
      text: visitor?['name']?.toString() ?? '',
    );
    final mobile = TextEditingController(
      text: visitor?['mobile']?.toString() ?? '',
    );
    final email = TextEditingController(
      text: visitor?['email']?.toString() ?? '',
    );
    final purpose = TextEditingController(
      text: visitor?['purpose']?.toString() ?? '',
    );
    final entryDate = TextEditingController(
      text: visitor?['entryDate']?.toString() ?? currentDateTime(),
    );
    final exitDate = TextEditingController(
      text: visitor?['exitDate']?.toString() ?? currentDateTime(),
    );
    final flatId = TextEditingController(
      text: visitor?['flatId']?.toString() ?? '',
    );
    final residentId = TextEditingController(
      text: visitor?['residentId']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: surface,
              title: Text(
                visitor == null ? 'Register Visitor' : 'Edit Visitor',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                        field(
                          controller: name,
                          label: 'Visitor name',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        field(
                          controller: mobile,
                          label: 'Mobile number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        field(
                          controller: email,
                          label: 'Email address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        field(
                          controller: purpose,
                          label: 'Purpose of visit',
                          icon: Icons.assignment_outlined,
                        ),
                        const SizedBox(height: 12),
                        field(
                          controller: entryDate,
                          label: 'Entry date-time (ISO)',
                          icon: Icons.login_rounded,
                        ),
                        const SizedBox(height: 6),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Format: yyyy-MM-ddTHH:mm:ss',
                            style: TextStyle(color: muted, fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 12),
                        field(
                          controller: exitDate,
                          label: 'Exit date-time (ISO)',
                          icon: Icons.logout_rounded,
                        ),
                        const SizedBox(height: 12),
                        field(
                          controller: flatId,
                          label: 'Flat ID',
                          icon: Icons.apartment_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        field(
                          controller: residentId,
                          label: 'Resident ID',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
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
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: background,
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          final parsedFlatId = int.tryParse(flatId.text.trim());
                          final parsedResidentId = int.tryParse(
                            residentId.text.trim(),
                          );

                          if (parsedFlatId == null ||
                              parsedFlatId <= 0 ||
                              parsedResidentId == null ||
                              parsedResidentId <= 0) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enter valid Flat ID and Resident ID',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            DateTime.parse(entryDate.text.trim());
                            DateTime.parse(exitDate.text.trim());
                          } catch (_) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enter date-time as yyyy-MM-ddTHH:mm:ss',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => saving = true);

                          try {
                            if (visitor == null) {
                              await service.addVisitor(
                                name: name.text.trim(),
                                mobile: mobile.text.trim(),
                                email: email.text.trim(),
                                purpose: purpose.text.trim(),
                                entryDate: entryDate.text.trim(),
                                exitDate: exitDate.text.trim(),
                                flatId: parsedFlatId,
                                residentId: parsedResidentId,
                              );
                            } else {
                              await service.updateVisitor(
                                visitorId: (visitor['visid'] as num).toInt(),
                                name: name.text.trim(),
                                mobile: mobile.text.trim(),
                                email: email.text.trim(),
                                purpose: purpose.text.trim(),
                                entryDate: entryDate.text.trim(),
                                exitDate: exitDate.text.trim(),
                                flatId: parsedFlatId,
                                residentId: parsedResidentId,
                              );
                            }

                            if (!mounted) return;
                            Navigator.pop(dialogContext);
                            await loadVisitors();

                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  visitor == null
                                      ? 'Visitor registered successfully'
                                      : 'Visitor updated successfully',
                                ),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => saving = false);
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text('Request failed: $e')),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(visitor == null ? 'Register' : 'Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    name.dispose();
    mobile.dispose();
    email.dispose();
    purpose.dispose();
    entryDate.dispose();
    exitDate.dispose();
    flatId.dispose();
    residentId.dispose();
  }

  Future<void> deleteVisitor(Map<String, dynamic> visitor) async {
    final id = (visitor['visid'] as num).toInt();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        title: const Text(
          'Delete visitor?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Delete ${visitor['name'] ?? 'this visitor'} from records?',
          style: const TextStyle(color: muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: muted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await service.deleteVisitor(id);
      await loadVisitors();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Widget visitorCard(Map<String, dynamic> visitor) {
    final id = visitor['visid']?.toString() ?? '-';
    final name = visitor['name']?.toString() ?? 'Unknown visitor';
    final mobile = visitor['mobile']?.toString() ?? '-';
    final email = visitor['email']?.toString() ?? '-';
    final purpose = visitor['purpose']?.toString() ?? '-';
    final entry = formatDate(visitor['entryDate']);
    final exit = formatDate(visitor['exitDate']);
    final flat = visitor['flatId']?.toString() ?? '-';
    final resident = visitor['residentId']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: blue.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.person_pin_circle_outlined,
                  color: blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Visitor #$id',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: surface,
                icon: const Icon(Icons.more_vert, color: muted),
                onSelected: (value) {
                  if (value == 'edit') {
                    openForm(visitor: visitor);
                  } else if (value == 'delete') {
                    deleteVisitor(visitor);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit', style: TextStyle(color: Colors.white)),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          _detail(Icons.phone_outlined, mobile),
          const SizedBox(height: 8),
          _detail(Icons.email_outlined, email),
          const SizedBox(height: 8),
          _detail(Icons.info_outline, purpose),
          const SizedBox(height: 14),
          Divider(color: muted.withValues(alpha: 0.15)),
          _detail(Icons.login_rounded, 'Entry: $entry'),
          const SizedBox(height: 8),
          _detail(Icons.logout_rounded, 'Exit: $exit'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _detail(Icons.apartment, 'Flat: $flat')),
              Expanded(
                child: _detail(Icons.badge_outlined, 'Resident: $resident'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 17, color: muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: muted, fontSize: 12)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Visitor Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loadVisitors,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openForm(),
        backgroundColor: blue,
        foregroundColor: background,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Register Visitor'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadVisitors,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(21),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF4338CA)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Your Guests',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Register visitors and keep track of entry '
                            'and exit details.',
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.directions_walk_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 23),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Visitor Records',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${visitors.length} total',
                    style: const TextStyle(color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search visitors...',
                  hintStyle: const TextStyle(color: muted),
                  prefixIcon: const Icon(Icons.search, color: muted),
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: Colors.orangeAccent,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load visitors',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: muted),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: loadVisitors,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              else if (filteredVisitors.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 54,
                        color: muted,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No visitor records found',
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                )
              else
                ...filteredVisitors.map(visitorCard),
            ],
          ),
        ),
      ),
    );
  }
}
