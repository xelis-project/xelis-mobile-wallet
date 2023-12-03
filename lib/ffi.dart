import 'dart:ffi';
import 'dart:io' as io;

import 'package:xelis_mobile_wallet/bridge_definitions.dart';
import 'package:xelis_mobile_wallet/bridge_generated.dart';

export 'bridge_definitions.dart';

// Re-export the bridge so it is only necessary to import this file.
export 'bridge_generated.dart';

const _base = 'xelis_native';

// On MacOS, the dynamic library is not bundled with the binary,
// but rather directly **linked** against the binary.
final _dylib = io.Platform.isWindows ? '$_base.dll' : 'lib$_base.so';

final XelisNative api = XelisNativeImpl(
  io.Platform.isIOS || io.Platform.isMacOS
      ? DynamicLibrary.executable()
      : DynamicLibrary.open(_dylib),
);
