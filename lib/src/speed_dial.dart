import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'animated_child.dart'; // Ensure this is your updated AnimatedChild
import 'global_key_extension.dart';
import 'animated_floating_button.dart';
import 'background_overlay.dart';
import 'speed_dial_child.dart';
import 'speed_dial_direction.dart';

typedef AsyncChildrenBuilder = Future<List<SpeedDialChild>> Function(BuildContext context);

class SpeedDial extends StatefulWidget {
  // [Previous SpeedDial properties remain unchanged]
  final List<SpeedDialChild> children;
  final bool visible;
  final Curve curve;
  final String? tooltip;
  final String? heroTag;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? activeBackgroundColor;
  final Color? activeForegroundColor;
  final double elevation;
  final Size buttonSize;
  final Size childrenButtonSize;
  final ShapeBorder shape;
  final Gradient? gradient;
  final BoxShape gradientBoxShape;
  final bool isOpenOnStart;
  final bool closeDialOnPop;
  final Color? overlayColor;
  final double overlayOpacity;
  final AnimatedIconData? animatedIcon;
  final IconThemeData? animatedIconTheme;
  final IconData? icon;
  final IconData? activeIcon;
  final bool useRotationAnimation;
  final double animationAngle;
  final IconThemeData? iconTheme;
  final Widget? label;
  final Widget? activeLabel;
  final Widget Function(Widget, Animation<double>)? labelTransitionBuilder;
  final AsyncChildrenBuilder? onOpenBuilder;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final VoidCallback? onPress;
  final bool closeManually;
  final bool renderOverlay;
  final ValueNotifier<bool>? openCloseDial;
  final Duration animationDuration;
  final EdgeInsets childMargin;
  final EdgeInsets childPadding;
  final double? spacing;
  final double? spaceBetweenChildren;
  final SpeedDialDirection direction;
  final Widget Function(BuildContext, bool, VoidCallback)? dialRoot;
  final Widget? child;
  final Widget? activeChild;
  final bool switchLabelPosition;
  final Curve? animationCurve;
  final bool mini;

  const SpeedDial({
    Key? key,
    this.children = const [],
    this.visible = true,
    this.backgroundColor,
    this.foregroundColor,
    this.activeBackgroundColor,
    this.activeForegroundColor,
    this.gradient,
    this.gradientBoxShape = BoxShape.rectangle,
    this.elevation = 6.0,
    this.buttonSize = const Size(56.0, 56.0),
    this.childrenButtonSize = const Size(56.0, 56.0),
    this.dialRoot,
    this.mini = false,
    this.overlayOpacity = 0.8,
    this.overlayColor,
    this.tooltip,
    this.heroTag,
    this.animatedIcon,
    this.animatedIconTheme,
    this.icon,
    this.activeIcon,
    this.child,
    this.activeChild,
    this.switchLabelPosition = false,
    this.useRotationAnimation = true,
    this.animationAngle = pi / 2,
    this.iconTheme,
    this.label,
    this.activeLabel,
    this.labelTransitionBuilder,
    this.onOpenBuilder,
    this.onOpen,
    this.onClose,
    this.direction = SpeedDialDirection.up,
    this.closeManually = false,
    this.renderOverlay = true,
    this.shape = const StadiumBorder(),
    this.curve = Curves.fastOutSlowIn,
    this.onPress,
    this.animationDuration = const Duration(milliseconds: 150),
    this.openCloseDial,
    this.isOpenOnStart = false,
    this.closeDialOnPop = true,
    this.childMargin = const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    this.childPadding = const EdgeInsets.symmetric(vertical: 5),
    this.spaceBetweenChildren,
    this.spacing,
    this.animationCurve,
  }) : super(key: key);

  @override
  State createState() => _SpeedDialState();
}

