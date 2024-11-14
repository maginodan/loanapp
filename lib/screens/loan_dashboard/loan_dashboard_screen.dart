import 'package:expense_tracker/config/extensions.dart';
import 'package:expense_tracker/enums/enums.dart';
import 'package:expense_tracker/provider/authentication/auth_provider.dart';
import 'package:expense_tracker/provider/loan/loan_provider.dart';
import 'package:expense_tracker/screens/loan_dashboard/local_widget/loan_info_card.dart';
import 'package:expense_tracker/shared/utils/currency_formatter.dart';
import 'package:expense_tracker/shared/widgets/busy_overlay.dart';
import 'package:expense_tracker/styles/color.dart';
import 'package:expense_tracker/styles/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoanDashboardScreen extends StatefulWidget {
  const LoanDashboardScreen({super.key});

  @override
  State<LoanDashboardScreen> createState() => _LoanDashboardScreenState();
}

class _LoanDashboardScreenState extends State<LoanDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<LoanProviderImpl>(context, listen: false).viewLoan();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanProviderImpl>(builder: (context, stateModel, child) {
      final totalLoaned = stateModel.loans
          .where((element) => element.loanType == LoanType.LoanGivenByMe.name)
          .fold(
              0.0,
              (previousValue, element) =>
                  previousValue + double.parse(element.loanAmount));

      final totalOwed = stateModel.loans
          .where((element) => element.loanType == LoanType.LoanOwedByMe.name)
          .fold(
              0.0,
              (previousValue, element) =>
                  previousValue + double.parse(element.loanAmount));

      return BusyOverlay(
        show: stateModel.viewState == ViewState.Busy,
        title: stateModel.message,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "LoanEX",
              style: AppTheme.headerStyle(),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Provider.of<AuthenticationProviderImpl>(context,
                          listen: false)
                      .logoutUser()
                      .then((value) => context.go('/'));
                },
                icon: const Icon(Icons.logout),
              ),
              IconButton(
                onPressed: () {
                  context.push('/search_loan');
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //date
                  // Align(
                  //   alignment: Alignment.center,
                  //   child: Text(
                  //     '1st Jan 2024',
                  //     style: AppTheme.headerStyle(),
                  //   ),
                  // ),
                  // 20.height(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: greyColor)),
                    alignment: Alignment.centerLeft,
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Total Loaned",
                                        style: AppTheme.headerStyle(),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.outbond,
                                      color: redColor,
                                    ),
                                  ],
                                ),
                                Text(
                                  "\$ -${currencyFormatter(totalLoaned)}",
                                  style: AppTheme.titleStyle(),
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Total Owed",
                                        style: AppTheme.headerStyle(),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.outbond,
                                      color: greenColor,
                                    ),
                                  ],
                                ),
                                Text(
                                  "\$ ${currencyFormatter(totalOwed)}",
                                  style: AppTheme.titleStyle(),
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Total Balance",
                                style: AppTheme.headerStyle(),
                              ),
                              Text(
                                "\$ ${currencyFormatter(totalOwed - totalLoaned)}",
                                style: AppTheme.titleStyle(),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  30.height(),

                  //pending loan view
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pending Loan",
                        style: AppTheme.headerStyle(),
                      ),
                      15.height(),
                      (stateModel.pendingLoans.isNotEmpty)
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                    stateModel.pendingLoans.length, (index) {
                                  final data = stateModel.pendingLoans[index];
                                  return LoanInfoCard(
                                    loanData: data,
                                    onTap: () {
                                      context.push(
                                          '/view_loan?loan_id=${data.loanId}');
                                    },
                                  );
                                }),
                              ),
                            )
                          : Center(
                              child: Text("No Pending Loans",
                                  style: AppTheme.headerStyle()))
                    ],
                  ),

                  30.height(),

                  //completed loan view
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Completed Loan",
                        style: AppTheme.headerStyle(),
                      ),
                      15.height(),
                      (stateModel.completedLoans.isNotEmpty)
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                    stateModel.completedLoans.length, (index) {
                                  final data = stateModel.completedLoans[index];
                                  return LoanInfoCard(
                                    loanData: data,
                                    onTap: () {
                                      context.push(
                                          '/view_loan?loan_id=${data.loanId}');
                                    },
                                  );
                                }),
                              ),
                            )
                          : Center(
                              child: Text("No Completed Loans",
                                  style: AppTheme.headerStyle()))
                    ],
                  ),

                  100.height(),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColor,
            onPressed: () {
              context.push('/add_loan');
            },
            child: const Icon(Icons.add),
          ),
        ),
      );
    });
  }
}
