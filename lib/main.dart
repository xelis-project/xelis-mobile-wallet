import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xelis_mobile_wallet/shared/logger.dart';
import 'package:xelis_mobile_wallet/shared/resources/app_resources.dart';
import 'package:xelis_mobile_wallet/shared/storage/shared_preferences/shared_preferences_provider.dart';
import 'package:xelis_mobile_wallet/shared/theme/extensions.dart';
import 'package:xelis_mobile_wallet/shared/widgets/xelis_wallet_app.dart';
import 'package:xelis_mobile_wallet/src/rust/frb_generated.dart';

Future<void> main() async {
  logger.info('Starting XELIS Wallet ...');
  initFlutterLogging();
  logger.info('initializing Flutter bindings ...');
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  logger.info('initializing Rust lib ...');
  await RustLib.init();
  await initRustLogging();

  if (isDesktopDevice) {
    logger.info('initializing window manager ...');
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      title: AppResources.xelisWalletName,
      size: Size(800, 1000),
      minimumSize: Size(600, 800),
      maximumSize: Size(1000, 1200),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  logger.info('loading SVG assets ...');
  //-------------------------- PRELOAD ASSETS ----------------------------------
  AppResources.svgBannerGreen = await ScalableImage.fromSvgAsset(
      rootBundle, AppResources.svgBannerGreenPath,
      compact: true);
  AppResources.svgBannerBlack = await ScalableImage.fromSvgAsset(
      rootBundle, AppResources.svgBannerBlackPath,
      compact: true);
  AppResources.svgBannerWhite = await ScalableImage.fromSvgAsset(
      rootBundle, AppResources.svgBannerWhitePath,
      compact: true);
  //----------------------------------------------------------------------------

  final prefs = await SharedPreferences.getInstance();

  logger.info('initialisation done!');
  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      observers: kDebugMode ? [LoggerProviderObserver()] : null,
      child: const XelisWalletApp(),
    ),
  );
}
