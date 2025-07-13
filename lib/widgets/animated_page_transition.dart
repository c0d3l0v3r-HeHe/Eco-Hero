import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../models/app_theme.dart';

class AnimatedPageTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool slideFromBottom;
  final bool fadeIn;
  final bool scaleIn;
  final Curve curve;

  const AnimatedPageTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.slideFromBottom = true,
    this.fadeIn = true,
    this.scaleIn = false,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedPageTransition> createState() => _AnimatedPageTransitionState();
}

class _AnimatedPageTransitionState extends State<AnimatedPageTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _controller.forward();
  }

  void _initializeAnimations() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: widget.slideFromBottom ? const Offset(0, 1) : const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _scaleAnimation = Tween<double>(
      begin: widget.scaleIn ? 0.8 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget animatedChild = widget.child;

        if (widget.scaleIn) {
          animatedChild = Transform.scale(
            scale: _scaleAnimation.value,
            child: animatedChild,
          );
        }

        if (widget.fadeIn) {
          animatedChild = FadeTransition(
            opacity: _fadeAnimation,
            child: animatedChild,
          );
        }

        animatedChild = SlideTransition(
          position: _slideAnimation,
          child: animatedChild,
        );

        return animatedChild;
      },
    );
  }
}

class ThemedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final ThemeType? themeType;
  final Duration duration;

  ThemedPageRoute({
    required this.child,
    this.themeType,
    this.duration = const Duration(milliseconds: 400),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, _) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              context,
              animation,
              secondaryAnimation,
              child,
              themeType,
            );
          },
        );

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    ThemeType? themeType,
  ) {
    final themeService = ThemeService();
    final currentTheme = themeType ?? themeService.currentTheme.themeType;

    // Different transitions based on theme
    if (currentTheme == ThemeType.marine) {
      // Marine theme: wave-like transition
      return _buildWaveTransition(animation, secondaryAnimation, child);
    } else {
      // Grass theme: grow-like transition
      return _buildGrowTransition(animation, secondaryAnimation, child);
    }
  }

  static Widget _buildWaveTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn));

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    final scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Transform.scale(scale: scaleAnimation.value, child: child),
      ),
    );
  }

  static Widget _buildGrowTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut));

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Transform.scale(scale: scaleAnimation.value, child: child),
      ),
    );
  }
}

class StaggeredAnimationWidget extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration animationDuration;
  final Axis direction;

  const StaggeredAnimationWidget({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 600),
    this.direction = Axis.vertical,
  });

  @override
  State<StaggeredAnimationWidget> createState() =>
      _StaggeredAnimationWidgetState();
}

class _StaggeredAnimationWidgetState extends State<StaggeredAnimationWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startStaggeredAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) =>
          AnimationController(duration: widget.animationDuration, vsync: this),
    );

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: widget.direction == Axis.vertical
            ? const Offset(0, 0.5)
            : const Offset(0.5, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    }).toList();
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, _) {
            return SlideTransition(
              position: _slideAnimations[index],
              child: FadeTransition(
                opacity: _fadeAnimations[index],
                child: child,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
