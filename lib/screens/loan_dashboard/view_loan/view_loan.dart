import 'package:expense_tracker/config/extensions.dart';
import 'package:expense_tracker/enums/enums.dart';
import 'package:expense_tracker/provider/loan/loan_provider.dart';
import 'package:expense_tracker/screens/loan_dashboard/local_widget/loan_view_details_card.dart';
import 'package:expense_tracker/shared/utils/app_logger.dart';
import 'package:expense_tracker/shared/utils/currency_formatter.dart';
import 'package:expense_tracker/shared/utils/message.dart';
import 'package:expense_tracker/shared/utils/url_launcher_helper.dart';
import 'package:expense_tracker/shared/widgets/busy_overlay.dart';
import 'package:expense_tracker/shared/widgets/custom_button.dart';
import 'package:expense_tracker/styles/color.dart';
import 'package:expense_tracker/styles/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

class ViewLoadScreen extends StatefulWidget {
  final String loanId;
  const ViewLoadScreen({super.key, required this.loanId});

  @override
  State<ViewLoadScreen> createState() => _ViewLoadScreenState();
}

class _ViewLoadScreenState extends State<ViewLoadScreen> {
  @override
  void initState() {
    super.initState();

    Provider.of<LoanProviderImpl>(context, listen: false)
        .viewLoanById(widget.loanId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanProviderImpl>(builder: (context, stateModel, child) {
      return BusyOverlay(
        show: stateModel.viewState == ViewState.Busy,
        title: stateModel.message,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Loan Details', style: AppTheme.headerStyle()),
          ),
          body: stateModel.singleLoan == null
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //loan name
                        LoanViewDetailsCard(
                          titleText: stateModel.singleLoan!.loanName,
                          headerText: 'Loan Name',
                        ),

                        LoanViewDetailsCard(
                          titleText:
                              '${stateModel.singleLoan!.loanCurrency.symbol} ${currencyFormatter(double.parse(stateModel.singleLoan!.loanAmount))}',
                          headerText: 'Loan Amount',
                        ),

                        if (stateModel.singleLoan!.loanDoc != null)
                          Column(
                            children: [
                              Text(
                                "Loan Document",
                                style: AppTheme.headerStyle(),
                              ),
                              TextButton(
                                onPressed: () {
                                  launchSite(stateModel.singleLoan!.loanDoc);
                                  appLogger(stateModel.singleLoan!.loanDoc);
                                },
                                child: Text(
                                  "View Document",
                                  style:
                                      AppTheme.titleStyle(color: primaryColor),
                                ),
                              ),
                            ],
                          ),
                        15.height(),

                        Row(
                          children: [
                            LoanViewDetailsCard(
                              headerText: 'Incured Date',
                              titleText: DateFormat.yMEd().format(
                                  stateModel.singleLoan!.loanDateIncurred),
                            ),
                            const Spacer(),
                            LoanViewDetailsCard(
                              headerText: 'Due Date',
                              titleText: DateFormat.yMEd().format(
                                  stateModel.singleLoan!.loanDateIncurred),
                            ),
                          ],
                        ),
                        10.height(),
                        const Divider(),
                        10.height(),

                        Text(
                          stateModel.singleLoan!.loanType ==
                                  LoanType.LoanGivenByMe.name
                              ? "Debtor's Details"
                              : "Creditor's Details",
                          style: AppTheme.headerStyle(),
                        ),

                        const Divider(),

                        10.height(),
                        LoanViewDetailsCard(
                          headerText: 'Full Name',
                          titleText: stateModel.singleLoan!.fullName,
                        ),
                        LoanViewDetailsCard(
                          headerText: 'Phone Number',
                          titleText: stateModel.singleLoan!.phoneNumber,
                        ),
                        80.height(),
                        //
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                onPressed: () async {
                                  await stateModel.deleteLoan(widget.loanId);

                                  if (stateModel.viewState == ViewState.Error) {
                                    if (context.mounted) {
                                      showMessage(context, stateModel.message,
                                          isError: true);
                                    }
                                    return;
                                  }
                                  if (stateModel.viewState ==
                                      ViewState.Success) {
                                    if (context.mounted) {
                                      stateModel.viewLoan();
                                      showMessage(context, stateModel.message);
                                      context.go('/loan_dashboard');
                                    }
                                  }
                                },
                                text: 'Delete',
                                width: 0,
                                color: Colors.red,
                              ),
                            ),
                            if (stateModel.singleLoan!.loanStatus ==
                                LoanStatus.Pending.name)
                              20.width(),
                            if (stateModel.singleLoan!.loanStatus ==
                                LoanStatus.Pending.name)
                              Expanded(
                                child: CustomButton(
                                  onPressed: () async {
                                    ///success
                                    await stateModel.updateLoan(widget.loanId);

                                    if (stateModel.viewState ==
                                        ViewState.Error) {
                                      if (context.mounted) {
                                        showMessage(context, stateModel.message,
                                            isError: true);
                                      }
                                      return;
                                    }
                                    if (stateModel.viewState ==
                                        ViewState.Success) {
                                      if (context.mounted) {
                                        stateModel.viewLoan();
                                        showMessage(
                                            context, stateModel.message);
                                        context.go('/loan_dashboard');
                                      }
                                    }
                                  },
                                  width: 0,
                                  text: 'Mark as Complete',
                                ),
                              ),
                          ],
                        ),
                        50.height()
                      ],
                    ),
                  ),
                ),
        ),
      );
    });
  }
}
