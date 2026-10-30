import 'package:flutter/material.dart';
import 'package:society_management/services/maintainceservice.dart';

class MaintainceScreen extends StatefulWidget {
  const MaintainceScreen({super.key});

  @override
  State<MaintainceScreen> createState() => _MaintainceScreenState();
}

class _MaintainceScreenState extends State<MaintainceScreen> {
  final MaintainceService service = MaintainceService();

  static const Color background = Color(0xFFF3F5FA);
  static const Color surface = Colors.white;
  static const Color navy = Color(0xFF122B4E);
  static const Color blue = Color(0xFF244C80);
  static const Color gold = Color(0xFFD9B66F);
  static const Color muted = Color(0xFF8290A0);

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

  List<Map<String, dynamic>> get filteredRecords {
    final query = search.trim().toLowerCase();

    if (query.isEmpty) return records;

    return records.where((item) {
      final flatId =
          item['flat']?['flatid'] ??
          item['flat']?['flatId'] ??
          item['flatId'] ??
          '';

      return [
        item['maintainceid'],
        item['amount'],
        item['amountdue'],
        item['paymentDate'],
        item['paymentStatus'],
        flatId,
      ].any((value) => value.toString().toLowerCase().contains(query));
    }).toList();
  }

  int get paidCount {
    return records
        .where(
          (item) =>
              (item['paymentStatus'] ?? '').toString().toLowerCase() == 'paid',
        )
        .length;
  }

  int get pendingCount {
    return records.length - paidCount;
  }

