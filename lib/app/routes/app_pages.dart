import 'package:get/get.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/modules/auth/views/forgot_password_view.dart';
import 'package:student_app/modules/auth/views/reset_password_view.dart';
import 'package:student_app/modules/auth/views/verify_reset_code_view.dart';
import 'package:student_app/modules/chats/bindings/blocked_users_binding.dart';
import 'package:student_app/modules/chats/bindings/create_new_chat_binding.dart';
import 'package:student_app/modules/chats/views/pages/blocked_users_view.dart';
import 'package:student_app/modules/chats/views/pages/new_chat.dart';
import 'package:student_app/modules/settings/api/views/api_settings_page.dart';
import 'package:student_app/modules/settings/appearance_settings/views/pages/appearance_settings_page.dart';


import '../../core/themes/app_theme.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/home/bindinges/home_binding.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/home/views/pages/profile_page.dart';
import '../../modules/settings/appearance_settings/controllers/appearance_settings_controller.dart';
import '../../modules/settings/controllers/settings_controller.dart';
import '../../modules/settings/help_support_module/controllers/help_support_controller.dart';
import '../../modules/settings/help_support_module/views/pages/contact_info_page.dart';
import '../../modules/settings/help_support_module/views/pages/faq_page.dart';
import '../../modules/settings/help_support_module/views/pages/help_support_main_page.dart';
import '../../modules/settings/help_support_module/views/pages/send_complaint_feedback_page.dart';
import '../../modules/settings/help_support_module/views/pages/user_guide_page.dart';
import '../../modules/settings/language_settings/controllers/language_settings_controller.dart';
import '../../modules/settings/language_settings/views/pages/language_settings_page.dart';
import '../../modules/settings/views/pages/about_app_page.dart';
import '../../modules/settings/views/pages/privacy_policy_page.dart';
import '../../modules/settings/views/pages/settings_main_page.dart';
import '../../modules/settings/views/pages/terms_conditions_page.dart';
import '../../modules/splash/views/splash_screen.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/student_services/grade/grades_coming_soon_view.dart';
import '../../modules/student_services/views/attendance_service/attendance_binding.dart';
import '../../modules/student_services/views/attendance_service/attendance_view.dart';
import '../../modules/student_services/views/attendance_service/course_attendance_details_view.dart';
import '../../modules/student_services/views/exam_service_v2/exam_creation_view.dart';
import '../../modules/student_services/views/exam_service_v2/exam_record_model.dart';
import '../../modules/student_services/views/exam_service_v2/exam_result_view.dart';
import '../../modules/student_services/views/exam_service_v2/exam_taking_view.dart';
import '../../modules/student_services/views/exam_service_v2/exam_view.dart';
import '../../modules/student_services/views/exam_service_v2/utils/exam_binding.dart';
import '../../modules/student_services/views/exam_service_v2/view_more_exams_view.dart';
import '../../modules/student_services/views/library_service/book_detail_view.dart';
import '../../modules/student_services/views/library_service/library_binding.dart';
import '../../modules/student_services/views/library_service/library_view.dart';
import '../../modules/student_services/views/student_schedule_service/schedule_binding.dart';
import '../../modules/student_services/views/student_schedule_service/schedule_view.dart';
import '../../modules/student_services/views/student_tasks_service/tasks_binding.dart';
import '../../modules/student_services/views/student_tasks_service/tasks_view.dart';

// Import Onboarding related files
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/views/onboarding_view.dart';

abstract class AppRoutes {
  static const initial = '/'; // Usually Splash Screen
  static const onboarding = '/onboarding'; // New route for onboarding
  static const login = '/login';
  static const home = '/home';
  static const register = '/register';
  static const String dashboard = '/dashboard';
  static const String schedule = '/schedule';
  static const String tasks = '/tasks';
  static const String grades = '/grades';
  static const String library = '/library';
  static const String book_details = '/library/book-details/:id';
  static const String library_searsh = '/library/search';

  static const String exams = '/exams';
  static const String examDetails = '/exams/details/:code';
  static const String takeExam = '/exams/take/:code';
  static const String examResult = '/exams/results/:code';
  static const String createExam = '/exams/create';
  static const String viewMoreExams = '/exams/view-more/:type';
  static const String attendance = '/attendance';
  static const String courseDetails = '/attendance/course-details';

  static const String aboutApp = '/about';
  static const String termsConditions = '/terms-conditions';
  static const String privacyPolicy = '/privacy-policy';
  static const String apiSettings = '/api-settings';

