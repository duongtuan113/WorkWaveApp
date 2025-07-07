import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<String> _routes = [
    '/', // Home
    '/project',
    '/allWork',
    '/notifications', // Notifications (giờ là index 3)
  ];

  void _onItemTapped(int index) {
    if (index < _routes.length && index != _selectedIndex) {
      context.go(_routes[index]);
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location =
        GoRouter.of(context).routeInformationProvider.value.location;
    final index = _routes.indexWhere((route) => location.startsWith(route));
    if (index != -1 && index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.grey[200],
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey[500],
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Project'),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt), label: 'All work'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Notifications'),
          ],
        ),
      ),
    );
  }
}
