import 'package:supreme_octo_eureka/Customers/customers_home.dart';
import 'package:supreme_octo_eureka/Customers/customers_profile.dart';
import 'package:supreme_octo_eureka/Customers/customers_search.dart';
import 'package:flutter/material.dart';

// Main Widget for the app, includes tabs management, uses NavigationBar instead of BottomNavigationBar
class CustomersRoot extends StatefulWidget {
  const CustomersRoot({Key? key}) : super(key: key);

  @override
  State<CustomersRoot> createState() => _CustomersRootState();
}

class _CustomersRootState extends State<CustomersRoot> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const HomeTab(),
        SearchTab(),
        const ProfileTab(),
      ][_selectedIndex],
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
