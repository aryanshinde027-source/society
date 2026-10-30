import 'package:flutter/material.dart';
import 'package:society_management/services/noticeservice.dart';

class ResidentNoticeScreen extends StatefulWidget {
  const ResidentNoticeScreen({super.key});

  @override
  State<ResidentNoticeScreen> createState() => _ResidentNoticeScreenState();
}

class _ResidentNoticeScreenState extends State<ResidentNoticeScreen> {
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

  String formatDate(dynamic value) {
    final raw = value?.toString() ?? '';

    if (raw.length == 8) {
      return '${raw.substring(6, 8)}/'
          '${raw.substring(4, 6)}/'
          '${raw.substring(0, 4)}';
    }

    return raw.isEmpty ? '-' : raw;
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

  Widget noticeCard(Map<String, dynamic> notice) {
    final title = notice['title']?.toString() ?? 'Untitled Notice';

    final description =
        notice['description']?.toString() ?? 'No description available';

    final id = notice['noticeid']?.toString() ?? '-';
    final date = formatDate(notice['noticeDate']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
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
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
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
            ],
          ),

          const SizedBox(height: 16),

          Text(
            description,
            style: const TextStyle(color: muted, fontSize: 14, height: 1.6),
          ),

          const SizedBox(height: 16),
          Divider(color: muted.withValues(alpha: 0.18)),

          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: blue, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ),
              const Icon(
                Icons.notifications_active_outlined,
                color: blue,
                size: 18,
              ),
              const SizedBox(width: 5),
              const Text(
                'Society Update',
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
            tooltip: 'Refresh notices',
            onPressed: loading ? null : loadNotices,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadNotices,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
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
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Read the latest announcements '
                            'from your society.',
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 44,
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
                    '${filteredNotices.length} notices',
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
                  prefixIcon: const Icon(Icons.search, color: blue),
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (loading)
                const Padding(
                  padding: EdgeInsets.all(30),
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
                        Icons.cloud_off_rounded,
                        color: Colors.orangeAccent,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load notices',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: muted),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: loadNotices,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              else if (filteredNotices.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 55,
                        color: muted,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No notices available',
                        style: TextStyle(color: muted),
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
