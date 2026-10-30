import 'dart:convert';
import 'package:http/http.dart' as http;

class ResidentService {
  // Android Emulator. Change port/context path if needed.
  static const String baseUrl = 'http://localhost:8080';

  Map<String, dynamic> _decodeObject(String body) {
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getAllResidents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/resident/getAll'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception(
      'Load residents failed (${response.statusCode}): ${response.body}',
    );
  }

  Future<Map<String, dynamic>> getResidentById(int residentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/resident/getbyid/$residentId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return _decodeObject(response.body);
    }

    throw Exception(
      'Load resident failed (${response.statusCode}): ${response.body}',
    );
  }

  Future<void> addResident({
    required String residentName,
    required String mobilenumber,
    required String email,
    required String gender,
    required int age,
    required String role,
    required int flatId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resident/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'residentName': residentName,
        'mobilenumber': mobilenumber,
        'email': email,
        'gender': gender,
        'age': age,
        'role': role,
        'flatId': flatId,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception(
        'Add resident failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> updateResident({
    required int residentId,
    required String residentName,
    required String mobilenumber,
    required String email,
    required String gender,
    required int age,
    required String role,
    required int flatId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/resident/update/$residentId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'residentName': residentName,
        'mobilenumber': mobilenumber,
        'email': email,
        'gender': gender,
        'age': age,
        'role': role,
        'flatId': flatId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Update resident failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> deleteResident(int residentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/resident/delete/$residentId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Delete resident failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}
