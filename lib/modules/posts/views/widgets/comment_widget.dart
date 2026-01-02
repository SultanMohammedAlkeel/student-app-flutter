import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:student_app/core/services/api_url_service.dart';

import '../../controllers/posts_controller.dart';
import '../../models/comment_model.dart';
class CommentWidget extends StatelessWidget {
  final Comment comment;

  const CommentWidget({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostsController>();
    final apiUrlService = Get.find<ApiUrlService>(); // Get the ApiUrlService instance

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المستخدم مع معالجة الأخطاء
          Neumorphic(
            style: NeumorphicStyle(
              shape: NeumorphicShape.convex,
              boxShape: NeumorphicBoxShape.circle(),
              color: controller.cardColor,
              depth: 2,
            ),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: _buildUserAvatar(apiUrlService),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Neumorphic(
              style: NeumorphicStyle(
                color: controller.cardColor,
                depth: -3,
                intensity: 0.8,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comment.userName,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: controller.textColor,
                          ),
                        ),
                        Text(
                          _formatTime(comment.createdAt),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 10,
                            color: controller.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.content,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        color: controller.textColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 10,
                        color: controller.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(ApiUrlService apiUrlService) {
    final imageUrl = comment.userImage.startsWith('http')
        ? comment.userImage
        : apiUrlService.getImageUrl(comment.userImage);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.grey[300]),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: Icon(
          Icons.person,
          color: Colors.grey[500],
          size: 24,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now().toLocal();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'قبل $minutes دقيقة${minutes > 1 ? 'ات' : ''}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'قبل $hours ساعة${hours > 1 ? 'ات' : ''}';
    } else if (difference.inDays == 1) {
      return 'بالأمس';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'قبل $days يوم${days > 1 ? 'ات' : ''}';
    } else {
      final formatter = DateFormat('dd/MM/yyyy', 'ar');
      return formatter.format(date);
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}