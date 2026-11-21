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
  List<Map<String, dynamic>> wallets = [];
  List<Map<String, dynamic>> sales = [];
  String selectedMachine = 'فوري رئيسي';
  double cashInDrawer = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sp = await SharedPreferences.getInstance();
    final wRaw = sp.getString('pay_wallets');
    if (wRaw != null) {
      wallets = List<Map<String, dynamic>>.from(jsonDecode(wRaw));
    } else {
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
    final sRaw = sp.getString('pay_sales2');
    if (sRaw != null) {
      sales = List<Map<String, dynamic>>.from(jsonDecode(sRaw));
    }
    
    // حساب النقدية في الدرج
    final cashIndex = wallets.indexWhere((w) => w['name'] == 'نقدية (كاش الدرج)');
    if (cashIndex != -1) {
      cashInDrawer = (wallets[cashIndex]['bal'] as num).toDouble();
    }

    setState(() {});
  }

  Future<void> _saveData() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('pay_wallets', jsonEncode(wallets));
    await sp.setString('pay_sales2', jsonEncode(sales));
  }

  double get todaySales {
    final today = DateTime.now().toString().substring(0, 10);
    double t = 0;
    for (final s in sales) {
      if ((s['date'] ?? '').toString().startsWith(today)) {
        t += (s['total'] as num).toDouble();
      }
    }
    return t;
  }

  double get todayProfit {
    final today = DateTime.now().toString().substring(0, 10);
    double t = 0;
    for (final s in sales) {
      if ((s['date'] ?? '').toString().startsWith(today)) {
        t += (s['profit'] as num).toDouble();
      }
    }
    return t;
  }

  // دالة الشحن
  Future<void> _charge() async {
    final c = TextEditingController();
    final amt = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('شحن - $selectedMachine'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'المبلغ'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('الغاء')),
          TextButton(onPressed: () => Navigator.pop(context, double.tryParse(c.text) ?? 0), child: const Text('شحن')),
        ],
      ),
    );
    if (amt != null && amt > 0) {
      setState(() {
        final i = wallets.indexWhere((e) => e['name'] == selectedMachine);
        if (i >= 0) {
          wallets[i]['bal'] = (wallets[i]['bal'] as num).toDouble() + amt;
        }
        sales.insert(0, {
          'name': 'شحن $selectedMachine',
          'total': amt,
          'profit': 0,
          'date': DateTime.now().toString(),
        });
      });
      await _saveData();
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 1. كروت الإحصائيات
          Row(
            children: [
              Expanded(child: _statCard('ربح اليوم', '$todayProfit', Colors.amber)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('المبيعات', '$todaySales', Colors.green)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _statCard('الديون', '0', Colors.red)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('النقدية (الدرج)', '$cashInDrawer', Colors.blue)),
            ],
          ),
          const SizedBox(height: 10),
          _statCard('عدد العمليات', '${sales.length}', petrol, fullWidth: true),
          
          const SizedBox(height: 20),
          
          // 2. شبكة المكن
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
                  children: wallets.where((w) => w['name'].toString().contains('فوري') || w['name'].toString().contains('بساطة') || w['name'].toString().contains('موبايل') || w['name'].toString().contains('كاش مصر')).map((w) {
                    final isSelected = selectedMachine == w['name'];
                    return GestureDetector(
                      onTap: () => setState(() => selectedMachine = w['name']),
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
                            Text(w['name'], style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : petrol), textAlign: TextAlign.center),
                            const SizedBox(height: 4),
                            Text('${w['bal']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
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
          
          // 3. إضافة منتج (مبيعات)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('المبيعات - إضافة منتج', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: petrol)),
                const SizedBox(height: 10),
                TextField(decoration: _inputDecoration('اسم المنتج / الموديل')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(keyboardType: TextInputType.number, decoration: _inputDecoration('الكمية'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(keyboardType: TextInputType.number, decoration: _inputDecoration('سعر الشراء'))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(keyboardType: TextInputType.number, decoration: _inputDecoration('سعر البيع')),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: petrol),
                    onPressed: () {
                      // هنا منطق إضافة المنتج لاحقاً
                    },
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

  // كارت الإحصائيات
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
