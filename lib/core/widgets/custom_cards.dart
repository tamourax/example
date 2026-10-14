import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

/// Filled, tappable card for primary content or actions.
class CustomMainCard extends StatelessWidget {
  const CustomMainCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = AppStyles.radius,
    this.color,
    this.elevation = 0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;
  final Color? color;
  final double elevation;

  @override
  Widget build(BuildContext context) => _CustomCard(
    onTap: onTap,
    padding: padding,
    margin: margin,
    borderRadius: borderRadius,
    color: color ?? Theme.of(context).colorScheme.primaryContainer,
    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    elevation: elevation,
    child: child,
  );
}

/// Surface card with a subtle outline for secondary content or actions.
class CustomSecondaryCard extends StatelessWidget {
  const CustomSecondaryCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = AppStyles.radius,
    this.color,
    this.borderColor,
    this.elevation = 0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;
  final Color? color;
  final Color? borderColor;
  final double elevation;

  @override
  Widget build(BuildContext context) => _CustomCard(
    onTap: onTap,
    padding: padding,
    margin: margin,
    borderRadius: borderRadius,
    color: color ?? Theme.of(context).colorScheme.surface,
    foregroundColor: Theme.of(context).colorScheme.onSurface,
    borderColor: borderColor ?? Theme.of(context).colorScheme.outlineVariant,
    elevation: elevation,
    child: child,
  );
}

class _CustomCard extends StatelessWidget {
  const _CustomCard({
    required this.child,
    required this.onTap,
    required this.padding,
    required this.margin,
    required this.borderRadius,
    required this.color,
    required this.foregroundColor,
    required this.elevation,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;
  final Color color;
  final Color foregroundColor;
  final Color? borderColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: borderRadius,
      side: borderColor == null
          ? BorderSide.none
          : BorderSide(color: borderColor!),
    );

    return Padding(
      padding: margin,
      child: Material(
        color: color,
        elevation: elevation,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Padding(
            padding: padding,
            child: IconTheme.merge(
              data: IconThemeData(color: foregroundColor),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: foregroundColor),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
