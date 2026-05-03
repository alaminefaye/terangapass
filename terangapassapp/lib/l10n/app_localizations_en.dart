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
  String get profileDefaultSosTitle => 'SOS alert';

  @override
  String get profileDefaultReportTitle => 'Report';

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
  String get mapPlaceholderSubtitle => 'Google Maps integration coming soon';

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
  String get profileEsimTitle => 'eSIM plans';

  @override
  String get profileEsimSubtitle => 'Travel data (coming soon)';

  @override
  String get esimComingTitle => 'Teranga Pass eSIM';

  @override
  String get esimComingBody =>
      'Partner integration (e.g. Airalo), payments (PayDunya, Wave) and QR activation will ship in a later release. This screen is a placeholder for demo and product sign-off.';
}
