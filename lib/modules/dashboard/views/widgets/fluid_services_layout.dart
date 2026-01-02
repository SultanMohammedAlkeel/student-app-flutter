import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart' ;
import '../../../../core/themes/colors.dart';
import '../../../home/controllers/home_controller.dart';
import '../../models/service_model.dart';
import 'fluid_service_item.dart';
import 'wave_shape.dart';
import 'dart:math' as math;

class FluidServicesLayout extends StatefulWidget {
  final List<ServiceModel> services;
  final bool isDarkMode;
  final Function(ServiceModel) onServiceSelected;

  const FluidServicesLayout({
    Key? key,
    required this.services,
    required this.isDarkMode,
    required this.onServiceSelected,
  }) : super(key: key);

  @override
  State<FluidServicesLayout> createState() => _FluidServicesLayoutState();
}

class _FluidServicesLayoutState extends State<FluidServicesLayout> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _expandedIndex;
  final List<GlobalKey> _serviceKeys = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
    
    // إنشاء مفاتيح للخدمات
    for (int i = 0; i < widget.services.length; i++) {
      _serviceKeys.add(GlobalKey());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isLandscape = width > 600;
        
        return _buildFluidLayout(isLandscape);
      },
    );
  }

  Widget _buildFluidLayout(bool isLandscape) {
    return AnimationLimiter(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'الخدمات',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: _buildOrbitalServices(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'الخدمات الأكثر استخداماً',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildWaveContainer(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isLandscape ? 4 : 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final service = widget.services[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    columnCount: isLandscape ? 4 : 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: FluidServiceItem(
                          key: _serviceKeys[index],
                          service: service,
                          isDarkMode: widget.isDarkMode,
                          isExpanded: _expandedIndex == index,
                          onTap: () {
                            setState(() {
                              if (_expandedIndex == index) {
                                _expandedIndex = null;
                                widget.onServiceSelected(service);
                              } else {
                                _expandedIndex = index;
                              }
                            });
                            Future.delayed(const Duration(milliseconds: 300), () {
                              if (_expandedIndex == index) {
                                widget.onServiceSelected(service);
                                setState(() {
                                  _expandedIndex = null;
                                });
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
                childCount: widget.services.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitalServices() {
      HomeController homeController = Get.find<HomeController>();

    return PlayAnimationBuilder<double>(
      tween: 0.0.tweenTo(1.0),
      duration: 1.5.seconds,
      curve: Curves.easeOutQuad,
      builder: (context,value , child) {

        return Stack(
          alignment: Alignment.center,
          children: [
            // المركز
            Container(
              width: 100 * value,
              height: 100 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    homeController.getPrimaryColor(),
                    homeController.getSecondaryColor(),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: homeController.getPrimaryColor().withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 40 * value,
                ),
              ),
            ),
            
            // المدار الأول
            ...List.generate(3, (index) {
              final angle = (index * (2 * 3.14159 / 3)) + (value * 3.14159 / 2);
              final xPosition = 120 * cos(angle) * value;
              final yPosition = 120 * sin(angle) * value;
              
              return Positioned(
                left: MediaQuery.of(context).size.width / 2 + xPosition - 40,
                top: 150 + yPosition - 40,
                child: Opacity(
                  opacity: value,
                  child: GestureDetector(
                    onTap: () {
                      widget.onServiceSelected(widget.services[index]);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.services[index].color,
                        boxShadow: [
                          BoxShadow(
                            color: widget.services[index].color.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.services[index].icon,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.services[index].title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            
            // المدار الثاني
            ...List.generate(4, (index) {
              final actualIndex = index + 3;
              final angle = (index * (2 * 3.14159 / 4)) + (value * 3.14159 / 4);
              final xPosition = 180 * cos(angle) * value;
              final yPosition = 180 * sin(angle) * value;
              
              return Positioned(
                left: MediaQuery.of(context).size.width / 2 + xPosition - 35,
                top: 150 + yPosition - 35,
                child: Opacity(
                  opacity: value,
                  child: GestureDetector(
                    onTap: () {
                      widget.onServiceSelected(widget.services[actualIndex]);
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.services[actualIndex].color,
                        boxShadow: [
                          BoxShadow(
                            color: widget.services[actualIndex].color.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.services[actualIndex].icon,
                              color: Colors.white,
                              size: 25,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.services[actualIndex].title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildWaveContainer() {
      HomeController homeController = Get.find<HomeController>();

    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        children: [
          WaveShape(
            height: 150,
            width: double.infinity,
            color: homeController.getPrimaryColor().withOpacity(0.8),
            secondaryColor: homeController.getSecondaryColor().withOpacity(0.6),
            amplitude: 20,
            frequency: 0.05,
            isAnimated: true,
            padding: const EdgeInsets.all(20),
            shadow: BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'المهام والمذاكرة',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'نظم وقتك وحقق أهدافك الدراسية',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      NeumorphicButton(
                        style: NeumorphicStyle(
                          depth: 2,
                          intensity: 0.8,
                          color: Colors.white,
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final studyTasksService = widget.services.firstWhere(
                            (service) => service.id == 'study_tasks',
                          );
                          widget.onServiceSelected(studyTasksService);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'ابدأ الآن',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: homeController.getPrimaryColor(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.task_alt,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  double cos(double angle) {
    return math.cos(angle);
  }
  
  double sin(double angle) {
    return math.sin(angle);
  }
}

// استيراد math للدوال الرياضية
