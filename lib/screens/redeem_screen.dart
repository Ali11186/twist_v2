import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/twist_service.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  int _balance = 0;
  bool _isLoadingBalance = true;
  int? _selectedIndex;
  bool _isRedeeming = false;

  final List<RedeemPackage> _packages = [
    RedeemPackage(cost: 100, units: 50, code: 'EAND_50_UNITS_ID_9', bestValue: false),
    RedeemPackage(cost: 200, units: 100, code: 'EAND_100_UNITS_ID_10', bestValue: false),
    RedeemPackage(cost: 300, units: 150, code: 'EAND_150_UNITS_ID_11', bestValue: false),
    RedeemPackage(cost: 600, units: 300, code: 'EAND_300_UNITS_ID_12', bestValue: true),
    RedeemPackage(cost: 1000, units: 500, code: 'EAND_500_UNITS_ID_13', bestValue: false),
    RedeemPackage(cost: 2000, units: 1000, code: 'EAND_1000_UNITS_ID_14', bestValue: false),
  ];

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    setState(() => _isLoadingBalance = true);
    final service = Provider.of<TwistService>(context, listen: false);
    final balance = await service.getBalance();
    setState(() {
      _balance = balance;
      _isLoadingBalance = false;
    });
  }

  Future<void> _redeemPackage(RedeemPackage package) async {
    if (_balance < package.cost) {
      _showError('الرصيد غير كافٍ');
      return;
    }

    setState(() => _isRedeeming = true);

    final service = Provider.of<TwistService>(context, listen: false);
    final success = await service.redeemUnits(package.code);

    setState(() => _isRedeeming = false);

    if (success) {
      _showSuccessDialog(package);
      await Future.delayed(const Duration(seconds: 2));
      _fetchBalance();
    } else {
      _showError('فشل الاستبدال، حاول مجددًا');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  void _showSuccessDialog(RedeemPackage package) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Color(0xFFFF9800),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '✅ تم الاستبدال بنجاح!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${package.units} وحدة موسيقية',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFB0B0B0),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '- ${package.cost} كوينز',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFF9800),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'حسنًا',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availablePackages = _packages.where((p) => _balance >= p.cost).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('🎁 استبدال الكوينز'),
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'رصيد الكوينز المتاح',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingBalance)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Text(
                            '$_balance كوينز',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFFFF9800)),
                      onPressed: _fetchBalance,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'الباقات المتاحة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              if (availablePackages.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: const Center(
                    child: Text(
                      '⚠️ لا توجد باقات متاحة لرصيدك الحالي',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: availablePackages.length,
                  itemBuilder: (context, index) {
                    final package = availablePackages[index];
                    final isSelected = _selectedIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PackageCard(
                        package: package,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedIndex = isSelected ? null : index);
                        },
                        onRedeem: () => _redeemPackage(package),
                        isRedeemingGlobal: _isRedeeming,
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class RedeemPackage {
  final int cost;
  final int units;
  final String code;
  final bool bestValue;

  RedeemPackage({
    required this.cost,
    required this.units,
    required this.code,
    required this.bestValue,
  });

  double get valueRatio => units / cost;
}

class PackageCard extends StatelessWidget {
  final RedeemPackage package;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRedeem;
  final bool isRedeemingGlobal;

  const PackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
    required this.onRedeem,
    required this.isRedeemingGlobal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A1A1A).withOpacity(0.8) : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF9800) : const Color(0xFF333333),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${package.units} وحدة 🎵',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تكلفة ${package.cost} كوينز',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB0B0B0),
                        ),
                      ),
                    ],
                  ),
                  if (package.bestValue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '⭐ الأفضل',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isRedeemingGlobal ? null : onRedeem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      disabledBackgroundColor: Colors.grey.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isRedeemingGlobal
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'استبدل الآن',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
