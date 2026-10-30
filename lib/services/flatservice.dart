import 'dart:convert';
import 'package:http/http.dart' as http;

class FlatService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Map<String, dynamic>>> getAllFlats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/flat/getAll'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception(
      'Load flats failed (${response.statusCode}): ${response.body}',
    );
  }

  Future<Map<String, dynamic>> getFlatById(int flatId) async {
    final response = await http.get(Uri.parse('$baseUrl/flat/getById/$flatId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Load flat failed (${response.statusCode}): ${response.body}',
    );
  }

  Future<void> addFlat({
    required int flatnumber,
    required String wing,
    required String floortype,
    required String status,
    required int societyId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/flat/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'flatnumber': flatnumber,
        'wing': wing,
        'floortype': floortype,
        'status': status,
        'societyId': societyId,
      }),
    );

    if (![200, 201, 204].contains(response.statusCode)) {
      throw Exception(
        'Add flat failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> updateFlat({
    required int flatId,
    required int flatnumber,
    required String wing,
    required String floortype,
    required String status,
    required int societyId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/flat/update/$flatId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'flatnumber': flatnumber,
        'wing': wing,
        'floortype': floortype,
        'status': status,
        'societyId': societyId,
      }),
    );

    if (![200, 201, 204].contains(response.statusCode)) {
      throw Exception(
        'Update flat failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> deleteFlat(int flatId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/flat/delete/$flatId'),
    );

    if (![200, 204].contains(response.statusCode)) {
      throw Exception(
        'Delete flat failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}
