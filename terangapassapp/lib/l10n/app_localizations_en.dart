// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Teranga Pass';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get filter => 'Filter';

  @override
  String get allZones => 'All zones';

  @override
  String get zoneLabel => 'Area';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get clearAll => 'Clear all';

  @override
  String get clearAllConfirmTitle => 'Clear all notifications';

  @override
  String get clearAllConfirmBody =>
      'All your personal notifications will be deleted. This action cannot be undone.';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get markAsUnread => 'Mark as unread';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get delete => 'Delete';

  @override
  String get deleteNotificationTitle => 'Delete notification';

  @override
  String get deleteNotificationBody =>
      'Are you sure you want to delete this notification?';

  @override
  String unreadCount(int count) {
    return '$count unread';
  }

  @override
  String get notifChipSosShort => 'SOS';

  @override
  String get notifChipMedicalShort => 'Medical emergency';

  @override
  String get notifChipIncidentShort => 'Report';

  @override
  String get notifChipSosSent => 'SOS sent';

  @override
  String get notifChipMedicalSent => 'Medical alert';

  @override
  String get notifChipIncidentReceived => 'Report received';

  @override
  String get notifChipStatusPending => 'Pending';

  @override
  String get notifChipStatusInProgress => 'In progress';

  @override
  String get notifChipStatusResolved => 'Resolved';

  @override
  String get notifChipStatusCancelled => 'Cancelled';

  @override
  String get notifChipIncidentValidated => 'Validated';

  @override
  String get notifChipIncidentRejected => 'Rejected';

  @override
  String get notifChipFollowUp => 'Update';

  @override
  String get notifChipGeneral => 'Message';

  @override
  String get notifChipAudioAnnouncement => 'Audio announcement';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get openMapError => 'Unable to open the map';

  @override
  String get settings => 'Settings';

  @override
  String get appLanguage => 'App language';

  @override
  String get loginValueProps =>
      'Discover · Travel with peace of mind · Stay protected';

  @override
  String get loginTagline => 'Your safety in Dakar';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'you@email.com';

  @override
  String get loginEmailRequired => 'Please enter your email';

  @override
  String get loginEmailInvalid => 'Invalid email';

  @override
  String get loginIdentifierLabel => 'Email or phone number';

  @override
  String get loginIdentifierHint => 'you@email.com or phone number';

  @override
  String get loginIdentifierRequired =>
      'Please enter your email or phone number';

  @override
  String get loginPhoneInvalid => 'Invalid number (at least 9 digits)';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginPasswordRequired => 'Please enter your password';

  @override
  String get loginPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginRememberMe => 'Remember me';

  @override
  String get loginNoAccount => 'No account? Sign up';

  @override
  String get loginUnknownError => 'An error occurred';

  @override
  String get loginConnectionError =>
      'Login error. Check your internet connection and try again.';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get registerSubtitle => 'Join Teranga Pass';

  @override
  String get registerFullNameLabel => 'Full name';

  @override
  String get registerFullNameHint => 'Your name';

  @override
  String get registerFullNameRequired => 'Please enter your name';

  @override
  String get registerPhoneHint => 'Phone number';

  @override
  String get registerPhoneNationalHint => 'Without country code';

  @override
  String get registerPhoneRequired => 'Please enter your phone number';

  @override
  String get registerSelectCountry => 'Select a country';

  @override
  String get registerPasswordRequired => 'Please enter a password';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get registerPasswordsNotMatch => 'Passwords do not match';

  @override
  String get registerSignUp => 'Sign up';

  @override
  String get registerHaveAccount => 'Already have an account? Sign in';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get call => 'Call';

  @override
  String get openPhoneError => 'Unable to open the phone app';

  @override
  String get sosEmergencyTitle => 'Emergency SOS';

  @override
  String get sosCancelled => 'SOS alert cancelled';

  @override
  String get sosSentTitle => 'SOS alert sent';

  @override
  String get sosSentBody =>
      'Your SOS alert has been sent to emergency services.\n\nThey will arrive as soon as possible.';

  @override
  String get sosCountdown => 'Alert in...';

  @override
  String get sosAlertSent => 'ALERT SENT!';

  @override
  String get sosUrgenceLabel => 'EMERGENCY SOS';

  @override
  String get sosHoldBanner => 'EMERGENCY — HOLD TO ALERT';

  @override
  String get sosDangerQuestion => 'Are you\nin danger?';

  @override
  String get sosThreeSecondsBadge => '3 SECONDS';

  @override
  String get sosPressToAlert => 'Tap to alert';

  @override
  String get sosCancelAlert => 'CANCEL ALERT';

  @override
  String callServiceTitle(Object service) {
    return 'Call $service';
  }

  @override
  String callServicePrompt(Object service, Object number) {
    return 'Do you want to call $service at $number?';
  }

  @override
  String get sosUnknownPosition => 'Unknown location';

  @override
  String get sosCurrentPosition => 'Your current location';

  @override
  String sosAccuracy(Object meters) {
    return 'Accuracy: $meters meters';
  }

  @override
  String get sosEmergencyServices => 'Emergency services';

  @override
  String get sosHistory => 'History';

  @override
  String get sosNoRecentAlerts => 'No alerts sent recently';

  @override
  String sosNumber(Object number) {
    return 'Number: $number';
  }

  @override
  String get unknownPosition => 'Unknown location';

  @override
  String get incidentReportTitle => 'Report an incident';

  @override
  String get incidentTypeTitle => 'Incident type';

  @override
  String get incidentTypeLoss => 'Loss';

  @override
  String get incidentTypeAccident => 'Accident';

  @override
  String get incidentTypeSuspicious => 'Suspicious';

  @override
  String get incidentDescriptionTitle => 'Description';

  @override
  String get incidentDescriptionHint => 'Describe the incident in detail...';

  @override
  String get incidentPhotosTitle => 'Photos';

  @override
  String get incidentAudioTitle => 'Audio';

  @override
  String get incidentLocationTitle => 'Incident location';

  @override
  String get incidentAdd => 'Add';

  @override
  String get incidentRecordingInProgress => 'Recording in progress...';

  @override
  String get incidentAddVoiceMessage => 'Add a voice message';

  @override
  String get incidentTapToRecord => 'Tap to record';

  @override
  String get incidentAudioAdded => 'Audio added';

  @override
  String get incidentSendReport => 'SEND REPORT';

  @override
  String get incidentSelectTypeError => 'Please select an incident type';

  @override
  String get incidentDescribeError => 'Please describe the incident';

  @override
  String get incidentSentTitle => 'Report sent';

  @override
  String get incidentSentBody =>
      'Your report has been sent to the relevant authorities.\n\nYou will receive a response as soon as possible.';

  @override
  String get incidentAddPhotoError => 'Unable to add a photo';

  @override
  String get incidentStopRecordingError => 'Unable to stop recording';

  @override
  String get incidentMicPermissionDenied => 'Microphone permission denied';

  @override
  String get incidentStartRecordingError => 'Unable to start recording';

  @override
  String get incidentGallery => 'Gallery';

  @override
  String get incidentCamera => 'Camera';

  @override
  String get medicalAlertTitle => 'Medical alert';

  @override
  String get homeFeatureAudioAnnouncements => 'Audio announcements';

  @override
  String get homeFeatureTouristInfo => 'Tourist info';

  @override
  String get homeFeatureCompetitionSites => 'Competition sites';

  @override
  String get homeFeatureCompetitions => 'Competitions';

  @override
  String get homeFeatureTransport => 'Shuttles & transport';

  @override
  String get homeFeatureReportIncident => 'Report incident';

  @override
  String get homeOfficialAnnouncementDefaultTitle => 'Official announcement';

  @override
  String get passQrTitle => 'My Teranga Pass';

  @override
  String get passQrEntry => 'Show my Pass (QR)';

  @override
  String get passQrSubtitle =>
      'Show this code at access checkpoints (JOJ pilot).';

  @override
  String get passQrRetry => 'Retry';

  @override
  String get homeJojInfoTitle => 'JOJ INFO: Competition sites';

  @override
  String get homeCalendar => 'Schedule';

  @override
  String get homeNoActiveSites => 'No active site';

  @override
  String get homeAddLatLngHint => 'Add latitude/longitude in the dashboard';

  @override
  String get homeSiteFallback => 'Site';

  @override
  String get homeNavHome => 'Home';

  @override
  String get homeNavMedicalAlert => 'Medical';

  @override
  String get homeNavSos => 'SOS';

  @override
  String get homeNavReport => 'Report';

  @override
  String get homeNavProfile => 'Profile';

  @override
  String get homeComingSoon => 'This feature will be available soon.';

  @override
  String get medicalSelectTypeError => 'Please select a medical emergency type';

  @override
  String get medicalSentTitle => 'Medical alert sent';

  @override
  String get medicalSentBody =>
      'Your medical alert has been sent to medical services.\n\nAn ambulance is on its way.';

  @override
  String get medicalSending => 'Sending alert...';

  @override
  String get medicalTapToAlert => 'Tap to alert medical services';

  @override
  String get medicalEmergencyTypeTitle => 'Medical emergency type';

  @override
  String get medicalTypeAccident => 'Accident';

  @override
  String get medicalTypeFainting => 'Fainting';

  @override
  String get medicalTypeInjury => 'Injury';

  @override
  String get medicalTypeOther => 'Other';

  @override
  String get medicalYourPosition => 'Your location';

  @override
  String get medicalNearbyHospitals => 'Nearby hospitals';

  @override
  String get medicalNoNearbyHospitals => 'No nearby hospitals found';

  @override
  String medicalEmergencyNumberLabel(Object number) {
    return 'Emergency $number';
  }

  @override
  String get transportTitle => 'Transport & shuttles';

  @override
  String get transportNoShuttles => 'No shuttles available';

  @override
  String get transportSecure => 'Secure';

  @override
  String transportTerminusPrefix(Object terminus) {
    return 'Terminus: $terminus';
  }

  @override
  String get transportNextDeparturePrefix => 'Next departure:';

  @override
  String get transportNextDeparture => 'Next departure';

  @override
  String get transportItinerarySection => 'Route';

  @override
  String get transportRouteLabel => 'Route';

  @override
  String get transportDepartureLabel => 'Departure';

  @override
  String get transportTerminusLabel => 'Terminus';

  @override
  String get transportStartPointLabel => 'Starting point';

  @override
  String get transportScheduleSection => 'Schedule';

  @override
  String get transportScheduleLabel => 'Time';

  @override
  String get transportDaysLabel => 'Days';

  @override
  String get transportPeriodLabel => 'Period';

  @override
  String get transportFrequencyLabel => 'Frequency';

  @override
  String get transportStopsSection => 'Stops';

  @override
  String get transportDescriptionSection => 'Description';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(Object count) {
    return '$count min ago';
  }

  @override
  String timeHoursAgo(Object count) {
    return '$count h ago';
  }

  @override
  String timeDaysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileUnavailable => 'Profile unavailable';

  @override
  String get profilePersonalInfoSection => 'Personal information';

  @override
  String get profileNotificationsSetting => 'Notifications';

  @override
  String get profileGeolocationSetting => 'Location';

  @override
  String get profilePrivacySetting => 'Privacy';

  @override
  String get profileOverviewSection => 'Overview';

  @override
  String get profileAlertsStat => 'Alerts';

  @override
  String get profileReportsStat => 'Reports';

  @override
  String get profileRecentActivitiesSection => 'Recent activity';

  @override
  String get profileNoRecentActivity => 'No recent activity';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileDeleteAccount => 'Delete my account';

  @override
  String get profileDeleteAccountTitle => 'Delete account';

  @override
  String get profileDeleteAccountBody =>
      'This action cannot be undone. Your alerts, reports and associated data will be permanently deleted. To confirm, type exactly the following code in the field below:';

  @override
  String get profileDeleteAccountCodeLabel => 'Confirmation code';

  @override
  String get profileDeleteAccountCodeHint => 'teranga pass';

  @override
  String get profileDeleteAccountCodeFieldHint => 'Enter the code here';

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
  String get profileDefaultSosTitle => 'SOS alert';

  @override
  String get profileDefaultReportTitle => 'Report';

  @override
  String get historyUnifiedTitle => 'SOS, medical & reports';

  @override
  String get historyUnifiedEmpty => 'No SOS, medical alerts or reports yet';

  @override
  String get historyKindSos => 'SOS';

  @override
  String get historyKindMedical => 'Medical alert';

  @override
  String get historyKindReport => 'Report';

  @override
  String get historyAlertDetailTitle => 'Alert details';

  @override
  String get historyFieldAddress => 'Address';

  @override
  String get historyFieldDate => 'Date';

  @override
  String get historyFieldCoords => 'Coordinates';

  @override
  String get alertTrackingNavTitle => 'My alert';

  @override
  String get alertTimelineRecorded => 'Alert recorded';

  @override
  String get alertTimelineDispatched => 'Sent to emergency services';

  @override
  String get alertTimelineClosed => 'Closed';

  @override
  String get alertTimelineRejected => 'Declined';

  @override
  String get alertTimelineCancelled => 'Cancelled';

  @override
  String get privacyPersonalDataTitle => 'Personal data';

  @override
  String get privacyPersonalDataBody =>
      'Teranga Pass uses your information to improve your experience (e.g., profile, notifications, safety). You can manage certain permissions from your phone.';

  @override
  String get privacyLocationSubtitle => 'Allow to show nearby points.';

  @override
  String get privacyNotificationsSubtitle =>
      'Receive alerts and useful information.';

  @override
  String get audioTitle => 'Audio announcements';

  @override
  String get audioNoAudioAvailable =>
      'No audio available for this announcement';

  @override
  String get audioCannotPlay => 'Unable to play audio';

  @override
  String get audioNoAnnouncements => 'No announcements available';

  @override
  String get audioAllLanguages => 'All';

  @override
  String get tourismTitle => 'Tourism & Services';

  @override
  String get tourismCategoryAll => 'All';

  @override
  String get tourismCategoryHotels => 'Hotels';

  @override
  String get tourismCategoryRestaurants => 'Restaurants';

  @override
  String get tourismCategoryPharmacies => 'Pharmacies';

  @override
  String get tourismCategoryHospitals => 'Hospitals';

  @override
  String get tourismCategoryEmbassies => 'Embassies';

  @override
  String tourismTabWithCount(Object label, Object count) {
    return '$label ($count)';
  }

  @override
  String get tourismCoordinatesMissing => 'Missing coordinates';

  @override
  String get tourismEnableLocation => 'Enable location';

  @override
  String get tourismDistanceUnavailable => 'Distance unavailable';

  @override
  String get tourismSettingsButton => 'Settings';

  @override
  String get tourismEnableGpsButton => 'Enable GPS';

  @override
  String get tourismNoResults => 'No results';

  @override
  String get mapTitle => 'Interactive Map';

  @override
  String get mapPlaceholderTitle => 'Interactive map';

  @override
  String get mapPlaceholderSubtitle => 'Search for a place or address…';

  @override
  String get mapOpenInGoogleMaps => 'Open in Google Maps';

  @override
  String get mapNearbyPointsTitle => 'Nearby points of interest';

  @override
  String get mapNoPoints => 'No points available';

  @override
  String get mapDefaultPointName => 'Point of interest';

  @override
  String get mapPositionUpdated => 'Position updated';

  @override
  String get mapCannotGetPosition => 'Unable to get location';

  @override
  String get mapOpenGoogleMapsError => 'Unable to open Google Maps';

  @override
  String get mapTilesLoadIssue =>
      'Map data may be incomplete. Check your connection.';

  @override
  String get mapFilterAll => 'All';

  @override
  String get mapFilterHelp => 'Help';

  @override
  String get mapFilterSites => 'JOJ sites';

  @override
  String get mapFilterHotels => 'Hotels';

  @override
  String get mapFilterRestaurants => 'Restaurants';

  @override
  String get mapFilterPharmacies => 'Pharmacies';

  @override
  String get mapFilterHospitals => 'Hospitals';

  @override
  String get mapFilterBanks => 'Banks';

  @override
  String get mapFilterGasStations => 'Gas stations';

  @override
  String get mapFilterShops => 'Shops';

  @override
  String get mapFilterConsulates => 'Consulates';

  @override
  String get notificationsFallbackTitle => 'Notification';

  @override
  String get jojTitle => 'JOJ info';

  @override
  String get jojTabCalendar => 'Calendar';

  @override
  String jojTabSportsWithCount(Object count) {
    return 'Sports ($count)';
  }

  @override
  String get jojTabAccess => 'Access';

  @override
  String get jojCalendarComingSoon => 'Calendar coming soon';

  @override
  String get jojDefaultEventTitle => 'Event';

  @override
  String get jojNoSportsAvailable => 'No sports available';

  @override
  String get jojDefaultLocation => 'Dakar';

  @override
  String get jojDatesComingSoon => 'Dates coming soon';

  @override
  String get jojSeeOnMap => 'View on map';

  @override
  String get jojDestinationFallback => 'Destination';

  @override
  String get languageFrench => 'French';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profilePhoneLabel => 'Phone';

  @override
  String get profileLanguageLabel => 'Language';

  @override
  String get profileUserTypeLabel => 'User type';

  @override
  String get profileUserTypeVisitor => 'Visitor';

  @override
  String get profileUserTypeCitizen => 'Citizen';

  @override
  String get profileUserTypeAthlete => 'Athlete';

  @override
  String get profileNameRequired => 'Name is required';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profileSave => 'Save';

  @override
  String get sosServicePolice => 'Police';

  @override
  String get sosServiceFirefighters => 'Firefighters';

  @override
  String get sosServiceAmbulance => 'Ambulance';

  @override
  String get sosFallbackAddress => 'Dakar Plateau, 9 Rue Carnot';

  @override
  String get homeAppNamePart1 => 'Teranga ';

  @override
  String get homeAppNamePart2 => 'Pass';

  @override
  String get homeTagline => 'Your safety in Dakar, discoveries in Senegal';

  @override
  String get homePillarDiscoverTitle => 'Discover';

  @override
  String get homePillarDiscoverSubtitle => 'Venues · Dining · Hotels';

  @override
  String get homePillarMoveTitle => 'Get around';

  @override
  String get homePillarMoveSubtitle => 'Map · Shuttles · Taxis';

  @override
  String get homePillarJojTitle => 'Youth Olympics 2026';

  @override
  String get homePillarJojSubtitle => 'Schedule · Medals';

  @override
  String get homePillarHelpTitle => 'Get help';

  @override
  String get homePillarHelpSubtitle => 'SOS · Medical · Embassy';

  @override
  String get homeHelpSheetTitle => 'Get help';

  @override
  String get homeHelpSheetSubtitle => 'Pick a quick action';

  @override
  String get homeHeroWelcome => 'Welcome to Senegal,';

  @override
  String get nearbyChipHotels => 'Hotels';

  @override
  String get nearbyChipHospitals => 'Hospitals';

  @override
  String get nearbyChipClinics => 'Clinics';

  @override
  String get nearbyChipNotaries => 'Notaries';

  @override
  String get nearbyChipLawyers => 'Lawyers';

  @override
  String get nearbyChipDoctors => 'Doctors';

  @override
  String get nearbyChipGovernment => 'Government';

  @override
  String get nearbyChipSchools => 'Schools';

  @override
  String get nearbyChipUniversities => 'Universities';

  @override
  String get nearbyChipMedia => 'Media';

  @override
  String get nearbyChipProfessionalServices => 'Pros';

  @override
  String get nearbyChipReligiousSites => 'Faith';

  @override
  String get nearbyAll => 'All';

  @override
  String get nearbyTitle => 'Nearby';

  @override
  String get nearbyNearMeTooltip => 'Near me';

  @override
  String nearbyRadiusLabel(int meters) {
    return 'Radius: $meters m';
  }

  @override
  String get nearbyEmpty => 'No places in this radius for this category.';

  @override
  String get nearbyLocationError => 'Enable location to see nearby places.';

  @override
  String get nearbySponsorBadge => 'Partner';

  @override
  String get profileThemeSetting => 'Appearance';

  @override
  String get profileThemeSettingHint =>
      'Choose light, dark, or follow system settings.';

  @override
  String get profileThemeSystem => 'Automatic (system)';

  @override
  String get profileThemeLight => 'Light mode';

  @override
  String get profileThemeDark => 'Dark mode';

  @override
  String get profileEsimTitle => 'eSIM plans';

  @override
  String get profileEsimSubtitle => 'Coming soon';

  @override
  String get esimComingBadge => 'Coming soon';

  @override
  String get esimComingTitle => 'eSIM plans';

  @override
  String get esimComingBody =>
      'Travel data packages for Senegal will be available soon in Teranga Pass.\n\nThank you for your patience.';

  @override
  String get mapLegendTitle => 'Legend';

  @override
  String get mapLegendYou => 'You';

  @override
  String get mapLegendPlace => 'Place';

  @override
  String get mapLegendSponsor => 'Featured partner';

  @override
  String get mapLegendCategoriesHint =>
      'Marker colors on the map indicate the type of place (filters above).';

  @override
  String get mapLegendJojSitesHint =>
      'Green markers: JOJ competition sites on the map.';

  @override
  String get profileOfflinePackTitle => 'Offline pack';

  @override
  String get profileOfflinePackBody =>
      'POI and useful content without a network (rolling rollout).';

  @override
  String profileOfflinePackCatalogVersion(String version) {
    return 'Server catalog: $version';
  }

  @override
  String get profileOfflinePackCatalogPending => 'Catalog: not synced yet';

  @override
  String get profileOfflinePackDialogBody =>
      'Download POI, JOJ sites, embassies, calendar, and announcements for offline use. If the connection drops, the download resumes—files that are already correct are skipped.';

  @override
  String get profileOfflinePackDownload => 'Download / update';

  @override
  String profileOfflinePackProgressDetail(
    int current,
    int total,
    String bundleId,
  ) {
    return '$current / $total · $bundleId';
  }

  @override
  String get profileOfflinePackDownloadSuccess => 'Pack saved on this device.';

  @override
  String get profileOfflinePackDownloadPartial =>
      'Download incomplete. Retry when online.';

  @override
  String get profileOfflinePackAlreadyCurrent =>
      'You already have the latest version locally.';

  @override
  String get profileOfflinePackDownloadError =>
      'Could not fetch the manifest. Check your connection.';

  @override
  String get offlineUsingCache => 'Offline view: using cached data.';

  @override
  String offlinePackUpdated(String version) {
    return 'Pack $version saved on this device.';
  }

  @override
  String profileOfflinePackFilesVersion(String version) {
    return 'Local files: $version';
  }

  @override
  String get profileOfflinePackStaleFiles =>
      'Some files are older than the catalog: go online to finish updating.';

  @override
  String profileOfflinePackLocalSize(String size) {
    return 'Local storage: $size';
  }

  @override
  String get incidentTrackingNavTitle => 'My report';

  @override
  String get incidentTypeLossLabel => 'Lost object or personal belongings';

  @override
  String get incidentTypeSuspiciousLabel => 'Suspicious behaviour';

  @override
  String get incidentTypeOtherLabel => 'Other report';

  @override
  String get incidentStatusInProgress => 'Being processed';

  @override
  String get incidentStatusProcessed => 'Processed';

  @override
  String get incidentStatusValidated => 'Validated';

  @override
  String get incidentStatusRejected => 'Rejected';

  @override
  String get incidentStatusPending => 'Pending';

  @override
  String get incidentStatusCancelled => 'Cancelled';

  @override
  String get incidentTrackingEmptyTimeline =>
      'Tracking will appear once your report is processed.';

  @override
  String get loadingWait => 'Please wait…';

  @override
  String get homeSearchHint => 'Restaurants, sites, hotels, events...';

  @override
  String get homeJojCountdownLabel => 'Days until JOJ';

  @override
  String get homeJojOlympicSubtitle => 'YOUTH OLYMPIC GAMES';

  @override
  String get homeJojCityLine => 'Dakar 2026';

  @override
  String get homeJojDateRange => '31 October -> 13 November';

  @override
  String get homeEsimConnectSubtitle => 'Coming soon';

  @override
  String get homeNearbySubtitle => 'Around me';

  @override
  String get homeAudioListenSubtitle => 'Listen';

  @override
  String get homeMyReportsTitle => 'My reports';

  @override
  String get homeMyReportsSubtitle => 'Track';

  @override
  String get homeCurrencyTitle => 'Converter';

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
      'You can keep exploring tourism and recommended places without an account.';

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
  String get placeReviewSavedOffline =>
      'Review saved on this device. Sign in to share it with everyone.';

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
