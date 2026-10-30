import 'dart:convert';
import 'package:http/http.dart' as http;

class NoticeService {
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

  Future<List<Map<String, dynamic>>> getAllNotices() async {
    final response = await http.get(Uri.parse('$baseUrl/notice/getAll'));

    _checkResponse(response);

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<Map<String, dynamic>> getNoticeById(int noticeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notice/getById/$noticeId'),
    );

    _checkResponse(response);
    return _decodeObject(response);
  }

  Future<void> addNotice({
    required String title,
    required String description,
    required int noticeDate,
    required int societyId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notice/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'noticeDate': noticeDate,
        'societyId': societyId,
      }),
    );

    _checkResponse(response);
  }

  Future<void> updateNotice({
    required int noticeId,
    required String title,
    required String description,
    required int noticeDate,
    required int societyId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notice/update/$noticeId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'noticeDate': noticeDate,
        'societyId': societyId,
      }),
    );

    _checkResponse(response);
  }

  Future<void> deleteNotice(int noticeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notice/delete/$noticeId'),
    );

    _checkResponse(response);
  }

  Future<Map<String, dynamic>> getNoticeWithSociety(int noticeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notice/getNoticeWithSociety/$noticeId'),
    );

    _checkResponse(response);
    return _decodeObject(response);
  }

  Future<void> addSocietyToNotice({
    required int noticeId,
    required int societyId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notice/addSocietyToNotice/$noticeId/$societyId'),
    );

    _checkResponse(response);
  }
}
