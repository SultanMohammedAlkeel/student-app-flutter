import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/rendering.dart';
import 'package:student_app/core/services/auth_service.dart';
// ignore: unused_import
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../data/models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../repositories/posts_repository.dart';
import '../../../core/network/api_service.dart';

class PostsController extends GetxController with StateMixin<List<Post>> {
  final PostsRepository _repository = Get.find();
  final ApiService _apiService = Get.find<ApiService>();

  // متغيرات أساسية للمنشورات
  final RxList<Post> posts = <Post>[].obs;
  final RxMap<int, List<Comment>> comments = <int, List<Comment>>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLiking = false.obs;
  final RxBool showComments = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isCreatingPost = false.obs;
  final RxInt currentUserId = 0.obs;
  final RxMap<int, bool> showCommentsMap = <int, bool>{}.obs;
  final RxBool showAddButton = true.obs;
  final ScrollController scrollController = ScrollController();
  
  // متغيرات تتبع تقدم رفع الملفات
  final Map<String, RxDouble> uploadProgress = <String, RxDouble>{}.obs;
  final RxList<String> uploadingFiles = <String>[].obs;
  final RxList<String> uploadedFiles = <String>[].obs;
  final RxList<String> failedUploads = <String>[].obs;

  // متغيرات جديدة لدعم الواجهة المحسنة
  final RxInt activeTabIndex = 0.obs;
  final RxList<Post> savedPosts = <Post>[].obs;
  final RxList<Post> myPosts = <Post>[].obs;
  final RxList<Post> collegePosts = <Post>[].obs;
  final RxList<Post> searchResults = <Post>[].obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxSet<int> viewedPosts = <int>{}.obs;
  final RxBool isRecordingView = false.obs;
  final RxBool showSuccessAnimation = false.obs;
  final RxBool showDeleteAnimation = false.obs;
  final RxBool showLikeAnimation = false.obs;
  final RxInt animatingPostId = (-1).obs;
  final RxBool isRefreshing = false.obs;

 static final Map<String, List<Post>> _contentSearchCache = {};
  static final Map<String, List<UserModel>> _userSearchCache = {};
  static final Map<int, List<Post>> _userPostsCache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);
  // Colors Management
  Color get bgColor => Get.find<HomeController>().isDarkMode.value
      ? AppColors.darkBackground
      : AppColors.lightBackground;

  Color get cardColor => Get.isDarkMode        
      ? AppColors.darkBackground
      : AppColors.lightBackground;

  Color get textColor =>Get.isDarkMode 
      ? Colors.white
      : AppColors.textPrimary;

  Color get secondaryTextColor => Get.isDarkMode 
      ? Colors.grey[400]!
      : AppColors.textSecondary;

  @override
  void onInit() {
    super.onInit();
    currentUserId.value = Get.find<AuthService>().currentUserId();
    _setupScrollListener();
    fetchPosts();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      final direction = scrollController.position.userScrollDirection;
      
      // إخفاء/إظهار زر الإضافة عند التمرير
      if (direction == ScrollDirection.reverse && showAddButton.value) {
        showAddButton.value = false;
      } else if (direction == ScrollDirection.forward && !showAddButton.value) {
        // تأخير إظهار الزر لتحسين التجربة
        Future.delayed(Duration(milliseconds: 300), () {
          if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
            showAddButton.value = true;
          }
        });
      }
      
      // تحميل المزيد من المنشورات عند الوصول لنهاية القائمة
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300) {
        fetchMorePosts();
      }
    });
  }

  // تحديث التبويب النشط
  void updateActiveTab(int index) {
    activeTabIndex.value = index;
    
    // تحميل المنشورات المناسبة للتبويب
    switch (index) {
      case 0: // الكل
        if (posts.isEmpty) fetchPosts();
        break;
      case 1: // الكلية
        if (collegePosts.isEmpty) fetchCollegePosts();
        break;
      case 2: // المحفوظة
        if (savedPosts.isEmpty) fetchSavedPosts();
        break;
      case 3: // منشوراتي
        if (myPosts.isEmpty) fetchMyPosts();
        break;
    }
  }
