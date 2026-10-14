import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

ButtonStyle _buttonStyle(Color backgroundColor) => FilledButton.styleFrom(
  backgroundColor: backgroundColor,
  foregroundColor: AppColors.black,
  disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
  disabledForegroundColor: AppColors.black.withValues(alpha: 0.5),
  textStyle: const TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  ),
  minimumSize: const Size(0, 38),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
  ),
  elevation: 0,
);

class CustomMainButton extends StatelessWidget {
  const CustomMainButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: expand ? double.infinity : null,
    child: FilledButton(
      style: _buttonStyle(AppColors.grey),
      onPressed: isLoading ? null : onPressed,
      child: _ButtonContent(label: label, isLoading: isLoading, icon: icon),
    ),
  );
}

class CustomSecondaryButton extends StatelessWidget {
  const CustomSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: expand ? double.infinity : null,
    child: FilledButton(
      style: _buttonStyle(AppColors.lightGrey),
      onPressed: isLoading ? null : onPressed,
      child: _ButtonContent(label: label, isLoading: isLoading, icon: icon),
    ),
  );
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    this.icon,
  });
  final String label;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (isLoading) ...[
        const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.black,
          ),
        ),
        const SizedBox(width: 8),
      ] else if (icon != null) ...[
        icon!,
        const SizedBox(width: 8),
      ],
      Flexible(child: Text(label)),
    ],
  );
}
