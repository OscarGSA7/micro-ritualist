-- ============================================================================
-- MICRO-RITUALIST - Schema de Base de Datos para Supabase
-- ============================================================================
-- ID del proyecto: gvvoqkmrzkeemwgwjxhj
-- 
-- INSTRUCCIONES:
-- 1. Ve a tu proyecto en Supabase: https://supabase.com/dashboard/project/gvvoqkmrzkeemwgwjxhj
-- 2. Ve a "SQL Editor" en el menú lateral
-- 3. Copia y pega todo este script
-- 4. Haz clic en "Run" para ejecutarlo
-- ============================================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLA: profiles
-- Información adicional del usuario (extiende auth.users de Supabase)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL DEFAULT '',
    email TEXT NOT NULL DEFAULT '',
    avatar_url TEXT,
    timezone TEXT DEFAULT 'America/Mexico_City',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- TABLA: user_settings
-- Configuraciones personalizadas del usuario
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.user_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    -- Notificaciones
    notifications_enabled BOOLEAN DEFAULT TRUE,
    daily_reminder_time TIME DEFAULT '08:00:00',
    reminder_days INTEGER[] DEFAULT ARRAY[1,2,3,4,5,6,7], -- 1=Lun, 7=Dom
    -- Tema
    theme_mode TEXT DEFAULT 'system' CHECK (theme_mode IN ('light', 'dark', 'system')),
    -- Preferencias de ritual
    default_ritual_duration INTEGER DEFAULT 3,
    sound_enabled BOOLEAN DEFAULT TRUE,
    haptic_feedback BOOLEAN DEFAULT TRUE,
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(user_id)
);

CREATE TRIGGER update_user_settings_updated_at
    BEFORE UPDATE ON public.user_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- TABLA: rituals
-- Rituales/hábitos personalizados del usuario
-- ============================================================================
CREATE TYPE ritual_category AS ENUM (
    'breathing',
    'movement', 
    'mindfulness',
    'hydration',
    'gratitude',
    'custom'
);

CREATE TABLE IF NOT EXISTS public.rituals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    duration_minutes INTEGER NOT NULL DEFAULT 3 CHECK (duration_minutes >= 1 AND duration_minutes <= 60),
    category ritual_category DEFAULT 'custom',
    -- Personalización visual
    icon_name TEXT DEFAULT 'self_improvement_rounded',
    color_hex TEXT DEFAULT '#6366F1', -- Color en hex
    -- Configuración de repetición
    is_active BOOLEAN DEFAULT TRUE,
    repeat_days INTEGER[] DEFAULT ARRAY[1,2,3,4,5,6,7], -- Días de la semana
    preferred_time TIME, -- Hora preferida (opcional)
    -- Metadata
    is_default BOOLEAN DEFAULT FALSE, -- Si es un ritual predefinido
    sort_order INTEGER DEFAULT 0,
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_rituals_user_id ON public.rituals(user_id);
CREATE INDEX idx_rituals_category ON public.rituals(category);
CREATE INDEX idx_rituals_is_active ON public.rituals(is_active);

CREATE TRIGGER update_rituals_updated_at
    BEFORE UPDATE ON public.rituals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- TABLA: ritual_completions
-- Registro de cada vez que el usuario completa un ritual
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.ritual_completions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    ritual_id UUID NOT NULL REFERENCES public.rituals(id) ON DELETE CASCADE,
    -- Datos de la completación
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    duration_seconds INTEGER, -- Duración real (puede diferir del esperado)
    -- Evaluación post-ritual (opcional)
    mood_before TEXT CHECK (mood_before IN ('bad', 'okay', 'good', 'great')),
    mood_after TEXT CHECK (mood_after IN ('bad', 'okay', 'good', 'great')),
    notes TEXT,
    -- Metadata
    completed_date DATE GENERATED ALWAYS AS (DATE(completed_at AT TIME ZONE 'UTC')) STORED
);

CREATE INDEX idx_completions_user_id ON public.ritual_completions(user_id);
CREATE INDEX idx_completions_ritual_id ON public.ritual_completions(ritual_id);
CREATE INDEX idx_completions_completed_date ON public.ritual_completions(completed_date);
CREATE INDEX idx_completions_user_date ON public.ritual_completions(user_id, completed_date);

