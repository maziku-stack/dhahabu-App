import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dhahabu/core/theme/app_colors.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> txn;
  const ReceiptScreen({super.key, required this.txn});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final textTheme = Theme.of(context).textTheme;
    final tax = txn['tax_record'] as Map<String, dynamic>?;
    final charges = (tax?['charges'] as List?) ?? const [];
    final confirmed = txn['status'] == 'confirmed';
    final minerConfirmed = txn['miner_confirmed_at'] != null;
    final dealerConfirmed = txn['dealer_confirmed_at'] != null;
    final statusColor = confirmed ? AppColors.success : AppColors.warning;
    final price = double.tryParse('${txn['agreed_price']}') ?? 0;

    String money(dynamic v) => fmt.format(double.tryParse('$v') ?? 0);
    bool has(dynamic v) => v != null && '$v'.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Receipt',
          style: textTheme.titleLarge?.copyWith(color: AppColors.navy),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        children: [
          // ---------- Status header ----------
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                confirmed ? Icons.check_rounded : Icons.schedule_rounded,
                size: 38,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            confirmed ? 'Sale confirmed' : 'Waiting for confirmation',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge
                ?.copyWith(color: AppColors.navy, fontSize: 22),
          ),
          const SizedBox(height: 10),
          Text(
            'TSh ${fmt.format(price)}',
            textAlign: TextAlign.center,
            style: textTheme.displayLarge?.copyWith(
              color: AppColors.navy,
              fontSize: 32,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (!confirmed) ...[
            const SizedBox(height: 12),
            Text(
              'Both the miner and the dealer must open Sales and confirm with their own PIN.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Transaction ${txn['id']}',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          // ---------- Parties ----------
          const _SectionTitle('PARTIES'),
          _DetailRow('Miner', '${txn['miner_name'] ?? txn['miner_phone'] ?? '-'}'),
          _DetailRow('Dealer', '${txn['dealer_name'] ?? txn['dealer_phone'] ?? '-'}'),
          const SizedBox(height: 28),

          // ---------- Gold ----------
          const _SectionTitle('GOLD'),
          _DetailRow('Weight', '${txn['weight_grams']} g'),
          _DetailRow('Karat', '${txn['karat']}'),
          _DetailRow('Assay status', '${txn['assay_status'] ?? 'unverified'}'),
          if (txn['assay_status'] == 'verified') ...[
            if (has(txn['measured_weight_grams']))
              _DetailRow('Measured weight', '${txn['measured_weight_grams']} g'),
            if (has(txn['measured_karat']))
              _DetailRow('Measured karat', '${txn['measured_karat']}'),
            if (has(txn['measured_purity']))
              _DetailRow('Measured purity', '${txn['measured_purity']}'),
            if (has(txn['assay_device_id']))
              _DetailRow('Assay device', '${txn['assay_device_id']}'),
            if (has(txn['assay_reference']))
              _DetailRow('Assay reference', '${txn['assay_reference']}'),
          ],
          const SizedBox(height: 28),

          // ---------- Price ----------
          const _SectionTitle('PRICE'),
          _DetailRow('Price basis', '${txn['price_basis'] ?? 'party_agreed'}'),
          _DetailRow('Agreed price', 'TSh ${fmt.format(price)}'),

          // ---------- Government charges ----------
          if (tax != null) ...[
            const SizedBox(height: 28),
            const _SectionTitle('GOVERNMENT CHARGES'),
            _DetailRow('Assessment', '${tax['assessment_status'] ?? 'unavailable'}'),
            _DetailRow('Payment', '${tax['payment_status'] ?? 'not started'}'),
            if (has(tax['authority_reference']))
              _DetailRow('Authority reference', '${tax['authority_reference']}'),
            if (tax['royalty_amount'] != null)
              _DetailRow('Assessed amount', 'TSh ${money(tax['royalty_amount'])}'),
            for (final charge in charges) ...[
              const SizedBox(height: 20),
              Text(
                '${charge['charge_name']} · ${charge['authority']}',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              if (charge['assessment_status'] == 'assessed' &&
                  charge['amount'] != null)
                _DetailRow(
                  'Assessed',
                  '${charge['currency']} ${money(charge['amount'])}',
                ),
              _DetailRow('Payment', '${charge['payment_status']}'),
              if (has(charge['legal_basis']))
                _DetailRow('Legal basis', '${charge['legal_basis']}'),
              if (has(charge['payment_reference']))
                _DetailRow('Payment reference', '${charge['payment_reference']}'),
            ],
          ],

          // ---------- Agreements ----------
          if (!confirmed) ...[
            const SizedBox(height: 28),
            const _SectionTitle('AGREEMENT'),
            _DetailRow('Miner', minerConfirmed ? 'Recorded' : 'Waiting'),
            _DetailRow('Dealer', dealerConfirmed ? 'Recorded' : 'Waiting'),
          ],

          const SizedBox(height: 36),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
              label: const Text('Download PDF (coming soon)'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: Text(
                'Back to home',
                style: textTheme.labelLarge?.copyWith(color: AppColors.navy),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}