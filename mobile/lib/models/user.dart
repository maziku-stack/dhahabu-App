class User {
  final String id;
  final String phone;
  final String fullName;
  final String role;
  final bool phoneVerified;
  final bool pinSet;
  final String region;
  final String miningSite;
  final bool? dealerVerified;
  final String? verificationStatus;

  User({
    required this.id,
    required this.phone,
    this.fullName = '',
    this.role = 'miner',
    this.phoneVerified = false,
    this.pinSet = false,
    this.region = '',
    this.miningSite = '',
    this.dealerVerified,
    this.verificationStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'].toString(),
        phone: json['phone'] ?? '',
        fullName: json['full_name'] ?? '',
        role: json['role'] ?? 'miner',
        phoneVerified: json['phone_verified'] ?? false,
        pinSet: json['pin_set'] ?? false,
        region: json['region'] ?? '',
        miningSite: json['mining_site'] ?? '',
        dealerVerified: json['dealer_verified'],
        verificationStatus: json['verification_status'],
      );

  bool get isMiner => role == 'miner';
  bool get isDealer => role == 'dealer';
  bool get isAdmin => role == 'admin';
  bool get isVerifiedDealer => dealerVerified == true;
}
