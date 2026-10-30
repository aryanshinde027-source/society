import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FacilityScreen extends StatefulWidget {
  const FacilityScreen({super.key});

  @override
  State<FacilityScreen> createState() => _FacilityScreenState();
}

class _FacilityScreenState extends State<FacilityScreen> {
  // Phone वर चालवत असशील तर laptop चा actual IPv4 address वापर.
  // Android emulator साठी 10.0.2.2 वापर.
  static const String baseUrl = 'http://10.0.2.2:8080';

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _facilities = [];
  bool _loading = false;
  String? _error;

  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF3F7FC);
  static const Color muted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // सर्व facilities साठी backend मध्ये असलेला
      // योग्य GET endpoint वापर.
      final response = await http.get(Uri.parse('$baseUrl/facility/getAll'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception(
          'Expected a JSON list. Check FacilityController response.',
        );
      }

      final facilities = decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      if (!mounted) return;

      setState(() {
        _facilities = facilities;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredFacilities {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return _facilities;

    return _facilities.where((facility) {
      return [
        facility['facilname'],
        facility['type'],
        facility['description'],
        facility['location'],
        facility['status'],
      ].any((value) => (value ?? '').toString().toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFacilities;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Facility Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadFacilities,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
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
                        'Manage Facilities',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'View available society facilities.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.apartment_rounded, color: Colors.white, size: 48),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search name, type or location',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _loading && _facilities.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _facilities.isEmpty
                ? _errorWidget()
                : filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No facilities found',
                      style: TextStyle(color: muted, fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadFacilities,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final facility = filtered[index];

                        final id =
                            facility['facilid'] ??
                            facility['facilityId'] ??
                            '-';

                        final name =
                            facility['facilname'] ?? 'Unnamed Facility';

                        final status = facility['status'] ?? 'Unknown';

                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0ECFF),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.holiday_village_rounded,
                                        color: blue,
                                        size: 29,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Text(
                                        name.toString(),
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF12345A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                _detail('Facility ID', id.toString()),
                                _detail('Type', '${facility['type'] ?? '-'}'),
                                _detail(
                                  'Description',
                                  '${facility['description'] ?? '-'}',
                                ),
                                _detail(
                                  'Location',
                                  '${facility['location'] ?? '-'}',
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      status.toString(),
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status.toString(),
                                    style: TextStyle(
                                      color: _statusColor(status.toString()),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(color: muted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'active':
        return Colors.green;
      case 'unavailable':
      case 'inactive':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _errorWidget() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 55,
            ),
            const SizedBox(height: 15),
            const Text(
              'Could not load facilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _loadFacilities,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
