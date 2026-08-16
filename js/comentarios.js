// ============================================================================
//  js/comentarios.js
//  Página de gestión de comentarios: ver, eliminar y exportar a Excel (CSV).
//
//  Reutiliza config.js (SUPABASE_URL / SUPABASE_ANON_KEY) y supabase.js.
//
//  SEGURIDAD:
//   - Usa SOLO la clave anon (pública). Nunca la service_role.
//   - Todas las operaciones pasan por las políticas RLS de Supabase.
//   - Se validan los datos de entrada y los registros recibidos.
// ============================================================================

const estadoCom = {
    paginaActual: 1,
    terminoBusqueda: "",
    seleccionados: new Set(),   // ids marcados con checkbox
    cacheDatos: [],             // datos de la página actual
};

const elC = {};

const COLUMNAS = ["id", "nombre", "email", "comentarios", "created_at"];

// ----------------------------------------------------------------------------
//  Inicialización
// ----------------------------------------------------------------------------
document.addEventListener("DOMContentLoaded", async () => {
    elC.tablaBody = document.getElementById("tabla-body");
    elC.buscador = document.getElementById("buscador");
    elC.btnExportar = document.getElementById("btn-exportar");
    elC.btnEliminarTodos = document.getElementById("btn-eliminar-todos");
    elC.checkTodos = document.getElementById("check-todos");
    elC.paginacion = document.getElementById("paginacion");
    elC.contador = document.getElementById("contador-registros");
    elC.mensajes = document.getElementById("mensajes");
    elC.spinner = document.getElementById("spinner");
    elC.sinRegistros = document.getElementById("sin-registros");

    try {
        getSupabase();
    } catch (err) {
        mostrarMensaje("error", err.message);
        return;
    }

    elC.buscador.addEventListener("input", alBuscarCom);
    elC.btnExportar.addEventListener("click", exportarExcel);
    elC.btnEliminarTodos.addEventListener("click", eliminarSeleccionados);
    elC.checkTodos.addEventListener("change", toggleTodos);

    await cargarComentarios();
});

// ----------------------------------------------------------------------------
//  VALIDACIÓN
// ----------------------------------------------------------------------------
// Valida que un registro tenga la forma esperada antes de usarlo (render/export).
// Esto protege la UI de datos corruptos o inesperados devueltos por la API.
function validarRegistro(r) {
    if (!r || typeof r !== "object") return false;
    if (typeof r.id !== "string" && typeof r.id !== "number") return false;
    // nombre puede venir vacío desde la BD, pero debe existir la clave.
    if (!("nombre" in r)) return false;
    if (!("comentarios" in r)) return false;
    return true;
}

// Valida el término de búsqueda (longitud razonable, sin inyección de patrones).
function validarTermino(texto) {
    const t = (texto || "").toString().trim();
    if (t.length > 100) return { ok: false, msg: "Búsqueda demasiado larga." };
    return { ok: true, valor: t };
}

// ----------------------------------------------------------------------------
//  READ
// ----------------------------------------------------------------------------
async function obtenerComentarios(pagina = 1, termino = "") {
    const sb = getSupabase();
    const desde = (pagina - 1) * REGISTROS_POR_PAGINA;
    const hasta = desde + REGISTROS_POR_PAGINA - 1;

    let query = sb
        .from(SUPABASE_TABLA)
        .select("id, nombre, email, comentarios, created_at", {
            count: "exact",
        })
        .order("created_at", { ascending: false })
        .range(desde, hasta);

    if (termino) {
        const t = `%${termino}%`;
        query = query.or(
            `comentarios.ilike.${t},nombre.ilike.${t},email.ilike.${t}`
        );
    }

    const { data, error, count } = await query;
    if (error) throw error;

    // Validar y filtrar registros no conformes.
    const limpios = (data || []).filter(validarRegistro);
    return { data: limpios, total: count || 0 };
}

async function cargarComentarios() {
    try {
        mostrarSpinner(true);
        const { data, total } = await obtenerComentarios(
            estadoCom.paginaActual,
            estadoCom.terminoBusqueda
        );
        estadoCom.cacheDatos = data;
        estadoCom.seleccionados.clear();
        sincronizarCheckTodos();
        renderTablaCom(data);
        renderPaginacionCom(total);
        actualizarContadorCom(total);
    } catch (err) {
        console.error(err);
        mostrarMensaje("error", "No se pudieron cargar los comentarios");
    } finally {
        mostrarSpinner(false);
    }
}

// ----------------------------------------------------------------------------
//  DELETE (individual y múltiple)
// ----------------------------------------------------------------------------
async function eliminarRegistroCom(id) {
    const sb = getSupabase();
    const { error } = await sb
        .from(SUPABASE_TABLA)
        .delete()
        .eq("id", id);
    if (error) throw error;
}

async function confirmarEliminarCom(id) {
    const ok = window.confirm(
        "¿Está seguro de que desea eliminar este registro?"
    );
    if (!ok) return;
    await ejecutarEliminacion([id]);
}

