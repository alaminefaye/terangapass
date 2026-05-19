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
  String get profileDeleteAccount => 'Delete my account';

  @override
  String get profileDeleteAccountTitle => 'Delete account';

  @override
  String get profileDeleteAccountBody =>
      'Esta ação é irreversível. Os seus alertas, relatórios e dados associados serão eliminados permanentemente. Para confirmar, digite exatamente o seguinte código no campo:';

  @override
  String get profileDeleteAccountCodeLabel => 'Código de confirmação';

  @override
  String get profileDeleteAccountCodeHint => 'teranga pass';

  @override
  String get profileDeleteAccountCodeFieldHint => 'Digite o código aqui';

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
  String get mapFilterBanks => 'Banks';

  @override
  String get mapFilterGasStations => 'Gas stations';

  @override
  String get mapFilterShops => 'Shops';

  @override
  String get mapFilterConsulates => 'Consulates';

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
  String get profileThemeSetting => 'Aparência';

  @override
  String get profileThemeSettingHint =>
      'Escolha modo claro, escuro ou automático.';

  @override
  String get profileThemeSystem => 'Automático (sistema)';

  @override
  String get profileThemeLight => 'Modo claro';

  @override
  String get profileThemeDark => 'Modo escuro';

  @override
  String get profileEsimTitle => 'Planos eSIM';

  @override
  String get profileEsimSubtitle => 'Em breve';

  @override
  String get esimComingBadge => 'Em breve';

  @override
  String get esimComingTitle => 'Planos eSIM';

  @override
  String get esimComingBody =>
      'A compra de pacotes de internet para as suas viagens no Senegal estará disponível em breve na Teranga Pass.\n\nObrigado pela sua paciência.';

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
  String get homeJojOlympicSubtitle => 'JOGOS OLÍMPICOS DA JUVENTUDE';

  @override
  String get homeJojCityLine => 'Dakar 2026';

  @override
  String get homeJojDateRange => '31 de outubro -> 13 de novembro';

  @override
  String get homeEsimConnectSubtitle => 'Em breve';

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
      'Pode continuar a explorar o turismo e os locais recomendados sem conta.';

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
