import 'package:expense_tracker/config/extensions.dart';
import 'package:expense_tracker/enums/enums.dart';
import 'package:expense_tracker/model/loan_model.dart';
import 'package:expense_tracker/shared/utils/currency_formatter.dart';
import 'package:expense_tracker/styles/color.dart';
import 'package:expense_tracker/styles/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanInfoCard extends StatelessWidget {
  final LoanModel loanData;
  final Function() onTap;
  const LoanInfoCard({super.key, required this.loanData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: primaryColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.outbond,
                  color: loanData.loanType == LoanType.LoanGivenByMe.name ? redColor : greenColor,
                ),
                Expanded(
                  child: Text(
                    '${loanData.loanCurrency.symbol}${currencyFormatter(double.parse(loanData.loanAmount.toString()))}',
                    textAlign: TextAlign.right,
                    style: AppTheme.subTitleStyle(),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              loanData.loanName.ellipsis(),
              style: AppTheme.titleStyle(isBold: true),
            ),
            Text(loanData.loanType == LoanType.LoanGivenByMe.name
                ? 'Loaned to'
                : 'Borrowed from'), //return loaned to or owed by depending on the type of loan
            Text(loanData.fullName.ellipsis(), style: AppTheme.titleStyle(isBold: true)),
            const Text('On'),
            Text(DateFormat.yMEd().format(loanData.loanDateIncurred),
                style: AppTheme.titleStyle(isBold: true)),
          ],
        ),
      ),
    );
  }
}
