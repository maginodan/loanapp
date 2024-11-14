class LoanModel {
  String? loanId;
  final String loanName;
  final String loanType;
  final dynamic loanDoc;
  final String loanAmount;
  final LoanCurrency loanCurrency;
  final DateTime loanDateIncurred;
  String loanStatus;
  final DateTime loanDateDue;
  final String fullName;
  final String phoneNumber;

  LoanModel({
    required this.loanId,
    required this.loanName,
    required this.loanType,
    required this.loanDoc,
    required this.loanAmount,
    required this.loanCurrency,
    required this.loanDateIncurred,
    required this.loanStatus,
    required this.loanDateDue,
    required this.fullName,
    required this.phoneNumber,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
        loanId: json["loan_id"],
        loanName: json["loan_name"],
        loanType: json["loan_type"],
        loanDoc: json["loan_doc"],
        loanAmount: json["loan_amount"],
        loanCurrency: LoanCurrency.fromJson(json["loan_currency"]),
        loanDateIncurred: DateTime.parse(json["loan_date_incurred"]),
        loanStatus: json["loan_status"],
        loanDateDue: DateTime.parse(json["loan_date_due"]),
        fullName: json["full_name"],
        phoneNumber: json["phone_number"],
      );

  Map<String, dynamic> toJson() => {
        "loan_id": loanId,
        "loan_name": loanName,
        "loan_type": loanType,
        "loan_doc": loanDoc,
        "loan_amount": loanAmount,
        "loan_currency": loanCurrency.toJson(),
        "loan_date_incurred": loanDateIncurred.toIso8601String(),
        "loan_status": loanStatus,
        "loan_date_due": loanDateDue.toIso8601String(),
        "full_name": fullName,
        "phone_number": phoneNumber,
      };
}

class LoanCurrency {
  final String code;
  final String name;
  final String symbol;
  final int number;
  final String flag;
  final int decimalDigits;
  final String namePlural;
  final bool symbolOnLeft;
  final String decimalSeparator;
  final String thousandsSeparator;
  final bool spaceBetweenAmountAndSymbol;

  LoanCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.number,
    required this.flag,
    required this.decimalDigits,
    required this.namePlural,
    required this.symbolOnLeft,
    required this.decimalSeparator,
    required this.thousandsSeparator,
    required this.spaceBetweenAmountAndSymbol,
  });

  factory LoanCurrency.fromJson(Map<String, dynamic> json) => LoanCurrency(
        code: json["code"],
        name: json["name"],
        symbol: json["symbol"],
        number: json["number"],
        flag: json["flag"],
        decimalDigits: json["decimal_digits"],
        namePlural: json["name_plural"],
        symbolOnLeft: json["symbol_on_left"],
        decimalSeparator: json["decimal_separator"],
        thousandsSeparator: json["thousands_separator"],
        spaceBetweenAmountAndSymbol: json["space_between_amount_and_symbol"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "symbol": symbol,
        "number": number,
        "flag": flag,
        "decimal_digits": decimalDigits,
        "name_plural": namePlural,
        "symbol_on_left": symbolOnLeft,
        "decimal_separator": decimalSeparator,
        "thousands_separator": thousandsSeparator,
        "space_between_amount_and_symbol": spaceBetweenAmountAndSymbol,
      };
}
