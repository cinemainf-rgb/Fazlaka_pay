import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/colors.dart';

class TabWallets extends StatefulWidget {
  const TabWallets({super.key});

  @override
  State<TabWallets> createState() => _TabWalletsState();
}

class _TabWalletsState extends State<TabWallets> {
  List<Map<String, dynamic>> wallets = [];

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final sp = await SharedPreferences.getInstance();
    final wRaw = sp.getString('pay_wallets');
    if (wRaw != null) {
      setState(() {
        wallets = List<Map<String, dynamic>>.from(jsonDecode(wRaw));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('المحافظ والخزنة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: petrol)),
          const SizedBox(height: 16),
          if (wallets.isEmpty)
            const Center(child: Text('لا توجد محافظ مسجلة')),
          ...wallets.map((w) {
            final name = w['name'];
            final bal = (w['bal'] as num).toDouble();
            final limit = (w['limit'] as num).toDouble();
            final remaining = limit - bal;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: petrol)),
                  const SizedBox(height: 8),
                  Text('الرصيد: $bal', style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (limit > 0) ...[
                    Text('الليميت: $limit — المتبقي: $remaining', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: bal / limit,
                      backgroundColor: bgColor,
                      color: accentColor,
                      minHeight: 6,
                    ),
                  ] else
                    const Text('الليميت: بدون', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
