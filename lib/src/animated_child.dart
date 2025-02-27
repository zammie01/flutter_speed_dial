import 'package:flutter/material.dart';

class AnimatedChild extends AnimatedWidget {
  final int? index;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Size buttonSize;
  final Widget? child;
  final List<BoxShadow>? labelShadow;
  final Key? btnKey;

  final String? label;
  final TextStyle? labelStyle;
  final Color? labelBackgroundColor;
  final Widget? labelWidget;

  final bool visible;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? toggleChildren;
  final ShapeBorder? shape;
  final String? heroTag;
  final bool useColumn;
  final bool switchLabelPosition;
  final EdgeInsets? margin;

  final EdgeInsets childMargin;
  final EdgeInsets childPadding;
  final Offset? customPosition; // New parameter for semicircle positioning

  const AnimatedChild({
    Key? key,
    this.btnKey,
    required Animation<double> animation,
    this.index,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 6.0,
    this.buttonSize = const Size(56.0, 56.0),
    this.child,
    this.label,
    this.labelStyle,
    this.labelShadow,
    this.labelBackgroundColor,
    this.labelWidget,
    this.visible = true,
    this.onTap,
    required this.switchLabelPosition,
    required this.useColumn,
    this.margin,
    this.onLongPress,
    this.toggleChildren,
    this.shape,
    this.heroTag,
    required this.childMargin,
    required this.childPadding,
    this.customPosition,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    bool dark = Theme.of(context).brightness == Brightness.dark;

    void performAction([bool isLong = false]) {
      if (onTap != null && !isLong) {
        onTap!();
      } else if (onLongPress != null && isLong) {
        onLongPress!();
      }
      toggleChildren?.call();
    }

    Widget buildLabel() {
      if (label == null && labelWidget == null) return Container();

      if (labelWidget != null) {
        return GestureDetector(
          onTap: performAction,
          onLongPress: onLongPress == null ? null : () => performAction(true),
          child: labelWidget,
        );
      }

      const borderRadius = BorderRadius.all(Radius.circular(6.0));
      return Padding(
        padding: childMargin,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: labelBackgroundColor ??
                (dark ? Colors.grey[800] : Colors.grey[50]),
            borderRadius: borderRadius,
            boxShadow: labelShadow ??
                [
                  BoxShadow(
                    color: dark
                        ? Colors.grey[900]!.withOpacity(0.7)
                        : Colors.grey.withOpacity(0.7),
                    offset: const Offset(0.8, 0.8),
                    blurRadius: 2.4,
                  ),
                ],
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: borderRadius,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: performAction,
              onLongPress:
              onLongPress == null ? null : () => performAction(true),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 8.0,
                ),
                child: Text(label!, style: labelStyle),
              ),
            ),
          ),
        ),
      );
    }

    Widget button = FloatingActionButton(
      key: btnKey,
      heroTag: heroTag,
      onPressed: performAction,
      backgroundColor:
      backgroundColor ?? (dark ? Colors.grey[800] : Colors.grey[50]),
      foregroundColor:
      foregroundColor ?? (dark ? Colors.white : Colors.black),
      elevation: elevation ?? 6.0,
      shape: shape,
      mini: buttonSize != const Size(56.0, 56.0),
      child: child,
    );

    // Combine button and label into a single widget
    Widget childContent = useColumn
        ? Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      switchLabelPosition ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: switchLabelPosition
          ? [if (label != null || labelWidget != null) buildLabel(), if (child != null) button]
          : [if (child != null) button, if (label != null || labelWidget != null) buildLabel()],
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      switchLabelPosition ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: switchLabelPosition
          ? [if (label != null || labelWidget != null) buildLabel(), if (child != null) button]
          : [if (child != null) button, if (label != null || labelWidget != null) buildLabel()],
    );

    // Apply animation and positioning
    return visible
        ? Positioned(
      left: customPosition?.dx != null
          ? (customPosition!.dx! + buttonSize.width / 2) // Center the child
          : null,
      top: customPosition?.dy != null
          ? (customPosition!.dy! + buttonSize.height / 2) // Center the child
          : null,
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation,
          child: Container(
            margin: margin,
            child: onLongPress == null
                ? childContent
                : GestureDetector(
              onLongPress: () => performAction(true),
              child: childContent,
            ),
          ),
        ),
      ),
    )
        : Container();
  }
}