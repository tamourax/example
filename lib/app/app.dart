import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/localization/l10n_extension.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/custom_buttons.dart';
import '../features/home/presentation/home_page.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_services.dart';
import 'settings/app_settings_cubit.dart';

/// App() is a standalone demo suitable for widget tests, without Firebase.
class App extends StatelessWidget {
  const App({
    super.key,
    this.services,
    this.startupFailed = false,
    this.isStarting = false,
    this.onRetrySetup,
  });
  final AppServices? services;
  final bool startupFailed;
  final bool isStarting;
  final VoidCallback? onRetrySetup;

  @override
  Widget build(BuildContext context) {
    final app = BlocProvider(
      create: (_) => AppSettingsCubit(),
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settings) => MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => context.l10n.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: settings.locale,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          home: isStarting
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : startupFailed
              ? Builder(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.l10n.firebaseUnavailable,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            CustomSecondaryButton(
                              label: context.l10n.restart,
                              onPressed: onRetrySetup,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const HomePage(),
        ),
      ),
    );
    return services == null
        ? app
        : RepositoryProvider<AppServices>.value(value: services!, child: app);
  }
}
