import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../models/ticket_model.dart';
import '../services/api_service.dart';

class TicketProvider extends ChangeNotifier {
  List<Ticket> _tickets = [];
  Ticket? _selectedTicket;
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'OPEN';
  int _openCount = 0;
  int _inProgressCount = 0;
  int _resolvedCount = 0;

  List<Ticket> get tickets => _tickets;
  Ticket? get selectedTicket => _selectedTicket;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;
  int get openCount => _openCount;
  int get inProgressCount => _inProgressCount;
  int get resolvedCount => _resolvedCount;

  Future<void> fetchTickets({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('[v0] DEBUG: TicketProvider.fetchTickets called with status: $status');
      _tickets = await ApiService.getTickets(status: status);
      print('[v0] DEBUG: Successfully fetched ${_tickets.length} tickets');
      _error = null;
    } catch (e) {
      print('[v0] ERROR in fetchTickets: $e');
      _error = e.toString();
      _tickets = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllTicketsForStats() async {
    try {
      print('[v0] DEBUG: fetchAllTicketsForStats called');
      final open = await ApiService.getTickets(status: 'OPEN');
      final inProgress = await ApiService.getTickets(status: 'IN_PROGRESS');
      final resolved = await ApiService.getTickets(status: 'RESOLVED');

      _openCount = open.length;
      _inProgressCount = inProgress.length;
      _resolvedCount = resolved.length;
      
      print('[v0] DEBUG: Stats - Open: $_openCount, InProgress: $_inProgressCount, Resolved: $_resolvedCount');
      notifyListeners();
    } catch (e) {
      print('[v0] ERROR in fetchAllTicketsForStats: $e');
      _error = e.toString();
    }
  }

  Future<void> fetchTicketDetail(int ticketId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedTicket = await ApiService.getTicketDetail(ticketId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _selectedTicket = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateTicketStatus(int ticketId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.updateStatus(ticketId, status);
      if (_selectedTicket != null && _selectedTicket!.id == ticketId) {
        _selectedTicket = Ticket(
          id: _selectedTicket!.id,
          title: _selectedTicket!.title,
          description: _selectedTicket!.description,
          location: _selectedTicket!.location,
          status: status,
          reporter: _selectedTicket!.reporter,
          reporterName: _selectedTicket!.reporterName,
          technician: _selectedTicket!.technician,
          technicianName: _selectedTicket!.technicianName,
          materialUsed: _selectedTicket!.materialUsed,
          photoProof: _selectedTicket!.photoProof,
          createdAt: _selectedTicket!.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Complete Ticket - Upload multiple photos + material digunakan
  /// Mengirim PATCH request dengan multipart form-data (multiple files)
  /// Status otomatis berubah ke RESOLVED
  Future<bool> completeTicket(
    int ticketId,
    List<String> filePaths,
    String? materialUsed,
    {List<Uint8List>? fileBytes}
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await ApiService.uploadPhoto(
        ticketId, 
        filePaths, 
        materialUsed,
        fileBytes: fileBytes,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createNewTicket(
    String title,
    String location,
    String description,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.createTicket(title, location, description);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