-- ============================================================================
-- TABLA: streaks
-- Rachas calculadas para cada ritual (se actualiza con triggers)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.streaks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    ritual_id UUID NOT NULL REFERENCES public.rituals(id) ON DELETE CASCADE,
    -- Racha actual
    current_streak INTEGER DEFAULT 0 NOT NULL,
    longest_streak INTEGER DEFAULT 0 NOT NULL,
    -- Fechas importantes
    last_completed_date DATE,
    streak_started_at DATE,
    -- Timestamps
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(user_id, ritual_id)
);

CREATE INDEX idx_streaks_user_id ON public.streaks(user_id);
CREATE INDEX idx_streaks_ritual_id ON public.streaks(ritual_id);

-- ============================================================================
-- TABLA: wellness_assessments
-- Evaluaciones de bienestar del usuario
-- ============================================================================
CREATE TYPE emotional_state AS ENUM (
    'excited', 'happy', 'grateful',
    'calm', 'relaxed', 'peaceful',
    'anxious', 'stressed', 'frustrated', 'angry',
    'sad', 'tired', 'bored', 'lonely',
    'neutral'
);

CREATE TYPE energy_level AS ENUM (
    'very_low', 'low', 'moderate', 'high', 'very_high'
);

CREATE TYPE sleep_quality AS ENUM (
    'terrible', 'poor', 'fair', 'good', 'excellent'
);

CREATE TABLE IF NOT EXISTS public.wellness_assessments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    -- Estado del usuario
    emotional_state emotional_state NOT NULL,
    energy_level energy_level NOT NULL,
    sleep_quality sleep_quality NOT NULL,
    sleep_hours NUMERIC(3,1), -- Horas de sueño
    -- Factores adicionales
    stress_factors TEXT[], -- Array de factores de estrés
    -- Puntaje calculado
    wellness_score INTEGER CHECK (wellness_score >= 0 AND wellness_score <= 100),
    -- Notas
    notes TEXT,
    -- Timestamps
    assessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    assessed_date DATE GENERATED ALWAYS AS (DATE(assessed_at AT TIME ZONE 'UTC')) STORED
);

CREATE INDEX idx_wellness_user_id ON public.wellness_assessments(user_id);
CREATE INDEX idx_wellness_assessed_date ON public.wellness_assessments(assessed_date);

-- ============================================================================
-- TABLA: daily_summary
-- Resumen diario del progreso del usuario
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.daily_summaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    summary_date DATE NOT NULL,
    -- Estadísticas diarias
    rituals_completed INTEGER DEFAULT 0,
    total_rituals INTEGER DEFAULT 0,
    total_minutes INTEGER DEFAULT 0,
    completion_rate NUMERIC(5,2) DEFAULT 0, -- Porcentaje
    -- Wellness
    average_mood_score NUMERIC(5,2),
    wellness_score INTEGER,
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(user_id, summary_date)
);

CREATE INDEX idx_daily_summary_user_date ON public.daily_summaries(user_id, summary_date);

CREATE TRIGGER update_daily_summaries_updated_at
    BEFORE UPDATE ON public.daily_summaries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FUNCIONES: Actualizar rachas automáticamente
-- ============================================================================
CREATE OR REPLACE FUNCTION update_streak_on_completion()
RETURNS TRIGGER AS $$
DECLARE
    v_last_date DATE;
    v_current_streak INTEGER;
    v_longest_streak INTEGER;
    v_streak_start DATE;
BEGIN
    -- Obtener el streak actual
    SELECT last_completed_date, current_streak, longest_streak, streak_started_at
    INTO v_last_date, v_current_streak, v_longest_streak, v_streak_start
    FROM public.streaks
    WHERE user_id = NEW.user_id AND ritual_id = NEW.ritual_id;
    
    IF NOT FOUND THEN
        -- Crear nuevo streak
        INSERT INTO public.streaks (user_id, ritual_id, current_streak, longest_streak, last_completed_date, streak_started_at)
        VALUES (NEW.user_id, NEW.ritual_id, 1, 1, NEW.completed_date, NEW.completed_date);
    ELSE
        -- Verificar si es el mismo día (no incrementar)
        IF v_last_date = NEW.completed_date THEN
            -- Ya se completó hoy, no hacer nada
            RETURN NEW;
        -- Verificar si es el día siguiente (continuar racha)
        ELSIF v_last_date = NEW.completed_date - INTERVAL '1 day' THEN
            v_current_streak := v_current_streak + 1;
            IF v_current_streak > v_longest_streak THEN
                v_longest_streak := v_current_streak;
            END IF;
        -- Si pasó más de un día (reiniciar racha)
        ELSE
            v_current_streak := 1;
            v_streak_start := NEW.completed_date;
        END IF;
        
        UPDATE public.streaks
        SET current_streak = v_current_streak,
            longest_streak = v_longest_streak,
            last_completed_date = NEW.completed_date,
            streak_started_at = v_streak_start,
            updated_at = NOW()
        WHERE user_id = NEW.user_id AND ritual_id = NEW.ritual_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_streak
    AFTER INSERT ON public.ritual_completions
    FOR EACH ROW
    EXECUTE FUNCTION update_streak_on_completion();

