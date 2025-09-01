import 'package:flutter/material.dart';

enum TicketStatus { reserved, paid, used, cancelled }

class Ticket {
  final String id;
  final String eventId;
  final String userId;
  final DateTime purchaseDate;
  final double price;
  final String qrCode;
  final TicketStatus status;
  final String? checkInTime;

  Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.purchaseDate,
    required this.price,
    required this.qrCode,
    required this.status,
    this.checkInTime,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      eventId: json['eventId'],
      userId: json['userId'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      price: json['price'].toDouble(),
      qrCode: json['qrCode'],
      status: TicketStatus.values.byName(json['status']),
      checkInTime: json['checkInTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'purchaseDate': purchaseDate.toIso8601String(),
      'price': price,
      'qrCode': qrCode,
      'status': status.name,
      'checkInTime': checkInTime,
    };
  }

  Ticket copyWith({
    String? id,
    String? eventId,
    String? userId,
    DateTime? purchaseDate,
    double? price,
    String? qrCode,
    TicketStatus? status,
    String? checkInTime,
  }) {
    return Ticket(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      price: price ?? this.price,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
    );
  }

  Color getStatusColor() {
    switch (status) {
      case TicketStatus.reserved:
        return Colors.orange;
      case TicketStatus.paid:
        return Colors.green;
      case TicketStatus.used:
        return Colors.grey;
      case TicketStatus.cancelled:
        return Colors.red;
    }
  }

  String getStatusText() {
    switch (status) {
      case TicketStatus.reserved:
        return 'Reserved';
      case TicketStatus.paid:
        return 'Paid';
      case TicketStatus.used:
        return 'Used';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }
}
