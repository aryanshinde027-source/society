import 'package:flutter/material.dart';
import 'package:society_management/services/societyservice.dart';

class SocietyScreen extends StatefulWidget {
  const SocietyScreen({super.key});

  @override
  State<SocietyScreen> createState() => _SocietyScreenState();
}

class _SocietyScreenState extends State<SocietyScreen> {
  final SocietyService _service = SocietyService();

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _pincode = TextEditingController();
  final _registration = TextEditingController();
  final _search = TextEditingController();

  List<Map<String, dynamic>> _societies = [];
  bool _loading = false;
  int? _editingId;

  static const Color navy = Color(0xFF14294E);
  static const Color navyLight = Color(0xFF243F70);
  static const Color gold = Color(0xFFDDBB65);
  static const Color bg = Color(0xFFF4F6FB);
  static const Color muted = Color(0xFF8490A0);

  @override
  void initState() {
    super.initState();
    _loadSocieties();
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    _pincode.dispose();
    _registration.dispose();
    _search.dispose();
    super.dispose();
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: navy,
      ),
    );
  }

  // LOAD SOCIETIES
  Future<void> _loadSocieties() async {
    if (!mounted) return;

    setState(() => _loading = true);

    try {
      final result = await _service.getAllSocieties();

      if (!mounted) return;

      setState(() => _societies = result);
    } catch (e) {
      _message('Could not load societies: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // CLEAR FORM
  void _clearForm() {
    _name.clear();
    _address.clear();
    _city.clear();
    _pincode.clear();
    _registration.clear();
    _editingId = null;
  }

  // FILL FORM
  void _fillForm(Map<String, dynamic> society) {
    _editingId = int.tryParse('${society['societyId']}');
    _name.text = '${society['societyname'] ?? ''}';
    _address.text = '${society['address'] ?? ''}';
    _city.text = '${society['city'] ?? ''}';
    _pincode.text = '${society['pincode'] ?? ''}';
    _registration.text = '${society['registrationNumber'] ?? ''}';
  }

  // SAVE SOCIETY
  Future<void> _saveSociety() async {
    if (!_formKey.currentState!.validate()) return;

    final pin = int.tryParse(_pincode.text.trim());
    final registration = int.tryParse(_registration.text.trim());

    if (pin == null || registration == null) {
      _message('Enter valid numeric values');
      return;
    }

    setState(() => _loading = true);

    try {
      if (_editingId == null) {
        await _service.addSociety(
          societyname: _name.text.trim(),
          address: _address.text.trim(),
          city: _city.text.trim(),
          pincode: pin,
          registrationNumber: registration,
        );

        _message('Society added successfully');
      } else {
        await _service.updateSociety(
          societyId: _editingId!,
          societyname: _name.text.trim(),
          address: _address.text.trim(),
          city: _city.text.trim(),
          pincode: pin,
          registrationNumber: registration,
        );

        _message('Society updated successfully');
      }

      if (!mounted) return;

      Navigator.of(context).pop();
      _clearForm();

      await _loadSocieties();
    } catch (e) {
      _message('Save failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // DELETE SOCIETY
  Future<void> _deleteSociety(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Society?',
          style: TextStyle(color: navy, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Are you sure you want to delete this society?',
          style: TextStyle(color: muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      await _service.deleteSociety(id);
      _message('Society deleted successfully');
      await _loadSocieties();
    } catch (e) {
      _message('Delete failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // FORM DECORATION
  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted),
      prefixIcon: Icon(icon, color: gold),
      filled: true,
      fillColor: bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E7EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: navy, width: 1.5),
      ),
    );
  }

  // TEXT FIELD
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool numeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: navy, fontWeight: FontWeight.w600),
        decoration: _decoration(label, icon),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }

          if (numeric && int.tryParse(value.trim()) == null) {
            return 'Enter a valid number';
          }

          return null;
        },
      ),
    );
  }

  // ADD / EDIT FORM
  void _showForm({Map<String, dynamic>? society}) {
    _clearForm();

    if (society != null) {
      _fillForm(society);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(sheetContext).viewInsets.bottom + 22,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  _editingId == null ? 'Add New Society' : 'Edit Society',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Enter society information below.',
                  style: TextStyle(color: muted),
                ),

                const SizedBox(height: 23),

                _field(_name, 'Society Name', Icons.apartment_rounded),

                _field(_address, 'Address', Icons.location_on_outlined),

                _field(_city, 'City', Icons.location_city_rounded),

                _field(
                  _pincode,
                  'Pincode',
                  Icons.pin_drop_outlined,
                  numeric: true,
                ),

                _field(
                  _registration,
                  'Registration Number',
                  Icons.confirmation_number_outlined,
                  numeric: true,
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _saveSociety,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      _editingId == null ? 'Add Society' : 'Update Society',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SOCIETY DETAILS
  Future<void> _showDetails(int id) async {
    try {
      final society = await _service.getSocietyById(id);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            '${society['societyname'] ?? 'Society Details'}',
            style: const TextStyle(color: navy, fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detail('Society ID', '${society['societyId'] ?? id}'),
                _detail('Address', '${society['address'] ?? '-'}'),
                _detail('City', '${society['city'] ?? '-'}'),
                _detail('Pincode', '${society['pincode'] ?? '-'}'),
                _detail(
                  'Registration',
                  '${society['registrationNumber'] ?? '-'}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close', style: TextStyle(color: navy)),
            ),
          ],
        ),
      );
    } catch (e) {
      _message('Could not load details: $e');
    }
  }

  // DETAIL ROW
  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HEADER BANNER
  Widget _banner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 25, 24, 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [navy, navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(29),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 18,
            child: Icon(
              Icons.apartment_rounded,
              size: 105,
              color: Colors.white.withOpacity(0.07),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'S O C I E T Y   D I R E C T O R Y',
                style: TextStyle(
                  color: gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.7,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Manage Your Community.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Keep society information organized and accessible.',
                style: TextStyle(
                  color: Color(0xFFD4DDEC),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 31),

              Row(
                children: [
                  const Icon(Icons.apartment_rounded, color: gold, size: 25),
                  const SizedBox(width: 12),
                  Text(
                    '${_societies.length} societies registered',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
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
  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E8EF)),
      ),
      child: TextField(
        controller: _search,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: navy, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search society, city or address...',
          hintStyle: const TextStyle(color: Colors.black54, fontSize: 15),
          prefixIcon: const Icon(Icons.search_rounded, color: navy, size: 29),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _search.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close, color: muted),
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 22),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // SOCIETY CARD
  Widget _societyCard(Map<String, dynamic> society) {
    final id = int.tryParse('${society['societyId']}') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E9F0)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.035),
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
                height: 49,
                width: 49,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3DD),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: navy,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  '${society['societyname'] ?? 'Unnamed Society'}',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: navy),
                onSelected: (value) {
                  if (value == 'details') {
                    _showDetails(id);
                  } else if (value == 'edit') {
                    _showForm(society: society);
                  } else if (value == 'delete') {
                    _deleteSociety(id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, color: navy),
                        SizedBox(width: 9),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: navy),
                        SizedBox(width: 9),
                        Text('Edit Society'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 9),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(color: Color(0xFFEDF0F4)),

          const SizedBox(height: 12),

          _detail('Society ID', '$id'),

          _detail('Address', '${society['address'] ?? '-'}'),

          _detail('City', '${society['city'] ?? '-'}'),

          _detail('Pincode', '${society['pincode'] ?? '-'}'),

          _detail(
            'Registration No.',
            '${society['registrationNumber'] ?? '-'}',
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.green, size: 17),
              const SizedBox(width: 6),
              const Text(
                'Registered Society',
                style: TextStyle(
                  color: Colors.green,
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

  // MAIN SCREEN
  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();

    final filtered = _societies.where((society) {
      return '${society['societyname'] ?? ''}'.toLowerCase().contains(query) ||
          '${society['city'] ?? ''}'.toLowerCase().contains(query) ||
          '${society['address'] ?? ''}'.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: bg,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        toolbarHeight: 65,
        title: const Text(
          'Society Management',
          style: TextStyle(
            color: navy,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadSocieties,
            icon: const Icon(Icons.refresh_rounded, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ADD SOCIETY BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: gold,
        foregroundColor: navy,
        elevation: 7,
        icon: const Icon(Icons.store_mall_directory_rounded, size: 25),
        label: const Text(
          'Add Society',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      ),

      // BODY
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadSocieties,
          color: navy,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 110),
            children: [
              // BANNER
              _banner(),

              const SizedBox(height: 22),

              // SEARCH
              _searchBar(),

              const SizedBox(height: 28),

              // REGISTERED SOCIETIES HEADING
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Registered Societies',
                      style: TextStyle(
                        color: navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${filtered.length} found',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // LOADING
              if (_loading && _societies.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: navy,
                      strokeWidth: 3,
                    ),
                  ),
                )
              // EMPTY
              else if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: Column(
                    children: [
                      Container(
                        height: 85,
                        width: 85,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: gold,
                          size: 43,
                        ),
                      ),

                      const SizedBox(height: 17),

                      Text(
                        query.isEmpty
                            ? 'No societies found'
                            : 'No matching societies found',
                        style: const TextStyle(
                          color: navy,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Add a society to get started.',
                        style: TextStyle(color: muted, fontSize: 13),
                      ),
                    ],
                  ),
                )
              // SOCIETY LIST
              else
                ...filtered.map(_societyCard),
            ],
          ),
        ),
      ),
    );
  }
}
