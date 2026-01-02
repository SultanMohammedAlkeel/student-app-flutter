import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class NeumorphicFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final NeumorphicStyle? style;

  const NeumorphicFloatingActionButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: style ??
          NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.circle(),
            depth: 8,
          ),
      child: FloatingActionButton(
        onPressed: onPressed,
        child: child,
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}