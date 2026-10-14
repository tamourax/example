// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get trackingTime => 'تتبع الوقت';

  @override
  String get creatingLocation => 'إنشاء موقع جديد';

  @override
  String get locationDescription => 'وصف الموقع';

  @override
  String get locationName => 'اسم الموقع';

  @override
  String get googleMapsLocation => 'الموقع على خرائط جوجل';

  @override
  String get latitude => 'خط العرض';

  @override
  String get longitude => 'خط الطول';

  @override
  String get allowGeofence => 'السماح بالسياج الجغرافي';

  @override
  String get country => 'دولة';

  @override
  String get stateProvince => 'ولاية او محافظة';

  @override
  String get city => 'مدينة';

  @override
  String get postalCode => 'الرمز البريدي';

  @override
  String get locationSetting => 'إعدادات الموقع';

  @override
  String get allowBreaks => 'السماح بفترات الراحة في الحضور';

  @override
  String get allowPause => 'السماح بالإيقاف المؤقت';

  @override
  String get discard => 'إلغاء';

  @override
  String get create => 'إنشاء';

  @override
  String get textHere => 'اكتب هنا';

  @override
  String get invalidCoordinate => 'أدخل إحداثيات صحيحة ضمن النطاق';

  @override
  String get invalidMapsUrl => 'أدخل رابط HTTPS صالح لخرائط جوجل';

  @override
  String get locationReady => 'تفاصيل الموقع جاهزة.';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get appTitle => 'بداية التطبيق';

  @override
  String get welcome => 'أساس تطبيقك جاهز';

  @override
  String get description =>
      'عناصر قابلة لإعادة الاستخدام، ترجمة، Cubit، وخدمات REST وFirebase.';

  @override
  String get primaryAction => 'الزر الرئيسي';

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
  String get listTitle => 'معاينة ويدجت القائمة';

  @override
  String get firebaseUnavailable =>
      'Firebase غير متاح. تحقق من الإعدادات وأعد التشغيل.';

  @override
  String get restart => 'إعادة محاولة الإعداد';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get componentReady => 'العناصر المشتركة جاهزة للاستخدام.';
}
