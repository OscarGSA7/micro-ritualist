# Configuración de Supabase para Micro-Ritualist

## Paso 1: Configurar la Base de Datos

1. Ve al dashboard de tu proyecto: https://supabase.com/dashboard/project/gvvoqkmrzkeemwgwjxhj

2. En el menú lateral, haz clic en **"SQL Editor"**

3. Copia **TODO** el contenido del archivo `supabase/schema.sql`

4. Pégalo en el editor SQL y haz clic en **"Run"**

5. Deberías ver mensajes de éxito para cada tabla creada

## Paso 2: Obtener tu API Key

1. En el dashboard de Supabase, ve a **Settings** (ícono de engranaje)

2. Haz clic en **"API"** en el submenú

3. En la sección **"Project API keys"**, copia el valor de **"anon public"**
   - Es una cadena larga que empieza con `eyJ...`

## Paso 3: Configurar Flutter

1. Abre el archivo `lib/core/config/supabase_config.dart`

2. Reemplaza `'YOUR_ANON_KEY'` con tu anon key:

```dart
static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // tu key real
```

## Paso 4: Configurar Autenticación (Opcional pero recomendado)

### Habilitar Email/Password
1. Ve a **Authentication** > **Providers**
2. Asegúrate de que **Email** esté habilitado

### Habilitar Google Sign-In
1. Ve a **Authentication** > **Providers** > **Google**
2. Habilita Google
3. Necesitas crear credenciales OAuth en Google Cloud Console:
   - Ve a https://console.cloud.google.com/
   - Crea un proyecto o usa uno existente
   - Ve a APIs & Services > Credentials
   - Crea OAuth 2.0 Client ID (Tipo: Web application)
   - Añade el redirect URI: `https://gvvoqkmrzkeemwgwjxhj.supabase.co/auth/v1/callback`
   - Copia Client ID y Client Secret a Supabase

### Configurar Deep Links (Para OAuth en móviles)
Para Android, añade esto a `android/app/src/main/AndroidManifest.xml` dentro del `<activity>`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.supabase.microritualist" android:host="login-callback" />
</intent-filter>
```

## Paso 5: Desactivar Confirmación de Email (Para desarrollo)

Por defecto, Supabase requiere que los usuarios confirmen su email. Para desarrollo, puedes desactivarlo:

1. Ve a **Authentication** > **Providers** > **Email**
2. Desactiva **"Confirm email"**

## Estructura de la Base de Datos

### Tablas creadas:
- **profiles**: Información del usuario
- **user_settings**: Configuraciones personalizadas
- **rituals**: Hábitos/rituales del usuario
- **ritual_completions**: Registro de completaciones
- **streaks**: Rachas de cada ritual (se actualiza automáticamente)
- **wellness_assessments**: Evaluaciones de bienestar
- **daily_summaries**: Resumen diario

### Características automáticas:
- ✅ Creación automática de perfil al registrarse
- ✅ Rituales predefinidos para nuevos usuarios
- ✅ Actualización automática de rachas al completar rituales
- ✅ Row Level Security (cada usuario solo ve sus datos)

## Verificar que todo funciona

1. Ejecuta la app: `flutter run`
2. Regístrate con un email/contraseña
3. Deberías ver los 5 rituales predefinidos
4. Completa un ritual y verifica que aparece la racha

## Solución de Problemas

### "Supabase no está configurado"
- Verifica que pusiste la anon key correctamente
- Asegúrate de que no haya espacios antes o después de la key

### Error al registrarse
- Verifica que corriste el script SQL completo
- Revisa los logs en Supabase > Database > Logs

### No aparecen los rituales
- Verifica que el trigger `on_auth_user_created` se creó correctamente
- Puedes revisar en Table Editor > rituals si hay datos

## URL de tu proyecto
- **Dashboard**: https://supabase.com/dashboard/project/gvvoqkmrzkeemwgwjxhj
- **API URL**: https://gvvoqkmrzkeemwgwjxhj.supabase.co
