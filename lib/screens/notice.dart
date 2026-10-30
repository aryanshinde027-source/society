import 'package:flutter/material.dart';
import 'package:society_management/services/noticeservice.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  final NoticeService service = NoticeService();

  static const Color background = Color(0xFF0B1120);
  static const Color surface = Color(0xFF151F32);
  static const Color blue = Color(0xFF60A5FA);
  static const Color muted = Color(0xFF94A3B8);

  List<Map<String, dynamic>> notices = [];
  bool loading = true;
  String? error;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadNotices();
  }

  Future<void> loadNotices() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await service.getAllNotices();

      if (!mounted) return;

      setState(() {
        notices = result;
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

  int todayAsInt() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  String formatDate(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.length != 8) return raw.isEmpty ? '-' : raw;

    return '${raw.substring(6, 8)}/'
        '${raw.substring(4, 6)}/'
        '${raw.substring(0, 4)}';
  }

  List<Map<String, dynamic>> get filteredNotices {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return notices;

    return notices.where((notice) {
      final title = (notice['title'] ?? '').toString().toLowerCase();
      final description = (notice['description'] ?? '')
          .toString()
          .toLowerCase();

      return title.contains(query) || description.contains(query);
    }).toList();
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted),
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
        borderSide: const BorderSide(color: blue),
      ),
    );
  }

  Widget textField({
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
      decoration: inputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Future<void> openNoticeForm({Map<String, dynamic>? notice}) async {
    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController(
      text: notice?['title']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: notice?['description']?.toString() ?? '',
    );
    final societyController = TextEditingController(
      text:
          (notice?['society']?['societyid'] ??
                  notice?['society']?['societyId'] ??
                  '')
              .toString(),
    );

    final isEditing = notice != null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: surface,
              title: Text(
                isEditing ? 'Edit Notice' : 'Publish Notice',
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
                        textField(
                          controller: titleController,
                          label: 'Notice title',
                          icon: Icons.title,
                        ),
                        const SizedBox(height: 14),
                        textField(
                          controller: descriptionController,
                          label: 'Notice description',
                          icon: Icons.description_outlined,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 14),
                        textField(
                          controller: societyController,
                          label: 'Society ID',
                          icon: Icons.apartment_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Notice date: ${todayAsInt()}',
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
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: background,
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          final societyId = int.tryParse(
                            societyController.text.trim(),
                          );

                          if (societyId == null || societyId <= 0) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid Society ID'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => saving = true);

                          try {
                            if (isEditing) {
                              await service.updateNotice(
                                noticeId: (notice['noticeid'] as num).toInt(),
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                noticeDate:
                                    (notice['noticeDate'] as num?)?.toInt() ??
                                    todayAsInt(),
                                societyId: societyId,
                              );
                            } else {
                              await service.addNotice(
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                noticeDate: todayAsInt(),
                                societyId: societyId,
                              );
                            }

                            if (!mounted) return;
                            Navigator.pop(dialogContext);
                            await loadNotices();

                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? 'Notice updated successfully'
                                      : 'Notice published successfully',
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
                      : Text(isEditing ? 'Save Changes' : 'Publish'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    societyController.dispose();
  }

  Future<void> deleteNotice(Map<String, dynamic> notice) async {
    final noticeId = (notice['noticeid'] as num).toInt();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        title: const Text(
          'Delete Notice?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This notice will be permanently deleted.',
          style: TextStyle(color: muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: muted)),
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
      await service.deleteNotice(noticeId);
      await loadNotices();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Widget noticeCard(Map<String, dynamic> notice) {
    final title = notice['title']?.toString() ?? 'Untitled notice';
    final description =
        notice['description']?.toString() ?? 'No description available';
    final id = notice['noticeid']?.toString() ?? '-';
    final date = formatDate(notice['noticeDate']);

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
                  color: blue.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: blue,
                  size: 26,
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Notice #$id',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: muted),
                color: surface,
                onSelected: (value) {
                  if (value == 'edit') {
                    openNoticeForm(notice: notice);
                  } else if (value == 'delete') {
                    deleteNotice(notice);
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
          const SizedBox(height: 15),
          Text(
            description,
            style: const TextStyle(color: muted, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Divider(color: muted.withValues(alpha: 0.16)),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 17, color: blue),
              const SizedBox(width: 8),
              Text(date, style: const TextStyle(color: muted, fontSize: 12)),
              const Spacer(),
              const Icon(
                Icons.notifications_active_outlined,
                size: 17,
                color: blue,
              ),
              const SizedBox(width: 5),
              const Text(
                'Announcement',
                style: TextStyle(
                  color: blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
        elevation: 0,
        title: const Text(
          'Society Notices',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loadNotices,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openNoticeForm(),
        backgroundColor: blue,
        foregroundColor: background,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Publish Notice'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadNotices,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(21),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF4338CA)],
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
                            'Stay Informed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Important updates from your society, '
                            'all in one place.',
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.notifications_active_rounded,
                      size: 45,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Latest Notices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${notices.length} total',
                    style: const TextStyle(color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search notices...',
                  hintStyle: const TextStyle(color: muted),
                  prefixIcon: const Icon(Icons.search, color: muted),
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
                        Icons.cloud_off_rounded,
                        color: Colors.orangeAccent,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load notices',
                        style: TextStyle(
                          color: Colors.white,
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
                      FilledButton(
                        onPressed: loadNotices,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              else if (filteredNotices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 54,
                        color: muted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        searchQuery.isEmpty
                            ? 'No notices available'
                            : 'No matching notices',
                        style: const TextStyle(color: muted),
                      ),
                    ],
                  ),
                )
              else
                ...filteredNotices.map(noticeCard),
            ],
          ),
        ),
      ),
    );
  }
}
