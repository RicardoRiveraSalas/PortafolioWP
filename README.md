# Formulario Web (Supabase + GitHub Pages)

Aplicación web **100% estática** (HTML/CSS/JS) que guarda datos en
**Supabase (PostgreSQL)** y se publica gratis en **GitHub Pages**. Sin backend,
sin Docker, sin PHP, sin Node como servidor.

## Estructura

```
.
├── index.html            # Formulario + listado CRUD completo
├── comentarios.html      # Ver / eliminar / exportar comentarios a Excel
├── css/
│   └── style.css
├── js/
│   ├── config.js         # SUPABASE_URL y SUPABASE_ANON_KEY (publishable key)
│   ├── supabase.js       # Inicializa el cliente oficial de Supabase
│   ├── app.js            # Lógica del formulario (CRUD, búsqueda, paginación)
│   └── comentarios.js    # Lógica de la página de comentarios
└── sql/
    └── database.sql      # Tabla registros, índices, trigger y políticas RLS
```

## Configuración ya aplicada

- Proyecto Supabase: `ckkdkewmafkxjjmnatca` (PortafolioWPs).
- Tabla `registros` ya creada con RLS y datos de prueba insertados.
- `js/config.js` ya contiene la URL y la publishable key.

## Cómo probar localmente

```bash
python3 -m http.server 8000
# abre http://localhost:8000
```

> No abras `index.html` con `file://` (el SDK de Supabase lo bloquea por CORS).
> Usa siempre un servidor local.

## Publicar en GitHub Pages

1. Sube estos archivos al repositorio (rama `main`).
2. GitHub: **Settings → Pages → Build and deployment → Source: Deploy from a branch**.
3. Rama: `main`, carpeta: `/ (root)`.
4. Guarda y espera ~1 minuto.
5. URL: `https://RicardoRiveraSalas.github.io/PortafolioWP/`

## Seguridad

- Solo se usa la clave **publishable/anon** (pública por diseño). Nunca la
  `service_role`.
- La contraseña de la base de datos **no** debe ir a este repo.
- Para datos privados, activa Supabase Auth y ajusta las políticas RLS en
  `sql/database.sql`.

## SQL de la base de datos

El archivo `sql/database.sql` crea la tabla `registros`, los índices, el trigger
que actualiza `updated_at` automáticamente y las políticas RLS. Ejecútalo en el
SQL Editor de Supabase (ya aplicado en este proyecto).
