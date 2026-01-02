// import 'package:flutter/material.dart';
// import 'package:simple_animations/simple_animations.dart';

// class AnimatedBackground extends StatelessWidget {
//   final bool isDarkMode;

//   const AnimatedBackground({Key? key, required this.isDarkMode}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDarkMode ? const Color(0xFF2D2F41) : const Color(0xFFF0F0F5),
//       ),
//       child: PlasmaRenderer(
//         type: PlasmaType.bubbles,
//         particles: 10,
//         color: isDarkMode 
//             ? const Color(0xFF6C63FF).withOpacity(0.05)
//             : const Color(0xFF6C63FF).withOpacity(0.03),
//         blur: 0.5,
//         size: 1.0,
//         speed: 0.8,
//         offset: 0,
//         blendMode: BlendMode.plus,
//         variation1: 0,
//         variation2: 0,
//         variation3: 0,
//         rotation: 0,
//       ),
//     );
//   }
// }
