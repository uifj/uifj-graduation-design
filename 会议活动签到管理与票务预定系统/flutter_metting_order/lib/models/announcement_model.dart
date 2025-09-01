class AnnouncementResponse {
  final int code;
  final String msg;
  final AnnouncementData data;

  AnnouncementResponse({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory AnnouncementResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementResponse(
      code: json['code'] as int,
      msg: json['msg'] as String,
      data: AnnouncementData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class AnnouncementData {
  final List<Announcement> list;
  final int total;
  final int page;
  final int pageSize;

  AnnouncementData({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory AnnouncementData.fromJson(Map<String, dynamic> json) {
    return AnnouncementData(
      list: (json['list'] as List)
          .map((item) => Announcement.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
    );
  }
}

class Announcement {
  final int id;
  final String createdAt;
  final String updatedAt;
  final String title;
  final String content;
  final int userId;
  final List<Map<String, dynamic>> attachments;

  Announcement({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.content,
    required this.userId,
    required this.attachments,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['ID'] as int,
      createdAt: json['CreatedAt'] as String,
      updatedAt: json['UpdatedAt'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      userId: json['userID'] as int,
      attachments: (json['attachments'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList(),
    );
  }
}
