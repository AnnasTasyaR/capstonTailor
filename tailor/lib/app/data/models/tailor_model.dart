class TailorModel {
  final int id;
  final int userId;
  final String shopName;
  final String? address;
  final String? phone;
  final double rating;
  final String status;
  final String? bio;
  final String? shopImage;
  final bool isVerified;
  final String? ownerName;
  final List<TailorAvailability> availability;
  final String? createdAt;
  final int totalOrders;

  TailorModel({
    required this.id,
    required this.userId,
    required this.shopName,
    this.address,
    this.phone,
    this.rating = 0.0,
    this.status = 'open',
    this.bio,
    this.shopImage,
    this.isVerified = false,
    this.ownerName,
    this.availability = const [],
    this.createdAt,
    this.totalOrders = 0,
  });

  factory TailorModel.fromJson(Map<String, dynamic> json) {
    return TailorModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      shopName: json['shop_name'] ?? '',
      address: json['address'],
      phone: json['phone'],
      rating: (json['rating'] ?? 0).toDouble(),
      status: json['status'] ?? 'open',
      bio: json['bio'],
      shopImage: json['shop_image'],
      isVerified: json['is_verified'] ?? false,
      ownerName: json['owner_name'],
      availability: (json['availability'] as List?)
          ?.map((e) => TailorAvailability.fromJson(e))
          .toList() ?? [],
      createdAt: json['created_at'],
      totalOrders: json['total_orders'] ?? 0,
    );
  }

  bool get isOpen => status == 'open';

  bool isServiceAvailable(String type) {
    final avail = availability.where((a) => a.type == type).toList();
    return avail.isNotEmpty && avail.first.isOpen;
  }
}

class TailorAvailability {
  final int id;
  final int tailorId;
  final String type;
  final bool isOpen;

  TailorAvailability({required this.id, required this.tailorId, required this.type, required this.isOpen});

  factory TailorAvailability.fromJson(Map<String, dynamic> json) {
    return TailorAvailability(
      id: json['id'] ?? 0,
      tailorId: json['tailor_id'] ?? 0,
      type: json['type'] ?? '',
      isOpen: json['is_open'] ?? false,
    );
  }
}
