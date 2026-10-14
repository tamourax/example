import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../localization/l10n_extension.dart';
import '../theme/app_colors.dart';
import 'app_image.dart';
import 'custom_buttons.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    required this.image,
    this.actions,
  });
  final String title;
  final String message;
  final String image;
  final Widget? actions;

  static Future<bool> confirmLocation(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AppDialog(
          title: context.l10n.creatingLocations,
          message: context.l10n.confirmNewLocation,
          image: AppAssets.locationHeader,
          actions: Row(
            children: [
              Expanded(
                child: CustomSecondaryButton(
                  label: context.l10n.no,
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: CustomMainButton(
                  label: context.l10n.yes,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 410),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(
              image,
              width: image == AppAssets.success ? 50 : 68,
              height: image == AppAssets.success ? 50 : 61,
            ),
            SizedBox(height: image == AppAssets.success ? 40 : 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.hintTextColor,
              ),
            ),
            if (actions != null) ...[const SizedBox(height: 12), actions!],
          ],
        ),
      ),
    ),
  );
}

class AppSuccess extends StatelessWidget {
  const AppSuccess({super.key});

  static Future<void> show(BuildContext context) =>
      showDialog<void>(context: context, builder: (_) => const AppSuccess());

  @override
  Widget build(BuildContext context) => AppDialog(
    title: context.l10n.successful,
    message: context.l10n.locationAdded,
    image: AppAssets.success,
  );
}
