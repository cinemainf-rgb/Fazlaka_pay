import 'package:flutter/material.dart';
import '../core/colors.dart';
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
  // التغيير هنا: بنبدأ بتبويب المكن (رقم 0)
  int _currentIndex = 0; 
  
  final List<Widget> _screens = [
    const TabMachines(), // 0 - المكن
    const TabWallets(),  // 1 - المحافظ
    const TabSales(),    // 2 - مبيعات
    const TabReports(),  // 3 - التقارير
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: petrol,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Column(
          children: [
            Text('Fazlaka Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('٢٠٢٦/١١/٢٠', style: TextStyle(fontSize: 12, color: Colors.white70)), 
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
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
            _drawerItem(Icons.atm, 'المكن', () { setState(() { _currentIndex = 0; }); Navigator.pop(context); }),
            _drawerItem(Icons.shopping_cart, 'المبيعات', () { setState(() { _currentIndex = 2; }); Navigator.pop(context); }),
            _drawerItem(Icons.credit_card, 'المحافظ والخزنة', () { setState(() { _currentIndex = 1; }); Navigator.pop(context); }),
            _drawerItem(Icons.bar_chart, 'التقارير', () { setState(() { _currentIndex = 3; }); Navigator.pop(context); }),
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
      body: _screens[_currentIndex],
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
