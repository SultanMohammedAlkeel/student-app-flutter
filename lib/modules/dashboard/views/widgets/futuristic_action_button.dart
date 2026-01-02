import 'package:flutter/material.dart';
import 'dart:ui';

/// ويدجت زر التفاعل المستقبلي
/// زر متطور مع تأثيرات تفاعلية وحركية متقدمة
class FuturisticActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDarkMode;
  final bool isExpanded;
  final bool isGlowing;

  const FuturisticActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDarkMode,
    this.isExpanded = false,
    this.isGlowing = false,
  }) : super(key: key);

  @override
  State<FuturisticActionButton> createState() => _FuturisticActionButtonState();
}

class _FuturisticActionButtonState extends State<FuturisticActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // ignore: unused_field
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    if (widget.isGlowing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FuturisticActionButton oldWidget) {
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
              widget.onPressed();
            },
            onTapCancel: () {
              setState(() {
                _isPressed = false;
              });
            },
            child: Transform.scale(
              scale: _isPressed ? 0.95 : (_isHovered ? 1.05 : 1.0),
              child: Container(
                height: 56,
                width: widget.isExpanded ? double.infinity : null,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.primaryColor,
                      widget.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(
                        widget.isGlowing ? 0.5 * _glowAnimation.value : (_isHovered ? 0.5 : 0.3),
                      ),
                      blurRadius: widget.isGlowing ? 15 * _glowAnimation.value : (_isHovered ? 15 : 10),
                      spreadRadius: widget.isGlowing ? 2 * _glowAnimation.value : (_isHovered ? 2 : 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.primaryColor.withOpacity(_isPressed ? 0.9 : 1.0),
                            widget.secondaryColor.withOpacity(_isPressed ? 0.9 : 1.0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
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
