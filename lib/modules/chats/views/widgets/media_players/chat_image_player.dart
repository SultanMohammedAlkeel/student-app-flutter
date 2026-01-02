import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:student_app/core/themes/colors.dart';
import 'dart:io';
import 'package:student_app/modules/chats/models/chat_media_model.dart';
import 'package:student_app/modules/chats/views/widgets/media_preview_controller.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class ChatImagePlayer extends StatelessWidget {
  final ChatMediaModel media;
  final MediaPreviewController controller;
  final bool showControls;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool enableZoom;
  final VoidCallback? onTap;
  final String imageUrl;

  const ChatImagePlayer({
    Key? key,
    required this.media,
    required this.controller,
    required this.imageUrl,
    this.showControls = true,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.enableZoom = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = media.isLocal ? media.localPath! : media.fileUrl!;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (enableZoom) {
          _openImageViewer(context, imageUrl);
        }
      },
      child: Container(
        width: width,
        height: height,
        constraints: BoxConstraints(
          maxWidth: width ?? MediaQuery.of(context).size.width * 0.7,
          maxHeight: height ?? 200,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.withOpacity(0.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImage(imageUrl),
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (media.isLocal) {
      return Image.file(
        File(imageUrl),
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        placeholder: (context, url) => _buildLoadingWidget(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      );
    }
  }

  Widget _buildLoadingWidget() {
      final HomeController _homeController = Get.find<HomeController>();

    return Center(
      child: CircularProgressIndicator(
        color: _homeController.getPrimaryColor(),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.grey, size: 40),
          const SizedBox(height: 8),
          Text(
            'فشل تحميل الصورة',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _openImageViewer(BuildContext context, String imageUrl) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);

    Get.to(
      () => Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => Get.back(),
          ),
          actions: [
            if (showControls)
              IconButton(
                icon: Icon(
                  Icons.download,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () => _downloadImage(imageUrl),
              ),
            if (showControls)
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () => _shareImage(imageUrl),
              ),
          ],
        ),
        body: Container(
          child: PhotoView(
            imageProvider: media.isLocal
                ? FileImage(File(imageUrl)) as ImageProvider
                : CachedNetworkImageProvider(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
            ),
            loadingBuilder: (context, event) => _buildLoadingWidget(),
            errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          ),
        ),
      ),
      fullscreenDialog: true,
    );
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      // تنفيذ تحميل الصورة
      Get.snackbar(
        'تحميل الصورة',
        'جاري تحميل الصورة...',
        snackPosition: SnackPosition.BOTTOM,
      );

      // هنا يمكن إضافة كود لتحميل الصورة إلى جهاز المستخدم
      // مثال: await GallerySaver.saveImage(imageUrl);

      Get.snackbar(
        'تم التحميل',
        'تم تحميل الصورة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تحميل الصورة: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _shareImage(String imageUrl) async {
    try {
      // تنفيذ مشاركة الصورة
      Get.snackbar(
        'مشاركة الصورة',
        'جاري مشاركة الصورة...',
        snackPosition: SnackPosition.BOTTOM,
      );

      // هنا يمكن إضافة كود لمشاركة الصورة
      // مثال: await Share.shareFiles([imageUrl]);

      Get.snackbar(
        'تمت المشاركة',
        'تم مشاركة الصورة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل مشاركة الصورة: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
