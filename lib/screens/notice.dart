import 'package:flutter/material.dart';
import 'package:society_management/services/noticeservice.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  final NoticeService service = NoticeService();

  // PROFESSIONAL THEME
  static const Color background = Color(0xFFF3F5FA);
  static const Color surface = Colors.white;
  static const Color navy = Color(0xFF142F52);
  static const Color gold = Color(0xFFD9B66F);
  static const Color muted = Color(0xFF8290A2);
  static const Color blue = Color(0xFF285AA5);

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
    if (!mounted) return;

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

    if (raw.length != 8) {
      return raw.isEmpty ? '-' : raw;
    }

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

  // INPUT DECORATION
  InputDecoration inputDecoration(String label, IconData icon) {
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
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: blue, width: 1.5),
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
      style: const TextStyle(color: navy),
      decoration: inputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  // PUBLISH / EDIT NOTICE
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                isEditing ? 'Edit Notice' : 'Publish Notice',
                style: const TextStyle(
                  color: navy,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
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
                          icon: Icons.title_rounded,
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

                        const SizedBox(height: 14),

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

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: navy,
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
                            color: navy,
                          ),
                        )
                      : Text(
                          isEditing ? 'Save Changes' : 'Publish',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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

  // DELETE NOTICE
  Future<void> deleteNotice(Map<String, dynamic> notice) async {
    final noticeId = (notice['noticeid'] as num).toInt();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Notice?',
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
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
      await service.deleteNotice(noticeId);

      await loadNotices();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notice deleted successfully'),
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

  // NOTICE CARD
  Widget noticeCard(Map<String, dynamic> notice) {
    final title = notice['title']?.toString() ?? 'Untitled notice';

    final description =
        notice['description']?.toString() ?? 'No description available';

    final id = notice['noticeid']?.toString() ?? '-';

    final date = formatDate(notice['noticeDate']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE6EAF0)),
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
                height: 47,
                width: 47,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5DF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: gold,
                  size: 27,
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
                        fontWeight: FontWeight.w800,
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
                color: Colors.white,
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
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 16),

          const Divider(color: Color(0xFFEDF0F5), height: 1),

          const SizedBox(height: 13),

          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 17, color: gold),
              const SizedBox(width: 8),
              Text(date, style: const TextStyle(color: muted, fontSize: 12)),
              const Spacer(),
              const Icon(
                Icons.notifications_active_outlined,
                size: 17,
                color: gold,
              ),
              const SizedBox(width: 5),
              const Text(
                'Announcement',
                style: TextStyle(
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

  // SOCIETY UPDATES BANNER
  Widget societyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF122D50), Color(0xFF203F6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 5,
            child: Icon(
              Icons.campaign_rounded,
              size: 125,
              color: Colors.white.withOpacity(0.07),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LABEL
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: gold.withOpacity(0.55)),
                ),
                child: const Text(
                  'S O C I E T Y  U P D A T E S',
                  style: TextStyle(
                    color: gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(height: 39),

              const Text(
                'Stay Informed.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 13),

              const Text(
                'Important announcements from your society, all in one place.',
                style: TextStyle(
                  color: Color(0xFFD4DFEF),
                  fontSize: 15,
                  height: 1.65,
                ),
              ),

              const SizedBox(height: 34),

              Row(
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    color: gold,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${notices.length} total notices',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
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
    final visibleNotices = filteredNotices;

    return Scaffold(
      backgroundColor: background,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 27),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 8,
        title: const Text(
          'Notice Board',
          style: TextStyle(
            color: navy,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      // PUBLISH BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openNoticeForm(),
        backgroundColor: gold,
        foregroundColor: navy,
        elevation: 7,
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text(
          'Publish Notice',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      ),

      // BODY
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadNotices,
          color: navy,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
            children: [
              // BANNER
              societyBanner(),

              const SizedBox(height: 26),

              // SEARCH
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE3E8EF)),
                  boxShadow: [
                    BoxShadow(color: navy.withOpacity(0.025), blurRadius: 10),
                  ],
                ),
                child: TextField(
                  style: const TextStyle(color: navy, fontSize: 16),
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search notices...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8793A2),
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: navy,
                      size: 29,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() => searchQuery = '');
                            },
                            icon: const Icon(Icons.close, color: muted),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 23,
                      horizontal: 15,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // RECENT NOTICES
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Notices',
                      style: TextStyle(
                        color: navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${visibleNotices.length} found',
                    style: const TextStyle(color: muted, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 19),

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
                        'Unable to load notices',
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
                        onPressed: loadNotices,
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
              else if (visibleNotices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 55,
                        color: gold,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        searchQuery.isEmpty
                            ? 'No notices available'
                            : 'No matching notices',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              // NOTICE LIST
              else
                ...visibleNotices.map(noticeCard),
            ],
          ),
        ),
      ),
    );
  }
}
