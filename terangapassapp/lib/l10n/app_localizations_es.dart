// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Teranga Pass';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get filter => 'Filtrar';

  @override
  String get allZones => 'Todas las zonas';

  @override
  String get zoneLabel => 'Zona';

  @override
  String get retry => 'Reintentar';

  @override
  String get close => 'Cerrar';

  @override
  String get noNotifications => 'Sin notificaciones';

  @override
  String get clearAll => 'Vaciar todo';

  @override
  String get clearAllConfirmTitle => 'Vaciar todas las notificaciones';

  @override
  String get clearAllConfirmBody =>
      'Se eliminarán todas tus notificaciones personales. Esta acción es irreversible.';

  @override
  String get markAsRead => 'Marcar como leído';

  @override
  String get markAsUnread => 'Marcar como no leído';

  @override
  String get markAllAsRead => 'Marcar todo como leído';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteNotificationTitle => 'Eliminar notificación';

  @override
  String get deleteNotificationBody =>
      '¿Seguro que deseas eliminar esta notificación?';

  @override
  String unreadCount(int count) {
    return '$count no leído(s)';
  }

  @override
  String get notifChipSosShort => 'SOS';

  @override
  String get notifChipMedicalShort => 'Urgencia médica';

  @override
  String get notifChipIncidentShort => 'Reporte';

  @override
  String get notifChipSosSent => 'SOS enviado';

  @override
  String get notifChipMedicalSent => 'Alerta médica';

  @override
  String get notifChipIncidentReceived => 'Reporte registrado';

  @override
  String get notifChipStatusPending => 'En espera';

  @override
  String get notifChipStatusInProgress => 'En curso';

  @override
  String get notifChipStatusResolved => 'Resuelto';

  @override
  String get notifChipStatusCancelled => 'Cancelado';

  @override
  String get notifChipIncidentValidated => 'Validado';

  @override
  String get notifChipIncidentRejected => 'Rechazado';

  @override
  String get notifChipFollowUp => 'Actualización';

  @override
  String get notifChipGeneral => 'Mensaje';

  @override
  String get notifChipAudioAnnouncement => 'Anuncio de audio';

  @override
  String get pullToRefresh => 'Desliza para actualizar';

  @override
  String get openMapError => 'No se puede abrir el mapa';

  @override
  String get settings => 'Ajustes';

  @override
  String get appLanguage => 'Idioma de la aplicación';

  @override
  String get loginValueProps =>
      'Descubrir · Viajar con seguridad · Estar protegido';

  @override
  String get loginTagline => 'Tu seguridad en Dakar';

  @override
  String get loginEmailLabel => 'Correo electrónico';

  @override
  String get loginEmailHint => 'tu@correo.com';

  @override
  String get loginEmailRequired => 'Por favor ingresa tu correo';

  @override
  String get loginEmailInvalid => 'Correo inválido';

  @override
  String get loginIdentifierLabel => 'Correo o número';

  @override
  String get loginIdentifierHint => 'tu@correo.com o número de teléfono';

  @override
  String get loginIdentifierRequired => 'Por favor ingresa tu correo o número';

  @override
  String get loginPhoneInvalid => 'Número inválido (mínimo 9 dígitos)';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginPasswordRequired => 'Por favor ingresa tu contraseña';

  @override
  String get loginPasswordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get loginSignIn => 'Iniciar sesión';

  @override
  String get loginRememberMe => 'Recordarme';

  @override
  String get loginNoAccount => '¿Sin cuenta? Registrarse';

  @override
  String get loginUnknownError => 'Se ha producido un error';

  @override
  String get loginConnectionError =>
      'Error de conexión. Verifica tu conexión a internet e inténtalo de nuevo.';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerSubtitle => 'Únete a Teranga Pass';

  @override
  String get registerFullNameLabel => 'Nombre completo';

  @override
  String get registerFullNameHint => 'Tu nombre';

  @override
  String get registerFullNameRequired => 'Por favor ingresa tu nombre';

  @override
  String get registerPhoneHint => 'Número de teléfono';

  @override
  String get registerPhoneNationalHint => 'Sin código de país';

  @override
  String get registerPhoneRequired => 'Por favor ingresa tu número de teléfono';

  @override
  String get registerSelectCountry => 'Seleccionar país';

  @override
  String get registerPasswordRequired => 'Por favor ingresa una contraseña';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get registerConfirmPasswordRequired =>
      'Por favor confirma tu contraseña';

  @override
  String get registerPasswordsNotMatch => 'Las contraseñas no coinciden';

  @override
  String get registerSignUp => 'Registrarse';

  @override
  String get registerHaveAccount => '¿Ya tienes cuenta? Iniciar sesión';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get call => 'Llamar';

  @override
  String get openPhoneError => 'No se puede abrir el teléfono';

  @override
  String get sosEmergencyTitle => 'SOS Emergencia';

  @override
  String get sosCancelled => 'Alerta SOS cancelada';

  @override
  String get sosSentTitle => 'Alerta SOS enviada';

  @override
  String get sosSentBody =>
      'Tu alerta SOS ha sido enviada a los servicios de emergencia.\n\nLlegarán lo antes posible.';

  @override
  String get sosCountdown => 'Alerta en...';

  @override
  String get sosAlertSent => '¡ALERTA ENVIADA!';

  @override
  String get sosUrgenceLabel => 'SOS EMERGENCIA';

  @override
  String get sosHoldBanner => 'EMERGENCIA – MANTÉN PULSADO';

  @override
  String get sosDangerQuestion => '¿Estás\nen peligro?';

  @override
  String get sosThreeSecondsBadge => '3 SEGUNDOS';

  @override
  String get sosPressToAlert => 'Pulsa para alertar';

  @override
  String get sosCancelAlert => 'CANCELAR ALERTA';

  @override
  String callServiceTitle(Object service) {
    return 'Llamar a $service';
  }

  @override
  String callServicePrompt(Object service, Object number) {
    return '¿Deseas llamar a $service al $number?';
  }

  @override
  String get sosUnknownPosition => 'Posición desconocida';

  @override
  String get sosCurrentPosition => 'Tu posición actual';

  @override
  String sosAccuracy(Object meters) {
    return 'Precisión: $meters metros';
  }

  @override
  String get sosEmergencyServices => 'Servicios de emergencia';

  @override
  String get sosHistory => 'Historial';

  @override
  String get sosNoRecentAlerts => 'Sin alertas recientes';

  @override
  String sosNumber(Object number) {
    return 'Número: $number';
  }

  @override
  String get unknownPosition => 'Posición desconocida';

  @override
  String get incidentReportTitle => 'Reportar un incidente';

  @override
  String get incidentTypeTitle => 'Tipo de incidente';

  @override
  String get incidentTypeLoss => 'Pérdida';

  @override
  String get incidentTypeAccident => 'Accidente';

  @override
  String get incidentTypeSuspicious => 'Sospechoso';

  @override
  String get incidentDescriptionTitle => 'Descripción';

  @override
  String get incidentDescriptionHint => 'Describe el incidente en detalle...';

  @override
  String get incidentPhotosTitle => 'Fotos';

  @override
  String get incidentAudioTitle => 'Audio';

  @override
  String get incidentLocationTitle => 'Lugar del incidente';

  @override
  String get incidentAdd => 'Añadir';

  @override
  String get incidentRecordingInProgress => 'Grabando...';

  @override
  String get incidentAddVoiceMessage => 'Añadir mensaje de voz';

  @override
  String get incidentTapToRecord => 'Pulsa para grabar';

  @override
  String get incidentAudioAdded => 'Audio añadido';

  @override
  String get incidentSendReport => 'ENVIAR EL REPORTE';

  @override
  String get incidentSelectTypeError =>
      'Por favor selecciona un tipo de incidente';

  @override
  String get incidentDescribeError => 'Por favor describe el incidente';

  @override
  String get incidentSentTitle => 'Reporte enviado';

  @override
  String get incidentSentBody =>
      'Tu reporte ha sido enviado a las autoridades competentes.\n\nRecibirás una respuesta a la brevedad.';

  @override
  String get incidentAddPhotoError => 'No se puede añadir una foto';

  @override
  String get incidentStopRecordingError => 'No se puede detener la grabación';

  @override
  String get incidentMicPermissionDenied => 'Permiso de micrófono denegado';

  @override
  String get incidentStartRecordingError => 'No se puede iniciar la grabación';

  @override
  String get incidentGallery => 'Galería';

  @override
  String get incidentCamera => 'Cámara';

  @override
  String get medicalAlertTitle => 'Alerta Médica';

  @override
  String get homeFeatureAudioAnnouncements => 'Anuncios de Audio';

  @override
  String get homeFeatureTouristInfo => 'Info Turista';

  @override
  String get homeFeatureCompetitionSites => 'Sedes de Competición';

  @override
  String get homeFeatureCompetitions => 'Competiciones';

  @override
  String get homeFeatureTransport => 'Lanzaderas y Transportes';

  @override
  String get homeFeatureReportIncident => 'Reportar Incidente';

  @override
  String get homeOfficialAnnouncementDefaultTitle => 'Anuncio oficial';

  @override
  String get passQrTitle => 'Mi Pass Teranga';

  @override
  String get passQrEntry => 'Mostrar mi Pass (QR)';

  @override
  String get passQrSubtitle =>
      'Presenta este código en los controles de acceso (piloto JOJ).';

  @override
  String get passQrRetry => 'Reintentar';

  @override
  String get homeJojInfoTitle => 'INFO JOJ: Sedes de Competición';

  @override
  String get homeCalendar => 'Calendario';

  @override
  String get homeNoActiveSites => 'Sin sedes activas';

  @override
  String get homeAddLatLngHint => 'Añade latitud/longitud en el panel';

  @override
  String get homeSiteFallback => 'Sede';

  @override
  String get homeNavHome => 'Inicio';

  @override
  String get homeNavMedicalAlert => 'Alerta Médica';

  @override
  String get homeNavSos => 'SOS';

  @override
  String get homeNavReport => 'Reporte';

  @override
  String get homeNavProfile => 'Perfil';

  @override
  String get homeComingSoon => 'Esta función estará disponible próximamente.';

  @override
  String get medicalSelectTypeError =>
      'Por favor selecciona un tipo de urgencia médica';

  @override
  String get medicalSentTitle => 'Alerta médica enviada';

  @override
  String get medicalSentBody =>
      'Tu alerta médica ha sido enviada a los servicios médicos.\n\nUna ambulancia está en camino.';

  @override
  String get medicalSending => 'Enviando alerta...';

  @override
  String get medicalTapToAlert => 'Pulsa para alertar a los servicios médicos';

  @override
  String get medicalEmergencyTypeTitle => 'Tipo de urgencia médica';

  @override
  String get medicalTypeAccident => 'Accidente';

  @override
  String get medicalTypeFainting => 'Desmayo';

  @override
  String get medicalTypeInjury => 'Herida';

  @override
  String get medicalTypeOther => 'Otro';

  @override
  String get medicalYourPosition => 'Tu posición';

  @override
  String get medicalNearbyHospitals => 'Hospitales cercanos';

  @override
  String get medicalNoNearbyHospitals =>
      'No se encontraron hospitales cercanos';

  @override
  String medicalEmergencyNumberLabel(Object number) {
    return 'Emergencia $number';
  }

  @override
  String get transportTitle => 'Transporte y Lanzaderas';

  @override
  String get transportNoShuttles => 'Sin lanzaderas disponibles';

  @override
  String get transportSecure => 'Seguro';

  @override
  String transportTerminusPrefix(Object terminus) {
    return 'Terminus: $terminus';
  }

  @override
  String get transportNextDeparturePrefix => 'Próxima salida:';

  @override
  String get transportNextDeparture => 'Próxima salida';

  @override
  String get transportItinerarySection => 'Itinerario';

  @override
  String get transportRouteLabel => 'Ruta';

  @override
  String get transportDepartureLabel => 'Salida';

  @override
  String get transportTerminusLabel => 'Terminus';

  @override
  String get transportStartPointLabel => 'Punto de partida';

  @override
  String get transportScheduleSection => 'Horarios';

  @override
  String get transportScheduleLabel => 'Horario';

  @override
  String get transportDaysLabel => 'Días';

  @override
  String get transportPeriodLabel => 'Período';

  @override
  String get transportFrequencyLabel => 'Frecuencia';

  @override
  String get transportStopsSection => 'Paradas';

  @override
  String get transportDescriptionSection => 'Descripción';

  @override
  String get timeJustNow => 'Ahora mismo';

  @override
  String timeMinutesAgo(Object count) {
    return 'Hace $count min';
  }

  @override
  String timeHoursAgo(Object count) {
    return 'Hace $count h';
  }

  @override
  String timeDaysAgo(Object count) {
    return 'Hace $count días';
  }

  @override
  String get profileTitle => 'Mi Perfil';

  @override
  String get profileUnavailable => 'Perfil no disponible';

  @override
  String get profilePersonalInfoSection => 'Información personal';

  @override
  String get profileNotificationsSetting => 'Notificaciones';

  @override
  String get profileGeolocationSetting => 'Geolocalización';

  @override
  String get profilePrivacySetting => 'Privacidad';

  @override
  String get profileOverviewSection => 'Resumen';

  @override
  String get profileAlertsStat => 'Alertas';

  @override
  String get profileReportsStat => 'Reportes';

  @override
  String get profileRecentActivitiesSection => 'Actividades Recientes';

  @override
  String get profileNoRecentActivity => 'Sin actividad reciente';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileDefaultSosTitle => 'Alerta SOS';

  @override
  String get profileDefaultReportTitle => 'Reporte';

  @override
  String get historyUnifiedTitle => 'Historial SOS y reportes';

  @override
  String get historyUnifiedEmpty => 'Sin SOS, alertas médicas ni reportes';

  @override
  String get historyKindSos => 'SOS';

  @override
  String get historyKindMedical => 'Alerta médica';

  @override
  String get historyKindReport => 'Reporte';

  @override
  String get historyAlertDetailTitle => 'Detalle de la alerta';

  @override
  String get historyFieldAddress => 'Dirección';

  @override
  String get historyFieldDate => 'Fecha';

  @override
  String get historyFieldCoords => 'Coordenadas';

  @override
  String get alertTrackingNavTitle => 'Mi alerta';

  @override
  String get alertTimelineRecorded => 'Alerta registrada';

  @override
  String get alertTimelineDispatched => 'Enviada a los servicios de emergencia';

  @override
  String get alertTimelineClosed => 'Cerrada';

  @override
  String get alertTimelineRejected => 'Rechazada';

  @override
  String get alertTimelineCancelled => 'Cancelada';

  @override
  String get privacyPersonalDataTitle => 'Datos personales';

  @override
  String get privacyPersonalDataBody =>
      'Teranga Pass utiliza tu información para mejorar tu experiencia (ej: perfil, notificaciones, seguridad). Puedes gestionar ciertos permisos desde tu teléfono.';

  @override
  String get privacyLocationSubtitle =>
      'Permitir para mostrar puntos cercanos.';

  @override
  String get privacyNotificationsSubtitle =>
      'Recibir alertas e información útil.';

  @override
  String get audioTitle => 'Anuncios de Audio';

  @override
  String get audioNoAudioAvailable => 'Sin audio disponible para este anuncio';

  @override
  String get audioCannotPlay => 'No se puede reproducir el audio';

  @override
  String get audioNoAnnouncements => 'Sin anuncios disponibles';

  @override
  String get audioAllLanguages => 'Todos';

  @override
  String get tourismTitle => 'Turismo y Servicios';

  @override
  String get tourismCategoryAll => 'Todos';

  @override
  String get tourismCategoryHotels => 'Hoteles';

  @override
  String get tourismCategoryRestaurants => 'Restaurantes';

  @override
  String get tourismCategoryPharmacies => 'Farmacias';

  @override
  String get tourismCategoryHospitals => 'Hospitales';

  @override
  String get tourismCategoryEmbassies => 'Embajadas';

  @override
  String tourismTabWithCount(Object label, Object count) {
    return '$label ($count)';
  }

  @override
  String get tourismCoordinatesMissing => 'Coordenadas faltantes';

  @override
  String get tourismEnableLocation => 'Activar ubicación';

  @override
  String get tourismDistanceUnavailable => 'Distancia no disponible';

  @override
  String get tourismSettingsButton => 'Ajustes';

  @override
  String get tourismEnableGpsButton => 'Activar GPS';

  @override
  String get tourismNoResults => 'Sin resultados';

  @override
  String get mapTitle => 'Mapa Interactivo';

  @override
  String get mapPlaceholderTitle => 'Mapa interactivo';

  @override
  String get mapPlaceholderSubtitle => 'Integración Google Maps próximamente';

  @override
  String get mapOpenInGoogleMaps => 'Abrir en Google Maps';

  @override
  String get mapNearbyPointsTitle => 'Puntos de interés cercanos';

  @override
  String get mapNoPoints => 'Sin puntos disponibles';

  @override
  String get mapDefaultPointName => 'Punto de interés';

  @override
  String get mapPositionUpdated => 'Posición actualizada';

  @override
  String get mapCannotGetPosition => 'No se puede obtener la posición';

  @override
  String get mapOpenGoogleMapsError => 'No se puede abrir Google Maps';

  @override
  String get mapTilesLoadIssue =>
      'El mapa puede estar incompleto. Verifica tu conexión.';

  @override
  String get mapFilterAll => 'Todos';

  @override
  String get mapFilterHelp => 'Ayuda';

  @override
  String get mapFilterSites => 'Sedes JOJ';

  @override
  String get mapFilterHotels => 'Hoteles';

  @override
  String get mapFilterRestaurants => 'Restaurantes';

  @override
  String get mapFilterPharmacies => 'Farmacias';

  @override
  String get mapFilterHospitals => 'Hospitales';

  @override
  String get notificationsFallbackTitle => 'Notificación';

  @override
  String get jojTitle => 'Info JOJ';

  @override
  String get jojTabCalendar => 'Calendario';

  @override
  String jojTabSportsWithCount(Object count) {
    return 'Deportes ($count)';
  }

  @override
  String get jojTabAccess => 'Acceso';

  @override
  String get jojCalendarComingSoon => 'Calendario próximamente';

  @override
  String get jojDefaultEventTitle => 'Evento';

  @override
  String get jojNoSportsAvailable => 'Sin deportes disponibles';

  @override
  String get jojDefaultLocation => 'Dakar';

  @override
  String get jojDatesComingSoon => 'Fechas próximamente';

  @override
  String get jojSeeOnMap => 'Ver en el mapa';

  @override
  String get jojDestinationFallback => 'Destino';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileNameLabel => 'Nombre';

  @override
  String get profilePhoneLabel => 'Teléfono';

  @override
  String get profileLanguageLabel => 'Idioma';

  @override
  String get profileUserTypeLabel => 'Tipo de usuario';

  @override
  String get profileUserTypeVisitor => 'Visitante';

  @override
  String get profileUserTypeCitizen => 'Ciudadano';

  @override
  String get profileUserTypeAthlete => 'Atleta';

  @override
  String get profileNameRequired => 'El nombre es obligatorio';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get profileSave => 'Guardar';

  @override
  String get sosServicePolice => 'Policía';

  @override
  String get sosServiceFirefighters => 'Bomberos';

  @override
  String get sosServiceAmbulance => 'Ambulancia';

  @override
  String get sosFallbackAddress => 'Dakar Plateau, 9 Rue Carnot';

  @override
  String get homeAppNamePart1 => 'Teranga ';

  @override
  String get homeAppNamePart2 => 'Pass';

  @override
  String get homeTagline => 'Tu seguridad en Dakar, descubrimientos en Senegal';

  @override
  String get homePillarDiscoverTitle => 'Descubrir';

  @override
  String get homePillarDiscoverSubtitle => 'Sitios · Restaurantes · Hoteles';

  @override
  String get homePillarMoveTitle => 'Moverse';

  @override
  String get homePillarMoveSubtitle => 'Mapa · Lanzaderas · Taxis';

  @override
  String get homePillarJojTitle => 'JOJ 2026';

  @override
  String get homePillarJojSubtitle => 'Calendario · Medallas';

  @override
  String get homePillarHelpTitle => 'Ser ayudado';

  @override
  String get homePillarHelpSubtitle => 'SOS · Médico · Embajada';

  @override
  String get homeHelpSheetTitle => 'Ser ayudado';

  @override
  String get homeHelpSheetSubtitle => 'Elige una acción rápida';

  @override
  String get homeHeroWelcome => 'Bienvenido a Senegal,';

  @override
  String get nearbyChipHotels => 'Hoteles';

  @override
  String get nearbyChipHospitals => 'Hospitales';

  @override
  String get nearbyChipClinics => 'Clínicas';

  @override
  String get nearbyChipNotaries => 'Notarios';

  @override
  String get nearbyChipLawyers => 'Abogados';

  @override
  String get nearbyChipDoctors => 'Médicos';

  @override
  String get nearbyChipGovernment => 'Estado';

  @override
  String get nearbyChipSchools => 'Escuelas';

  @override
  String get nearbyChipUniversities => 'Universidades';

  @override
  String get nearbyChipMedia => 'Medios';

  @override
  String get nearbyChipProfessionalServices => 'Profesionales';

  @override
  String get nearbyChipReligiousSites => 'Culto';

  @override
  String get nearbyAll => 'Todos';

  @override
  String get nearbyTitle => 'Cerca de aquí';

  @override
  String get nearbyNearMeTooltip => 'Cerca de mí';

  @override
  String nearbyRadiusLabel(int meters) {
    return 'Radio: $meters m';
  }

  @override
  String get nearbyEmpty => 'Sin lugares en este radio para esta categoría.';

  @override
  String get nearbyLocationError =>
      'La ubicación no está activada. Actívala para ver lugares cercanos.';

  @override
  String get nearbySponsorBadge => 'Socio';

  @override
  String get profileEsimTitle => 'Planes eSIM';

  @override
  String get profileEsimSubtitle => 'Datos de viaje (próximamente)';

  @override
  String get esimComingTitle => 'eSIM Teranga Pass';

  @override
  String get esimComingBody =>
      'La integración de socios (ej. Airalo), los pagos (PayDunya, Wave) y la activación por QR llegarán en una próxima versión. Esta pantalla sirve de referencia para la demo y revisión del producto.';

  @override
  String get mapLegendTitle => 'Leyenda';

  @override
  String get mapLegendYou => 'Tú';

  @override
  String get mapLegendPlace => 'Lugar';

  @override
  String get mapLegendSponsor => 'Socio destacado';

  @override
  String get mapLegendCategoriesHint =>
      'Los colores de los marcadores en el mapa indican el tipo de lugar (filtros de arriba).';

  @override
  String get mapLegendJojSitesHint =>
      'Marcadores verdes: sedes de competición JOJ en el mapa.';

  @override
  String get profileOfflinePackTitle => 'Pack sin conexión';

  @override
  String get profileOfflinePackBody =>
      'POI y contenidos útiles sin red (despliegue progresivo).';

  @override
  String profileOfflinePackCatalogVersion(String version) {
    return 'Catálogo del servidor: $version';
  }

  @override
  String get profileOfflinePackCatalogPending => 'Catálogo: no sincronizado';

  @override
  String get profileOfflinePackDialogBody =>
      'Descarga POI, sedes JOJ, embajadas, calendario y anuncios para consultarlos sin red. En caso de corte, la descarga se retoma: los archivos ya correctos se omiten.';

  @override
  String get profileOfflinePackDownload => 'Descargar / actualizar';

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
      'Pack guardado en el dispositivo.';

  @override
  String get profileOfflinePackDownloadPartial =>
      'Descarga incompleta. Inténtalo de nuevo con red.';

  @override
  String get profileOfflinePackAlreadyCurrent =>
      'Ya tienes la última versión en local.';

  @override
  String get profileOfflinePackDownloadError =>
      'No se puede obtener el manifiesto. Verifica la red.';

  @override
  String get offlineUsingCache => 'Modo sin conexión: datos en caché.';

  @override
  String offlinePackUpdated(String version) {
    return 'Pack $version guardado en el dispositivo.';
  }

  @override
  String profileOfflinePackFilesVersion(String version) {
    return 'Archivos locales: $version';
  }

  @override
  String get profileOfflinePackStaleFiles =>
      'Algunos archivos son más antiguos que el catálogo: conéctate a la red para completar la actualización.';

  @override
  String profileOfflinePackLocalSize(String size) {
    return 'Almacenamiento local: $size';
  }

  @override
  String get incidentTrackingNavTitle => 'Mi reporte';

  @override
  String get incidentTypeLossLabel =>
      'Pérdida de objeto o pertenencias personales';

  @override
  String get incidentTypeSuspiciousLabel => 'Comportamiento sospechoso';

  @override
  String get incidentTypeOtherLabel => 'Otro reporte';

  @override
  String get incidentStatusInProgress => 'En proceso de tramitación';

  @override
  String get incidentStatusProcessed => 'Tramitado';

  @override
  String get incidentStatusValidated => 'Validado';

  @override
  String get incidentStatusRejected => 'Rechazado';

  @override
  String get incidentStatusPending => 'En espera';

  @override
  String get incidentStatusCancelled => 'Cancelado';

  @override
  String get incidentTrackingEmptyTimeline =>
      'El seguimiento se mostrará cuando tu reporte sea tramitado.';

  @override
  String get loadingWait => 'Un momento por favor…';

  @override
  String get homeSearchHint => 'Restaurantes, sitios, hoteles, eventos...';

  @override
  String get homeJojCountdownLabel => 'Días antes de los JOJ';

  @override
  String get homeEsimConnectSubtitle => 'Conéctate';

  @override
  String get homeNearbySubtitle => 'A mi alrededor';

  @override
  String get homeAudioListenSubtitle => 'Escuchar';

  @override
  String get homeMyReportsTitle => 'Mis reportes';

  @override
  String get homeMyReportsSubtitle => 'Seguir';

  @override
  String get homeCurrencyTitle => 'Conversor';
}
