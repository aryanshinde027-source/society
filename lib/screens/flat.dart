import 'package:flutter/material.dart';
import 'package:society_management/services/flatservice.dart';

class FlatScreen extends StatefulWidget {
  const FlatScreen({super.key});

  @override
  State<FlatScreen> createState() => _FlatScreenState();
}

class _FlatScreenState extends State<FlatScreen> {
  final FlatService service = FlatService();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> flats = [];
  bool loading = false;
  String? error;
  String searchText = '';

  static const Color primary = Color(0xFF2563EB);

  final List<String> statuses = ['Available', 'Occupied', 'Maintenance'];

  @override
  void initState() {
    super.initState();
    loadFlats();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadFlats() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await service.getAllFlats();
      if (!mounted) return;

      setState(() {
        flats = result;
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

  List<Map<String, dynamic>> get filteredFlats {
    final query = searchText.toLowerCase().trim();

    if (query.isEmpty) return flats;

    return flats.where((flat) {
      return [
        flat['flatid'],
        flat['flatnumber'],
        flat['wing'],
        flat['floortype'],
        flat['status'],
      ].any((value) => value.toString().toLowerCase().contains(query));
    }).toList();
  }

  void message(String text, {bool failed = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: failed ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> openFlatForm({Map<String, dynamic>? flat}) async {
    final editing = flat != null;
    final formKey = GlobalKey<FormState>();

    final numberController = TextEditingController(
      text: flat?['flatnumber']?.toString() ?? '',
    );
    final wingController = TextEditingController(
      text: flat?['wing']?.toString() ?? '',
    );
    final floorController = TextEditingController(
      text: flat?['floortype']?.toString() ?? '',
    );
    final societyController = TextEditingController(
      text: flat?['society'] is Map
          ? (flat!['society']['societyId'] ??
                    flat['society']['societyid'] ??
                    '')
                .toString()
          : '',
    );

    String status = statuses.contains(flat?['status'])
        ? flat!['status'].toString()
        : statuses.first;

    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(editing ? 'Edit Flat' : 'Add New Flat'),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _field(
                          numberController,
                          'Flat Number',
                          Icons.home_outlined,
                          numeric: true,
                        ),
                        _field(wingController, 'Wing', Icons.apartment),
                        _field(
                          floorController,
                          'Floor Type',
                          Icons.layers_outlined,
                        ),
                        _field(
                          societyController,
                          'Society ID',
                          Icons.domain,
                          numeric: true,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: status,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Flat Status',
                            prefixIcon: Icon(Icons.info_outline),
                            border: OutlineInputBorder(),
                          ),
                          items: statuses.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => status = value);
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          final number = int.tryParse(
                            numberController.text.trim(),
                          );
                          final societyId = int.tryParse(
                            societyController.text.trim(),
                          );

                          if (number == null || societyId == null) {
                            message(
                              'Enter valid Flat Number and Society ID',
                              failed: true,
                            );
                            return;
                          }

                          setDialogState(() => saving = true);

                          try {
                            if (editing) {
                              await service.updateFlat(
                                flatId: (flat['flatid'] as num).toInt(),
                                flatnumber: number,
                                wing: wingController.text.trim(),
                                floortype: floorController.text.trim(),
                                status: status,
                                societyId: societyId,
                              );
                            } else {
                              await service.addFlat(
                                flatnumber: number,
                                wing: wingController.text.trim(),
                                floortype: floorController.text.trim(),
                                status: status,
                                societyId: societyId,
                              );
                            }

                            if (!mounted) return;
                            Navigator.pop(dialogContext);

                            message(
                              editing
                                  ? 'Flat updated successfully'
                                  : 'Flat added successfully',
                            );
                            await loadFlats();
                          } catch (e) {
                            setDialogState(() => saving = false);
                            message(e.toString(), failed: true);
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(editing ? 'Save Changes' : 'Add Flat'),
                ),
              ],
            );
          },
        );
      },
    );

    numberController.dispose();
    wingController.dispose();
    floorController.dispose();
    societyController.dispose();
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool numeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          if (numeric && int.tryParse(value.trim()) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Future<void> deleteFlat(Map<String, dynamic> flat) async {
    final id = (flat['flatid'] as num).toInt();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flat?'),
        content: Text('Delete Flat ${flat['flatnumber']}?'),
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
      await service.deleteFlat(id);
      if (!mounted) return;

      message('Flat deleted successfully');
      await loadFlats();
    } catch (e) {
      if (!mounted) return;
      message(e.toString(), failed: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = filteredFlats;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Flat Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadFlats,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openFlatForm(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_home_work_outlined),
        label: const Text('Add Flat'),
      ),
      body: RefreshIndicator(
        onRefresh: loadFlats,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(23),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primary, Color(0xFF0284C7)],
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
                          'Manage Your Flats',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'View and manage flat details in your society.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.apartment_rounded, color: Colors.white, size: 45),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Total Flats',
                    '${flats.length}',
                    Icons.domain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    'Matching',
                    '${visible.length}',
                    Icons.search,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchText = value),
              decoration: InputDecoration(
                hintText: 'Search flat, wing, floor or status',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchText.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          searchController.clear();
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
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off, size: 42, color: Colors.red),
                      const SizedBox(height: 10),
                      const Text('Could not load flats'),
                      const SizedBox(height: 8),
                      SelectableText(
                        error!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      TextButton(
                        onPressed: loadFlats,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (visible.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Icon(
                        Icons.other_houses_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text('No flats found'),
                    ],
                  ),
                ),
              )
            else
              ...visible.map((flat) {
                final status = (flat['status'] ?? 'Unknown').toString();
                final isAvailable = status.toLowerCase() == 'available';

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Container(
                          height: 58,
                          width: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.home_work_outlined,
                            color: primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flat ${flat['flatnumber'] ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Wing ${flat['wing'] ?? '-'} • '
                                '${flat['floortype'] ?? '-'}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isAvailable
                                        ? const Color(0xFF166534)
                                        : const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              openFlatForm(flat: flat);
                            } else if (value == 'delete') {
                              deleteFlat(flat);
                            } else if (value == 'details') {
                              showFlatDetails(flat);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'details',
                              child: Text('View Details'),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit Flat'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Flat'),
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

  Widget _statCard(String title, String value, IconData icon) {
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
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> showFlatDetails(Map<String, dynamic> flat) async {
    try {
      final details = await service.getFlatById(
        (flat['flatid'] as num).toInt(),
      );

      if (!mounted) return;

      final society = details['society'];
      final societyName = society is Map
          ? (society['societyName'] ?? society['name'] ?? '-').toString()
          : 'Not available';

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Flat ${details['flatnumber'] ?? '-'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flat ID: ${details['flatid'] ?? '-'}'),
              Text('Wing: ${details['wing'] ?? '-'}'),
              Text('Floor Type: ${details['floortype'] ?? '-'}'),
              Text('Status: ${details['status'] ?? '-'}'),
              Text('Society: $societyName'),
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
      if (mounted) message(e.toString(), failed: true);
    }
  }
}
