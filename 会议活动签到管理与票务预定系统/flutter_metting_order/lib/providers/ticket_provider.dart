import 'package:flutter/material.dart';
import 'dart:math';
import '../models/ticket.dart';
import '../models/ticket_model.dart';
import '../core/network/api_service.dart';

class TicketProvider with ChangeNotifier {
  List<Ticket> _tickets = [];
  bool _isLoading = false;
  String? _error;

  List<Ticket> get tickets => [..._tickets];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserTickets(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getTicketsList(
        userId: int.parse(userId),
      );

      if (response.code == 0) {
        _tickets = response.data.list
            .map((ticketModel) => ticketModel.toTicket())
            .toList();
      } else {
        _error = 'API Error: ${response.msg} (Code: ${response.code})';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Ticket?> reserveTicket(
    String eventId,
    String userId,
    double price,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.reserveTicket(
        meetingId: int.parse(eventId),
        price: price,
        userId: userId,
      );

      if (response['code'] == 0) {
        // 创建成功后，刷新票务列表
        await fetchUserTickets(userId);
        // 返回最新创建的票务
        return _tickets.isNotEmpty ? _tickets.last : null;
      } else {
        _error = 'API Error: ${response['msg']} (Code: ${response['code']})';
        return null;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> confirmPayment(String ticketId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final ticketIndex = _tickets.indexWhere(
        (ticket) => ticket.id == ticketId,
      );
      if (ticketIndex >= 0) {
        final updatedTicket = _tickets[ticketIndex].copyWith(
          status: TicketStatus.paid,
        );
        _tickets[ticketIndex] = updatedTicket;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Ticket not found');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkInTicket(String ticketId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final ticketIndex = _tickets.indexWhere(
        (ticket) => ticket.id == ticketId,
      );
      if (ticketIndex >= 0) {
        final ticket = _tickets[ticketIndex];
        if (ticket.status != TicketStatus.paid) {
          throw Exception('Ticket is not paid');
        }

        final updatedTicket = ticket.copyWith(
          status: TicketStatus.used,
          checkInTime: DateTime.now().toIso8601String(),
        );
        _tickets[ticketIndex] = updatedTicket;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Ticket not found');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelTicket(String ticketId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final ticketIndex = _tickets.indexWhere(
        (ticket) => ticket.id == ticketId,
      );
      if (ticketIndex >= 0) {
        final updatedTicket = _tickets[ticketIndex].copyWith(
          status: TicketStatus.cancelled,
        );
        _tickets[ticketIndex] = updatedTicket;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Ticket not found');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Ticket? findById(String id) {
    try {
      return _tickets.firstWhere((ticket) => ticket.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Ticket> getTicketsForEvent(String eventId) {
    return _tickets.where((ticket) => ticket.eventId == eventId).toList();
  }

  String _generateQrCode() {
    // In a real app, this would generate a unique QR code
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        32,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<Ticket> _upcomingTickets = [];

  List<Ticket> get upcomingTickets => _upcomingTickets;

  Future<void> fetchUpcomingTickets(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getTicketsList(
        userId: userId, // TODO: Get actual user ID from auth provider
        status: '1', // 1 represents upcoming tickets,2 是 past
      );
      _upcomingTickets =
          response.data.list.map((model) => model.toTicket()).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
