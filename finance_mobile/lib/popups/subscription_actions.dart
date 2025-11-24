import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../services/home_service.dart';
import '../models/subscription_models.dart';
import '../models/home_models.dart';

class SubscriptionActionsPopup extends StatefulWidget {
  final Subscription subscription;
  final int userId;
  final VoidCallback? onActionCompleted;

  const SubscriptionActionsPopup({
    super.key,
    required this.subscription,
    required this.userId,
    this.onActionCompleted,
  });

  @override
  State<SubscriptionActionsPopup> createState() =>
      _SubscriptionActionsPopupState();
}

class _SubscriptionActionsPopupState extends State<SubscriptionActionsPopup> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final HomeService _homeService = HomeService();

  List<Account> _accounts = [];
  bool _isLoadingAccounts = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _homeService.getAccounts(widget.userId);
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isLoadingAccounts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAccounts = false);
      }
    }
  }

  Future<void> _handlePay() async {
    if (_accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Önce bir hesap ekleyin.")),
      );
      return;
    }

    final selectedAccount = await showDialog<Account>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hangi Hesaptan Ödeme Yapılsın?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _accounts.map((account) {
              final canPay =
                  account.accountBalance >= widget.subscription.monthlyFee;
              return ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  color: canPay ? Colors.green : Colors.red,
                ),
                title: Text(account.accountName),
                subtitle: Text(
                  '₺${account.accountBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: canPay ? Colors.green : Colors.red,
                  ),
                ),
                enabled: canPay,
                onTap: canPay ? () => Navigator.pop(context, account) : null,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );

    if (selectedAccount == null) return;

    try {
      final model = PaySubscriptionModel(
        accountId: selectedAccount.accountId,
        note: '${widget.subscription.subscriptionName} abonelik ödemesi',
      );

      final success = await _subscriptionService.paySubscription(
          widget.subscription.subscriptionId, model);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ödeme başarıyla yapıldı.")),
        );
        widget.onActionCompleted?.call();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ödeme yapılamadı.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  Future<void> _handleSkip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ödemeyi Atla'),
        content: const Text(
            'Bu ay için ödeme atlanacak. Sonraki ödeme tarihi bir ay ileri alınacak. Onaylıyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Atla'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await _subscriptionService
          .skipSubscription(widget.subscription.subscriptionId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ödeme atlandı.")),
        );
        widget.onActionCompleted?.call();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("İşlem yapılamadı.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Aboneliği Sil'),
        content: const Text(
            'Bu aboneliği silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await _subscriptionService
          .deleteSubscription(widget.subscription.subscriptionId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Abonelik silindi.")),
        );
        widget.onActionCompleted?.call();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Silme işlemi başarısız.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 120 : 20,
        vertical: isWideScreen ? 80 : 60,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: isWideScreen ? 500 : double.infinity),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.subscription.isOverdue
                      ? [Colors.orange.shade400, Colors.orange.shade600]
                      : [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.subscription.isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.subscriptions_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subscription.subscriptionName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subscription.subscriptionCategory,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.attach_money,
                            label: "Aylık Ücret",
                            value:
                                "₺${widget.subscription.monthlyFee.toStringAsFixed(2)}",
                            valueColor: Colors.deepPurple,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            label: "Sonraki Ödeme",
                            value: widget.subscription.formattedNextPayment,
                            valueColor: widget.subscription.isOverdue
                                ? Colors.red
                                : Colors.black87,
                          ),
                          if (widget.subscription.isOverdue) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning, size: 20, color: Colors.orange.shade700),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Ödeme tarihi geçmiş!",
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    if (_isLoadingAccounts)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      )
                    else
                      Column(
                        children: [
                          // Pay Button
                          SizedBox(
                            width: double.infinity,
                            height: isWideScreen ? 52 : 48,
                            child: ElevatedButton.icon(
                              onPressed: _handlePay,
                              icon: const Icon(Icons.payment, size: 20),
                              label: const Text(
                                "Ödeme Yap",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Skip Button
                          SizedBox(
                            width: double.infinity,
                            height: isWideScreen ? 52 : 48,
                            child: OutlinedButton.icon(
                              onPressed: _handleSkip,
                              icon: const Icon(Icons.skip_next, size: 20),
                              label: const Text(
                                "Bu Ay İçin Atla",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.orange, width: 2),
                                foregroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Delete Button
                          SizedBox(
                            width: double.infinity,
                            height: isWideScreen ? 52 : 48,
                            child: OutlinedButton.icon(
                              onPressed: _handleDelete,
                              icon: const Icon(Icons.delete_outline, size: 20),
                              label: const Text(
                                "Aboneliği Sil",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red, width: 2),
                                foregroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}