import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/wallet_model.dart';
import 'auth_service.dart';
import 'payment_service.dart';

class WalletService extends GetxService {
  late AuthService _authService;
  late PaymentService _paymentService;

  late Box<Wallet> _walletBox;
  final Rx<Wallet?> currentWallet = Rx<Wallet?>(null);
  final RxBool isLoading = false.obs;
  final Uuid _uuid = const Uuid();

  Future<WalletService> init() async {
    print('🔷 Initializing WalletService...');

    // Get services after they are initialized
    _authService = Get.find<AuthService>();
    _paymentService = Get.find<PaymentService>();

    // Open Hive box
    _walletBox = await Hive.openBox<Wallet>('wallets');

    // Listen to auth changes
    _authService.currentUser.listen((user) {
      if (user != null) {
        _loadWallet(user.id);
      } else {
        currentWallet.value = null;
      }
    });

    // Load wallet if user is logged in
    if (_authService.currentUser.value != null) {
      await _loadWallet(_authService.currentUser.value!.id);
    }

    print('✅ WalletService initialized');
    return this;
  }

  Future<void> _loadWallet(String userId) async {
    try {
      isLoading.value = true;

      // Check if wallet exists in Hive
      Wallet? wallet = _walletBox.get(userId);

      if (wallet != null) {
        print(
          '✅ Loaded wallet for user: $userId (Balance: ${wallet.balance} ${wallet.currency})',
        );
      } else {
        print('⚠️ No wallet found for user: $userId');
      }

      currentWallet.value = wallet;
    } catch (e) {
      print('❌ Error loading wallet: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> rechargeWallet(double amount) async {
    try {
      final user = _authService.currentUser.value;
      if (user == null) {
        throw Exception('User not logged in');
      }

      isLoading.value = true;

      // Process payment via PaymentService
      final success = await _paymentService.processPayment(
        amount: amount,
        description: 'شحن المحفظة',
        userId: user.id,
        metadata: {
          'userName': user.name,
          'userEmail': user.email,
          'userPhone': user.phoneNumber,
          'currency': 'AED',
        },
      );

      if (success) {
        // Add credit transaction
        final transaction = WalletTransaction(
          id: _uuid.v4(),
          type: 'credit',
          amount: amount,
          currency: 'AED',
          description: 'شحن المحفظة',
          timestamp: DateTime.now(),
          referenceId: DateTime.now().millisecondsSinceEpoch.toString(),
          status: 'completed',
        );

        await addTransaction(transaction);
        print('✅ Wallet recharged successfully: $amount AED');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error recharging wallet: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deductFromWallet(
    double amount,
    String description, {
    String? referenceId,
  }) async {
    try {
      final wallet = currentWallet.value;
      if (wallet == null) {
        throw Exception('No wallet found');
      }

      if (wallet.balance < amount) {
        throw Exception('Insufficient balance');
      }

      final transaction = WalletTransaction(
        id: _uuid.v4(),
        type: 'debit',
        amount: amount,
        currency: 'AED',
        description: description,
        timestamp: DateTime.now(),
        referenceId: referenceId,
        status: 'completed',
      );

      await addTransaction(transaction);
      print('✅ Deducted $amount AED from wallet');
      return true;
    } catch (e) {
      print('❌ Error deducting from wallet: $e');
      return false;
    }
  }

  Future<void> addTransaction(WalletTransaction transaction) async {
    try {
      final wallet = currentWallet.value;
      if (wallet == null) {
        throw Exception('No wallet found');
      }

      wallet.addTransaction(transaction);
      await _walletBox.put(wallet.userId, wallet);
      currentWallet.value = Wallet(
        userId: wallet.userId,
        balance: wallet.balance,
        currency: wallet.currency,
        lastUpdated: wallet.lastUpdated,
        transactions: wallet.transactions,
      );

      print(
        '✅ Transaction added: ${transaction.description} (${transaction.type == 'credit' ? '+' : '-'}${transaction.amount} ${transaction.currency})',
      );
    } catch (e) {
      print('❌ Error adding transaction: $e');
      rethrow;
    }
  }

  List<WalletTransaction> getTransactionsByType(TransactionType type) {
    final wallet = currentWallet.value;
    if (wallet == null) return [];

    return wallet.transactions.where((t) => t.transactionType == type).toList();
  }

  List<WalletTransaction> getRecentTransactions({int limit = 10}) {
    final wallet = currentWallet.value;
    if (wallet == null) return [];

    return wallet.transactions.take(limit).toList();
  }

  double getTotalCredits() {
    final wallet = currentWallet.value;
    if (wallet == null) return 0.0;

    return wallet.transactions
        .where((t) => t.type == 'credit')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalDebits() {
    final wallet = currentWallet.value;
    if (wallet == null) return 0.0;

    return wallet.transactions
        .where((t) => t.type == 'debit')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  bool hasEnoughBalance(double amount) {
    final wallet = currentWallet.value;
    if (wallet == null) return false;
    return wallet.balance >= amount;
  }

  Future<void> clearWallet() async {
    try {
      final user = _authService.currentUser.value;
      if (user != null) {
        await _walletBox.delete(user.id);
        currentWallet.value = null;
        print('✅ Wallet cleared');
      }
    } catch (e) {
      print('❌ Error clearing wallet: $e');
    }
  }

  String formatCurrency(double amount, {String? currency}) {
    final curr = currency ?? 'AED';
    return '${amount.toStringAsFixed(2)} $curr';
  }
}
