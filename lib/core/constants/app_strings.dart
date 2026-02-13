/// Strings en español para Micro-Ritualist
/// Todos los textos de la UI centralizados
class AppStrings {
  AppStrings._();

  // ═══════════════════════════════════════════════════════════════
  // APP GENERAL
  // ═══════════════════════════════════════════════════════════════
  
  static const String appName = 'Micro-Ritualist';
  static const String appTagline = 'Tu momento de paz diario';

  // ═══════════════════════════════════════════════════════════════
  // GREETINGS (basados en hora del día)
  // ═══════════════════════════════════════════════════════════════
  
  static const String greetingMorning = 'Buenos días';
  static const String greetingAfternoon = 'Buenas tardes';
  static const String greetingEvening = 'Buenas noches';
  static const String greetingGeneric = 'Hola';

  // ═══════════════════════════════════════════════════════════════
  // DASHBOARD
  // ═══════════════════════════════════════════════════════════════
  
  static const String dashboardSubtitle = '¿Cómo te sientes hoy?';
  static const String dashboardRitualsTitle = 'Tus Micro-Rutinas';
  static const String dashboardEnergyTitle = 'Tu Energía';
  static const String dashboardNoRituals = 'Aún no tienes rutinas';
  static const String dashboardAddRitual = 'Añadir rutina';

  // ═══════════════════════════════════════════════════════════════
  // ENERGY TRACKER
  // ═══════════════════════════════════════════════════════════════
  
  static const String energyLow = 'Baja';
  static const String energyMedium = 'Media';
  static const String energyHigh = 'Alta';
  static const String energyStatus = 'Nivel de energía';
  static const String energyTip = 'Consejo del día';
  static const String energyTipLow = 'Tómate un momento para respirar profundamente';
  static const String energyTipMedium = 'Vas bien, mantén tu ritmo';
  static const String energyTipHigh = '¡Excelente! Aprovecha tu energía';

  // ═══════════════════════════════════════════════════════════════
  // MOOD CHECK (AI)
  // ═══════════════════════════════════════════════════════════════
  
  static const String moodInputHint = 'Cuéntame cómo te sientes...';
  static const String moodAnalyzing = 'Analizando tu estado...';
  static const String moodInputLabel = 'Tu estado de ánimo';
  static const String moodSendButton = 'Enviar';
  static const String moodAITitle = 'Asistente de Bienestar';
  static const String moodAISubtitle = 'Impulsado por IA';
  static const String moodCheckTitle = '¿Cómo te sientes?';
  static const String moodCheckSubtitle = 'Tu asistente de bienestar';
  static const String moodAnalyzeButton = 'Analizar con IA';
  static const String moodHappy = 'feliz';
  static const String moodSad = 'triste';
  static const String moodAnxious = 'ansioso';
  static const String moodTired = 'cansado';

  // ═══════════════════════════════════════════════════════════════
  // RITUAL CARDS
  // ═══════════════════════════════════════════════════════════════
  
  static const String ritualStart = 'Comenzar';
  static const String ritualPause = 'Pausar';
  static const String ritualComplete = 'Completar';
  static const String ritualCompleted = 'Completado';
  static const String ritualMinutes = 'min';
  static const String ritualProgress = 'Progreso';

  // ═══════════════════════════════════════════════════════════════
  // DEFAULT RITUALS
  // ═══════════════════════════════════════════════════════════════
  
  static const String ritualBreathingTitle = 'Respiración Consciente';
  static const String ritualBreathingDescription = 'Toma 5 respiraciones profundas para calmar tu mente';
  
  static const String ritualStretchTitle = 'Estiramiento Suave';
  static const String ritualStretchDescription = 'Estira cuello y hombros para liberar tensión';
  
  static const String ritualGratitudeTitle = 'Momento de Gratitud';
  static const String ritualGratitudeDescription = 'Piensa en 3 cosas por las que estás agradecido hoy';
  
  static const String ritualHydrationTitle = 'Hidratación';
  static const String ritualHydrationDescription = 'Bebe un vaso de agua con atención plena';
  
  static const String ritualMindfulnessTitle = 'Pausa Mindful';
  static const String ritualMindfulnessDescription = 'Observa tu entorno con todos tus sentidos';

  // ═══════════════════════════════════════════════════════════════
  // ACTIONS & BUTTONS
  // ═══════════════════════════════════════════════════════════════
  
  static const String actionCancel = 'Cancelar';
  static const String actionSave = 'Guardar';
  static const String actionDelete = 'Eliminar';
  static const String actionEdit = 'Editar';
  static const String actionDone = 'Listo';
  static const String actionSkip = 'Omitir';
  static const String actionNext = 'Siguiente';
  static const String actionBack = 'Atrás';

  // ═══════════════════════════════════════════════════════════════
  // TIME PERIODS
  // ═══════════════════════════════════════════════════════════════
  
  static const String timeToday = 'Hoy';
  static const String timeYesterday = 'Ayer';
  static const String timeThisWeek = 'Esta semana';
  static const String timeThisMonth = 'Este mes';

  // ═══════════════════════════════════════════════════════════════
  // ERROR MESSAGES
  // ═══════════════════════════════════════════════════════════════
  
  static const String errorGeneric = 'Algo salió mal. Intenta de nuevo';
  static const String errorNetwork = 'Sin conexión a internet';
  static const String errorAI = 'No pudimos analizar tu estado. Intenta más tarde';

  // ═══════════════════════════════════════════════════════════════
  // SUCCESS MESSAGES
  // ═══════════════════════════════════════════════════════════════
  
  static const String successRitualCompleted = '¡Rutina completada! 🎉';
  static const String successDailyGoal = '¡Meta diaria alcanzada!';

  // ═══════════════════════════════════════════════════════════════
  // PROFILE MENU
  // ═══════════════════════════════════════════════════════════════
  
  static const String menuEditProfile = 'Editar perfil';
  static const String menuTheme = 'TEMA';
  static const String menuThemeLight = 'Claro';
  static const String menuThemeDark = 'Oscuro';
  static const String menuThemeSystem = 'Sistema';
  static const String menuSettings = 'Configuración';
  static const String menuHistory = 'Historial';
  static const String menuHelp = 'Ayuda';
  static const String menuAbout = 'Acerca de';
  static const String menuLogout = 'Cerrar sesión';
}
