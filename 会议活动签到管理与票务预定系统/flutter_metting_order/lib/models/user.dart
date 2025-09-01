enum UserRole { attendee, staff, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final UserRole role;
  final List<String> ticketIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.role,
    required this.ticketIds,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      role: UserRole.values.byName(json['role']),
      ticketIds: List<String>.from(json['ticketIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'role': role.name,
      'ticketIds': ticketIds,
    };
  }

  bool get isStaff => role == UserRole.staff || role == UserRole.admin;
}
