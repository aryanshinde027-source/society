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

  static const Color navy = Color(0xFF14294E);
  static const Color navyLight = Color(0xFF344D80);
  static const Color gold = Color(0xFFD9B65D);
  static const Color background = Color(0xFFF3F5FA);

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

  // ================= LOAD FLATS =================

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

  // ================= STATISTICS =================

  int get availableCount {
    return flats
        .where(
          (flat) =>
              (flat['status'] ?? '').toString().toLowerCase() == 'available',
        )
        .length;
  }

  int get occupiedCount {
    return flats
        .where(
          (flat) =>
              (flat['status'] ?? '').toString().toLowerCase() == 'occupied',
        )
        .length;
  }

  int get maintenanceCount {
    return flats
        .where(
          (flat) =>
              (flat['status'] ?? '').toString().toLowerCase() == 'maintenance',
        )
        .length;
  }

  // ================= SEARCH =================

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

  // ================= MESSAGE =================

  void message(String text, {bool failed = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: failed ? Colors.red : Colors.green,
      ),
    );
  }

  // ================= ADD / EDIT FLAT =================

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                editing ? 'Edit Flat' : 'Add New Flat',
                style: const TextStyle(
                  color: navy,
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
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

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

  // ================= FORM FIELD =================

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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

  // ================= DELETE FLAT =================

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

  // ================= STATISTICS CARD =================

  Widget _statCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFE3E8EF), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFDF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 27),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              color: navy,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8490A0)),
          ),
        ],
      ),
    );
  }

  // ================= HERO CARD =================

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [navy, navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.apartment_rounded, color: gold, size: 43),
          const SizedBox(height: 25),
          const Text(
            'Manage Your Flats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'View, add and manage society flats.',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ================= FLAT DETAILS =================

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Flat ${details['flatnumber'] ?? '-'}',
            style: const TextStyle(color: navy, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flat ID: ${details['flatid'] ?? '-'}'),
              const SizedBox(height: 10),
              Text('Wing: ${details['wing'] ?? '-'}'),
              const SizedBox(height: 10),
              Text('Floor Type: ${details['floortype'] ?? '-'}'),
              const SizedBox(height: 10),
              Text('Status: ${details['status'] ?? '-'}'),
              const SizedBox(height: 10),
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
      if (mounted) {
        message(e.toString(), failed: true);
      }
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final visible = filteredFlats;

    return Scaffold(
      backgroundColor: background,

      // APP BAR
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Flat Management',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 21),
        ),
        actions: [
          IconButton(
            onPressed: loadFlats,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),

      // ADD FLAT BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openFlatForm(),
        backgroundColor: gold,
        foregroundColor: navy,
        elevation: 5,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Flat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // BODY
      body: RefreshIndicator(
        onRefresh: loadFlats,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          children: [
            // HERO
            _heroCard(),

            const SizedBox(height: 22),

            // FOUR COMPACT STATISTICS CARDS
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.47,
                  children: [
                    _statCard(
                      'Total Flats',
                      '${flats.length}',
                      Icons.other_houses_outlined,
                      navy,
                    ),
                    _statCard(
                      'Available',
                      '$availableCount',
                      Icons.check_circle_outline_rounded,
                      Colors.green,
                    ),
                    _statCard(
                      'Occupied',
                      '$occupiedCount',
                      Icons.people_outline_rounded,
                      Colors.lightBlue,
                    ),
                    _statCard(
                      'Maintenance',
                      '$maintenanceCount',
                      Icons.build_outlined,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // SEARCH
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() => searchText = value);
              },
              decoration: InputDecoration(
                hintText: 'Search by flat, wing or status...',
                hintStyle: const TextStyle(
                  color: Color(0xFF929BAA),
                  fontSize: 15,
                ),
                prefixIcon: const Icon(Icons.search, color: navy, size: 27),
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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 21,
                  horizontal: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: Color(0xFFE4E8EF)),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ALL FLATS TITLE
            const Text(
              'All Flats',
              style: TextStyle(
                color: navy,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 18),

            // LOADING
            if (loading)
              const Padding(
                padding: EdgeInsets.all(35),
                child: Center(child: CircularProgressIndicator(color: navy)),
              )
            // ERROR
            else if (error != null)
              Card(
                color: Colors.white,
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
            // EMPTY
            else if (visible.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE3E8EF)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.other_houses_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No flats found',
                      style: TextStyle(
                        color: navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            // FLAT LIST
            else
              ...visible.map((flat) {
                final status = (flat['status'] ?? 'Unknown').toString();

                final isAvailable = status.toLowerCase() == 'available';

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(color: Color(0xFFE3E8EF)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5EFDF),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Icon(
                            Icons.home_work_outlined,
                            color: navy,
                            size: 29,
                          ),
                        ),

                        const SizedBox(width: 13),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flat ${flat['flatnumber'] ?? '-'}',
                                style: const TextStyle(
                                  color: navy,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Wing ${flat['wing'] ?? '-'} • '
                                '${flat['floortype'] ?? '-'}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 9),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
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
                                    fontWeight: FontWeight.w700,
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

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}
