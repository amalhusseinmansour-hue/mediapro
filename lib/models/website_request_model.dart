class WebsiteRequestModel {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String? companyName;
  final String websiteType;
  final String description;
  final double? budget;
  final String? currency;
  final DateTime? deadline;
  final List<String>? features;
  final String? status;
  final String? adminNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WebsiteRequestModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.companyName,
    required this.websiteType,
    required this.description,
    this.budget,
    this.currency,
    this.deadline,
    this.features,
    this.status,
    this.adminNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory WebsiteRequestModel.fromJson(Map<String, dynamic> json) {
    return WebsiteRequestModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      companyName: json['company_name'],
      websiteType: json['website_type'] ?? '',
      description: json['description'] ?? '',
      budget: json['budget'] != null ? double.tryParse(json['budget'].toString()) : null,
      currency: json['currency'],
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
      features: json['features'] != null ? List<String>.from(json['features']) : null,
      status: json['status'],
      adminNotes: json['admin_notes'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      if (companyName != null) 'company_name': companyName,
      'website_type': websiteType,
      'description': description,
      if (budget != null) 'budget': budget,
      if (currency != null) 'currency': currency,
      if (deadline != null) 'deadline': deadline?.toIso8601String().split('T')[0],
      if (features != null) 'features': features,
    };
  }
}
