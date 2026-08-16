// ============================================================================
//  js/config.js
//  Configuración de Supabase.
//
//  ⚠️  IMPORTANTE: NO coloques aquí la "service_role key".
//      Usa ÚNICAMENTE la clave pública "anon" (anon key).
//      La service_role key es secreta y NUNCA debe ir al frontend.
//
//  Sustituye los valores de abajo por los de tu proyecto Supabase:
//    SUPABASE_URL     -> Project URL      (ej. https://xxxx.supabase.co)
//    SUPABASE_ANON_KEY-> Project API keys -> anon public
// ============================================================================

const SUPABASE_URL = "https://ckkdkewmafkxjjmnatca.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_y4tH8TCX9feLK-oBzj3ETw_vn03Y_q8";

// Nombre de la tabla (debe coincidir con sql/database.sql).
const SUPABASE_TABLA = "registros";

// ¿Cuántos registros se cargan por página? (paginación)
const REGISTROS_POR_PAGINA = 10;
