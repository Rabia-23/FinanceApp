class Subscription {
  final int subscriptionId;
  final int userId;
  final String subscriptionName;
  final String subscriptionCategory;
  final double monthlyFee;
  final int paymentDay;
  final String nextPaymentDate;
  final bool isOverdue;

  Subscription({
    required this.subscriptionId,
    required this.userId,
    required this.subscriptionName,
    required this.subscriptionCategory,
    required this.monthlyFee,
    required this.paymentDay,
    required this.nextPaymentDate,
    required this.isOverdue,
  });

  String get formattedNextPayment {
    try {
      final date = DateTime.parse(nextPaymentDate);
      const months = [
        'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
      ];
      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return '';
    }
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      subscriptionId: json['subscriptionId'],
      userId: json['userId'],
      subscriptionName: json['subscriptionName'],
      subscriptionCategory: json['subscriptionCategory'],
      monthlyFee: (json['monthlyFee'] as num).toDouble(),
      paymentDay: json['paymentDay'],
      nextPaymentDate: json['nextPaymentDate'],
      isOverdue: json['isOverdue'] ?? false,
    );
  }
}

class CreateSubscriptionModel {
  final int userId;
  final String subscriptionName;
  final String subscriptionCategory;
  final double monthlyFee;
  final int paymentDay;

  CreateSubscriptionModel({
    required this.userId,
    required this.subscriptionName,
    required this.subscriptionCategory,
    required this.monthlyFee,
    required this.paymentDay,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "subscriptionName": subscriptionName,
      "subscriptionCategory": subscriptionCategory,
      "monthlyFee": monthlyFee,
      "paymentDay": paymentDay,
    };
  }
}

class UpdateSubscriptionModel {
  final String subscriptionName;
  final String subscriptionCategory;
  final double monthlyFee;
  final int paymentDay;

  UpdateSubscriptionModel({
    required this.subscriptionName,
    required this.subscriptionCategory,
    required this.monthlyFee,
    required this.paymentDay,
  });

  Map<String, dynamic> toJson() {
    return {
      "subscriptionName": subscriptionName,
      "subscriptionCategory": subscriptionCategory,
      "monthlyFee": monthlyFee,
      "paymentDay": paymentDay,
    };
  }
}

class PaySubscriptionModel {
  final int accountId;
  final String? note;

  PaySubscriptionModel({
    required this.accountId,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      "accountId": accountId,
      "note": note,
    };
  }
}