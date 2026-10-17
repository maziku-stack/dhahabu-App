import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/l10n/l10n.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> txn;
  const ReceiptScreen({super.key, required this.txn});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          l10n.receipt,
          style: textTheme.titleLarge?.copyWith(color: AppColors.navy),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        children: [
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
            confirmed ? l10n.saleConfirmed : l10n.waitingForConfirmation,
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
              l10n.bothPartiesMustConfirmNote,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l10n.transactionId('${txn['id']}'),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          _SectionTitle(l10n.parties),
          _DetailRow(l10n.miner, '${txn['miner_name'] ?? txn['miner_phone'] ?? '-'}'),
          _DetailRow(l10n.dealer, '${txn['dealer_name'] ?? txn['dealer_phone'] ?? '-'}'),
          const SizedBox(height: 28),

          _SectionTitle(l10n.gold),
          _DetailRow(l10n.weight, '${txn['weight_grams']} g'),
          _DetailRow(l10n.karat, '${txn['karat']}'),
          _DetailRow(l10n.assayStatus, '${txn['assay_status'] ?? l10n.unverified}'),
          if (txn['assay_status'] == 'verified') ...[
            if (has(txn['measured_weight_grams']))
              _DetailRow(l10n.measuredWeight, '${txn['measured_weight_grams']} g'),
            if (has(txn['measured_karat']))
              _DetailRow(l10n.measuredKarat, '${txn['measured_karat']}'),
            if (has(txn['measured_purity']))
              _DetailRow(l10n.measuredPurity, '${txn['measured_purity']}'),
            if (has(txn['assay_device_id']))
              _DetailRow(l10n.assayDevice, '${txn['assay_device_id']}'),
            if (has(txn['assay_reference']))
              _DetailRow(l10n.assayReference, '${txn['assay_reference']}'),
          ],
          const SizedBox(height: 28),

          _SectionTitle(l10n.price),
          _DetailRow(l10n.priceBasis, '${txn['price_basis'] ?? 'party_agreed'}'),
          _DetailRow(l10n.agreedPrice, 'TSh ${fmt.format(price)}'),

          if (tax != null) ...[
            const SizedBox(height: 28),
            _SectionTitle(l10n.governmentCharges),
            _DetailRow(l10n.assessment, '${tax['assessment_status'] ?? l10n.unavailable}'),
            _DetailRow(l10n.payment, '${tax['payment_status'] ?? l10n.notStarted}'),
            if (has(tax['authority_reference']))
              _DetailRow(l10n.authorityReference, '${tax['authority_reference']}'),
            if (tax['royalty_amount'] != null)
              _DetailRow(l10n.assessedAmount, 'TSh ${money(tax['royalty_amount'])}'),
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
                  l10n.assessed,
                  '${charge['currency']} ${money(charge['amount'])}',
                ),
              _DetailRow(l10n.payment, '${charge['payment_status']}'),
              if (has(charge['legal_basis']))
                _DetailRow(l10n.legalBasis, '${charge['legal_basis']}'),
              if (has(charge['payment_reference']))
                _DetailRow(l10n.paymentReference, '${charge['payment_reference']}'),
            ],
          ],

          if (!confirmed) ...[
            const SizedBox(height: 28),
            _SectionTitle(l10n.agreement),
            _DetailRow(l10n.miner, minerConfirmed ? l10n.recorded : l10n.waiting),
            _DetailRow(l10n.dealer, dealerConfirmed ? l10n.recorded : l10n.waiting),
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
              label: Text(l10n.downloadPdf),
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
                l10n.backToHome,
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
