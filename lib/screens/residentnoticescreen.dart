import 'package:flutter/material.dart';
import 'package:society_management/services/noticeservice.dart';

class ResidentNoticeScreen extends StatefulWidget {
  const ResidentNoticeScreen({super.key});

  @override
  State<ResidentNoticeScreen> createState() => _ResidentNoticeScreenState();
}

class _ResidentNoticeScreenState extends State<ResidentNoticeScreen> {
  final NoticeService service = NoticeService();

  static const Color background = Color(0xFFF4F5FA);
  static const Color navy = Color(0xFF142B50);
  static const Color gold = Color(0xFFD9B76E);
  static const Color muted = Color(0xFF8993A4);

  List<Map<String, dynamic>> notices = [];

  bool loading = true;
  String? error;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadNotices();
  }

  @override
  void dispose() {
    super.dispose();
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

  // HEADER BANNER
  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF142B50), Color(0xFF203F70)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 15,
            child: Icon(
              Icons.campaign_rounded,
              size: 110,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: gold.withOpacity(0.5)),
                ),
                child: const Text(
                  'SOCIETY UPDATES',
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 27),

              const Text(
                'Stay Informed.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Important announcements from your society, '
                'all in one place.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.7,
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    color: gold,
                    size: 23,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${notices.length} total notices',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1E5EC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: navy, size: 29),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              style: const TextStyle(color: navy, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Search notices...',
                hintStyle: TextStyle(color: muted, fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NOTICE CARD
  Widget _noticeCard(Map<String, dynamic> notice) {
    final title = notice['title']?.toString() ?? 'Untitled Notice';

    final description =
        notice['description']?.toString() ?? 'No description available';

    final id = notice['noticeid']?.toString() ?? '-';

    final date = formatDate(notice['noticeDate']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E8EF)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 49,
                width: 49,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EEDC),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: navy,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
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

              const Icon(
                Icons.notifications_active_outlined,
                color: gold,
                size: 23,
              ),
            ],
          ),

          const SizedBox(height: 17),

          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 16),

          const Divider(color: Color(0xFFE9ECF1)),

          const SizedBox(height: 7),

          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: gold, size: 19),
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
              ),

              const Icon(Icons.verified_outlined, color: gold, size: 18),

              const SizedBox(width: 5),

              const Text(
                'Society Update',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: [
          Container(
            height: 85,
            width: 85,
            decoration: const BoxDecoration(
              color: Color(0xFFF1EBDc),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: navy,
              size: 43,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No Notices Found',
            style: TextStyle(
              color: navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Society announcements will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 14),
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 75,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: navy, size: 29),
        ),
        title: const Text(
          'Notice Board',
          style: TextStyle(
            color: navy,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : loadNotices,
            icon: const Icon(Icons.refresh_rounded, color: navy, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // NO ADD BUTTON / NO FLOATING ACTION BUTTON
      body: SafeArea(
        child: RefreshIndicator(
          color: navy,
          onRefresh: loadNotices,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 25, 18, 25),
            children: [
              _buildBanner(),

              const SizedBox(height: 30),

              _buildSearchBar(),

              const SizedBox(height: 28),

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
                    '${filteredNotices.length} found',
                    style: const TextStyle(color: muted, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: navy,
                      strokeWidth: 3,
                    ),
                  ),
                )
              else if (error != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: Colors.redAccent,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load notices',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: muted),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: loadNotices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              else if (filteredNotices.isEmpty)
                _emptyState()
              else
                ...filteredNotices.map(_noticeCard),
            ],
          ),
        ),
      ),
    );
  }
}
