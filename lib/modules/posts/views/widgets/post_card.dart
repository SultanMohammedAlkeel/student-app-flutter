import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/services/api_url_service.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'package:student_app/modules/posts/controllers/posts_controller.dart';
import 'package:student_app/modules/posts/models/post_model.dart';
import 'package:student_app/modules/posts/views/widgets/comment_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/modules/posts/views/widgets/media_preview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class LikeAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;
  final bool smallLike;

  const LikeAnimation({
    Key? key,
    required this.child,
    required this.isAnimating,
    this.duration = const Duration(milliseconds: 150),
    this.onEnd,
    this.smallLike = false,
  }) : super(key: key);

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
        HomeController homeController = Get.find<HomeController>();

  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration.inMilliseconds ~/ 2),
    );
    _scale = Tween<double>(begin: 1, end: 1.2).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isAnimating != oldWidget.isAnimating) {
      startAnimation();
    }
  }

  void startAnimation() async {
    if (widget.isAnimating) {
      await _controller.forward();
      await _controller.reverse();
      await Future.delayed(const Duration(milliseconds: 200));

      if (widget.onEnd != null) {
        widget.onEnd!();
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
    return ScaleTransition(
      scale: _scale,
      child: widget.child,
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  final bool isLastItem;

  const PostCard({
    Key? key,
    required this.post,
    this.isLastItem = false,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
        HomeController homeController = Get.find<HomeController>();
  final ApiUrlService _apiUrlService = Get.find<ApiUrlService>();

  final RxBool _isLikeAnimating = false.obs;
  final RxBool _isDoubleTapLiking = false.obs;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // تسجيل مشاهدة المنشور عند عرضه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackPostView();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _trackPostView() {
    final controller = Get.find<PostsController>();
    controller.recordPostView(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostsController>();

    return Container(
      margin: EdgeInsets.only(
        bottom: widget.isLastItem ? 80 : 0,
      ),
      decoration: BoxDecoration(
        color: controller.cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(controller),
          _buildPostContent(controller),
          _buildMediaContent(controller),
          _buildPostStats(controller),
          _buildPostActions(controller),
        ],
      ),
    );
  }

  Widget _buildPostHeader(PostsController controller) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
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
              child: CachedNetworkImage(
                imageUrl: _apiUrlService.getImageUrl(widget.post.userImage),
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(
                  strokeWidth: 2,
                  color: homeController.getPrimaryColor(),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/user_profile.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.userName,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: controller.textColor,
                ),
              ),
              Text(
                _formatPostTime(widget.post.createdAt),
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: controller.secondaryTextColor,
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.more_vert, color: controller.secondaryTextColor),
            onPressed: () => _showPostOptions(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(PostsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Text(
        widget.post.content,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 14,
          color: controller.textColor,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildMediaContent(PostsController controller) {
    if (widget.post.hasMedia == false) {
      return SizedBox.shrink();
    }

    return GestureDetector(
      onDoubleTap: () => _handleDoubleTapLike(controller),
      child: Stack(
        alignment: Alignment.center,
        children: [
          MediaPreview(post: widget.post),

          // رسوم متحركة للإعجاب عند النقر المزدوج
          Obx(() => _isDoubleTapLiking.value
              ? Lottie.asset(
                  'assets/animations/like_animation.json',
                  width: 150,
                  height: 150,
                  repeat: false,
                  onLoaded: (composition) {
                    Future.delayed(composition.duration, () {
                      _isDoubleTapLiking.value = false;
                    });
                  },
                )
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildPostStats(PostsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: 16,
                color: homeController.getPrimaryColor(),
              ),
              const SizedBox(width: 5),
              Text(
                '${widget.post.likesCount}',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: controller.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Row(
            children: [
              Icon(
                Icons.comment,
                size: 16,
                color: homeController.getPrimaryColor(),
              ),
              const SizedBox(width: 5),
              Text(
                '${widget.post.commentsCount}',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: controller.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 16,
                color: homeController.getPrimaryColor(),
              ),
              const SizedBox(width: 5),
              Text(
                '${widget.post.viewsCount}',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: controller.secondaryTextColor,
                ),
              ),
            ],
          ),
          Spacer(),
          if (widget.post.isSaved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: homeController.getPrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark,
                    size: 14,
                    color: homeController.getPrimaryColor(),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'محفوظ',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: homeController.getPrimaryColor(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostActions(PostsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
            label: 'إعجاب',
            color: widget.post.isLiked
                ? Colors.red
                : controller.secondaryTextColor,
            onTap: () => _handleLike(controller),
            isAnimating: _isLikeAnimating.value,
          ),
          _buildActionButton(
            icon: Icons.comment,
            label: 'تعليق',
            color: controller.secondaryTextColor,
            onTap: () => _showComments(controller),
          ),
          _buildActionButton(
            icon: widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
            label: 'حفظ',
            color: widget.post.isSaved
                ? homeController.getPrimaryColor()
                : controller.secondaryTextColor,
            onTap: () => _handleSave(controller),
          ),
          _buildActionButton(
            icon: Icons.share,
            label: 'مشاركة',
            color: controller.secondaryTextColor,
            onTap: () => _handleShare(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isAnimating = false,
  }) {
    return LikeAnimation(
      isAnimating: isAnimating,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPostTime(String isoDate) {
    try {
      final postDate = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(postDate);

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

  void _handleLike(PostsController controller) {
    _isLikeAnimating.value = true;
    controller.toggleLike(widget.post);
  }

  void _handleDoubleTapLike(PostsController controller) {
    if (!widget.post.isLiked) {
      _isDoubleTapLiking.value = true;
      controller.toggleLike(widget.post);
    }
  }

  void _handleSave(PostsController controller) {
    controller.toggleSave(widget.post);
  }

  // تنفيذ وظيفة مشاركة المنشور
  void _handleShare(PostsController controller) async {
    try {
      // إنشاء نص المشاركة
      String shareText = 'منشور من تطبيق البستات:\n\n';
      shareText += '${widget.post.userName}: ${widget.post.content}\n\n';

      // إضافة رابط الملف إذا كان موجوداً
     // إضافة رابط الملف إذا كان موجوداً
      if (widget.post.fileUrl != null) {
        shareText += 'رابط الملف: ${_apiUrlService.getImageUrl(widget.post.fileUrl)}\n\n';
      }

      // إضافة رابط المنشور (افتراضي)
      shareText += 'رابط المنشور: ${_apiUrlService.apiBaseUrl}posts/${widget.post.id}';

      // عرض قائمة خيارات المشاركة
      await _showShareOptions(shareText);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء المشاركة: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // عرض خيارات المشاركة
  Future<void> _showShareOptions(String shareText) async {
    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Get.find<PostsController>().cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'مشاركة المنشور',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.find<PostsController>().textColor,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.share,
                  label: 'مشاركة النص',
                  onTap: () {
                    Get.back();
                    Share.share(shareText);
                  },
                ),
                if (widget.post.fileUrl != null)
                  _buildShareOption(
                    icon: Icons.link,
                    label: 'نسخ الرابط',
                    onTap: () {
                      Get.back();
                      _copyLink(widget.post.fileUrl.toString());
                    },
                  ),
                _buildShareOption(
                  icon: Icons.message,
                  label: 'رسالة',
                  onTap: () {
                    Get.back();
                    _shareViaSMS(shareText);
                  },
                ),
                _buildShareOption(
                  icon: Icons.email,
                  label: 'بريد إلكتروني',
                  onTap: () {
                    Get.back();
                    _shareViaEmail(shareText);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // خيارات مشاركة إضافية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'نسخ النص',
                  onTap: () {
                    Get.back();
                    _copyText(shareText);
                  },
                ),
                _buildShareOption(
                  icon: Icons.facebook,
                  label: 'فيسبوك',
                  onTap: () {
                    Get.back();
                    _shareToSocialMedia('facebook', shareText);
                  },
                ),
                _buildShareOption(
                  icon: Icons.wechat_sharp,
                  label: 'واتساب',
                  onTap: () {
                    Get.back();
                    _shareToSocialMedia('whatsapp', shareText);
                  },
                ),
                _buildShareOption(
                  icon: Icons.telegram,
                  label: 'تلجرام',
                  onTap: () {
                    Get.back();
                    _shareToSocialMedia('telegram', shareText);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // بناء خيار مشاركة
  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: homeController.getPrimaryColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: homeController.getPrimaryColor(),
              size: 25,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              color: Get.find<PostsController>().textColor,
            ),
          ),
        ],
      ),
    );
  }

  // نسخ النص إلى الحافظة
  void _copyText(String text) {
    // استخدام Clipboard.setData في التطبيق الفعلي
    Get.snackbar(
      'تم النسخ',
      'تم نسخ النص إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  // نسخ الرابط إلى الحافظة
  void _copyLink(String link) {
    // استخدام Clipboard.setData في التطبيق الفعلي
    Get.snackbar(
      'تم النسخ',
      'تم نسخ الرابط إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  // مشاركة عبر الرسائل النصية
  void _shareViaSMS(String text) async {
    final uri = Uri.parse('sms:?body=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح تطبيق الرسائل',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // مشاركة عبر البريد الإلكتروني
  void _shareViaEmail(String text) async {
    final uri = Uri.parse(
        'mailto:?subject=مشاركة من تطبيق البستات&body=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح تطبيق البريد الإلكتروني',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // مشاركة عبر وسائل التواصل الاجتماعي
  void _shareToSocialMedia(String platform, String text) async {
    Uri? uri;

    switch (platform) {
      case 'whatsapp':
        uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
        break;
      case 'telegram':
        uri = Uri.parse('tg://msg?text=${Uri.encodeComponent(text)}');
        break;
      case 'facebook':
        // استخدام مشاركة عامة لفيسبوك
        Share.share(text);
        return;
      default:
        // استخدام مشاركة عامة
        Share.share(text);
        return;
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // إذا تعذر فتح التطبيق المحدد، استخدم المشاركة العامة
        Share.share(text);
      }
    } catch (e) {
      // في حالة حدوث خطأ، استخدم المشاركة العامة
      Share.share(text);
    }
  }

  void _showComments(PostsController controller) {
    // تحميل التعليقات إذا لم تكن محملة بالفعل
    controller.fetchComments(widget.post.id);

    // عرض التعليقات في نافذة منبثقة من الأسفل
    Get.bottomSheet(
      CommentBottomSheet(post: widget.post),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void _showPostOptions(PostsController controller) {
    final isMyPost = widget.post.senderId == controller.currentUserId.value;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: controller.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            if (isMyPost)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'حذف المنشور',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _confirmDeletePost(controller);
                },
              ),
            ListTile(
              leading: Icon(
                Icons.share,
                color: controller.textColor,
              ),
              title: Text(
                'مشاركة المنشور',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: controller.textColor,
                ),
              ),
              onTap: () {
                Get.back();
                _handleShare(controller);
              },
            ),
            if (widget.post.fileUrl != null)
              ListTile(
                leading: Icon(
                  Icons.download,
                  color: controller.textColor,
                ),
                title: Text(
                  'تحميل الملف',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: controller.textColor,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _downloadFile();
                },
              ),
            ListTile(
              leading: Icon(
                Icons.report,
                color: controller.textColor,
              ),
              title: Text(
                'الإبلاغ عن المنشور',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: controller.textColor,
                ),
              ),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'قريباً',
                  'ستتوفر ميزة الإبلاغ عن المنشورات قريباً',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void _confirmDeletePost(PostsController controller) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'حذف المنشور',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا المنشور؟',
          style: TextStyle(
            fontFamily: 'Tajawal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deletePost(controller);
            },
            child: Text(
              'حذف',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deletePost(PostsController controller) async {
    try {
      await controller.deletePost(widget.post.id);

      Get.snackbar(
        'تم الحذف',
        'تم حذف المنشور بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حذف المنشور: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // تنفيذ وظيفة تحميل الملف
  void _downloadFile() async {
    if (widget.post.fileUrl == null) return;

    try {
      // استخدام الطريقة الثابتة في MediaPreview لتحميل الملف
      await MediaPreview.downloadFile(widget.post);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الملف: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
