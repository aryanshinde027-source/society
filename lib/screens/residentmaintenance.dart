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

  static const Color navy = Color(0xFF14294E);
  static const Color navyLight = Color(0xFF294B80);
  static const Color gold = Color(0xFFDDBB70);
  static const Color background = Color(0xFFF4F6FB);
  static const Color muted = Color(0xFF8490A0);

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

  int get paidCount => records
      .where(
        (r) => (r['paymentStatus'] ?? '').toString().toLowerCase() == 'paid',
      )
      .length;

  int get pendingCount => records
      .where(
        (r) => (r['paymentStatus'] ?? '').toString().toLowerCase() != 'paid',
      )
      .length;

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.orange.shade800;
    }
  }

  // STATISTIC CARD
  Widget statCard({
    required IconData icon,
    required String count,
    required String title,
  }) {
    return Expanded(
      child: Container(
        height: 165,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFE4E8EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFF4EEDF),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(icon, color: navy, size: 27),
            ),

            const SizedBox(height: 14),

            Text(
              count,
              style: const TextStyle(
                color: navy,
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 4),

            Text(title, style: const TextStyle(color: muted, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // DETAIL ROW
  Widget detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: muted, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: muted, fontSize: 14),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MAINTENANCE RECORD CARD
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E8EF)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  color: const Color(0xFFF4EEDF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: navy,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maintenance #$id',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Flat ID: $flatId',
                      style: const TextStyle(
                        color: muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor(status),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Divider(color: Color(0xFFE8ECF2)),

          const SizedBox(height: 15),

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

      // APP BAR
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 72,
        title: const Text(
          'Maintenance',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadRecords,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),

      // BODY
      body: SafeArea(
        child: RefreshIndicator(
          color: navy,
          onRefresh: loadRecords,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(17, 25, 17, 30),
            children: [
              // HEADER BANNER
              Container(
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [navy, navyLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Maintenance Payments',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 13),

                          const Text(
                            'Manage flat charges and payment status.',
                            style: TextStyle(
                              color: Color(0xFFD2DCEB),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Container(
                      height: 85,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: gold,
                        size: 45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // STATISTICS
              Row(
                children: [
                  statCard(
                    icon: Icons.receipt_long_rounded,
                    count: records.length.toString(),
                    title: 'Total Records',
                  ),

                  const SizedBox(width: 10),

                  statCard(
                    icon: Icons.check_circle_outline_rounded,
                    count: paidCount.toString(),
                    title: 'Paid',
                  ),

                  const SizedBox(width: 10),

                  statCard(
                    icon: Icons.pending_actions_rounded,
                    count: pendingCount.toString(),
                    title: 'Pending',
                  ),
                ],
              ),

              const SizedBox(height: 45),

              // ALL RECORDS
              const Text(
                'All Records',
                style: TextStyle(
                  color: navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 20),

              // SEARCH
              TextField(
                style: const TextStyle(color: navy, fontSize: 15),
                onChanged: (value) {
                  setState(() => search = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by ID, amount, status or Flat ID',
                  hintStyle: const TextStyle(color: muted, fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: navy,
                    size: 28,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 23,
                    horizontal: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(23),
                    borderSide: const BorderSide(color: Color(0xFFE2E7EF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(23),
                    borderSide: const BorderSide(color: gold, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // LOADING
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(45),
                  child: Center(child: CircularProgressIndicator(color: navy)),
                )
              // ERROR
              else if (error != null)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: Colors.orange,
                        size: 45,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load maintenance records',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: muted),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: loadRecords,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              // EMPTY
              else if (filteredRecords.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(35),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        color: navy,
                        size: 55,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        search.isEmpty
                            ? 'No maintenance records found'
                            : 'No matching records found',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              // RECORDS
              else ...[
                Text(
                  '${filteredRecords.length} Records Found',
                  style: const TextStyle(
                    color: muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 15),

                ...filteredRecords.map(maintenanceCard),
              ],
            ],
          ),
        ),
      ),

      // NO ADD MAINTENANCE BUTTON
    );
  }
}
