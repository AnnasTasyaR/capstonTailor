class OrderModel {
  final int id;
  final int customerId;
  final int tailorId;
  final String type;
  final String? complexity;
  final String status;
  final String? designImage;
  final String? designNotes;
  final String? estimatedDone;
  final String? fittingDate;
  final int? queueNumber;
  final String? customerName;
  final String? tailorName;
  final List<OrderHistoryItem> history;
  final String? createdAt;

  OrderModel({
    required this.id, required this.customerId, required this.tailorId,
    required this.type, this.complexity, required this.status,
    this.designImage, this.designNotes, this.estimatedDone, this.fittingDate,
    this.queueNumber, this.customerName, this.tailorName,
    this.history = const [], this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      tailorId: json['tailor_id'] ?? 0,
      type: json['type'] ?? '',
      complexity: json['complexity'],
      status: json['status'] ?? 'pending',
      designImage: json['design_image'],
      designNotes: json['design_notes'],
      estimatedDone: json['estimated_done'],
      fittingDate: json['fitting_date'],
      queueNumber: json['queue_number'],
      customerName: json['customer_name'],
      tailorName: json['tailor_name'],
      history: (json['history'] as List?)?.map((e) => OrderHistoryItem.fromJson(e)).toList() ?? [],
      createdAt: json['created_at'],
    );
  }
}

class OrderHistoryItem {
  final int id;
  final int orderId;
  final String status;
  final String? changedAt;
  final String? notes;

  OrderHistoryItem({required this.id, required this.orderId, required this.status, this.changedAt, this.notes});

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderHistoryItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      status: json['status'] ?? '',
      changedAt: json['changed_at'],
      notes: json['notes'],
    );
  }
}

class TrackingStep {
  final String status;
  final String label;
  final String icon;
  final bool isCompleted;
  final bool isCurrent;
  final String? completedAt;

  TrackingStep({required this.status, required this.label, required this.icon,
    required this.isCompleted, required this.isCurrent, this.completedAt});

  factory TrackingStep.fromJson(Map<String, dynamic> json) {
    return TrackingStep(
      status: json['status'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      isCurrent: json['is_current'] ?? false,
      completedAt: json['completed_at'],
    );
  }
}
