// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get requests => 'الطلبات';

  @override
  String get submit => 'إرسال';

  @override
  String get creatingRequestType => 'إنشاء طلب جديد';

  @override
  String get creatingRequest => 'إنشاء طلب';

  @override
  String get confirmNewRequest => 'هل أنت متأكد أنك تريد إنشاء هذا الطلب؟';

  @override
  String get requestSubmitted => 'تم إرسال طلبك بنجاح';

  @override
  String get requestType => 'نوع الطلب';

  @override
  String get requestDescription => 'وصف الطلب';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get allDay => 'طوال اليوم';

  @override
  String get startTime => 'وقت البداية';

  @override
  String get endTime => 'وقت النهاية';

  @override
  String get requestAttachments => 'مرفقات الطلب';

  @override
  String get upload => 'رفع';

  @override
  String get addingAttachment => 'إضافة مرفق';

  @override
  String get dragDropFiles => 'اسحب الملفات وأفلتها هنا';

  @override
  String get or => 'أو';

  @override
  String get browseFiles => 'تصفح الملفات';

  @override
  String get attachmentLimits =>
      'صور أو PDF • حتى ٥ ملفات، ١٠ ميجابايت لكل ملف';

  @override
  String get attachmentTooLarge => 'يجب ألا يتجاوز حجم كل مرفق ١٠ ميجابايت.';

  @override
  String get attachmentTooMany => 'يمكنك إرفاق حتى ٥ ملفات لكل طلب.';

  @override
  String get attachmentUnsupported =>
      'اختر صورة صالحة (PNG أو JPG أو GIF أو WebP أو BMP) أو ملف PDF.';

  @override
  String get attachmentReadFailed => 'تعذرت قراءة الملف المحدد. حاول مرة أخرى.';

  @override
  String get attachmentOpenFailed => 'تعذر فتح المرفق. حاول مرة أخرى.';

  @override
  String get removeAttachment => 'إزالة المرفق';

  @override
  String get chooseDate => 'اختيار التاريخ';

  @override
  String get chooseTime => 'اختيار الوقت';

  @override
  String get invalidRequestDate => 'أدخل تاريخاً صالحاً بصيغة YYYY-MM-DD';

  @override
  String get endDateBeforeStart =>
      'يجب أن يكون تاريخ النهاية في تاريخ البداية أو بعده';

  @override
  String get invalidRequestTime =>
      'أدخل وقتاً صالحاً بصيغة HH:mm بنظام ٢٤ ساعة';

  @override
  String get endTimeBeforeStart =>
      'يجب أن يكون وقت النهاية في وقت البداية أو بعده في اليوم نفسه';

  @override
  String get noRequests => 'لا توجد طلبات بعد. اختر إرسال لإنشاء طلب.';

  @override
  String get requestsLoadFailed => 'تعذر تحميل الطلبات. حاول مرة أخرى.';

  @override
  String get requestSaveFailed =>
      'تعذر إرسال الطلب. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get requestSaveDenied =>
      'ليس لديك صلاحية إرسال الطلبات أو رفع المرفقات.';

  @override
  String get requestStorageUnavailable =>
      'تخزين المرفقات غير متاح. حاول مرة أخرى أو أرسل الطلب دون مرفقات.';

  @override
  String get locations => 'المواقع';

  @override
  String get creatingLocations => 'إنشاء مواقع جديدة';

  @override
  String get confirmNewLocation => 'هل أنت متأكد أنك تريد إضافة موقع جديد؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get successful => 'تم بنجاح';

  @override
  String get locationAdded => 'تمت إضافة الموقع الجديد بنجاح';

  @override
  String get noLocations => 'لا توجد مواقع بعد. أضف موقعك الأول.';

  @override
  String get locationsLoadFailed => 'تعذر تحميل المواقع. حاول مرة أخرى.';

  @override
  String get locationSaveFailed =>
      'تعذر حفظ الموقع. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get locationSaveDenied => 'ليس لديك صلاحية إضافة مواقع.';

  @override
  String get useDeviceLocation => 'استخدام موقع الجهاز';

  @override
  String get selectOnMap => 'تحديد على الخريطة';

  @override
  String get tapMapToSelect =>
      'اضغط على الخريطة لتحديد موقع. يمكنك تكبير الخريطة وتحريكها.';

  @override
  String get useSelectedLocation => 'استخدام الموقع المحدد';

  @override
  String get locationPermissionDenied =>
      'تم رفض إذن الموقع. أدخل الإحداثيات يدوياً أو حدد الموقع على الخريطة.';

  @override
  String get locationPermissionPermanent =>
      'إذن الموقع محظور. فعّله من إعدادات الجهاز أو المتصفح، أو أدخل الإحداثيات يدوياً، أو حدد الموقع على الخريطة.';

  @override
  String get locationServicesDisabled =>
      'خدمات الموقع متوقفة. فعّلها أو أدخل الإحداثيات يدوياً أو حدد الموقع على الخريطة.';

  @override
  String get deviceLocationUnavailable =>
      'موقع الجهاز غير متاح. أدخل الإحداثيات يدوياً أو حدد الموقع على الخريطة.';

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
