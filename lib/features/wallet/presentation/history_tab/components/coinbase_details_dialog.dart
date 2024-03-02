import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xelis_dart_sdk/xelis_dart_sdk.dart';
import 'package:xelis_mobile_wallet/features/settings/application/app_localizations_provider.dart';
import 'package:xelis_mobile_wallet/shared/theme/extensions.dart';
import 'package:xelis_mobile_wallet/shared/utils/utils.dart';

class CoinbaseDetailsDialog extends ConsumerWidget {
  const CoinbaseDetailsDialog(this.transactionEntry, {super.key});

  final TransactionEntry transactionEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(appLocalizationsProvider);
    final entryType = transactionEntry.txEntryType as CoinbaseEntry;
    return AlertDialog(
      scrollable: true,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          loc.details,
          style: context.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                loc.topoheight,
                style: context.labelMedium
                    ?.copyWith(color: context.colors.primary),
              ),
              SelectableText(transactionEntry.topoHeight.toString()),
            ],
          ),
          const SizedBox(height: 16.0),
          Column(
            children: [
              Text(
                loc.tx_hash,
                style: context.labelMedium
                    ?.copyWith(color: context.colors.primary),
              ),
              SelectableText(transactionEntry.hash)
            ],
          ),
          const SizedBox(height: 16.0),
          Column(
            children: [
              Text(
                loc.reward,
                style:
                    context.labelSmall?.copyWith(color: context.colors.primary),
              ),
              SelectableText(
                '${formatXelis(entryType.reward)} XEL',
                style: context.bodyLarge,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(loc.ok_button),
        ),
      ],
    );
  }
}