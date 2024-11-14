// import 'dart:developer';

import 'package:flutter/foundation.dart';

appLogger(dynamic data) {
  if (kDebugMode) {
    print(data.toString());
  }
}
