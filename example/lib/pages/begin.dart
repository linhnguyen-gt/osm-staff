import 'package:flutter/material.dart';
import 'package:flutter_map_example/pages/home.dart';
import 'package:flutter_map_example/pages/home_2.dart';
import 'package:flutter_map_example/pages/profile_screen.dart';
import 'package:flutter_svg/svg.dart';

class BeginPage extends StatefulWidget {
  static const String route = '/begin';

  const BeginPage({super.key});

  @override
  State<BeginPage> createState() => _BeginState();
}

class _BeginState extends State<BeginPage> {
  int _selectedIndex = 0;
  List<int> loadedPages = [0];

  void _onItemTapped(int index) {
    final pages = loadedPages;
    if (!pages.contains(index)) {
      pages.add(index);
    }
    setState(() {
      _selectedIndex = index;
      loadedPages = pages;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const Home2Page(),
      loadedPages.contains(1) ? const HomePage() : Container(),
      loadedPages.contains(2) ? const ProfileScreen() : Container(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/bottom_navigator/ic_home.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/bottom_navigator/ic_home.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/bottom_navigator/ic_map.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/bottom_navigator/ic_map.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/bottom_navigator/ic_profile.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(
                'assets/bottom_navigator/ic_profile.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
