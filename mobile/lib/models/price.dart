class GoldPrice {
  final String karat;
  final double? pricePerGram;
  final String currency;
  final bool isStale;
  final double? ageHours;
  final String? effectiveAt;

  GoldPrice({
    required this.karat,
    this.pricePerGram,
    this.currency = 'TZS',
    this.isStale = true,
    this.ageHours,
    this.effectiveAt,
  });

  factory GoldPrice.fromJson(Map<String, dynamic> json) {
    return GoldPrice(
      karat: json['karat'] ?? '',
      pricePerGram: json['price_per_gram'] != null
          ? double.tryParse(json['price_per_gram'].toString())
          : null,
      currency: json['currency'] ?? 'TZS',
      isStale: json['is_stale'] ?? true,
      ageHours: json['age_hours'] != null
          ? double.tryParse(json['age_hours'].toString())
          : null,
      effectiveAt: json['effective_at'],
    );
  }
}
