import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../core/log/log_utils.dart';
import '../core/network/api_service.dart';
import '../models/event.dart';
import '../models/meeting_model.dart';

class EventProvider with ChangeNotifier {
  final List<Meeting> _meetings = [];
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => [..._events];
  List<Meeting> get meetings => [..._meetings];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final meetingResponse = await ApiService.getMeetingsList();
      // await ApiService.getTicketsList(); // This call seems unrelated to fetching the main event list, keeping it for now but might need review later.

      // Check if the API call was successful and data is not null
      if (meetingResponse.code == 0) {
        // Convert Meeting objects to Event objects
        _events = meetingResponse.data.list.map((meeting) {
          // Basic conversion, adjust mapping based on how you want Meeting fields to map to Event fields
          return Event(
            id: meeting.id.toString(), // Use ID as a string
            title: meeting.title,
            description: meeting.description,
            location: meeting.location,
            date: DateTime.parse(
                meeting.startTime), // Assuming startTime is the event date
            imageUrl: meeting.posturl,
            price: meeting.price ?? 0.0, // Use 0.0 if price is null
            availableSeats:
                meeting.capacity, // Assuming capacity is availableSeats
            speakers: meeting.speakers
                .split(',')
                .map((s) => s.trim())
                .toList(), // Split speakers string into a list
            tags: meeting.tags
                .split(',')
                .map((t) => t.trim())
                .toList(), // Split tags string into a list
          );
        }).toList();
      } else {
        // Handle API error based on the response code and message
        _error =
            'API Error: ${meetingResponse.msg} (Code: ${meetingResponse.code})';
      }

      LogUtils().w(_events);
      // Remove the simulated delay and mock data
      // await Future.delayed(const Duration(seconds: 1));
      // _events = [...]; // Remove mock data assignment

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Event findById(String id) {
    return _events.firstWhere((event) => event.id == id);
  }

  List<Event> searchEvents(String query) {
    if (query.isEmpty) {
      return events;
    }

    final lowercaseQuery = query.toLowerCase();
    return _events.where((event) {
      return event.title.toLowerCase().contains(lowercaseQuery) ||
          event.description.toLowerCase().contains(lowercaseQuery) ||
          event.location.toLowerCase().contains(lowercaseQuery) ||
          event.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
