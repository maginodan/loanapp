import 'package:currency_picker/currency_picker.dart';
import 'package:expense_tracker/config/extensions.dart';
import 'package:expense_tracker/enums/enums.dart';
import 'package:expense_tracker/provider/loan/loan_provider.dart';
import 'package:expense_tracker/service/upload_doc_service.dart';
import 'package:expense_tracker/shared/utils/app_logger.dart';
import 'package:expense_tracker/shared/utils/message.dart';
import 'package:expense_tracker/shared/utils/pick_file.dart';
import 'package:expense_tracker/shared/widgets/busy_overlay.dart';
import 'package:expense_tracker/shared/widgets/custom_button.dart';
import 'package:expense_tracker/shared/widgets/date_picker.dart';
import 'package:expense_tracker/styles/color.dart';
import 'package:expense_tracker/styles/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text_form_field/flutter_text_form_field.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// import 'package:expense_tracker/shared/widgets/custom_text_field.dart';
// import 'package:your_project_name/shared/widgets/custom_text_field.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final currentDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Consumer<LoanProviderImpl>(builder: (context, stateModel, _) {
      return BusyOverlay(
        show: stateModel.viewState == ViewState.Busy,
        title: stateModel.message,
        child: Scaffold(
          appBar: AppBar(),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Loan Name",
                      style: AppTheme.headerStyle(),
                    ),
                    8.height(),
                    CustomTextField(
                      stateModel.loanNameController,
                      hint: 'Loan Name',
                      password: false,
                      border: Border.all(color: greyColor),
                    ),
                    20.height(),
                    Text(
                      "Loan Type",
                      style: AppTheme.headerStyle(),
                    ),
                    ...List.generate(LoanType.values.length, (index) {
                      final type = LoanType.values[index];

                      final loanText = type == LoanType.LoanGivenByMe
                          ? 'Giving out a loan?'
                          : 'Taking a loan?';

                      return RadioListTile(
                        activeColor: primaryColor,
                        contentPadding: const EdgeInsets.all(0),
                        value: type,
                        groupValue: stateModel.selectedLoanType,
                        onChanged: (value) {
                          stateModel.selectedLoanType = value;
                        },
                        title: Text(loanText),
                      );
                    }),
                    20.height(),
                    Text(
                      "Loan Document (optional)",
                      style: AppTheme.headerStyle(),
                    ),
                    8.height(),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            pickDocument().then((value) async {
                              appLogger("Value path : $value");
                              if (value != null) {
                                ///Upload the doc to the server
                                stateModel.viewState = ViewState.Busy;
                                stateModel.message = 'Uploading doc';

                                final result =
                                    await uploadDocumentToServer(value);

                                appLogger("result $result");

                                if (result.state == ViewState.Error) {
                                  if (context.mounted) {
                                    showMessage(context, result.fileUrl);
                                  }
                                  stateModel.viewState = ViewState.Error;
                                  return;
                                }

                                if (result.state == ViewState.Success) {
                                  stateModel.uploadedDocument = result.fileUrl;
                                  if (context.mounted) {
                                    showMessage(context,
                                        'Document uploaded successfully');
                                  }
                                  stateModel.viewState = ViewState.Success;
                                  return;
                                }
                              }
                            });
                          },
                          child: Text(
                            'Upload Document (pdf, image)',
                            style: AppTheme.titleStyle(color: primaryColor),
                          ),
                        ),
                        const Spacer(),
                        if (stateModel.uploadedDocument != null)
                          const Icon(
                            Icons.check_circle,
                            color: greenColor,
                          )
                      ],
                    ),
                    20.height(),
                    Row(
                      children: [
                        Text(
                          "Loan Amount",
                          style: AppTheme.headerStyle(),
                        ),
                        const Spacer(),
                        Text(
                          "Loan Currency",
                          style: AppTheme.headerStyle(),
                        ),
                      ],
                    ),
                    8.height(),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            stateModel.loanAmountController,
                            hint: 'Loan Amount',
                            keyboardType: TextInputType.number,
                            password: false,
                            border: Border.all(color: greyColor),
                          ),
                        ),
                        30.width(),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              showCurrencyPicker(
                                context: context,
                                showFlag: true,
                                showCurrencyName: true,
                                showCurrencyCode: true,
                                onSelect: (Currency currency) {
                                  stateModel.selectedCurrency = currency;
                                },
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: greyColor),
                                  color: whiteColor),
                              height: 50,
                              child: Text(stateModel.selectedCurrency == null
                                  ? 'Currency'
                                  : '${stateModel.selectedCurrency!.code} - ${stateModel.selectedCurrency!.symbol}'),
                            ),
                          ),
                        )
                      ],
                    ),
                    20.height(),
                    Row(
                      children: [
                        Text(
                          "Incurred Date",
                          style: AppTheme.headerStyle(),
                        ),
                        const Spacer(),
                        Text(
                          "Due Date",
                          style: AppTheme.headerStyle(),
                        ),
                      ],
                    ),
                    8.height(),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            stateModel.incurredDateController,
                            hint: 'Incurred Date',
                            keyboardType: TextInputType.number,
                            password: false,
                            readOnly: true,
                            onTap: () async {
                              ///show date picker
                              final date = await pickDate(context,
                                  firstDate: DateTime(currentDate.year - 1),
                                  secondDate: currentDate);

                              if (date != null) {
                                stateModel.incurredDateController.text =
                                    date.toString();
                              }
                            },
                            border: Border.all(color: greyColor),
                          ),
                        ),
                        30.width(),
                        Expanded(
                          child: CustomTextField(
                            stateModel.dueDateController,
                            hint: 'Due Date',
                            keyboardType: TextInputType.number,
                            password: false,
                            readOnly: true,
                            onTap: () async {
                              ///show date picker
                              final date = await pickDate(context,
                                  firstDate: currentDate,
                                  secondDate: DateTime(currentDate.year + 150));

                              if (date != null) {
                                stateModel.dueDateController.text =
                                    date.toString();
                              }
                            },
                            border: Border.all(color: greyColor),
                          ),
                        ),
                      ],
                    ),
                    20.height(),
                    if (stateModel.selectedLoanType != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${stateModel.selectedLoanType == LoanType.LoanOwedByMe ? 'Creditor' : 'Debtor'}  Details",
                            style: AppTheme.headerStyle(),
                          ),
                          10.height(),
                          Text(
                            "Full Name",
                            style: AppTheme.headerStyle(),
                          ),
                          8.height(),
                          CustomTextField(
                            stateModel.creditorOrDebtorNameController,
                            hint: 'Full Name',
                            password: false,
                            border: Border.all(color: greyColor),
                          ),
                          8.height(),
                          Text(
                            "Phone Number",
                            style: AppTheme.headerStyle(),
                          ),
                          8.height(),
                          CustomTextField(
                            stateModel.creditorOrDebtorPhoneNumberController,
                            hint: 'Phone Number',
                            keyboardType: TextInputType.number,
                            password: false,
                            border: Border.all(color: greyColor),
                          ),
                          40.height(),
                          CustomButton(
                            onPressed: () async {
                              // context.go('/loan_dashboard');
                              if (stateModel.loanNameController.text.isEmpty ||
                                  stateModel
                                      .loanAmountController.text.isEmpty ||
                                  stateModel
                                      .incurredDateController.text.isEmpty ||
                                  stateModel.dueDateController.text.isEmpty) {
                                showMessage(context, "All Fields are required");
                                return;
                              }
                              if (stateModel.selectedLoanType == null) {
                                showMessage(
                                    context, "Please select a loan type");
                                return;
                              }

                              if (stateModel.selectedCurrency == null) {
                                showMessage(
                                    context, "Please select a currency");
                                return;
                              }

                              if (stateModel.creditorOrDebtorNameController.text
                                      .isEmpty ||
                                  stateModel
                                      .creditorOrDebtorPhoneNumberController
                                      .text
                                      .isEmpty) {
                                final messageType =
                                    stateModel.selectedLoanType ==
                                            LoanType.LoanGivenByMe
                                        ? "Debtor's details are required"
                                        : "Creditor's details are required";

                                showMessage(context, messageType);
                                return;
                              }

                              ///success
                              await stateModel.addLoan();

                              if (stateModel.viewState == ViewState.Error) {
                                if (context.mounted) {
                                  showMessage(context, stateModel.message,
                                      isError: true);
                                }
                                return;
                              }
                              if (stateModel.viewState == ViewState.Success) {
                                if (context.mounted) {
                                  stateModel.viewLoan();
                                  showMessage(context, stateModel.message);
                                  context.go('/loan_dashboard');
                                }
                              }
                            },
                            text: 'Send Request',
                          ),
                          40.height(),
                          ///////
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
