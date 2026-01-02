import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../home/controllers/home_controller.dart';

class ColorPickerWidget extends StatefulWidget {
  final String title;
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color>? onPreview;
  final bool isDarkMode;

  const ColorPickerWidget({
    super.key,
    required this.title,
    required this.color,
    required this.onColorChanged,
    this.onPreview,
    required this.isDarkMode,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color _selectedColor;
  bool _isExpanded = false;

  // Predefined color palette
  final List<Color> _colorPalette = [
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFF6B5B95), // Purple
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFFF44336), // Red
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFFE91E63), // Pink
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF009688), // Teal
    const Color(0xFFCDDC39), // Lime
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF673AB7), // Deep Purple
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(textColor),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isExpanded ? 200 : 0,
          child: _isExpanded ? _buildColorPalette() : null,
        ),
      ],
    );
  }

  Widget _buildHeader(Color textColor) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: widget.isDarkMode ? -1 : 2,
        intensity: 0.6,
        color: widget.isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildColorPreview(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      Text(
                        _getColorHex(_selectedColor),
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.circle(),
        depth: widget.isDarkMode ? -2 : 3,
        intensity: 0.8,
        color: _selectedColor,
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _selectedColor,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    return Neumorphic(
      
      style: NeumorphicStyle(
        
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: widget.isDarkMode ? 2 : -2,
        intensity: 0.6,
        color: widget.isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر لوناً',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8, // المزيد من الأعمدة
                    crossAxisSpacing: 4, // تقليل المسافات
                    mainAxisSpacing: 4,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _colorPalette.length,
                  itemBuilder: (context, index) {
                    final color = _colorPalette[index];
                    final isSelected = _selectedColor.value == color.value;

                    return _buildColorItem(color, isSelected);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildCustomColorButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorItem(Color color, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectColor(color),
      onLongPress: () {
        // Preview color on long press
        if (widget.onPreview != null) {
          widget.onPreview!(color);
        }
      },
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.circle(),
          depth: isSelected ? -3 : 2,
          intensity: 0.8,
          color: color,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border:
                isSelected ? Border.all(color: Colors.white, width: 3) : null,
          ),
          child: isSelected
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCustomColorButton() {
          HomeController homeController = Get.find<HomeController>();

    return SizedBox(
      width: double.infinity,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
          depth: widget.isDarkMode ? -1 : 2,
          intensity: 0.6,
          color: widget.isDarkMode
              ? AppColors.darkBackground
              : AppColors.lightBackground,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showCustomColorPicker,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.palette,
                    size: 20,
                    color: homeController.getPrimaryColor(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'لون مخصص',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: homeController.getPrimaryColor(),
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
    widget.onColorChanged(color);
  }

  void _showCustomColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'اختيار لون مخصص',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hueWheel,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.onColorChanged(_selectedColor);
              Navigator.of(context).pop();
            },
            child: const Text(
              'تطبيق',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }

  String _getColorHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

// Simple color picker implementation
class ColorPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final bool enableAlpha;
  final bool displayThumbColor;
  final PaletteType paletteType;
  final double pickerAreaHeightPercent;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.enableAlpha = true,
    this.displayThumbColor = false,
    this.paletteType = PaletteType.hsv,
    this.pickerAreaHeightPercent = 1.0,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late HSVColor _hsvColor;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.pickerColor);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.cyan,
                Colors.blue,
                Colors.pinkAccent,
                Colors.red,
              ],
            ),
          ),
          child: GestureDetector(
            onPanUpdate: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localOffset =
                  box.globalToLocal(details.globalPosition);
              final double hue = (localOffset.dx / box.size.width) * 360;

              setState(() {
                _hsvColor = _hsvColor.withHue(hue.clamp(0, 360));
              });

              widget.onColorChanged(_hsvColor.toColor());
            },
            child: Container(),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 40,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _hsvColor.toColor(),
            border: Border.all(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

enum PaletteType { hsv, hsl, rgb, hueWheel }
