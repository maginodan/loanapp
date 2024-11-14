import 'package:expense_tracker/config/extensions.dart';
import 'package:expense_tracker/styles/theme.dart';
import 'package:flutter/material.dart';

class LoanViewDetailsCard extends StatelessWidget {
  final String headerText;
  final String titleText;
  const LoanViewDetailsCard({super.key, required this.headerText, required this.titleText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headerText,
          style: AppTheme.headerStyle(),
        ),
        8.height(),
        Text(
          titleText,
          style: AppTheme.titleStyle(),
        ),
        15.height(),
      ],
    );
  }
}