async function eliminarSeleccionados() {
    const ids = Array.from(estadoCom.seleccionados);
    if (ids.length === 0) {
        mostrarMensaje("error", "Seleccione al menos un registro para eliminar.");
        return;
    }
    const ok = window.confirm(
        `¿Eliminar ${ids.length} registro(s) seleccionado(s)?`
    );
    if (!ok) return;
    await ejecutarEliminacion(ids);
}

async function ejecutarEliminacion(ids) {
    try {
        deshabilitarBotonesCom(true);
        mostrarSpinner(true);

        // Eliminación por lotes usando in().
        const sb = getSupabase();
        const { error } = await sb
            .from(SUPABASE_TABLA)
            .delete()
            .in("id", ids);

        if (error) throw error;

        mostrarMensaje(
            "exito",
            ids.length === 1
                ? "Registro eliminado correctamente"
                : `Registros eliminados correctamente (${ids.length})`
        );
        estadoCom.paginaActual = 1;
        await cargarComentarios();
    } catch (err) {
        console.error(err);
        mostrarMensaje("error", "No se pudo eliminar el registro");
    } finally {
        deshabilitarBotonesCom(false);
        mostrarSpinner(false);
    }
}

// ----------------------------------------------------------------------------
//  EXPORTAR A EXCEL (CSV con BOM para Excel)
// ----------------------------------------------------------------------------
async function exportarExcel() {
    try {
        deshabilitarBotonesCom(true);
        mostrarSpinner(true);

        // Obtenemos TODOS los comentarios que coincidan con la búsqueda
        // (sin paginación) para exportar el conjunto completo.
        const { data } = await obtenerTodosParaExportar(
            estadoCom.terminoBusqueda
        );

        if (!data || data.length === 0) {
            mostrarMensaje("error", "No hay datos para exportar.");
            return;
        }

        const csv = generarCSV(data);
        descargarArchivo(csv, nombreArchivoExport());

        mostrarMensaje("exito", "Exportación completada");
    } catch (err) {
        console.error(err);
        mostrarMensaje("error", "No se pudo exportar el archivo");
    } finally {
        deshabilitarBotonesCom(false);
        mostrarSpinner(false);
    }
}

async function obtenerTodosParaExportar(termino) {
    const sb = getSupabase();
    let query = sb
        .from(SUPABASE_TABLA)
        .select("id, nombre, email, comentarios, created_at")
        .order("created_at", { ascending: false });

    if (termino) {
        const t = `%${termino}%`;
        query = query.or(
            `comentarios.ilike.${t},nombre.ilike.${t},email.ilike.${t}`
        );
    }

    // Paginar internamente para no traer de golpe millones de filas.
    let todos = [];
    let desde = 0;
    const paso = 1000;
    while (true) {
        const { data, error } = await query.range(desde, desde + paso - 1);
        if (error) throw error;
        if (!data || data.length === 0) break;
        todos = todos.concat(data.filter(validarRegistro));
        if (data.length < paso) break;
        desde += paso;
    }
    return { data: todos };
}

