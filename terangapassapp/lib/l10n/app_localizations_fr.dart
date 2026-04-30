// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Teranga Pass';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get filter => 'Filtrer';

  @override
  String get allZones => 'Toutes les zones';

  @override
  String get zoneLabel => 'Zone';

  @override
  String get retry => 'Réessayer';

  @override
  String get close => 'Fermer';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get pullToRefresh => 'Tirez pour actualiser';

  @override
  String get openMapError => 'Impossible d’ouvrir la carte';

  @override
  String get settings => 'Paramètres';

  @override
  String get appLanguage => 'Langue de l’application';

  @override
  String get loginTagline => 'Votre sécurité à Dakar';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'votre@email.com';

  @override
  String get loginEmailRequired => 'Veuillez entrer votre email';

  @override
  String get loginEmailInvalid => 'Email invalide';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginPasswordRequired => 'Veuillez entrer votre mot de passe';

  @override
  String get loginPasswordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get loginSignIn => 'Se connecter';

  @override
  String get loginNoAccount => 'Pas de compte ? S’inscrire';

  @override
  String get loginUnknownError => 'Une erreur est survenue';

  @override
  String get loginConnectionError =>
      'Erreur de connexion. Vérifiez votre connexion internet et réessayez.';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerSubtitle => 'Rejoignez Teranga Pass';

  @override
  String get registerFullNameLabel => 'Nom complet';

  @override
  String get registerFullNameHint => 'Votre nom';

  @override
  String get registerFullNameRequired => 'Veuillez entrer votre nom';

  @override
  String get registerPasswordRequired => 'Veuillez entrer un mot de passe';

  @override
  String get registerConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get registerConfirmPasswordRequired =>
      'Veuillez confirmer votre mot de passe';

  @override
  String get registerPasswordsNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get registerSignUp => 'S’inscrire';

  @override
  String get registerHaveAccount => 'Déjà un compte ? Se connecter';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get call => 'Appeler';

  @override
  String get openPhoneError => 'Impossible d’ouvrir le téléphone';

  @override
  String get sosEmergencyTitle => 'SOS Urgence';

  @override
  String get sosCancelled => 'Alerte SOS annulée';

  @override
  String get sosSentTitle => 'Alerte SOS envoyée';

  @override
  String get sosSentBody =>
      'Votre alerte SOS a été envoyée aux services de secours.\n\nIls arriveront dans les plus brefs délais.';

  @override
  String get sosCountdown => 'Alerte dans...';

  @override
  String get sosAlertSent => 'ALERTE ENVOYÉE !';

  @override
  String get sosUrgenceLabel => 'SOS URGENCE';

  @override
  String get sosPressToAlert => 'Appuyez pour alerter';

  @override
  String get sosCancelAlert => 'ANNULER L’ALERTE';

  @override
  String callServiceTitle(Object service) {
    return 'Appeler $service';
  }

  @override
  String callServicePrompt(Object service, Object number) {
    return 'Voulez-vous appeler le $service au $number ?';
  }

  @override
  String get sosUnknownPosition => 'Position inconnue';

  @override
  String get sosCurrentPosition => 'Votre position actuelle';

  @override
  String sosAccuracy(Object meters) {
    return 'Précision: $meters mètres';
  }

  @override
  String get sosEmergencyServices => 'Services de secours';

  @override
  String get sosHistory => 'Historique';

  @override
  String get sosNoRecentAlerts => 'Aucune alerte envoyée récemment';

  @override
  String sosNumber(Object number) {
    return 'Numéro: $number';
  }

  @override
  String get unknownPosition => 'Position inconnue';

  @override
  String get incidentReportTitle => 'Signaler un incident';

  @override
  String get incidentTypeTitle => 'Type d’incident';

  @override
  String get incidentTypeLoss => 'Perte';

  @override
  String get incidentTypeAccident => 'Accident';

  @override
  String get incidentTypeSuspicious => 'Suspect';

  @override
  String get incidentDescriptionTitle => 'Description';

  @override
  String get incidentDescriptionHint => 'Décrivez l’incident en détail...';

  @override
  String get incidentPhotosTitle => 'Photos';

  @override
  String get incidentAudioTitle => 'Audio';

  @override
  String get incidentLocationTitle => 'Lieu de l’incident';

  @override
  String get incidentAdd => 'Ajouter';

  @override
  String get incidentRecordingInProgress => 'Enregistrement en cours...';

  @override
  String get incidentAddVoiceMessage => 'Ajouter un message vocal';

  @override
  String get incidentTapToRecord => 'Appuyez pour enregistrer';

  @override
  String get incidentAudioAdded => 'Audio ajouté';

  @override
  String get incidentSendReport => 'ENVOYER LE SIGNALEMENT';

  @override
  String get incidentSelectTypeError =>
      'Veuillez sélectionner un type d’incident';

  @override
  String get incidentDescribeError => 'Veuillez décrire l’incident';

  @override
  String get incidentSentTitle => 'Signalement envoyé';

  @override
  String get incidentSentBody =>
      'Votre signalement a été envoyé aux autorités compétentes.\n\nVous recevrez une réponse dans les plus brefs délais.';

  @override
  String get incidentAddPhotoError => 'Impossible d’ajouter une photo';

  @override
  String get incidentStopRecordingError =>
      'Impossible d’arrêter l’enregistrement';

  @override
  String get incidentMicPermissionDenied => 'Permission micro refusée';

  @override
  String get incidentStartRecordingError =>
      'Impossible de démarrer l’enregistrement';

  @override
  String get incidentGallery => 'Galerie';

  @override
  String get incidentCamera => 'Caméra';

  @override
  String get medicalAlertTitle => 'Alerte Médicale';

  @override
  String get homeFeatureAudioAnnouncements => 'Annonces Audio';

  @override
  String get homeFeatureTouristInfo => 'Infos Touriste';

  @override
  String get homeFeatureCompetitionSites => 'Sites Compétitions';

  @override
  String get homeFeatureCompetitions => 'Compétitions';

  @override
  String get homeFeatureTransport => 'Navettes & Transports';

  @override
  String get homeFeatureReportIncident => 'Signaler Incident';

  @override
  String get homeOfficialAnnouncementDefaultTitle => 'Annonce officielle';

  @override
  String get homeJojInfoTitle => 'INFOS JOJ: Sites Compétitions';

  @override
  String get homeCalendar => 'Calendrier';

  @override
  String get homeNoActiveSites => 'Aucun site actif';

  @override
  String get homeAddLatLngHint => 'Ajoute latitude/longitude dans le dashboard';

  @override
  String get homeSiteFallback => 'Site';

  @override
  String get homeNavHome => 'Accueil';

  @override
  String get homeNavMedicalAlert => 'Alerte Médicale';

  @override
  String get homeNavSos => 'SOS';

  @override
  String get homeNavReport => 'Signalement';

  @override
  String get homeNavProfile => 'Profil';

  @override
  String get homeComingSoon =>
      'Cette fonctionnalité sera disponible prochainement.';

  @override
  String get medicalSelectTypeError =>
      'Veuillez sélectionner un type d’urgence médicale';

  @override
  String get medicalSentTitle => 'Alerte médicale envoyée';

  @override
  String get medicalSentBody =>
      'Votre alerte médicale a été envoyée aux services médicaux.\n\nUne ambulance est en route.';

  @override
  String get medicalSending => 'Envoi de l’alerte...';

  @override
  String get medicalTapToAlert => 'Appuyez pour alerter les services médicaux';

  @override
  String get medicalEmergencyTypeTitle => 'Type d’urgence médicale';

  @override
  String get medicalTypeAccident => 'Accident';

  @override
  String get medicalTypeFainting => 'Malaise';

  @override
  String get medicalTypeInjury => 'Blessure';

  @override
  String get medicalTypeOther => 'Autre';

  @override
  String get medicalYourPosition => 'Votre position';

  @override
  String get medicalNearbyHospitals => 'Hôpitaux à proximité';

  @override
  String get medicalNoNearbyHospitals => 'Aucun hôpital trouvé à proximité';

  @override
  String medicalEmergencyNumberLabel(Object number) {
    return 'Urgence $number';
  }

  @override
  String get transportTitle => 'Transport & Navettes';

  @override
  String get transportNoShuttles => 'Aucune navette disponible';

  @override
  String get transportSecure => 'Sécurisé';

  @override
  String transportTerminusPrefix(Object terminus) {
    return 'Terminus: $terminus';
  }

  @override
  String get transportNextDeparturePrefix => 'Prochain départ:';

  @override
  String get transportNextDeparture => 'Prochain départ';

  @override
  String get transportItinerarySection => 'Itinéraire';

  @override
  String get transportRouteLabel => 'Trajet';

  @override
  String get transportDepartureLabel => 'Départ';

  @override
  String get transportTerminusLabel => 'Terminus';

  @override
  String get transportStartPointLabel => 'Point de départ';

  @override
  String get transportScheduleSection => 'Horaires';

  @override
  String get transportScheduleLabel => 'Horaire';

  @override
  String get transportDaysLabel => 'Jours';

  @override
  String get transportPeriodLabel => 'Période';

  @override
  String get transportFrequencyLabel => 'Fréquence';

  @override
  String get transportStopsSection => 'Arrêts';

  @override
  String get transportDescriptionSection => 'Description';

  @override
  String get timeJustNow => 'À l’instant';

  @override
  String timeMinutesAgo(Object count) {
    return 'Il y a $count min';
  }

  @override
  String timeHoursAgo(Object count) {
    return 'Il y a $count h';
  }

  @override
  String timeDaysAgo(Object count) {
    return 'Il y a $count jours';
  }

  @override
  String get profileTitle => 'Mon Profil';

  @override
  String get profileUnavailable => 'Profil indisponible';

  @override
  String get profilePersonalInfoSection => 'Informations personnelles';

  @override
  String get profileNotificationsSetting => 'Notifications';

  @override
  String get profileGeolocationSetting => 'Géolocalisation';

  @override
  String get profilePrivacySetting => 'Confidentialité';

  @override
  String get profileOverviewSection => 'Aperçu';

  @override
  String get profileAlertsStat => 'Alertes';

  @override
  String get profileReportsStat => 'Signalements';

  @override
  String get profileRecentActivitiesSection => 'Activités Récentes';

  @override
  String get profileNoRecentActivity => 'Aucune activité récente';

  @override
  String get profileLogout => 'Déconnexion';

  @override
  String get profileDefaultSosTitle => 'Alerte SOS';

  @override
  String get profileDefaultReportTitle => 'Signalement';

  @override
  String get privacyPersonalDataTitle => 'Données personnelles';

  @override
  String get privacyPersonalDataBody =>
      'Teranga Pass utilise vos informations pour améliorer votre expérience (ex: profil, notifications, sécurité). Vous pouvez gérer certaines autorisations depuis votre téléphone.';

  @override
  String get privacyLocationSubtitle =>
      'Autoriser pour afficher les points proches.';

  @override
  String get privacyNotificationsSubtitle =>
      'Recevoir des alertes et informations utiles.';

  @override
  String get audioTitle => 'Annonces Audio';

  @override
  String get audioNoAudioAvailable =>
      'Aucun audio disponible pour cette annonce';

  @override
  String get audioCannotPlay => 'Impossible de lire l’audio';

  @override
  String get audioNoAnnouncements => 'Aucune annonce disponible';

  @override
  String get audioAllLanguages => 'Toutes';

  @override
  String get tourismTitle => 'Tourisme & Services';

  @override
  String get tourismCategoryAll => 'Tous';

  @override
  String get tourismCategoryHotels => 'Hôtels';

  @override
  String get tourismCategoryRestaurants => 'Restaurants';

  @override
  String get tourismCategoryPharmacies => 'Pharmacies';

  @override
  String get tourismCategoryHospitals => 'Hôpitaux';

  @override
  String get tourismCategoryEmbassies => 'Ambassades';

  @override
  String tourismTabWithCount(Object label, Object count) {
    return '$label ($count)';
  }

  @override
  String get tourismCoordinatesMissing => 'Coordonnées manquantes';

  @override
  String get tourismEnableLocation => 'Activer la localisation';

  @override
  String get tourismDistanceUnavailable => 'Distance indisponible';

  @override
  String get tourismSettingsButton => 'Paramètres';

  @override
  String get tourismEnableGpsButton => 'Activer GPS';

  @override
  String get tourismNoResults => 'Aucun résultat';

  @override
  String get mapTitle => 'Carte Interactive';

  @override
  String get mapPlaceholderTitle => 'Carte interactive';

  @override
  String get mapPlaceholderSubtitle => 'Intégration Google Maps à venir';

  @override
  String get mapOpenInGoogleMaps => 'Ouvrir dans Google Maps';

  @override
  String get mapNearbyPointsTitle => 'Points d’intérêt à proximité';

  @override
  String get mapNoPoints => 'Aucun point disponible';

  @override
  String get mapDefaultPointName => 'Point d’intérêt';

  @override
  String get mapPositionUpdated => 'Position mise à jour';

  @override
  String get mapCannotGetPosition => 'Impossible d’obtenir la position';

  @override
  String get mapOpenGoogleMapsError => 'Impossible d’ouvrir Google Maps';

  @override
  String get mapFilterAll => 'Tous';

  @override
  String get mapFilterHelp => 'Secours';

  @override
  String get mapFilterSites => 'Sites JOJ';

  @override
  String get mapFilterHotels => 'Hôtels';

  @override
  String get mapFilterRestaurants => 'Restaurants';

  @override
  String get mapFilterPharmacies => 'Pharmacies';

  @override
  String get mapFilterHospitals => 'Hôpitaux';

  @override
  String get notificationsFallbackTitle => 'Notification';

  @override
  String get jojTitle => 'Infos JOJ';

  @override
  String get jojTabCalendar => 'Calendrier';

  @override
  String jojTabSportsWithCount(Object count) {
    return 'Sports ($count)';
  }

  @override
  String get jojTabAccess => 'Accès';

  @override
  String get jojCalendarComingSoon => 'Calendrier à venir';

  @override
  String get jojDefaultEventTitle => 'Événement';

  @override
  String get jojNoSportsAvailable => 'Aucun sport disponible';

  @override
  String get jojDefaultLocation => 'Dakar';

  @override
  String get jojDatesComingSoon => 'Dates à venir';

  @override
  String get jojSeeOnMap => 'Voir sur la carte';

  @override
  String get jojDestinationFallback => 'Destination';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get profileEditTitle => 'Modifier le profil';

  @override
  String get profileNameLabel => 'Nom';

  @override
  String get profilePhoneLabel => 'Téléphone';

  @override
  String get profileLanguageLabel => 'Langue';

  @override
  String get profileUserTypeLabel => 'Type d’utilisateur';

  @override
  String get profileUserTypeVisitor => 'Visiteur';

  @override
  String get profileUserTypeCitizen => 'Citoyen';

  @override
  String get profileUserTypeAthlete => 'Athlète';

  @override
  String get profileNameRequired => 'Le nom est requis';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get profileSave => 'Enregistrer';

  @override
  String get sosServicePolice => 'Police';

  @override
  String get sosServiceFirefighters => 'Pompiers';

  @override
  String get sosServiceAmbulance => 'SAMU';

  @override
  String get sosFallbackAddress => 'Dakar Plateau, 9 Rue Carnot';

  @override
  String get homeAppNamePart1 => 'Teranga ';

  @override
  String get homeAppNamePart2 => 'Pass';

  @override
  String get homeTagline => 'Votre sécurité à Dakar, découvertes au Sénégal';
}
