// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:student_app/core/network/api_service.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/modules/chats/models/chat_model.dart';
import 'package:student_app/modules/chats/models/message_model.dart';
import 'package:student_app/modules/chats/repositories/chat_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'package:icons_plus/icons_plus.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatController extends GetxController {
  final ChatRepository repository = Get.find<ChatRepository>();
  final StorageService _storage = Get.find<StorageService>();
  final RxInt currentCategoryIndex = 0.obs;
  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxList<ChatModel> filteredChats = <ChatModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController messageController = TextEditingController();
  final RxBool isEmojiVisible = false.obs;
  final FocusNode focusNode = FocusNode();
  final RxList<dynamic> availableUsers = <dynamic>[].obs;
  final RxBool isLoadingUsers = false.obs;
  final RxString selectedUserType = ''.obs;
  final RxInt selectedCollegeId = 0.obs;
  final RxInt selectedDepartmentId = 0.obs;
  final RxString selectedLevel = ''.obs;

  // إنشاء وحدات تحكم منفصلة للتمرير
  final ScrollController chatListScrollController = ScrollController();
  final ScrollController messagesScrollController = ScrollController();
  final RxBool showScrollToBottomButton = false.obs;
  final RxBool isAtBottom = true.obs;

  //search in messages controllers
  final RxString searchText = ''.obs;
  final RxList<MessageModel> searchMessagesResults = <MessageModel>[].obs;
  final RxInt currentSearchIndex = (-1).obs;

  final RxBool showOptions = false.obs;
  final RxBool isScrolling = false.obs;
  final Rx<DateTime> lastScrollTime = DateTime.now().obs;
  final RxBool isSearching = false.obs;
  final RxList<ChatModel> searchResults = <ChatModel>[].obs;
  final RxBool showFabMenu = false.obs;

  // متغيرات للوسائط
  final RxBool isRecording = false.obs;
  final RxString recordingPath = ''.obs;
  final RxDouble recordingDuration = 0.0.obs;
  final RxBool isAttachmentSelected = false.obs;
  final RxBool isContainText = false.obs;
  final RxBool isKeabordTap = false.obs;
  final Rx<File?> selectedFile = Rx<File?>(null);
  final RxString selectedFileType = ''.obs;
  final RxString selectedFilePath = ''.obs;
  final RxBool isSending = false.obs;
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // --- New Variables for Emoji Animation ---
  final RxInt currentEmojiIconIndex = 0.obs;
  Timer? _emojiAnimationTimer;
  Timer? _emojiAnimationStopTimer;

  // List of icons for animation (User's + 3 chosen)
  final List<IconData> emojiAnimationIcons = [
    Bootstrap.emoji_wink,
    Bootstrap.emoji_astonished,
    Bootstrap.emoji_grin,
    Bootstrap.emoji_kiss,
    Iconsax.emoji_happy_outline,
    FontAwesome.person_running_solid,
    Bootstrap.emoji_heart_eyes, // Chosen 1
    Bootstrap.emoji_laughing, // Chosen 2
    Bootstrap.emoji_sunglasses, // Chosen 3 (intended to be animated)
  ];

  // متغيرات للرد على الرسائل
  final Rx<MessageModel?> replyToMessage = Rx<MessageModel?>(null);

  // مسجل الصوت - تصحيح الاستخدام
  final _audioRecorder = AudioRecorder();

  @override
  void onInit() {
    super.onInit();
    loadChats();

    messagesScrollController.addListener(_scrollListener);
    startEmojiAnimation(); // Start the animation

    debounce(searchQuery, (_) => filterChats(), time: 300.milliseconds);
  }

  @override
  void onClose() {
    audioPlayer.dispose(); // تحرير الموارد عند إغلاق الكونترولر
    stopEmojiAnimation(); // Stop animation timers
    _audioPlayer.dispose();

    _audioRecorder.dispose();
    messageController.dispose();
    chatListScrollController.dispose();
    messagesScrollController.dispose();
    super.onClose();
  }

  Future<void> loadChats() async {
    try {
      isLoading(true);
      final result = await repository.getChats();
      chats.assignAll(result);
      filterChats();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المحادثات: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }
  }

  void toggleEmojiKeyboard() {
    isEmojiVisible.toggle();

    if (!isEmojiVisible.value) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
    }
  }

  // --- New Methods for Emoji Animation ---
  void startEmojiAnimation() {
    // Ensure any previous timers are cancelled
    stopEmojiAnimation();

    // Reset index
    currentEmojiIconIndex.value = 0;

    // Start periodic timer to change icon every 2 seconds
    _emojiAnimationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      currentEmojiIconIndex.value =
          (currentEmojiIconIndex.value + 1) % emojiAnimationIcons.length;
    });

    // Start one-shot timer to stop animation after 1 minute
    _emojiAnimationStopTimer = Timer(const Duration(minutes: 1), () {
      stopEmojiAnimation();
      // Reset to the first icon after stopping
      currentEmojiIconIndex.value = 8;
    });
  }

  void stopEmojiAnimation() {
    _emojiAnimationTimer?.cancel();
    _emojiAnimationStopTimer?.cancel();
    _emojiAnimationTimer = null;
    _emojiAnimationStopTimer = null;
  }

  Future<void> _playKeySound() async {
    try {
      await _audioPlayer.stop(); // إيقاف أي صوت مشغل حالياً
      await _audioPlayer.play(
        AssetSource('sounds/keyboard_click.mp3'),
        volume: 0.8, // تخفيض الصوت ليكون أقل إزعاجاً
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      debugPrint('Error playing key sound: $e');
    }
  }

  Future<void> playSendSound() async {
    try {
      await audioPlayer.stop(); // إيقاف أي صوت مشغل حالياً
      await audioPlayer.play(
        AssetSource('sounds/message_sent.mp3'),
        volume: 1.0,
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

// وظيفة البحث في الرسائل
  void searchInMessages(String query) {
    searchText.value = query;
    if (query.isEmpty) {
      searchMessagesResults.clear();
      currentSearchIndex.value = -1;
      return;
    }

    searchMessagesResults.assignAll(messages
        .where((msg) => msg.content.toLowerCase().contains(query.toLowerCase()))
        .toList());

    if (searchMessagesResults.isNotEmpty) {
      currentSearchIndex.value = 0;
      _scrollToSearchResult(currentSearchIndex.value);
    }
  }

// وظيفة التنقل بين نتائج البحث
  void navigateSearchResult(bool isNext) {
    if (searchMessagesResults.isEmpty) return;

    if (isNext) {
      currentSearchIndex.value =
          (currentSearchIndex.value + 1) % searchMessagesResults.length;
    } else {
      currentSearchIndex.value =
          (currentSearchIndex.value - 1) % searchMessagesResults.length;
      if (currentSearchIndex.value < 0) {
        currentSearchIndex.value = searchMessagesResults.length - 1;
      }
    }

    _scrollToSearchResult(currentSearchIndex.value);
  }

// وظيفة التمرير إلى نتيجة البحث
  void _scrollToSearchResult(int index) {
    if (index < 0 || index >= searchMessagesResults.length) return;

    final messageId = searchMessagesResults[index].id;
    final messageIndex = messages.indexWhere((msg) => msg.id == messageId);

    if (messageIndex != -1 && messagesScrollController.hasClients) {
      final scrollPosition = messagesScrollController.position;
      final itemExtent = 100.0; // ارتفاع تقريبي لكل رسالة
      final scrollOffset = messageIndex * itemExtent;

      messagesScrollController.animateTo(
        scrollOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

// إغلاق البحث
  void closeSearch() {
    // messageColor = Colors.transparent;

    searchText.value = '';
    searchMessagesResults.clear();
    currentSearchIndex.value = -1;
  }

  void _scrollListener() {
    if (messagesScrollController.hasClients) {
      final position = messagesScrollController.position;

      // تحديد ما إذا كنا في أسفل القائمة
      final isScrolledToBottom =
          position.pixels >= (position.maxScrollExtent - 50);
      isAtBottom.value = isScrolledToBottom;

      // تحديث حالة التمرير
      isScrolling.value = position.isScrollingNotifier.value;

      // تحديث وقت آخر تمرير
      if (isScrolling.value) {
        lastScrollTime.value = DateTime.now();
      }

      // إظهار الزر إذا لم نكن في الأسفل ولم نكن نقوم بالتمرير حاليًا
      showScrollToBottomButton.value = !isScrolledToBottom;
    }
  }

// دالة التمرير إلى أسفل القائمة
  void scrollToBottom() {
    if (messagesScrollController.hasClients) {
      messagesScrollController.animateTo(
        messagesScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool OpenKeabord() {
    return isKeabordTap.value = true;
  }

  Future<void> sendMessage(int chatId) async {
    final text = messageController.text.trim();

    // التحقق من وجود نص أو ملف مرفق
    if (text.isEmpty && selectedFilePath.value.isEmpty) {
      return;
    }

    try {
      isSending(true);
      MessageModel newMessage;

      // إذا كان هناك ملف مرفق
      if (selectedFilePath.value.isNotEmpty) {
        newMessage = await repository.sendMessage(
          contactId: chatId,
          message: text,
          filePath: selectedFilePath.value,
          fileType: selectedFileType.value,
        );
      } else if (text.isNotEmpty && selectedFilePath.value.isNotEmpty) {
        newMessage = await repository.sendMessage(
          contactId: chatId,
          message: text,
          filePath: selectedFilePath.value,
          fileType: selectedFileType.value,
        );
      } else {
        // إرسال رسالة نصية فقط
        newMessage = await repository.sendMessage(
          contactId: chatId,
          message: text,
        );
      }

      // إضافة الرسالة الجديدة إلى القائمة
      messages.add(newMessage);
      playSendSound(); // تشغيل الصوت هنا

      // مسح النص والملف المرفق
      messageController.clear();
      clearAttachment();

      // إلغاء الرد إذا كان موجودًا
      replyToMessage.value = null;

      // التمرير إلى أحدث رسالة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (messagesScrollController.hasClients) {
          // messagesScrollController.jumpTo(
          //   messagesScrollController.position.maxScrollExtent,

          // // duration: const Duration(milliseconds: 300),
          // curve: Curves.easeOut,
          // );
          scrollToBottom();
        }
      });

      // تحديث آخر رسالة في المحادثة
      final chatIndex = chats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        final updatedChat = chats[chatIndex].copyWith(
          lastMessage:
              text.isEmpty ? _getMediaTypeText(selectedFileType.value) : text,
          lastMessageTime: DateTime.now().toIso8601String(),
        );
        chats[chatIndex] = updatedChat;
        filterChats(); // تحديث القائمة المفلترة
      }
      isEmojiVisible.value = false; // إخفاء لوحة الإيموجي بعد الإرسال
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إرسال الرسالة: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSending(false);
    }
  }

  // الحصول على نص وصفي لنوع الوسائط
  String _getMediaTypeText(String fileType) {
    switch (fileType) {
      case 'image':
        return 'صورة';
      case 'video':
        return 'فيديو';
      case 'audio':
        return 'تسجيل صوتي';
      case 'file':
        return 'ملف';
      default:
        return 'مرفق';
    }
  }

  void filterChats() {
    if (searchQuery.value.isEmpty) {
      filteredChats.assignAll(chats);
    } else {
      filteredChats.assignAll(
        chats.where((chat) =>
            chat.name.toLowerCase().contains(searchQuery.value.toLowerCase())),
      );
    }
  }

  void toggleOptions() {
    showOptions.toggle();
  }

  void searchChats(String query) {
    isSearching.value = true;
    if (query.isEmpty) {
      searchResults.assignAll(chats);
    } else {
      searchResults.assignAll(
        chats.where((chat) =>
            chat.name.toLowerCase().contains(query.toLowerCase()) ||
            (chat.lastMessage ?? '')
                .toLowerCase()
                .contains(query.toLowerCase())),
      );
    }
    isSearching.value = false;
  }

  // تنفيذ اختيار الصورة
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        selectedFile.value = File(pickedFile.path);
        selectedFilePath.value = pickedFile.path;
        selectedFileType.value = 'image';
        isAttachmentSelected.value = true;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في اختيار الصورة: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // تنفيذ اختيار الفيديو
  Future<void> pickVideo() async {
    try {
      final pickedFile = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );

      if (pickedFile != null) {
        selectedFile.value = File(pickedFile.path);
        selectedFilePath.value = pickedFile.path;
        selectedFileType.value = 'video';
        isAttachmentSelected.value = true;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في اختيار الفيديو: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // تنفيذ اختيار الملف
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        selectedFile.value = File(result.files.single.path!);
        selectedFilePath.value = result.files.single.path!;

        // تحديد نوع الملف
        final extension = result.files.single.extension?.toLowerCase() ?? '';
        String fileType;

        if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
          fileType = 'image';
        } else if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp']
            .contains(extension)) {
          fileType = 'video';
        } else if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(extension)) {
          fileType = 'audio';
        } else {
          fileType = 'file';
        }

        selectedFileType.value = fileType;
        isAttachmentSelected.value = true;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في اختيار الملف: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // مسح المرفق المحدد
  void clearAttachment() {
    selectedFile.value = null;
    selectedFilePath.value = '';
    selectedFileType.value = '';
    isAttachmentSelected.value = false;
  }

  // بدء تسجيل الصوت
  Future<void> startRecording() async {
    try {
      // طلب الإذن
      if (await Permission.microphone.request().isGranted) {
        // تحديد مسار الملف
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // بدء التسجيل - تصحيح استخدام الدالة
        final config = RecordConfig(
          encoder: AudioEncoder.aacLc, // استخدام ترميز AAC
          bitRate: 128000, // معدل البت
          sampleRate: 44100, // معدل العينة
        );
        await _audioRecorder.start(config, path: filePath);

        isRecording.value = true;
        recordingPath.value = filePath;
        recordingDuration.value = 0.0;

        // تحديث مدة التسجيل
        _updateRecordingDuration();
      } else {
        Get.snackbar(
          'خطأ',
          'لم يتم منح إذن الميكروفون',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في بدء التسجيل: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // إيقاف تسجيل الصوت
  Future<void> stopRecording() async {
    try {
      if (isRecording.value) {
        final path = await _audioRecorder.stop();

        isRecording.value = false;

        if (path != null) {
          selectedFile.value = File(path);
          selectedFilePath.value = path;
          selectedFileType.value = 'audio';
          isAttachmentSelected.value = true;
        }
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إيقاف التسجيل: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // إلغاء تسجيل الصوت
  Future<void> cancelRecording() async {
    try {
      if (isRecording.value) {
        await _audioRecorder.stop();
        isRecording.value = false;

        // حذف ملف التسجيل
        if (recordingPath.value.isNotEmpty) {
          final file = File(recordingPath.value);
          if (await file.exists()) {
            await file.delete();
          }
        }

        recordingPath.value = '';
        recordingDuration.value = 0.0;
      }
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }

  // تحديث مدة التسجيل
  void _updateRecordingDuration() {
    if (isRecording.value) {
      Future.delayed(const Duration(milliseconds: 100), () async {
        if (isRecording.value) {
          recordingDuration.value += 0.1;
          _updateRecordingDuration();
        }
      });
    }
  }

  // تعيين الرسالة للرد عليها
  void setReplyMessage(MessageModel message) {
    replyToMessage.value = message;
  }

  // إلغاء الرد
  void cancelReply() {
    replyToMessage.value = null;
  }

  // توجيه رسالة
  // حل جذري لمشكلة إعادة توجيه الرسائل مع الوسائط

// توجيه رسالة - الإصدار المحسن
  Future<void> forwardMessage(MessageModel message, int targetChatId) async {
    try {
      isSending(true);
      print(
          'بدء إعادة توجيه الرسالة: ${message.id} إلى المحادثة: $targetChatId');
      print('محتوى الرسالة: ${message.content}');
      print('رابط الملف: ${message.fileUrl}');

      // إرسال الرسالة إلى المحادثة المستهدفة
      MessageModel newMessage;

      if (message.fileUrl != null && message.fileUrl!.isNotEmpty) {
        print('الرسالة تحتوي على وسائط، جاري تحميل الملف...');

        // تحميل الملف مباشرة من الخادم
        final dio = Dio();
        final directory = await getTemporaryDirectory();
        final fileName = message.fileUrl!.split('/').last;
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        try {
          // تحميل الملف مباشرة
          final response = await dio.download(
            message.fileUrl!,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                print(
                    'تم تحميل ${(received / total * 100).toStringAsFixed(0)}%');
              }
            },
          );

          print('تم تحميل الملف بنجاح: $filePath');

          // التحقق من وجود الملف
          if (await file.exists()) {
            print('الملف موجود، حجمه: ${await file.length()} بايت');

            // تحديد نوع الملف
            final fileType = _getFileTypeFromUrl(message.fileUrl!);
            print('نوع الملف: $fileType');

            // إرسال الرسالة مع الملف
            newMessage = await repository.sendMessage(
              contactId: targetChatId,
              message: message.content,
              filePath: file.path,
              fileType: fileType,
            );

            print('تم إرسال الرسالة مع الملف بنجاح');
          } else {
            print('خطأ: الملف غير موجود بعد التحميل');
            // إرسال النص فقط
            newMessage = await repository.sendMessage(
              contactId: targetChatId,
              message: message.content,
            );
          }
        } catch (downloadError) {
          print('خطأ في تحميل الملف: $downloadError');

          // محاولة بديلة باستخدام ApiService
          try {
            print('محاولة تحميل الملف باستخدام ApiService...');
            final ApiService _apiService = Get.find<ApiService>();

            // إنشاء مسار للتحميل المباشر
            final downloadUrl =
                '/chat/download-file?file_url=${Uri.encodeComponent(message.fileUrl!)}';
            print('رابط التحميل: $downloadUrl');

            final response = await _apiService.getWithToken(
              downloadUrl,
              headers: {'Accept': 'application/octet-stream'},
            );

            // حفظ البيانات في ملف
            await file.writeAsBytes(response.data);
            print('تم تحميل الملف بنجاح باستخدام ApiService: $filePath');

            // إرسال الرسالة مع الملف
            newMessage = await repository.sendMessage(
              contactId: targetChatId,
              message: message.content,
              filePath: file.path,
              fileType: _getFileTypeFromUrl(message.fileUrl!),
            );
          } catch (apiError) {
            print('فشلت المحاولة البديلة: $apiError');
            // إرسال النص فقط كملاذ أخير
            newMessage = await repository.sendMessage(
              contactId: targetChatId,
              message: message.content,
            );
          }
        }
      } else {
        print('الرسالة لا تحتوي على وسائط، إرسال النص فقط');
        // إرسال النص فقط
        newMessage = await repository.sendMessage(
          contactId: targetChatId,
          message: message.content,
        );
      }

      // عرض إشعار النجاح
      Get.snackbar(
        messageText: Lottie.asset('assets/animations/forward_success.json',
            height: 40.h, width: 40.w, fit: BoxFit.contain),
        icon: Lottie.asset(
          'assets/animations/forward_done.json',
          height: 40.h,
          width: 40.w,
          fit: BoxFit.contain,
          repeat: false,
        ),
        titleText: Text(
          'تم التوجيه',
          textAlign: TextAlign.center,
        ),
        '',
        'تم توجيه الرسالة بنجاح',
        snackPosition: SnackPosition.TOP,
      );

      // تحديث المحادثة المستهدفة إذا كانت مفتوحة حاليًا
      if (messages.isNotEmpty && messages.first.chatId == targetChatId) {
        messages.add(newMessage);
      }
    } catch (e) {
      print('خطأ عام في إعادة توجيه الرسالة: $e');
      Get.snackbar(
        'خطأ',
        'فشل في توجيه الرسالة: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSending(false);
    }
  }

  // تحديد نوع الملف من الرابط
  String _getFileTypeFromUrl(String url) {
    final extension = url.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp']
        .contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(extension)) {
      return 'audio';
    } else {
      return 'file';
    }
  }

  // Future<File?> _downloadFileFromUrl(String url) async {
  //   try {
  //     // استخدام ApiService للتعامل مع التحميل مع مراعاة التوثيق
  //     final ApiService _apiService = Get.find<ApiService>();

  //     // تحديد اسم الملف من الرابط
  //     final fileName = url.split('/').last;

  //     // إنشاء مسار مؤقت لحفظ الملف
  //     final directory = await getTemporaryDirectory();
  //     final filePath = '${directory.path}/$fileName';
  //     final file = File(filePath);

  //     // التحقق مما إذا كان الملف موجودًا بالفعل
  //     if (await file.exists()) {
  //       print('الملف موجود بالفعل: $filePath');
  //       return file;
  //     }

  //     // إذا كان الرابط يشير إلى ملف في الخادم، استخدم نقطة النهاية المخصصة للتحميل
  //     if (url.contains('storage/chat_files')) {
  //       // استخدام نقطة النهاية الجديدة للتحميل
  //       final response = await _apiService.getWithToken(
  //         '/chat/download-file',
  //         queryParameters: {'file_url': url},
  //         headers: {'Accept': 'application/octet-stream'},
  //       );

  //       // حفظ البيانات في ملف
  //       await file.writeAsBytes(response.data);
  //       print('تم تحميل الملف بنجاح من API: $filePath');
  //       return file;
  //     } else {
  //       // إذا كان الرابط خارجيًا، استخدم Dio مباشرة للتحميل
  //       final response = await Dio().get(
  //         url,
  //         options: Options(
  //           responseType: ResponseType.bytes,
  //           followRedirects: true,
  //           validateStatus: (status) => status! < 500,
  //         ),
  //       );

  //       if (response.statusCode == 200) {
  //         // حفظ البيانات في ملف
  //         await file.writeAsBytes(response.data);
  //         print('تم تحميل الملف بنجاح من رابط خارجي: $filePath');
  //         return file;
  //       } else {
  //         print('فشل في تحميل الملف. كود الحالة: ${response.statusCode}');
  //         return null;
  //       }
  //     }
  //   } catch (e) {
  //     print('خطأ في تحميل الملف: $e');
  //     return null;
  //   }
  // }

  // عرض مربع حوار توجيه الرسالة
  void showForwardDialog(MessageModel message) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'توجيه إلى',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      backgroundImage: chat.imageUrl != null
                          ? NetworkImage(chat.imageUrl!)
                          : null,
                      child: chat.imageUrl == null
                          ? Text(
                              chat.name.isNotEmpty
                                  ? chat.name[0].toUpperCase()
                                  : '',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(chat.name),
                    onTap: () {
                      Get.back();
                      forwardMessage(message, chat.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عرض مربع حوار تأكيد الحذف
  void showDeleteConfirmation(MessageModel message) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف الرسالة'),
        content: const Text(
            'هل أنت متأكد من حذف هذه الرسالة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteMessage(message);
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // تحميل المجموعات
  Future<void> loadGroups() async {
    try {
      isLoading(true);
      final result = await repository.getGroups();
      // يمكن إضافة المجموعات إلى قائمة منفصلة أو دمجها مع المحادثات الحالية
      // حسب متطلبات التطبيق
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المجموعات: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }
  }

  // تحميل القنوات
  Future<void> loadChannels() async {
    try {
      isLoading(true);
      final result = await repository.getChannels();
      // يمكن إضافة القنوات إلى قائمة منفصلة أو دمجها مع المحادثات الحالية
      // حسب متطلبات التطبيق
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل القنوات: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }
  }

  // --- Modified loadMessages to use caching repository ---
  Future<void> loadMessages(int chatId, {bool forceRefresh = false}) async {
    try {
      isLoading(true);
      // Call the repository method which handles caching
      final result = await repository.getMessages(chatId);
      print('Number of messages received (from repo): ${result.length}');
      messages.assignAll(result);

      // Scroll to bottom after messages are loaded (as in original)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    } catch (e) {
      // Only show error if cache is also empty
      if (messages.isEmpty) {
        print('Error loading messages: $e');
        Get.snackbar(
          'خطأ',
          'فشل في تحميل الرسائل: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
        );
      }
      print('Error loading messages: $e'); // Log error regardless
    } finally {
      isLoading(false);
    }
  }

  // --- All other functions preserved exactly from the original file ---

  Future<void> changeText(String value) async {
    if (messageController.value.text.isNotEmpty &&
        (messageController.value.text.trim() != "")) {
      _playKeySound();
      isContainText.value = true;
    } else
      isContainText.value = false;
  }

  void changeCategory(int index) {
    currentCategoryIndex.value = index;
    // Original navigation logic commented out, assuming it's handled elsewhere
    // if(index==2)
    // Get.to(() => ChannelsPage());
    // else if (index==1)
    // Get.to(() => GroupChatPage());
    // else
    // Get.to(() => ChatPage());
    //filterChats(); // filterChats is called in loadChats now
  }

  // --- _downloadFileFromUrl - Preserved original logic ---
  // Note: This function seems unused in the original forwardMessage logic provided,
  // b
  // --- deleteMessage - Modified to use caching repository ---
  Future<void> deleteMessage(MessageModel message) async {
    try {
      // Call repository to delete from server and cache
      final success = await repository.deleteMessage(message.id);
      if (success) {
        // Remove from local list for immediate UI update
        messages.removeWhere((m) => m.id == message.id);
        // Get.snackbar(
        //   'نجاح',
        //   'تم حذف الرسالة بنجاح',
        //   snackPosition: SnackPosition.TOP,
        // );
      } else {
        // Error handled by repository or show generic error
        Get.snackbar(
          'خطأ',
          'فشل في حذف الرسالة من الخادم',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حذف الرسالة: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// جلب المستخدمين المتاحين لبدء محادثة معهم
  Future<void> loadAvailableUsers({
    String? type,
    int? collegeId,
    int? departmentId,
    String? level,
  }) async {
    try {
      isLoadingUsers.value = true;
      print('بدء تحميل المستخدمين المتاحين...');
      print('نوع المستخدم المطلوب: $type');

      final fetchedUsers = await repository.getAvailableUsers(
        type: type,
        // collegeId: collegeId,
        // departmentId: departmentId,
        // level: level,
      );

      availableUsers.value = fetchedUsers;
      print('تم تحميل ${availableUsers.length} مستخدم متاح');

      if (availableUsers.isEmpty) {
        print('لا توجد مستخدمين متاحين للنوع المحدد: $type');
      } else {
        print('أول مستخدم في القائمة: ${availableUsers.first}');
      }
    } catch (e) {
      print('خطأ في تحميل المستخدمين المتاحين: $e');
      availableUsers.clear();
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المستخدمين المتاحين: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingUsers.value = false;
    }
  }

  /// إنشاء محادثة جديدة مع مستخدم
  Future<ChatModel?> createChatWithUser(List<int> participantIds) async {
    try {
      print('بدء إنشاء محادثة جديدة مع المشاركين: $participantIds');

      final newChat = await repository.createChat(participantIds);

      // إضافة المحادثة الجديدة إلى القائمة
      chats.add(newChat!);

      // حفظ في التخزين المحلي
      saveChatsToStorage();

      print('تم إنشاء محادثة جديدة بنجاح مع المعرف: ${newChat.id}');

      return newChat;
    } catch (e) {
      print('خطأ في إنشاء المحادثة: $e');
      rethrow; // إعادة رمي الخطأ ليتم التعامل معه في الواجهة
    }
  }

  /// دالة إنشاء محادثة جديدة (للتوافق مع الكود السابق)
  Future<void> createNewChat() async {
    try {
      print('استدعاء دالة createNewChat...');

      // فتح صفحة اختيار المستخدمين
      Get.toNamed('/create-new-chat');
    } catch (e) {
      print('خطأ في فتح صفحة إنشاء محادثة جديدة: $e');
      Get.snackbar(
        'خطأ',
        'فشل في فتح صفحة إنشاء محادثة جديدة: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// تحديث نوع المستخدم المحدد للتصفية
  void updateSelectedUserType(String type) {
    selectedUserType.value = type;
    print('تم تحديث نوع المستخدم المحدد إلى: $type');
  }

  /// حفظ المحادثات في التخزين المحلي
  void saveChatsToStorage() {
    try {
      final chatsJson = chats.map((chat) => chat.toJson()).toList();
      _storage.write('chats', chatsJson);
      print('تم تحديث ${chats.length} محادثة في التخزين المحلي');
    } catch (e) {
      print('خطأ في حفظ المحادثات: $e');
    }
  }

  // بناء فلاتر البحث
  // Widget _buildUserFilters() {
  //   return Column(
  //     children: [
  //       // اختيار نوع المستخدم
  //       DropdownButtonFormField<String>(
  //         decoration: InputDecoration(
  //           labelText: 'نوع المستخدم',
  //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  //         ),
  //         value: selectedUserType.value.isEmpty ? null : selectedUserType.value,
  //         items: ['معلم', 'طالب', 'مشرف'].map((type) {
  //           return DropdownMenuItem(value: type, child: Text(type));
  //         }).toList(),
  //         onChanged: (value) {
  //           selectedUserType.value = value ?? '';
  //           loadAvailableUsers(type: value);
  //         },
  //       ),

  //       SizedBox(height: 10),

  //       // يمكن إضافة المزيد من الفلاتر هنا (الكلية، القسم، المستوى)
  //     ],
  //   );
  // }

  Future<void> blockUser(int userId) async {
    try {
      isLoading(true);
      final success = await repository.blockUser(userId);
      if (success) {
        await _storage.addBlockedUserId(userId);
        chats.removeWhere((chat) => chat.id == userId);
        filterChats();
        Get.snackbar(
          'تم الحظر',
          'تم حظر المستخدم بنجاح.',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في حظر المستخدم.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حظر المستخدم: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> unblockUser(int userId) async {
    try {
      isLoading(true);
      final success = await repository.unblockUser(userId);
      if (success) {
        await _storage.removeBlockedUserId(userId);
        await loadChats(); // إعادة تحميل المحادثات من الخادم والتخزين المحلي
        Get.snackbar(
          'تم رفع الحظر',
          'تم رفع الحظر عن المستخدم بنجاح.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في رفع الحظر عن المستخدم.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في رفع الحظر عن المستخدم: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }

    Get.snackbar(
      'خطأ',
      'فشل في إلغاء حظر المستخدم: ${e.toString()}',
      snackPosition: SnackPosition.TOP,
    );
  }

  void toggleFabMenu() {
    showFabMenu.toggle();
  }
}
