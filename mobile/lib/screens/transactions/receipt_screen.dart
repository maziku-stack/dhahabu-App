import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> txn;
  const ReceiptScreen({super.key, required this.txn});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final tax = txn['tax_record'] as Map<String, dynamic>?;
    final confirmed = txn['status'] == 'confirmed';

    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(confirmed ? Icons.check_circle : Icons.schedule, size: 56, color: confirmed ? AppColors.success : AppColors.warning),
          const SizedBox(height: 12),
          Text(
            confirmed ? 'Sale Confirmed' : 'Pending miner confirmation',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Txn ${txn['id']}', style: const TextStyle(fontSize: 12, color: AppColors.gold)),
                const SizedBox(height: 12),
                Text('Miner: ${txn['miner_name'] ?? txn['miner_phone'] ?? ''}'),
                Text('Dealer: ${txn['dealer_name'] ?? txn['dealer_phone'] ?? ''}'),
                Text('Weight: ${txn['weight_grams']} g (${txn['karat']})'),
                Text('Price: TSh ${fmt.format(double.tryParse('${txn['agreed_price']}') ?? 0)}'),
                if (tax != null) ...[
                  const Divider(),
                  Text('Tax withheld: TSh ${fmt.format(double.tryParse('${tax['royalty_amount']}') ?? 0)}'),
                  Text('Rate: ${((double.tryParse('${tax['royalty_rate']}') ?? 0) * 100).toStringAsFixed(1)}%'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: () {}, child: const Text('Download PDF (soon)')),
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
