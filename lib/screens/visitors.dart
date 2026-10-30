import 'package:flutter/material.dart';
import 'package:society_management/services/visitorservice.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  final VisitorService service = VisitorService();

  // PROFESSIONAL THEME
  static const Color background = Color(0xFFF3F5FA);
  static const Color surface = Colors.white;
  static const Color navy = Color(0xFF142F52);
  static const Color blue = Color(0xFF244C80);
  static const Color gold = Color(0xFFD9B66F);
  static const Color muted = Color(0xFF8290A0);

  List<Map<String, dynamic>> visitors = [];

  bool loading = true;
  String? error;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadVisitors();
  }

  // LOAD VISITORS
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

  // SEARCH
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

  // INPUT DECORATION
  InputDecoration decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted),
      prefixIcon: Icon(icon, color: gold),
      filled: true,
      fillColor: background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE3E8EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: blue, width: 1.5),
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
      style: const TextStyle(color: navy),
      decoration: decoration(label, icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  // ADD / UPDATE VISITOR
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                visitor == null ? 'Register Visitor' : 'Edit Visitor',
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

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

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
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => saving = false);

                            if (!mounted) return;

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Request failed: $e'),
                                backgroundColor: Colors.red,
                              ),
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

  // DELETE VISITOR
  Future<void> deleteVisitor(Map<String, dynamic> visitor) async {
    final id = (visitor['visid'] as num).toInt();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete visitor?',
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
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
      await service.deleteVisitor(id);
      await loadVisitors();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visitor deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // VISITOR DETAIL ROW
  Widget detail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 17, color: gold),
        const SizedBox(width: 9),
        Expanded(
          child: Text(text, style: const TextStyle(color: muted, fontSize: 13)),
        ),
      ],
    );
  }

  // VISITOR CARD
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
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAF0)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5DF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.person_pin_circle_rounded,
                  color: gold,
                  size: 29,
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
                        color: navy,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 5),
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
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: blue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 17),

          detail(Icons.phone_outlined, mobile),
          const SizedBox(height: 10),

          detail(Icons.email_outlined, email),
          const SizedBox(height: 10),

          detail(Icons.info_outline_rounded, purpose),

          const SizedBox(height: 15),
          const Divider(color: Color(0xFFEDF0F5)),
          const SizedBox(height: 12),

          detail(Icons.login_rounded, 'Entry: $entry'),
          const SizedBox(height: 10),

          detail(Icons.logout_rounded, 'Exit: $exit'),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: detail(Icons.apartment_rounded, 'Flat: $flat')),
              Expanded(
                child: detail(Icons.badge_outlined, 'Resident: $resident'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WELCOME BANNER
  Widget visitorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF142E51), Color(0xFF234777)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 5,
            child: Icon(
              Icons.groups_rounded,
              size: 125,
              color: Colors.white.withOpacity(0.07),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'V I S I T O R  M A N A G E M E N T',
                style: TextStyle(
                  color: gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Welcome Every Guest.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 13),

              const Text(
                'Keep visitor details organized in one place.',
                style: TextStyle(
                  color: Color(0xFFD4DFEF),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 37),

              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, color: gold, size: 23),
                  const SizedBox(width: 12),
                  Text(
                    '${visitors.length} visitors added',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MAIN SCREEN
  @override
  Widget build(BuildContext context) {
    final visibleVisitors = filteredVisitors;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        surfaceTintColor: Colors.white,
        titleSpacing: 8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 27),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Visitors',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loadVisitors,
            icon: const Icon(Icons.refresh_rounded, color: navy, size: 28),
          ),
          const SizedBox(width: 7),
        ],
      ),

      // ADD VISITOR BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openForm(),
        backgroundColor: gold,
        foregroundColor: navy,
        elevation: 7,
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 25),
        label: const Text(
          'Add Visitor',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadVisitors,
          color: navy,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(17, 20, 17, 110),
            children: [
              // BANNER
              visitorBanner(),

              const SizedBox(height: 25),

              // SEARCH BAR
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE3E8EF)),
                  boxShadow: [
                    BoxShadow(color: navy.withOpacity(0.025), blurRadius: 10),
                  ],
                ),
                child: TextField(
                  style: const TextStyle(color: navy, fontSize: 16),
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, flat or purpose...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8793A2),
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: navy,
                      size: 29,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() => searchQuery = '');
                            },
                            icon: const Icon(Icons.close, color: muted),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 23,
                      horizontal: 15,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 27),

              // VISITOR RECORDS HEADING
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Visitor Records',
                      style: TextStyle(
                        color: navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${visibleVisitors.length} found',
                    style: const TextStyle(color: muted, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 19),

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
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load visitors',
                        style: TextStyle(
                          color: navy,
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
                      ElevatedButton.icon(
                        onPressed: loadVisitors,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              // EMPTY
              else if (visibleVisitors.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        size: 55,
                        color: gold,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        searchQuery.isEmpty
                            ? 'No visitor records found'
                            : 'No matching visitors found',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              // VISITOR LIST
              else
                ...visibleVisitors.map(visitorCard),
            ],
          ),
        ),
      ),
    );
  }
}