class _SpeedDialState extends State<SpeedDial> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.animationDuration,
    vsync: this,
  );
  bool _open = false;
  final LayerLink _layerLink = LayerLink();
  final dialKey = GlobalKey<State<StatefulWidget>>();

  @override
  void initState() {
    super.initState();
    widget.openCloseDial?.addListener(_onOpenCloseDial);
    Future.delayed(Duration.zero, () async {
      if (mounted && widget.isOpenOnStart) _toggleChildren();
    });
    _checkChildren();
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.openCloseDial?.removeListener(_onOpenCloseDial);
    super.dispose();
  }

  @override
  void didUpdateWidget(SpeedDial oldWidget) {
    if (oldWidget.children.length != widget.children.length) {
      _controller.duration = widget.animationDuration;
    }
    widget.openCloseDial?.removeListener(_onOpenCloseDial);
    widget.openCloseDial?.addListener(_onOpenCloseDial);
    super.didUpdateWidget(oldWidget);
  }

  void _checkChildren() {
    if (widget.children.length > 5) {
      debugPrint('Warning! More than 5 children not compliant with Material design.');
    }
  }

  void _onOpenCloseDial() {
    final show = widget.openCloseDial?.value;
    if (!mounted || _open == show) return;
    _toggleChildren();
  }

  void _toggleChildren() async {
    if (!mounted) return;

    final opening = !_open;
    if (opening && widget.onOpenBuilder != null) {
      widget.children.clear();
      final widgets = await widget.onOpenBuilder!(context);
      widget.children.addAll(widgets);
      _checkChildren();
    }

    if (widget.children.isNotEmpty) {
      widget.openCloseDial?.value = opening;
      opening ? widget.onOpen?.call() : widget.onClose?.call();
      opening ? _controller.forward() : _controller.reverse();
      setState(() {
        _open = opening;
      });
    } else {
      widget.onOpen?.call();
    }
  }

  Widget _renderButton() {
    var child = widget.animatedIcon != null
        ? // [Unchanged animated icon logic]
    Container(
      decoration: BoxDecoration(
        shape: widget.gradientBoxShape,
        gradient: widget.gradient,
      ),
      child: Center(
        child: AnimatedIcon(
          icon: widget.animatedIcon!,
          progress: _controller,
          color: widget.animatedIconTheme?.color,
          size: widget.animatedIconTheme?.size,
        ),
      ),
    )
        : AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) => Transform.rotate(
        angle: (widget.activeChild != null || widget.activeIcon != null) &&
            widget.useRotationAnimation
            ? _controller.value * widget.animationAngle
            : 0,
        child: AnimatedSwitcher(
          duration: widget.animationDuration,
          child: (widget.child != null && _controller.value < 0.4)
              ? widget.child
              : (widget.activeIcon == null && widget.activeChild == null ||
              _controller.value < 0.4)
              ? Container(
            decoration: BoxDecoration(
              shape: widget.gradientBoxShape,
              gradient: widget.gradient,
            ),
            child: Center(
              child: widget.icon != null
                  ? Icon(
                widget.icon,
                key: const ValueKey<int>(0),
                color: widget.iconTheme?.color,
                size: widget.iconTheme?.size,
              )
                  : widget.child,
            ),
          )
              : Transform.rotate(
            angle: widget.useRotationAnimation ? -pi * 1 / 2 : 0,
            child: widget.activeChild ??
                Container(
                  decoration: BoxDecoration(
                    shape: widget.gradientBoxShape,
                    gradient: widget.gradient,
                  ),
                  child: Center(
                    child: Icon(
                      widget.activeIcon,
                      key: const ValueKey<int>(1),
                      color: widget.iconTheme?.color,
                      size: widget.iconTheme?.size,
                    ),
                  ),
                ),
          ),
        ),
      ),
    );

    var label = AnimatedSwitcher(
      duration: widget.animationDuration,
      transitionBuilder: widget.labelTransitionBuilder ??
              (child, animation) => FadeTransition(opacity: animation, child: child),
      child: (!_open || widget.activeLabel == null) ? widget.label : widget.activeLabel,
    );

    final backgroundColorTween = ColorTween(
        begin: widget.backgroundColor, end: widget.activeBackgroundColor ?? widget.backgroundColor);
    final foregroundColorTween = ColorTween(
        begin: widget.foregroundColor, end: widget.activeForegroundColor ?? widget.foregroundColor);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, ch) => CompositedTransformTarget(
        link: _layerLink,
        key: dialKey,
        child: AnimatedFloatingButton(
          visible: widget.visible,
          tooltip: widget.tooltip,
          mini: widget.mini,
          dialRoot: widget.dialRoot != null ? widget.dialRoot!(context, _open, _toggleChildren) : null,
          backgroundColor: widget.backgroundColor != null
              ? backgroundColorTween.lerp(_controller.value)
              : null,
          foregroundColor: widget.foregroundColor != null
              ? foregroundColorTween.lerp(_controller.value)
              : null,
          elevation: widget.elevation,
          onLongPress: _toggleChildren,
          callback: (_open || widget.onPress == null) ? _toggleChildren : widget.onPress,
          size: widget.buttonSize,
          label: widget.label != null ? label : null,
          heroTag: widget.heroTag,
          shape: widget.shape,
          child: child,
        ),
      ),
    );
  }

  List<Widget> _getChildrenList() {
    final totalChildren = widget.children.length;
    const double totalAngle = pi; // 180 degrees for semicircle
    final double angleStep = totalAngle / (totalChildren > 1 ? totalChildren - 1 : 1);
    const double radius = 80.0;

    return widget.children.map((SpeedDialChild child) {
      int index = widget.children.indexOf(child);
      double angle;
      switch (widget.direction) {
        case SpeedDialDirection.up:
          angle = pi / 2 - (totalAngle / 2) + (index * angleStep);
          break;
        case SpeedDialDirection.down:
          angle = -pi / 2 - (totalAngle / 2) + (index * angleStep);
          break;
        case SpeedDialDirection.left:
          angle = pi - (totalAngle / 2) + (index * angleStep);
          break;
        case SpeedDialDirection.right:
          angle = 0 - (totalAngle / 2) + (index * angleStep);
          break;
      }

      double dx = radius * cos(angle);
      double dy = radius * sin(angle);

      return AnimatedChild(
        animation: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              index / totalChildren,
              1.0,
              curve: widget.animationCurve ?? Curves.ease,
            ),
          ),
        ),
        index: index,
        btnKey: child.key,
        visible: _open && child.visible,
        backgroundColor: child.backgroundColor,
        foregroundColor: child.foregroundColor,
        elevation: child.elevation,
        buttonSize: widget.childrenButtonSize,
        label: child.label,
        labelStyle: child.labelStyle,
        labelBackgroundColor: child.labelBackgroundColor,
        labelWidget: child.labelWidget,
        labelShadow: child.labelShadow,
        onTap: child.onTap,
        onLongPress: child.onLongPress,
        toggleChildren: () {
          if (!widget.closeManually) _toggleChildren();
        },
        shape: child.shape,
        heroTag: widget.heroTag != null ? '${widget.heroTag}-child-$index' : null,
        childMargin: widget.childMargin,
        childPadding: widget.childPadding,
        child: child.child,
        customPosition: Offset(dx, dy),
        useColumn: widget.direction.isLeft || widget.direction.isRight,
        switchLabelPosition: widget.switchLabelPosition,
        margin: widget.spaceBetweenChildren != null
            ? EdgeInsets.fromLTRB(
          widget.direction.isRight ? widget.spaceBetweenChildren! : 0,
          widget.direction.isDown ? widget.spaceBetweenChildren! : 0,
          widget.direction.isLeft ? widget.spaceBetweenChildren! : 0,
          widget.direction.isUp ? widget.spaceBetweenChildren! : 0,
        )
            : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Children in a semicircle
        CompositedTransformTarget(
          link: _layerLink,
          child: Stack(
            alignment: Alignment.center,
            children: _getChildrenList(),
          ),
        ),
        // Main FAB button
        _renderButton(),
      ],
    );
  }
}