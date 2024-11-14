import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:expense_tracker/enums/enums.dart';
import 'package:expense_tracker/model/loan_model.dart';
import 'package:expense_tracker/shared/utils/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class LoanProviderUseCase {
  Future<void> addLoan();
  Future<void> viewLoan();
  Future<void> searchLoan();
  Future<void> viewLoanById(String loanId);
  Future<void> deleteLoan(String loanId);
  Future<void> updateLoan(String loanId);
}

class LoanProviderImpl extends ChangeNotifier implements LoanProviderUseCase {
  TextEditingController loanNameController = TextEditingController();
  TextEditingController loanAmountController = TextEditingController();
  TextEditingController incurredDateController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();

  TextEditingController searchLoanQueryController = TextEditingController();

  //creditor or debtor's controller
  TextEditingController creditorOrDebtorNameController =
      TextEditingController();
  TextEditingController creditorOrDebtorPhoneNumberController =
      TextEditingController();

  Currency? _selectedCurrency;

  Currency? get selectedCurrency => _selectedCurrency;

  set selectedCurrency(Currency? currency) {
    _selectedCurrency = currency;
    _updateState();
  }

  //For loan type
  LoanType? _selectedLoanType;
  LoanType? get selectedLoanType => _selectedLoanType;
  set selectedLoanType(LoanType? value) {
    _selectedLoanType = value;
    _updateState();
  }
  //Loan type ends

  String? _uploadedDocument;

  String? get uploadedDocument => _uploadedDocument;

  ///

  set uploadedDocument(String? doc) {
    _uploadedDocument = doc;
    _updateState();
  }

  ///Create state
  ViewState _viewState = ViewState.Idle;

  ViewState get viewState => _viewState;

  set viewState(ViewState value) {
    _viewState = value;
    _updateState();
  }

  String _message = '';
  String get message => _message;
  set message(String value) {
    _message = value;
    _updateState();
  }

  final _loanRef = FirebaseFirestore.instance.collection('loans');
  final _user = FirebaseAuth.instance.currentUser;

  List<LoanModel> _loans = [];

  List<LoanModel> get loans => _loans;

  //pending loans
  List<LoanModel> _pendingLoans = [];

  List<LoanModel> get pendingLoans => _pendingLoans;

  //completed loans

  List<LoanModel> _completedLoans = [];

  List<LoanModel> get completedLoans => _completedLoans;

  /// single loan
  LoanModel? _singleLoan;

  LoanModel? get singleLoan => _singleLoan;

  /// single loan
  List<LoanModel>? _searchedLoan;

  List<LoanModel>? get searchedLoan => _searchedLoan;

  _updateState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  Future<void> addLoan() async {
    _viewState = ViewState.Busy;
    message = 'Securing and saving your loan details...';
    _updateState();

    try {
      // final payload = {
      //   "loan_name": loanNameController.text,
      //   "loan_type": _selectedLoanType!.name,
      //   "loan_doc": _uploadedDocument,
      //   "loan_amount": loanAmountController.text,
      //   "loan_currency": selectedCurrency!.toJson(),
      //   "loan_date_incurred": incurredDateController.text,
      //   "loan_status": LoanStatus.Pending.name,
      //   "loan_date_due": dueDateController.text,
      //   "full_name": creditorOrDebtorNameController.text,
      //   "phone_number": creditorOrDebtorPhoneNumberController.text
      // };

      final payload = LoanModel(
          loanId: '',
          loanName: loanNameController.text,
          loanType: _selectedLoanType!.name,
          loanDoc: _uploadedDocument,
          loanAmount: loanAmountController.text,
          loanCurrency: LoanCurrency.fromJson(selectedCurrency!.toJson()),
          loanDateIncurred: DateTime.parse(incurredDateController.text),
          loanStatus: LoanStatus.Pending.name,
          loanDateDue: DateTime.parse(dueDateController.text),
          fullName: creditorOrDebtorNameController.text,
          phoneNumber: creditorOrDebtorPhoneNumberController.text);

      appLogger(payload);

      _loanRef
          .doc(_user!.uid)
          .collection('loan_details')
          .add(payload.toJson()); // Change to model

      _viewState = ViewState.Success;
      message = "Saved successfully";
      _updateState();

      _clearFields();
    } on SocketException catch (_) {
      _viewState = ViewState.Error;
      message = 'Network error. Please try again later.';
      _updateState();
    } on FirebaseException catch (e) {
      _viewState = ViewState.Error;
      message = e.code;
      _updateState();
    } catch (e) {
      _viewState == ViewState.Error;
      message = 'Error occured. Please try again later.';
      _updateState();
    }
  }

  @override
  Future<void> deleteLoan(String loanId) async {
    _viewState = ViewState.Busy;
    message = 'Updating your loan...';
    _updateState();

    try {
      final result = await _loanRef
          .doc(_user!.uid)
          .collection('loan_details')
          .doc(loanId)
          .get();

      if (result.exists) {
        await _loanRef
            .doc(_user.uid)
            .collection('loan_details')
            .doc(loanId)
            .delete();
        _viewState = ViewState.Success;
        message = "Loan deleted successfully";
      } else {
        message = "Loan with Id : $loanId does not exist";
        _viewState = ViewState.Error;
      }

      appLogger(_loans.length);

      _updateState();
    } on SocketException catch (_) {
      _viewState = ViewState.Error;
      message = 'Network error. Please try again later.';
      _updateState();
    } on FirebaseException catch (e) {
      _viewState = ViewState.Error;
      message = e.code;
      _updateState();
    } catch (e) {
      _viewState == ViewState.Error;
      message = 'Error occured. Please try again later.';
      _updateState();
    }
  }

