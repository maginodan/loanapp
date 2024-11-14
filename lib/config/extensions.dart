import 'package:flutter/material.dart';

extension IntSizedBoxExtension on int {
  SizedBox height() {
    return SizedBox(
      height: toDouble(),
    );
  }

  SizedBox width() {
    return SizedBox(
      width: toDouble(),
    );
  }
}

extension EllipsisExtension on String {
  String ellipsis() {
    if (length > 14) {
      final getFirst10String = substring(0, 14);
      return '$getFirst10String...';
    }
    return this;
  }
}



