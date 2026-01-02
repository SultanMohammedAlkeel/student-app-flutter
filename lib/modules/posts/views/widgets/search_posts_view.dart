import 'dart:async';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/services/api_url_service.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'package:student_app/modules/posts/controllers/posts_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:student_app/modules/posts/models/post_model.dart';
import 'package:student_app/data/models/user_model.dart';

import 'post_card.dart';

enum ViewMode { search, userPosts }

class SearchPostsView extends StatefulWidget {
  const SearchPostsView({Key? key}) : super(key: key);

  @override
  State<SearchPostsView> createState() => _SearchPostsViewState();
}

class _SearchPostsViewState extends State<SearchPostsView> {
  HomeController homeController = Get.find<HomeController>();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxInt _selectedFilter = 0.obs; // 0: الكل، 1: المحتوى، 2: المستخدمين
  final RxBool _showAdvancedFilters = false.obs;

  // فلاتر متقدمة
  final Rx<DateTime?> _startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _endDate = Rx<DateTime?>(null);
  final RxString _selectedFileType = 'الكل'.obs;
  final RxString _selectedLikesFilter = 'الكل'.obs;

  // نتائج البحث
  final RxList<Post> _searchResults = <Post>[].obs;
  final RxList<UserModel> _userResults = <UserModel>[].obs;
  final RxList<Post> _userPosts = <Post>[].obs;

  // حالة العرض
  final Rx<ViewMode> _viewMode = ViewMode.search.obs;
  final RxInt _selectedUserId = (-1).obs;
  final RxBool _isLoadingUserPosts = false.obs;

