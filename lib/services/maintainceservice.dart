import 'dart:convert';
import 'package:http/http.dart' as http;

class MaintainceService {
  // Android emulator URL.
  // Physical phone asel tar computer cha LAN IP vapra.
  static const String baseUrl = 'http://localhost:8080';

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception('Unexpected server response');
  }

  Future<List<Map<String, dynamic>>> getAllMaintaince() async {
    final response = await http.get(Uri.parse('$baseUrl/maintaince/getAll'));

    _checkResponse(response);

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<Map<String, dynamic>> getMaintainceById(int maintainceId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/maintaince/getById/$maintainceId'),
    );

    _checkResponse(response);
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> addMaintaince({
    required int amount,
    required String amountdue,
    required int paymentDate,
    required String paymentStatus,
    required int flatId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/maintaince/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'amountdue': amountdue,
        'paymentDate': paymentDate,
        'paymentStatus': paymentStatus,
        'flatId': flatId,
      }),
    );

    _checkResponse(response);
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> updateMaintaince({
    required int maintainceId,
    required int amount,
    required String amountdue,
    required int paymentDate,
    required String paymentStatus,
    required int flatId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/maintaince/update/$maintainceId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'amountdue': amountdue,
        'paymentDate': paymentDate,
        'paymentStatus': paymentStatus,
        'flatId': flatId,
      }),
    );

    _checkResponse(response);
    return _decodeObject(response);
  }

  Future<void> deleteMaintaince(int maintainceId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/maintaince/delete/$maintainceId'),
    );

    _checkResponse(response);
  }

  Future<Map<String, dynamic>> getMaintainceWithFlat(int maintainceId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/maintaince/getMaintainceWithFlat/$maintainceId'),
    );

    _checkResponse(response);
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> addFlatToMaintaince({
    required int maintainceId,
    required int flatId,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/maintaince/addFlatToMaintaince/'
        '$maintainceId/$flatId',
      ),
    );

    _checkResponse(response);
    return _decodeObject(response);
  }
}
