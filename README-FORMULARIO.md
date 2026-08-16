# Formulario Web (Supabase + GitHub Pages)

Este directorio contiene un formulario estático (HTML/CSS/JS) que guarda datos
en **Supabase (PostgreSQL)** y se publica con **GitHub Pages**.

## Archivos
- `index.html` — formulario + listado CRUD completo.
- `comentarios.html` — ver / eliminar / exportar comentarios a Excel (CSV).
- `css/style.css` — estilos.
- `js/config.js` — `SUPABASE_URL` y `SUPABASE_ANON_KEY` (publishable key).
- `js/supabase.js` — inicialización del cliente oficial de Supabase.
- `js/app.js` — lógica del formulario (CRUD, búsqueda, paginación).
- `js/comentarios.js` — lógica de la página de comentarios.
- `sql/database.sql` — tabla `registros`, índices, trigger y políticas RLS.

## Configuración ya aplicada
- Proyecto Supabase: `ckkdkewmafkxjjmnatca` (PortafolioWPs).
- Tabla `registros` ya creada con RLS y datos de prueba insertados.
- `js/config.js` ya tiene la URL y la publishable key.

## Publicar en GitHub Pages
1. Sube estos archivos al repo (rama `main`).
2. En GitHub: **Settings → Pages → Build and deployment → Source: Deploy from a branch**.
3. Rama: `main`, carpeta: `/ (root)`.
4. Guarda y espera ~1 minuto.
5. URL: `https://RicardoRiveraSalas.github.io/PortafolioWP/`

> Nota: este repo también contiene un proyecto WordPress/Docker. GitHub Pages
> servirá `index.html` (el formulario) sin afectar a WordPress.

## Seguridad
- Solo se usa la clave **publishable/anon** (pública). Nunca la `service_role`.
- La contraseña de la base de datos NO debe ir a este repo.
- Para datos privados, activa Supabase Auth y ajusta las políticas RLS.
