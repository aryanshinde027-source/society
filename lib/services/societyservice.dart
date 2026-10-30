import 'dart:convert';
import 'package:http/http.dart' as http;

class SocietyService {
  static const String baseUrl = 'http://localhost:8080';

  void _check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }

  Map<String, dynamic> _parseObject(http.Response response) {
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected society response');
  }

  List<Map<String, dynamic>> _parseList(http.Response response) {
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // GET /society/getAll
  Future<List<Map<String, dynamic>>> getAllSocieties() async {
    final response = await http.get(Uri.parse('$baseUrl/society/getAll'));
    _check(response);
    return _parseList(response);
  }

  // GET /society/getById/{societyId}
  Future<Map<String, dynamic>> getSocietyById(int societyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/society/getById/$societyId'),
    );
    _check(response);
    return _parseObject(response);
  }

  // POST /society/add
  Future<void> addSociety({
    required String societyname,
    required String address,
    required String city,
    required int pincode,
    required int registrationNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/society/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'societyname': societyname,
        'address': address,
        'city': city,
        'pincode': pincode,
        'registrationNumber': registrationNumber,
      }),
    );
    _check(response);
  }

  // PUT /society/update/{societyId}
  Future<void> updateSociety({
    required int societyId,
    required String societyname,
    required String address,
    required String city,
    required int pincode,
    required int registrationNumber,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/society/update/$societyId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'societyname': societyname,
        'address': address,
        'city': city,
        'pincode': pincode,
        'registrationNumber': registrationNumber,
      }),
    );
    _check(response);
  }

  // DELETE /society/delete/{societyId}
  Future<void> deleteSociety(int societyId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/society/delete/$societyId'),
    );
    _check(response);
  }

  // GET /society/getSocietyWithFlats/{societyId}
  Future<Map<String, dynamic>> getSocietyWithFlats(int societyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/society/getSocietyWithFlats/$societyId'),
    );
    _check(response);
    return _parseObject(response);
  }

  // GET /society/getSocietyWithNotices/{societyId}
  Future<Map<String, dynamic>> getSocietyWithNotices(int societyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/society/getSocietyWithNotices/$societyId'),
    );
    _check(response);
    return _parseObject(response);
  }
}
