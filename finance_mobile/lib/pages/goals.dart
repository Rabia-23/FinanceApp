import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../popups/add_goal.dart';
import '../services/goal_service.dart';
import '../services/user_service.dart';
import '../models/goal_models.dart';
import '../popups/contribute_to_goal.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final GoalService _service = GoalService();
  final ApiService _apiService = ApiService();

  List<Goal> _goals = [];
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final userIdStr = await _apiService.getUserId();
      if (userIdStr == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
        return;
      }

      _userId = int.parse(userIdStr);
      final goals = await _service.getGoals(_userId!);

      if (mounted) {
        setState(() {
          _goals = goals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _deleteGoal(int goalId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hedefi Sil'),
        content: const Text('Bu hedefi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _service.deleteGoal(goalId);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hedef silindi')),
          );
          _loadGoals();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
  }

  void _logout() async {
    await _apiService.deleteToken();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  IconData _getIconForGoalType(String goalType) {
    if (goalType.toLowerCase().contains('tasarruf')) return Icons.savings_outlined;
    if (goalType.toLowerCase().contains('yatırım')) return Icons.trending_up_rounded;
    if (goalType.toLowerCase().contains('borç')) return Icons.credit_card_off;
    return Icons.flag_outlined;
  }

  Color _getColorForGoalType(String goalType) {
    if (goalType.toLowerCase().contains('tasarruf')) return Colors.green;
    if (goalType.toLowerCase().contains('yatırım')) return Colors.blue;
    if (goalType.toLowerCase().contains('borç')) return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb && MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: isWeb ? _buildWebContent() : _buildMobileLayout(),
    );
  }

  // WEB CONTENT (Sidebar yok, sadece içerik)
  Widget _buildWebContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              const Text(
                "Hedefler",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  if (_userId != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AddGoalPopup(
                        userId: _userId!,
                        onGoalAdded: _loadGoals,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 20, color: Colors.white),
                label: const Text("Yeni Hedef", style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),

        // Content Area
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _goals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flag_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            "Henüz hedef eklenmemiş",
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Yeni bir hedef eklemek için üstteki butona tıklayın",
                            style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 1.3,
                            ),
                            itemCount: _goals.length,
                            itemBuilder: (context, index) {
                              return _buildWebGoalCard(_goals[index]);
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // MOBILE LAYOUT
  Widget _buildMobileLayout() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ÜST BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, color: Colors.deepPurple),
                        SizedBox(width: 6),
                        Text(
                          "Finans Takip",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_outlined, size: 16),
                      label: const Text("Çıkış"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // NAV BAR
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _navButton(
                        context,
                        icon: Icons.home_outlined,
                        label: "Ana Sayfa",
                        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                      ),
                      _navButton(
                        context,
                        icon: Icons.receipt_long_outlined,
                        label: "İşlemler",
                        onTap: () => Navigator.pushNamed(context, '/transactions'),
                      ),
                      _navButton(
                        context,
                        icon: Icons.subscriptions_outlined,
                        label: "Abonelikler",
                        onTap: () => Navigator.pushNamed(context, '/subscriptions'),
                      ),
                      _navButton(
                        context,
                        icon: Icons.flag_outlined,
                        label: "Hedefler",
                        isActive: true,
                        onTap: () {},
                      ),
                      _navButton(
                        context,
                        icon: Icons.monetization_on_outlined,
                        label: "Currency",
                        onTap: () => Navigator.pushNamed(context, '/currency'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Hedefler",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_userId != null) {
                          showDialog(
                            context: context,
                            builder: (context) => AddGoalPopup(
                              userId: _userId!,
                              onGoalAdded: _loadGoals,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Hedef Ekle"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Goals List
                Expanded(
                  child: _goals.isEmpty
                      ? const Center(
                          child: Text(
                            "Henüz hedef eklenmemiş.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _goals.length,
                          itemBuilder: (context, index) {
                            return _buildMobileGoalCard(_goals[index]);
                          },
                        ),
                ),
              ],
            ),
          );
  }

  // WEB GOAL CARD
  Widget _buildWebGoalCard(Goal goal) {
    final icon = _getIconForGoalType(goal.goalType);
    final color = _getColorForGoalType(goal.goalType);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ContributeToGoalPopup(
            goal: goal,
            userId: _userId!,
            onContributed: _loadGoals,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _deleteGoal(goal.goalId),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Goal Name
            Text(
              goal.goalName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              goal.goalType,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: Colors.grey[200],
                color: color,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),

            // Progress Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₺${goal.currentAmount.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "${(goal.progress * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Hedef: ₺${goal.targetAmount.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MOBILE GOAL CARD
  Widget _buildMobileGoalCard(Goal goal) {
    final icon = _getIconForGoalType(goal.goalType);
    final color = _getColorForGoalType(goal.goalType);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ContributeToGoalPopup(
            goal: goal,
            userId: _userId!,
            onContributed: _loadGoals,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      goal.goalName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _deleteGoal(goal.goalId),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              goal.goalType,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: Colors.grey[300],
                color: Colors.black,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₺${goal.currentAmount.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Text(
                  "₺${goal.targetAmount.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "%${(goal.progress * 100).toInt()} tamamlandı\n${goal.status}",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MOBILE NAV BUTTON
  Widget _navButton(BuildContext context,
      {required IconData icon,
      required String label,
      bool isActive = false,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isActive ? Colors.white : Colors.black87),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}