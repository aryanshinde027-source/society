import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String baseUrl = 'http://localhost:8080';

  void _check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }

  // POST /ai/chat
  Future<Map<String, dynamic>> sendMessage({
    required int residentId,
    required String message,
    String? conversationId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'residentId': residentId,
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
      }),
    );

    _check(response);

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  // GET /ai/history/{conversationId}?residentId={residentId}
  Future<dynamic> getChatHistory({
    required String conversationId,
    required int residentId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/ai/history/${Uri.encodeComponent(conversationId)}',
    ).replace(queryParameters: {'residentId': residentId.toString()});

    final response = await http.get(uri);
    _check(response);
    return jsonDecode(response.body);
  }

  // POST /ai/complaint-suggestion
  Future<Map<String, dynamic>> suggestComplaint({
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/complaint-suggestion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'description': description}),
    );

    _check(response);

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }
}
