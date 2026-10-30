import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResidentFacilityBookingScreen extends StatefulWidget {
  const ResidentFacilityBookingScreen({super.key});

  @override
  State<ResidentFacilityBookingScreen> createState() =>
      _ResidentFacilityBookingScreenState();
}

class _ResidentFacilityBookingScreenState
    extends State<ResidentFacilityBookingScreen> {
  static const String baseUrl = 'http://172.31.141.202:8080';

  static const Color blue = Color(0xFF2563EB);
  static const Color navy = Color(0xFF12345A);
  static const Color background = Color(0xFFF3F7FC);

  final residentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> facilities = [];
  List<Map<String, dynamic>> bookings = [];

  int? selectedFacilityId;
  DateTime? selectedDate;
  String? selectedSlot;

  bool loadingFacilities = false;
  bool loadingBookings = false;
  bool submitting = false;

  String? facilityError;
  String? bookingError;

  final List<String> timeSlots = const [
    '08:00 AM - 09:00 AM',
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 01:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
    '05:00 PM - 06:00 PM',
    '06:00 PM - 07:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    loadFacilities();
  }

  @override
  void dispose() {
    residentController.dispose();
    super.dispose();
  }

  int? getFacilityId(Map<String, dynamic> item) {
    final value = item['facilid'] ?? item['facilityId'] ?? item['id'];

    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  String getFacilityName(Map<String, dynamic> item) {
    return (item['facilname'] ??
            item['facilityName'] ??
            item['name'] ??
            'Facility')
        .toString();
  }

  // GET /facility/all
  Future<void> loadFacilities() async {
    setState(() {
      loadingFacilities = true;
      facilityError = null;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/facility/all'));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception('Facility API did not return a list.');
      }

      final result = data
          .map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        facilities = result;
        if (!result.any((item) => getFacilityId(item) == selectedFacilityId)) {
          selectedFacilityId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => facilityError = e.toString());
    } finally {
      if (mounted) {
        setState(() => loadingFacilities = false);
      }
    }
  }

  // GET /booking/resident/{residentId}
  Future<void> loadBookings() async {
    final id = int.tryParse(residentController.text.trim());

    if (id == null || id <= 0) {
      setState(() {
        bookingError = 'Enter a valid Resident ID.';
        bookings = [];
      });
      return;
    }

    setState(() {
      loadingBookings = true;
      bookingError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/booking/resident/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception('Booking API did not return a list.');
      }

      if (!mounted) return;

      setState(() {
        bookings = data
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item as Map),
            )
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => bookingError = e.toString());
    } finally {
      if (mounted) {
        setState(() => loadingBookings = false);
      }
    }
  }

  Future<void> selectDate() async {
    final now = DateTime.now();

    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (result != null && mounted) {
      setState(() => selectedDate = result);
    }
  }

  // POST /booking/add
  Future<void> bookFacility() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedFacilityId == null ||
        selectedDate == null ||
        selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select facility, date and time slot.')),
      );
      return;
    }

    final residentId = int.parse(residentController.text.trim());

    setState(() => submitting = true);

    try {
      final date =
          '${selectedDate!.year.toString().padLeft(4, '0')}-'
          '${selectedDate!.month.toString().padLeft(2, '0')}-'
          '${selectedDate!.day.toString().padLeft(2, '0')}';

      final response = await http.post(
        Uri.parse('$baseUrl/booking/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bookingDate': date,
          'timeSlot': selectedSlot,
          'status': 'Pending',
          'residentId': residentId,
          'facilid': selectedFacilityId,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Facility booking submitted!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        selectedFacilityId = null;
        selectedDate = null;
        selectedSlot = null;
      });

      await loadBookings();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Facility Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadingFacilities ? null : loadFacilities,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
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
                Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFFFFD166),
                  size: 42,
                ),
                SizedBox(height: 12),
                Text(
                  'Book a Facility',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Clubhouse, Gym and society facilities',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'New Booking',
            style: TextStyle(
              color: navy,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Resident ID manual input
                    TextFormField(
                      controller: residentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Resident ID',
                        hintText: 'Enter Resident ID',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final id = int.tryParse(value?.trim() ?? '');

                        if (id == null || id <= 0) {
                          return 'Enter a valid Resident ID';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Facilities dropdown
                    if (loadingFacilities)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (facilityError != null)
                      _errorBox(facilityError!, loadFacilities)
                    else if (facilities.isEmpty)
                      _errorBox(
                        'No facilities found. Add facilities in your backend first.',
                        loadFacilities,
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: selectedFacilityId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Facility',
                          prefixIcon: Icon(Icons.apartment),
                          border: OutlineInputBorder(),
                        ),
                        items: facilities
                            .where((f) => getFacilityId(f) != null)
                            .map((f) {
                              final id = getFacilityId(f)!;

                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  getFacilityName(f),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            })
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedFacilityId = value);
                        },
                        validator: (value) =>
                            value == null ? 'Select a facility' : null,
                      ),

                    const SizedBox(height: 16),

                    // Date picker
                    OutlinedButton.icon(
                      onPressed: selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        selectedDate == null
                            ? 'Choose Booking Date'
                            : '${selectedDate!.day}/'
                                  '${selectedDate!.month}/'
                                  '${selectedDate!.year}',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Time slot dropdown
                    DropdownButtonFormField<String>(
                      value: selectedSlot,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Time Slot',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                      items: timeSlots.map((slot) {
                        return DropdownMenuItem<String>(
                          value: slot,
                          child: Text(slot, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedSlot = value);
                      },
                      validator: (value) =>
                          value == null ? 'Select a time slot' : null,
                    ),

                    const SizedBox(height: 22),

                    // Book button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed:
                            submitting ||
                                loadingFacilities ||
                                facilities.isEmpty
                            ? null
                            : bookFacility,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        icon: submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.event_available),
                        label: Text(
                          submitting ? 'Booking...' : 'Book Facility',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // My bookings heading and button
          Row(
            children: [
              const Expanded(
                child: Text(
                  'My Bookings',
                  style: TextStyle(
                    color: navy,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: loadingBookings ? null : loadBookings,
                icon: const Icon(Icons.search),
                label: const Text('View'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (loadingBookings)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(),
              ),
            )
          else if (bookingError != null)
            _errorBox(bookingError!, loadBookings)
          else if (bookings.isEmpty)
            const Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Center(
                  child: Text(
                    'Enter Resident ID and tap View to see bookings.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            ...bookings.map((booking) {
              final status = (booking['status'] ?? 'Pending').toString();

              final facilityId = booking['facilid']?.toString() ?? '-';

              final matching = facilities.where(
                (f) => getFacilityId(f)?.toString() == facilityId,
              );

              final name = matching.isEmpty
                  ? 'Facility #$facilityId'
                  : getFacilityName(matching.first);

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0ECFF),
                    child: Icon(Icons.event_available, color: blue),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  subtitle: Text(
                    'Booking ID: ${booking['bookingid'] ?? '-'}\n'
                    'Date: ${booking['bookingDate'] ?? '-'}\n'
                    'Time: ${booking['timeSlot'] ?? '-'}\n'
                    'Status: $status',
                  ),
                  isThreeLine: true,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _errorBox(String message, VoidCallback retry) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          TextButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