// Escapa campos CSV y los encierra en comillas dobles cuando es necesario.
function escaparCSV(valor) {
    if (valor === null || valor === undefined) return "";
    const s = String(valor);
    if (/[",\n;\r]/.test(s)) {
        return '"' + s.replace(/"/g, '""') + '"';
    }
    return s;
}

function generarCSV(datos) {
    const encabezados = [
        "ID",
        "Nombre",
        "Correo",
        "Comentario",
        "Fecha",
    ];
    const filas = datos.map((r) => [
        r.id,
        r.nombre || "",
        r.email || "",
        r.comentarios || "",
        r.created_at || "",
    ]);

    const lineas = [encabezados, ...filas].map((fila) =>
        fila.map(escaparCSV).join(",")
    );

    // BOM para que Excel interprete UTF-8 (acentos, ñ, etc.).
    return "﻿" + lineas.join("\r\n");
}

function nombreArchivoExport() {
    const d = new Date();
    const pad = (n) => String(n).padStart(2, "0");
    const fecha = `${d.getFullYear()}${pad(d.getMonth() + 1)}${pad(d.getDate())}`;
    return `comentarios_${fecha}.csv`;
}

function descargarArchivo(contenido, nombre) {
    const blob = new Blob([contenido], {
        type: "text/csv;charset=utf-8;",
    });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = nombre;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

// ----------------------------------------------------------------------------
//  RENDER: tabla
// ----------------------------------------------------------------------------
function renderTablaCom(registros) {
    elC.tablaBody.innerHTML = "";

    if (!registros || registros.length === 0) {
        elC.sinRegistros.classList.remove("oculto");
        return;
    }
    elC.sinRegistros.classList.add("oculto");

    const fragment = document.createDocumentFragment();

    registros.forEach((r) => {
        const tr = document.createElement("tr");

        // Checkbox de selección
        const tdCheck = document.createElement("td");
        const check = document.createElement("input");
        check.type = "checkbox";
        check.setAttribute("aria-label", "Seleccionar " + (r.nombre || r.id));
        check.checked = estadoCom.seleccionados.has(r.id);
        check.addEventListener("change", () => {
            if (check.checked) estadoCom.seleccionados.add(r.id);
            else estadoCom.seleccionados.delete(r.id);
            sincronizarCheckTodos();
        });
        tdCheck.appendChild(check);
        tr.appendChild(tdCheck);

        tr.appendChild(crearCelda(r.nombre || "—"));
        tr.appendChild(crearCelda(r.email || "—"));

        // Comentario (respetamos saltos de línea)
        const tdCom = document.createElement("td");
        tdCom.textContent = r.comentarios || "—";
        tdCom.style.whiteSpace = "pre-wrap";
        tr.appendChild(tdCom);

        tr.appendChild(crearCelda(formatearFecha(r.created_at)));

        // Acciones
        const tdAcciones = document.createElement("td");
        const btnEliminar = document.createElement("button");
        btnEliminar.type = "button";
        btnEliminar.className = "btn-accion btn-eliminar";
        btnEliminar.textContent = "Eliminar";
        btnEliminar.setAttribute(
            "aria-label",
            "Eliminar comentario de " + (r.nombre || "")
        );
        btnEliminar.addEventListener("click", () => confirmarEliminarCom(r.id));
        tdAcciones.appendChild(btnEliminar);
        tr.appendChild(tdAcciones);

        fragment.appendChild(tr);
    });

    elC.tablaBody.appendChild(fragment);
}

function crearCelda(texto) {
    const td = document.createElement("td");
    td.textContent = texto;
    return td;
}

function sincronizarCheckTodos() {
    const todos = estadoCom.cacheDatos.length > 0 &&
        estadoCom.cacheDatos.every((r) => estadoCom.seleccionados.has(r.id));
    elC.checkTodos.checked = todos;
    elC.checkTodos.indeterminate =
        !todos &&
        estadoCom.cacheDatos.some((r) => estadoCom.seleccionados.has(r.id));
}

function toggleTodos(e) {
    const marcar = e.target.checked;
    estadoCom.cacheDatos.forEach((r) => {
        if (marcar) estadoCom.seleccionados.add(r.id);
        else estadoCom.seleccionados.delete(r.id);
    });
    // Re-render para reflejar checks
    renderTablaCom(estadoCom.cacheDatos);
}

// ----------------------------------------------------------------------------
//  RENDER: paginación
// ----------------------------------------------------------------------------
function renderPaginacionCom(total) {
    elC.paginacion.innerHTML = "";
    const totalPaginas = Math.max(1, Math.ceil(total / REGISTROS_POR_PAGINA));
    if (totalPaginas <= 1) return;

    const crearBtn = (label, pagina, deshabilitado, activo) => {
        const b = document.createElement("button");
        b.type = "button";
        b.className = "btn-pagina" + (activo ? " activo" : "");
        b.textContent = label;
        b.disabled = deshabilitado;
        if (!deshabilitado) {
            b.addEventListener("click", () => {
                estadoCom.paginaActual = pagina;
                cargarComentarios();
            });
        }
        return b;
    };

    elC.paginacion.appendChild(
        crearBtn("« Anterior", estadoCom.paginaActual - 1,
            estadoCom.paginaActual === 1, false)
    );
    for (let p = 1; p <= totalPaginas; p++) {
        elC.paginacion.appendChild(
            crearBtn(String(p), p, false, p === estadoCom.paginaActual)
        );
    }
    elC.paginacion.appendChild(
        crearBtn("Siguiente »", estadoCom.paginaActual + 1,
            estadoCom.paginaActual === totalPaginas, false)
    );
}

function actualizarContadorCom(total) {
    elC.contador.textContent =
        total === 1 ? "1 comentario" : `${total} comentarios`;
}

// ----------------------------------------------------------------------------
//  EVENTOS: buscador
// ----------------------------------------------------------------------------
function alBuscarCom() {
    const valid = validarTermino(elC.buscador.value);
    if (!valid.ok) {
        mostrarMensaje("error", valid.msg);
        return;
    }
    clearTimeout(alBuscarCom._timer);
    alBuscarCom._timer = setTimeout(() => {
        estadoCom.terminoBusqueda = valid.valor;
        estadoCom.paginaActual = 1;
        cargarComentarios();
    }, 300);
}

// ----------------------------------------------------------------------------
//  UI HELPERS
// ----------------------------------------------------------------------------
function mostrarSpinner(mostrar) {
    if (mostrar) elC.spinner.classList.remove("oculto");
    else elC.spinner.classList.add("oculto");
}

function deshabilitarBotonesCom(deshabilitar) {
    elC.btnExportar.disabled = deshabilitar;
    elC.btnEliminarTodos.disabled = deshabilitar;
    elC.buscador.disabled = deshabilitar;
}

function mostrarMensaje(tipo, texto) {
    const div = document.createElement("div");
    div.className = `toast toast-${tipo}`;
    div.setAttribute("role", "status");
    div.textContent = texto;
    elC.mensajes.appendChild(div);
    setTimeout(() => {
        div.classList.add("oculto");
        setTimeout(() => div.remove(), 400);
    }, 4000);
}

function formatearFecha(iso) {
    if (!iso) return "—";
    try {
        return new Date(iso).toLocaleString("es-ES", {
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit",
        });
    } catch {
        return iso;
    }
}
