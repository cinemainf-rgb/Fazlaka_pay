import 'package:flutter/material.dart';
import '../core/colors.dart';

// استيراد الشاشات (اللي هنعملها فاضية دلوقتي)
import 'tab_machines.dart';
import 'tab_wallets.dart';
import 'tab_sales.dart';
import 'tab_reports.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 3; // نبدأ بتبويب المكن زي الصورة
  
  // قائمة الشاشات
  final List<Widget> _screens = [
    const TabMachines(), // 0
    const TabWallets(),  // 1
    const TabSales(),    // 2
    const TabReports(),  // 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. الشريط العلوي
      appBar: AppBar(
        backgroundColor: petrol,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Column(
          children: [
            Text('Fazlaka Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('٢٠٢٦/١١/٢٠', style: TextStyle(fontSize: 12, color: Colors.white70)), // التاريخ (هيتحدث بعدين)
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),

      // 2. القائمة الجانبية (Drawer)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: petrol),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('القائمة', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('FAZLAKA PAY PRO', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            _drawerItem(Icons.atm, 'المكن', () {}),
            _drawerItem(Icons.shopping_cart, 'المبيعات', () {}),
            _drawerItem(Icons.credit_card, 'المحافظ والخزنة', () {}),
            _drawerItem(Icons.bar_chart, 'التقارير', () {}),
            const Divider(),
            _drawerItem(Icons.settings, 'الإعدادات', () {}),
            _drawerItem(Icons.share, 'مشاركة واتساب', () {}),
            _drawerItem(Icons.file_download, 'تصدير JSON', () {}),
            _drawerItem(Icons.file_upload, 'استيراد', () {}),
            _drawerItem(Icons.construction, 'وضع الصيانة', () {}),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.red),
              title: const Text('قفل البرنامج', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),

      // 3. محتوى الشاشة
      body: _screens[_currentIndex],

      // 4. التبويبات السفلية
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: petrol,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.atm), label: 'المكن'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'المحافظ'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'مبيعات'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
        ],
      ),
      
      // 5. الزر العائم
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: petrol),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }
}
