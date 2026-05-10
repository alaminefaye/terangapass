// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Teranga Pass';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get filter => 'Filtrar';

  @override
  String get allZones => 'Todas as zonas';

  @override
  String get zoneLabel => 'Zona';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get close => 'Fechar';

  @override
  String get noNotifications => 'Sem notificações';

  @override
  String get clearAll => 'Limpar tudo';

  @override
  String get clearAllConfirmTitle => 'Limpar todas as notificações';

  @override
  String get clearAllConfirmBody =>
      'Todas as suas notificações pessoais serão eliminadas. Esta ação é irreversível.';

  @override
  String get markAsRead => 'Marcar como lido';

  @override
  String get markAsUnread => 'Marcar como não lido';

  @override
  String get markAllAsRead => 'Marcar tudo como lido';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteNotificationTitle => 'Eliminar notificação';

  @override
  String get deleteNotificationBody =>
      'Tem certeza de que deseja eliminar esta notificação?';

  @override
  String unreadCount(int count) {
    return '$count não lido(s)';
  }

  @override
  String get notifChipSosShort => 'SOS';

  @override
  String get notifChipMedicalShort => 'Urgência médica';

  @override
  String get notifChipIncidentShort => 'Relatório';

  @override
  String get notifChipSosSent => 'SOS enviado';

  @override
  String get notifChipMedicalSent => 'Alerta médico';

  @override
  String get notifChipIncidentReceived => 'Relatório registado';

  @override
  String get notifChipStatusPending => 'Pendente';

  @override
  String get notifChipStatusInProgress => 'Em curso';

  @override
  String get notifChipStatusResolved => 'Resolvido';

  @override
  String get notifChipStatusCancelled => 'Cancelado';

  @override
  String get notifChipIncidentValidated => 'Validado';

  @override
  String get notifChipIncidentRejected => 'Rejeitado';

  @override
  String get notifChipFollowUp => 'Atualização';

  @override
  String get notifChipGeneral => 'Mensagem';

  @override
  String get notifChipAudioAnnouncement => 'Anúncio de áudio';

  @override
  String get pullToRefresh => 'Puxe para atualizar';

  @override
  String get openMapError => 'Impossível abrir o mapa';

  @override
  String get settings => 'Definições';

  @override
  String get appLanguage => 'Idioma da aplicação';

  @override
  String get loginValueProps =>
      'Descobrir · Viajar com segurança · Estar protegido';

  @override
  String get loginTagline => 'A sua segurança em Dakar';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginEmailHint => 'o_seu@email.com';

  @override
  String get loginEmailRequired => 'Por favor, introduza o seu e-mail';

  @override
  String get loginEmailInvalid => 'E-mail inválido';

  @override
  String get loginIdentifierLabel => 'E-mail ou número';

  @override
  String get loginIdentifierHint => 'o_seu@email.com ou número de telefone';

  @override
  String get loginIdentifierRequired =>
      'Por favor, introduza o seu e-mail ou número';

  @override
  String get loginPhoneInvalid => 'Número inválido (mínimo 9 dígitos)';

  @override
  String get loginPasswordLabel => 'Palavra-passe';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginPasswordRequired =>
      'Por favor, introduza a sua palavra-passe';

  @override
  String get loginPasswordMinLength =>
      'A palavra-passe deve ter pelo menos 6 caracteres';

  @override
  String get loginSignIn => 'Entrar';

  @override
  String get loginRememberMe => 'Lembrar-me';

  @override
  String get loginNoAccount => 'Sem conta? Registar';

  @override
  String get loginUnknownError => 'Ocorreu um erro';

  @override
  String get loginConnectionError =>
      'Erro de ligação. Verifique a sua ligação à internet e tente novamente.';

  @override
  String get registerTitle => 'Criar conta';

  @override
  String get registerSubtitle => 'Junte-se ao Teranga Pass';

  @override
  String get registerFullNameLabel => 'Nome completo';

  @override
  String get registerFullNameHint => 'O seu nome';

  @override
  String get registerFullNameRequired => 'Por favor, introduza o seu nome';

  @override
  String get registerPhoneHint => 'Número de telefone';

  @override
  String get registerPhoneNationalHint => 'Sem indicativo do país';

  @override
  String get registerPhoneRequired =>
      'Por favor, introduza o seu número de telefone';

  @override
  String get registerSelectCountry => 'Selecionar país';

  @override
  String get registerPasswordRequired =>
      'Por favor, introduza uma palavra-passe';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar palavra-passe';

  @override
  String get registerConfirmPasswordRequired =>
      'Por favor, confirme a sua palavra-passe';

  @override
  String get registerPasswordsNotMatch => 'As palavras-passe não coincidem';

  @override
  String get registerSignUp => 'Registar';

  @override
  String get registerHaveAccount => 'Já tem conta? Entrar';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get call => 'Ligar';

  @override
  String get openPhoneError => 'Impossível abrir o telefone';

  @override
  String get sosEmergencyTitle => 'SOS Emergência';

  @override
  String get sosCancelled => 'Alerta SOS cancelado';

  @override
  String get sosSentTitle => 'Alerta SOS enviado';

  @override
  String get sosSentBody =>
      'O seu alerta SOS foi enviado para os serviços de emergência.\n\nChegarão o mais breve possível.';

  @override
  String get sosCountdown => 'Alerta em...';

  @override
  String get sosAlertSent => 'ALERTA ENVIADO!';

  @override
  String get sosUrgenceLabel => 'SOS EMERGÊNCIA';

  @override
  String get sosHoldBanner => 'EMERGÊNCIA – MANTENHA PRESSIONADO';

  @override
  String get sosDangerQuestion => 'Está\nem perigo?';

  @override
  String get sosThreeSecondsBadge => '3 SEGUNDOS';

  @override
  String get sosPressToAlert => 'Prima para alertar';

  @override
  String get sosCancelAlert => 'CANCELAR ALERTA';

  @override
  String callServiceTitle(Object service) {
    return 'Ligar para $service';
  }

  @override
  String callServicePrompt(Object service, Object number) {
    return 'Deseja ligar para $service ao número $number?';
  }

  @override
  String get sosUnknownPosition => 'Posição desconhecida';

  @override
  String get sosCurrentPosition => 'A sua posição atual';

  @override
  String sosAccuracy(Object meters) {
    return 'Precisão: $meters metros';
  }

  @override
  String get sosEmergencyServices => 'Serviços de emergência';

  @override
  String get sosHistory => 'Histórico';

  @override
  String get sosNoRecentAlerts => 'Sem alertas recentes';

  @override
  String sosNumber(Object number) {
    return 'Número: $number';
  }

  @override
  String get unknownPosition => 'Posição desconhecida';

  @override
  String get incidentReportTitle => 'Reportar um incidente';

  @override
  String get incidentTypeTitle => 'Tipo de incidente';

  @override
  String get incidentTypeLoss => 'Perda';

  @override
  String get incidentTypeAccident => 'Acidente';

  @override
  String get incidentTypeSuspicious => 'Suspeito';

  @override
  String get incidentDescriptionTitle => 'Descrição';

  @override
  String get incidentDescriptionHint => 'Descreva o incidente em detalhe...';

  @override
  String get incidentPhotosTitle => 'Fotos';

  @override
  String get incidentAudioTitle => 'Áudio';

  @override
  String get incidentLocationTitle => 'Local do incidente';

  @override
  String get incidentAdd => 'Adicionar';

  @override
  String get incidentRecordingInProgress => 'A gravar...';

  @override
  String get incidentAddVoiceMessage => 'Adicionar mensagem de voz';

  @override
  String get incidentTapToRecord => 'Prima para gravar';

  @override
  String get incidentAudioAdded => 'Áudio adicionado';

  @override
  String get incidentSendReport => 'ENVIAR O RELATÓRIO';

  @override
  String get incidentSelectTypeError =>
      'Por favor, selecione um tipo de incidente';

  @override
  String get incidentDescribeError => 'Por favor, descreva o incidente';

  @override
  String get incidentSentTitle => 'Relatório enviado';

  @override
  String get incidentSentBody =>
      'O seu relatório foi enviado às autoridades competentes.\n\nReceberá uma resposta o mais breve possível.';

  @override
  String get incidentAddPhotoError => 'Impossível adicionar uma foto';

  @override
  String get incidentStopRecordingError => 'Impossível parar a gravação';

  @override
  String get incidentMicPermissionDenied => 'Permissão de microfone negada';

  @override
  String get incidentStartRecordingError => 'Impossível iniciar a gravação';

  @override
  String get incidentGallery => 'Galeria';

  @override
  String get incidentCamera => 'Câmara';

  @override
  String get medicalAlertTitle => 'Alerta Médico';

  @override
  String get homeFeatureAudioAnnouncements => 'Anúncios de Áudio';

  @override
  String get homeFeatureTouristInfo => 'Info Turista';

  @override
  String get homeFeatureCompetitionSites => 'Locais de Competição';

  @override
  String get homeFeatureCompetitions => 'Competições';

  @override
  String get homeFeatureTransport => 'Shuttles e Transportes';

  @override
  String get homeFeatureReportIncident => 'Reportar Incidente';

  @override
  String get homeOfficialAnnouncementDefaultTitle => 'Anúncio oficial';

  @override
  String get passQrTitle => 'O Meu Pass Teranga';

  @override
  String get passQrEntry => 'Mostrar o meu Pass (QR)';

  @override
  String get passQrSubtitle =>
      'Apresente este código nos controlos de acesso (piloto JOJ).';

  @override
  String get passQrRetry => 'Tentar novamente';

  @override
  String get homeJojInfoTitle => 'INFO JOJ: Locais de Competição';

  @override
  String get homeCalendar => 'Calendário';

  @override
  String get homeNoActiveSites => 'Sem locais ativos';

  @override
  String get homeAddLatLngHint => 'Adicione latitude/longitude no painel';

  @override
  String get homeSiteFallback => 'Local';

  @override
  String get homeNavHome => 'Início';

  @override
  String get homeNavMedicalAlert => 'Alerta Médico';

  @override
  String get homeNavSos => 'SOS';

  @override
  String get homeNavReport => 'Relatório';

  @override
  String get homeNavProfile => 'Perfil';

  @override
  String get homeComingSoon =>
      'Esta funcionalidade estará disponível em breve.';

  @override
  String get medicalSelectTypeError =>
      'Por favor, selecione um tipo de urgência médica';

  @override
  String get medicalSentTitle => 'Alerta médico enviado';

  @override
  String get medicalSentBody =>
      'O seu alerta médico foi enviado para os serviços médicos.\n\nUma ambulância está a caminho.';

  @override
  String get medicalSending => 'A enviar alerta...';

  @override
  String get medicalTapToAlert => 'Prima para alertar os serviços médicos';

  @override
  String get medicalEmergencyTypeTitle => 'Tipo de urgência médica';

  @override
  String get medicalTypeAccident => 'Acidente';

  @override
  String get medicalTypeFainting => 'Desmaio';

  @override
  String get medicalTypeInjury => 'Ferimento';

  @override
  String get medicalTypeOther => 'Outro';

  @override
  String get medicalYourPosition => 'A sua posição';

  @override
  String get medicalNearbyHospitals => 'Hospitais próximos';

  @override
  String get medicalNoNearbyHospitals =>
      'Nenhum hospital encontrado nas proximidades';

  @override
  String medicalEmergencyNumberLabel(Object number) {
    return 'Emergência $number';
  }

  @override
  String get transportTitle => 'Transporte e Shuttles';

  @override
  String get transportNoShuttles => 'Sem shuttles disponíveis';

  @override
  String get transportSecure => 'Seguro';

  @override
  String transportTerminusPrefix(Object terminus) {
    return 'Terminus: $terminus';
  }

  @override
  String get transportNextDeparturePrefix => 'Próxima partida:';

  @override
  String get transportNextDeparture => 'Próxima partida';

  @override
  String get transportItinerarySection => 'Itinerário';

  @override
  String get transportRouteLabel => 'Rota';

  @override
  String get transportDepartureLabel => 'Partida';

  @override
  String get transportTerminusLabel => 'Terminus';

  @override
  String get transportStartPointLabel => 'Ponto de partida';

  @override
  String get transportScheduleSection => 'Horários';

  @override
  String get transportScheduleLabel => 'Horário';

  @override
  String get transportDaysLabel => 'Dias';

  @override
  String get transportPeriodLabel => 'Período';

  @override
  String get transportFrequencyLabel => 'Frequência';

  @override
  String get transportStopsSection => 'Paragens';

  @override
  String get transportDescriptionSection => 'Descrição';

  @override
  String get timeJustNow => 'Agora mesmo';

  @override
  String timeMinutesAgo(Object count) {
    return 'Há $count min';
  }

  @override
  String timeHoursAgo(Object count) {
    return 'Há $count h';
  }

  @override
  String timeDaysAgo(Object count) {
    return 'Há $count dias';
  }

  @override
  String get profileTitle => 'O Meu Perfil';

  @override
  String get profileUnavailable => 'Perfil indisponível';

  @override
  String get profilePersonalInfoSection => 'Informações pessoais';

  @override
  String get profileNotificationsSetting => 'Notificações';

  @override
  String get profileGeolocationSetting => 'Geolocalização';

  @override
  String get profilePrivacySetting => 'Privacidade';

  @override
  String get profileOverviewSection => 'Visão geral';

  @override
  String get profileAlertsStat => 'Alertas';

  @override
  String get profileReportsStat => 'Relatórios';

  @override
  String get profileRecentActivitiesSection => 'Atividades Recentes';

  @override
  String get profileNoRecentActivity => 'Sem atividade recente';

  @override
  String get profileLogout => 'Terminar sessão';

  @override
  String get profileDefaultSosTitle => 'Alerta SOS';

  @override
  String get profileDefaultReportTitle => 'Relatório';

  @override
  String get historyUnifiedTitle => 'Histórico SOS e relatórios';

  @override
  String get historyUnifiedEmpty => 'Sem SOS, alertas médicos nem relatórios';

  @override
  String get historyKindSos => 'SOS';

  @override
  String get historyKindMedical => 'Alerta médico';

  @override
  String get historyKindReport => 'Relatório';

  @override
  String get historyAlertDetailTitle => 'Detalhe do alerta';

  @override
  String get historyFieldAddress => 'Endereço';

  @override
  String get historyFieldDate => 'Data';

  @override
  String get historyFieldCoords => 'Coordenadas';

  @override
  String get alertTrackingNavTitle => 'O meu alerta';

  @override
  String get alertTimelineRecorded => 'Alerta registado';

  @override
  String get alertTimelineDispatched =>
      'Enviado para os serviços de emergência';

  @override
  String get alertTimelineClosed => 'Encerrado';

  @override
  String get alertTimelineRejected => 'Rejeitado';

  @override
  String get alertTimelineCancelled => 'Cancelado';

  @override
  String get privacyPersonalDataTitle => 'Dados pessoais';

  @override
  String get privacyPersonalDataBody =>
      'Teranga Pass utiliza as suas informações para melhorar a sua experiência (ex: perfil, notificações, segurança). Pode gerir determinadas permissões no seu telemóvel.';

  @override
  String get privacyLocationSubtitle =>
      'Autorizar para mostrar pontos próximos.';

  @override
  String get privacyNotificationsSubtitle =>
      'Receber alertas e informações úteis.';

  @override
  String get audioTitle => 'Anúncios de Áudio';

  @override
  String get audioNoAudioAvailable => 'Sem áudio disponível para este anúncio';

  @override
  String get audioCannotPlay => 'Impossível reproduzir o áudio';

  @override
  String get audioNoAnnouncements => 'Sem anúncios disponíveis';

  @override
  String get audioAllLanguages => 'Todos';

  @override
  String get tourismTitle => 'Turismo e Serviços';

  @override
  String get tourismCategoryAll => 'Todos';

  @override
  String get tourismCategoryHotels => 'Hotéis';

  @override
  String get tourismCategoryRestaurants => 'Restaurantes';

  @override
  String get tourismCategoryPharmacies => 'Farmácias';

  @override
  String get tourismCategoryHospitals => 'Hospitais';

  @override
  String get tourismCategoryEmbassies => 'Embaixadas';

  @override
  String tourismTabWithCount(Object label, Object count) {
    return '$label ($count)';
  }

  @override
  String get tourismCoordinatesMissing => 'Coordenadas em falta';

  @override
  String get tourismEnableLocation => 'Ativar localização';

  @override
  String get tourismDistanceUnavailable => 'Distância indisponível';

  @override
  String get tourismSettingsButton => 'Definições';

  @override
  String get tourismEnableGpsButton => 'Ativar GPS';

  @override
  String get tourismNoResults => 'Sem resultados';

  @override
  String get mapTitle => 'Mapa Interativo';

  @override
  String get mapPlaceholderTitle => 'Mapa interativo';

  @override
  String get mapPlaceholderSubtitle => 'Integração Google Maps em breve';

  @override
  String get mapOpenInGoogleMaps => 'Abrir no Google Maps';

  @override
  String get mapNearbyPointsTitle => 'Pontos de interesse próximos';

  @override
  String get mapNoPoints => 'Sem pontos disponíveis';

  @override
  String get mapDefaultPointName => 'Ponto de interesse';

  @override
  String get mapPositionUpdated => 'Posição atualizada';

  @override
  String get mapCannotGetPosition => 'Impossível obter a posição';

  @override
  String get mapOpenGoogleMapsError => 'Impossível abrir o Google Maps';

  @override
  String get mapTilesLoadIssue =>
      'O mapa pode estar incompleto. Verifique a sua ligação.';

  @override
  String get mapFilterAll => 'Todos';

  @override
  String get mapFilterHelp => 'Ajuda';

  @override
  String get mapFilterSites => 'Locais JOJ';

  @override
  String get mapFilterHotels => 'Hotéis';

  @override
  String get mapFilterRestaurants => 'Restaurantes';

  @override
  String get mapFilterPharmacies => 'Farmácias';

  @override
  String get mapFilterHospitals => 'Hospitais';

  @override
  String get notificationsFallbackTitle => 'Notificação';

  @override
  String get jojTitle => 'Info JOJ';

  @override
  String get jojTabCalendar => 'Calendário';

  @override
  String jojTabSportsWithCount(Object count) {
    return 'Desportos ($count)';
  }

  @override
  String get jojTabAccess => 'Acesso';

  @override
  String get jojCalendarComingSoon => 'Calendário em breve';

  @override
  String get jojDefaultEventTitle => 'Evento';

  @override
  String get jojNoSportsAvailable => 'Sem desportos disponíveis';

  @override
  String get jojDefaultLocation => 'Dakar';

  @override
  String get jojDatesComingSoon => 'Datas em breve';

  @override
  String get jojSeeOnMap => 'Ver no mapa';

  @override
  String get jojDestinationFallback => 'Destino';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileNameLabel => 'Nome';

  @override
  String get profilePhoneLabel => 'Telefone';

  @override
  String get profileLanguageLabel => 'Idioma';

  @override
  String get profileUserTypeLabel => 'Tipo de utilizador';

  @override
  String get profileUserTypeVisitor => 'Visitante';

  @override
  String get profileUserTypeCitizen => 'Cidadão';

  @override
  String get profileUserTypeAthlete => 'Atleta';

  @override
  String get profileNameRequired => 'O nome é obrigatório';

  @override
  String get profileUpdated => 'Perfil atualizado';

  @override
  String get profileSave => 'Guardar';

  @override
  String get sosServicePolice => 'Polícia';

  @override
  String get sosServiceFirefighters => 'Bombeiros';

  @override
  String get sosServiceAmbulance => 'Ambulância';

  @override
  String get sosFallbackAddress => 'Dakar Plateau, 9 Rue Carnot';

  @override
  String get homeAppNamePart1 => 'Teranga ';

  @override
  String get homeAppNamePart2 => 'Pass';

  @override
  String get homeTagline => 'A sua segurança em Dakar, descobertas no Senegal';

  @override
  String get homePillarDiscoverTitle => 'Descobrir';

  @override
  String get homePillarDiscoverSubtitle => 'Sítios · Restaurantes · Hotéis';

  @override
  String get homePillarMoveTitle => 'Deslocar-se';

  @override
  String get homePillarMoveSubtitle => 'Mapa · Shuttles · Táxis';

  @override
  String get homePillarJojTitle => 'JOJ 2026';

  @override
  String get homePillarJojSubtitle => 'Calendário · Medalhas';

  @override
  String get homePillarHelpTitle => 'Ser ajudado';

  @override
  String get homePillarHelpSubtitle => 'SOS · Médico · Embaixada';

  @override
  String get homeHelpSheetTitle => 'Ser ajudado';

  @override
  String get homeHelpSheetSubtitle => 'Escolha uma ação rápida';

  @override
  String get homeHeroWelcome => 'Bem-vindo ao Senegal,';

  @override
  String get nearbyChipHotels => 'Hotéis';

  @override
  String get nearbyChipHospitals => 'Hospitais';

  @override
  String get nearbyChipClinics => 'Clínicas';

  @override
  String get nearbyChipNotaries => 'Notários';

  @override
  String get nearbyChipLawyers => 'Advogados';

  @override
  String get nearbyChipDoctors => 'Médicos';

  @override
  String get nearbyChipGovernment => 'Estado';

  @override
  String get nearbyChipSchools => 'Escolas';

  @override
  String get nearbyChipUniversities => 'Universidades';

  @override
  String get nearbyChipMedia => 'Média';

  @override
  String get nearbyChipProfessionalServices => 'Profissionais';

  @override
  String get nearbyChipReligiousSites => 'Culto';

  @override
  String get nearbyAll => 'Todos';

  @override
  String get nearbyTitle => 'Aqui perto';

  @override
  String get nearbyNearMeTooltip => 'Perto de mim';

  @override
  String nearbyRadiusLabel(int meters) {
    return 'Raio: $meters m';
  }

  @override
  String get nearbyEmpty => 'Sem lugares neste raio para esta categoria.';

  @override
  String get nearbyLocationError =>
      'A localização não está ativada. Ative-a para ver os lugares próximos.';

  @override
  String get nearbySponsorBadge => 'Parceiro';

  @override
  String get profileEsimTitle => 'Planos eSIM';

  @override
  String get profileEsimSubtitle => 'Dados de viagem (em breve)';

  @override
  String get esimComingTitle => 'eSIM Teranga Pass';

  @override
  String get esimComingBody =>
      'A integração com parceiros (ex. Airalo), os pagamentos (PayDunya, Wave) e a ativação por QR chegarão numa próxima versão. Este ecrã serve de referência para a demonstração e revisão do produto.';

  @override
  String get mapLegendTitle => 'Legenda';

  @override
  String get mapLegendYou => 'Você';

  @override
  String get mapLegendPlace => 'Lugar';

  @override
  String get mapLegendSponsor => 'Parceiro em destaque';

  @override
  String get mapLegendCategoriesHint =>
      'As cores dos marcadores no mapa indicam o tipo de lugar (filtros acima).';

  @override
  String get mapLegendJojSitesHint =>
      'Marcadores verdes: locais de competição JOJ no mapa.';

  @override
  String get profileOfflinePackTitle => 'Pack offline';

  @override
  String get profileOfflinePackBody =>
      'POI e conteúdos úteis sem rede (implementação progressiva).';

  @override
  String profileOfflinePackCatalogVersion(String version) {
    return 'Catálogo do servidor: $version';
  }

  @override
  String get profileOfflinePackCatalogPending => 'Catálogo: não sincronizado';

  @override
  String get profileOfflinePackDialogBody =>
      'Descarregue POI, locais JOJ, embaixadas, calendário e anúncios para os consultar sem rede. Em caso de interrupção, o descarregamento retoma: os ficheiros já corretos são ignorados.';

  @override
  String get profileOfflinePackDownload => 'Descarregar / atualizar';

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
      'Pack guardado no dispositivo.';

  @override
  String get profileOfflinePackDownloadPartial =>
      'Descarregamento incompleto. Tente novamente com rede.';

  @override
  String get profileOfflinePackAlreadyCurrent =>
      'Já tem a versão mais recente em local.';

  @override
  String get profileOfflinePackDownloadError =>
      'Impossível obter o manifesto. Verifique a rede.';

  @override
  String get offlineUsingCache => 'Modo offline: dados em cache.';

  @override
  String offlinePackUpdated(String version) {
    return 'Pack $version guardado no dispositivo.';
  }

  @override
  String profileOfflinePackFilesVersion(String version) {
    return 'Ficheiros locais: $version';
  }

  @override
  String get profileOfflinePackStaleFiles =>
      'Alguns ficheiros são mais antigos que o catálogo: ligue-se à rede para concluir a atualização.';

  @override
  String profileOfflinePackLocalSize(String size) {
    return 'Armazenamento local: $size';
  }

  @override
  String get incidentTrackingNavTitle => 'O meu relatório';

  @override
  String get incidentTypeLossLabel => 'Perda de objeto ou pertences pessoais';

  @override
  String get incidentTypeSuspiciousLabel => 'Comportamento suspeito';

  @override
  String get incidentTypeOtherLabel => 'Outro relatório';

  @override
  String get incidentStatusInProgress => 'Em processamento';

  @override
  String get incidentStatusProcessed => 'Processado';

  @override
  String get incidentStatusValidated => 'Validado';

  @override
  String get incidentStatusRejected => 'Rejeitado';

  @override
  String get incidentStatusPending => 'Pendente';

  @override
  String get incidentStatusCancelled => 'Cancelado';

  @override
  String get incidentTrackingEmptyTimeline =>
      'O acompanhamento será exibido assim que o seu relatório for processado.';

  @override
  String get loadingWait => 'Aguarde um momento…';

  @override
  String get homeSearchHint => 'Restaurantes, sítios, hotéis, eventos...';

  @override
  String get homeJojCountdownLabel => 'Dias até os JOJ';

  @override
  String get homeEsimConnectSubtitle => 'Ligar-se';

  @override
  String get homeNearbySubtitle => 'À minha volta';

  @override
  String get homeAudioListenSubtitle => 'Ouvir';

  @override
  String get homeMyReportsTitle => 'Os meus relatórios';

  @override
  String get homeMyReportsSubtitle => 'Acompanhar';

  @override
  String get homeCurrencyTitle => 'Conversor';
}