  @override
  Future<void> searchLoan() async {
    _viewState = ViewState.Busy;
    message = 'Searching for loan...';
    _updateState();

    await Future.delayed(const Duration(seconds: 1));

    try {
      final result = _loans.where((element) => element.loanName
          .toLowerCase()
          .contains(searchLoanQueryController.text.toLowerCase()));

      if (result.isNotEmpty) {
        _searchedLoan = result.toList();
      } else {
        _searchedLoan = [];
      }
      _viewState = ViewState.Success;
      _updateState();
    } on SocketException catch (_) {
      _viewState = ViewState.Error;
      message = 'Network error. Please try again later.';
      _updateState();
    } on FirebaseException catch (e) {
      _viewState = ViewState.Error;
      message = e.code;
      _updateState();
    } catch (e) {
      _viewState = ViewState.Error;
      message = 'Error occured. Please try again later.';
      _updateState();
    }
  }

  @override
  Future<void> updateLoan(String loanId) async {
    _viewState = ViewState.Busy;
    message = 'Updating your loan...';
    _updateState();

    try {
      final result = await _loanRef
          .doc(_user!.uid)
          .collection('loan_details')
          .doc(loanId)
          .get();

      if (result.exists) {
        final loanData = LoanModel.fromJson(result.data()!);

        loanData.loanStatus = LoanStatus.Completed.name;

        appLogger(loanData);

        await _loanRef
            .doc(_user.uid)
            .collection('loan_details')
            .doc(loanId)
            .update(loanData.toJson());
        _viewState = ViewState.Success;
        message = "Loan updated successfully";
      } else {
        message = "Loan with Id : $loanId does not exist";
        _viewState = ViewState.Error;
      }

      appLogger(_loans.length);

      _updateState();
    } on SocketException catch (_) {
      _viewState = ViewState.Error;
      message = 'Network error. Please try again later.';
      _updateState();
    } on FirebaseException catch (e) {
      _viewState = ViewState.Error;
      message = e.code;
      _updateState();
    } catch (e) {
      _viewState = ViewState.Error;
      message = 'Error occured. Please try again later.';
      _updateState();
    }
  }

  @override
  Future<void> viewLoan() async {
    _viewState = ViewState.Busy;
    message = 'Preparing your loans...';
    _updateState();

    List<LoanModel> tempData = [];

    try {
      final result =
          await _loanRef.doc(_user!.uid).collection('loan_details').get();

      if (result.docs.isNotEmpty) {
        final loanData = result.docs;

        for (var i in loanData) {
          appLogger(loanData);

          final loanDataModel = LoanModel.fromJson(i.data());

          ///Add ID
          loanDataModel.loanId = i.id;
          tempData.add(loanDataModel);
        }

        appLogger(loanData);

        _loans = tempData;

        _pendingLoans = (loans.where(
                (element) => element.loanStatus == LoanStatus.Pending.name))
            .toList();
        _completedLoans = (loans.where(
                (element) => element.loanStatus == LoanStatus.Completed.name))
            .toList();
      } else {
        _loans = [];
        _pendingLoans = [];
        _completedLoans = [];
      }

      appLogger(_loans.length);

      _viewState = ViewState.Success;
      message = "Loans Fetched";
      _updateState();
    } on SocketException catch (_) {
      _viewState = ViewState.Error;
      message = 'Network error. Please try again later.';
      _updateState();
    } on FirebaseException catch (e) {
      _viewState = ViewState.Error;
      message = e.code;
      _updateState();
    } catch (e) {
      appLogger(e.toString());
      _viewState = ViewState.Error;
      message = 'Error occured. Please try again later.';
      _updateState();
    }
  }

  @override
  Future<void> viewLoanById(String loanId) async {
    _viewState = ViewState.Busy;
    message = 'Fetching your loan...';
    _updateState();

    try {
      final result = await _loanRef
          .doc(_user!.uid)
          .collection('loan_details')
          .doc(loanId)
          .get();

      if (result.exists) {
        final loanData = LoanModel.fromJson(result.data()!);

        _singleLoan = loanData;

        appLogger(loanData);

        _viewState = ViewState.Success;
        message = "Loan fetched successfully";
      } else {
        message = "Loan with Id : $loanId does not exist";
        _viewState = ViewState.Error;
      }

      _updateState();
    } on SocketException catch (_) {
      _viewState = ViewState.Error;
      message = 'Network error. Please try again later.';
      _updateState();
    } on FirebaseException catch (e) {
      _viewState = ViewState.Error;
      message = e.code;
      _updateState();
    } catch (e) {
      _viewState = ViewState.Error;
      message = 'Error occured. Please try again later.';
      _updateState();
    }
  }

  void _clearFields() {
    loanNameController.clear();
    _selectedLoanType = null;
    _uploadedDocument = null;
    loanAmountController.clear();
    selectedCurrency = null;
    incurredDateController.clear();
    dueDateController.clear();
    creditorOrDebtorNameController.clear();
    creditorOrDebtorPhoneNumberController.clear();
  }
}
