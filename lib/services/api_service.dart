import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_model.dart';
import '../models/schedule_model.dart';

class ApiService {
  static const String baseUrl = 'http://103.169.238.18:9999';

  /// Helper method untuk membuat headers yang konsisten untuk semua request
  /// Termasuk ngrok-skip-browser-warning header yang diperlukan ngrok
  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'Accept-Encoding': 'gzip, deflate',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    
    return headers;
  }

  /// Test connection to API
  static Future<void> testConnection() async {
    try {
      print('[v0] DEBUG: Testing connection to API...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      print('[v0] DEBUG: API connection test - Status: ${response.statusCode}');
    } catch (e) {
      print('[v0] ERROR: API connection test failed: $e');
    }
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
      ).timeout(const Duration(seconds: 30)); // Increased timeout for NGROK

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
      ).timeout(const Duration(seconds: 30)); // Increased timeout to 30 seconds for NGROK

      print('[v0] DEBUG: Response status: ${response.statusCode}');
      final bodyPreview = response.body.length > 200 
          ? response.body.substring(0, 200) + '...' 
          : response.body;
      print('[v0] DEBUG: Response body: $bodyPreview');

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

  /// Submit Tugas - Upload multiple photos dan selesaikan tugas
  /// Endpoint: PATCH /api/tickets/{id}/
  /// Body: Multipart Form Data dengan status=RESOLVED, photos[]=files, material_used=text (optional)
  static Future<void> uploadPhoto(
    int ticketId,
    List<String> filePaths,
    String? materialUsed,
    {List<Uint8List>? fileBytes}
  ) async {
    try {
      print('[v0] DEBUG: uploadPhoto called - ticketId: $ticketId, photoCount: ${filePaths.length}');
      print('[v0] DEBUG: Platform: ${kIsWeb ? 'WEB' : 'MOBILE/DESKTOP'}');
      print('[v0] DEBUG: fileBytes provided: ${fileBytes != null}');
      
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

      // Upload multiple file fotos - support both web dan mobile
      for (int i = 0; i < filePaths.length; i++) {
        if (kIsWeb && fileBytes != null && i < fileBytes.length) {
          // Web: gunakan bytes langsung
          print('[v0] DEBUG: Using bytes for photo ${i + 1} (size: ${fileBytes[i].length} bytes)');
          request.files.add(
            http.MultipartFile.fromBytes(
              'photos',
              fileBytes[i],
              filename: 'photo_proof_${i + 1}.jpg',
            ),
          );
        } else {
          // Mobile/Desktop: gunakan file path
          print('[v0] DEBUG: Using file path for photo ${i + 1}');
          request.files.add(
            await http.MultipartFile.fromPath('photos', filePaths[i]),
          );
        }
      }

      final response = await request.send().timeout(const Duration(seconds: 30));

      print('[v0] DEBUG: Upload response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        print('[v0] ERROR: Upload failed - ${response.statusCode}: $responseBody');
        throw Exception('Failed to upload photos: ${response.statusCode} - $responseBody');
      }
      
      print('[v0] DEBUG: Photo uploaded successfully!');
    } catch (e) {
      print('[v0] ERROR in uploadPhoto: $e');
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
      ).timeout(const Duration(seconds: 30)); // Increased timeout for NGROK

      if (response.statusCode != 201) {
        throw Exception('Failed to create ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create ticket error: $e');
    }
  }

  /// Fetch Preventive Maintenance schedules by month
  /// Endpoint: GET /api/schedules/month/{month_id}/
  /// Note: Backend automatically filters data for year 2026
  static Future<List<Schedule>> getSchedulesByMonth(int year, int month) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('No token found');

      // Use new endpoint format: /api/schedules/month/{month_id}/
      final url = '$baseUrl/api/schedules/month/$month/';
      final headers = _getHeaders(token: token);
      
      print('[v0] DEBUG: Fetching schedules from: $url');
      print('[v0] DEBUG: Using token: ${token.substring(0, 10)}...');
      print('[v0] DEBUG: Request headers: $headers');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30)); // Increased timeout to 30 seconds for NGROK

      print('[v0] DEBUG: Schedule response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('[v0] DEBUG: Successfully loaded ${data.length} schedules');
        return data.map((json) => Schedule.fromJson(json as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        print('[v0] ERROR: Authentication failed - Token invalid or expired');
        print('[v0] DEBUG: Response: ${response.body}');
        throw Exception('Unauthorized - Token invalid');
      } else {
        print('[v0] ERROR: Server returned status ${response.statusCode}');
        print('[v0] DEBUG: Response: ${response.body}');
        throw Exception('Failed to load schedules: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] ERROR in getSchedulesByMonth: $e');
      throw Exception('Get schedules error: $e');
    }
  }

  /// Take/Terima Jadwal Preventive Maintenance task
  /// Endpoint: PATCH /api/schedules/{id}/
  /// Body: {"status": "IN_PROGRESS"}
  static Future<void> takeScheduleTask(int scheduleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('No token found');

      final url = '$baseUrl/api/schedules/$scheduleId/';
      final headers = _getHeaders(token: token);
      
      print('[v0] DEBUG: Taking schedule task - ID: $scheduleId');
      print('[v0] DEBUG: PATCH to: $url');

      // Use new endpoint format: /api/schedules/{id}/
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'status': 'IN_PROGRESS'}),
      ).timeout(const Duration(seconds: 30)); // Increased timeout to 30 seconds for NGROK

      print('[v0] DEBUG: Take task response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('[v0] ERROR: Failed to take task - Status: ${response.statusCode}');
        print('[v0] DEBUG: Response: ${response.body}');
        throw Exception('Failed to take task: ${response.statusCode}');
      }
      print('[v0] DEBUG: Task taken successfully');
    } catch (e) {
      print('[v0] ERROR in takeScheduleTask: $e');
      throw Exception('Take task error: $e');
    }
  }

  /// Submit Preventive Maintenance report dengan dokumentasi (multiple photos)
  /// Endpoint: PATCH /api/schedules/{id}/
  /// Body: Multipart Form Data dengan status=RESOLVED, photos=files[], keterangan=text, material_used=text
  static Future<void> submitScheduleReport(
    int scheduleId,
    List<String> filePaths,
    String keterangan,
    String? materialUsed,
    {List<Uint8List>? fileBytes}
  ) async {
    try {
      print('[v0] DEBUG: submitScheduleReport called - scheduleId: $scheduleId, photos: ${filePaths.length}');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('No token found');

      // Use new endpoint format: /api/schedules/{id}/
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/api/schedules/$scheduleId/'),
      );

      request.headers['Authorization'] = 'Token $token';
      request.headers['ngrok-skip-browser-warning'] = 'true';

      request.fields['status'] = 'RESOLVED';
      request.fields['keterangan'] = keterangan;

      if (materialUsed != null && materialUsed.isNotEmpty) {
        request.fields['material_used'] = materialUsed;
      }

      // Upload multiple photos
      for (int i = 0; i < filePaths.length; i++) {
        if (kIsWeb && fileBytes != null && i < fileBytes.length) {
          print('[v0] DEBUG: Adding photo ${i + 1} from bytes');
          request.files.add(
            http.MultipartFile.fromBytes(
              'photos',
              fileBytes[i],
              filename: 'schedule_report_${i + 1}.jpg',
            ),
          );
        } else {
          print('[v0] DEBUG: Adding photo ${i + 1} from path');
          request.files.add(
            await http.MultipartFile.fromPath('photos', filePaths[i]),
          );
        }
      }

      print('[v0] DEBUG: Sending multipart request to ${request.url}');
      final response = await request.send().timeout(const Duration(seconds: 30));

      print('[v0] DEBUG: Submit report response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        print('[v0] ERROR: Failed to submit report - Status: ${response.statusCode}');
        print('[v0] DEBUG: Response: $responseBody');
        throw Exception('Failed to submit report: ${response.statusCode}');
      }
      print('[v0] DEBUG: Report submitted successfully');
    } catch (e) {
      print('[v0] ERROR in submitScheduleReport: $e');
      throw Exception('Submit report error: $e');
    }
  }
}
