enum AuthAppScreen {
  wallet,
  changePassword,
  walletSeedScreen,
  walletSeedDialog,
  transfer,
  transactionEntry,
}

enum AppScreen {
  openWallet,
  createWallet,
  settings,
}

extension AppScreenExtension on AppScreen {
  String get toPath {
    switch (this) {
      case AppScreen.createWallet:
        return '/create_wallet';
      case AppScreen.openWallet:
        return '/open_wallet';
      case AppScreen.settings:
        return '/settings';
    }
  }
}

extension AuthAppScreenExtension on AuthAppScreen {
  String get toPath {
    switch (this) {
      case AuthAppScreen.wallet:
        return '/wallet';
      case AuthAppScreen.changePassword:
        return '/change_password';
      case AuthAppScreen.walletSeedScreen:
        return '/wallet_seed';
      case AuthAppScreen.walletSeedDialog:
        return '/wallet_seed_dialog';
      case AuthAppScreen.transfer:
        return '/transfer';
      case AuthAppScreen.transactionEntry:
        return '/transaction_entry';
    }
  }
}
