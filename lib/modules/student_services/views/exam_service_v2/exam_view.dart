import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/themes/colors.dart';
import 'neumorphic_widgets.dart';
import 'exam_controller.dart';
import 'exam_search_controller.dart';
import 'widgets/exam_card.dart';
import 'widgets/exam_search_bar.dart';
import 'widgets/most_popular_exams_list.dart';
import 'widgets/recent_exams_list.dart';
import 'widgets/exam_filter_dialog.dart';

class ExamView extends StatelessWidget {
  final ExamController examController = Get.find<ExamController>();
  final ExamSearchController searchController =
      Get.find<ExamSearchController>();

  // متغير لتتبع حالة التمرير
  final RxBool isScrollingDown = false.obs;
  final ScrollController scrollController = ScrollController();

  ExamView({Key? key}) : super(key: key) {
    // إضافة مستمع للتمرير لتتبع اتجاه التمرير
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        isScrollingDown.value = true;
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        isScrollingDown.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Get.isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        child: SafeArea(
          child: Stack(
            children: [
              // المحتوى الرئيسي
              Obx(() => RefreshIndicator(
                    onRefresh: () async {
                      await examController.loadExams();
                      await examController.loadPopularExams();
                      await examController.loadRecentExams();
                      await examController.loadMyExams();
                    },
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.only(bottom: 80),
                      children: [
                        // العنوان وشريط البحث
                        _buildHeader(),

                        // شريط البحث
                        ExamSearchBar(
                          controller: searchController.searchTextController,
                          onChanged: (value) {
                            // استخدام الدالة المعدلة لحل مشكلة اختفاء الحرف وإخفاء لوحة المفاتيح
                            searchController
                                .setSearchQueryWithoutStateChange(value);
                            searchController.searchWithDebounce();
                          },
                          onSubmitted: (value) {
                            searchController.setSearchQuery(value);
                            searchController.search();
                          },
                          onClear: () {
                            searchController.clearSearch();
                          },
                          onFilterTap: () {
                            showExamFilterDialog(context);
                          },
                          hasActiveFilters:
                              searchController.hasActiveFilters.value,
                        ),
                        // عنوان امتحاناتي
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'امتحاناتي',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Get.isDarkMode
                                      ? AppColors.darkTextColor
                                      : AppColors.textColor,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Get.toNamed('/exams/my-exams');
                                },
                                icon: Icon(Icons.arrow_forward),
                                label: Text('عرض الكل'),
                              ),
                            ],
                          ),
                        ),

                        // قائمة امتحاناتي
                        _buildMyExamsList(),

                        // عرض الامتحانات الشائعة
                        MostPopularExamsList(
                          exams: examController.popularExams,
                          isLoading: examController.isPopularExamsLoading.value,
                          onViewMore: () {
                            Get.toNamed('/exams/popular');
                          },
                        ),

                        // عرض الامتحانات الحديثة
                        RecentExamsList(
                          exams: examController.recentExams,
                          isLoading: examController.isRecentExamsLoading.value,
                          onViewMore: () {
                            Get.toNamed('/exams/recent');
                          },
                        ),

                        // عنوان قائمة الامتحانات
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'جميع الامتحانات',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Get.isDarkMode
                                      ? AppColors.darkTextColor
                                      : AppColors.textColor,
                                ),
                              ),
                              Obx(
                                () => searchController.hasActiveFilters.value
                                    ? TextButton.icon(
                                        onPressed: () {
                                          searchController.clearSearch();
                                          examController.resetFilter();
                                        },
                                        icon: Icon(Icons.filter_list_off),
                                        label: Text('إلغاء الفلتر'),
                                      )
                                    : SizedBox(),
                              ),
                            ],
                          ),
                        ),

                        // قائمة الامتحانات
                        _buildExamsList(),
                      ],
                    ),
                  )),

              // زر الإضافة العائم
              // Obx(() => AnimatedPositioned(
              //       duration: Duration(milliseconds: 300),
              //       curve: Curves.easeInOut,
              //       right: 16,
              //       bottom: isScrollingDown.value ? -80 : 16,
              //       child: NeumorphicFloatingActionButton(
              //         onPressed: () {
              //           Get.toNamed('/exams/create');
              //         },
              //         child: Icon(
              //           Icons.add,
              //           color: Colors.white,
              //         ),
              //       ),
              //     )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نماذج الامتحانات',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.textColor,
                ),
              ),
              Text(
                'استعرض واختبر نفسك',
                style: TextStyle(
                  fontSize: 16,
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor.withOpacity(0.7)
                      : AppColors.textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          // NeumorphicCard(
          //   padding: EdgeInsets.all(8),
          //   depth: 3,
          //   intensity: 1,
          //   child: IconButton(
          //     icon: Icon(
          //       Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          //       color: Get.isDarkMode
          //           ? AppColors.darkTextColor
          //           : AppColors.textColor,
          //     ),
          //     onPressed: () {
          //       Get.changeThemeMode(
          //         Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildExamsList() {
    return Obx(() {
      if (examController.isLoading.value) {
        return Center(
          child: Lottie.asset(
            'assets/animations/loading_posts.json',
            width: 200,
            height: 200,
          ),
        );
      }

      if (examController.exams.isEmpty) {
        return Center(
          child: Column(
            children: [
              Lottie.asset(
                'assets/animations/no_results.json',
                width: 200,
                height: 200,
              ),
              Text(
                'لا توجد امتحانات متاحة',
                style: TextStyle(
                  fontSize: 16,
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.textColor,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: examController.exams.length,
        itemBuilder: (context, index) {
          final exam = examController.exams[index];
          return ExamCard(
            exam: exam,
            onTap: () {
              Get.toNamed('/exams/take/${exam.code}');
            },
          );
        },
      );
    });
  }

  Widget _buildMyExamsList() {
    return Obx(() {
      if (examController.isMyExamsLoading.value) {
        return Center(
          child: Lottie.asset(
            'assets/animations/loading_posts.json',
            width: 200,
            height: 200,
          ),
        );
      }

      if (examController.myExams.isEmpty) {
        return Center(
          child: Column(
            children: [
              Lottie.asset(
                'assets/animations/no_results.json',
                width: 200,
                height: 200,
              ),
              Text(
                'لم تقم بإجراء أي امتحان بعد',
                style: TextStyle(
                  fontSize: 16,
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.textColor,
                ),
              ),
            ],
          ),
        );
      }

      // عرض أحدث 3 امتحانات فقط
      final displayedExams = examController.myExams.length > 3
          ? examController.myExams.sublist(0, 3)
          : examController.myExams;

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: displayedExams.length,
        itemBuilder: (context, index) {
          final exam = displayedExams[index];
          return ExamCard(
            exam: exam,
            isCompleted: true,
            onTap: () {
              Get.toNamed('/exams/results/${exam.code}');
            },
          );
        },
      );
    });
  }

  void showExamFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExamFilterDialog(
        currentFilter: examController.currentFilter.value,
        onApplyFilter: (filter) {
          examController.applyFilter(filter);
        },
      ),
    );
  }
}
