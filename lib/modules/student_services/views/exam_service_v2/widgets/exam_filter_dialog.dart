import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/themes/colors.dart';
import '../exam_filter_model.dart';
import '../neumorphic_widgets.dart';
// Ensure this package is added to your pubspec.yaml

class ExamFilterDialog extends StatefulWidget {
  final ExamFilter currentFilter;
  final Function(ExamFilter) onApplyFilter;

  const ExamFilterDialog({
    Key? key,
    required this.currentFilter,
    required this.onApplyFilter,
  }) : super(key: key);

  @override
  _ExamFilterDialogState createState() => _ExamFilterDialogState();
}

class _ExamFilterDialogState extends State<ExamFilterDialog> {
  late ExamFilter filter;
  
  // قوائم الخيارات
  final List<String> types = ['اختيارات', 'صح و خطأ'];
  final List<String> levels = [
    'المستوى الاول',
    'المستوى الثاني',
    'المستوى الثالث',
    'المستوى الرابع',
    'المستوى الخامس',
    'المستوى السادس',
    'المستوى السابع'
  ];
  final List<String> languages = ['عربي', 'انجليزي'];
  final List<Map<String, dynamic>> sortOptions = [
    {'value': 'created_at', 'label': 'الأحدث', 'ascending': false},
    {'value': 'created_at', 'label': 'الأقدم', 'ascending': true},
    {'value': 'name', 'label': 'الاسم (أ-ي)', 'ascending': true},
    {'value': 'name', 'label': 'الاسم (ي-أ)', 'ascending': false},
  ];

  @override
  void initState() {
    super.initState();
    // نسخ الفلتر الحالي
    filter = widget.currentFilter.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: NeumorphicCard(
        depth: 3,
        intensity: 1,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان الفلتر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'فلترة الامتحانات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Get.isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            
            Divider(),
            
            // محتوى الفلتر
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نوع الامتحان
                    _buildFilterSection(
                      title: 'نوع الامتحان',
                      child: _buildChipSelection(
                        options: types,
                        selectedValue: filter.type,
                        onSelected: (value) {
                          setState(() {
                            filter = filter.copyWith(type: value);
                          });
                        },
                      ),
                    ),
                    
                    // المستوى
                    _buildFilterSection(
                      title: 'المستوى',
                      child: _buildChipSelection(
                        options: levels,
                        selectedValue: filter.level,
                        onSelected: (value) {
                          setState(() {
                            filter = filter.copyWith(level: value);
                          });
                        },
                      ),
                    ),
                    
                    // اللغة
                    _buildFilterSection(
                      title: 'اللغة',
                      child: _buildChipSelection(
                        options: languages,
                        selectedValue: filter.language,
                        onSelected: (value) {
                          setState(() {
                            filter = filter.copyWith(language: value);
                          });
                        },
                      ),
                    ),
                    
                    // الترتيب
                    _buildFilterSection(
                      title: 'الترتيب',
                      child: _buildSortSelection(),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // أزرار التطبيق وإعادة التعيين
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      filter = ExamFilter();
                    });
                  },
                  child: Text('إعادة تعيين'),
                ),
                NeumorphicButton(
                  onPressed: () {
                    widget.onApplyFilter(filter);
                    Navigator.of(context).pop();
                  },
                  depth: 3,
                  intensity: 1,
                  child: Text(
                    'تطبيق',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
            ),
          ),
        ),
        child,
        SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildChipSelection({
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // خيار "الكل"
        ChoiceChip(
          label: Text('الكل'),
          selected: selectedValue == null,
          onSelected: (bool isSelected) {
            if (isSelected) {
              onSelected(null);
            }
          },
        ),
        
        ...options.map((option) => ChoiceChip(
          label: Text(option),
          selected: selectedValue == option,
          onSelected: (isSelected) {
            if (isSelected) {
              onSelected(option);
            }
          },
        )),
        
      ],
    );
  }
  
  Widget _buildSortSelection() {
    // البحث عن الخيار المحدد
    int selectedIndex = sortOptions.indexWhere((option) => 
      option['value'] == filter.sortBy && option['ascending'] == filter.ascending);
    
    if (selectedIndex == -1) {
      selectedIndex = 0; // الافتراضي هو الأحدث
    }
    
    return NeumorphicDropdown(
      value: selectedIndex,
      items: List.generate(
        sortOptions.length,
        (index) => DropdownMenuItem(
          value: index,
          child: Text(sortOptions[index]['label']),
        ),
      ),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            filter = filter.copyWith(
              sortBy: sortOptions[value]['value'],
              ascending: sortOptions[value]['ascending'],
            );
          });
        }
      },
    );
  }
}
