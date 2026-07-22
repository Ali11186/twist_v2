import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/twist_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isRunning = false;
  int _completedCount = 0;
  int _totalAttempts = 0;
  int _maxAttempts = 4;
  String _status = 'جاهز للبدء';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _runAchievements() async {
    setState(() {
      _isRunning = true;
      _completedCount = 0;
      _totalAttempts = 0;
      _status = 'جاري إنجاز المهام...';
    });

    final service = Provider.of<TwistService>(context, listen: false);

    for (int i = 1; i <= _maxAttempts; i++) {
      setState(() {
        _totalAttempts = i;
        _status = 'المحاولة $i من $_maxAttempts...';
      });

      final completed = await service.completeAchievements();
      setState(() => _completedCount += completed);

      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      _isRunning = false;
      _status = 'تم الانتهاء! ✅';
    });

    if (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('⚡ إنجاز المهام'),
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: RotationTransition(
                  turns: _animationController,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.star, size: 60, color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: Text(
                  _status,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (_isRunning) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: _totalAttempts / _maxAttempts,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF1A1A1A),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF9800),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'التقدم: $_totalAttempts / $_maxAttempts',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: '✅',
                      title: 'تم إنجازه',
                      value: _completedCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: '🔄',
                      title: 'محاولات',
                      value: '$_totalAttempts/$_maxAttempts',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 كيف يعمل',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• سيتم تنفيذ المهام تلقائيًا 4 مرات\n• كل محاولة توفر نقاط إضافية\n• لا تحتاج لفعل شيء، فقط انتظر\n• ستُضاف الكوينز مباشرة إلى حسابك',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB0B0B0),
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isRunning ? null : _runAchievements,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    disabledBackgroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFFFF9800).withOpacity(0.4),
                  ),
                  child: _isRunning
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'ابدأ إنجاز المهام',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const StatCard({
    required this.icon,
    required this.title,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }
}
