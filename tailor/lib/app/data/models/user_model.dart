class UserModel {
  final int id;
  final String name;
  final String email;
  final String username;
  final String? phone;
  final String role;
  final String? avatar;
  final bool isActive;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    this.phone,
    required this.role,
    this.avatar,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'customer',
      avatar: json['avatar'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'username': username,
    'phone': phone, 'role': role, 'avatar': avatar,
  };
}
