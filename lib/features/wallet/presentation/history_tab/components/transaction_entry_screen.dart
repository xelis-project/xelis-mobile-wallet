import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:xelis_dart_sdk/xelis_dart_sdk.dart';
import 'package:genesix/features/settings/application/app_localizations_provider.dart';
import 'package:genesix/shared/theme/extensions.dart';
import 'package:genesix/shared/theme/constants.dart';
import 'package:genesix/shared/utils/utils.dart';
import 'package:genesix/shared/widgets/components/background_widget.dart';
import 'package:genesix/shared/widgets/components/generic_app_bar_widget.dart';

class TransactionEntryScreenExtra {
  final TransactionEntry transactionEntry;

  TransactionEntryScreenExtra(this.transactionEntry);
}

class TransactionEntryScreen extends ConsumerWidget {
  const TransactionEntryScreen({required this.routerState, super.key});

  final GoRouterState routerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(appLocalizationsProvider);
    //final entryType = transactionEntry.txEntryType as IncomingEntry;

    final extra = routerState.extra as TransactionEntryScreenExtra;
    final transactionEntry = extra.transactionEntry;
    final entryType = transactionEntry.txEntryType;

    var displayTopoheight = NumberFormat().format(transactionEntry.topoHeight);

    var entryTypeName = '';
    Icon icon;

    CoinbaseEntry? coinbase;
    OutgoingEntry? outgoing;
    BurnEntry? burn;
    IncomingEntry? incoming;

    switch (entryType) {
      case CoinbaseEntry():
        entryTypeName = 'Coinbase';
        coinbase = entryType;
        icon = const Icon(Icons.square_rounded);
      case BurnEntry():
        entryTypeName = 'Burn';
        burn = entryType;
        icon = const Icon(Icons.fireplace_rounded);
      case IncomingEntry():
        entryTypeName = 'Incoming';
        incoming = entryType;
        icon = const Icon(Icons.arrow_downward);
      case OutgoingEntry():
        entryTypeName = 'Outgoing';
        outgoing = entryType;
        icon = const Icon(Icons.arrow_upward);
    }

    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const GenericAppBar(title: 'Transaction Entry'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
              Spaces.large, 0, Spaces.large, Spaces.large),
          children: [
            Text('Type', style: context.headlineSmall),
            const SizedBox(height: Spaces.small),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectableText(
                  entryTypeName,
                  style: context.bodyLarge!
                      .copyWith(color: context.moreColors.mutedColor),
                ),
                const SizedBox(width: Spaces.medium),
                icon,
              ],
            ),
            const SizedBox(height: Spaces.medium),
            Text(loc.topoheight, style: context.headlineSmall),
            const SizedBox(height: Spaces.small),
            SelectableText(
              displayTopoheight,
              style: context.bodyLarge!
                  .copyWith(color: context.moreColors.mutedColor),
            ),
            const SizedBox(height: Spaces.medium),
            Text('Hash', style: context.headlineSmall),
            const SizedBox(height: Spaces.small),
            SelectableText(
              transactionEntry.hash,
              style: context.bodyLarge!
                  .copyWith(color: context.moreColors.mutedColor),
            ),
            const SizedBox(height: Spaces.medium),
            Text('Fee', style: context.headlineSmall),
            const SizedBox(height: Spaces.small),
            SelectableText(
              transactionEntry.fee != null
                  ? '${formatXelis(transactionEntry.fee!)} XEL'
                  : '${formatXelis(0)} XEL',
              style: context.bodyLarge!
                  .copyWith(color: context.moreColors.mutedColor),
            ),

            // COINBASE
            if (entryType is CoinbaseEntry)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Spaces.medium),
                  Text('Amount', style: context.headlineSmall),
                  const SizedBox(height: Spaces.small),
                  SelectableText(
                    '+${formatXelis(coinbase!.reward)} XEL', // hmm coinbase could return other asset than XELIS
                    style: context.bodyLarge!
                        .copyWith(color: context.moreColors.mutedColor),
                  ),
                ],
              ),

            // BURN
            if (entryType is BurnEntry)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Spaces.medium),
                  Text('Burn', style: context.headlineSmall),
                  const SizedBox(height: Spaces.small),
                  SelectableText(
                    '-${formatXelis(burn!.amount)} XEL',
                    style: context.bodyLarge!
                        .copyWith(color: context.moreColors.mutedColor),
                  ),
                ],
              ),

            // OUTGOING

            if (entryType is OutgoingEntry)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Spaces.medium),
                  Text(
                    loc.transfers,
                    style: context.headlineSmall,
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: outgoing!.transfers.length,
                    itemBuilder: (BuildContext context, int index) {
                      final transfer = outgoing!.transfers[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(Spaces.medium),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loc.asset, style: context.labelLarge),
                                  SelectableText(transfer.asset == xelisAsset
                                      ? 'XELIS'
                                      : transfer.asset),
                                ],
                              ),
                              const SizedBox(width: Spaces.medium),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Amount',
                                      /* transfer.asset == xelisAsset
                                          ? loc.amount.capitalize
                                          : '${loc.amount.capitalize} (${loc.atomic_units})',*/
                                      style: context.labelLarge),
                                  SelectableText(transfer.asset == xelisAsset
                                      ? '-${formatXelis(transfer.amount)} XEL'
                                      : '${transfer.amount}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),

            // INCOMING
            if (entryType is IncomingEntry)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Spaces.medium),
                  Text('From', style: context.headlineSmall),
                  const SizedBox(height: Spaces.small),
                  Row(
                    children: [
                      RandomAvatar(incoming!.from, width: 35, height: 35),
                      const SizedBox(width: Spaces.small),
                      Expanded(
                        child: SelectableText(
                          incoming.from,
                          style: context.bodyLarge!
                              .copyWith(color: context.moreColors.mutedColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spaces.medium),
                  Text(
                    loc.transfers,
                    style: context.headlineSmall,
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: incoming.transfers.length,
                    itemBuilder: (BuildContext context, int index) {
                      final transfer = incoming!.transfers[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(Spaces.medium,
                              Spaces.small, Spaces.medium, Spaces.small),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loc.asset, style: context.labelLarge),
                                  SelectableText(transfer.asset == xelisAsset
                                      ? 'XELIS'
                                      : transfer.asset),
                                ],
                              ),
                              const SizedBox(width: Spaces.medium),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Amount',
                                      /*transfer.asset == xelisAsset
                                          ? loc.amount.capitalize
                                          : '${loc.amount.capitalize} (${loc.atomic_units})',*/
                                      style: context.labelLarge),
                                  SelectableText(transfer.asset == xelisAsset
                                      ? '+${formatXelis(transfer.amount)} XEL'
                                      : '${transfer.amount}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}