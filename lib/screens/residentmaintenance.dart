import 'package:flutter/material.dart';
import 'package:society_management/services/maintainceservice.dart';

class ResidentMaintenanceScreen extends StatefulWidget {
  const ResidentMaintenanceScreen({super.key});

  @override
  State<ResidentMaintenanceScreen> createState() =>
      _ResidentMaintenanceScreenState();
}

class _ResidentMaintenanceScreenState extends State<ResidentMaintenanceScreen> {
  final MaintainceService service = MaintainceService();

  final Color background = const Color(0xFF0B1120);
  final Color surface = const Color(0xFF151F32);
  final Color blue = const Color(0xFF60A5FA);
  final Color muted = const Color(0xFF94A3B8);

  List<Map<String, dynamic>> records = [];
  bool loading = true;
  String? error;
  String search = '';

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await service.getAllMaintaince();

      if (!mounted) return;

      setState(() {
        records = result;
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

  int? getFlatId(Map<String, dynamic> record) {
    final flat = record['flat'];

    final value =
        record['flatId'] ??
        record['flatid'] ??
        (flat is Map ? flat['flatid'] ?? flat['flatId'] : null);

    if (value == null) return null;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  List<Map<String, dynamic>> get filteredRecords {
    final query = search.trim().toLowerCase();

    if (query.isEmpty) return records;

    return records.where((record) {
      final flatId = getFlatId(record);

      final values = [
        record['maintainceid'],
        flatId,
        record['amount'],
        record['amountdue'],
        record['paymentDate'],
        record['paymentStatus'],
      ];

      return values.any(
        (value) => value.toString().toLowerCase().contains(query),
      );
    }).toList();
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.greenAccent;
      case 'overdue':
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  Widget detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: muted, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: TextStyle(color: muted, fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget maintenanceCard(Map<String, dynamic> record) {
    final id = record['maintainceid']?.toString() ?? '-';
    final flatId = getFlatId(record)?.toString() ?? 'Not provided';
    final amount = record['amount']?.toString() ?? '0';
    final due = record['amountdue']?.toString() ?? '0';
    final date = record['paymentDate']?.toString() ?? '-';
    final status = record['paymentStatus']?.toString() ?? 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: blue.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long, color: blue, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maintenance #$id',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Flat ID: $flatId',
                      style: TextStyle(
                        color: blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor(status).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor(status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: muted.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          detailRow(Icons.currency_rupee, 'Maintenance Amount', '₹$amount'),
          detailRow(
            Icons.account_balance_wallet_outlined,
            'Amount Due',
            '₹$due',
          ),
          detailRow(Icons.calendar_month_outlined, 'Payment Date', date),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        title: const Text(
          'My Maintenance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadRecords,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadRecords,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
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
                            'Maintenance Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'View flat charges and payment status.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.apartment, size: 44, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() => search = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by Flat ID or status...',
                  hintStyle: TextStyle(color: muted),
                  prefixIcon: Icon(Icons.search, color: muted),
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
                  padding: EdgeInsets.all(35),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        color: Colors.orangeAccent,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load maintenance records',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: loadRecords,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              else if (filteredRecords.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 50, color: muted),
                      const SizedBox(height: 12),
                      Text(
                        search.isEmpty
                            ? 'No maintenance records found'
                            : 'No matching records found',
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  '${filteredRecords.length} maintenance records',
                  style: TextStyle(color: muted, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                ...filteredRecords.map(maintenanceCard),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
