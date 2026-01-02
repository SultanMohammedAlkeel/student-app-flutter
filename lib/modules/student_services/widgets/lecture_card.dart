import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class LectureCard extends StatelessWidget {
  final dynamic lecture;
  final bool isDarkMode;
  final VoidCallback onTap;
  final Color textColor;
  final Color secondaryTextColor;

  const LectureCard({
    Key? key,
    required this.lecture,
    required this.isDarkMode,
    required this.onTap,
    required this.textColor,
    required this.secondaryTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: isDarkMode ? -3 : 4,
          intensity: 0.7,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          color: isDarkMode ? const Color(0xFF3E3F58) : const Color(0xFFE4E6F1),
          shadowLightColor: isDarkMode ? Colors.white24 : Colors.white,
          shadowDarkColor: isDarkMode ? Colors.black : Colors.black38,
        ),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                lecture.typeColor.withOpacity(isDarkMode ? 0.1 : 0.05),
                isDarkMode ? const Color(0xFF3E3F58) : const Color(0xFFE4E6F1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lecture.typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      lecture.typeIcon,
                      size: 20,
                      color: lecture.typeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lecture.courseName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontFamily: 'Tajawal',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          lecture.courseCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLectureInfoRow(
                icon: Icons.access_time,
                text: '${_formatTime(lecture.startTime)} - ${_formatTime(lecture.endTime)}',
                color: secondaryTextColor,
              ),
              const SizedBox(height: 8),
              _buildLectureInfoRow(
                icon: Icons.location_on,
                text: lecture.location,
                color: secondaryTextColor,
              ),
              const SizedBox(height: 8),
              _buildLectureInfoRow(
                icon: Icons.person,
                text: lecture.instructorName,
                color: secondaryTextColor,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: lecture.typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lecture.type,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: lecture.typeColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLectureInfoRow({required IconData icon, required String text, required Color color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontFamily: 'Tajawal',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
