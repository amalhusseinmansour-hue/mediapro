import 'package:hive/hive.dart';

part 'wallet_model.g.dart';

@HiveType(typeId: 40)
class Wallet extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  double balance;

  @HiveField(2)
  String currency;

  @HiveField(3)
  DateTime lastUpdated;

  @HiveField(4)
  List<WalletTransaction> transactions;

  Wallet({
    required this.userId,
    this.balance = 0.0,
    this.currency = 'AED',
    required this.lastUpdated,
    List<WalletTransaction>? transactions,
  }) : transactions = transactions ?? [];

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'currency': currency,
      'lastUpdated': lastUpdated.toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      userId: json['userId'],
      balance: (json['balance'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'AED',
      lastUpdated: DateTime.parse(json['lastUpdated']),
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((t) => WalletTransaction.fromJson(t))
              .toList() ??
          [],
    );
  }

  void addTransaction(WalletTransaction transaction) {
    transactions.insert(0, transaction);
    if (transaction.type == 'credit') {
      balance += transaction.amount;
    } else {
      balance -= transaction.amount;
    }
    lastUpdated = DateTime.now();
  }
}

@HiveType(typeId: 41)
class WalletTransaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'credit' or 'debit'

  @HiveField(2)
  double amount;

  @HiveField(3)
  String currency;

  @HiveField(4)
  String description;

  @HiveField(5)
  DateTime timestamp;

  @HiveField(6)
  String? referenceId; // Payment order ID

  @HiveField(7)
  String status; // 'pending', 'completed', 'failed'

  @HiveField(8)
  Map<String, dynamic>? metadata;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.currency = 'AED',
    required this.description,
    required this.timestamp,
    this.referenceId,
    this.status = 'completed',
    this.metadata,
  });

  TransactionType get transactionType {
    return type == 'credit' ? TransactionType.credit : TransactionType.debit;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'currency': currency,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'referenceId': referenceId,
      'status': status,
      'metadata': metadata,
    };
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      type: json['type'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'AED',
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      referenceId: json['referenceId'],
      status: json['status'] ?? 'completed',
      metadata: json['metadata'],
    );
  }
}

enum TransactionType {
  credit,
  debit,
}
