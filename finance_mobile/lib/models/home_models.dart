class Account {
  final int accountId;
  final int userId;
  final String accountName;
  final double accountBalance;
  final String currency;

  Account({
    required this.accountId,
    required this.userId,
    required this.accountName,
    required this.accountBalance,
    required this.currency,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'],
      userId: json['userId'],
      accountName: json['accountName'],
      accountBalance: (json['accountBalance'] as num).toDouble(),
      currency: json['currency'],
    );
  }
}

class Budget {
  final int budgetId;
  final int userId;
  final String periodType;
  final String startDate;
  final String endDate;
  final double amountLimit;
  final double spentAmount;

  Budget({
    required this.budgetId,
    required this.userId,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.amountLimit,
    required this.spentAmount,
  });

  double get total => amountLimit;
  double get spent => spentAmount;

  String get month {
    // startDate'den ay adını almak için
    final date = DateTime.parse(startDate);
    return "${date.month}/${date.year}"; // örn. "11/2025"
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      budgetId: json['budgetId'],
      userId: json['userId'],
      periodType: json['periodType'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      amountLimit: (json['amountLimit'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
    );
  }
}

class Transaction {
  final int transactionId;
  final int userId;
  final int accountId;
  final String transactionType;
  final String transactionTitle;
  final String transactionCategory;
  final double transactionAmount;
  final String transactionNote;
  final String transactionDate;
  final String transactionTime;

  Transaction({
    required this.transactionId,
    required this.userId,
    required this.accountId,
    required this.transactionType,
    required this.transactionTitle,
    required this.transactionCategory,
    required this.transactionAmount,
    required this.transactionNote,
    required this.transactionDate,
    required this.transactionTime,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'],
      userId: json['userId'],
      accountId: json['accountId'],
      transactionType: json['transactionType'],
      transactionTitle: json['transactionTitle'],
      transactionCategory: json['transactionCategory'],
      transactionAmount: (json['transactionAmount'] as num).toDouble(),
      transactionNote: json['transactionNote'] ?? '',
      transactionDate: json['transactionDate'],
      transactionTime: json['transactionTime'],
    );
  }
}

class ChartData {
  final double income;
  final double expense;
  final double total;

  ChartData({
    required this.income,
    required this.expense,
    required this.total,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      income: (json['income'] as num).toDouble(),
      expense: (json['expense'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}

class HomeData {
  final String userName;
  final int userId; // EKLENDİ
  final List<Account> accounts;
  final double netWorth;
  final List<Budget> budgets;
  final List<Transaction> lastTransactions;
  final ChartData chartData;

  HomeData({
    required this.userName,
    required this.userId, // constructor'a ekle
    required this.accounts,
    required this.netWorth,
    required this.budgets,
    required this.lastTransactions,
    required this.chartData,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      userName: json['userName'] ?? '',
      userId: json['userId'], // EKLENDİ
      accounts: (json['accounts'] as List)
          .map((e) => Account.fromJson(e))
          .toList(),
      netWorth: (json['netWorth'] as num).toDouble(),
      budgets: (json['budgets'] as List)
          .map((e) => Budget.fromJson(e))
          .toList(),
      lastTransactions: (json['lastTransactions'] as List)
          .map((e) => Transaction.fromJson(e))
          .toList(),
      chartData: ChartData.fromJson(json['chartData']),
    );
  }
}

// -------------------------------------------------- //

class CreateTransactionModel {
  final int userId;
  final int accountId;
  final String transactionType;
  final String transactionTitle;
  final String transactionCategory;
  final double transactionAmount;
  final String? transactionNote;
  final String transactionDate;
  final String transactionTime;

  CreateTransactionModel({
    required this.userId,
    required this.accountId,
    required this.transactionType,
    required this.transactionTitle,
    required this.transactionCategory,
    required this.transactionAmount,
    this.transactionNote,
    required this.transactionDate,
    required this.transactionTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "accountId": accountId,
      "transactionType": transactionType,
      "transactionTitle": transactionTitle,
      "transactionCategory": transactionCategory,
      "transactionAmount": transactionAmount,
      "transactionNote": transactionNote,
      "transactionDate": transactionDate,
      "transactionTime": transactionTime,
    };
  }
}

class CreateAccountModel {
  final int userId;
  final String accountName;
  final double accountBalance;
  final String currency;

  CreateAccountModel({
    required this.userId,
    required this.accountName,
    required this.accountBalance,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "accountName": accountName,
      "accountBalance": accountBalance,
      "currency": currency,
    };
  }
}

class CreateBudgetModel {
  final int userId;
  final String periodType;
  final String startDate;
  final String endDate;
  final double amountLimit;

  CreateBudgetModel({
    required this.userId,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.amountLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "periodType": periodType,
      "startDate": startDate,
      "endDate": endDate,
      "amountLimit": amountLimit,
    };
  }
}

class UpdateBudgetModel {
  final String periodType;
  final String startDate;
  final String endDate;
  final double amountLimit;
  final double spentAmount;

  UpdateBudgetModel({
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.amountLimit,
    required this.spentAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      "periodType": periodType,
      "startDate": startDate,
      "endDate": endDate,
      "amountLimit": amountLimit,
      "spentAmount": spentAmount,
    };
  }
}