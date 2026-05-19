// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Teranga Pass';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get filter => 'تصفية';

  @override
  String get allZones => 'جميع المناطق';

  @override
  String get zoneLabel => 'المنطقة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get close => 'إغلاق';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get clearAllConfirmTitle => 'مسح جميع الإشعارات';

  @override
  String get clearAllConfirmBody =>
      'سيتم حذف جميع إشعاراتك الشخصية. هذا الإجراء لا يمكن التراجع عنه.';

  @override
  String get markAsRead => 'تحديد كمقروء';

  @override
  String get markAsUnread => 'تحديد كغير مقروء';

  @override
  String get markAllAsRead => 'تحديد الكل كمقروء';

  @override
  String get delete => 'حذف';

  @override
  String get deleteNotificationTitle => 'حذف الإشعار';

  @override
  String get deleteNotificationBody =>
      'هل أنت متأكد من رغبتك في حذف هذا الإشعار؟';

  @override
  String unreadCount(int count) {
    return '$count غير مقروء(ة)';
  }

  @override
  String get notifChipSosShort => 'SOS';

  @override
  String get notifChipMedicalShort => 'طوارئ طبية';

  @override
  String get notifChipIncidentShort => 'بلاغ';

  @override
  String get notifChipSosSent => 'تم إرسال نداء الاستغاثة';

  @override
  String get notifChipMedicalSent => 'تنبيه طبي';

  @override
  String get notifChipIncidentReceived => 'تم تسجيل البلاغ';

  @override
  String get notifChipStatusPending => 'قيد الانتظار';

  @override
  String get notifChipStatusInProgress => 'جارٍ المعالجة';

  @override
  String get notifChipStatusResolved => 'تمت المعالجة';

  @override
  String get notifChipStatusCancelled => 'ملغى';

  @override
  String get notifChipIncidentValidated => 'تم التحقق';

  @override
  String get notifChipIncidentRejected => 'مرفوض';

  @override
  String get notifChipFollowUp => 'تحديث';

  @override
  String get notifChipGeneral => 'رسالة';

  @override
  String get notifChipAudioAnnouncement => 'إعلان صوتي';

  @override
  String get pullToRefresh => 'اسحب للتحديث';

  @override
  String get openMapError => 'تعذّر فتح الخريطة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get loginValueProps => 'الاكتشاف · السفر بأمان · الحماية';

  @override
  String get loginTagline => 'أمانك في دكار';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginEmailHint => 'بريدك@example.com';

  @override
  String get loginEmailRequired => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get loginEmailInvalid => 'البريد الإلكتروني غير صالح';

  @override
  String get loginIdentifierLabel => 'البريد أو الرقم';

  @override
  String get loginIdentifierHint => 'بريدك@example.com أو رقم الهاتف';

  @override
  String get loginIdentifierRequired => 'يرجى إدخال بريدك الإلكتروني أو رقمك';

  @override
  String get loginPhoneInvalid => 'رقم غير صالح (9 أرقام على الأقل)';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginPasswordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get loginPasswordMinLength =>
      'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل';

  @override
  String get loginSignIn => 'تسجيل الدخول';

  @override
  String get loginRememberMe => 'تذكرني';

  @override
  String get loginNoAccount => 'ليس لديك حساب؟ سجّل الآن';

  @override
  String get loginUnknownError => 'حدث خطأ ما';

  @override
  String get loginConnectionError =>
      'خطأ في الاتصال. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'انضم إلى Teranga Pass';

  @override
  String get registerFullNameLabel => 'الاسم الكامل';

  @override
  String get registerFullNameHint => 'اسمك';

  @override
  String get registerFullNameRequired => 'يرجى إدخال اسمك';

  @override
  String get registerPhoneHint => 'رقم الهاتف';

  @override
  String get registerPhoneNationalHint => 'بدون رمز الدولة';

  @override
  String get registerPhoneRequired => 'يرجى إدخال رقم هاتفك';

  @override
  String get registerSelectCountry => 'اختر دولة';

  @override
  String get registerPasswordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get registerConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get registerConfirmPasswordRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get registerPasswordsNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get registerSignUp => 'التسجيل';

  @override
  String get registerHaveAccount => 'لديك حساب بالفعل؟ سجّل دخولك';

  @override
  String get ok => 'موافق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get call => 'اتصال';

  @override
  String get openPhoneError => 'تعذّر فتح الهاتف';

  @override
  String get sosEmergencyTitle => 'نداء استغاثة';

  @override
  String get sosCancelled => 'تم إلغاء تنبيه الاستغاثة';

  @override
  String get sosSentTitle => 'تم إرسال تنبيه الاستغاثة';

  @override
  String get sosSentBody =>
      'تم إرسال تنبيه الاستغاثة إلى خدمات الإنقاذ.\n\nسيصلون في أقرب وقت ممكن.';

  @override
  String get sosCountdown => 'التنبيه في...';

  @override
  String get sosAlertSent => 'تم إرسال التنبيه!';

  @override
  String get sosUrgenceLabel => 'نداء استغاثة';

  @override
  String get sosHoldBanner => 'طوارئ – اضغط مطوّلاً';

  @override
  String get sosDangerQuestion => 'هل أنت\nفي خطر؟';

  @override
  String get sosThreeSecondsBadge => '3 ثوانٍ';

  @override
  String get sosPressToAlert => 'اضغط للتنبيه';

  @override
  String get sosCancelAlert => 'إلغاء التنبيه';

  @override
  String callServiceTitle(Object service) {
    return 'الاتصال بـ $service';
  }

  @override
  String callServicePrompt(Object service, Object number) {
    return 'هل تريد الاتصال بـ $service على الرقم $number؟';
  }

  @override
  String get sosUnknownPosition => 'موقع غير معروف';

  @override
  String get sosCurrentPosition => 'موقعك الحالي';

  @override
  String sosAccuracy(Object meters) {
    return 'الدقة: $meters متر';
  }

  @override
  String get sosEmergencyServices => 'خدمات الطوارئ';

  @override
  String get sosHistory => 'السجل';

  @override
  String get sosNoRecentAlerts => 'لا توجد تنبيهات حديثة';

  @override
  String sosNumber(Object number) {
    return 'الرقم: $number';
  }

  @override
  String get unknownPosition => 'موقع غير معروف';

  @override
  String get incidentReportTitle => 'الإبلاغ عن حادثة';

  @override
  String get incidentTypeTitle => 'نوع الحادثة';

  @override
  String get incidentTypeLoss => 'فقدان';

  @override
  String get incidentTypeAccident => 'حادث';

  @override
  String get incidentTypeSuspicious => 'مريب';

  @override
  String get incidentDescriptionTitle => 'الوصف';

  @override
  String get incidentDescriptionHint => 'صف الحادثة بالتفصيل...';

  @override
  String get incidentPhotosTitle => 'الصور';

  @override
  String get incidentAudioTitle => 'الصوت';

  @override
  String get incidentLocationTitle => 'موقع الحادثة';

  @override
  String get incidentAdd => 'إضافة';

  @override
  String get incidentRecordingInProgress => 'جارٍ التسجيل...';

  @override
  String get incidentAddVoiceMessage => 'إضافة رسالة صوتية';

  @override
  String get incidentTapToRecord => 'اضغط للتسجيل';

  @override
  String get incidentAudioAdded => 'تمت إضافة الصوت';

  @override
  String get incidentSendReport => 'إرسال البلاغ';

  @override
  String get incidentSelectTypeError => 'يرجى اختيار نوع الحادثة';

  @override
  String get incidentDescribeError => 'يرجى وصف الحادثة';

  @override
  String get incidentSentTitle => 'تم إرسال البلاغ';

  @override
  String get incidentSentBody =>
      'تم إرسال بلاغك إلى السلطات المختصة.\n\nستتلقى ردًا في أقرب وقت ممكن.';

  @override
  String get incidentAddPhotoError => 'تعذّر إضافة صورة';

  @override
  String get incidentStopRecordingError => 'تعذّر إيقاف التسجيل';

  @override
  String get incidentMicPermissionDenied => 'تم رفض إذن الميكروفون';

  @override
  String get incidentStartRecordingError => 'تعذّر بدء التسجيل';

  @override
  String get incidentGallery => 'المعرض';

  @override
  String get incidentCamera => 'الكاميرا';

  @override
  String get medicalAlertTitle => 'تنبيه طبي';

  @override
  String get homeFeatureAudioAnnouncements => 'الإعلانات الصوتية';

  @override
  String get homeFeatureTouristInfo => 'معلومات السياحة';

  @override
  String get homeFeatureCompetitionSites => 'مواقع المنافسات';

  @override
  String get homeFeatureCompetitions => 'المنافسات';

  @override
  String get homeFeatureTransport => 'المواصلات والنقل';

  @override
  String get homeFeatureReportIncident => 'الإبلاغ عن حادثة';

  @override
  String get homeOfficialAnnouncementDefaultTitle => 'إعلان رسمي';

  @override
  String get passQrTitle => 'تصريح Teranga الخاص بي';

  @override
  String get passQrEntry => 'عرض تصريحي (QR)';

  @override
  String get passQrSubtitle => 'قدّم هذا الرمز عند نقاط التفتيش (تجريبي).';

  @override
  String get passQrRetry => 'إعادة المحاولة';

  @override
  String get homeJojInfoTitle => 'معلومات الدورة: مواقع المنافسات';

  @override
  String get homeCalendar => 'التقويم';

  @override
  String get homeNoActiveSites => 'لا توجد مواقع نشطة';

  @override
  String get homeAddLatLngHint => 'أضف خط العرض/الطول في لوحة التحكم';

  @override
  String get homeSiteFallback => 'موقع';

  @override
  String get homeNavHome => 'الرئيسية';

  @override
  String get homeNavMedicalAlert => 'تنبيه طبي';

  @override
  String get homeNavSos => 'SOS';

  @override
  String get homeNavReport => 'بلاغ';

  @override
  String get homeNavProfile => 'الملف';

  @override
  String get homeComingSoon => 'ستكون هذه الميزة متاحة قريبًا.';

  @override
  String get medicalSelectTypeError => 'يرجى اختيار نوع الطوارئ الطبية';

  @override
  String get medicalSentTitle => 'تم إرسال التنبيه الطبي';

  @override
  String get medicalSentBody =>
      'تم إرسال تنبيهك الطبي إلى الخدمات الطبية.\n\nسيارة الإسعاف في الطريق إليك.';

  @override
  String get medicalSending => 'جارٍ إرسال التنبيه...';

  @override
  String get medicalTapToAlert => 'اضغط لتنبيه الخدمات الطبية';

  @override
  String get medicalEmergencyTypeTitle => 'نوع الطوارئ الطبية';

  @override
  String get medicalTypeAccident => 'حادث';

  @override
  String get medicalTypeFainting => 'إغماء';

  @override
  String get medicalTypeInjury => 'إصابة';

  @override
  String get medicalTypeOther => 'أخرى';

  @override
  String get medicalYourPosition => 'موقعك';

  @override
  String get medicalNearbyHospitals => 'المستشفيات القريبة';

  @override
  String get medicalNoNearbyHospitals => 'لم يتم العثور على مستشفيات قريبة';

  @override
  String medicalEmergencyNumberLabel(Object number) {
    return 'طوارئ $number';
  }

  @override
  String get transportTitle => 'النقل والمواصلات';

  @override
  String get transportNoShuttles => 'لا توجد حافلات متاحة';

  @override
  String get transportSecure => 'آمن';

  @override
  String transportTerminusPrefix(Object terminus) {
    return 'المحطة النهائية: $terminus';
  }

  @override
  String get transportNextDeparturePrefix => 'المغادرة التالية:';

  @override
  String get transportNextDeparture => 'المغادرة التالية';

  @override
  String get transportItinerarySection => 'المسار';

  @override
  String get transportRouteLabel => 'الخط';

  @override
  String get transportDepartureLabel => 'المغادرة';

  @override
  String get transportTerminusLabel => 'المحطة النهائية';

  @override
  String get transportStartPointLabel => 'نقطة الانطلاق';

  @override
  String get transportScheduleSection => 'الجدول الزمني';

  @override
  String get transportScheduleLabel => 'الجدول';

  @override
  String get transportDaysLabel => 'الأيام';

  @override
  String get transportPeriodLabel => 'الفترة';

  @override
  String get transportFrequencyLabel => 'التكرار';

  @override
  String get transportStopsSection => 'المحطات';

  @override
  String get transportDescriptionSection => 'الوصف';

  @override
  String get timeJustNow => 'الآن';

  @override
  String timeMinutesAgo(Object count) {
    return 'منذ $count دق';
  }

  @override
  String timeHoursAgo(Object count) {
    return 'منذ $count س';
  }

  @override
  String timeDaysAgo(Object count) {
    return 'منذ $count أيام';
  }

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get profileUnavailable => 'الملف الشخصي غير متوفر';

  @override
  String get profilePersonalInfoSection => 'المعلومات الشخصية';

  @override
  String get profileNotificationsSetting => 'الإشعارات';

  @override
  String get profileGeolocationSetting => 'تحديد الموقع الجغرافي';

  @override
  String get profilePrivacySetting => 'الخصوصية';

  @override
  String get profileOverviewSection => 'نظرة عامة';

  @override
  String get profileAlertsStat => 'التنبيهات';

  @override
  String get profileReportsStat => 'البلاغات';

  @override
  String get profileRecentActivitiesSection => 'الأنشطة الأخيرة';

  @override
  String get profileNoRecentActivity => 'لا توجد أنشطة حديثة';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileDeleteAccount => 'Delete my account';

  @override
  String get profileDeleteAccountTitle => 'Delete account';

  @override
  String get profileDeleteAccountBody =>
      'لا يمكن التراجع عن هذا الإجراء. سيتم حذف تنبيهاتك وتقاريرك والبيانات المرتبطة نهائياً. للتأكيد، اكتب الرمز التالي بالضبط في الحقل:';

  @override
  String get profileDeleteAccountCodeLabel => 'رمز التأكيد';

  @override
  String get profileDeleteAccountCodeHint => 'teranga pass';

  @override
  String get profileDeleteAccountCodeFieldHint => 'أدخل الرمز هنا';

  @override
  String get profileDeleteAccountCodeError =>
      'Incorrect code. Type exactly: teranga pass';

  @override
  String get profileDeleteAccountConfirm => 'Delete permanently';

  @override
  String get profileDeleteAccountSuccess => 'Your account has been deleted.';

  @override
  String get profileDeleteAccountFailed =>
      'Could not delete your account right now.';

  @override
  String get profileDefaultSosTitle => 'تنبيه استغاثة';

  @override
  String get profileDefaultReportTitle => 'بلاغ';

  @override
  String get historyUnifiedTitle => 'سجل الاستغاثة والبلاغات';

  @override
  String get historyUnifiedEmpty =>
      'لا توجد استغاثات ولا تنبيهات طبية ولا بلاغات';

  @override
  String get historyKindSos => 'SOS';

  @override
  String get historyKindMedical => 'تنبيه طبي';

  @override
  String get historyKindReport => 'بلاغ';

  @override
  String get historyAlertDetailTitle => 'تفاصيل التنبيه';

  @override
  String get historyFieldAddress => 'العنوان';

  @override
  String get historyFieldDate => 'التاريخ';

  @override
  String get historyFieldCoords => 'الإحداثيات';

  @override
  String get alertTrackingNavTitle => 'تنبيهي';

  @override
  String get alertTimelineRecorded => 'تم تسجيل التنبيه';

  @override
  String get alertTimelineDispatched => 'تم إرسالها إلى خدمات الإنقاذ';

  @override
  String get alertTimelineClosed => 'مُغلق';

  @override
  String get alertTimelineRejected => 'مرفوض';

  @override
  String get alertTimelineCancelled => 'ملغى';

  @override
  String get privacyPersonalDataTitle => 'البيانات الشخصية';

  @override
  String get privacyPersonalDataBody =>
      'يستخدم Teranga Pass معلوماتك لتحسين تجربتك (مثل: الملف الشخصي، الإشعارات، الأمان). يمكنك إدارة بعض الأذونات من هاتفك.';

  @override
  String get privacyLocationSubtitle => 'اسمح بالوصول لعرض الأماكن القريبة.';

  @override
  String get privacyNotificationsSubtitle =>
      'استقبل التنبيهات والمعلومات المفيدة.';

  @override
  String get audioTitle => 'الإعلانات الصوتية';

  @override
  String get audioNoAudioAvailable => 'لا يوجد صوت متاح لهذا الإعلان';

  @override
  String get audioCannotPlay => 'تعذّر تشغيل الصوت';

  @override
  String get audioNoAnnouncements => 'لا توجد إعلانات متاحة';

  @override
  String get audioAllLanguages => 'الكل';

  @override
  String get tourismTitle => 'السياحة والخدمات';

  @override
  String get tourismCategoryAll => 'الكل';

  @override
  String get tourismCategoryHotels => 'الفنادق';

  @override
  String get tourismCategoryRestaurants => 'المطاعم';

  @override
  String get tourismCategoryPharmacies => 'الصيدليات';

  @override
  String get tourismCategoryHospitals => 'المستشفيات';

  @override
  String get tourismCategoryEmbassies => 'السفارات';

  @override
  String tourismTabWithCount(Object label, Object count) {
    return '$label ($count)';
  }

  @override
  String get tourismCoordinatesMissing => 'إحداثيات مفقودة';

  @override
  String get tourismEnableLocation => 'تفعيل تحديد الموقع';

  @override
  String get tourismDistanceUnavailable => 'المسافة غير متاحة';

  @override
  String get tourismSettingsButton => 'الإعدادات';

  @override
  String get tourismEnableGpsButton => 'تفعيل GPS';

  @override
  String get tourismNoResults => 'لا توجد نتائج';

  @override
  String get mapTitle => 'الخريطة التفاعلية';

  @override
  String get mapPlaceholderTitle => 'خريطة تفاعلية';

  @override
  String get mapPlaceholderSubtitle => 'التكامل مع Google Maps قريبًا';

  @override
  String get mapOpenInGoogleMaps => 'فتح في Google Maps';

  @override
  String get mapNearbyPointsTitle => 'نقاط الاهتمام القريبة';

  @override
  String get mapNoPoints => 'لا توجد نقاط متاحة';

  @override
  String get mapDefaultPointName => 'نقطة اهتمام';

  @override
  String get mapPositionUpdated => 'تم تحديث الموقع';

  @override
  String get mapCannotGetPosition => 'تعذّر تحديد الموقع';

  @override
  String get mapOpenGoogleMapsError => 'تعذّر فتح Google Maps';

  @override
  String get mapTilesLoadIssue => 'قد تكون الخريطة غير مكتملة. تحقق من اتصالك.';

  @override
  String get mapFilterAll => 'الكل';

  @override
  String get mapFilterHelp => 'إنقاذ';

  @override
  String get mapFilterSites => 'مواقع الألعاب';

  @override
  String get mapFilterHotels => 'الفنادق';

  @override
  String get mapFilterRestaurants => 'المطاعم';

  @override
  String get mapFilterPharmacies => 'الصيدليات';

  @override
  String get mapFilterHospitals => 'المستشفيات';

  @override
  String get mapFilterBanks => 'Banks';

  @override
  String get mapFilterGasStations => 'Gas stations';

  @override
  String get mapFilterShops => 'Shops';

  @override
  String get mapFilterConsulates => 'Consulates';

  @override
  String get notificationsFallbackTitle => 'إشعار';

  @override
  String get jojTitle => 'معلومات الدورة';

  @override
  String get jojTabCalendar => 'التقويم';

  @override
  String jojTabSportsWithCount(Object count) {
    return 'الرياضات ($count)';
  }

  @override
  String get jojTabAccess => 'الدخول';

  @override
  String get jojCalendarComingSoon => 'التقويم قريبًا';

  @override
  String get jojDefaultEventTitle => 'فعالية';

  @override
  String get jojNoSportsAvailable => 'لا توجد رياضات متاحة';

  @override
  String get jojDefaultLocation => 'دكار';

  @override
  String get jojDatesComingSoon => 'المواعيد قريبًا';

  @override
  String get jojSeeOnMap => 'عرض على الخريطة';

  @override
  String get jojDestinationFallback => 'الوجهة';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get languagePortuguese => 'البرتغالية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get profileEditTitle => 'تعديل الملف الشخصي';

  @override
  String get profileNameLabel => 'الاسم';

  @override
  String get profilePhoneLabel => 'الهاتف';

  @override
  String get profileLanguageLabel => 'اللغة';

  @override
  String get profileUserTypeLabel => 'نوع المستخدم';

  @override
  String get profileUserTypeVisitor => 'زائر';

  @override
  String get profileUserTypeCitizen => 'مواطن';

  @override
  String get profileUserTypeAthlete => 'رياضي';

  @override
  String get profileNameRequired => 'الاسم مطلوب';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get profileSave => 'حفظ';

  @override
  String get sosServicePolice => 'الشرطة';

  @override
  String get sosServiceFirefighters => 'المطافئ';

  @override
  String get sosServiceAmbulance => 'الإسعاف';

  @override
  String get sosFallbackAddress => 'Dakar Plateau, 9 Rue Carnot';

  @override
  String get homeAppNamePart1 => 'Teranga ';

  @override
  String get homeAppNamePart2 => 'Pass';

  @override
  String get homeTagline => 'أمانك في دكار، اكتشافاتك في السنغال';

  @override
  String get homePillarDiscoverTitle => 'اكتشف';

  @override
  String get homePillarDiscoverSubtitle => 'مواقع · مطاعم · فنادق';

  @override
  String get homePillarMoveTitle => 'تنقّل';

  @override
  String get homePillarMoveSubtitle => 'خريطة · حافلات · تاكسي';

  @override
  String get homePillarJojTitle => 'الألعاب 2026';

  @override
  String get homePillarJojSubtitle => 'التقويم · الميداليات';

  @override
  String get homePillarHelpTitle => 'احصل على مساعدة';

  @override
  String get homePillarHelpSubtitle => 'SOS · طبي · سفارة';

  @override
  String get homeHelpSheetTitle => 'احصل على مساعدة';

  @override
  String get homeHelpSheetSubtitle => 'اختر إجراءً سريعًا';

  @override
  String get homeHeroWelcome => 'مرحبًا بك في السنغال،';

  @override
  String get nearbyChipHotels => 'الفنادق';

  @override
  String get nearbyChipHospitals => 'المستشفيات';

  @override
  String get nearbyChipClinics => 'العيادات';

  @override
  String get nearbyChipNotaries => 'الكتّاب العدليون';

  @override
  String get nearbyChipLawyers => 'المحامون';

  @override
  String get nearbyChipDoctors => 'الأطباء';

  @override
  String get nearbyChipGovernment => 'الدولة';

  @override
  String get nearbyChipSchools => 'المدارس';

  @override
  String get nearbyChipUniversities => 'الجامعات';

  @override
  String get nearbyChipMedia => 'الإعلام';

  @override
  String get nearbyChipProfessionalServices => 'المهنيون';

  @override
  String get nearbyChipReligiousSites => 'الأماكن الدينية';

  @override
  String get nearbyAll => 'الكل';

  @override
  String get nearbyTitle => 'بالقرب منك';

  @override
  String get nearbyNearMeTooltip => 'قريب مني';

  @override
  String nearbyRadiusLabel(int meters) {
    return 'النطاق: $meters م';
  }

  @override
  String get nearbyEmpty => 'لا توجد أماكن ضمن هذا النطاق لهذه الفئة.';

  @override
  String get nearbyLocationError =>
      'تحديد الموقع غير مفعّل. فعّله لعرض الأماكن القريبة.';

  @override
  String get nearbySponsorBadge => 'شريك';

  @override
  String get profileThemeSetting => 'المظهر';

  @override
  String get profileThemeSettingHint =>
      'اختر الوضع الفاتح أو الداكن أو التلقائي.';

  @override
  String get profileThemeSystem => 'تلقائي (النظام)';

  @override
  String get profileThemeLight => 'الوضع الفاتح';

  @override
  String get profileThemeDark => 'الوضع الداكن';

  @override
  String get profileEsimTitle => 'خطط eSIM';

  @override
  String get profileEsimSubtitle => 'قريبًا';

  @override
  String get esimComingBadge => 'قريبًا';

  @override
  String get esimComingTitle => 'خطط eSIM';

  @override
  String get esimComingBody =>
      'ستتوفر قريبًا حزم الإنترنت لرحلاتكم في السنغال مباشرة عبر تيرانغا باس.\n\nشكرًا لصبركم.';

  @override
  String get mapLegendTitle => 'المفتاح';

  @override
  String get mapLegendYou => 'أنت';

  @override
  String get mapLegendPlace => 'مكان';

  @override
  String get mapLegendSponsor => 'شريك مميز';

  @override
  String get mapLegendCategoriesHint =>
      'ألوان العلامات على الخريطة تدل على نوع المكان (الفلاتر أعلاه).';

  @override
  String get mapLegendJojSitesHint =>
      'العلامات الخضراء: مواقع منافسات الألعاب على الخريطة.';

  @override
  String get profileOfflinePackTitle => 'حزمة بلا إنترنت';

  @override
  String get profileOfflinePackBody =>
      'نقاط الاهتمام والمحتوى المفيد بدون شبكة (نشر تدريجي).';

  @override
  String profileOfflinePackCatalogVersion(String version) {
    return 'كتالوج الخادم: $version';
  }

  @override
  String get profileOfflinePackCatalogPending => 'الكتالوج: غير متزامن';

  @override
  String get profileOfflinePackDialogBody =>
      'قم بتنزيل نقاط الاهتمام ومواقع الألعاب والسفارات والتقويم والإعلانات للتصفح بدون إنترنت. في حالة انقطاع الاتصال، يُستأنف التنزيل: الملفات الصحيحة يتم تخطيها.';

  @override
  String get profileOfflinePackDownload => 'تنزيل / تحديث';

  @override
  String profileOfflinePackProgressDetail(
    int current,
    int total,
    String bundleId,
  ) {
    return '$current / $total · $bundleId';
  }

  @override
  String get profileOfflinePackDownloadSuccess => 'تم حفظ الحزمة على الجهاز.';

  @override
  String get profileOfflinePackDownloadPartial =>
      'التنزيل غير مكتمل. حاول مجددًا مع الإنترنت.';

  @override
  String get profileOfflinePackAlreadyCurrent => 'لديك بالفعل آخر نسخة محليًا.';

  @override
  String get profileOfflinePackDownloadError =>
      'تعذّر جلب البيان. تحقق من الشبكة.';

  @override
  String get offlineUsingCache =>
      'وضع بلا إنترنت: البيانات من الذاكرة المؤقتة.';

  @override
  String offlinePackUpdated(String version) {
    return 'تم حفظ الحزمة $version على الجهاز.';
  }

  @override
  String profileOfflinePackFilesVersion(String version) {
    return 'الملفات المحلية: $version';
  }

  @override
  String get profileOfflinePackStaleFiles =>
      'بعض الملفات أقدم من الكتالوج: اتصل بالشبكة لإتمام التحديث.';

  @override
  String profileOfflinePackLocalSize(String size) {
    return 'التخزين المحلي: $size';
  }

  @override
  String get incidentTrackingNavTitle => 'بلاغي';

  @override
  String get incidentTypeLossLabel => 'فقدان شيء أو متعلقات شخصية';

  @override
  String get incidentTypeSuspiciousLabel => 'سلوك مريب';

  @override
  String get incidentTypeOtherLabel => 'بلاغ آخر';

  @override
  String get incidentStatusInProgress => 'جارٍ المعالجة';

  @override
  String get incidentStatusProcessed => 'تمت المعالجة';

  @override
  String get incidentStatusValidated => 'تم التحقق';

  @override
  String get incidentStatusRejected => 'مرفوض';

  @override
  String get incidentStatusPending => 'قيد الانتظار';

  @override
  String get incidentStatusCancelled => 'ملغى';

  @override
  String get incidentTrackingEmptyTimeline =>
      'سيظهر تتبع البلاغ فور معالجة ملفك.';

  @override
  String get loadingWait => 'يرجى الانتظار…';

  @override
  String get homeSearchHint => 'مطاعم، مواقع، فنادق، فعاليات...';

  @override
  String get homeJojCountdownLabel => 'أيام حتى الألعاب';

  @override
  String get homeJojOlympicSubtitle => 'ألعاب الشباب الأولمبية';

  @override
  String get homeJojCityLine => 'داكار 2026';

  @override
  String get homeJojDateRange => '31 أكتوبر -> 13 نوفمبر';

  @override
  String get homeEsimConnectSubtitle => 'قريبًا';

  @override
  String get homeNearbySubtitle => 'حولي';

  @override
  String get homeAudioListenSubtitle => 'استمع';

  @override
  String get homeMyReportsTitle => 'بلاغاتي';

  @override
  String get homeMyReportsSubtitle => 'تتبّع';

  @override
  String get homeCurrencyTitle => 'محوّل العملات';

  @override
  String get authRequiredTitle => 'Sign-in required';

  @override
  String authRequiredBody(Object featureName) {
    return 'To use \"$featureName\", sign in or create an account.';
  }

  @override
  String authRequiredBodyGuestHint(Object featureName) {
    return 'To use \"$featureName\", sign in to save your actions.';
  }

  @override
  String get authRequiredExploreHint =>
      'يمكنك متابعة استكشاف السياحة والأماكن الموصى بها دون حساب.';

  @override
  String get authLater => 'Later';

  @override
  String get authFeatureMedicalAlert => 'Medical alert';

  @override
  String get authFeatureAiAssistant => 'AI assistant';

  @override
  String get authFeatureReport => 'Report';

  @override
  String get authFeatureMyReports => 'My reports';

  @override
  String get authFeatureSos => 'SOS emergency';

  @override
  String get authFeatureMapAndRoute => 'the map and route';

  @override
  String get authFeatureRoute => 'the route';

  @override
  String get authFeatureLeaveReview => 'Leave a review';

  @override
  String get weatherUnavailable => 'Unavailable';

  @override
  String get weatherDefaultLabel => 'Weather';

  @override
  String get homeLogin => 'Sign in';

  @override
  String get recommendedSectionTitle => 'Our recommendations';

  @override
  String get recommendedSectionSubtitle =>
      'Teranga Pass picks · hotels, restaurants and useful places';

  @override
  String get recommendedBadge => 'Recommended';

  @override
  String get viewOnMap => 'View on map';

  @override
  String get loadingPleaseWait => 'Please wait…';

  @override
  String get promoCloseBarrier => 'Close ad';

  @override
  String get promoLearnMore => 'Learn more';

  @override
  String promoSponsoredLabel(Object sponsor) {
    return 'Ad · $sponsor';
  }

  @override
  String get aiWelcomeMessage =>
      'Hello, I\'m your Teranga Pass AI assistant. How can I help?';

  @override
  String get aiDisclaimer =>
      'Answers based on TerangaPass data (sites, shuttles, tourism).';

  @override
  String get aiSuggestionCompetitionSites => 'Competition sites';

  @override
  String get aiSuggestionCompetitionSitesQuery =>
      'What are the JOJ competition sites?';

  @override
  String get aiSuggestionShuttles => 'Shuttles';

  @override
  String get aiSuggestionShuttlesQuery => 'Shuttle schedules';

  @override
  String get aiSuggestionTourism => 'Tourist info';

  @override
  String get aiSuggestionTourismQuery => 'Tourist places in Dakar';

  @override
  String get aiSuggestionAnnouncements => 'Announcements';

  @override
  String get aiSuggestionAnnouncementsQuery => 'Latest audio announcements';

  @override
  String get aiSuggestionEmergencies => 'Emergencies';

  @override
  String get aiSuggestionEmergenciesQuery => 'Emergency numbers in Senegal';

  @override
  String get aiSuggestionCalendar => 'Calendar';

  @override
  String get aiSuggestionCalendarQuery => 'JOJ competition calendar';

  @override
  String get aiEmptyReply => 'I couldn\'t generate a reply. Please try again.';

  @override
  String aiErrorPrefix(Object error) {
    return 'AI error: $error';
  }

  @override
  String get aiTitle => 'TerangaPass AI assistant';

  @override
  String aiConnectedAs(Object name) {
    return 'Signed in as: $name';
  }

  @override
  String get aiAllowLocation => 'Allow location';

  @override
  String get aiSuggestionsTitle => 'Suggestions';

  @override
  String get aiMessageHint => 'Write a message...';

  @override
  String get placeLeaveReviewTitle => 'Leave a review';

  @override
  String get placeReviewCommentHint => 'Your comment (optional)…';

  @override
  String get placeReviewPublish => 'Publish';

  @override
  String get placeReviewPublished => 'Review published.';

  @override
  String get placeReviewSavedOffline => 'Review saved offline.';

  @override
  String get placeReviewsUnavailableDetail =>
      'Reviews are not available for this place.';

  @override
  String get placeReviewsEmptyDetail =>
      'No reviews yet.\nBe the first to leave a comment!';

  @override
  String get placePhotoGallery => 'Photo gallery';

  @override
  String get placeInfoDistance => 'Distance';

  @override
  String get placeInfoAddress => 'Address';

  @override
  String get placeInfoPhone => 'Phone';

  @override
  String get placeInfoHours => 'Hours';

  @override
  String get placeInfoDuration => 'Estimated duration';

  @override
  String get placeInfoDirections => 'How to get there';

  @override
  String get placeWebsite => 'Website';

  @override
  String get placeDescription => 'Description';

  @override
  String get placeReviewsSectionTitle => 'Reviews & comments';

  @override
  String placeReviewCount(int count) {
    return '$count reviews';
  }

  @override
  String get placeReviewsUnavailable => 'Reviews are not available right now.';

  @override
  String get placeReviewsEmpty => 'No reviews yet. Be the first!';

  @override
  String get reviewAuthorMe => 'Me';

  @override
  String get reviewAuthorAnonymous => 'Anonymous';

  @override
  String get embassiesTitle => 'Embassies';

  @override
  String get embassiesSearchHint => 'Search for a country...';

  @override
  String get embassiesSortDistance => 'Distance';

  @override
  String get embassiesSortRating => 'Rating';

  @override
  String get embassiesSortName => 'A-Z';

  @override
  String get embassyTypeConsulate => 'Consulate';

  @override
  String get embassyTypeEmbassy => 'Embassy';

  @override
  String embassyOpeningHours(Object hours) {
    return 'Hours: $hours';
  }

  @override
  String embassyRating(Object rating) {
    return 'Rating: $rating / 5';
  }

  @override
  String embassyCoordinates(Object coords) {
    return 'Coordinates: $coords';
  }

  @override
  String embassyPhone(Object phone) {
    return 'Tel: $phone';
  }

  @override
  String embassyEmail(Object email) {
    return 'Email: $email';
  }

  @override
  String get embassyActionMap => 'Map';

  @override
  String get embassyActionWebsite => 'Website';

  @override
  String get embassyUrgent => 'Emergency';

  @override
  String get embassyFilterConsulates => 'Consulates';

  @override
  String get embassyFilterEmbassies => 'Embassies';

  @override
  String embassyDistanceLabel(Object distance) {
    return 'Distance: $distance';
  }

  @override
  String get tourismSearchMinChars => 'Enter at least 2 characters to search.';

  @override
  String get tourismSearchNoResults => 'No places found for this search.';

  @override
  String get tourismSearchUnavailable => 'Search unavailable at the moment.';

  @override
  String get tourismLocalFilterHint => 'Local filter on the displayed list.';

  @override
  String get tourismEmptySearch => 'No places for this search';

  @override
  String get nearbyErrorLocationDisabled =>
      'Phone location is off. Enable it in settings.';

  @override
  String get nearbyErrorPermissionDenied =>
      'Location permission denied. Allow it to see nearby places.';

  @override
  String get nearbyErrorPositionTimeout =>
      'Position unavailable for now. Try again.';

  @override
  String nearbyFallbackOutOfRadius(int radius) {
    return 'No places within $radius m. Widen the radius or change category.';
  }

  @override
  String get incidentVideoGallery => 'Video gallery';

  @override
  String get incidentVideoCamera => 'Video camera';

  @override
  String get incidentAddVideoError => 'Could not add video';

  @override
  String get incidentTrackAction => 'Track';

  @override
  String get incidentReportNavShort => 'Report';

  @override
  String get incidentHistoryTooltip => 'History';

  @override
  String get incidentPrivacyNotice =>
      'Your evidence will be encrypted and sent securely.';

  @override
  String get incidentEvidencePhoto => 'Photo';

  @override
  String get incidentEvidenceVideo => 'Video';

  @override
  String get incidentEvidenceAudio => 'Audio';

  @override
  String incidentVideosAddedCount(int count) {
    return '$count video(s) added';
  }

  @override
  String incidentDossierRef(Object year, Object month, Object id) {
    return 'File TP-$year-$month-$id';
  }

  @override
  String incidentDossierRefShort(Object id) {
    return 'File #$id';
  }

  @override
  String get jojNoEventsForDate => 'No events for this date';

  @override
  String get jojCurrencyConverterTooltip => 'Converter';

  @override
  String mapRouteServerError(int code) {
    return 'Server error ($code)';
  }

  @override
  String get mapRouteNotFound => 'No route found';

  @override
  String get mapRouteDirectionsApiError =>
      'Could not calculate route. Try again.';

  @override
  String get mapGuestPointsUnavailable =>
      'Places unavailable for now. Sign in to see all.';

  @override
  String get mapMissingCoordinates => 'Missing coordinates';

  @override
  String get mapNavInProgress => 'Navigation in progress';

  @override
  String mapNavRemaining(Object distance) {
    return '$distance left';
  }

  @override
  String get mapNavStop => 'Stop navigation';

  @override
  String mapRouteSummaryDriving(Object distance, Object duration) {
    return '$distance · $duration by car';
  }

  @override
  String get mapRouteRecalculate => 'Recalculate';

  @override
  String get mapRouteView => 'View route';

  @override
  String get mapNavStart => 'Start';

  @override
  String get mapNavDefaultInstruction => 'Navigating…';

  @override
  String mapNavRemainingDistance(Object distance) {
    return 'Remaining distance: $distance';
  }

  @override
  String get mapNavFollowRoute => 'Follow the route';

  @override
  String get mapNavFollowRouteToDestination =>
      'Follow the route to your destination';

  @override
  String mapNavInMeters(Object distance) {
    return 'In $distance meters';
  }

  @override
  String mapNavInKilometers(Object distance) {
    return 'In $distance kilometers';
  }

  @override
  String get mapNavApproachingTitle => 'You\'re getting close!';

  @override
  String mapNavApproachingBody(Object distance) {
    return 'Your destination is $distance away';
  }

  @override
  String get mapNavArrivedTitle => 'You have arrived!';

  @override
  String get mapNavArrivedBody => 'You have reached your destination.';

  @override
  String get mapNavArrivedVoice => 'You have arrived at your destination';

  @override
  String mapNavInstructionDepart(Object destination) {
    return 'Head toward $destination';
  }

  @override
  String mapNavInstructionContinue(Object road) {
    return 'Continue on $road';
  }

  @override
  String mapNavInstructionTurn(Object direction, Object road) {
    return 'Turn $direction onto $road';
  }

  @override
  String mapNavInstructionRoundabout(Object exit) {
    return 'At the roundabout, take the $exit exit';
  }

  @override
  String mapNavInstructionArrive(Object destination) {
    return 'You have arrived at $destination';
  }
}