final PostsRepository _postsRepository = Get.find<PostsRepository>();
  


  
  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }
  
  void _scrollListener() {
    if (scrollController.position.pixels >= 100) {
      showAddButton.value = false;
    } else {
      showAddButton.value = true;
    }
    
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }
  
 
  Future<void> _loadMorePosts() async {
    if (isLoadingMore.value || posts.isEmpty) return;
    
    isLoadingMore.value = true;
    try {
      final lastPostId = posts.last.id;
      final result = await _postsRepository.getMorePosts(lastPostId);
      if (result.isNotEmpty) {
        posts.addAll(result);
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المزيد من المنشورات: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }
  
  // Future<void> searchPosts(String query) async {
  //   if (query.isEmpty) {
  //     fetchPosts();
  //     return;
  //   }
    
  //   isLoading.value = true;
  //   try {
  //     final result = await _postsRepository.searchPosts(query);
  //     posts.value = result;
  //   } catch (e) {
  //     Get.snackbar(
  //       'خطأ',
  //       'فشل في البحث عن المنشورات: ${e.toString()}',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
   // البحث في المنشورات (الكل)
  Future<List<Post>> searchPosts(String query, Map<String, dynamic> filters) async {
    try {
      isSearching.value = true;
      
      // محاولة استرجاع النتائج من التخزين المؤقت
      final cacheKey = _generateCacheKey(query, filters);
      if (_contentSearchCache.containsKey(cacheKey)) {
        return _contentSearchCache[cacheKey]!;
      }
      
      // تنفيذ البحث من خلال المستودع
      final results = await _repository.searchPosts(query, filters);
      
      // تخزين النتائج في التخزين المؤقت
      _contentSearchCache[cacheKey] = results;
      _scheduleRemoveFromCache(cacheKey, _contentSearchCache);
      
      return results;
    } catch (e) {
      throw Exception('فشل في البحث: ${e.toString()}');
    } finally {
      isSearching.value = false;
    }
  }

  // البحث في محتوى المنشورات فقط
  Future<List<Post>> searchPostsByContent(String query, Map<String, dynamic> filters) async {
    try {
      isSearching.value = true;
      
      // محاولة استرجاع النتائج من التخزين المؤقت
      final cacheKey = 'content_${_generateCacheKey(query, filters)}';
      if (_contentSearchCache.containsKey(cacheKey)) {
        return _contentSearchCache[cacheKey]!;
      }
      
      // تنفيذ البحث من خلال المستودع
      final results = await _repository.searchPostsByContent(query, filters);
      
      // تخزين النتائج في التخزين المؤقت
      _contentSearchCache[cacheKey] = results;
      _scheduleRemoveFromCache(cacheKey, _contentSearchCache);
      
      return results;
    } catch (e) {
      throw Exception('فشل في البحث: ${e.toString()}');
    } finally {
      isSearching.value = false;
    }
  }

  // البحث عن المستخدمين
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      isSearching.value = true;
      
      // محاولة استرجاع النتائج من التخزين المؤقت
      if (_userSearchCache.containsKey(query)) {
        return _userSearchCache[query]!;
      }
      
      // تنفيذ البحث من خلال المستودع
      final results = await _repository.searchUsers(query);
      
      // تخزين النتائج في التخزين المؤقت
      _userSearchCache[query] = results;
      _scheduleRemoveFromCache(query, _userSearchCache);
      
      return results;
    } catch (e) {
      throw Exception('فشل في البحث عن المستخدمين: ${e.toString()}');
    } finally {
      isSearching.value = false;
    }
  }

  // جلب منشورات مستخدم معين
  Future<List<Post>> getUserPosts(int userId) async {
    try {
      // محاولة استرجاع النتائج من التخزين المؤقت
      if (_userPostsCache.containsKey(userId)) {
        return _userPostsCache[userId]!;
      }
      
      // تنفيذ البحث من خلال المستودع
      final results = await _repository.getUserPosts(userId);
      
      // تخزين النتائج في التخزين المؤقت
      _userPostsCache[userId] = results;
      _scheduleRemoveFromCache(userId, _userPostsCache);
      
      return results;
    } catch (e) {
      throw Exception('فشل في جلب منشورات المستخدم: ${e.toString()}');
    }
  }

  // إنشاء مفتاح للتخزين المؤقت بناءً على الاستعلام والفلاتر
  String _generateCacheKey(String query, Map<String, dynamic> filters) {
    final filterString = filters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '${query}_$filterString';
  }

  // جدولة إزالة العناصر من التخزين المؤقت بعد فترة محددة
  void _scheduleRemoveFromCache<K, V>(K key, Map<K, V> cache) {
    Future.delayed(_cacheDuration, () {
      cache.remove(key);
    });
  }

  // مسح التخزين المؤقت
  void clearSearchCache() {
    _contentSearchCache.clear();
    _userSearchCache.clear();
    _userPostsCache.clear();
  }


  // إنشاء محتوى المنشور
  // ignore: unused_element
  Future<String?> _createPostContent(String content) async {
    try {
      final response = await _apiService.post(
        '/posts/create',
        data: {
          'content': content,
        },
      );
      
      if (response.statusCode == 201) {
        return response.data['id'];
      }
      return null;
    } catch (e) {
      throw 'فشل في إنشاء المنشور: ${e.toString()}';
    }
  }
  
  // رفع ملفات المنشور
  // Future<void> _uploadPostFiles(String postId, List<File> files, List<String>? fileTypes) async {
  //   // تهيئة قائمة الملفات التي يتم رفعها
  //   uploadingFiles.clear();
  //   uploadedFiles.clear();
  //   failedUploads.clear();
    
  //   // إضافة الملفات إلى قائمة الرفع
  //   for (var i = 0; i < files.length; i++) {
  //     final file = files[i];
  //     final fileId = '${postId}_${i}_${path.basename(file.path)}';
  //     uploadingFiles.add(fileId);
  //     uploadProgress[fileId] = 0.0.obs;
  //   }
    
  //   // رفع الملفات بالتوازي
  //   final uploadFutures = <Future>[];
    
  //   for (var i = 0; i < files.length; i++) {
  //     final file = files[i];
  //     final fileType = fileTypes != null && i < fileTypes.length ? fileTypes[i] : 'file';
  //     final fileId = '${postId}_${i}_${path.basename(file.path)}';
      
  //     uploadFutures.add(_uploadSingleFile(postId, file, fileType, fileId));
  //   }
    
  //   // انتظار اكتمال جميع عمليات الرفع
  //   await Future.wait(uploadFutures);
    
  //   // التحقق من نجاح جميع عمليات الرفع
  //   if (failedUploads.isNotEmpty) {
  //     throw 'فشل في رفع بعض الملفات: ${failedUploads.length} من ${files.length}';
  //   }
  // }
  
  // رفع ملف واحد
  // ignore: unused_element
  Future<void> _uploadSingleFile(String postId, File file, String fileType, String fileId) async {
    try {
      // إنشاء FormData لرفع الملف
      final fileName = path.basename(file.path);
      final formData = FormData.fromMap({
        'post_id': postId,
        'file_type': fileType,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });
      
      // رفع الملف مع تتبع التقدم
      await _apiService.post(
        '/posts/upload-File',
        data: formData,
        onSendProgress: (int sent, int total) {
          final progress = sent / total;
          uploadProgress[fileId]?.value = progress;
        },
      );
      
      // إضافة الملف إلى قائمة الملفات المرفوعة
      uploadingFiles.remove(fileId);
      uploadedFiles.add(fileId);
      
    } catch (e) {
      // إضافة الملف إلى قائمة الملفات الفاشلة
      uploadingFiles.remove(fileId);
      failedUploads.add(fileId);
      
      // إعادة المحاولة مرة واحدة
      if (!failedUploads.contains('retry_$fileId')) {
        failedUploads.add('retry_$fileId');
        await Future.delayed(const Duration(seconds: 2));
        return _uploadSingleFile(postId, file, fileType, fileId);
      }
    }
  }
  
  
  // الحصول على المنشورات حسب التبويب النشط
  List<Post> getPostsByActiveTab() {
    switch (activeTabIndex.value) {
      case 1: return collegePosts;
      case 2: return savedPosts;
      case 3: return myPosts;
      case 0:
      default: return posts;
    }
  }

  // جلب جميع المنشورات
  Future<void> fetchPosts() async {
    try {
      if (isLoading.value) return; // تجنب الطلبات المكررة
      
      isLoading.value = true;
      final fetchedPosts = await _repository.getPosts();
      posts.assignAll(fetchedPosts);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('خطأ', 'فشل في جلب المنشورات: ${e.toString()}');
    }
  }

  // جلب منشورات الكلية
  Future<void> fetchCollegePosts() async {
    try {
      if (isLoading.value) return;
      
      isLoading.value = true;
      final fetchedPosts = await _repository.getCollegePosts();
      collegePosts.assignAll(fetchedPosts);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('خطأ', 'فشل في جلب منشورات الكلية: ${e.toString()}');
    }
  }

  // جلب المنشورات المحفوظة
  Future<void> fetchSavedPosts() async {
    try {
      if (isLoading.value) return;
      
      isLoading.value = true;
      final fetchedPosts = await _repository.getSavedPosts();
      savedPosts.assignAll(fetchedPosts);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('خطأ', 'فشل في جلب المنشورات المحفوظة: ${e.toString()}');
    }
  }

  // جلب منشوراتي
  Future<void> fetchMyPosts() async {
    try {
      if (isLoading.value) return;
      
      isLoading.value = true;
      final fetchedPosts = await _repository.getMyPosts();
      myPosts.assignAll(fetchedPosts);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('خطأ', 'فشل في جلب منشوراتك: ${e.toString()}');
    }
  }

  // تحديث جميع المنشورات
  Future<void> refreshAllPosts() async {
    isRefreshing.value = true;
    
    try {
      await Future.wait([
        fetchPosts(),
        fetchCollegePosts(),
        fetchSavedPosts(),
        fetchMyPosts(),
      ]);
    } catch (e) {
      print('خطأ في تحديث المنشورات: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  // جلب المزيد من المنشورات (للتحميل المتدرج)
  Future<void> fetchMorePosts() async {
    if (isLoadingMore.value) return;

    try {
      final currentPosts = getPostsByActiveTab();
      if (currentPosts.isEmpty) return;
      
      isLoadingMore.value = true;
      
      List<Post> morePosts;
      switch (activeTabIndex.value) {
        case 1: // الكلية
          morePosts = await _repository.getMoreCollegePosts(currentPosts.last.id);
          collegePosts.addAll(morePosts);
          break;
        case 2: // المحفوظة
          morePosts = await _repository.getMoreSavedPosts(currentPosts.last.id);
          savedPosts.addAll(morePosts);
          break;
        case 3: // منشوراتي
          morePosts = await _repository.getMoreMyPosts(currentPosts.last.id);
          myPosts.addAll(morePosts);
          break;
        case 0: // الكل
        default:
          morePosts = await _repository.getMorePosts(currentPosts.last.id);
          posts.addAll(morePosts);
          break;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في جلب المزيد من المنشورات');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // جلب تعليقات منشور معين
  Future<void> fetchComments(int postId) async {
    try {
      if (!comments.containsKey(postId)) {
        final postComments = await _repository.getPostComments(postId);
        comments[postId] = postComments;
        comments.refresh();
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في جلب التعليقات: ${e.toString()}');
    }
  }

  // تسجيل مشاهدة المنشور
  Future<void> recordPostView(int postId) async {
    // تجنب تسجيل المشاهدة مرتين لنفس المنشور في نفس الجلسة
    if (viewedPosts.contains(postId) || isRecordingView.value) return;
    
    try {
      isRecordingView.value = true;
      await _repository.recordView(postId);
      
      // تحديث عداد المشاهدات في المنشور
      _updatePostViewCount(postId);
      
      // إضافة المنشور إلى قائمة المنشورات المشاهدة
      viewedPosts.add(postId);
    } catch (e) {
      print('خطأ في تسجيل المشاهدة: $e');
    } finally {
      isRecordingView.value = false;
    }
  }

  // تحديث عداد المشاهدات في المنشور
  void _updatePostViewCount(int postId) {
    // تحديث في جميع القوائم
    _updatePostViewInList(posts, postId);
    _updatePostViewInList(collegePosts, postId);
    _updatePostViewInList(savedPosts, postId);
    _updatePostViewInList(myPosts, postId);
  }

  // تحديث عداد المشاهدات في قائمة محددة
  void _updatePostViewInList(List<Post> postsList, int postId) {
    final index = postsList.indexWhere((p) => p.id == postId);
    if (index != -1) {
      postsList[index] = postsList[index].copyWith(
        viewsCount: postsList[index].viewsCount + 1,
      );
    }
  }

  // تبديل الإعجاب بمنشور
  Future<void> toggleLike(Post post) async {
    try {
      // تحديث فوري للواجهة
      final tempPost = post.copyWith(
        isLiked: !post.isLiked,
        likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
      _updatePostInList(tempPost);

      // عرض رسوم الإعجاب المتحركة
      if (!post.isLiked) {
        animatingPostId.value = post.id;
        showLikeAnimation.value = true;
        
        // إخفاء الرسوم المتحركة بعد فترة
        Future.delayed(Duration(milliseconds: 1500), () {
          showLikeAnimation.value = false;
        });
      }

      // إرسال الطلب للخادم
      final response = await _repository.toggleLike(post.id);
      
      // تحديث نهائي بعد استجابة الخادم
      _updatePostInList(tempPost.copyWith(
        isLiked: response.isLiked,
        likesCount: response.likesCount,
      ));
      
    } catch (e) {
      // التراجع عن التغييرات عند الخطأ
      _updatePostInList(post);
      
      Get.snackbar(
        'خطأ',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // تبديل حفظ منشور
  Future<void> toggleSave(Post post) async {
    try {
      // تحديث فوري للواجهة
      final tempPost = post.copyWith(isSaved: !post.isSaved);
      _updatePostInList(tempPost);

      // إرسال الطلب للخادم
      final response = await _repository.toggleSave(post.id);
      
      // تحديث البيانات من الخادم
      final updatedPost = post.copyWith(isSaved: response.isSaved);
      _updatePostInList(updatedPost);
      
      // تحديث قائمة المنشورات المحفوظة
      if (response.isSaved) {
        if (!savedPosts.any((p) => p.id == post.id)) {
          savedPosts.insert(0, updatedPost);
        }
      } else {
        savedPosts.removeWhere((p) => p.id == post.id);
      }
      
    } catch (e) {
      // التراجع عن التغييرات عند الخطأ
      _updatePostInList(post);
      
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الحفظ',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // تبديل عرض التعليقات
  void toggleCommentsVisibility(int postId) {
    showCommentsMap[postId] = !(showCommentsMap[postId] ?? false);
    
    // جلب التعليقات إذا لم تكن موجودة
    if (showCommentsMap[postId] == true && (!comments.containsKey(postId) || comments[postId]!.isEmpty)) {
      fetchComments(postId);
    }
    
    update();
  }

  // تحديث منشور في جميع القوائم
  void _updatePostInList(Post updatedPost) {
    try {
      // تحديث في قائمة جميع المنشورات
      final index = posts.indexWhere((p) => p.id == updatedPost.id);
      if (index != -1) {
        posts[index] = updatedPost;
      }
      
      // تحديث في قائمة منشورات الكلية
      final collegeIndex = collegePosts.indexWhere((p) => p.id == updatedPost.id);
      if (collegeIndex != -1) {
        collegePosts[collegeIndex] = updatedPost;
      }
      
      // تحديث في قائمة المنشورات المحفوظة
      final savedIndex = savedPosts.indexWhere((p) => p.id == updatedPost.id);
      if (savedIndex != -1) {
        savedPosts[savedIndex] = updatedPost;
      }
      
      // تحديث في قائمة منشوراتي
      final myIndex = myPosts.indexWhere((p) => p.id == updatedPost.id);
      if (myIndex != -1) {
        myPosts[myIndex] = updatedPost;
      }
      
      // تحديث في نتائج البحث
      final searchIndex = searchResults.indexWhere((p) => p.id == updatedPost.id);
      if (searchIndex != -1) {
        searchResults[searchIndex] = updatedPost;
      }
      
      // تحديث جميع القوائم
      posts.refresh();
      collegePosts.refresh();
      savedPosts.refresh();
      myPosts.refresh();
      searchResults.refresh();
      
    } catch (e) {
      print('خطأ في تحديث قائمة المنشورات: ${e.toString()}');
    }
  }
   
  // إضافة تعليق على منشور
  Future<void> addComment(int postId, String content) async {
    try {
      final newComment = await _repository.addComment(postId, content);
      
      // تحديث قائمة التعليقات المحلية
      comments[postId] ??= [];
      comments[postId]!.insert(0, newComment);
      comments.refresh();

      // تحديث عدد التعليقات في المنشور في جميع القوائم
      _updatePostCommentCount(postId);
      
      // عرض رسالة نجاح
      Get.snackbar('نجاح', 'تم إضافة التعليق بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إضافة التعليق: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  // تحديث عدد التعليقات في المنشور
  void _updatePostCommentCount(int postId) {
    // تحديث في جميع القوائم
    _updatePostCommentCountInList(posts, postId);
    _updatePostCommentCountInList(collegePosts, postId);
    _updatePostCommentCountInList(savedPosts, postId);
    _updatePostCommentCountInList(myPosts, postId);
    _updatePostCommentCountInList(searchResults, postId);
  }

  // تحديث عدد التعليقات في قائمة محددة
  void _updatePostCommentCountInList(List<Post> postsList, int postId) {
    final index = postsList.indexWhere((p) => p.id == postId);
    if (index != -1) {
      postsList[index] = postsList[index].copyWith(
        commentsCount: postsList[index].commentsCount + 1,
      );
    }
  }

  // إنشاء منشور جديد
  Future<void> createPost({
    required String content,
    File? file,
    String? fileType,
  }) async {
    try {
      isCreatingPost.value = true;
      
      String? fileUrl;
      int? fileSize;
      String? finalFileType = fileType;
      
      // رفع الملف إذا كان موجوداً
      if (file != null) {
        // إنشاء معرف فريد للملف لتتبع تقدم الرفع
        final fileId = DateTime.now().millisecondsSinceEpoch.toString();
        uploadProgress[fileId] = 0.0.obs;
        uploadingFiles.add(fileId);
        
        try {
          // رفع الملف
          final fileInfo = await _repository.uploadFile(
            file,
            fileType ?? _getFileTypeFromExtension(file.path),
            onProgress: (progress) {
              uploadProgress[fileId]?.value = progress;
            },
          );
          
          // تحديث معلومات الملف
          fileUrl = fileInfo['file_url'];
          fileSize = fileInfo['file_size'];
          finalFileType = fileInfo['file_type'];
          
          // تحديث حالة الرفع
          uploadingFiles.remove(fileId);
          uploadedFiles.add(fileId);
        } catch (e) {
          // تحديث حالة الرفع عند الفشل
          uploadingFiles.remove(fileId);
          failedUploads.add(fileId);
          
          throw Exception('فشل في رفع الملف: ${e.toString()}');
        }
      }
      
      // إنشاء المنشور
      final newPost = await _repository.createPost(
        content: content,
        fileUrl: fileUrl,
        fileType: finalFileType,
        filesize: fileSize,
      );
      
      // تحديث قائمة المنشورات
      posts.insert(0, newPost);
      myPosts.insert(0, newPost);
      
      // عرض رسوم النجاح المتحركة
      showSuccessAnimation.value = true;
      
      // إخفاء الرسوم المتحركة بعد فترة
      Future.delayed(Duration(seconds: 2), () {
        showSuccessAnimation.value = false;
      });
      
      // عرض رسالة نجاح
      Get.snackbar(
        'نجاح',
        'تم إنشاء المنشور بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إنشاء المنشور: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCreatingPost.value = false;
    }
  }

  // البحث في المنشورات
  // Future<void> searchPosts(String query) async {
  //   if (query.isEmpty) {
  //     searchResults.clear();
  //     isSearching.value = false;
  //     return;
  //   }
    
  //   try {
  //     isSearching.value = true;
  //     final results = await _repository.searchPosts(query);
  //     searchResults.value = results;
  //   } catch (e) {
  //     Get.snackbar('خطأ', 'فشل في البحث: ${e.toString()}');
  //   } finally {
  //     isSearching.value = false;
  //   }
  // }

  // حذف منشور
  Future<void> deletePost(int postId) async {
    try {
      // عرض رسوم الحذف المتحركة
      animatingPostId.value = postId;
      showDeleteAnimation.value = true;
      
      // إخفاء الرسوم المتحركة بعد فترة
      Future.delayed(Duration(milliseconds: 1500), () {
        showDeleteAnimation.value = false;
      });
      
      // حذف المنشور من الخادم
      final success = await _repository.deletePost(postId);
      
      if (success) {
        // حذف المنشور من جميع القوائم
        posts.removeWhere((p) => p.id == postId);
        collegePosts.removeWhere((p) => p.id == postId);
        savedPosts.removeWhere((p) => p.id == postId);
        myPosts.removeWhere((p) => p.id == postId);
        searchResults.removeWhere((p) => p.id == postId);
        
        // عرض رسالة نجاح
        Get.snackbar(
          'نجاح',
          'تم حذف المنشور بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حذف المنشور: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // تحديد نوع الملف من امتداده
  String _getFileTypeFromExtension(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'ogg', 'm4a'].contains(extension)) {
      return 'audio';
    } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extension)) {
      return 'document';
    } else {
      return 'file';
    }
  }
  // الحصول على تقدم رفع ملف معين
  double getFileUploadProgress(String fileId) {
    return uploadProgress[fileId]?.value ?? 0.0;
  }
  
  // التحقق مما إذا كان الملف قيد الرفع
  bool isFileUploading(String fileId) {
    return uploadingFiles.contains(fileId);
  }
  
  // التحقق مما إذا كان الملف تم رفعه بنجاح
  bool isFileUploaded(String fileId) {
    return uploadedFiles.contains(fileId);
  }
  
  // التحقق مما إذا كان الملف فشل في الرفع
  bool isFileUploadFailed(String fileId) {
    return failedUploads.contains(fileId);
  }
}
