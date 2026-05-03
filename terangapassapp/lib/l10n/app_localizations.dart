import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Teranga Pass'**
  String get appTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @filter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get filter;

  /// No description provided for @allZones.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les zones'**
  String get allZones;

  /// No description provided for @zoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Zone'**
  String get zoneLabel;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @noNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotifications;

  /// No description provided for @pullToRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Tirez pour actualiser'**
  String get pullToRefresh;

  /// No description provided for @openMapError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’ouvrir la carte'**
  String get openMapError;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @appLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l’application'**
  String get appLanguage;

  /// No description provided for @loginValueProps.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir · Voyager sereinement · Être protégé'**
  String get loginValueProps;

  /// No description provided for @loginTagline.
  ///
  /// In fr, this message translates to:
  /// **'Votre sécurité à Dakar'**
  String get loginTagline;

  /// No description provided for @loginEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'votre@email.com'**
  String get loginEmailHint;

  /// No description provided for @loginEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'••••••••'**
  String get loginPasswordHint;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre mot de passe'**
  String get loginPasswordRequired;

  /// No description provided for @loginPasswordMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 6 caractères'**
  String get loginPasswordMinLength;

  /// No description provided for @loginSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginSignIn;

  /// No description provided for @loginNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ? S’inscrire'**
  String get loginNoAccount;

  /// No description provided for @loginUnknownError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get loginUnknownError;

  /// No description provided for @loginConnectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion. Vérifiez votre connexion internet et réessayez.'**
  String get loginConnectionError;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez Teranga Pass'**
  String get registerSubtitle;

  /// No description provided for @registerFullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get registerFullNameLabel;

  /// No description provided for @registerFullNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom'**
  String get registerFullNameHint;

  /// No description provided for @registerFullNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre nom'**
  String get registerFullNameRequired;

  /// No description provided for @registerPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un mot de passe'**
  String get registerPasswordRequired;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerConfirmPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez confirmer votre mot de passe'**
  String get registerConfirmPasswordRequired;

  /// No description provided for @registerPasswordsNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get registerPasswordsNotMatch;

  /// No description provided for @registerSignUp.
  ///
  /// In fr, this message translates to:
  /// **'S’inscrire'**
  String get registerSignUp;

  /// No description provided for @registerHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? Se connecter'**
  String get registerHaveAccount;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @call.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get call;

  /// No description provided for @openPhoneError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’ouvrir le téléphone'**
  String get openPhoneError;

  /// No description provided for @sosEmergencyTitle.
  ///
  /// In fr, this message translates to:
  /// **'SOS Urgence'**
  String get sosEmergencyTitle;

  /// No description provided for @sosCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Alerte SOS annulée'**
  String get sosCancelled;

  /// No description provided for @sosSentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alerte SOS envoyée'**
  String get sosSentTitle;

  /// No description provided for @sosSentBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre alerte SOS a été envoyée aux services de secours.\n\nIls arriveront dans les plus brefs délais.'**
  String get sosSentBody;

  /// No description provided for @sosCountdown.
  ///
  /// In fr, this message translates to:
  /// **'Alerte dans...'**
  String get sosCountdown;

  /// No description provided for @sosAlertSent.
  ///
  /// In fr, this message translates to:
  /// **'ALERTE ENVOYÉE !'**
  String get sosAlertSent;

  /// No description provided for @sosUrgenceLabel.
  ///
  /// In fr, this message translates to:
  /// **'SOS URGENCE'**
  String get sosUrgenceLabel;

  /// No description provided for @sosHoldBanner.
  ///
  /// In fr, this message translates to:
  /// **'URGENCE – MAINTENEZ APPUYÉ'**
  String get sosHoldBanner;

  /// No description provided for @sosDangerQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes\nen danger ?'**
  String get sosDangerQuestion;

  /// No description provided for @sosThreeSecondsBadge.
  ///
  /// In fr, this message translates to:
  /// **'3 SECONDES'**
  String get sosThreeSecondsBadge;

  /// No description provided for @sosPressToAlert.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour alerter'**
  String get sosPressToAlert;

  /// No description provided for @sosCancelAlert.
  ///
  /// In fr, this message translates to:
  /// **'ANNULER L’ALERTE'**
  String get sosCancelAlert;

  /// No description provided for @callServiceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Appeler {service}'**
  String callServiceTitle(Object service);

  /// No description provided for @callServicePrompt.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous appeler le {service} au {number} ?'**
  String callServicePrompt(Object service, Object number);

  /// No description provided for @sosUnknownPosition.
  ///
  /// In fr, this message translates to:
  /// **'Position inconnue'**
  String get sosUnknownPosition;

  /// No description provided for @sosCurrentPosition.
  ///
  /// In fr, this message translates to:
  /// **'Votre position actuelle'**
  String get sosCurrentPosition;

  /// No description provided for @sosAccuracy.
  ///
  /// In fr, this message translates to:
  /// **'Précision: {meters} mètres'**
  String sosAccuracy(Object meters);

  /// No description provided for @sosEmergencyServices.
  ///
  /// In fr, this message translates to:
  /// **'Services de secours'**
  String get sosEmergencyServices;

  /// No description provided for @sosHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get sosHistory;

  /// No description provided for @sosNoRecentAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte envoyée récemment'**
  String get sosNoRecentAlerts;

  /// No description provided for @sosNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro: {number}'**
  String sosNumber(Object number);

  /// No description provided for @unknownPosition.
  ///
  /// In fr, this message translates to:
  /// **'Position inconnue'**
  String get unknownPosition;

  /// No description provided for @incidentReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un incident'**
  String get incidentReportTitle;

  /// No description provided for @incidentTypeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Type d’incident'**
  String get incidentTypeTitle;

  /// No description provided for @incidentTypeLoss.
  ///
  /// In fr, this message translates to:
  /// **'Perte'**
  String get incidentTypeLoss;

  /// No description provided for @incidentTypeAccident.
  ///
  /// In fr, this message translates to:
  /// **'Accident'**
  String get incidentTypeAccident;

  /// No description provided for @incidentTypeSuspicious.
  ///
  /// In fr, this message translates to:
  /// **'Suspect'**
  String get incidentTypeSuspicious;

  /// No description provided for @incidentDescriptionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get incidentDescriptionTitle;

  /// No description provided for @incidentDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez l’incident en détail...'**
  String get incidentDescriptionHint;

  /// No description provided for @incidentPhotosTitle.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get incidentPhotosTitle;

  /// No description provided for @incidentAudioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get incidentAudioTitle;

  /// No description provided for @incidentLocationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lieu de l’incident'**
  String get incidentLocationTitle;

  /// No description provided for @incidentAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get incidentAdd;

  /// No description provided for @incidentRecordingInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement en cours...'**
  String get incidentRecordingInProgress;

  /// No description provided for @incidentAddVoiceMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un message vocal'**
  String get incidentAddVoiceMessage;

  /// No description provided for @incidentTapToRecord.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour enregistrer'**
  String get incidentTapToRecord;

  /// No description provided for @incidentAudioAdded.
  ///
  /// In fr, this message translates to:
  /// **'Audio ajouté'**
  String get incidentAudioAdded;

  /// No description provided for @incidentSendReport.
  ///
  /// In fr, this message translates to:
  /// **'ENVOYER LE SIGNALEMENT'**
  String get incidentSendReport;

  /// No description provided for @incidentSelectTypeError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un type d’incident'**
  String get incidentSelectTypeError;

  /// No description provided for @incidentDescribeError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez décrire l’incident'**
  String get incidentDescribeError;

  /// No description provided for @incidentSentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signalement envoyé'**
  String get incidentSentTitle;

  /// No description provided for @incidentSentBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre signalement a été envoyé aux autorités compétentes.\n\nVous recevrez une réponse dans les plus brefs délais.'**
  String get incidentSentBody;

  /// No description provided for @incidentAddPhotoError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’ajouter une photo'**
  String get incidentAddPhotoError;

  /// No description provided for @incidentStopRecordingError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’arrêter l’enregistrement'**
  String get incidentStopRecordingError;

  /// No description provided for @incidentMicPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission micro refusée'**
  String get incidentMicPermissionDenied;

  /// No description provided for @incidentStartRecordingError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de démarrer l’enregistrement'**
  String get incidentStartRecordingError;

  /// No description provided for @incidentGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get incidentGallery;

  /// No description provided for @incidentCamera.
  ///
  /// In fr, this message translates to:
  /// **'Caméra'**
  String get incidentCamera;

  /// No description provided for @medicalAlertTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alerte Médicale'**
  String get medicalAlertTitle;

  /// No description provided for @homeFeatureAudioAnnouncements.
  ///
  /// In fr, this message translates to:
  /// **'Annonces Audio'**
  String get homeFeatureAudioAnnouncements;

  /// No description provided for @homeFeatureTouristInfo.
  ///
  /// In fr, this message translates to:
  /// **'Infos Touriste'**
  String get homeFeatureTouristInfo;

  /// No description provided for @homeFeatureCompetitionSites.
  ///
  /// In fr, this message translates to:
  /// **'Sites Compétitions'**
  String get homeFeatureCompetitionSites;

  /// No description provided for @homeFeatureCompetitions.
  ///
  /// In fr, this message translates to:
  /// **'Compétitions'**
  String get homeFeatureCompetitions;

  /// No description provided for @homeFeatureTransport.
  ///
  /// In fr, this message translates to:
  /// **'Navettes & Transports'**
  String get homeFeatureTransport;

  /// No description provided for @homeFeatureReportIncident.
  ///
  /// In fr, this message translates to:
  /// **'Signaler Incident'**
  String get homeFeatureReportIncident;

  /// No description provided for @homeOfficialAnnouncementDefaultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annonce officielle'**
  String get homeOfficialAnnouncementDefaultTitle;

  /// No description provided for @homeJojInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'INFOS JOJ: Sites Compétitions'**
  String get homeJojInfoTitle;

  /// No description provided for @homeCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get homeCalendar;

  /// No description provided for @homeNoActiveSites.
  ///
  /// In fr, this message translates to:
  /// **'Aucun site actif'**
  String get homeNoActiveSites;

  /// No description provided for @homeAddLatLngHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute latitude/longitude dans le dashboard'**
  String get homeAddLatLngHint;

  /// No description provided for @homeSiteFallback.
  ///
  /// In fr, this message translates to:
  /// **'Site'**
  String get homeSiteFallback;

  /// No description provided for @homeNavHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get homeNavHome;

  /// No description provided for @homeNavMedicalAlert.
  ///
  /// In fr, this message translates to:
  /// **'Alerte Médicale'**
  String get homeNavMedicalAlert;

  /// No description provided for @homeNavSos.
  ///
  /// In fr, this message translates to:
  /// **'SOS'**
  String get homeNavSos;

  /// No description provided for @homeNavReport.
  ///
  /// In fr, this message translates to:
  /// **'Signalement'**
  String get homeNavReport;

  /// No description provided for @homeNavProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get homeNavProfile;

  /// No description provided for @homeComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Cette fonctionnalité sera disponible prochainement.'**
  String get homeComingSoon;

  /// No description provided for @medicalSelectTypeError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un type d’urgence médicale'**
  String get medicalSelectTypeError;

  /// No description provided for @medicalSentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alerte médicale envoyée'**
  String get medicalSentTitle;

  /// No description provided for @medicalSentBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre alerte médicale a été envoyée aux services médicaux.\n\nUne ambulance est en route.'**
  String get medicalSentBody;

  /// No description provided for @medicalSending.
  ///
  /// In fr, this message translates to:
  /// **'Envoi de l’alerte...'**
  String get medicalSending;

  /// No description provided for @medicalTapToAlert.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour alerter les services médicaux'**
  String get medicalTapToAlert;

  /// No description provided for @medicalEmergencyTypeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Type d’urgence médicale'**
  String get medicalEmergencyTypeTitle;

  /// No description provided for @medicalTypeAccident.
  ///
  /// In fr, this message translates to:
  /// **'Accident'**
  String get medicalTypeAccident;

  /// No description provided for @medicalTypeFainting.
  ///
  /// In fr, this message translates to:
  /// **'Malaise'**
  String get medicalTypeFainting;

  /// No description provided for @medicalTypeInjury.
  ///
  /// In fr, this message translates to:
  /// **'Blessure'**
  String get medicalTypeInjury;

  /// No description provided for @medicalTypeOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get medicalTypeOther;

  /// No description provided for @medicalYourPosition.
  ///
  /// In fr, this message translates to:
  /// **'Votre position'**
  String get medicalYourPosition;

  /// No description provided for @medicalNearbyHospitals.
  ///
  /// In fr, this message translates to:
  /// **'Hôpitaux à proximité'**
  String get medicalNearbyHospitals;

  /// No description provided for @medicalNoNearbyHospitals.
  ///
  /// In fr, this message translates to:
  /// **'Aucun hôpital trouvé à proximité'**
  String get medicalNoNearbyHospitals;

  /// No description provided for @medicalEmergencyNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'Urgence {number}'**
  String medicalEmergencyNumberLabel(Object number);

  /// No description provided for @transportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Transport & Navettes'**
  String get transportTitle;

  /// No description provided for @transportNoShuttles.
  ///
  /// In fr, this message translates to:
  /// **'Aucune navette disponible'**
  String get transportNoShuttles;

  /// No description provided for @transportSecure.
  ///
  /// In fr, this message translates to:
  /// **'Sécurisé'**
  String get transportSecure;

  /// No description provided for @transportTerminusPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Terminus: {terminus}'**
  String transportTerminusPrefix(Object terminus);

  /// No description provided for @transportNextDeparturePrefix.
  ///
  /// In fr, this message translates to:
  /// **'Prochain départ:'**
  String get transportNextDeparturePrefix;

  /// No description provided for @transportNextDeparture.
  ///
  /// In fr, this message translates to:
  /// **'Prochain départ'**
  String get transportNextDeparture;

  /// No description provided for @transportItinerarySection.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get transportItinerarySection;

  /// No description provided for @transportRouteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Trajet'**
  String get transportRouteLabel;

  /// No description provided for @transportDepartureLabel.
  ///
  /// In fr, this message translates to:
  /// **'Départ'**
  String get transportDepartureLabel;

  /// No description provided for @transportTerminusLabel.
  ///
  /// In fr, this message translates to:
  /// **'Terminus'**
  String get transportTerminusLabel;

  /// No description provided for @transportStartPointLabel.
  ///
  /// In fr, this message translates to:
  /// **'Point de départ'**
  String get transportStartPointLabel;

  /// No description provided for @transportScheduleSection.
  ///
  /// In fr, this message translates to:
  /// **'Horaires'**
  String get transportScheduleSection;

  /// No description provided for @transportScheduleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Horaire'**
  String get transportScheduleLabel;

  /// No description provided for @transportDaysLabel.
  ///
  /// In fr, this message translates to:
  /// **'Jours'**
  String get transportDaysLabel;

  /// No description provided for @transportPeriodLabel.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get transportPeriodLabel;

  /// No description provided for @transportFrequencyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fréquence'**
  String get transportFrequencyLabel;

  /// No description provided for @transportStopsSection.
  ///
  /// In fr, this message translates to:
  /// **'Arrêts'**
  String get transportStopsSection;

  /// No description provided for @transportDescriptionSection.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get transportDescriptionSection;

  /// No description provided for @timeJustNow.
  ///
  /// In fr, this message translates to:
  /// **'À l’instant'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {count} min'**
  String timeMinutesAgo(Object count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {count} h'**
  String timeHoursAgo(Object count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {count} jours'**
  String timeDaysAgo(Object count);

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get profileTitle;

  /// No description provided for @profileUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Profil indisponible'**
  String get profileUnavailable;

  /// No description provided for @profilePersonalInfoSection.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get profilePersonalInfoSection;

  /// No description provided for @profileNotificationsSetting.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get profileNotificationsSetting;

  /// No description provided for @profileGeolocationSetting.
  ///
  /// In fr, this message translates to:
  /// **'Géolocalisation'**
  String get profileGeolocationSetting;

  /// No description provided for @profilePrivacySetting.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get profilePrivacySetting;

  /// No description provided for @profileOverviewSection.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get profileOverviewSection;

  /// No description provided for @profileAlertsStat.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get profileAlertsStat;

  /// No description provided for @profileReportsStat.
  ///
  /// In fr, this message translates to:
  /// **'Signalements'**
  String get profileReportsStat;

  /// No description provided for @profileRecentActivitiesSection.
  ///
  /// In fr, this message translates to:
  /// **'Activités Récentes'**
  String get profileRecentActivitiesSection;

  /// No description provided for @profileNoRecentActivity.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité récente'**
  String get profileNoRecentActivity;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get profileLogout;

  /// No description provided for @profileDefaultSosTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alerte SOS'**
  String get profileDefaultSosTitle;

  /// No description provided for @profileDefaultReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signalement'**
  String get profileDefaultReportTitle;

  /// No description provided for @privacyPersonalDataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Données personnelles'**
  String get privacyPersonalDataTitle;

  /// No description provided for @privacyPersonalDataBody.
  ///
  /// In fr, this message translates to:
  /// **'Teranga Pass utilise vos informations pour améliorer votre expérience (ex: profil, notifications, sécurité). Vous pouvez gérer certaines autorisations depuis votre téléphone.'**
  String get privacyPersonalDataBody;

  /// No description provided for @privacyLocationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser pour afficher les points proches.'**
  String get privacyLocationSubtitle;

  /// No description provided for @privacyNotificationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir des alertes et informations utiles.'**
  String get privacyNotificationsSubtitle;

  /// No description provided for @audioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annonces Audio'**
  String get audioTitle;

  /// No description provided for @audioNoAudioAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun audio disponible pour cette annonce'**
  String get audioNoAudioAvailable;

  /// No description provided for @audioCannotPlay.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire l’audio'**
  String get audioCannotPlay;

  /// No description provided for @audioNoAnnouncements.
  ///
  /// In fr, this message translates to:
  /// **'Aucune annonce disponible'**
  String get audioNoAnnouncements;

  /// No description provided for @audioAllLanguages.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get audioAllLanguages;

  /// No description provided for @tourismTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tourisme & Services'**
  String get tourismTitle;

  /// No description provided for @tourismCategoryAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get tourismCategoryAll;

  /// No description provided for @tourismCategoryHotels.
  ///
  /// In fr, this message translates to:
  /// **'Hôtels'**
  String get tourismCategoryHotels;

  /// No description provided for @tourismCategoryRestaurants.
  ///
  /// In fr, this message translates to:
  /// **'Restaurants'**
  String get tourismCategoryRestaurants;

  /// No description provided for @tourismCategoryPharmacies.
  ///
  /// In fr, this message translates to:
  /// **'Pharmacies'**
  String get tourismCategoryPharmacies;

  /// No description provided for @tourismCategoryHospitals.
  ///
  /// In fr, this message translates to:
  /// **'Hôpitaux'**
  String get tourismCategoryHospitals;

  /// No description provided for @tourismCategoryEmbassies.
  ///
  /// In fr, this message translates to:
  /// **'Ambassades'**
  String get tourismCategoryEmbassies;

  /// No description provided for @tourismTabWithCount.
  ///
  /// In fr, this message translates to:
  /// **'{label} ({count})'**
  String tourismTabWithCount(Object label, Object count);

  /// No description provided for @tourismCoordinatesMissing.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées manquantes'**
  String get tourismCoordinatesMissing;

  /// No description provided for @tourismEnableLocation.
  ///
  /// In fr, this message translates to:
  /// **'Activer la localisation'**
  String get tourismEnableLocation;

  /// No description provided for @tourismDistanceUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Distance indisponible'**
  String get tourismDistanceUnavailable;

  /// No description provided for @tourismSettingsButton.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get tourismSettingsButton;

  /// No description provided for @tourismEnableGpsButton.
  ///
  /// In fr, this message translates to:
  /// **'Activer GPS'**
  String get tourismEnableGpsButton;

  /// No description provided for @tourismNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get tourismNoResults;

  /// No description provided for @mapTitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte Interactive'**
  String get mapTitle;

  /// No description provided for @mapPlaceholderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte interactive'**
  String get mapPlaceholderTitle;

  /// No description provided for @mapPlaceholderSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Intégration Google Maps à venir'**
  String get mapPlaceholderSubtitle;

  /// No description provided for @mapOpenInGoogleMaps.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir dans Google Maps'**
  String get mapOpenInGoogleMaps;

  /// No description provided for @mapNearbyPointsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Points d’intérêt à proximité'**
  String get mapNearbyPointsTitle;

  /// No description provided for @mapNoPoints.
  ///
  /// In fr, this message translates to:
  /// **'Aucun point disponible'**
  String get mapNoPoints;

  /// No description provided for @mapDefaultPointName.
  ///
  /// In fr, this message translates to:
  /// **'Point d’intérêt'**
  String get mapDefaultPointName;

  /// No description provided for @mapPositionUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Position mise à jour'**
  String get mapPositionUpdated;

  /// No description provided for @mapCannotGetPosition.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’obtenir la position'**
  String get mapCannotGetPosition;

  /// No description provided for @mapOpenGoogleMapsError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’ouvrir Google Maps'**
  String get mapOpenGoogleMapsError;

  /// No description provided for @mapFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get mapFilterAll;

  /// No description provided for @mapFilterHelp.
  ///
  /// In fr, this message translates to:
  /// **'Secours'**
  String get mapFilterHelp;

  /// No description provided for @mapFilterSites.
  ///
  /// In fr, this message translates to:
  /// **'Sites JOJ'**
  String get mapFilterSites;

  /// No description provided for @mapFilterHotels.
  ///
  /// In fr, this message translates to:
  /// **'Hôtels'**
  String get mapFilterHotels;

  /// No description provided for @mapFilterRestaurants.
  ///
  /// In fr, this message translates to:
  /// **'Restaurants'**
  String get mapFilterRestaurants;

  /// No description provided for @mapFilterPharmacies.
  ///
  /// In fr, this message translates to:
  /// **'Pharmacies'**
  String get mapFilterPharmacies;

  /// No description provided for @mapFilterHospitals.
  ///
  /// In fr, this message translates to:
  /// **'Hôpitaux'**
  String get mapFilterHospitals;

  /// No description provided for @notificationsFallbackTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notification'**
  String get notificationsFallbackTitle;

  /// No description provided for @jojTitle.
  ///
  /// In fr, this message translates to:
  /// **'Infos JOJ'**
  String get jojTitle;

  /// No description provided for @jojTabCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get jojTabCalendar;

  /// No description provided for @jojTabSportsWithCount.
  ///
  /// In fr, this message translates to:
  /// **'Sports ({count})'**
  String jojTabSportsWithCount(Object count);

  /// No description provided for @jojTabAccess.
  ///
  /// In fr, this message translates to:
  /// **'Accès'**
  String get jojTabAccess;

  /// No description provided for @jojCalendarComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier à venir'**
  String get jojCalendarComingSoon;

  /// No description provided for @jojDefaultEventTitle.
  ///
  /// In fr, this message translates to:
  /// **'Événement'**
  String get jojDefaultEventTitle;

  /// No description provided for @jojNoSportsAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun sport disponible'**
  String get jojNoSportsAvailable;

  /// No description provided for @jojDefaultLocation.
  ///
  /// In fr, this message translates to:
  /// **'Dakar'**
  String get jojDefaultLocation;

  /// No description provided for @jojDatesComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Dates à venir'**
  String get jojDatesComingSoon;

  /// No description provided for @jojSeeOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir sur la carte'**
  String get jojSeeOnMap;

  /// No description provided for @jojDestinationFallback.
  ///
  /// In fr, this message translates to:
  /// **'Destination'**
  String get jojDestinationFallback;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In fr, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @profileEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get profileEditTitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get profileNameLabel;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get profilePhoneLabel;

  /// No description provided for @profileLanguageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguageLabel;

  /// No description provided for @profileUserTypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Type d’utilisateur'**
  String get profileUserTypeLabel;

  /// No description provided for @profileUserTypeVisitor.
  ///
  /// In fr, this message translates to:
  /// **'Visiteur'**
  String get profileUserTypeVisitor;

  /// No description provided for @profileUserTypeCitizen.
  ///
  /// In fr, this message translates to:
  /// **'Citoyen'**
  String get profileUserTypeCitizen;

  /// No description provided for @profileUserTypeAthlete.
  ///
  /// In fr, this message translates to:
  /// **'Athlète'**
  String get profileUserTypeAthlete;

  /// No description provided for @profileNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est requis'**
  String get profileNameRequired;

  /// No description provided for @profileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour'**
  String get profileUpdated;

  /// No description provided for @profileSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get profileSave;

  /// No description provided for @sosServicePolice.
  ///
  /// In fr, this message translates to:
  /// **'Police'**
  String get sosServicePolice;

  /// No description provided for @sosServiceFirefighters.
  ///
  /// In fr, this message translates to:
  /// **'Pompiers'**
  String get sosServiceFirefighters;

  /// No description provided for @sosServiceAmbulance.
  ///
  /// In fr, this message translates to:
  /// **'SAMU'**
  String get sosServiceAmbulance;

  /// No description provided for @sosFallbackAddress.
  ///
  /// In fr, this message translates to:
  /// **'Dakar Plateau, 9 Rue Carnot'**
  String get sosFallbackAddress;

  /// No description provided for @homeAppNamePart1.
  ///
  /// In fr, this message translates to:
  /// **'Teranga '**
  String get homeAppNamePart1;

  /// No description provided for @homeAppNamePart2.
  ///
  /// In fr, this message translates to:
  /// **'Pass'**
  String get homeAppNamePart2;

  /// No description provided for @homeTagline.
  ///
  /// In fr, this message translates to:
  /// **'Votre sécurité à Dakar, découvertes au Sénégal'**
  String get homeTagline;

  /// No description provided for @homePillarDiscoverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir'**
  String get homePillarDiscoverTitle;

  /// No description provided for @homePillarDiscoverSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sites · Restos · Hôtels'**
  String get homePillarDiscoverSubtitle;

  /// No description provided for @homePillarMoveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déplacer'**
  String get homePillarMoveTitle;

  /// No description provided for @homePillarMoveSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte · Navettes · Taxis'**
  String get homePillarMoveSubtitle;

  /// No description provided for @homePillarJojTitle.
  ///
  /// In fr, this message translates to:
  /// **'JOJ 2026'**
  String get homePillarJojTitle;

  /// No description provided for @homePillarJojSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier · Médailles'**
  String get homePillarJojSubtitle;

  /// No description provided for @homePillarHelpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Être aidé'**
  String get homePillarHelpTitle;

  /// No description provided for @homePillarHelpSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'SOS · Médical · Ambassade'**
  String get homePillarHelpSubtitle;

  /// No description provided for @homeHelpSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Être aidé'**
  String get homeHelpSheetTitle;

  /// No description provided for @homeHelpSheetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une action rapide'**
  String get homeHelpSheetSubtitle;

  /// No description provided for @homeHeroWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue au Sénégal,'**
  String get homeHeroWelcome;

  /// No description provided for @nearbyChipHotels.
  ///
  /// In fr, this message translates to:
  /// **'Hôtels'**
  String get nearbyChipHotels;

  /// No description provided for @nearbyChipHospitals.
  ///
  /// In fr, this message translates to:
  /// **'Hôpitaux'**
  String get nearbyChipHospitals;

  /// No description provided for @nearbyChipClinics.
  ///
  /// In fr, this message translates to:
  /// **'Cliniques'**
  String get nearbyChipClinics;

  /// No description provided for @nearbyChipNotaries.
  ///
  /// In fr, this message translates to:
  /// **'Notaires'**
  String get nearbyChipNotaries;

  /// No description provided for @nearbyChipLawyers.
  ///
  /// In fr, this message translates to:
  /// **'Avocats'**
  String get nearbyChipLawyers;

  /// No description provided for @nearbyChipDoctors.
  ///
  /// In fr, this message translates to:
  /// **'Médecins'**
  String get nearbyChipDoctors;

  /// No description provided for @nearbyChipGovernment.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get nearbyChipGovernment;

  /// No description provided for @nearbyChipSchools.
  ///
  /// In fr, this message translates to:
  /// **'Écoles'**
  String get nearbyChipSchools;

  /// No description provided for @nearbyChipUniversities.
  ///
  /// In fr, this message translates to:
  /// **'Universités'**
  String get nearbyChipUniversities;

  /// No description provided for @nearbyChipMedia.
  ///
  /// In fr, this message translates to:
  /// **'Médias'**
  String get nearbyChipMedia;

  /// No description provided for @nearbyAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get nearbyAll;

  /// No description provided for @nearbyTitle.
  ///
  /// In fr, this message translates to:
  /// **'À deux pas'**
  String get nearbyTitle;

  /// No description provided for @nearbyNearMeTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Près de moi'**
  String get nearbyNearMeTooltip;

  /// No description provided for @nearbyRadiusLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rayon : {meters} m'**
  String nearbyRadiusLabel(int meters);

  /// No description provided for @nearbyEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lieu dans ce rayon pour cette catégorie.'**
  String get nearbyEmpty;

  /// No description provided for @nearbyLocationError.
  ///
  /// In fr, this message translates to:
  /// **'Activez la localisation pour voir les lieux à proximité.'**
  String get nearbyLocationError;

  /// No description provided for @nearbySponsorBadge.
  ///
  /// In fr, this message translates to:
  /// **'Partenaire'**
  String get nearbySponsorBadge;

  /// No description provided for @profileEsimTitle.
  ///
  /// In fr, this message translates to:
  /// **'Forfaits eSIM'**
  String get profileEsimTitle;

  /// No description provided for @profileEsimSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Data voyage (bientôt)'**
  String get profileEsimSubtitle;

  /// No description provided for @esimComingTitle.
  ///
  /// In fr, this message translates to:
  /// **'eSIM Teranga Pass'**
  String get esimComingTitle;

  /// No description provided for @esimComingBody.
  ///
  /// In fr, this message translates to:
  /// **'L’intégration partenaire (ex. Airalo), les paiements (PayDunya, Wave) et l’activation par QR arriveront dans une prochaine version. Cet écran sert de repère pour la démo et la recette produit.'**
  String get esimComingBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
