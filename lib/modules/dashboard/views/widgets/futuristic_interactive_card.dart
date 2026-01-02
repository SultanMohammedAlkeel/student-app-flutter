import 'package:flutter/material.dart';
import 'dart:ui';

/// ويدجت بطاقة المعلومات التفاعلية المستقبلية
/// بطاقة متطورة مع تأثيرات تفاعلية وحركية متقدمة
class FuturisticInteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color accentColor;
  final bool isDarkMode;
  final double borderRadius;
  final bool isGlowing;
  final bool isExpandable;
  final String? expandedTitle;
  final Widget? expandedContent;

  const FuturisticInteractiveCard({
    Key? key,
    required this.child,
    this.onTap,
    required this.accentColor,
    required this.isDarkMode,
    this.borderRadius = 20,
    this.isGlowing = false,
    this.isExpandable = false,
    this.expandedTitle,
    this.expandedContent,
  }) : super(key: key);

  @override
  State<FuturisticInteractiveCard> createState() => _FuturisticInteractiveCardState();
}

class _FuturisticInteractiveCardState extends State<FuturisticInteractiveCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    
    _glowAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.isGlowing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FuturisticInteractiveCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGlowing != oldWidget.isGlowing) {
      if (widget.isGlowing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) {
            setState(() {
              _isHovered = true;
            });
          },
          onExit: (_) {
            setState(() {
              _isHovered = false;
              _isPressed = false;
            });
          },
          child: GestureDetector(
            onTapDown: (_) {
              setState(() {
                _isPressed = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                _isPressed = false;
              });
              if (widget.isExpandable) {
                _toggleExpanded();
              } else if (widget.onTap != null) {
                widget.onTap!();
              }
            },
            onTapCancel: () {
              setState(() {
                _isPressed = false;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..scale(_isPressed ? 0.98 : (_isHovered ? 1.02 : 1.0)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accentColor.withOpacity(0.2),
                    widget.accentColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.accentColor.withOpacity(_isHovered ? 0.5 : 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(
                      widget.isGlowing ? 0.3 * _glowAnimation.value : (_isHovered ? 0.3 : 0.1),
                    ),
                    blurRadius: widget.isGlowing ? 15 * _glowAnimation.value : (_isHovered ? 15 : 5),
                    spreadRadius: widget.isGlowing ? 2 * _glowAnimation.value : (_isHovered ? 2 : 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // المحتوى الأساسي
                        widget.child,
                        
                        // المحتوى الموسع
                        if (widget.isExpandable && widget.expandedContent != null)
                          SizeTransition(
                            sizeFactor: _expandAnimation,
                            child: Column(
                              children: [
                                if (widget.expandedTitle != null) ...[
                                  Divider(
                                    color: widget.accentColor.withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          widget.expandedTitle!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: widget.isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.keyboard_arrow_up,
                                          color: widget.accentColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                widget.expandedContent!,
                              ],
                            ),
                          ),
                        
                        // مؤشر التوسيع
                        if (widget.isExpandable && !_isExpanded && widget.expandedContent != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 30,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: widget.accentColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
