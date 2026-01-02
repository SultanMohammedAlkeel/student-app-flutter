import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/services/api_url_service.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/posts/controllers/posts_controller.dart';
import 'package:student_app/modules/posts/models/post_model.dart';
import 'package:student_app/modules/posts/models/comment_model.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../home/controllers/home_controller.dart';

class CommentBottomSheet extends StatefulWidget {
  final Post post;

  const CommentBottomSheet({Key? key, required this.post}) : super(key: key);

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  final RxBool _isSubmitting = false.obs;
  final PostsController _postsController = Get.find<PostsController>();
  final homecontroller = Get.find<HomeController>();

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: _postsController.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(
            child: _buildCommentsList(),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildHeader() {
    HomeController homeController = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'التعليقات',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _postsController.textColor,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: homeController.getPrimaryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.post.commentsCount}',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: homeController.getPrimaryColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: _postsController.secondaryTextColor),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    HomeController homeController = Get.find<HomeController>();

    return Obx(() {
      final comments = _postsController.comments[widget.post.id];

      if (comments == null) {
        return Center(
          child: CircularProgressIndicator(
            color: homeController.getPrimaryColor(),
          ),
        );
      }

      if (comments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/empty_comments.json',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                'لا توجد تعليقات بعد',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: _postsController.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'كن أول من يعلق على هذا المنشور',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: _postsController.secondaryTextColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: comments.length,
        itemBuilder: (context, index) {
          return _buildCommentItem(comments[index]);
        },
      );
    });
  }

  Widget _buildCommentItem(Comment comment) {
    HomeController homeController = Get.find<HomeController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المستخدم
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: homeController.getPrimaryColor().withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _buildUserAvatar(comment.userImage),
            ),
          ),
          const SizedBox(width: 10),
          // محتوى التعليق
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المستخدم والوقت
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _postsController.textColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatCommentTime(comment.createdAt.toIso8601String()),
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: _postsController.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // نص التعليق
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode
                    
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    comment.content,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: _postsController.textColor,
                    ),
                  ),
                ),
                // أزرار التفاعل
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        // سيتم تنفيذ الرد على التعليق لاحقاً
                        Get.snackbar(
                          'قريباً',
                          'ستتوفر ميزة الرد على التعليقات قريباً',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'رد',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: homeController.getPrimaryColor(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    TextButton(
                      onPressed: () {
                        // سيتم تنفيذ الإعجاب بالتعليق لاحقاً
                        Get.snackbar(
                          'قريباً',
                          'ستتوفر ميزة الإعجاب بالتعليقات قريباً',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'إعجاب',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: homeController.getPrimaryColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String imageUrl) {
    final placeholder = Image.asset(
      'assets/images/user_profile.jpg',
      fit: BoxFit.cover,
    );

    if (imageUrl.isEmpty) {
      return placeholder;
    }
// افترض أن _apiUrlService متاح في هذا السياق (مثل متحكم GetX)
final ApiUrlService _apiUrlService = Get.find<ApiUrlService>();

return CachedNetworkImage(
  imageUrl: _apiUrlService.getImageUrl(imageUrl), // استخدام الخدمة هنا
  fit: BoxFit.cover,
  placeholder: (context, url) => placeholder,
  errorWidget: (context, url, error) => placeholder,
);

    // return CachedNetworkImage(
    //   imageUrl: 'http://192.168.1.9:8000/$imageUrl',
    //   fit: BoxFit.cover,
    //   placeholder: (context, url) => placeholder,
    //   errorWidget: (context, url, error) => placeholder,
    // );
  }

  String _formatCommentTime(String isoDate) {
    try {
      final commentDate = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(commentDate);

      if (difference.inSeconds < 60) {
        return 'الآن';
      } else if (difference.inMinutes < 60) {
        return 'قبل ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24) {
        return 'قبل ${difference.inHours} ساعة';
      } else if (difference.inDays == 1) {
        return 'بالأمس';
      } else if (difference.inDays < 7) {
        return 'قبل ${difference.inDays} يوم';
      } else {
        return isoDate.substring(0, 10);
      }
    } catch (e) {
      return 'وقت غير معروف';
    }
  }

  Widget _buildCommentInput() {
    HomeController homeController = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: _postsController.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // صورة المستخدم المصغرة
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: homeController.getPrimaryColor().withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: homecontroller.cachedImage.value != null
                    ? Image.memory(
                        homecontroller.cachedImage.value!,
                        width: 36,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/user_profile.jpg',
                        width: 36,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 10),
            // حقل إدخال التعليق
            Expanded(
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: -3,
                  intensity: 0.7,
                  color: _postsController.cardColor,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                ),
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocus,
                  decoration: InputDecoration(
                    hintText: 'أضف تعليقاً...',
                    hintStyle: TextStyle(
                      fontFamily: 'Tajawal',
                      color: _postsController.secondaryTextColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                  ),
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: _postsController.textColor,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // زر إرسال التعليق
            Obx(
              () => _isSubmitting.value
                  ? SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            homeController.getPrimaryColor()),
                      ),
                    )
                  : NeumorphicButton(
                      style: NeumorphicStyle(
                        color: homeController.getPrimaryColor(),
                        boxShape: NeumorphicBoxShape.circle(),
                      ),
                      onPressed: _submitComment,
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      _commentFocus.requestFocus();
      return;
    }

    try {
      _isSubmitting.value = true;
      await _postsController.addComment(widget.post.id, content);
      _commentController.clear();

      // عرض رسوم متحركة للنجاح
      _showSuccessAnimation();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة التعليق',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  void _showSuccessAnimation() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 150,
          height: 150,
          child: Lottie.asset(
            'assets/animations/comment_success.json',
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(composition.duration, () {
                Get.back();
              });
            },
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