  static const String forgotPassword = '/forgot-password';
static const String verifyResetCode = '/verify-reset-code';
static const String resetPassword = '/reset-password';
  static const String createNewChat = 
  '/create-new-chat';
  static const String blockedUsers = 
  '/blocked-users';
  // الحصول على مسار بمعلمات
  static String getExamDetailsRoute(String code) => '/exams/details/$code';
  static String getTakeExamRoute(String code) => '/exams/take/$code';
  static String getExamResultRoute(ExamRecord code) => '/exams/results/$code';
  static String getViewMoreExamsRoute(String type) => '/exams/view-more/$type';

  // Settings routes
  static const SETTINGS = '/settings';
  static const ACCOUNT_SECURITY = '/settings/account-security';
  static const SECURITY = '/settings/security';
  static const LOGIN_HISTORY = '/settings/login-history';
  static const ACADEMIC_NOTIFICATIONS = '/settings/academic-notifications';
  static const ADMIN_NOTIFICATIONS = '/settings/admin-notifications';
  static const REMINDERS = '/settings/reminders';
  static const APPEARANCE = '/settings/appearance';
  static const LANGUAGE = '/settings/language';
  static const LANGUAGE_REGION = '/settings/language-region';
  static const FONT_SIZE = '/settings/font-size';
  static const PRIVACY = '/settings/privacy';
  static const STORAGE_DATA = '/settings/storage-data';
  static const BACKUP = '/settings/backup';
  static const VISUAL_AIDS = '/settings/visual-aids';
  static const AUDIO_AIDS = '/settings/audio-aids';
  static const MOTOR_AIDS = '/settings/motor-aids';
  static const LEARNING_PREFERENCES = '/settings/learning-preferences';
  static const LEARNING_TOOLS = '/settings/learning-tools';
  static const ACHIEVEMENTS_SETTINGS = '/settings/achievements';
  static const FRIENDS_SETTINGS = '/settings/friends';
  static const STUDY_GROUPS_SETTINGS = '/settings/study-groups';
  static const ACHIEVEMENT_SHARING = '/settings/achievement-sharing';
  static const NOTIFICATIONS = '/settings/notifications';
  static const ACCESSIBILITY = '/settings/accessibility';
  static const LEARNING = '/settings/learning';
  
  // Help and Support routes
  static const String helpSupport = '/help-support';
  static const String userGuide = '/user-guide';
  static const String faq = '/faq';
  static const String contactInfo = '/contact-info';
  static const String sendComplaintFeedback = '/send-complaint-feedback';
  
  // Social routes
  static const SOCIAL_SETTINGS = '/social';
  static const FRIENDS_LIST = '/social/friends';
  static const STUDY_GROUPS = '/social/study-groups';
  static const ACHIEVEMENTS = '/social/achievements';
  
  // App Info routes
  static const TERMS_CONDITIONS = '/about/terms';
  static const PRIVACY_POLICY = '/about/privacy-policy';
  static const LICENSES = '/about/licenses';
  
  static var profile = '/profile'; // Assuming profile is a part of settings

  // إضافة المزيد من المسارات هنا
}

