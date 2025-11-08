import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

/// Tab item with label and optional icon
class TabItem {
  final String label;
  final IconData? icon;

  const TabItem({
    required this.label,
    this.icon,
  });
}

/// Animated tab switcher with sliding indicator
/// Inspired by modern UI design with smooth animations
class AnimatedTabSwitcher extends StatefulWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final double? height;
  final double? tabWidth;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const AnimatedTabSwitcher({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.height = 84,
    this.tabWidth = 185,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  @override
  State<AnimatedTabSwitcher> createState() => _AnimatedTabSwitcherState();
}

class _AnimatedTabSwitcherState extends State<AnimatedTabSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: widget.selectedIndex.toDouble(),
      end: widget.selectedIndex.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _slideAnimation = Tween<double>(
        begin: _previousIndex.toDouble(),
        end: widget.selectedIndex.toDouble(),
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
      );
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? 
        AppColors.surface.withValues(alpha: 0.5);
    final selectedTextColor = widget.selectedTextColor ?? AppColors.primary;
    final unselectedTextColor = widget.unselectedTextColor ?? 
        AppColors.textSecondary;

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none, // Prevent clipping of shadows and borders
        children: [
          // Animated indicator
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Positioned(
                left: 3 + (_slideAnimation.value * widget.tabWidth!),
                top: 3,
                bottom: 3, // Fix bottom clipping
                child: Container(
                  width: widget.tabWidth! - 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.18),
                        AppColors.primaryLight.withValues(alpha: 0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Tab labels
          Row(
            children: List.generate(
              widget.tabs.length,
              (index) => _buildTabLabel(
                widget.tabs[index],
                index,
                selectedTextColor,
                unselectedTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabLabel(
    TabItem tabItem,
    int index,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final isSelected = widget.selectedIndex == index;
    final hasIcon = tabItem.icon != null;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onTabSelected(index),
        behavior: HitTestBehavior.opaque, // Makes entire container clickable
        child: Container(
          width: widget.tabWidth,
          height: widget.height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasIcon) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    tabItem.icon,
                    size: 18,
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.95)
                        : unselectedColor,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? selectedColor : unselectedColor,
                    letterSpacing: 0.2,
                  ),
                  child: Text(
                    tabItem.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

