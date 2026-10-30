import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SecretaryFacilityManagementScreen extends StatefulWidget {
  const SecretaryFacilityManagementScreen({super.key});

  @override
  State<SecretaryFacilityManagementScreen> createState() =>
      _SecretaryFacilityManagementScreenState();
}

class _SecretaryFacilityManagementScreenState
    extends State<SecretaryFacilityManagementScreen> {
  static const String baseUrl = 'http://172.31.141.202:8080';

  // Android emulator:
  // static const String baseUrl = 'http://10.0.2.2:8080';

  static const Color blue = Color(0xFF2563EB);
  static const Color navy = Color(0xFF12345A);
  static const Color background = Color(0xFFF3F7FC);

  List<Map<String, dynamic>> facilities = [];
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> societies = [];

  bool loadingFacilities = false;
  bool loadingBookings = false;
  bool loadingSocieties = false;

  String? facilityError;
  String? bookingError;
  String? societyError;

  @override
  void initState() {
    super.initState();
    loadFacilities();
    loadBookings();
    loadSocieties();
  }

  int number(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<List<Map<String, dynamic>>> getList(String path) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl$path'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    if (response.body.trim().isEmpty) return [];

    final data = jsonDecode(response.body);

    if (data is! List) {
      throw Exception('Expected a JSON list from $path');
    }

    return data
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item as Map),
        )
        .toList();
  }

  Future<void> loadFacilities() async {
    if (!mounted) return;

    setState(() {
      loadingFacilities = true;
      facilityError = null;
    });

    try {
      final result = await getList('/facility/all');

      if (!mounted) return;
      setState(() => facilities = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => facilityError = e.toString());
    } finally {
      if (mounted) setState(() => loadingFacilities = false);
    }
  }

  Future<void> loadBookings() async {
    if (!mounted) return;

    setState(() {
      loadingBookings = true;
      bookingError = null;
    });

    try {
      final result = await getList('/booking/all');

      if (!mounted) return;
      setState(() => bookings = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => bookingError = e.toString());
    } finally {
      if (mounted) setState(() => loadingBookings = false);
    }
  }

  Future<void> loadSocieties() async {
    if (!mounted) return;

    setState(() {
      loadingSocieties = true;
      societyError = null;
    });

    try {
      final result = await getList('/society/getAll');

      if (!mounted) return;
      setState(() => societies = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => societyError = e.toString());
    } finally {
      if (mounted) setState(() => loadingSocieties = false);
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([loadFacilities(), loadBookings(), loadSocieties()]);
  }

  int getFacilityId(Map<String, dynamic> facility) {
    return number(
      facility['facilid'] ?? facility['facilityId'] ?? facility['id'],
    );
  }

  String getFacilityName(int id) {
    for (final facility in facilities) {
      if (getFacilityId(facility) == id) {
        return (facility['facilname'] ??
                facility['facilityName'] ??
                facility['name'] ??
                'Facility')
            .toString();
      }
    }

    return 'Facility #$id';
  }

  String getSocietyName(dynamic id) {
    for (final society in societies) {
      final societyId = number(society['societyId'] ?? society['societyid']);

      if (societyId == number(id)) {
        return (society['societyname'] ?? society['name'] ?? 'Society')
            .toString();
      }
    }

    return 'Society #${id ?? '-'}';
  }

  bool isPending(Map<String, dynamic> booking) {
    final status = (booking['status'] ?? '').toString().trim().toLowerCase();

    return status == 'pending' || status == 'requested' || status == 'waiting';
  }

  void showMessage(String text, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ADD / EDIT FACILITY
  Future<void> openFacilityForm({Map<String, dynamic>? facility}) async {
    final nameController = TextEditingController(
      text: (facility?['facilname'] ?? facility?['facilityName'] ?? '')
          .toString(),
    );

    final typeController = TextEditingController(
      text: (facility?['type'] ?? '').toString(),
    );

    final descriptionController = TextEditingController(
      text: (facility?['description'] ?? '').toString(),
    );

    final locationController = TextEditingController(
      text: (facility?['location'] ?? '').toString(),
    );

    int? selectedSocietyId = number(
      facility?['societyId'] ?? facility?['societyid'],
    );

    if (selectedSocietyId == 0) selectedSocietyId = null;

    String status = (facility?['status'] ?? 'Available').toString();

    if (!['Available', 'Unavailable'].contains(status)) {
      status = 'Available';
    }

    bool saving = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(facility == null ? 'Add Facility' : 'Edit Facility'),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Facility Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: typeController,
                        decoration: const InputDecoration(
                          labelText: 'Facility Type *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (loadingSocieties)
                        const CircularProgressIndicator()
                      else if (societyError != null)
                        Column(
                          children: [
                            Text(
                              societyError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: loadSocieties,
                              child: const Text('Retry Societies'),
                            ),
                          ],
                        )
                      else
                        DropdownButtonFormField<int>(
                          value: selectedSocietyId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Society *',
                            border: OutlineInputBorder(),
                          ),
                          items: societies
                              .map((society) {
                                final id = number(
                                  society['societyId'] ?? society['societyid'],
                                );

                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(
                                    (society['societyname'] ??
                                            society['name'] ??
                                            'Society $id')
                                        .toString(),
                                  ),
                                );
                              })
                              .where((item) => item.value != 0)
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedSocietyId = value);
                          },
                        ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Facility Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Available',
                            child: Text('Available'),
                          ),
                          DropdownMenuItem(
                            value: 'Unavailable',
                            child: Text('Unavailable'),
                          ),
                        ],
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
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final type = typeController.text.trim();

                          if (name.isEmpty ||
                              type.isEmpty ||
                              selectedSocietyId == null) {
                            showMessage(
                              'Facility name, type and society are required.',
                              isError: true,
                            );
                            return;
                          }

                          setDialogState(() => saving = true);

                          try {
                            final isEdit = facility != null;
                            final id = isEdit ? getFacilityId(facility) : 0;

                            final uri = isEdit
                                ? Uri.parse('$baseUrl/facility/update/$id')
                                : Uri.parse('$baseUrl/facility/add');

                            final payload = <String, dynamic>{
                              'facilname': name,
                              'type': type,
                              'description': descriptionController.text.trim(),
                              'location': locationController.text.trim(),
                              'status': status,
                              'societyId': selectedSocietyId,
                            };

                            if (isEdit) {
                              payload['facilid'] = id;
                            }

                            final response = isEdit
                                ? await http.put(
                                    uri,
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Accept': 'application/json',
                                    },
                                    body: jsonEncode(payload),
                                  )
                                : await http.post(
                                    uri,
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Accept': 'application/json',
                                    },
                                    body: jsonEncode(payload),
                                  );

                            if (response.statusCode < 200 ||
                                response.statusCode >= 300) {
                              throw Exception(
                                'HTTP ${response.statusCode}: '
                                '${response.body}',
                              );
                            }

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            showMessage(
                              isEdit
                                  ? 'Facility updated successfully.'
                                  : 'Facility added successfully.',
                            );

                            await loadFacilities();
                          } catch (e) {
                            showMessage(
                              'Facility save failed: $e',
                              isError: true,
                            );

                            setDialogState(() => saving = false);
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          facility == null ? 'Add Facility' : 'Save Changes',
                        ),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      nameController.dispose();
      typeController.dispose();
      descriptionController.dispose();
      locationController.dispose();
    }
  }

  // MARK UNAVAILABLE INSTEAD OF DELETING BOOKED FACILITIES
  Future<void> markFacilityUnavailable(Map<String, dynamic> facility) async {
    final id = getFacilityId(facility);

    if (id <= 0) {
      showMessage('Facility ID not found.', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark Facility Unavailable?'),
        content: const Text(
          'This facility will remain in the database, '
          'but it should not be offered for new bookings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final payload = <String, dynamic>{
        'facilid': id,
        'facilname':
            facility['facilname'] ??
            facility['facilityName'] ??
            facility['name'],
        'type': facility['type'],
        'description': facility['description'],
        'location': facility['location'],
        'status': 'Unavailable',
        'societyId': number(facility['societyId'] ?? facility['societyid']),
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/facility/update/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      showMessage('Facility marked as Unavailable.');
      await loadFacilities();
    } catch (e) {
      showMessage('Could not update facility: $e', isError: true);
    }
  }

  // BOOKING APPROVAL
  Future<void> updateBooking(
    Map<String, dynamic> booking,
    String newStatus,
  ) async {
    final id = number(booking['bookingid'] ?? booking['bookingId']);

    if (id <= 0) {
      showMessage('Booking ID not found.', isError: true);
      return;
    }

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/booking/update/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'bookingid': id,
              'bookingDate': booking['bookingDate'],
              'timeSlot': booking['timeSlot'],
              'status': newStatus,
              'residentId': number(booking['residentId']),
              'facilid': number(booking['facilid'] ?? booking['facilityId']),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      showMessage('Booking $newStatus successfully.');
      await loadBookings();
    } catch (e) {
      showMessage('Booking update failed: $e', isError: true);
    }
  }

  Widget detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.blueGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: navy, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        title,
        style: const TextStyle(
          color: navy,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget errorCard(String error, VoidCallback retry) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, color: Colors.red, size: 36),
            const SizedBox(height: 8),
            SelectableText(error, textAlign: TextAlign.center),
            TextButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingBookings = bookings.where(isPending).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Secretary Facility Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: refreshAll,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF12345A), Color(0xFF087FC1)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.apartment, size: 42, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Manage Facilities',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Add facilities, update details and approve bookings.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            sectionTitle('Booking Approval Requests'),

            if (loadingBookings)
              const Center(child: CircularProgressIndicator())
            else if (bookingError != null)
              errorCard(bookingError!, loadBookings)
            else if (pendingBookings.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('No pending booking requests.')),
                ),
              )
            else
              ...pendingBookings.map((booking) {
                final id = number(booking['bookingid'] ?? booking['bookingId']);

                final residentId = booking['residentId'] ?? '-';

                final fid = number(booking['facilid'] ?? booking['facilityId']);

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getFacilityName(fid),
                          style: const TextStyle(
                            color: navy,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        detail('Booking ID', '$id'),
                        detail('Facility ID', '$fid'),
                        detail('Resident ID', '$residentId'),
                        detail(
                          'Booking Date',
                          '${booking['bookingDate'] ?? '-'}',
                        ),
                        detail('Time Slot', '${booking['timeSlot'] ?? '-'}'),
                        detail('Status', '${booking['status'] ?? '-'}'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    updateBooking(booking, 'Approved'),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    updateBooking(booking, 'Rejected'),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

            sectionTitle('All Facilities'),

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => openFacilityForm(),
                icon: const Icon(Icons.add_business),
                label: const Text('Add Facility'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (loadingFacilities)
              const Center(child: CircularProgressIndicator())
            else if (facilityError != null)
              errorCard(facilityError!, loadFacilities)
            else if (facilities.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('No facilities found.'),
                ),
              )
            else
              ...facilities.map((facility) {
                final id = getFacilityId(facility);

                final name =
                    (facility['facilname'] ??
                            facility['facilityName'] ??
                            facility['name'] ??
                            'Facility')
                        .toString();

                final societyId =
                    facility['societyId'] ?? facility['societyid'] ?? '-';

                final status = (facility['status'] ?? '-').toString();

                final unavailable = status.toLowerCase() == 'unavailable';

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFE0ECFF),
                              child: Icon(Icons.apartment, color: blue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: navy,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  openFacilityForm(facility: facility);
                                } else if (value == 'unavailable') {
                                  markFacilityUnavailable(facility);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: blue),
                                      SizedBox(width: 8),
                                      Text('Edit Facility'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'unavailable',
                                  child: Row(
                                    children: [
                                      Icon(Icons.block, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Mark Unavailable'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        detail('Facility ID', '$id'),
                        detail('Society', getSocietyName(societyId)),
                        detail('Type', '${facility['type'] ?? '-'}'),
                        detail('Location', '${facility['location'] ?? '-'}'),
                        detail('Status', status),
                        if ((facility['description'] ?? '')
                            .toString()
                            .trim()
                            .isNotEmpty)
                          detail('Description', '${facility['description']}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    openFacilityForm(facility: facility),
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: unavailable
                                    ? null
                                    : () => markFacilityUnavailable(facility),
                                icon: const Icon(Icons.block),
                                label: Text(
                                  unavailable
                                      ? 'Unavailable'
                                      : 'Make Unavailable',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
