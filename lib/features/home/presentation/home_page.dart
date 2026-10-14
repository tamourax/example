import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/settings/app_settings_cubit.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_buttons.dart';
import '../../../core/widgets/custom_cards.dart';
import '../../../core/widgets/custom_list_view.dart';
import '../../../core/widgets/custom_text.dart';

/// A clean starter screen: shared components only, with no sample records or data source.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: context.l10n.appTitle,
      actions: [
        IconButton(
          tooltip: context.l10n.changeLanguage,
          onPressed: () {
            final isArabic =
                Localizations.localeOf(context).languageCode == 'ar';
            context.read<AppSettingsCubit>().setLocale(
              Locale(isArabic ? 'en' : 'ar'),
            );
          },
          icon: const Icon(Icons.translate),
        ),
      ],
    ),
    body: SafeArea(
      child: Padding(
        padding: AppStyles.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppImage(AppAssets.appMark, width: 48, height: 48),
            const SizedBox(height: 12),
            CustomText(
              context.l10n.welcome,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            CustomText(context.l10n.description),
            const SizedBox(height: 16),
            CustomMainButton(
              label: context.l10n.primaryAction,
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.componentReady)),
              ),
            ),
            const SizedBox(height: 8),
            CustomSecondaryButton(
              label: context.l10n.secondaryAction,
              onPressed: () {
                final isArabic =
                    Localizations.localeOf(context).languageCode == 'ar';
                context.read<AppSettingsCubit>().setLocale(
                  Locale(isArabic ? 'en' : 'ar'),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomMainCard(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.componentReady)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.dashboard_outlined),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.primaryAction,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomSecondaryCard(
                    onTap: () {
                      final isArabic =
                          Localizations.localeOf(context).languageCode == 'ar';
                      context.read<AppSettingsCubit>().setLocale(
                        Locale(isArabic ? 'en' : 'ar'),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.widgets_outlined),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.secondaryAction,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomText(
              context.l10n.listTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: CustomListView<String>(
                items: const [],
                itemBuilder: (context, item, index) => CustomText(item),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
