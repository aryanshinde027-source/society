import 'package:flutter/material.dart';
import 'package:society_management/services/complaintservice.dart';

class ComplaintsScreen extends StatefulWidget {
  final int? residentId;

  const ComplaintsScreen({super.key, this.residentId});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final ComplaintService service = ComplaintService();

  final Color background = const Color(0xFF0B1120);
  final Color surface = const Color(0xFF151F32);
  final Color blue = const Color(0xFF60A5FA);
  final Color muted = const Color(0xFF94A3B8);

  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadComplaints();
  }

  Future<void> loadComplaints() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await service.getAllComplaints();
      if (!mounted) return;

      setState(() {
        complaints = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredComplaints {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return complaints;

    return complaints.where((complaint) {
      final title = (complaint['title'] ?? '').toString().toLowerCase();
      final description = (complaint['description'] ?? '')
          .toString()
          .toLowerCase();
      final status = (complaint['status'] ?? '').toString().toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          status.contains(query);
    }).toList();
  }

  int _todayAsInt() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  Future<void> openComplaintForm({Map<String, dynamic>? complaint}) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(
      text: complaint?['title']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: complaint?['description']?.toString() ?? '',
    );
    final residentController = TextEditingController(
      text: (complaint?['resident']?['residentid'] ?? widget.residentId ?? '')
          .toString(),
    );

    String selectedStatus = complaint?['status']?.toString() ?? 'Pending';

    final statuses = ['Pending', 'In Progress', 'Resolved', 'Rejected'];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: surface,
              title: Text(
                complaint == null ? 'Raise Complaint' : 'Edit Complaint',
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
                        _formField(
                          controller: titleController,
                          label: 'Complaint title',
                          icon: Icons.title,
                        ),
                        const SizedBox(height: 14),
                        _formField(
                          controller: descriptionController,
                          label: 'Description',
                          icon: Icons.description_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        _formField(
                          controller: residentController,
                          label: 'Resident ID',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: statuses.contains(selectedStatus)
                              ? selectedStatus
                              : statuses.first,
                          dropdownColor: surface,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            'Status',
                            Icons.flag_outlined,
                          ),
                          items: statuses.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedStatus = value;
                              });
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

                          final residentId = int.tryParse(
                            residentController.text.trim(),
                          );

                          if (residentId == null || residentId <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid Resident ID'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => saving = true);

                          try {
                            if (complaint == null) {
                              await service.addComplaint(
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                status: selectedStatus,
                                complaintDate: _todayAsInt(),
                                residentId: residentId,
                              );
                            } else {
                              await service.updateComplaint(
                                complaintId: (complaint['complaintid'] as num)
                                    .toInt(),
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                status: selectedStatus,
                                complaintDate:
                                    (complaint['complaintDate'] as num?)
                                        ?.toInt() ??
                                    _todayAsInt(),
                                residentId: residentId,
                              );
                            }

                            if (!mounted) return;
                            Navigator.pop(dialogContext);
                            await loadComplaints();

                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  complaint == null
                                      ? 'Complaint added successfully'
                                      : 'Complaint updated successfully',
                                ),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => saving = false);
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(complaint == null ? 'Submit' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    residentController.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
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

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.greenAccent;
      case 'rejected':
        return Colors.redAccent;
      case 'in progress':
        return Colors.orangeAccent;
      default:
        return blue;
    }
  }

  Future<void> confirmDelete(Map<String, dynamic> complaint) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        title: const Text(
          'Delete complaint?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This complaint will be permanently deleted.',
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

    if (confirmed != true) return;

    try {
      await service.deleteComplaint((complaint['complaintid'] as num).toInt());
      await loadComplaints();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final title = complaint['title']?.toString() ?? 'Untitled';
    final description =
        complaint['description']?.toString() ?? 'No description';
    final status = complaint['status']?.toString() ?? 'Pending';
    final id = complaint['complaintid']?.toString() ?? '-';
    final date = complaint['complaintDate']?.toString() ?? '-';

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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.report_problem_outlined, color: blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Complaint #$id', style: TextStyle(color: muted)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: muted),
                color: surface,
                onSelected: (value) {
                  if (value == 'edit') {
                    openComplaintForm(complaint: complaint);
                  } else if (value == 'delete') {
                    confirmDelete(complaint);
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
          const SizedBox(height: 14),
          Text(description, style: TextStyle(color: muted, height: 1.5)),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 15, color: muted),
              const SizedBox(width: 6),
              Text(date, style: TextStyle(color: muted, fontSize: 12)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
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
          'Complaints',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loadComplaints,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openComplaintForm(),
        backgroundColor: blue,
        foregroundColor: background,
        icon: const Icon(Icons.add),
        label: const Text('Raise Complaint'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadComplaints,
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
                            'Your Voice Matters',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Report an issue and track its status.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.support_agent,
                      size: 48,
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
                      'All Complaints',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${complaints.length} total',
                    style: TextStyle(color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search complaints...',
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
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(35),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (errorMessage != null)
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
                        'Could not load complaints',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: TextStyle(color: muted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: loadComplaints,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              else if (filteredComplaints.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 54, color: muted),
                      const SizedBox(height: 12),
                      Text(
                        searchQuery.isEmpty
                            ? 'No complaints found'
                            : 'No matching complaints',
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                )
              else
                ...filteredComplaints.map(_buildComplaintCard),
            ],
          ),
        ),
      ),
    );
  }
}
