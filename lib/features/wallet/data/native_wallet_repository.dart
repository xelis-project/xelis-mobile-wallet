import 'dart:convert';

import 'package:xelis_dart_sdk/xelis_dart_sdk.dart' as sdk;
import 'package:xelis_mobile_wallet/features/wallet/domain/event.dart';
import 'package:xelis_mobile_wallet/shared/logger.dart';
import 'package:xelis_mobile_wallet/src/rust/api/wallet.dart';

class NativeWalletRepository {
  NativeWalletRepository._internal(this._xelisWallet);

  final XelisWallet _xelisWallet;

  static Future<NativeWalletRepository> create(
      String walletPath, String pwd, Network network) async {
    final xelisWallet = await createXelisWallet(
        name: walletPath, password: pwd, network: network);
    logger.info('new XELIS Wallet created: $walletPath');
    return NativeWalletRepository._internal(xelisWallet);
  }

  static Future<NativeWalletRepository> recover(
      String walletPath, String pwd, Network network,
      {required String seed}) async {
    final xelisWallet = await createXelisWallet(
        name: walletPath, password: pwd, seed: seed, network: network);
    logger.info('XELIS Wallet recovered from seed: $walletPath');
    return NativeWalletRepository._internal(xelisWallet);
  }

  static Future<NativeWalletRepository> open(
      String walletPath, String pwd, Network network) async {
    final xelisWallet = await openXelisWallet(
        name: walletPath, password: pwd, network: network);
    logger.info('XELIS Wallet open: $walletPath');
    return NativeWalletRepository._internal(xelisWallet);
  }

  Future<void> close() async {
    await _xelisWallet.close();
  }

  void dispose() {
    _xelisWallet.dispose();
    if (_xelisWallet.isDisposed) logger.info('Rust Wallet disposed');
  }

  XelisWallet get nativeWallet => _xelisWallet;

  String get humanReadableAddress => _xelisWallet.getAddressStr();

  Future<int> get nonce => _xelisWallet.getNonce();

  Future<bool> get isOnline => _xelisWallet.isOnline();

  Future<String> formatCoin(int amount, [String? assetHash]) async {
    return _xelisWallet.formatCoin(atomicAmount: amount, assetHash: assetHash);
  }

  Future<void> changePassword(
      {required String oldPassword, required String newPassword}) async {
    return _xelisWallet.changePassword(
        oldPassword: oldPassword, newPassword: newPassword);
  }

  Future<String> getSeed({required String password, int? languageIndex}) async {
    return _xelisWallet.getSeed(
        password: password, languageIndex: languageIndex);
  }

  Future<String> getXelisBalance() async {
    return _xelisWallet.getXelisBalance();
  }

  Future<Map<String, String>> getAssetBalances() async {
    return _xelisWallet.getAssetBalances();
  }

  Future<void> rescan({required int topoHeight}) async {
    return _xelisWallet.rescan(topoheight: topoHeight);
  }

  Future<String> transfer(
      {required double amount,
      required String address,
      String? assetHash}) async {
    return _xelisWallet.transfer(
        floatAmount: amount, strAddress: address, assetHash: assetHash);
  }

  Future<String> burn(
      {required double amount, required String assetHash}) async {
    return _xelisWallet.burn(floatAmount: amount, assetHash: assetHash);
  }

  Future<List<sdk.TransactionEntry>> allHistory() async {
    var jsonTransactionsList = await _xelisWallet.allHistory();
    return jsonTransactionsList
        .map((e) => jsonDecode(e))
        .map((entry) =>
            sdk.TransactionEntry.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> setOnline({required String daemonAddress}) async {
    await _xelisWallet.onlineMode(daemonAddress: daemonAddress);
    logger.info('XELIS Wallet connected to: $daemonAddress');
  }

  Future<void> setOffline() async {
    await _xelisWallet.offlineMode();
    logger.info('XELIS Wallet offline');
  }

  Future<sdk.GetInfoResult> getDaemonInfo() async {
    var rawData = await _xelisWallet.getDaemonInfo();
    final json = jsonDecode(rawData);
    return sdk.GetInfoResult.fromJson(json as Map<String, dynamic>);
  }

  Stream<Event> convertRawEvents() async* {
    final rawEventStream = _xelisWallet.eventsStream();

    await for (final rawData in rawEventStream) {
      final json = jsonDecode(rawData);
      final eventType = sdk.WalletEvent.fromStr(json['event'] as String);
      switch (eventType) {
        case sdk.WalletEvent.newTopoHeight:
          final newTopoheight =
              Event.newTopoHeight(json['data']['topoheight'] as int);
          yield newTopoheight;
        case sdk.WalletEvent.newAsset:
          final newAsset = Event.newAsset(
              sdk.AssetWithData.fromJson(json['data'] as Map<String, dynamic>));
          yield newAsset;
        case sdk.WalletEvent.newTransaction:
          final newTransaction = Event.newTransaction(
              sdk.TransactionEntry.fromJson(
                  json['data'] as Map<String, dynamic>));
          yield newTransaction;
        case sdk.WalletEvent.balanceChanged:
          final balanceChanged = Event.balanceChanged(
              sdk.BalanceChangedEvent.fromJson(
                  json['data'] as Map<String, dynamic>));
          yield balanceChanged;
        case sdk.WalletEvent.rescan:
          final rescan = Event.rescan(json['data']['start_topoheight'] as int);
          yield rescan;
        case sdk.WalletEvent.online:
          yield const Event.online();
        case sdk.WalletEvent.offline:
          yield const Event.offline();
      }
    }
  }
}