  int todayAsInt() {
    final date = DateTime.now();
    return date.year * 10000 + date.month * 100 + date.day;
  }

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
        borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
    );
  }

  Widget formField({
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

  // ADD / UPDATE MAINTENANCE
  Future<void> openForm({Map<String, dynamic>? record}) async {
    final formKey = GlobalKey<FormState>();

    final amountController = TextEditingController(
      text: record?['amount']?.toString() ?? '',
    );

    final dueController = TextEditingController(
      text: record?['amountdue']?.toString() ?? '',
    );

    final flatController = TextEditingController(
      text: (record?['flat']?['flatid'] ?? '').toString(),
    );

    String status = record?['paymentStatus']?.toString() ?? 'Pending';

    const statuses = ['Pending', 'Paid', 'Overdue'];

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
                record == null ? 'Add Maintenance' : 'Update Maintenance',
                style: const TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w900,
                  fontSize: 21,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        formField(
                          controller: amountController,
                          label: 'Amount',
                          icon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        formField(
                          controller: dueController,
                          label: 'Amount Due',
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                        const SizedBox(height: 14),
                        formField(
                          controller: flatController,
                          label: 'Flat ID',
                          icon: Icons.apartment,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: status,
                          dropdownColor: surface,
                          style: const TextStyle(color: navy),
                          decoration: decoration(
                            'Payment Status',
                            Icons.payment,
                          ),
                          items: statuses.map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => status = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Payment date: ${todayAsInt()}',
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
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
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
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

                          final amount = int.tryParse(
                            amountController.text.trim(),
                          );

                          final flatId = int.tryParse(
                            flatController.text.trim(),
                          );

                          if (amount == null || amount < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid amount'),
                              ),
                            );
                            return;
                          }

                          if (flatId == null || flatId <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid Flat ID'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => saving = true);

                          try {
                            if (record == null) {
                              await service.addMaintaince(
                                amount: amount,
                                amountdue: dueController.text.trim(),
                                paymentDate: todayAsInt(),
                                paymentStatus: status,
                                flatId: flatId,
                              );
                            } else {
                              await service.updateMaintaince(
                                maintainceId: (record['maintainceid'] as num)
                                    .toInt(),
                                amount: amount,
                                amountdue: dueController.text.trim(),
                                paymentDate:
                                    (record['paymentDate'] as num?)?.toInt() ??
                                    todayAsInt(),
                                paymentStatus: status,
                                flatId: flatId,
                              );
                            }

                            if (!mounted) return;

                            Navigator.pop(dialogContext);
                            await loadRecords();

                            if (!mounted) return;

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  record == null
                                      ? 'Maintenance added successfully'
                                      : 'Maintenance updated successfully',
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
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(record == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    dueController.dispose();
    flatController.dispose();
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  // DELETE MAINTENANCE
  Future<void> deleteRecord(Map<String, dynamic> record) async {
    final id = (record['maintainceid'] as num).toInt();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete maintenance?',
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete record #$id?',
          style: const TextStyle(color: muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
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

    if (confirm != true) return;

    try {
      await service.deleteMaintaince(id);
      await loadRecords();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maintenance deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  // SUMMARY CARD
  Widget summaryCard({
    required IconData icon,
    required int count,
    required String title,
  }) {
    return Expanded(
      child: Container(
        height: 145,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE3E8EF)),
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
            Container(
              height: 47,
              width: 47,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: navy, size: 25),
            ),
            const Spacer(),
            Text(
              count.toString(),
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w900,
                fontSize: 27,
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MAINTENANCE CARD
  Widget maintenanceCard(Map<String, dynamic> record) {
    final id = record['maintainceid']?.toString() ?? '-';
    final amount = record['amount']?.toString() ?? '0';
    final due = record['amountdue']?.toString() ?? '-';
    final date = record['paymentDate']?.toString() ?? '-';
    final status = record['paymentStatus']?.toString() ?? 'Pending';
    final flatId = record['flat']?['flatid'] ?? record['flatId'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAF0)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.04),
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
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5DF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: gold,
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
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Payment date: $date',
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
                    openForm(record: record);
                  } else if (value == 'delete') {
                    deleteRecord(record);
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

          const SizedBox(height: 19),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '₹$amount',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor(status).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor(status),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),
          const Divider(color: Color(0xFFEDF0F5)),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: gold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Amount due: ₹$due',
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
              ),
              const Icon(Icons.apartment_rounded, size: 17, color: gold),
              const SizedBox(width: 5),
              Text(
                'Flat $flatId',
                style: const TextStyle(
                  color: navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Maintenance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 23,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadRecords,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 27,
            ),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ADD MAINTENANCE BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openForm(),
        backgroundColor: gold,
        foregroundColor: navy,
        elevation: 7,
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text(
          'Add Maintenance',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadRecords,
          color: navy,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
            children: [
              // BANNER
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF112A4D), Color(0xFF294B7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withOpacity(0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Maintenance Payments',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Manage flat charges and payment status.',
                            style: TextStyle(
                              color: Color(0xFFD7E2F0),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 85,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: gold,
                        size: 49,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SUMMARY CARDS
              Row(
                children: [
                  summaryCard(
                    icon: Icons.receipt_long_rounded,
                    count: records.length,
                    title: 'Total Records',
                  ),
                  const SizedBox(width: 10),
                  summaryCard(
                    icon: Icons.check_circle_outline_rounded,
                    count: paidCount,
                    title: 'Paid',
                  ),
                  const SizedBox(width: 10),
                  summaryCard(
                    icon: Icons.pending_actions_rounded,
                    count: pendingCount,
                    title: 'Pending',
                  ),
                ],
              ),

              const SizedBox(height: 27),

              // ALL RECORDS
              const Text(
                'All Records',
                style: TextStyle(
                  color: navy,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 16),

              // SEARCH
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: const Color(0xFFE1E7EF)),
                ),
                child: TextField(
                  style: const TextStyle(color: navy),
                  onChanged: (value) {
                    setState(() => search = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by ID, amount, status or Flat ID',
                    hintStyle: const TextStyle(color: muted, fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: navy,
                      size: 27,
                    ),
                    suffixIcon: search.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() => search = '');
                            },
                            icon: const Icon(Icons.close, color: muted),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 22),

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
                        size: 45,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load maintenance records',
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
                        onPressed: loadRecords,
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
              else if (filteredRecords.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        size: 55,
                        color: gold,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        search.isEmpty
                            ? 'No maintenance records found'
                            : 'No matching records',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              // RECORDS
              else
                ...filteredRecords.map(maintenanceCard),
            ],
          ),
        ),
      ),
    );
  }
}
