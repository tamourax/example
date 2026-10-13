import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/settings/app_settings_cubit.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_buttons.dart';
import '../../../core/widgets/custom_paginated_list_view.dart';
import '../../../core/widgets/custom_text.dart';
import '../data/demo_repository.dart';
import 'cubit/home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => HomeCubit(DemoRepository())..loadNextPage(),
    child: const _HomeView(),
  );
}

class _HomeView extends StatelessWidget {
  const _HomeView();
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return Scaffold(
      appBar: CustomAppBar(title: context.l10n.appTitle),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: AppStyles.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    onPressed: cubit.refresh,
                  ),
                  const SizedBox(height: 8),
                  CustomSecondaryButton(
                    label: context.l10n.secondaryAction,
                    onPressed: () {
                      final arabic =
                          Localizations.localeOf(context).languageCode == 'ar';
                      context.read<AppSettingsCubit>().setLocale(
                        Locale(arabic ? 'en' : 'ar'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    context.l10n.listTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomPaginatedListView<int>(
                cubit: cubit,
                itemBuilder: (context, item, index) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: CustomText(context.l10n.itemTitle(item)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
