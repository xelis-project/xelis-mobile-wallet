// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.12.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'logger.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

Future<void> startTokioRuntimeForRust({dynamic hint}) =>
    RustLib.instance.api.startTokioRuntimeForRust(hint: hint);

Stream<LogEntry> createLogStream({dynamic hint}) =>
    RustLib.instance.api.createLogStream(hint: hint);

Future<void> setUpRustLogger({dynamic hint}) =>
    RustLib.instance.api.setUpRustLogger(hint: hint);
