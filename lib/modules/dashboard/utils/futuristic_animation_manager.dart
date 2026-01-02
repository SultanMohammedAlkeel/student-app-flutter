import 'package:flutter/material.dart';

/// مدير الرسوم المتحركة للانتقالات السلسة
/// يوفر انتقالات وتأثيرات حركية متقدمة للتطبيق
class FuturisticAnimationManager {
  // انتقال صفحة مع تأثير تلاشي وحركة
  static Route<dynamic> fadeSlideTransition({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeOutCubic;
        var tween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        var offsetTween = Tween(begin: const Offset(0, 0.2), end: Offset.zero).chain(
          CurveTween(curve: curve),
        );
        
        return FadeTransition(
          opacity: animation.drive(tween),
          child: SlideTransition(
            position: animation.drive(offsetTween),
            child: child,
          ),
        );
      },
    );
  }
  
  // انتقال صفحة مع تأثير تكبير وتلاشي
  static Route<dynamic> zoomFadeTransition({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeOutCubic;
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        var scaleTween = Tween(begin: 0.9, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        
        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
    );
  }
  
  // انتقال صفحة مع تأثير انزلاق من الجانب
  static Route<dynamic> slideTransition({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 500),
    bool fromRight = true,
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeOutCubic;
        var offsetTween = Tween(
          begin: Offset(fromRight ? 1.0 : -1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));
        
        return SlideTransition(
          position: animation.drive(offsetTween),
          child: child,
        );
      },
    );
  }
  
  // تأثير ظهور متدرج للعناصر
  static Widget staggeredFadeIn({
    required List<Widget> children,
    Duration initialDelay = Duration.zero,
    Duration itemDelay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return _StaggeredFadeInList(
      children: children,
      initialDelay: initialDelay,
      itemDelay: itemDelay,
      duration: duration,
      curve: curve,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
    );
  }
  
  // تأثير ظهور متدرج للعناصر في شبكة
  static Widget staggeredFadeInGrid({
    required List<Widget> children,
    required int crossAxisCount,
    Duration initialDelay = Duration.zero,
    Duration itemDelay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
    double mainAxisSpacing = 10.0,
    double crossAxisSpacing = 10.0,
    double childAspectRatio = 1.0,
  }) {
    return _StaggeredFadeInGrid(
      children: children,
      crossAxisCount: crossAxisCount,
      initialDelay: initialDelay,
      itemDelay: itemDelay,
      duration: duration,
      curve: curve,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
    );
  }
  
  // تأثير نبض للعناصر
  static Widget pulseAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    double minScale = 0.97,
    double maxScale = 1.03,
    bool repeat = true,
  }) {
    return _PulseAnimationWidget(
      child: child,
      duration: duration,
      minScale: minScale,
      maxScale: maxScale,
      repeat: repeat,
    );
  }
  
  // تأثير توهج للعناصر
  static Widget glowAnimation({
    required Widget child,
    required Color glowColor,
    Duration duration = const Duration(milliseconds: 1500),
    double minOpacity = 0.2,
    double maxOpacity = 0.6,
    double spreadRadius = 10.0,
    double blurRadius = 20.0,
    bool repeat = true,
  }) {
    return _GlowAnimationWidget(
      child: child,
      glowColor: glowColor,
      duration: duration,
      minOpacity: minOpacity,
      maxOpacity: maxOpacity,
      spreadRadius: spreadRadius,
      blurRadius: blurRadius,
      repeat: repeat,
    );
  }
}

// ويدجت تأثير ظهور متدرج للعناصر في قائمة
class _StaggeredFadeInList extends StatefulWidget {
  final List<Widget> children;
  final Duration initialDelay;
  final Duration itemDelay;
  final Duration duration;
  final Curve curve;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const _StaggeredFadeInList({
    Key? key,
    required this.children,
    required this.initialDelay,
    required this.itemDelay,
    required this.duration,
    required this.curve,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    required this.mainAxisSize,
  }) : super(key: key);

  @override
  State<_StaggeredFadeInList> createState() => _StaggeredFadeInListState();
}

class _StaggeredFadeInListState extends State<_StaggeredFadeInList> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    // حساب المدة الإجمالية للرسوم المتحركة
    final totalDuration = widget.initialDelay +
        widget.itemDelay * (widget.children.length - 1) +
        widget.duration;
    
    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    );
    
    // إنشاء رسوم متحركة لكل عنصر
    _animations = List.generate(
      widget.children.length,
      (index) {
        final startTime = widget.initialDelay + widget.itemDelay * index;
        final endTime = startTime + widget.duration;
        
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              startTime.inMilliseconds / totalDuration.inMilliseconds,
              endTime.inMilliseconds / totalDuration.inMilliseconds,
              curve: widget.curve,
            ),
          ),
        );
      },
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      children: List.generate(
        widget.children.length,
        (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Opacity(
                opacity: _animations[index].value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _animations[index].value)),
                  child: child,
                ),
              );
            },
            child: widget.children[index],
          );
        },
      ),
    );
  }
}

// ويدجت تأثير ظهور متدرج للعناصر في شبكة
class _StaggeredFadeInGrid extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final Duration initialDelay;
  final Duration itemDelay;
  final Duration duration;
  final Curve curve;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const _StaggeredFadeInGrid({
    Key? key,
    required this.children,
    required this.crossAxisCount,
    required this.initialDelay,
    required this.itemDelay,
    required this.duration,
    required this.curve,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.childAspectRatio,
  }) : super(key: key);

  @override
  State<_StaggeredFadeInGrid> createState() => _StaggeredFadeInGridState();
}

class _StaggeredFadeInGridState extends State<_StaggeredFadeInGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    // حساب المدة الإجمالية للرسوم المتحركة
    final totalDuration = widget.initialDelay +
        widget.itemDelay * (widget.children.length - 1) +
        widget.duration;
    
    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    );
    
    // إنشاء رسوم متحركة لكل عنصر
    _animations = List.generate(
      widget.children.length,
      (index) {
        final startTime = widget.initialDelay + widget.itemDelay * index;
        final endTime = startTime + widget.duration;
        
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              startTime.inMilliseconds / totalDuration.inMilliseconds,
              endTime.inMilliseconds / totalDuration.inMilliseconds,
              curve: widget.curve,
            ),
          ),
        );
      },
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Opacity(
              opacity: _animations[index].value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _animations[index].value)),
                child: child,
              ),
            );
          },
          child: widget.children[index],
        );
      },
    );
  }
}

// ويدجت تأثير نبض للعناصر
class _PulseAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool repeat;

  const _PulseAnimationWidget({
    Key? key,
    required this.child,
    required this.duration,
    required this.minScale,
    required this.maxScale,
    required this.repeat,
  }) : super(key: key);

  @override
  State<_PulseAnimationWidget> createState() => _PulseAnimationWidgetState();
}

class _PulseAnimationWidgetState extends State<_PulseAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ويدجت تأثير توهج للعناصر
class _GlowAnimationWidget extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;
  final double spreadRadius;
  final double blurRadius;
  final bool repeat;

  const _GlowAnimationWidget({
    Key? key,
    required this.child,
    required this.glowColor,
    required this.duration,
    required this.minOpacity,
    required this.maxOpacity,
    required this.spreadRadius,
    required this.blurRadius,
    required this.repeat,
  }) : super(key: key);

  @override
  State<_GlowAnimationWidget> createState() => _GlowAnimationWidgetState();
}

class _GlowAnimationWidgetState extends State<_GlowAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _opacityAnimation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_opacityAnimation.value),
                blurRadius: widget.blurRadius,
                spreadRadius: widget.spreadRadius,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
