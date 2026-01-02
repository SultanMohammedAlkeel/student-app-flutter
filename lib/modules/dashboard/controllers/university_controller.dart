import 'package:get/get.dart';
import '../models/university_model.dart';

class UniversityController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<University> universities = <University>[].obs;
  final Rx<University?> selectedUniversity = Rx<University?>(null);
  final Rx<College?> selectedCollege = Rx<College?>(null);
  final Rx<Building?> selectedBuilding = Rx<Building?>(null);
  final Rx<Department?> selectedDepartment = Rx<Department?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchUniversities();
  }

  Future<void> fetchUniversities() async {
    isLoading.value = true;
    try {
      // هنا سيتم استدعاء API لجلب بيانات الجامعات
      // مؤقتاً سنستخدم بيانات تجريبية
      await Future.delayed(const Duration(seconds: 1));
      
      final mockUniversity = University(
        id: 1,
        name: 'جامعة صنعاء',
        logoUrl: 'assets/images/university_logo.png',
        contactInfo: 'هاتف: 123456789',
        colleges: [
          College(
            id: 1,
            name: 'كلية الحاسوب وتكنولوجيا المعلومات',
            universityId: 1,
            contactInfo: 'هاتف: 123456789',
            departments: [
              Department(
                id: 1,
                name: 'قسم علوم الحاسوب',
                collegeId: 1,
                description: 'قسم متخصص في علوم الحاسوب والبرمجة',
              ),
              Department(
                id: 2,
                name: 'قسم نظم المعلومات',
                collegeId: 1,
                description: 'قسم متخصص في نظم المعلومات وقواعد البيانات',
              ),
            ],
            buildings: [
              Building(
                id: 1,
                name: 'مبنى الحاسبات',
                location: 'جوار مبنى العلوم التطبيقية',
                description: 'مبنى يضم العديد من القاعات الدراسية',
              ),
            ],
          ),
          College(
            id: 2,
            name: 'كلية الهندسة',
            universityId: 1,
            contactInfo: 'هاتف: 987654321',
            departments: [
              Department(
                id: 3,
                name: 'قسم الهندسة المدنية',
                collegeId: 2,
                description: 'قسم متخصص في الهندسة المدنية والإنشاءات',
              ),
              Department(
                id: 4,
                name: 'قسم الهندسة الكهربائية',
                collegeId: 2,
                description: 'قسم متخصص في الهندسة الكهربائية والإلكترونيات',
              ),
            ],
            buildings: [
              Building(
                id: 3,
                name: 'مبنى الهندسة',
                location: 'جوار مبنى رئاسة الجامعة',
                description: 'مبنى يضم العديد من المعامل والقاعات الدراسية',
              ),
            ],
          ),
        ],
      );
      
      universities.add(mockUniversity);
      selectedUniversity.value = mockUniversity;
      
    } catch (e) {
      print('خطأ في جلب بيانات الجامعات: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectUniversity(University university) {
    selectedUniversity.value = university;
    selectedCollege.value = null;
    selectedBuilding.value = null;
    selectedDepartment.value = null;
  }

  void selectCollege(College college) {
    selectedCollege.value = college;
    selectedBuilding.value = null;
    selectedDepartment.value = null;
  }

  void selectBuilding(Building building) {
    selectedBuilding.value = building;
  }

  void selectDepartment(Department department) {
    selectedDepartment.value = department;
  }
}
