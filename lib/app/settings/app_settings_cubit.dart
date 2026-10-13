import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({this.locale, this.themeMode = ThemeMode.system});
  final Locale? locale;
  final ThemeMode themeMode;
  @override
  List<Object?> get props => [locale, themeMode];
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState());
  void setLocale(Locale? locale) {
    if (locale != null && !['en', 'ar'].contains(locale.languageCode)) return;
    emit(AppSettingsState(locale: locale, themeMode: state.themeMode));
  }

  void setThemeMode(ThemeMode mode) =>
      emit(AppSettingsState(locale: state.locale, themeMode: mode));
}
