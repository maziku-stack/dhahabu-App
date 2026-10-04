class TaxRecord {
  final String id;
  final double royaltyRate;
  final double royaltyAmount;
  final double taxBase;
  final String currency;

  TaxRecord({
    required this.id,
    required this.royaltyRate,
    required this.royaltyAmount,
    required this.taxBase,
    this.currency = 'TZS',
  });

  factory TaxRecord.fromJson(Map<String, dynamic> json) {
    return TaxRecord(
      id: json['id'].toString(),
      royaltyRate: double.tryParse(json['royalty_rate'].toString()) ?? 0,
      royaltyAmount: double.tryParse(json['royalty_amount'].toString()) ?? 0,
      taxBase: double.tryParse(json['tax_base'].toString()) ?? 0,
      currency: json['currency'] ?? 'TZS',
    );
  }
}

class GoldTransaction {
  final String id;
  final String minerName;
  final String minerPhone;
  final String dealerName;
  final String dealerPhone;
  final double weightGrams;
  final String karat;
  final double pricePerGram;
  final double agreedPrice;
  final String status;
  final String notes;
  final String createdAt;
  final String? confirmedAt;
  final TaxRecord? taxRecord;

  GoldTransaction({
    required this.id,
    this.minerName = '',
    this.minerPhone = '',
    this.dealerName = '',
    this.dealerPhone = '',
    required this.weightGrams,
    required this.karat,
    required this.pricePerGram,
    required this.agreedPrice,
    required this.status,
    this.notes = '',
    required this.createdAt,
    this.confirmedAt,
    this.taxRecord,
  });

  factory GoldTransaction.fromJson(Map<String, dynamic> json) {
    return GoldTransaction(
      id: json['id'].toString(),
      minerName: json['miner_name'] ?? '',
      minerPhone: json['miner_phone'] ?? '',
      dealerName: json['dealer_name'] ?? '',
      dealerPhone: json['dealer_phone'] ?? '',
      weightGrams: double.tryParse(json['weight_grams'].toString()) ?? 0,
      karat: json['karat'] ?? '',
      pricePerGram: double.tryParse(json['price_per_gram'].toString()) ?? 0,
      agreedPrice: double.tryParse(json['agreed_price'].toString()) ?? 0,
      status: json['status'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
      confirmedAt: json['confirmed_at'],
      taxRecord: json['tax_record'] != null
          ? TaxRecord.fromJson(json['tax_record'])
          : null,
    );
  }

  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending_confirm';
}
