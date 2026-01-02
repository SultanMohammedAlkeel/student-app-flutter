import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/posts/controllers/posts_controller.dart';
import 'package:student_app/modules/posts/views/widgets/post_card.dart';
import 'package:student_app/modules/posts/views/widgets/create_post_modal.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../posts/views/widgets/search_posts_view.dart';

class PostsView extends StatefulWidget {
  const PostsView({Key? key}) : super(key: key);

  @override
  State<PostsView> createState() => _PostsViewState();
}

class _PostsViewState extends State<PostsView>
    with SingleTickerProviderStateMixin {
  final PostsController _controller = Get.find<PostsController>();
  final HomeController _homeController = Get.find<HomeController>();
  late TabController _tabController;
  final RxBool _isRefreshing = false.obs;
  final RxInt _highlightedPostId = (-1).obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      _controller.updateActiveTab(_tabController.index);
    });

    // تحميل المنشورات عند بدء الصفحة
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    await _controller.fetchPosts();
  }

  Future<void> _refreshPosts() async {
    _isRefreshing.value = true;
    await _controller.fetchPosts();
    _isRefreshing.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = _controller.isLoading.value;
      if (isLoading) {
        return Center(
          child: Lottie.asset(
            'assets/animations/loading_posts.json',
            width: 200,
            height: 200,
          ),
        );
      }
      final isDarkMode = Get.isDarkMode;
      final bgColor =
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
      final cardColor =
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
      final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
      final secondaryTextColor =
          isDarkMode ? Colors.grey[400]! : AppColors.textSecondary;
      final iconColor = _homeController.getPrimaryColor();
      final highlightColor = _homeController.getPrimaryColor().withOpacity(0.1);

      return Scaffold(
        backgroundColor: bgColor,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(cardColor, textColor, iconColor),
                _buildTabBar(cardColor, textColor, secondaryTextColor),
                Expanded(
                  child: _buildPostsList(
                      bgColor, textColor, secondaryTextColor, highlightColor),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Obx(() => _controller.showAddButton.value
            ? _buildAddPostButton()
            : SizedBox.shrink()),
      );
    });
  }

  Widget _buildHeader(Color cardColor, Color textColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'المنشورات',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(width: 10),
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: 2,
              intensity: 0.7,
              color: _homeController.getPrimaryColor(),
              boxShape: NeumorphicBoxShape.circle(),
            ),
            onPressed: _showCreatePostModal,
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
          ),
          Spacer(),
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: 2,
              intensity: 0.7,
              color: cardColor,
              boxShape: NeumorphicBoxShape.circle(),
            ),
            onPressed: () => _openSearch(),
            child: Icon(
              Icons.search,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
      Color cardColor, Color textColor, Color secondaryTextColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: _homeController.getPrimaryColor(),
        unselectedLabelColor: secondaryTextColor,
        indicatorColor: _homeController.getPrimaryColor(),
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Tajawal',
        ),
        tabs: [
          Tab(text: 'الجامعة'),
          Tab(text: 'الكلية'),
          Tab(text: 'المحفوظة'),
          Tab(text: 'منشوراتي'),
        ],
      ),
    );
  }

  Widget _buildPostsList(Color bgColor, Color textColor,
      Color secondaryTextColor, Color highlightColor) {
    return Obx(() {
      final posts = _controller.getPostsByActiveTab();

      if (_controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/loading_posts.json',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              Text(
                'جاري تحميل المنشورات...',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      }

      if (posts.isEmpty) {
        return _buildEmptyState(bgColor, textColor, secondaryTextColor);
      }

      return RefreshIndicator(
        onRefresh: _refreshPosts,
        color: _homeController.getPrimaryColor(),
        child: ListView.builder(
          controller: _controller.scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: posts.length + 1, // +1 للمؤشر في النهاية
          itemBuilder: (context, index) {
            if (index == posts.length) {
              return _buildLoadMoreIndicator();
            }

            final post = posts[index];
            final isHighlighted = _highlightedPostId.value == post.id;

            return AnimatedContainer(
              duration: Duration(milliseconds: 500),
              color: isHighlighted ? highlightColor : bgColor,
              child: PostCard(
                post: post,
                isLastItem: index == posts.length - 1,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(
      Color bgColor, Color textColor, Color secondaryTextColor) {
    String message = '';
    String animation = 'assets/animations/empty_posts.json';

    switch (_tabController.index) {
      case 1: // الكلية
        message = 'لا توجد منشورات للكلية حالياً';
        break;
      case 2: // المحفوظة
        message = 'لم تقم بحفظ أي منشورات بعد';
        animation = 'assets/animations/empty_posts.json';
        break;
      case 3: // منشوراتي
        message = 'لم تقم بنشر أي منشورات بعد';
        animation = 'assets/animations/empty_posts.json';
        break;
      case 0: // الكل
      default:
        message = 'لا توجد منشورات حالياً';
        break;
    }

    return Container(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              animation,
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _tabController.index == 3
                  ? 'انقر على زر الإضافة لإنشاء منشور جديد'
                  : 'اسحب للأسفل للتحديث',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: secondaryTextColor,
              ),
            ),
            if (_tabController.index == 3)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: NeumorphicButton(
                  style: NeumorphicStyle(
                    color: _homeController.getPrimaryColor(),
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                  ),
                  onPressed: _showCreatePostModal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'إنشاء منشور جديد',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (_controller.isLoadingMore.value) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  _homeController.getPrimaryColor()),
            ),
          ),
        );
      }
      return SizedBox(height: 80); // مساحة إضافية في النهاية
    });
  }

  Widget _buildAddPostButton() {
    return NeumorphicFloatingActionButton(
      style: NeumorphicStyle(
        color: _homeController.getPrimaryColor(),
        boxShape: NeumorphicBoxShape.circle(),
      ),
      onPressed: _showCreatePostModal,
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  void _showCreatePostModal() {
    Get.bottomSheet(
      CreatePostModal(),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void _openSearch() async {
    final result = await Get.to(() => SearchPostsView());

    if (result != null && result is int) {
      _highlightSelectedPost(result);
    }
  }

  void _highlightSelectedPost(int postId) {
    _tabController.animateTo(0);
    _highlightedPostId.value = postId;

    final index = _controller.posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      Future.delayed(Duration(milliseconds: 300), () {
        _controller.scrollController.animateTo(
          index * 400.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        Future.delayed(Duration(seconds: 2), () {
          _highlightedPostId.value = -1;
        });
      });
    }
  }
}
