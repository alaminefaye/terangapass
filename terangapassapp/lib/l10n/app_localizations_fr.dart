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
  String get clearAll => 'Tout vider';

  @override
  String get clearAllConfirmTitle => 'Vider toutes les notifications';

  @override
  String get clearAllConfirmBody =>
      'Toutes vos notifications personnelles seront supprimées. Cette action est irréversible.';

  @override
  String get markAsRead => 'Marquer comme lu';

  @override
  String get markAsUnread => 'Marquer comme non lu';

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteNotificationTitle => 'Supprimer la notification';

  @override
  String get deleteNotificationBody =>
      'Voulez-vous vraiment supprimer cette notification ?';

  @override
  String unreadCount(int count) {
    return '$count non lu(s)';
  }

  @override
  String get notifChipSosShort => 'SOS';

  @override
  String get notifChipMedicalShort => 'Urgence médicale';

  @override
  String get notifChipIncidentShort => 'Signalement';

  @override
  String get notifChipSosSent => 'SOS envoyé';

  @override
  String get notifChipMedicalSent => 'Alerte médicale';

  @override
  String get notifChipIncidentReceived => 'Signalement enregistré';

  @override
  String get notifChipStatusPending => 'En attente';

  @override
  String get notifChipStatusInProgress => 'En cours';

  @override
  String get notifChipStatusResolved => 'Résolu';

  @override
  String get notifChipStatusCancelled => 'Annulée';

  @override
  String get notifChipIncidentValidated => 'Validé';

  @override
  String get notifChipIncidentRejected => 'Refusé';

  @override
  String get notifChipFollowUp => 'Mise à jour';

  @override
  String get notifChipGeneral => 'Message';

  @override
  String get notifChipAudioAnnouncement => 'Annonce audio';

  @override
  String get pullToRefresh => 'Tirez pour actualiser';

  @override
  String get openMapError => 'Impossible d’ouvrir la carte';

  @override
  String get settings => 'Paramètres';

  @override
  String get appLanguage => 'Langue de l’application';

  @override
  String get loginValueProps =>
      'Découvrir · Voyager sereinement · Être protégé';

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
  String get loginIdentifierLabel => 'Email ou numéro';

  @override
  String get loginIdentifierHint => 'vous@email.com ou numéro de téléphone';

  @override
  String get loginIdentifierRequired =>
      'Veuillez entrer votre email ou votre numéro';

  @override
  String get loginPhoneInvalid => 'Numéro invalide (au moins 9 chiffres)';

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
  String get loginRememberMe => 'Se souvenir de moi';

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
  String get registerPhoneHint => 'Numéro de téléphone';

  @override
  String get registerPhoneNationalHint => 'Sans indicatif pays';

  @override
  String get registerPhoneRequired =>
      'Veuillez entrer votre numéro de téléphone';

  @override
  String get registerSelectCountry => 'Choisir un pays';

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
  String get sosHoldBanner => 'URGENCE – MAINTENEZ APPUYÉ';

  @override
  String get sosDangerQuestion => 'Vous êtes\nen danger ?';

  @override
  String get sosThreeSecondsBadge => '3 SECONDES';

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
  String get passQrTitle => 'Mon Pass Teranga';

  @override
  String get passQrEntry => 'Afficher mon Pass (QR)';

  @override
  String get passQrSubtitle =>
      'Présentez ce code aux contrôles d’accès (pilote JOJ).';

  @override
  String get passQrRetry => 'Réessayer';

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
  String get profileDeleteAccount => 'Supprimer mon compte';

  @override
  String get profileDeleteAccountTitle => 'Supprimer le compte';

  @override
  String get profileDeleteAccountBody =>
      'Cette action est irréversible. Vos alertes, signalements et données associées seront supprimés définitivement. Pour confirmer, saisissez exactement le code suivant dans le champ ci-dessous :';

  @override
  String get profileDeleteAccountCodeLabel => 'Code de confirmation';

  @override
  String get profileDeleteAccountCodeHint => 'teranga pass';

  @override
  String get profileDeleteAccountCodeFieldHint => 'Saisissez le code ici';

  @override
  String get profileDeleteAccountCodeError =>
      'Code incorrect. Saisissez exactement : teranga pass';

  @override
  String get profileDeleteAccountConfirm => 'Supprimer définitivement';

  @override
  String get profileDeleteAccountSuccess => 'Votre compte a été supprimé.';

  @override
  String get profileDeleteAccountFailed =>
      'Impossible de supprimer le compte pour le moment.';

  @override
  String get profileDefaultSosTitle => 'Alerte SOS';

  @override
  String get profileDefaultReportTitle => 'Signalement';

  @override
  String get historyUnifiedTitle => 'Historique SOS & signalements';

  @override
  String get historyUnifiedEmpty => 'Aucun SOS, alerte médicale ni signalement';

  @override
  String get historyKindSos => 'SOS';

  @override
  String get historyKindMedical => 'Alerte médicale';

  @override
  String get historyKindReport => 'Signalement';

  @override
  String get historyAlertDetailTitle => 'Détail de l’alerte';

  @override
  String get historyFieldAddress => 'Adresse';

  @override
  String get historyFieldDate => 'Date';

  @override
  String get historyFieldCoords => 'Coordonnées';

  @override
  String get alertTrackingNavTitle => 'Mon alerte';

  @override
  String get alertTimelineRecorded => 'Alerte enregistrée';

  @override
  String get alertTimelineDispatched => 'Transmise aux services de secours';

  @override
  String get alertTimelineClosed => 'Clôturée';

  @override
  String get alertTimelineRejected => 'Refusée';

  @override
  String get alertTimelineCancelled => 'Annulée';

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
  String get mapPlaceholderSubtitle => 'Rechercher un lieu, une adresse…';

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
  String get mapTilesLoadIssue =>
      'La carte peut être incomplète. Vérifiez votre connexion.';

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
  String get mapFilterBanks => 'Banques';

  @override
  String get mapFilterGasStations => 'Stations';

  @override
  String get mapFilterShops => 'Boutiques';

  @override
  String get mapFilterConsulates => 'Consulats';

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
  String get languagePortuguese => 'Português';

  @override
  String get languageArabic => 'العربية';

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

  @override
  String get homePillarDiscoverTitle => 'Découvrir';

  @override
  String get homePillarDiscoverSubtitle => 'Sites · Restos · Hôtels';

  @override
  String get homePillarMoveTitle => 'Se déplacer';

  @override
  String get homePillarMoveSubtitle => 'Carte · Navettes · Taxis';

  @override
  String get homePillarJojTitle => 'JOJ 2026';

  @override
  String get homePillarJojSubtitle => 'Calendrier · Médailles';

  @override
  String get homePillarHelpTitle => 'Être aidé';

  @override
  String get homePillarHelpSubtitle => 'SOS · Médical · Ambassade';

  @override
  String get homeHelpSheetTitle => 'Être aidé';

  @override
  String get homeHelpSheetSubtitle => 'Choisissez une action rapide';

  @override
  String get homeHeroWelcome => 'Bienvenue au Sénégal,';

  @override
  String get nearbyChipHotels => 'Hôtels';

  @override
  String get nearbyChipHospitals => 'Hôpitaux';

  @override
  String get nearbyChipClinics => 'Cliniques';

  @override
  String get nearbyChipNotaries => 'Notaires';

  @override
  String get nearbyChipLawyers => 'Avocats';

  @override
  String get nearbyChipDoctors => 'Médecins';

  @override
  String get nearbyChipGovernment => 'État';

  @override
  String get nearbyChipSchools => 'Écoles';

  @override
  String get nearbyChipUniversities => 'Universités';

  @override
  String get nearbyChipMedia => 'Médias';

  @override
  String get nearbyChipProfessionalServices => 'Pros';

  @override
  String get nearbyChipReligiousSites => 'Culte';

  @override
  String get nearbyAll => 'Tous';

  @override
  String get nearbyTitle => 'À deux pas';

  @override
  String get nearbyNearMeTooltip => 'Près de moi';

  @override
  String nearbyRadiusLabel(int meters) {
    return 'Rayon : $meters m';
  }

  @override
  String get nearbyEmpty => 'Aucun lieu dans ce rayon pour cette catégorie.';

  @override
  String get nearbyLocationError =>
      'La localisation n’est pas activée. Activez-la pour voir les lieux à proximité.';

  @override
  String get nearbySponsorBadge => 'Partenaire';

  @override
  String get profileThemeSetting => 'Apparence';

  @override
  String get profileThemeSettingHint =>
      'Choisissez le mode clair, sombre ou automatique.';

  @override
  String get profileThemeSystem => 'Automatique (système)';

  @override
  String get profileThemeLight => 'Mode clair';

  @override
  String get profileThemeDark => 'Mode sombre';

  @override
  String get profileEsimTitle => 'Forfaits eSIM';

  @override
  String get profileEsimSubtitle => 'Fonctionnalité à venir';

  @override
  String get esimComingBadge => 'Fonctionnalité à venir';

  @override
  String get esimComingTitle => 'Forfaits eSIM';

  @override
  String get esimComingBody =>
      'L’achat de forfaits internet pour vos voyages au Sénégal sera bientôt disponible directement dans Teranga Pass.\n\nMerci de votre patience.';

  @override
  String get mapLegendTitle => 'Légende';

  @override
  String get mapLegendYou => 'Vous';

  @override
  String get mapLegendPlace => 'Lieu';

  @override
  String get mapLegendSponsor => 'Partenaire mis en avant';

  @override
  String get mapLegendCategoriesHint =>
      'Les couleurs des repères sur la carte indiquent le type de lieu (filtres ci-dessus).';

  @override
  String get mapLegendJojSitesHint =>
      'Repères verts : sites de compétition JOJ sur la carte.';

  @override
  String get profileOfflinePackTitle => 'Pack hors ligne';

  @override
  String get profileOfflinePackBody =>
      'POI et contenus utiles sans réseau (déploiement progressif).';

  @override
  String profileOfflinePackCatalogVersion(String version) {
    return 'Catalogue serveur : $version';
  }

  @override
  String get profileOfflinePackCatalogPending => 'Catalogue : non synchronisé';

  @override
  String get profileOfflinePackDialogBody =>
      'Téléchargez POI, sites JOJ, ambassades, calendrier et annonces pour les consulter sans réseau. En cas de coupure, le téléchargement reprend : les fichiers déjà corrects sont ignorés.';

  @override
  String get profileOfflinePackDownload => 'Télécharger / mettre à jour';

  @override
  String profileOfflinePackProgressDetail(
    int current,
    int total,
    String bundleId,
  ) {
    return '$current / $total · $bundleId';
  }

  @override
  String get profileOfflinePackDownloadSuccess =>
      'Pack enregistré sur l’appareil.';

  @override
  String get profileOfflinePackDownloadPartial =>
      'Téléchargement incomplet. Réessayez avec le réseau.';

  @override
  String get profileOfflinePackAlreadyCurrent =>
      'Vous avez déjà la dernière version en local.';

  @override
  String get profileOfflinePackDownloadError =>
      'Impossible de récupérer le manifeste. Vérifiez le réseau.';

  @override
  String get offlineUsingCache => 'Affichage hors ligne : données en cache.';

  @override
  String offlinePackUpdated(String version) {
    return 'Pack $version enregistré sur l’appareil.';
  }

  @override
  String profileOfflinePackFilesVersion(String version) {
    return 'Fichiers locaux : $version';
  }

  @override
  String get profileOfflinePackStaleFiles =>
      'Des fichiers sont plus anciens que le catalogue : reconnectez-vous au réseau pour terminer la mise à jour.';

  @override
  String profileOfflinePackLocalSize(String size) {
    return 'Stockage local : $size';
  }

  @override
  String get incidentTrackingNavTitle => 'Mon signalement';

  @override
  String get incidentTypeLossLabel => 'Perte d\'objet ou effets personnels';

  @override
  String get incidentTypeSuspiciousLabel => 'Comportement suspect';

  @override
  String get incidentTypeOtherLabel => 'Autre signalement';

  @override
  String get incidentStatusInProgress => 'En cours de traitement';

  @override
  String get incidentStatusProcessed => 'Traité';

  @override
  String get incidentStatusValidated => 'Validé';

  @override
  String get incidentStatusRejected => 'Refusé';

  @override
  String get incidentStatusPending => 'En attente';

  @override
  String get incidentStatusCancelled => 'Annulé';

  @override
  String get incidentTrackingEmptyTimeline =>
      'Le suivi sera affiché dès que votre dossier sera traité.';

  @override
  String get loadingWait => 'Patientez un instant…';

  @override
  String get homeSearchHint => 'Restaurants, sites, hôtels, événements...';

  @override
  String get homeJojCountdownLabel => 'Jours avant les JOJ';

  @override
  String get homeJojOlympicSubtitle => 'JEUX OLYMPIQUES DE LA JEUNESSE';

  @override
  String get homeJojCityLine => 'Dakar 2026';

  @override
  String get homeJojDateRange => '31 octobre -> 13 novembre';

  @override
  String get homeEsimConnectSubtitle => 'Bientôt disponible';

  @override
  String get homeNearbySubtitle => 'Autour de moi';

  @override
  String get homeAudioListenSubtitle => 'Écouter';

  @override
  String get homeMyReportsTitle => 'Mes signalements';

  @override
  String get homeMyReportsSubtitle => 'Suivre';

  @override
  String get homeCurrencyTitle => 'Convertisseur';

  @override
  String get authRequiredTitle => 'Connexion requise';

  @override
  String authRequiredBody(Object featureName) {
    return 'Pour utiliser « $featureName », connectez-vous ou créez un compte.';
  }

  @override
  String authRequiredBodyGuestHint(Object featureName) {
    return 'Pour utiliser « $featureName », connectez-vous pour enregistrer vos actions.';
  }

  @override
  String get authRequiredExploreHint =>
      'Vous pouvez continuer à explorer le tourisme et les lieux recommandés sans compte.';

  @override
  String get authLater => 'Plus tard';

  @override
  String get authFeatureMedicalAlert => 'Alerte médicale';

  @override
  String get authFeatureAiAssistant => 'Assistant IA';

  @override
  String get authFeatureReport => 'Signalement';

  @override
  String get authFeatureMyReports => 'Mes signalements';

  @override
  String get authFeatureSos => 'SOS urgence';

  @override
  String get authFeatureMapAndRoute => 'la carte et l\'itinéraire';

  @override
  String get authFeatureRoute => 'l\'itinéraire';

  @override
  String get authFeatureLeaveReview => 'Laisser un avis';

  @override
  String get weatherUnavailable => 'Indisponible';

  @override
  String get weatherDefaultLabel => 'Météo';

  @override
  String get homeLogin => 'Connexion';

  @override
  String get recommendedSectionTitle => 'Nos recommandations';

  @override
  String get recommendedSectionSubtitle =>
      'Sélection Teranga Pass · hôtels, restos et lieux utiles';

  @override
  String get recommendedBadge => 'Recommandé';

  @override
  String get viewOnMap => 'Voir sur la carte';

  @override
  String get loadingPleaseWait => 'Patientez un instant…';

  @override
  String get promoCloseBarrier => 'Fermer la publicité';

  @override
  String get promoLearnMore => 'En savoir plus';

  @override
  String promoSponsoredLabel(Object sponsor) {
    return 'Publicité · $sponsor';
  }

  @override
  String get aiWelcomeMessage =>
      'Bonjour, je suis votre assistant IA TerangaPass. Posez votre question.';

  @override
  String get aiDisclaimer =>
      'Réponses basées sur les données TerangaPass (JOJ Dakar 2026).';

  @override
  String get aiSuggestionCompetitionSites => 'Sites de compétition';

  @override
  String get aiSuggestionCompetitionSitesQuery =>
      'Quels sont les sites de compétition JOJ ?';

  @override
  String get aiSuggestionShuttles => 'Navettes';

  @override
  String get aiSuggestionShuttlesQuery => 'Horaires des navettes';

  @override
  String get aiSuggestionTourism => 'Infos touristiques';

  @override
  String get aiSuggestionTourismQuery => 'Lieux touristiques à Dakar';

  @override
  String get aiSuggestionAnnouncements => 'Annonces';

  @override
  String get aiSuggestionAnnouncementsQuery => 'Dernières annonces audio';

  @override
  String get aiSuggestionEmergencies => 'Urgences';

  @override
  String get aiSuggestionEmergenciesQuery => 'Numéros d\'urgence au Sénégal';

  @override
  String get aiSuggestionCalendar => 'Calendrier';

  @override
  String get aiSuggestionCalendarQuery => 'Calendrier des compétitions JOJ';

  @override
  String get aiEmptyReply => 'Je n\'ai pas pu générer de réponse. Réessayez.';

  @override
  String aiErrorPrefix(Object error) {
    return 'Erreur IA : $error';
  }

  @override
  String get aiTitle => 'Assistant IA TerangaPass';

  @override
  String aiConnectedAs(Object name) {
    return 'Connecté(e) : $name';
  }

  @override
  String get aiAllowLocation => 'Autoriser la localisation';

  @override
  String get aiSuggestionsTitle => 'Suggestions';

  @override
  String get aiMessageHint => 'Écrire un message...';

  @override
  String get placeLeaveReviewTitle => 'Laisser un avis';

  @override
  String get placeReviewCommentHint => 'Votre commentaire (optionnel)…';

  @override
  String get placeReviewPublish => 'Publier';

  @override
  String get placeReviewPublished => 'Avis publié.';

  @override
  String get placeReviewSavedOffline =>
      'Avis sauvegardé sur cet appareil. Pour le partager à tous les utilisateurs, connectez-vous.';

  @override
  String get placeReviewsUnavailableDetail =>
      'Les avis ne sont pas disponibles pour ce lieu.';

  @override
  String get placeReviewsEmptyDetail =>
      'Aucun avis pour le moment.\nSoyez le premier à laisser un commentaire !';

  @override
  String get placePhotoGallery => 'Galerie photos';

  @override
  String get placeInfoDistance => 'Distance';

  @override
  String get placeInfoAddress => 'Adresse';

  @override
  String get placeInfoPhone => 'Téléphone';

  @override
  String get placeInfoHours => 'Horaires';

  @override
  String get placeInfoDuration => 'Durée estimée';

  @override
  String get placeInfoDirections => 'Comment s\'y rendre';

  @override
  String get placeWebsite => 'Site web';

  @override
  String get placeDescription => 'Description';

  @override
  String get placeReviewsSectionTitle => 'Avis & commentaires';

  @override
  String placeReviewCount(int count) {
    return '$count avis';
  }

  @override
  String get placeReviewsUnavailable =>
      'Les avis ne sont pas disponibles pour le moment.';

  @override
  String get placeReviewsEmpty =>
      'Aucun avis pour le moment. Soyez le premier !';

  @override
  String get reviewAuthorMe => 'Moi';

  @override
  String get reviewAuthorAnonymous => 'Anonyme';

  @override
  String get embassiesTitle => 'Ambassades';

  @override
  String get embassiesSearchHint => 'Rechercher un pays...';

  @override
  String get embassiesSortDistance => 'Distance';

  @override
  String get embassiesSortRating => 'Note';

  @override
  String get embassiesSortName => 'A-Z';

  @override
  String get embassyTypeConsulate => 'Consulat';

  @override
  String get embassyTypeEmbassy => 'Ambassade';

  @override
  String embassyOpeningHours(Object hours) {
    return 'Horaires : $hours';
  }

  @override
  String embassyRating(Object rating) {
    return 'Note : $rating / 5';
  }

  @override
  String embassyCoordinates(Object coords) {
    return 'Coordonnées : $coords';
  }

  @override
  String embassyPhone(Object phone) {
    return 'Tél : $phone';
  }

  @override
  String embassyEmail(Object email) {
    return 'Email : $email';
  }

  @override
  String get embassyActionMap => 'Carte';

  @override
  String get embassyActionWebsite => 'Site web';

  @override
  String get embassyUrgent => 'Urgence';

  @override
  String get embassyFilterConsulates => 'Consulats';

  @override
  String get embassyFilterEmbassies => 'Ambassades';

  @override
  String embassyDistanceLabel(Object distance) {
    return 'Distance : $distance';
  }

  @override
  String get tourismSearchMinChars =>
      'Saisissez au moins 2 caractères pour rechercher.';

  @override
  String get tourismSearchNoResults =>
      'Aucun lieu trouvé pour cette recherche.';

  @override
  String get tourismSearchUnavailable =>
      'Recherche indisponible pour le moment.';

  @override
  String get tourismLocalFilterHint => 'Filtre local sur la liste affichée.';

  @override
  String get tourismEmptySearch => 'Aucun lieu pour cette recherche';

  @override
  String get nearbyErrorLocationDisabled =>
      'La localisation du téléphone est désactivée. Activez-la dans les réglages.';

  @override
  String get nearbyErrorPermissionDenied =>
      'La permission de localisation est refusée. Autorisez-la pour voir les lieux proches.';

  @override
  String get nearbyErrorPositionTimeout =>
      'Position introuvable pour le moment. Réessayez.';

  @override
  String nearbyFallbackOutOfRadius(int radius) {
    return 'Aucun lieu dans un rayon de $radius m. Élargissez le rayon ou changez de catégorie.';
  }

  @override
  String get incidentVideoGallery => 'Galerie vidéo';

  @override
  String get incidentVideoCamera => 'Caméra vidéo';

  @override
  String get incidentAddVideoError => 'Impossible d\'ajouter la vidéo';

  @override
  String get incidentTrackAction => 'Suivre';

  @override
  String get incidentReportNavShort => 'Signaler';

  @override
  String get incidentHistoryTooltip => 'Historique';

  @override
  String get incidentPrivacyNotice =>
      'Vos preuves seront chiffrées et transmises de façon sécurisée.';

  @override
  String get incidentEvidencePhoto => 'Photo';

  @override
  String get incidentEvidenceVideo => 'Vidéo';

  @override
  String get incidentEvidenceAudio => 'Audio';

  @override
  String incidentVideosAddedCount(int count) {
    return '$count vidéo(s) ajoutée(s)';
  }

  @override
  String incidentDossierRef(Object year, Object month, Object id) {
    return 'Dossier TP-$year-$month-$id';
  }

  @override
  String incidentDossierRefShort(Object id) {
    return 'Dossier #$id';
  }

  @override
  String get jojNoEventsForDate => 'Aucun événement pour cette date';

  @override
  String get jojCurrencyConverterTooltip => 'Convertisseur';

  @override
  String mapRouteServerError(int code) {
    return 'Erreur serveur ($code)';
  }

  @override
  String get mapRouteNotFound => 'Aucun itinéraire trouvé';

  @override
  String get mapRouteDirectionsApiError =>
      'Impossible de calculer l\'itinéraire. Réessayez.';

  @override
  String get mapGuestPointsUnavailable =>
      'Lieux indisponibles pour le moment. Connectez-vous pour tout afficher.';

  @override
  String get mapMissingCoordinates => 'Coordonnées manquantes';

  @override
  String get mapNavInProgress => 'Navigation en cours';

  @override
  String mapNavRemaining(Object distance) {
    return 'Reste $distance';
  }

  @override
  String get mapNavStop => 'Arrêter la navigation';

  @override
  String mapRouteSummaryDriving(Object distance, Object duration) {
    return '$distance · $duration en voiture';
  }

  @override
  String get mapRouteRecalculate => 'Recalculer';

  @override
  String get mapRouteView => 'Voir l\'itinéraire';

  @override
  String get mapNavStart => 'Démarrer';

  @override
  String get mapNavDefaultInstruction => 'Navigation…';

  @override
  String mapNavRemainingDistance(Object distance) {
    return 'Distance restante : $distance';
  }

  @override
  String get mapNavFollowRoute => 'Suivez la route';

  @override
  String get mapNavFollowRouteToDestination =>
      'Suivez la route vers votre destination';

  @override
  String mapNavInMeters(Object distance) {
    return 'Dans $distance mètres';
  }

  @override
  String mapNavInKilometers(Object distance) {
    return 'Dans $distance kilomètres';
  }

  @override
  String get mapNavApproachingTitle => 'Vous approchez !';

  @override
  String mapNavApproachingBody(Object distance) {
    return 'Votre destination est à $distance';
  }

  @override
  String get mapNavArrivedTitle => 'Vous êtes arrivé !';

  @override
  String get mapNavArrivedBody => 'Vous êtes arrivé à destination.';

  @override
  String get mapNavArrivedVoice => 'Vous êtes arrivé à destination';

  @override
  String mapNavInstructionDepart(Object destination) {
    return 'Partez vers $destination';
  }

  @override
  String mapNavInstructionContinue(Object road) {
    return 'Continuez sur $road';
  }

  @override
  String mapNavInstructionTurn(Object direction, Object road) {
    return 'Tournez $direction sur $road';
  }

  @override
  String mapNavInstructionRoundabout(Object exit) {
    return 'Au rond-point, prenez la $exit sortie';
  }

  @override
  String mapNavInstructionArrive(Object destination) {
    return 'Vous êtes arrivé à $destination';
  }
}
