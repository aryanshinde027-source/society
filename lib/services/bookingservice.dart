import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  static const String baseUrl = 'http://localhost:8080';

  void _check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }

  Map<String, dynamic> _object(http.Response response) {
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected API response');
  }

  List<Map<String, dynamic>> _list(http.Response response) {
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final response = await http.get(Uri.parse('$baseUrl/booking/all'));
    _check(response);
    return _list(response);
  }

  Future<Map<String, dynamic>> getBookingById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/booking/$id'));
    _check(response);
    return _object(response);
  }

  Future<List<Map<String, dynamic>>> getBookingsByResident(
    int residentId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/booking/resident/$residentId'),
    );
    _check(response);
    return _list(response);
  }

  Future<List<Map<String, dynamic>>> getBookingsByFacility(int facilid) async {
    final response = await http.get(
      Uri.parse('$baseUrl/booking/facility/$facilid'),
    );
    _check(response);
    return _list(response);
  }

  Future<Map<String, dynamic>> addBooking({
    required String bookingDate,
    required String timeSlot,
    required String status,
    required int residentId,
    required int facilid,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/booking/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bookingDate': bookingDate,
        'timeSlot': timeSlot,
        'status': status,
        'residentId': residentId,
        'facilid': facilid,
      }),
    );

    _check(response);
    return _object(response);
  }

  Future<Map<String, dynamic>> updateBooking({
    required int bookingid,
    required String bookingDate,
    required String timeSlot,
    required String status,
    required int residentId,
    required int facilid,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/booking/update/$bookingid'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bookingid': bookingid,
        'bookingDate': bookingDate,
        'timeSlot': timeSlot,
        'status': status,
        'residentId': residentId,
        'facilid': facilid,
      }),
    );

    _check(response);
    return _object(response);
  }

  Future<void> deleteBooking(int bookingid) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/booking/delete/$bookingid'),
    );
    _check(response);
  }
}
