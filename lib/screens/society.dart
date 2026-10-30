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

  static const Color bg = Color(0xFF0B1120);
  static const Color surface = Color(0xFF151F32);
  static const Color blue = Color(0xFF60A5FA);
  static const Color muted = Color(0xFF94A3B8);

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _loadSocieties() async {
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

  void _clearForm() {
    _name.clear();
    _address.clear();
    _city.clear();
    _pincode.clear();
    _registration.clear();
    _editingId = null;
  }

  void _fillForm(Map<String, dynamic> society) {
    _editingId = int.tryParse('${society['societyId']}');
    _name.text = '${society['societyname'] ?? ''}';
    _address.text = '${society['address'] ?? ''}';
    _city.text = '${society['city'] ?? ''}';
    _pincode.text = '${society['pincode'] ?? ''}';
    _registration.text = '${society['registrationNumber'] ?? ''}';
  }

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

  Future<void> _deleteSociety(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surface,
        title: const Text(
          'Delete Society?',
          style: TextStyle(color: Colors.white),
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
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
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

  void _showForm({Map<String, dynamic>? society}) {
    _clearForm();
    if (society != null) _fillForm(society);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editingId == null ? 'Add Society' : 'Edit Society',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _field(_name, 'Society Name'),
                _field(_address, 'Address'),
                _field(_city, 'City'),
                _field(_pincode, 'Pincode', numeric: true),
                _field(_registration, 'Registration Number', numeric: true),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _saveSociety,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      _editingId == null ? 'Add Society' : 'Update Society',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: bg,
                      padding: const EdgeInsets.all(15),
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

  Future<void> _showDetails(int id) async {
    try {
      final society = await _service.getSocietyById(id);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: surface,
          title: Text(
            '${society['societyname'] ?? 'Society Details'}',
            style: const TextStyle(color: Colors.white),
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
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      _message('Could not load details: $e');
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted),
      filled: true,
      fillColor: bg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool numeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: _decoration(label),
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

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(label, style: const TextStyle(color: muted)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        title: const Text('Society Management'),
        actions: [
          IconButton(
            onPressed: _loadSocieties,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: blue,
        foregroundColor: bg,
        icon: const Icon(Icons.add),
        label: const Text('Add Society'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(
                'Search society or city',
              ).copyWith(prefixIcon: const Icon(Icons.search, color: muted)),
            ),
          ),
          Expanded(
            child: _loading && _societies.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No societies found',
                      style: TextStyle(color: muted),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadSocieties,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final society = filtered[index];
                        final id = int.tryParse('${society['societyId']}') ?? 0;

                        return Card(
                          color: surface,
                          margin: const EdgeInsets.only(bottom: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
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
                                        Icons.apartment_rounded,
                                        color: blue,
                                        size: 27,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${society['societyname'] ?? 'Unnamed Society'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: muted,
                                      ),
                                      color: surface,
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showForm(society: society);
                                        } else if (value == 'details') {
                                          _showDetails(id);
                                        } else if (value == 'delete') {
                                          _deleteSociety(id);
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'details',
                                          child: Text(
                                            'View Details',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text(
                                            'Edit',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _detail('Society ID', '$id'),
                                _detail(
                                  'Address',
                                  '${society['address'] ?? '-'}',
                                ),
                                _detail('City', '${society['city'] ?? '-'}'),
                                _detail(
                                  'Pincode',
                                  '${society['pincode'] ?? '-'}',
                                ),
                                _detail(
                                  'Registration No.',
                                  '${society['registrationNumber'] ?? '-'}',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