abstract class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.initial,
      page: () => const SplashView(),
      binding: HomeBinding(), 
    ),
      // Assuming HomeBinding is sufficient for initial setup
    GetPage(
      name: AppRoutes.onboarding, // Add onboarding page
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    // إضافة المزيد من الصفحات هنا
    GetPage(
      name: AppRoutes.tasks,
      page: () => const TasksView(),
      binding: TasksBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      // Assuming dashboard points to TasksView for now based on original code
      page: () => const TasksView(), 
      binding: TasksBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.schedule,
      page: () => const ScheduleView(),
      binding: ScheduleBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.library,
      page: () => LibraryView(),
      binding: LibraryBinding(),
    ),
    GetPage(
      name: AppRoutes.book_details,
      page: () => BookDetailView(),
      binding: LibraryBinding(), // Assuming same binding is okay
    ),
    GetPage(
      name: AppRoutes.library_searsh,
      page: () => LibraryView(), // Assuming search is part of LibraryView
      binding: LibraryBinding(),
    ),
    GetPage(
      name: AppRoutes.exams,
      page: () => ExamView(),
      binding: ExamBinding(),
    ),
    // Note: Original code had issues with duplicate bindings/pages for exam details, etc.
    // These should be reviewed, but are kept similar for now.
    GetPage(
      name: AppRoutes.examDetails,
      page: () => ExamView(), 
      binding: ExamDetailsBinding(), // Consider a dedicated details view/binding
    ),
    GetPage(
      name: AppRoutes.takeExam,
      page: () => ExamTakingView(),
      binding: ExamTakingBinding(),
    ),
    GetPage(
      name: AppRoutes.examResult,
      page: () => ExamResultView(),
      binding: ExamResultBinding(),
    ),
    GetPage(
      name: AppRoutes.createExam,
      page: () => ExamCreationView(),
      binding: ExamCreationBinding(),
    ),
    GetPage(
      name: AppRoutes.viewMoreExams,
      page: () => ViewMoreExamsView(type: Get.parameters['type'] ?? 'defaultType', title: 'Default Title'), // Get type from params
      binding: ExamBinding(),
    ),
    GetPage(
      name: AppRoutes.attendance,
      page: () => AttendanceView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      binding: AttendanceBinding(),
    ),
    GetPage(
      name: AppRoutes.courseDetails,
      page: () => CourseAttendanceDetailsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.grades,
      page: () => const GradesComingSoonView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // Settings pages
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsMainPage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () =>  ProfilePage(),
      binding: SettingsBinding(),
    ),
    // New Appearance and Language Settings Pages
    GetPage(
      name: AppRoutes.APPEARANCE,
      page: () => const AppearanceSettingsPage(),
      binding: AppearanceSettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.LANGUAGE,
      page: () => const LanguageSettingsPage(),
      binding: LanguageSettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // صفحات المعلومات القانونية
    GetPage(
      name: AppRoutes.aboutApp,
      page: () => const AboutAppPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.termsConditions,
      page: () => const TermsConditionsPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // Help & Support Module
    GetPage(
      name: AppRoutes.helpSupport,
      page: () => const HelpSupportMainPage(),
      binding: HelpSupportBinding(),
    ),
    GetPage(
      name: AppRoutes.userGuide,
      page: () => const UserGuidePage(),
      binding: HelpSupportBinding(),
    ),
    GetPage(
      name: AppRoutes.faq,
      page: () => const FAQPage(),
      binding: HelpSupportBinding(),
    ),
    GetPage(
      name: AppRoutes.contactInfo,
      page: () => const ContactInfoPage(),
      binding: HelpSupportBinding(),
    ),
    GetPage(
      name: AppRoutes.sendComplaintFeedback,
      page: () => const SendComplaintFeedbackPage(),
      binding: HelpSupportBinding(),
    ),
    GetPage(
name: AppRoutes.forgotPassword,
page: () => ForgotPasswordView(),
binding: AuthBinding(),
),
GetPage(
name: AppRoutes.verifyResetCode,
page: () => VerifyResetCodeView(),
binding: AuthBinding(),
),
GetPage(
name: AppRoutes.resetPassword,
page: () => ResetPasswordView(),
binding: AuthBinding(),
),
    GetPage(
      name: AppRoutes.createNewChat,
      page: () => CreateNewChatPage(),
      binding: CreateNewChatBinding(),
    ),
    GetPage(
      name: AppRoutes.blockedUsers,
      page: () => const BlockedUsersView(),
      binding: BlockedUsersBinding(),
    ),
    GetPage(
      name: AppRoutes.apiSettings,
      page: () => const ApiSettingsPage(),
      binding: HomeBinding(),
    ),

  ];
}

// Bindings for dependency injection
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<StorageService>(() => StorageService());
    HelpSupportBinding().dependencies();
  }
}

// New bindings for appearance and language settings
class AppearanceSettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize core services first
    Get.lazyPut<StorageService>(() =>StorageService(), fenix: true);
    Get.lazyPut<AppThemeService>(() => AppThemeService(), fenix: true);
    
    // Initialize appearance settings controller
    Get.lazyPut<AppearanceSettingsController>(() => AppearanceSettingsController());
  }
}

class LanguageSettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize core services first
    Get.lazyPut<StorageService>(() =>StorageService(), fenix: true);
    
    // Initialize language settings controller
    Get.lazyPut<LanguageSettingsController>(() => LanguageSettingsController());
  }
}

class HelpSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpSupportController>(() => HelpSupportController(), fenix: true);
    // Get.lazyPut<HelpController>(() => HelpController());
    // Get.lazyPut<FAQController>(() => FAQController());
    // Get.lazyPut<SupportController>(() => SupportController());
  }
}

class SocialBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<SocialController>(() => SocialController());
    // Get.lazyPut<StudyGroupsController>(() => StudyGroupsController());
    // Get.lazyPut<AchievementsController>(() => AchievementsController());
  }
}

class AppInfoBinding extends Bindings {
  @override
  void dependencies() {
   // Get.lazyPut<AppInfoController>(() => AppInfoController());
  }
}

