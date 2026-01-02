import 'package:flutter/material.dart';
import 'dart:ui';

/// ويدجت قائمة التفاعل المستقبلية
/// قائمة متطورة مع تأثيرات تفاعلية وحركية متقدمة
class FuturisticInteractiveMenu extends StatefulWidget {
  final List<MenuItemData> items;
  final Function(int) onItemSelected;
  final int selectedIndex;
  final bool isDarkMode;
  final Color accentColor;
  final bool isVertical;

  const FuturisticInteractiveMenu({
    Key? key,
    required this.items,
    required this.onItemSelected,
    this.selectedIndex = 0,
    required this.isDarkMode,
    required this.accentColor,
    this.isVertical = false,
  }) : super(key: key);

  @override
  State<FuturisticInteractiveMenu> createState() => _FuturisticInteractiveMenuState();
}

class _FuturisticInteractiveMenuState extends State<FuturisticInteractiveMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
   List<bool> _hoveredItems = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    
    _controller.forward();
    
    // تهيئة قائمة العناصر التي تم التحويم عليها
    _hoveredItems = List.generate(widget.items.length, (index) => false);
  }

  @override
  void didUpdateWidget(FuturisticInteractiveMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      _hoveredItems.clear();
      _hoveredItems.addAll(List.generate(widget.items.length, (index) => false));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return widget.isVertical
            ? _buildVerticalMenu()
            : _buildHorizontalMenu();
      },
    );
  }

  Widget _buildHorizontalMenu() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: widget.accentColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.items.length, (index) {
              return _buildMenuItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalMenu() {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: widget.accentColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.items.length, (index) {
              return _buildMenuItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index) {
    final isSelected = widget.selectedIndex == index;
    final item = widget.items[index];
    
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredItems[index] = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredItems[index] = false;
        });
      },
      child: GestureDetector(
        onTap: () => widget.onItemSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.accentColor,
                      widget.accentColor.withOpacity(0.7),
                    ],
                  )
                : null,
            color: isSelected
                ? null
                : _hoveredItems[index]
                    ? widget.accentColor.withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // أيقونة العنصر
              Icon(
                item.icon,
                color: isSelected
                    ? Colors.white
                    : _hoveredItems[index]
                        ? widget.accentColor
                        : widget.isDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                size: 24,
              ),
              
              // مؤشر الإشعارات
              if (item.notificationCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      item.notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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

/// نموذج بيانات عنصر القائمة
class MenuItemData {
  final String label;
  final IconData icon;
  final int notificationCount;

  MenuItemData({
    required this.label,
    required this.icon,
    this.notificationCount = 0,
  });
}
