// ignore_for_file: avoid_print

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_web/views/connection/connection_list_view.dart';
import 'package:sen_gs_1_web/views/protected/dashboard_view.dart';
import 'package:sen_gs_1_web/views/protected/profile_view.dart';
import 'package:sen_gs_1_web/widgets/selectors/navigation_bar.dart' as custom;
import 'package:sen_gs_1_ca_connector_plugin/constant/trendi_custom_icons.dart';

class MasterLayout extends StatefulWidget {
  const MasterLayout({super.key});

  @override
  State<MasterLayout> createState() => _MasterLayoutState();
}

class _MasterLayoutState extends State<MasterLayout>
    with TickerProviderStateMixin {
  int _selectedIndex = 1;
  int _previousIndex = 1;
  late AnimationController _pageTransitionController;
  late AnimationController _navBarController;
  late Future<String> userId;
  late Future<Map<String, dynamic>?> userInfo;

  @override
  void initState() {
    print("Initializing MasterLayout...");   
    super.initState();

    userId = Amplify.Auth.getCurrentUser().then((user) => user.userId);
    //userInfo = UserService().fetchUserInfo(userId);
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _navBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  List<Widget> _widgetOptions(BuildContext context) => <Widget>[
    const ProfileView(),
    const DashboardView(),
    FutureBuilder<String>(
      future: userId,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ConnectionListView(userId: snapshot.data!);
        } else {
          return const CircularProgressIndicator();
        }
      },
    ),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _previousIndex = _selectedIndex;
        _selectedIndex = index;

        // Trigger the expand/collapse animation for secondary nav bar
        if (_selectedIndex == 2) {
          _navBarController.forward(); // Expand
        } else if (_previousIndex == 2) {
          _navBarController.reverse(); // Collapse
        }
      });
      _pageTransitionController.reset();
      _pageTransitionController.forward();
    }
  }

  Animation<Offset> _getSlideInAnimation() {
    return Tween<Offset>(
      begin: _selectedIndex > _previousIndex
          ? const Offset(1.0, 0.0)
          : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageTransitionController, curve: Curves.easeInOut),
    );
  }

  Animation<double> _getFadeOutAnimation() {
    return Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: _pageTransitionController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),
          SingleChildScrollView(
            child: Column(
              children: [
                custom.NavigationBar(
                  navigationItems: navigationItems(context),
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
                SizeTransition(
                  sizeFactor: _navBarController,
                  axis: Axis.vertical,
                  axisAlignment: -1.0,
                  child: _buildSecondaryNavigationBar(),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      child: Stack(
                        children: [
                          FadeTransition(
                            opacity: _getFadeOutAnimation(),
                            child: _widgetOptions(context)[_previousIndex],
                          ),
                          SlideTransition(
                            position: _getSlideInAnimation(),
                            child: _widgetOptions(context)[_selectedIndex],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryNavigationBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavigationItem(
            imagePath: 'assets/img/trendi_logo.png',
            isSelected: false,
            onTap: () => print("First option clicked!"),
          ),
          _NavigationItem(
            imagePath: 'assets/img/trendi_logo.png',
            isSelected: false,
            onTap: () => print("Second option clicked!"),
          ),
          _NavigationItem(
            imagePath: 'assets/img/trendi_logo.png',
            isSelected: false,
            onTap: () => print("Third option clicked!"),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = MediaQuery.of(context).size.width * 0.1;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              color: isSelected ? Colors.white : Colors.white54,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

List<BottomNavigationBarItem> navigationItems(BuildContext context) => [
  BottomNavigationBarItem(
    icon: Icon(TrendiCustomIcons.user, size: MediaQuery.of(context).size.width * 0.1),
    label: LocalizationService.getString("master", "profile"),
  ),
  BottomNavigationBarItem(
    icon: Icon(TrendiCustomIcons.dashboard, size: MediaQuery.of(context).size.width * 0.1),
    label: LocalizationService.getString("master", "dashboard"),
  ),
  BottomNavigationBarItem(
    icon: Icon(TrendiCustomIcons.connections, size: MediaQuery.of(context).size.width * 0.1),
    label: LocalizationService.getString("master", "connections"),
  ),
];
