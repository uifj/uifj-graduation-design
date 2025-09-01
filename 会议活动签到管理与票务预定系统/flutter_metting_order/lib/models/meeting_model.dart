import 'dart:convert';

class MeetingResponse {
  final int code;
  final MeetingData data;
  final String msg;

  MeetingResponse({
    required this.code,
    required this.data,
    required this.msg,
  });

  factory MeetingResponse.fromJson(Map<String, dynamic> json) {
    return MeetingResponse(
      code: json['code'],
      data: MeetingData.fromJson(json['data']),
      msg: json['msg'],
    );
  }
}

class MeetingData {
  final List<Meeting> list;
  final int total;
  final int page;
  final int pageSize;

  MeetingData({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory MeetingData.fromJson(Map<String, dynamic> json) {
    return MeetingData(
      list: List<Meeting>.from(json['list'].map((x) => Meeting.fromJson(x))),
      total: json['total'],
      page: json['page'],
      pageSize: json['pageSize'],
    );
  }
}

class Meeting {
  final int id;
  final String createdAt;
  final String updatedAt;
  final String title;
  final int capacity;
  final String location;
  final String type;
  final String status;
  final String posturl;
  final double? price; // Price can be null
  final String tags;
  final String speakers;
  final String description;
  final String equipment;
  final String startTime;
  final String endTime;

  Meeting({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.capacity,
    required this.location,
    required this.type,
    required this.status,
    required this.posturl,
    this.price,
    required this.tags,
    required this.speakers,
    required this.description,
    required this.equipment,
    required this.startTime,
    required this.endTime,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['ID'],
      createdAt: json['CreatedAt'],
      updatedAt: json['UpdatedAt'],
      title: json['title'],
      capacity: json['capacity'],
      location: json['location'],
      type: json['type'],
      status: json['status'],
      posturl: json['posturl'],
      price:
          json['price']?.toDouble(), // Handle potential null and cast to double
      tags: json['tags'],
      speakers: json['speakers'],
      description: json['description'],
      equipment: json['equipment'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}
