import 'package:expense_tracker/styles/theme.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showMessage(BuildContext context, String message, {bool isError = false}) {
  toastification.show(
    context: context,
    title: Text(
      message,
      style: AppTheme.headerStyle(),
    ),
    showProgressBar: true,
    autoCloseDuration: const Duration(seconds: 3),
    type: isError ? ToastificationType.error : ToastificationType.success,
    // .... Other parameters
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return RotationTransition(
        turns: animation,
        child: child,
      );
    },
  );
}
