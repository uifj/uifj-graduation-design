import 'ticket.dart';

class TicketResponse {
  final int code;
  final TicketData data;
  final String msg;

  TicketResponse({
    required this.code,
    required this.data,
    required this.msg,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      code: json['code'],
      data: TicketData.fromJson(json['data']),
      msg: json['msg'],
    );
  }
}

class TicketData {
  final List<TicketModel> list;
  final int total;
  final int page;
  final int pageSize;

  TicketData({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      list: List<TicketModel>.from(
          json['list'].map((x) => TicketModel.fromJson(x))),
      total: json['total'],
      page: json['page'],
      pageSize: json['pageSize'],
    );
  }
}

class TicketModel {
  final int id;
  final String createdAt;
  final String updatedAt;
  final String ticketId;
  final int userId;
  final int meetingId;
  final String? status;
  final String? qrData;
  final String? checkinData;
  final String? purchase;
  final double? price;

  TicketModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.ticketId,
    required this.userId,
    required this.meetingId,
    this.status,
    this.qrData,
    this.checkinData,
    this.purchase,
    this.price,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['ID'],
      createdAt: json['CreatedAt'],
      updatedAt: json['UpdatedAt'],
      ticketId: json['ticket_id'],
      userId: json['user_id'],
      meetingId: json['metting_id'],
      status: json['status'],
      qrData: json['qr_data'],
      checkinData: json['checkin_data'],
      purchase: json['purchase'],
      price: json['price']?.toDouble(),
    );
  }

  // Convert to Ticket model for UI
  Ticket toTicket() {
    return Ticket(
      id: ticketId,
      eventId: meetingId.toString(),
      userId: userId.toString(),
      purchaseDate:
          purchase != null ? DateTime.parse(purchase!) : DateTime.now(),
      price: price ?? 0.0,
      qrCode: qrData ?? '',
      status: _getTicketStatus(),
      checkInTime: checkinData,
    );
  }

  TicketStatus _getTicketStatus() {
    switch (status) {
      case '1':
        return TicketStatus.reserved;
      case '2':
        return TicketStatus.paid;
      case '3':
        return TicketStatus.used;
      case '4':
        return TicketStatus.cancelled;
      default:
        return TicketStatus.reserved;
    }
  }
}
