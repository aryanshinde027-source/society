import 'dart:convert';
import 'package:http/http.dart' as http;

class VisitorService {
  static const String baseUrl = 'http://localhost:8080';

  void _check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }

  Map<String, dynamic> _object(http.Response response) {
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected server response');
  }

  Future<List<Map<String, dynamic>>> getAllVisitors() async {
    final response = await http.get(Uri.parse('$baseUrl/visitor/all'));
    _check(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> getVisitorById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/visitor/$id'));
    _check(response);
    return _object(response);
  }

  Future<List<Map<String, dynamic>>> getVisitorsByResident(
    int residentId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/visitor/resident/$residentId'),
    );
    _check(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getVisitorsByFlat(int flatId) async {
    final response = await http.get(Uri.parse('$baseUrl/visitor/flat/$flatId'));
    _check(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> addVisitor({
    required String name,
    required String mobile,
    required String email,
    required String purpose,
    required String entryDate,
    required String exitDate,
    required int flatId,
    required int residentId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visitor/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'mobile': mobile,
        'email': email,
        'purpose': purpose,
        'entryDate': entryDate,
        'exitDate': exitDate,
        'flatId': flatId,
        'residentId': residentId,
      }),
    );

    _check(response);
    return _object(response);
  }

  Future<Map<String, dynamic>> updateVisitor({
    required int visitorId,
    required String name,
    required String mobile,
    required String email,
    required String purpose,
    required String entryDate,
    required String exitDate,
    required int flatId,
    required int residentId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/visitor/update/$visitorId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'visid': visitorId,
        'name': name,
        'mobile': mobile,
        'email': email,
        'purpose': purpose,
        'entryDate': entryDate,
        'exitDate': exitDate,
        'flatId': flatId,
        'residentId': residentId,
      }),
    );

    _check(response);
    return _object(response);
  }

  Future<void> deleteVisitor(int visitorId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/visitor/delete/$visitorId'),
    );
    _check(response);
  }
}