-- ============================================================================
-- FUNCIÓN: Crear perfil automáticamente cuando se registra un usuario
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Crear perfil
    INSERT INTO public.profiles (id, name, email)
    VALUES (
        NEW.id, 
        COALESCE(NEW.raw_user_meta_data->>'name', SPLIT_PART(NEW.email, '@', 1)),
        NEW.email
    );
    
    -- Crear configuración por defecto
    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id);
    
    -- Las cuentas nuevas empiezan sin rituales predefinidos
    -- El usuario puede crear sus propios rituales desde la app
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para cuando se crea un nuevo usuario
CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) - Seguridad a nivel de fila
-- ============================================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rituals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ritual_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wellness_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_summaries ENABLE ROW LEVEL SECURITY;

-- Políticas para profiles
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Políticas para user_settings
CREATE POLICY "Users can view own settings" ON public.user_settings
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own settings" ON public.user_settings
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own settings" ON public.user_settings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para rituals
CREATE POLICY "Users can view own rituals" ON public.rituals
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own rituals" ON public.rituals
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own rituals" ON public.rituals
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own rituals" ON public.rituals
    FOR DELETE USING (auth.uid() = user_id);

-- Políticas para ritual_completions
CREATE POLICY "Users can view own completions" ON public.ritual_completions
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own completions" ON public.ritual_completions
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own completions" ON public.ritual_completions
    FOR DELETE USING (auth.uid() = user_id);

-- Políticas para streaks
CREATE POLICY "Users can view own streaks" ON public.streaks
    FOR SELECT USING (auth.uid() = user_id);

-- Políticas para wellness_assessments
CREATE POLICY "Users can view own assessments" ON public.wellness_assessments
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own assessments" ON public.wellness_assessments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para daily_summaries
CREATE POLICY "Users can view own summaries" ON public.daily_summaries
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own summaries" ON public.daily_summaries
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own summaries" ON public.daily_summaries
    FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================================
-- VIEWS: Vistas útiles para consultas comunes
-- ============================================================================

-- Vista de estadísticas de usuario
CREATE OR REPLACE VIEW public.user_stats AS
SELECT 
    u.id AS user_id,
    p.name,
    COUNT(DISTINCT r.id) AS total_rituals,
    COUNT(DISTINCT rc.id) AS total_completions,
    COALESCE(SUM(rc.duration_seconds) / 60, 0) AS total_minutes,
    MAX(s.current_streak) AS best_current_streak,
    MAX(s.longest_streak) AS best_all_time_streak,
    COUNT(DISTINCT rc.completed_date) AS active_days
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
LEFT JOIN public.rituals r ON r.user_id = u.id
LEFT JOIN public.ritual_completions rc ON rc.user_id = u.id
LEFT JOIN public.streaks s ON s.user_id = u.id
GROUP BY u.id, p.name;

-- ============================================================================
-- ÍNDICES ADICIONALES para mejor rendimiento
-- ============================================================================

-- Índice compuesto para consultas de completaciones por usuario y fecha
CREATE INDEX IF NOT EXISTS idx_completions_user_ritual_date 
    ON public.ritual_completions(user_id, ritual_id, completed_date);

-- ============================================================================
-- ¡LISTO! Tu base de datos está configurada correctamente
-- ============================================================================
-- 
-- Ahora necesitas configurar tu proyecto Flutter con las credenciales:
-- URL: https://gvvoqkmrzkeemwgwjxhj.supabase.co
-- Anon Key: [Ve a Settings > API en tu dashboard de Supabase]
-- ============================================================================
