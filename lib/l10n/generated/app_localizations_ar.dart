// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بداية التطبيق';

  @override
  String get welcome => 'أساس تطبيقك جاهز';

  @override
  String get description =>
      'عناصر قابلة لإعادة الاستخدام، ترجمة، Cubit، وخدمات REST وFirebase.';

  @override
  String get primaryAction => 'تحديث القائمة';

  @override
  String get secondaryAction => 'تغيير اللغة';

  @override
  String get emptyList => 'لا توجد عناصر بعد';

  @override
  String get somethingWentWrong => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String itemTitle(int number) {
    return 'العنصر $number';
  }

  @override
  String get listTitle => 'مثال تحميل القائمة تدريجيًا';

  @override
  String get firebaseUnavailable =>
      'Firebase غير متاح. تحقق من الإعدادات وأعد التشغيل.';

  @override
  String get restart => 'إعادة محاولة الإعداد';
}
