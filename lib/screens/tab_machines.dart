import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/colors.dart';

class TabMachines extends StatefulWidget {
  const TabMachines({super.key});

  @override
  State<TabMachines> createState() => _TabMachinesState();
}

class _TabMachinesState extends State<TabMachines> {
  // تصحيح النوع هنا ليكون Map<String, dynamic>
  List<Map<String, dynamic>> wallets = [];
  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> charges = [];
  String selectedMachine = 'فوري رئيسي';
  double cashInDrawer = 0.0;

  // حقول إضافة منتج
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final buyCtrl = TextEditingController();
  final sellCtrl = TextEditingController();

  static const List<String> machineNames = [
    'فوري رئيسي',
    'فوري كروت',
    'فوري كاش أوت',
    'بساطة',
    'موبايل',
    'كاش مصر',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    buyCtrl.dispose();
    sellCtrl.dispose();
    super.dispose();
  }

  double _toDouble(dynamic value, {double fallback = 0.0}) {
    if (value is num && value.isFinite) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null && parsed.isFinite) return parsed;
    }
    return fallback;
  }

  String _formatAmount(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  Future<void> _loadData() async {
    final sp = await SharedPreferences.getInstance();

    // تحميل المحافظ
    final wRaw = sp.getString('pay_wallets');
    if (wRaw != null) {
      try {
        wallets = List<Map<String, dynamic>>.from(jsonDecode(wRaw));
      } catch (_) {
        wallets = [];
      }
    }

    if (wallets.isEmpty) {
      wallets = [
        {'name': 'الخزنة الرئيسية', 'bal': 0.0, 'limit': 0.0},
        {'name': 'نقدية (كاش الدرج)', 'bal': 0.0, 'limit': 0.0},
        {'name': 'إنستاباي', 'bal': 0.0, 'limit': 4000.0},
        {'name': 'فودافون كاش', 'bal': 0.0, 'limit': 2000.0},
        {'name': 'فوري رئيسي', 'bal': 0.0, 'limit': 0.0},
        {'name': 'فوري كروت', 'bal': 0.0, 'limit': 0.0},
        {'name': 'فوري كاش أوت', 'bal': 0.0, 'limit': 0.0},
        {'name': 'بساطة', 'bal': 0.0, 'limit': 0.0},
        {'name': 'موبايل', 'bal': 0.0, 'limit': 0.0},
        {'name': 'كاش مصر', 'bal': 0.0, 'limit': 0.0},
      ];
    }

    // تحميل المبيعات
    final sRaw = sp.getString('pay_sales2');
    if (sRaw != null) {
      try {
        sales = List<Map<String, dynamic>>.from(jsonDecode(sRaw));
      } catch (_) {
        sales = [];
      }
    }

    // تحميل سجل الشحن
    final cRaw = sp.getString('pay_charges');
    if (cRaw != null) {
      try {
        charges = List<Map<String, dynamic>>.from(jsonDecode(cRaw));
      } catch (_) {
        charges = [];
      }
    }

    final cashIndex = wallets.indexWhere((w) => w['name'] == 'نقدية (كاش الدرج)');
    cashInDrawer = cashIndex != -1 ? _toDouble(wallets[cashIndex]['bal']) : 0.0;

    final machinesList = _filteredMachines;
    if (machinesList.isNotEmpty && !machinesList.any((m) => m['name'] == selectedMachine)) {
      selectedMachine = machinesList.first['name'].toString();
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _saveData() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('pay_wallets', jsonEncode(wallets));
    await sp.setString('pay_sales2', jsonEncode(sales));
    await sp.setString('pay_charges', jsonEncode(charges));
  }

  List<Map<String, dynamic>> get _filteredMachines {
    return wallets.where((w) => machineNames.contains(w['name'].toString())).toList();
  }

  double get todaySales {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    double total = 0;
    for (final s in sales) {
      if ((s['date'] ?? '').toString().startsWith(today)) {
        total += _toDouble(s['total']);
      }
    }
    return total;
  }

  double get todayProfit {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    double total = 0;
    for (final s in sales) {
      if ((s['date'] ?? '').toString().startsWith(today)) {
        total += _toDouble(s['profit']);
      }
    }
    return total;
  }

  Future<void> _charge() async {
    final ctrl = TextEditingController();
    final amt = await showDialog<double>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('شحن - $selectedMachine', textAlign: TextAlign.right),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'المبلغ'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(dialogCtx, _toDouble(ctrl.text)), child: const Text('شحن')),
        ],
      ),
    );
    ctrl.dispose();

    if (amt == null || amt <= 0) return;

    final machineIdx = wallets.indexWhere((e) => e['name'] == selectedMachine);
    final cashIdx = wallets.indexWhere((e) => e['name'] == 'نقدية (كاش الدرج)');
    final currentCash = cashIdx != -1 ? _toDouble(wallets[cashIdx]['bal']) : 0.0;

    // التحقق من كفاية الرصيد في الدرج
    if (cashIdx != -1 && currentCash < amt) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رصيد النقدية في الدرج غير كافٍ لإتمام الشحن')),
      );
      return;
    }

    if (machineIdx != -1) {
      wallets[machineIdx]['bal'] = _toDouble(wallets[machineIdx]['bal']) + amt;
    }
    if (cashIdx != -1) {
      wallets[cashIdx]['bal'] = currentCash - amt;
      cashInDrawer = _toDouble(wallets[cashIdx]['bal']);
    }

    charges.insert(0, {
      'machine': selectedMachine,
      'amount': amt,
      'date': DateTime.now().toIso8601String(),
    });

    await _saveData();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم شحن $selectedMachine بمبلغ ${_formatAmount(amt)}')),
    );
  }

  Future<void> _addProduct() async {
    final name = nameCtrl.text.trim();
    final qty = _toDouble(qtyCtrl.text);
    final buy = _toDouble(buyCtrl.text);
    final sell = _toDouble(sellCtrl.text);

    if (name.isEmpty || qty <= 0 || sell <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم المنتج والكمية وسعر البيع بشكل صحيح')),
      );
      return;
    }

    if (buyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تنبيه: تم احتساب سعر الشراء 0 لأن الحقل فارغ')),
      );
    }

    final total = qty * sell;
    final profit = qty * (sell - buy);

    sales.insert(0, {
      'name': name,
      'total': total,
      'profit': profit,
      'date': DateTime.now().toIso8601String(),
    });

    final cashIndex = wallets.indexWhere((e) => e['name'] == 'نقدية (كاش الدرج)');
    if (cashIndex != -1) {
      wallets[cashIndex]['bal'] = _toDouble(wallets[cashIndex]['bal']) + total;
      cashInDrawer = _toDouble(wallets[cashIndex]['bal']);
    }

    nameCtrl.clear();
    qtyCtrl.clear();
    buyCtrl.clear();
    sellCtrl.clear();

    await _saveData();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل العملية بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final machines = _filteredMachines;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _statCard('ربح اليوم', _formatAmount(todayProfit), Colors.amber)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('المبيعات', _formatAmount(todaySales), Colors.green)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _statCard('الديون', '0', Colors.red)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('النقدية (الدرج)', _formatAmount(cashInDrawer), Colors.blue)),
            ],
          ),
          const SizedBox(height: 10),
          _statCard('عدد العمليات', '${sales.length}', petrol, fullWidth: true),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المكن', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: petrol)),
                    Icon(Icons.atm, color: petrol, size: 30),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: machines.map((w) {
                    final name = w['name'].toString();
                    final bal = _toDouble(w['bal']);
                    final isSelected = selectedMachine == name;
                    return GestureDetector(
                      onTap: () => setState(() => selectedMachine = name),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? petrol : bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? petrol : petrol.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : petrol), textAlign: TextAlign.center),
                            const SizedBox(height: 4),
                            Text(_formatAmount(bal), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: _charge,
                        child: const Text('شحن ⚡', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('المبيعات - إضافة منتج', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: petrol)),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: _inputDecoration('اسم المنتج / الموديل')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: qtyCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _inputDecoration('الكمية'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: buyCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _inputDecoration('سعر الشراء'))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: sellCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _inputDecoration('سعر البيع')),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: petrol),
                    onPressed: _addProduct,
                    child: const Text('إضافة منتج', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(right: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: petrol)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
