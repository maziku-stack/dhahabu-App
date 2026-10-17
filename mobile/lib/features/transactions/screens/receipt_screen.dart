import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/core/widgets/app_card.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> txn;
  const ReceiptScreen({super.key, required this.txn});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final tax = txn['tax_record'] as Map<String, dynamic>?;
    final charges = (tax?['charges'] as List?) ?? const [];
    final confirmed = txn['status'] == 'confirmed';
    final minerConfirmed = txn['miner_confirmed_at'] != null;
    final dealerConfirmed = txn['dealer_confirmed_at'] != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(confirmed ? Icons.check_circle : Icons.schedule,
              size: 56,
              color: confirmed ? AppColors.success : AppColors.warning),
          const SizedBox(height: 12),
          Text(
            confirmed
                ? 'Sale Confirmed'
                : 'Waiting for both parties to confirm',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (!confirmed) ...[
            const SizedBox(height: 8),
            const Text(
              'Both the miner and dealer must open Sales and confirm with their own PIN.',
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Txn ${txn['id']}',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.gold)),
                const SizedBox(height: 12),
                Text('Miner: ${txn['miner_name'] ?? txn['miner_phone'] ?? ''}'),
                Text(
                    'Dealer: ${txn['dealer_name'] ?? txn['dealer_phone'] ?? ''}'),
                Text('Weight: ${txn['weight_grams']} g (${txn['karat']})'),
                Text('Assay: ${txn['assay_status'] ?? 'unverified'}'),
                if (txn['assay_status'] == 'verified') ...[
                  if (txn['measured_weight_grams'] != null)
                    Text('Measured weight: ${txn['measured_weight_grams']} g'),
                  if (txn['measured_karat'] != null &&
                      '${txn['measured_karat']}'.isNotEmpty)
                    Text('Measured karat: ${txn['measured_karat']}'),
                  if (txn['measured_purity'] != null)
                    Text('Measured purity: ${txn['measured_purity']}'),
                  if (txn['assay_device_id'] != null &&
                      '${txn['assay_device_id']}'.isNotEmpty)
                    Text('Assay device: ${txn['assay_device_id']}'),
                  if (txn['assay_reference'] != null &&
                      '${txn['assay_reference']}'.isNotEmpty)
                    Text('Assay reference: ${txn['assay_reference']}'),
                ],
                Text('Price basis: ${txn['price_basis'] ?? 'party_agreed'}'),
                Text(
                    'Price: TSh ${fmt.format(double.tryParse('${txn['agreed_price']}') ?? 0)}'),
                if (tax != null) ...[
                  const Divider(),
                  Text(
                      'Charge assessment: ${tax['assessment_status'] ?? 'unavailable'}'),
                  Text(
                      'Payment to authority: ${tax['payment_status'] ?? 'not started'}'),
                  if (tax['authority_reference'] != null &&
                      '${tax['authority_reference']}'.isNotEmpty)
                    Text('Authority reference: ${tax['authority_reference']}'),
                  if (tax['royalty_amount'] != null)
                    Text(
                        'Assessed amount: TSh ${fmt.format(double.tryParse('${tax['royalty_amount']}') ?? 0)}'),
                  for (final charge in charges) ...[
                    const Divider(),
                    Text('${charge['charge_name']} · ${charge['authority']}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (charge['assessment_status'] == 'assessed' &&
                        charge['amount'] != null)
                      Text(
                          'Assessed: ${charge['currency']} ${fmt.format(double.tryParse('${charge['amount']}') ?? 0)}'),
                    Text('Payment: ${charge['payment_status']}'),
                    if (charge['legal_basis'] != null &&
                        '${charge['legal_basis']}'.isNotEmpty)
                      Text('Legal basis: ${charge['legal_basis']}'),
                    if (charge['payment_reference'] != null &&
                        '${charge['payment_reference']}'.isNotEmpty)
                      Text('Payment reference: ${charge['payment_reference']}'),
                  ],
                ],
                if (!confirmed) ...[
                  const Divider(),
                  Text(
                      'Miner agreement: ${minerConfirmed ? 'recorded' : 'waiting'}'),
                  Text(
                      'Dealer agreement: ${dealerConfirmed ? 'recorded' : 'waiting'}'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
              onPressed: () {}, child: const Text('Download PDF (soon)')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
