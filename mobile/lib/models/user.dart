class User {
  final String id;
  final String phone;
  final String fullName;
  final String role; // miner | dealer | admin
  final bool phoneVerified;
  final String region;
  final String miningSite;
  final bool? dealerVerified;

  User({
    required this.id,
    required this.phone,
    this.fullName = '',
    this.role = 'miner',
    this.phoneVerified = false,
    this.region = '',
    this.miningSite = '',
    this.dealerVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      phone: json['phone'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'miner',
      phoneVerified: json['phone_verified'] ?? false,
      region: json['region'] ?? '',
      miningSite: json['mining_site'] ?? '',
      dealerVerified: json['dealer_verified'],
    );
  }

  bool get isMiner => role == 'miner';
  bool get isDealer => role == 'dealer';
  bool get isAdmin => role == 'admin';
}
