import 'package:flutter/foundation.dart';

import 'package:nepal_explore/main_admin.dart' as admin_app;
import 'package:nepal_explore/main_mobile.dart' as mobile_app;

Future<void> main() {
  if (kIsWeb ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows) {
    return admin_app.mainAdmin();
  }

  return mobile_app.mainMobile();
}
