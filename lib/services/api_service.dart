import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_model.dart';

class ApiService {
  static const String baseUrl = 'http://upstate-unbaked-peso.ngrok.free.dev';

  /// Helper method untuk membuat headers yang konsisten untuk semua request
  /// Termasuk ngrok-skip-browser-warning header yang diperlukan ngrok
  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    
    return headers;
  }

  static Future<String> login(String username, String password) async {
    try {
      print('[v0] DEBUG: Attempting login for user: $username');
      print('[v0] DEBUG: API Endpoint: $baseUrl/api/login/');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/login/'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('[v0] DEBUG: Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;
        print('[v0] DEBUG: Login successful! Token received: ${token.substring(0, 10)}...');
        return token;
      } else {
        print('[v0] ERROR: Login failed with status ${response.statusCode}');
        print('[v0] DEBUG: Response: ${response.body}');
        throw Exception('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[v0] ERROR in login: $e');
      throw Exception('Login error: $e');
    }
  }

  static Future<List<Ticket>> getTickets({String? status}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('[v0] DEBUG: Token from storage = ${token != null ? 'EXISTS' : 'NOT FOUND'}');
      
      if (token == null) {
        print('[v0] ERROR: No token found in SharedPreferences');
        throw Exception('No token found - Please login first');
      }

      String url = '$baseUrl/api/tickets/';
      if (status != null) {
        url += '?status=$status';
      }

      print('[v0] DEBUG: Fetching from URL: $url');
      print('[v0] DEBUG: Using token: ${token.substring(0, 10)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      ).timeout(const Duration(seconds: 10));

      print('[v0] DEBUG: Response status: ${response.statusCode}');
      print('[v0] DEBUG: Response body: ${response.body.substring(0, 200)}...');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('[v0] DEBUG: Successfully loaded ${data.length} tickets');
        return data.map((json) => Ticket.fromJson(json as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        print('[v0] ERROR: Unauthorized - Token invalid or expired');
        throw Exception('Unauthorized - Token invalid or expired');
      } else {
        print('[v0] ERROR: Failed to load tickets: ${response.statusCode}');
        print('[v0] DEBUG: Error response: ${response.body}');
        throw Exception('Failed to load tickets: ${response.statusCode} - ${response.body}');
      }
    } on Exception catch (e) {
      print('[v0] ERROR in getTickets: $e');
      
      // CORS error detection
      if (e.toString().contains('Failed to fetch')) {
        print('[v0] CORS ERROR DETECTED!');
        print('[v0] Backend perlu menambahkan CORS headers:');
        print('[v0]   Access-Control-Allow-Origin: *');
        print('[v0]   Access-Control-Allow-Methods: GET, POST, PATCH, DELETE, OPTIONS');
        print('[v0]   Access-Control-Allow-Headers: Authorization, Content-Type');
        throw Exception('CORS Error - Backend belum configure CORS headers. Hubungi admin!');
      }
      
      throw Exception('Get tickets error: $e');
    }
  }

  static Future<Ticket> getTicketDetail(int ticketId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('[v0] DEBUG: Fetching ticket detail for ID: $ticketId');

      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse('$baseUrl/api/tickets/$ticketId/'),
        headers: _getHeaders(token: token),
      ).timeout(const Duration(seconds: 10));

      print('[v0] DEBUG: Detail response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[v0] DEBUG: Successfully loaded ticket detail');
        return Ticket.fromJson(data as Map<String, dynamic>);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token invalid');
      } else {
        print('[v0] ERROR: Failed to load ticket: ${response.statusCode}');
        throw Exception('Failed to load ticket: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] ERROR in getTicketDetail: $e');
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
        headers: _getHeaders(token: token),
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
      request.headers['ngrok-skip-browser-warning'] = 'true';

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
        headers: _getHeaders(token: token),
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
