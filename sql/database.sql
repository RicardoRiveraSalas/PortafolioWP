-- ============================================================================
--  Base de datos: registros (Supabase / PostgreSQL)
--  Proyecto: Formulario web estático + Supabase
-- ============================================================================
--
--  INSTRUCCIONES:
--  1. Abre el "SQL Editor" en tu proyecto de Supabase.
--  2. Pega este archivo completo.
--  3. Pulsa "Run" (ejecutar).
--
--  Este script es idempotente en la medida de lo posible (usa IF NOT EXISTS /
--  CREATE OR REPLACE) para poder ejecutarlo varias veces sin errores.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. TABLA PRINCIPAL: registros
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.registros (
    id          uuid            PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre      text            NOT NULL,
    telefono    text,
    email       text,
    direccion   text,
    estado      text,
    comentarios text,
    created_at  timestamptz     NOT NULL DEFAULT now(),
    updated_at  timestamptz     NOT NULL DEFAULT now()
);

-- Comentarios de columnas (opcional, útil para documentación en el catalogo)
COMMENT ON TABLE  public.registros IS 'Registros del formulario web público.';
COMMENT ON COLUMN public.registros.nombre      IS 'Nombre de la persona (obligatorio).';
COMMENT ON COLUMN public.registros.telefono    IS 'Teléfono de contacto.';
COMMENT ON COLUMN public.registros.email       IS 'Correo electrónico.';
COMMENT ON COLUMN public.registros.direccion   IS 'Dirección física.';
COMMENT ON COLUMN public.registros.estado      IS 'Estado / situación del registro.';
COMMENT ON COLUMN public.registros.comentarios IS 'Comentarios libres.';
COMMENT ON COLUMN public.registros.created_at  IS 'Fecha de creación.';
COMMENT ON COLUMN public.registros.updated_at  IS 'Fecha de última modificación.';

-- ----------------------------------------------------------------------------
-- 2. ÍNDICES (mejoran las búsquedas y el ordenamiento)
-- ----------------------------------------------------------------------------
-- Ordenar por fecha de creación (más recientes primero) es la consulta base.
CREATE INDEX IF NOT EXISTS idx_registros_created_at
    ON public.registros (created_at DESC);

-- Búsquedas frecuentes por nombre, teléfono y correo.
CREATE INDEX IF NOT EXISTS idx_registros_nombre
    ON public.registros (lower(nombre));

CREATE INDEX IF NOT EXISTS idx_registros_telefono
    ON public.registros (telefono);

CREATE INDEX IF NOT EXISTS idx_registros_email
    ON public.registros (lower(email));

-- Búsqueda de texto en varias columnas (trigrams) para el buscador general.
-- Requiere la extensión pg_trgm (disponible en Supabase).
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX IF NOT EXISTS idx_registros_busqueda
    ON public.registros USING gin (
        (lower(coalesce(nombre, '') || ' ' ||
               coalesce(telefono, '') || ' ' ||
               coalesce(email, ''))) gin_trgm_ops
    );

-- ----------------------------------------------------------------------------
-- 3. TRIGGER: actualizar automáticamente updated_at
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_registros_updated_at ON public.registros;

CREATE TRIGGER trg_registros_updated_at
    BEFORE UPDATE ON public.registros
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

-- ----------------------------------------------------------------------------
-- 4. ROW LEVEL SECURITY (RLS)
-- ----------------------------------------------------------------------------
-- Activamos RLS. Sin políticas, nadie (ni siquiera con la anon key) podría
-- acceder. Las políticas definen QUÉ puede hacer el rol "anon"/"authenticated".
ALTER TABLE public.registros ENABLE ROW LEVEL SECURITY;

-- Función auxiliar para borrar políticas previas (idempotencia).
DO $$
BEGIN
    DROP POLICY IF EXISTS registros_anon_insert ON public.registros;
    DROP POLICY IF EXISTS registros_anon_select ON public.registros;
    DROP POLICY IF EXISTS registros_anon_update ON public.registros;
    DROP POLICY IF EXISTS registros_anon_delete ON public.registros;
END $$;

-- ----------------------------------------------------------------------------
-- IMPORTANTE SOBRE SEGURIDAD (LEER ANTES DE PUBLICAR)
-- ----------------------------------------------------------------------------
-- Las políticas de abajo permiten acceso PÚBLICO (rol anon) a TODOS los
-- registros. Esto es necesario para que un sitio estático en GitHub Pages
-- pueda hacer CRUD sin iniciar sesión.
--
-- CONSECUENCIAS:
--   * Cualquier persona en internet podrá CREAR, LEER, EDITAR y BORRAR
--     registros usando la anon key (que es pública por definición).
--   * Los datos serán visibles por cualquiera.
--
-- ESTO ES ACEPTABLE SOLO SI:
--   * El formulario es de tipo "registro público / contacto" y no contiene
--     información sensible.
--
-- SI NECESITAS PROTEGER LOS DATOS:
--   * Implementa Supabase Auth (ver README.md sección "Protección con Auth").
--   * Cambia estas políticas para que usen: auth.uid() IS NOT NULL
--     (solo usuarios logueados) o auth.uid() = user_id (por registro).
--   * NUNCA coloques la service_role key en el frontend.
-- ----------------------------------------------------------------------------

-- Política: INSERT (cualquiera puede crear registros)
CREATE POLICY registros_anon_insert ON public.registros
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

-- Política: SELECT (cualquiera puede leer registros)
CREATE POLICY registros_anon_select ON public.registros
    FOR SELECT
    TO anon, authenticated
    USING (true);

-- Política: UPDATE (cualquiera puede editar registros)
CREATE POLICY registros_anon_update ON public.registros
    FOR UPDATE
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

-- Política: DELETE (cualquiera puede eliminar registros)
CREATE POLICY registros_anon_delete ON public.registros
    FOR DELETE
    TO anon, authenticated
    USING (true);
