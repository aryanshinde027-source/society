import 'package:flutter/material.dart';
import 'package:society_management/services/maintainceservice.dart';

class MaintainceScreen extends StatefulWidget {
  const MaintainceScreen({super.key});

  @override
  State<MaintainceScreen> createState() => _MaintainceScreenState();
}

class _MaintainceScreenState extends State<MaintainceScreen> {
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

  List<Map<String, dynamic>> get filteredRecords {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return records;

    return records.where((item) {
      return [
        item['maintainceid'],
        item['amount'],
        item['amountdue'],
        item['paymentDate'],
        item['paymentStatus'],
      ].any((value) => value.toString().toLowerCase().contains(query));
    }).toList();
  }

  int todayAsInt() {
    final date = DateTime.now();
    return date.year * 10000 + date.month * 100 + date.day;
  }

  InputDecoration decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: muted),
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
        borderSide: BorderSide(color: blue),
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
              title: Text(
                record == null ? 'Add Maintenance' : 'Update Maintenance',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                          style: const TextStyle(color: Colors.white),
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
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Payment date: ${todayAsInt()}',
                            style: TextStyle(color: muted, fontSize: 12),
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
                  child: Text('Cancel', style: TextStyle(color: muted)),
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
                                      ? 'Maintenance added'
                                      : 'Maintenance updated',
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
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
        return Colors.greenAccent;
      case 'overdue':
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  Future<void> deleteRecord(Map<String, dynamic> record) async {
    final id = (record['maintainceid'] as num).toInt();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        title: const Text(
          'Delete maintenance?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete record #$id?',
          style: TextStyle(color: muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maintenance deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Widget maintenanceCard(Map<String, dynamic> record) {
    final id = record['maintainceid']?.toString() ?? '-';
    final amount = record['amount']?.toString() ?? '0';
    final due = record['amountdue']?.toString() ?? '-';
    final date = record['paymentDate']?.toString() ?? '-';
    final status = record['paymentStatus']?.toString() ?? 'Pending';

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
                  color: blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long, color: blue),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Payment date: $date',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: surface,
                icon: Icon(Icons.more_vert, color: muted),
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
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount', style: TextStyle(color: muted)),
                    const SizedBox(height: 5),
                    Text(
                      '₹$amount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor(status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: muted.withValues(alpha: 0.15)),
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: muted,
              ),
              const SizedBox(width: 8),
              Text('Amount due: $due', style: TextStyle(color: muted)),
            ],
          ),
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
          'Maintenance',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openForm(),
        backgroundColor: blue,
        foregroundColor: background,
        icon: const Icon(Icons.add),
        label: const Text('Add Maintenance'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadRecords,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(22),
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Manage flat charges and payment status.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.account_balance,
                      size: 45,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'All Records',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${records.length} records',
                    style: TextStyle(color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => search = value),
                decoration: InputDecoration(
                  hintText: 'Search maintenance...',
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
                        Icons.cloud_off,
                        size: 42,
                        color: Colors.orangeAccent,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load maintenance records',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 52, color: muted),
                      const SizedBox(height: 12),
                      Text(
                        search.isEmpty
                            ? 'No maintenance records found'
                            : 'No matching records',
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                )
              else
                ...filteredRecords.map(maintenanceCard),
            ],
          ),
        ),
      ),
    );
  }
}
