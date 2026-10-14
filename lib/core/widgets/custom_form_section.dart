import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_cards.dart';
import 'custom_text.dart';

class CustomFormSection extends StatelessWidget {
  const CustomFormSection({
    super.key,
    required this.title,
    required this.child,
  });
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CustomText(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
      const SizedBox(height: 4),
      CustomMainCard(
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    ],
  );
}
