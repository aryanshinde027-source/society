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

  // PROFESSIONAL LIGHT THEME
  static const Color background = Color(0xFFF3F5FA);
  static const Color surface = Colors.white;
  static const Color navy = Color(0xFF122F4B);
  static const Color blue = Color(0xFF24579B);
  static const Color gold = Color(0xFFD5AA57);
  static const Color muted = Color(0xFF718096);

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

  // ADD / EDIT COMPLAINT
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                complaint == null ? 'Raise Complaint' : 'Edit Complaint',
                style: const TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w800,
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
                        _formField(
                          controller: titleController,
                          label: 'Complaint title',
                          icon: Icons.title_rounded,
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
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: navy),
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
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => saving = false);

                            if (!mounted) return;

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Failed: $e'),
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

  // INPUT DECORATION
  InputDecoration _inputDecoration(String label, IconData icon) {
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
        borderSide: const BorderSide(color: Color(0xFFE4E9F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: blue, width: 1.5),
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
      style: const TextStyle(color: navy),
      decoration: _inputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  // STATUS COLORS
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      case 'in progress':
        return Colors.orange;
      default:
        return blue;
    }
  }

  // DELETE COMPLAINT
  Future<void> confirmDelete(Map<String, dynamic> complaint) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete complaint?',
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This complaint will be permanently deleted.',
          style: TextStyle(color: muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: muted)),
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

    if (confirmed != true) return;

    try {
      await service.deleteComplaint((complaint['complaintid'] as num).toInt());

      await loadComplaints();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // COMPLAINT CARD
  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final title = complaint['title']?.toString() ?? 'Untitled';

    final description =
        complaint['description']?.toString() ?? 'No description';

    final status = complaint['status']?.toString() ?? 'Pending';

    final id = complaint['complaintid']?.toString() ?? '-';

    final date = complaint['complaintDate']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE8EDF4)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.045),
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
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.report_problem_rounded,
                  color: Color(0xFFD94B4B),
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complaint #$id',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: muted),
                color: Colors.white,
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
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: blue),
                        SizedBox(width: 9),
                        Text('Edit', style: TextStyle(color: navy)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.redAccent),
                        SizedBox(width: 9),
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

          const SizedBox(height: 15),

          Text(
            description,
            style: const TextStyle(color: muted, height: 1.5, fontSize: 13),
          ),

          const SizedBox(height: 15),

          const Divider(color: Color(0xFFEDF0F5), height: 1),

          const SizedBox(height: 13),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 15, color: gold),
              const SizedBox(width: 7),
              Text(date, style: const TextStyle(color: muted, fontSize: 12)),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WELCOME BANNER
  Widget _welcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102F52), Color(0xFF285AA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.support_agent_rounded,
              size: 115,
              color: Colors.white.withOpacity(0.08),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 62,
                width: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: gold,
                  size: 32,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Your Voice Matters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Report an issue and keep track of its progress.',
                style: TextStyle(
                  color: Color(0xFFDCE8F7),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 23),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.20)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, color: gold, size: 19),
                    SizedBox(width: 10),
                    Text(
                      'We are here to help',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MAIN SCREEN
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        surfaceTintColor: Colors.white,
        titleSpacing: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 27),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: gold, size: 31),
            SizedBox(width: 11),
            Text(
              'Complaints',
              style: TextStyle(
                color: navy,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loadComplaints,
            icon: const Icon(Icons.refresh_rounded, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // RAISE COMPLAINT BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openComplaintForm(),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 7,
        icon: const Icon(Icons.add, color: gold, size: 27),
        label: const Text(
          'Raise Complaint',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadComplaints,
          color: navy,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 17, 16, 110),
            children: [
              // BANNER
              _welcomeBanner(),

              const SizedBox(height: 27),

              // ALL COMPLAINTS HEADER
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'All Complaints',
                      style: TextStyle(
                        color: navy,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6E8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${complaints.length} total',
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              // SEARCH BAR
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5EAF1)),
                  boxShadow: [
                    BoxShadow(color: navy.withOpacity(0.025), blurRadius: 10),
                  ],
                ),
                child: TextField(
                  style: const TextStyle(color: navy, fontSize: 15),
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search by title, description or status...',
                    hintStyle: TextStyle(
                      color: Color(0xFF929BA8),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: gold,
                      size: 29,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // LOADING
              if (isLoading)
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
              else if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                        'Could not load complaints',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: muted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 13),
                      ElevatedButton.icon(
                        onPressed: loadComplaints,
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
              else if (filteredComplaints.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.inbox_outlined, size: 55, color: gold),
                      const SizedBox(height: 12),
                      Text(
                        searchQuery.isEmpty
                            ? 'No complaints found'
                            : 'No matching complaints',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              // COMPLAINT LIST
              else
                ...filteredComplaints.map(_buildComplaintCard),
            ],
          ),
        ),
      ),
    );
  }
}
