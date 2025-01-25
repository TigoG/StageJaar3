import 'package:flutter/material.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';

class NavigationBar extends StatelessWidget {
  final List<BottomNavigationBarItem> navigationItems;
  final int currentIndex;
  final Function(int) onTap;

  const NavigationBar({
    super.key,
    required this.navigationItems,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get responsive sizes for icons and padding
    final double iconSize = SensibleDefaults.getFontSize(context, baseSize: 48); 
    final double labelFontSize = SensibleDefaults.getFontSize(context, baseSize: 12);
    final double horizontalPadding = SensibleDefaults.getPadding(context) / 2;

    return Container(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navigationItems.length, (index) {
            final item = navigationItems[index];
            final isSelected = index == currentIndex;
            return GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: SensibleDefaults.getPadding(context)),
                  FittedBox(
                    child: Icon(
                      (item.icon as Icon).icon,
                      size: iconSize, // Use responsive icon size
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label ?? '',
                    style: TextStyle(
                      fontSize: labelFontSize, // Use responsive label font size
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                  ),
                  SizedBox(height: SensibleDefaults.getPadding(context)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
