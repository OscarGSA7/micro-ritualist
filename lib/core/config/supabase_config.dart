/// Configuración de Supabase para Micro-Ritualist
/// 
/// IMPORTANTE: Reemplaza 'YOUR_ANON_KEY' con tu anon key de Supabase
/// La puedes encontrar en: https://supabase.com/dashboard/project/gvvoqkmrzkeemwgwjxhj/settings/api
library;

class SupabaseConfig {
  /// URL del proyecto de Supabase
  static const String url = 'https://gvvoqkmrzkeemwgwjxhj.supabase.co';
  
  /// Anon Key (clave pública)
  /// ⚠️ REEMPLAZA ESTO con tu clave real de Supabase
  /// Ve a Settings > API > Project API keys > anon public
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2dm9xa21yemtlZW13Z3dqeGhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEyNzE2NTcsImV4cCI6MjA4Njg0NzY1N30.OAma_bex7Y0LeI4jw4EN98i3-FoxFKMb5ZPh1yXyUEU';
  
  /// Verificar si la configuración es válida
  /// La key es válida si no es el placeholder 'YOUR_ANON_KEY' y no está vacía
  static bool get isConfigured => 
      anonKey != 'YOUR_ANON_KEY' && 
      anonKey.isNotEmpty && 
      anonKey.startsWith('eyJ');  // JWT tokens empiezan con eyJ
}