  // تأخير البحث لتحسين الأداء
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // تركيز حقل البحث تلقائياً عند فتح الصفحة
    Future.delayed(Duration(milliseconds: 300), () {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostsController>();

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchHeader(controller),
              _buildFilterTabs(controller),
              Expanded(
                child: Obx(() {
                  if (_viewMode.value == ViewMode.userPosts) {
                    return _buildUserPostsView(controller);
                  } else {
                    return _buildSearchResults(controller);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(PostsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: controller.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: controller.textColor),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: -3,
                    intensity: 0.7,
                    color: controller.cardColor,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    decoration: InputDecoration(
                      hintText: 'ابحث في المنشورات أو المستخدمين...',
                      hintStyle: TextStyle(
                        fontFamily: 'Tajawal',
                        color: controller.secondaryTextColor,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search,
                          color: homeController.getPrimaryColor()),
                      suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: controller.secondaryTextColor),
                              onPressed: () {
                                _searchController.clear();
                                _searchQuery.value = '';
                                _isSearching.value = false;
                                _searchResults.clear();
                                _userResults.clear();
                              },
                            )
                          : SizedBox.shrink()),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                    ),
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: controller.textColor,
                    ),
                    textDirection: TextDirection.rtl,
                    onChanged: (value) {
                      _searchQuery.value = value;
                      _onSearchTextChanged(value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Obx(() => _isSearching.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            homeController.getPrimaryColor()),
                      ),
                    )
                  : NeumorphicButton(
                      style: NeumorphicStyle(
                        color: homeController.getPrimaryColor(),
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(10)),
                      ),
                      onPressed: () => _toggleAdvancedFilters(),
                      child: Icon(
                        Icons.filter_list,
                        color: Colors.white,
                      ),
                    )),
            ],
          ),
          // عرض الفلاتر المتقدمة عند تفعيلها
          Obx(() => _showAdvancedFilters.value
              ? _buildAdvancedFilters(controller)
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(PostsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: controller.cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterTab(controller, 0, 'الكل'),
          _buildFilterTab(controller, 1, 'المحتوى'),
          _buildFilterTab(controller, 2, 'المستخدمين'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(PostsController controller, int index, String title) {
    return Obx(() => GestureDetector(
          onTap: () {
            _selectedFilter.value = index;
            if (_searchQuery.value.isNotEmpty) {
              _performSearch();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedFilter.value == index
                  ? homeController.getPrimaryColor()
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: _selectedFilter.value == index
                    ? Colors.white
                    : controller.secondaryTextColor,
                fontWeight: _selectedFilter.value == index
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ));
  }

  Widget _buildAdvancedFilters(PostsController controller) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: controller.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'فلاتر متقدمة',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              color: controller.textColor,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDateFilter(controller, 'من تاريخ', _startDate,
                    (date) => _startDate.value = date),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDateFilter(controller, 'إلى تاريخ', _endDate,
                    (date) => _endDate.value = date),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  controller,
                  'نوع الملف',
                  ['الكل', 'صورة', 'فيديو', 'صوت', 'ملف'],
                  _selectedFileType,
                  (value) => _selectedFileType.value = value,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDropdownFilter(
                  controller,
                  'الإعجابات',
                  ['الكل', 'أكثر من 10', 'أكثر من 50', 'أكثر من 100'],
                  _selectedLikesFilter,
                  (value) => _selectedLikesFilter.value = value,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeumorphicButton(
                style: NeumorphicStyle(
                  color: homeController.getPrimaryColor(),
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _applyFilters();
                  _toggleAdvancedFilters();
                },
                child: Text(
                  'تطبيق',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              NeumorphicButton(
                style: NeumorphicStyle(
                  color: controller.cardColor,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                  border: NeumorphicBorder(
                      color: homeController.getPrimaryColor().withOpacity(0.5)),
                ),
                onPressed: () {
                  _resetFilters();
                },
                child: Text(
                  'إعادة ضبط',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: homeController.getPrimaryColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(PostsController controller, String label,
      Rx<DateTime?> dateValue, Function(DateTime?) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            color: controller.secondaryTextColor,
          ),
        ),
        SizedBox(height: 5),
        Neumorphic(
          style: NeumorphicStyle(
            depth: -2,
            intensity: 0.6,
            color: controller.cardColor,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
          ),
          child: InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: Get.context!,
                initialDate: dateValue.value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: homeController.getPrimaryColor(),
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: homeController.getPrimaryColor(),
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Obx(() => Text(
                    dateValue.value != null
                        ? '${dateValue.value!.day}/${dateValue.value!.month}/${dateValue.value!.year}'
                        : 'اختر التاريخ',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: dateValue.value != null
                          ? controller.textColor
                          : controller.secondaryTextColor,
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(
    PostsController controller,
    String label,
    List<String> options,
    RxString selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            color: controller.secondaryTextColor,
          ),
        ),
        SizedBox(height: 5),
        Neumorphic(
          style: NeumorphicStyle(
            depth: -2,
            intensity: 0.6,
            color: controller.cardColor,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: DropdownButton<String>(
              value: selectedValue.value,
              isExpanded: true,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down,
                  color: homeController.getPrimaryColor()),
              dropdownColor: controller.cardColor,
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: controller.textColor,
              ),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(PostsController controller) {
    return Obx(() {
      if (_isSearching.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/searching.json',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                'جاري البحث...',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: controller.textColor,
                ),
              ),
            ],
          ),
        );
      }

      if (_searchQuery.value.isEmpty) {
        return _buildSearchSuggestions(controller);
      }

      // عرض نتائج البحث حسب الفلتر المحدد
      if (_selectedFilter.value == 2 && _userResults.isNotEmpty) {
        return _buildUserSearchResults(controller);
      }

      if (_searchResults.isEmpty) {
        return _buildNoResultsFound(controller);
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final post = _searchResults[index];
          return _buildPostResultItem(controller, post);
        },
      );
    });
  }

  Widget _buildUserSearchResults(PostsController controller) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          alignment: Alignment.centerRight,
          child: Text(
            'المستخدمون',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: controller.textColor,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 5),
            itemCount: _userResults.length,
            itemBuilder: (context, index) {
              final user = _userResults[index];
              return _buildUserResultItem(controller, user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserResultItem(PostsController controller, UserModel user) {
    final ApiUrlService _apiUrlService = Get.find<ApiUrlService>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: controller.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: homeController.getPrimaryColor().withOpacity(0.5),
              width: 2,
            ),
          ),
          child: ClipOval(
child: CachedNetworkImage(
  imageUrl: _apiUrlService.getImageUrl(user.imageUrl), // استخدام الخدمة هنا
  fit: BoxFit.cover,
  placeholder: (context, url) => CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(
        homeController.getPrimaryColor()),
    strokeWidth: 2,
  ),
  errorWidget: (context, url, error) => Image.asset(
    'assets/images/user_profile.jpg',
    fit: BoxFit.cover,
  ),
),
          ),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            color: controller.textColor,
          ),
        ),
        subtitle: Text(
          'عرض منشورات المستخدم',
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: homeController.getPrimaryColor(),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: controller.secondaryTextColor,
        ),
        onTap: () {
          _showUserPosts(controller, user.id!);
        },
      ),
    );
  }

  Widget _buildUserPostsView(PostsController controller) {
    return Obx(() {
      if (_isLoadingUserPosts.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/loading_posts.json',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                'جاري تحميل منشورات المستخدم...',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: controller.textColor,
                ),
              ),
            ],
          ),
        );
      }

      if (_userPosts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/no_results.json',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                'لا توجد منشورات لهذا المستخدم',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: controller.textColor,
                ),
              ),
              const SizedBox(height: 15),
              NeumorphicButton(
                style: NeumorphicStyle(
                  color: homeController.getPrimaryColor(),
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _viewMode.value = ViewMode.search;
                },
                child: Text(
                  'العودة للبحث',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: controller.textColor),
                  onPressed: () {
                    _viewMode.value = ViewMode.search;
                  },
                ),
                Text(
                  'منشورات ${_userPosts.first.userName}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: controller.textColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                final post = _userPosts[index];
                return _buildPostResultItem(controller, post);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPostResultItem(PostsController controller, Post post) {
    return PostCard(
      post: post,
      isLastItem: false,
    );
  }

  // ignore: unused_element
  Widget _buildInteractionButton({
    required IconData icon,
    required Color color,
    required int? count,
    required Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            if (count != null) ...[
              SizedBox(width: 5),
              Text(
                count.toString(),
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(PostsController controller) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/search_suggestion.json',
              width: 400,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'ابحث عن المنشورات والمستخدمين',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: controller.textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'اكتب كلمات البحث في الأعلى',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: controller.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildSearchChip(controller, 'الجامعة'),
                _buildSearchChip(controller, 'الكلية'),
                _buildSearchChip(controller, 'الاختبارات'),
                _buildSearchChip(controller, 'المحاضرات'),
                _buildSearchChip(controller, 'الأنشطة'),
                _buildSearchChip(controller, 'الطلاب'),
                _buildSearchChip(controller, 'المعلمين'),
                _buildSearchChip(controller, 'المكتبة'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip(PostsController controller, String keyword) {
    return GestureDetector(
      onTap: () {
        _searchController.text = keyword;
        _searchQuery.value = keyword;
        _performSearch();
      },
      child: Chip(
        label: Text(
          keyword,
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.white,
          ),
        ),
        backgroundColor: homeController.getPrimaryColor(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
    );
  }

  Widget _buildNoResultsFound(PostsController controller) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/no_results.json',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: controller.textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'جرب كلمات بحث أخرى أو تعديل الفلاتر',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: controller.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            NeumorphicButton(
              style: NeumorphicStyle(
                color: homeController.getPrimaryColor(),
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
              ),
              onPressed: () => _resetFilters(),
              child: Text(
                'إعادة ضبط الفلاتر',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // وظائف مساعدة
  void _onSearchTextChanged(String query) {
    if (query.isEmpty) {
      _searchResults.clear();
      _userResults.clear();
      _isSearching.value = false;
      return;
    }

    _isSearching.value = true;

    // تأخير البحث لتجنب الطلبات المتكررة أثناء الكتابة
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final controller = Get.find<PostsController>();
    final query = _searchQuery.value;

    if (query.isEmpty) return;

    // تنفيذ البحث حسب الفلتر المحدد
    switch (_selectedFilter.value) {
      case 1: // المحتوى
        _performContentSearch(controller, query);
        break;
      case 2: // المستخدمين
        _performUserSearch(controller, query);
        break;
      case 0: // الكل
      default:
        _performFullSearch(controller, query);
        break;
    }
  }

  Future<void> _performContentSearch(
      PostsController controller, String query) async {
    try {
      final results =
          await controller.searchPostsByContent(query, _getSearchFilters());
      _searchResults.value = results;
      _userResults.clear();
      _isSearching.value = false;
    } catch (e) {
      _handleSearchError(e);
    }
  }

  Future<void> _performUserSearch(
      PostsController controller, String query) async {
    try {
      final results = await controller.searchUsers(query);
      _userResults.value = results;
      _searchResults.clear();
      _isSearching.value = false;
    } catch (e) {
      _handleSearchError(e);
    }
  }

  Future<void> _performFullSearch(
      PostsController controller, String query) async {
    try {
      final results = await controller.searchPosts(query, _getSearchFilters());
      _searchResults.value = results;

      // إذا كان البحث عاماً، نبحث أيضاً عن المستخدمين
      final userResults = await controller.searchUsers(query);
      _userResults.value = userResults;

      _isSearching.value = false;
    } catch (e) {
      _handleSearchError(e);
    }
  }

  void _showUserPosts(PostsController controller, int userId) {
    _isLoadingUserPosts.value = true;
    _selectedUserId.value = userId;
    _viewMode.value = ViewMode.userPosts;

    controller.getUserPosts(userId).then((posts) {
      _userPosts.value = posts;
      _isLoadingUserPosts.value = false;
    }).catchError((error) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل منشورات المستخدم: ${error.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      _isLoadingUserPosts.value = false;
    });
  }

  Map<String, dynamic> _getSearchFilters() {
    final filters = <String, dynamic>{};

    if (_startDate.value != null) {
      filters['start_date'] = _startDate.value!.toIso8601String();
    }

    if (_endDate.value != null) {
      filters['end_date'] = _endDate.value!.toIso8601String();
    }

    if (_selectedFileType.value != 'الكل') {
      filters['file_type'] = _selectedFileType.value;
    }

    if (_selectedLikesFilter.value != 'الكل') {
      switch (_selectedLikesFilter.value) {
        case 'أكثر من 10':
          filters['min_likes'] = 10;
          break;
        case 'أكثر من 50':
          filters['min_likes'] = 50;
          break;
        case 'أكثر من 100':
          filters['min_likes'] = 100;
          break;
      }
    }

    return filters;
  }

  void _toggleAdvancedFilters() {
    _showAdvancedFilters.value = !_showAdvancedFilters.value;
  }

  void _applyFilters() {
    if (_searchQuery.value.isNotEmpty) {
      _performSearch();
    }
  }

  void _resetFilters() {
    _startDate.value = null;
    _endDate.value = null;
    _selectedFileType.value = 'الكل';
    _selectedLikesFilter.value = 'الكل';

    if (_searchQuery.value.isNotEmpty) {
      _performSearch();
    }
  }

  void _handleSearchError(dynamic error) {
    _isSearching.value = false;
    Get.snackbar(
      'خطأ',
      'فشل في البحث: ${error.toString()}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ignore: unused_element
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} سنة';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} شهر';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  // ignore: unused_element
  IconData _getFileIcon(String? fileType) {
    switch (fileType) {
      case 'صورة':
        return Icons.image;
      case 'فيديو':
        return Icons.video_file;
      case 'صوت':
        return Icons.audio_file;
      case 'ملف':
        return Icons.insert_drive_file;
      default:
        return Icons.description;
    }
  }

  // ignore: unused_element
  String _getFileName(String? fileUrl) {
    if (fileUrl == null) return 'ملف';
    final parts = fileUrl.split('/');
    return parts.last;
  }

  // ignore: unused_element
  String _getFileSize(int? size) {
    if (size == null) return '';

    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
