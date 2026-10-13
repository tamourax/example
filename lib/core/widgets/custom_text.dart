import 'package:flutter/material.dart';

/// Pass generated ARB values: CustomText(context.l10n.welcome).
class CustomText extends StatelessWidget {
  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.maxLines,
    this.textAlign,
    this.overflow,
  });
  final String text;
  final TextStyle? style;
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: (style ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
      color: color,
    ),
    maxLines: maxLines,
    textAlign: textAlign,
    overflow: overflow,
  );
}
