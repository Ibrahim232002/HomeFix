enum UserRole {
  customer,
  technician;

  String get displayNameAr => this == UserRole.customer ? 'عميل' : 'فني صيانة';
  String get nameStr => this == UserRole.customer ? 'Customer' : 'Technician';

  static UserRole fromString(String value) {
    if (value.toLowerCase() == 'technician') return UserRole.technician;
    return UserRole.customer;
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final UserRole role;
  final String? avatarUrl;
  final String createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? avatarUrl,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.nameStr,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'Customer'),
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}
