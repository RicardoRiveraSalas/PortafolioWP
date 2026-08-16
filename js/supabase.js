// ============================================================================
//  js/supabase.js
//  Inicialización del cliente oficial de Supabase para JavaScript.
//
//  Usa la configuración definida en config.js (SUPABASE_URL, SUPABASE_ANON_KEY).
//  Carga el SDK desde un CDN (funciona en sitios estáticos / GitHub Pages).
// ============================================================================

// Importamos el cliente desde el CDN oficial de Supabase (UMD build).
// Se expone como window.supabase.
// Nota: el <script> del SDK debe cargarse ANTES que este archivo en index.html.

let supabaseClient = null;

function initSupabase() {
    if (typeof window.supabase === "undefined") {
        throw new Error(
            "El SDK de Supabase no se cargó. Verifica el <script> en index.html."
        );
    }

    if (
        !SUPABASE_URL ||
        SUPABASE_URL === "TU_SUPABASE_URL" ||
        !SUPABASE_ANON_KEY ||
        SUPABASE_ANON_KEY === "TU_SUPABASE_ANON_KEY"
    ) {
        throw new Error(
            "Falta configurar SUPABASE_URL y SUPABASE_ANON_KEY en js/config.js"
        );
    }

    // createClient(url, anonKey) — usa SOLO la clave pública.
    supabaseClient = window.supabase.createClient(
        SUPABASE_URL,
        SUPABASE_ANON_KEY
    );

    return supabaseClient;
}

function getSupabase() {
    if (!supabaseClient) {
        initSupabase();
    }
    return supabaseClient;
}
