// Goal Model
class Goal {
  final int goalId;
  final int userId;
  final String goalType;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final String startDate;
  final String endDate;

  Goal({
    required this.goalId,
    required this.userId,
    required this.goalType,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
  });

  // Progress hesaplama
  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  
  // Kalan gün hesaplama
  int get daysRemaining {
    try {
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      final difference = end.difference(now).inDays;
      return difference > 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  // Status
  String get status {
    if (daysRemaining == 0) return "Süre doldu";
    if (daysRemaining < 7) return "$daysRemaining gün kaldı";
    if (daysRemaining < 30) return "${(daysRemaining / 7).ceil()} hafta kaldı";
    return "${(daysRemaining / 30).ceil()} ay kaldı";
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      goalId: json['goalId'],
      userId: json['userId'],
      goalType: json['goalType'],
      goalName: json['goalName'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }
}

// Create Goal Model
class CreateGoalModel {
  final int userId;
  final String goalType;
  final String goalName;
  final double targetAmount;
  final String startDate;
  final String endDate;

  CreateGoalModel({
    required this.userId,
    required this.goalType,
    required this.goalName,
    required this.targetAmount,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "goalType": goalType,
      "goalName": goalName,
      "targetAmount": targetAmount,
      "startDate": startDate,
      "endDate": endDate,
    };
  }
}

// Update Goal Model
class UpdateGoalModel {
  final String goalType;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final String startDate;
  final String endDate;

  UpdateGoalModel({
    required this.goalType,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      "goalType": goalType,
      "goalName": goalName,
      "targetAmount": targetAmount,
      "currentAmount": currentAmount,
      "startDate": startDate,
      "endDate": endDate,
    };
  }
}

// Contribute to Goal Model
class ContributeToGoalModel {
  final int accountId;
  final double amount;
  final String? note;

  ContributeToGoalModel({
    required this.accountId,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      "accountId": accountId,
      "amount": amount,
      "note": note,
    };
  }
}