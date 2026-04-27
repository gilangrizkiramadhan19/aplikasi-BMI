import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_model.dart';

class ApiService {
  static const String baseUrl = 'https://upstate-unbaked-peso.ngrok-free.dev';

  static Future<String> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] as String;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  static Future<List<Ticket>> getTickets({String? status}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('No token found');

      String url = '$baseUrl/api/tickets/';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Ticket.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get tickets error: $e');
    }
  }

  static Future<Ticket> getTicketDetail(int ticketId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse('$baseUrl/api/tickets/$ticketId/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Ticket.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get ticket detail error: $e');
    }
  }

  /// Update status to IN_PROGRESS - Terima Tugas
  /// Endpoint: PATCH /api/tickets/{id}/
  /// Body: {"status": "IN_PROGRESS"}
  static Future<void> updateStatus(int ticketId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('No token found');

      final response = await http.patch(
        Uri.parse('$baseUrl/api/tickets/$ticketId/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Update status error: $e');
    }
  }

  /// Submit Tugas - Upload photo dan selesaikan tugas
  /// Endpoint: PATCH /api/tickets/{id}/
  /// Body: Multipart Form Data dengan status=RESOLVED, photo_proof=file, material_used=text (optional)
  static Future<void> uploadPhoto(
    int ticketId,
    String filePath,
    String? materialUsed,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('No token found');

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/api/tickets/$ticketId/'),
      );

      // Header - jangan set Content-Type manual, biarkan Flutter atur otomatis
      request.headers['Authorization'] = 'Token $token';

      // Status diubah menjadi RESOLVED
      request.fields['status'] = 'RESOLVED';

      // Optional: Material yang digunakan
      if (materialUsed != null && materialUsed.isNotEmpty) {
        request.fields['material_used'] = materialUsed;
      }

      // Upload file foto
      request.files.add(
        await http.MultipartFile.fromPath('photo_proof', filePath),
      );

      final response = await request.send().timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Failed to upload photo: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Upload photo error: $e');
    }
  }

  static Future<void> createTicket(
    String title,
    String location,
    String description,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('No token found');

      final response = await http.post(
        Uri.parse('$baseUrl/api/tickets/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'location': location,
          'description': description,
          'status': 'OPEN',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        throw Exception('Failed to create ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create ticket error: $e');
    }
  }
}
