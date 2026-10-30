import 'dart:convert';
import 'package:http/http.dart' as http;

class ComplaintService {
  static const String baseUrl = 'http://localhost:8080';

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Unexpected server response');
  }

  void _checkSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getAllComplaints() async {
    final response = await http.get(Uri.parse('$baseUrl/complaint/getAll'));

    _checkSuccess(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<Map<String, dynamic>> getComplaintById(int complaintId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/complaint/getById/$complaintId'),
    );

    _checkSuccess(response);
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> addComplaint({
    required String title,
    required String description,
    required String status,
    required int complaintDate,
    required int residentId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/complaint/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'status': status,
        'complaintDate': complaintDate,
        'residentId': residentId,
      }),
    );

    _checkSuccess(response);
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> updateComplaint({
    required int complaintId,
    required String title,
    required String description,
    required String status,
    required int complaintDate,
    required int residentId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/complaint/update/$complaintId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'status': status,
        'complaintDate': complaintDate,
        'residentId': residentId,
      }),
    );

    _checkSuccess(response);
    return _decodeObject(response);
  }

  Future<void> deleteComplaint(int complaintId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/complaint/delete/$complaintId'),
    );

    _checkSuccess(response);
  }

  Future<Map<String, dynamic>> getComplaintWithResident(int complaintId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/complaint/getComplaintWithResident/$complaintId'),
    );

    _checkSuccess(response);
    return _decodeObject(response);
  }
}
