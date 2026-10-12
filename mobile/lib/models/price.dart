class GoldPrice {
  final String karat;
  final double? pricePerGram;
  final String currency;
  final bool isStale;
  final double? ageHours;
  final String? effectiveAt;
  final String priceType;
  final String unit;
  final String? source;
  final String? reference;

  GoldPrice({
    required this.karat,
    this.pricePerGram,
    this.currency = 'TZS',
    this.isStale = true,
    this.ageHours,
    this.effectiveAt,
    this.priceType = '',
    this.unit = 'TZS/g',
    this.source,
    this.reference,
  });

  factory GoldPrice.fromJson(Map<String, dynamic> json) {
    return GoldPrice(
      karat: json['karat'] ?? json['price_type'] ?? '',
      pricePerGram: (json['value'] ?? json['price_per_gram']) != null
          ? double.tryParse(
              (json['value'] ?? json['price_per_gram']).toString())
          : null,
      currency: json['currency'] ?? 'TZS',
      isStale: json['is_stale'] ?? true,
      ageHours: json['age_hours'] != null
          ? double.tryParse(json['age_hours'].toString())
          : null,
      effectiveAt: json['effective_at'],
      priceType: json['price_type'] ?? json['karat'] ?? '',
      unit: json['unit'] ?? 'TZS/g',
      source: json['source'],
      reference: json['reference'],
    );
  }
}
