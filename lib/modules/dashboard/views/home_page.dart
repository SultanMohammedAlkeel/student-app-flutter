import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/themes/colors.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../models/service_model.dart';
import 'widgets/futuristic_service_card.dart';
import 'widgets/futuristic_data_section.dart';
import 'widgets/futuristic_info_card.dart';

class FuturisticHomePage extends StatefulWidget {
  const FuturisticHomePage({Key? key}) : super(key: key);

  @override
  State<FuturisticHomePage> createState() => _FuturisticHomePageState();
}

class _FuturisticHomePageState extends State<FuturisticHomePage>
    with SingleTickerProviderStateMixin {
  final HomePageController _controller = Get.find<HomePageController>();
  final HomeController _homeController = Get.find<HomeController>();
  final ScrollController _scrollController = ScrollController();
  late List<ServiceModel> _services;

  // حالة توسيع الأقسام
  final RxBool _isLecturesExpanded = true.obs;
  final RxBool _isTasksExpanded = true.obs;

  // مؤشر الخدمة المحددة
  final RxInt _selectedServiceIndex = (-1).obs;

  @override
  void initState() {
    super.initState();
    _services = ServiceModel.getDefaultServices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = Get.isDarkMode;
      final bgColor = isDarkMode ? Colors.black : Colors.grey[100];
      final textColor = isDarkMode ? Colors.white : Colors.black87;
      final secondaryTextColor =
          isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;

      return Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(isDarkMode, textColor),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [
                      Colors.black,
                      Colors.blueGrey[900]!,
                    ]
                  : [
                      Colors.blue[50]!,
                      Colors.grey[100]!,
                    ],
            ),
          ),
          child: SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child:
                        _buildHeader(isDarkMode, textColor, secondaryTextColor),
                  ),
                  SliverToBoxAdapter(
                    child: _buildServicesGrid(isDarkMode),
                  ),
                  SliverToBoxAdapter(
                    child: FuturisticDataSection(
                      title: 'محاضرات اليوم',
                      accentColor: Colors.blue,
                      isDarkMode: isDarkMode,
                      isExpanded: _isLecturesExpanded.value,
                      onExpand: () => _isLecturesExpanded.toggle(),
                      children: [
                        _buildTodayLectures(isDarkMode),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FuturisticDataSection(
                      title: 'المهام القادمة',
                      accentColor: Colors.purple,
                      isDarkMode: isDarkMode,
                      isExpanded: _isTasksExpanded.value,
                      onExpand: () => _isTasksExpanded.toggle(),
                      children: [
                        _buildUpcomingTasks(isDarkMode),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: const SizedBox(height: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(isDarkMode),
      );
    });
  }

  AppBar _buildAppBar(bool isDarkMode, Color textColor) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: textColor,
          ),
          onPressed: () {
            _controller.toggleTheme();
          },
        ),
        IconButton(
          icon: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_outlined,
                color: textColor,
              ),
              if (_controller.notificationsCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_controller.notificationsCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            // فتح الإشعارات
          },
        ),
      ],
    );
  }

  Widget _buildHeader(
      bool isDarkMode, Color textColor, Color secondaryTextColor) {
    HomeController homeController = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً،',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _homeController.userData['name'] ?? 'طالب',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يوم جديد مليء بالفرص التعليمية',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      homeController.getPrimaryColor(),
                      homeController.getSecondaryColor(),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: homeController.getPrimaryColor().withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  image:
                      // ignore: unnecessary_null_comparison
                      _homeController.cachedImage != null
                          ? DecorationImage(
                              image: _homeController.cachedImage.value != null
                                  ? MemoryImage(
                                      _homeController.cachedImage.value!)
                                  : const AssetImage(
                                          'assets/images/default_user.png')
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                ),

                // ignore: unnecessary_null_comparison
                child: _homeController.cachedImage == null
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white.withOpacity(0.9),
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          FuturisticInfoCard(
            title: 'الفصل الدراسي الحالي',
            subtitle: 'الفصل الثاني - 2025',
            icon: Icons.calendar_today_rounded,
            accentColor: homeController.getPrimaryColor(),
            isDarkMode: isDarkMode,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: homeController.getPrimaryColor(),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: homeController.getPrimaryColor().withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Text(
                'نشط',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'الخدمات الطلابية',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              return Obx(() {
                final isSelected = _selectedServiceIndex.value == index;
                return FuturisticServiceCard(
                  title: service.title,
                  description: service.description ?? 'خدمة تعليمية',
                  icon: service.icon,
                  primaryColor: service.color,
                  secondaryColor: service.secondaryColor,
                  notificationsCount: service.notificationsCount,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    _selectedServiceIndex.value = isSelected ? -1 : index;
                    if (!isSelected) {
                      Future.delayed(const Duration(milliseconds: 1500), () {
                        _handleServiceSelected(service);
                      });
                    }
                  },
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodayLectures(bool isDarkMode) {
    final lectures = [
      {
        'title': 'برمجة تطبيقات الويب',
        'time': '10:00 - 11:30',
        'location': 'قاعة 101 - مبنى التقنية',
        'color': Colors.blue,
      },
      {
        'title': 'قواعد البيانات المتقدمة',
        'time': '12:00 - 1:30',
        'location': 'معمل الحاسب - مبنى العلوم',
        'color': Colors.purple,
      },
      {
        'title': 'تطوير تطبيقات الجوال',
        'time': '2:00 - 3:30',
        'location': 'قاعة 305 - مبنى الهندسة',
        'color': Colors.teal,
      },
    ];

    return Column(
      children: List.generate(lectures.length, (index) {
        final lecture = lectures[index];
        return FuturisticInfoCard(
          title: lecture['title'] as String,
          subtitle: '${lecture['time']} | ${lecture['location']}',
          icon: Icons.school_rounded,
          accentColor: lecture['color'] as Color,
          isDarkMode: isDarkMode,
          isHighlighted: index == 0, // تمييز المحاضرة الأولى
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (lecture['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: lecture['color'] as Color,
                width: 1,
              ),
            ),
            child: Text(
              'بعد ${index + 1} ساعة',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: lecture['color'] as Color,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUpcomingTasks(bool isDarkMode) {
    final tasks = [
      {
        'title': 'تسليم مشروع برمجة الويب',
        'course': 'برمجة تطبيقات الويب',
        'dueDate': DateTime.now().add(const Duration(days: 2)),
        'priority': 'عالية',
        'priorityColor': Colors.red,
      },
      {
        'title': 'تحضير عرض تقديمي',
        'course': 'مهارات الاتصال',
        'dueDate': DateTime.now().add(const Duration(days: 4)),
        'priority': 'متوسطة',
        'priorityColor': Colors.orange,
      },
      {
        'title': 'حل تمارين الفصل الخامس',
        'course': 'قواعد البيانات المتقدمة',
        'dueDate': DateTime.now().add(const Duration(days: 1)),
        'priority': 'عالية',
        'priorityColor': Colors.red,
        'isHighlighted': true,
      },
    ];

    return Column(
      children: List.generate(tasks.length, (index) {
        final task = tasks[index];
        final dueDate = task['dueDate'] as DateTime;
        final formattedDate = DateFormat('dd/MM/yyyy').format(dueDate);
        final isHighlighted = task['isHighlighted'] as bool? ?? false;

        return FuturisticInfoCard(
          title: task['title'] as String,
          subtitle: '${task['course']} - تاريخ التسليم: $formattedDate',
          icon: Icons.assignment_rounded,
          accentColor: task['priorityColor'] as Color,
          isDarkMode: isDarkMode,
          isHighlighted: isHighlighted,
          onTap: () {
            // الانتقال إلى تفاصيل المهمة
            final studyTasksService = _services.firstWhere(
              (service) => service.id == 'study_tasks',
            );
            _handleServiceSelected(studyTasksService);
          },
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (task['priorityColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: task['priorityColor'] as Color,
                width: 1,
              ),
            ),
            child: Text(
              task['priority'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: task['priorityColor'] as Color,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    HomeController homeController = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            homeController.getPrimaryColor(),
            homeController.getSecondaryColor(),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: homeController.getPrimaryColor().withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // إضافة مهمة جديدة
            final studyTasksService = _services.firstWhere(
              (service) => service.id == 'study_tasks',
            );
            _handleServiceSelected(studyTasksService);
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'مهمة جديدة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleServiceSelected(ServiceModel service) {
    Get.toNamed(service.route);
  }
}
