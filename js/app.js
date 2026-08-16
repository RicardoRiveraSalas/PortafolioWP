// ============================================================================
//  js/app.js
//  Lógica completa de la aplicación: CRUD + búsqueda + paginación.
//
//  Depende de: config.js  y  supabase.js
// ============================================================================

// ----------------------------------------------------------------------------
//  Estado global de la interfaz
// ----------------------------------------------------------------------------
const estadoApp = {
    editandoId: null,        // id del registro en edición (null = modo crear)
    paginaActual: 1,         // página de la paginación
    terminoBusqueda: "",     // texto del buscador
};

// Referencias a elementos del DOM (se asignan en init).
const el = {};

// ----------------------------------------------------------------------------
//  Inicialización
// ----------------------------------------------------------------------------
document.addEventListener("DOMContentLoaded", async () => {
    // Cachear elementos del DOM.
    el.form = document.getElementById("formulario");
    el.idInput = document.getElementById("registro-id");
    el.nombre = document.getElementById("nombre");
    el.telefono = document.getElementById("telefono");
    el.email = document.getElementById("email");
    el.direccion = document.getElementById("direccion");
    el.estado = document.getElementById("estado");
    el.comentarios = document.getElementById("comentarios");
    el.btnGuardar = document.getElementById("btn-guardar");
    el.btnLimpiar = document.getElementById("btn-limpiar");
    el.btnCancelar = document.getElementById("btn-cancelar");
    el.buscador = document.getElementById("buscador");
    el.tablaBody = document.getElementById("tabla-body");
    el.paginacion = document.getElementById("paginacion");
    el.contador = document.getElementById("contador-registros");
    el.mensajes = document.getElementById("mensajes");
    el.spinner = document.getElementById("spinner");
    el.sinRegistros = document.getElementById("sin-registros");

    // Inicializar cliente de Supabase.
    try {
        getSupabase();
    } catch (err) {
        mostrarMensaje("error", err.message);
        return;
    }

    // Listeners del formulario.
    el.form.addEventListener("submit", alEnviarFormulario);
    el.btnLimpiar.addEventListener("click", limpiarFormulario);
    el.btnCancelar.addEventListener("click", cancelarEdicion);
    el.buscador.addEventListener("input", alBuscar);

    // Carga inicial.
    await cargarRegistros();
});

// ----------------------------------------------------------------------------
//  VALIDACIÓN
// ----------------------------------------------------------------------------
function validarDatos(datos) {
    const errores = [];

    // Nombre obligatorio.
    if (!datos.nombre || datos.nombre.trim().length === 0) {
        errores.push("El nombre es obligatorio.");
    }

    // Email: solo validar si se proporciona.
    if (datos.email && datos.email.trim().length > 0) {
        const reEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!reEmail.test(datos.email.trim())) {
            errores.push("El correo electrónico no tiene un formato válido.");
        }
    }

    // Teléfono: validación razonable (dígitos, +, -, espacios, paréntesis).
    if (datos.telefono && datos.telefono.trim().length > 0) {
        const reTel = /^[\d\s()+\-]{7,20}$/;
        if (!reTel.test(datos.telefono.trim())) {
            errores.push("El teléfono contiene caracteres no válidos.");
        }
    }

    // Evitar registro completamente vacío (además del nombre).
    const todoVacio =
        (!datos.telefono || !datos.telefono.trim()) &&
        (!datos.email || !datos.email.trim()) &&
        (!datos.direccion || !datos.direccion.trim()) &&
        (!datos.estado || !datos.estado.trim()) &&
        (!datos.comentarios || !datos.comentarios.trim());

    if (datos.nombre && datos.nombre.trim().length > 0 && todoVacio) {
        errores.push("Completa al menos un campo además del nombre.");
    }

    return errores;
}

// ----------------------------------------------------------------------------
//  CREATE / UPDATE  -> guardarRegistro() / editarRegistro()
// ----------------------------------------------------------------------------
async function alEnviarFormulario(event) {
    event.preventDefault();

    // Recolectar y limpiar datos.
    const datos = {
        nombre: el.nombre.value,
        telefono: el.telefono.value,
        email: el.email.value,
        direccion: el.direccion.value,
        estado: el.estado.value,
        comentarios: el.comentarios.value,
    };

    // Validación en frontend (no confiar solo en el navegador).
    const errores = validarDatos(datos);
    if (errores.length > 0) {
        mostrarMensaje("error", errores.join(" "));
        return;
    }

    // Limpiar espacios innecesarios.
    const limpios = {
        nombre: datos.nombre.trim(),
        telefono: datos.telefono.trim() || null,
        email: datos.email.trim() || null,
        direccion: datos.direccion.trim() || null,
        estado: datos.estado.trim() || null,
        comentarios: datos.comentarios.trim() || null,
    };

    const esEdicion = estadoApp.editandoId !== null;

    try {
        deshabilitarBotones(true);
        mostrarSpinner(true);

        if (esEdicion) {
            await editarRegistro(estadoApp.editandoId, limpios);
            mostrarMensaje("exito", "Registro actualizado correctamente");
        } else {
            await guardarRegistro(limpios);
            mostrarMensaje("exito", "Registro guardado correctamente");
        }

        limpiarFormulario();
        estadoApp.paginaActual = 1;
        await cargarRegistros();
    } catch (err) {
        console.error(err);
        mostrarMensaje(
            "error",
            esEdicion
                ? "No se pudo actualizar el registro"
                : "No se pudo guardar el registro"
        );
    } finally {
        deshabilitarBotones(false);
        mostrarSpinner(false);
    }
}

async function guardarRegistro(datos) {
    const sb = getSupabase();
    const { error } = await sb
        .from(SUPABASE_TABLA)
        .insert([datos]);

    if (error) throw error;
}

async function editarRegistro(id, datos) {
    const sb = getSupabase();
    const { error } = await sb
        .from(SUPABASE_TABLA)
        .update(datos)
        .eq("id", id);

    if (error) throw error;
}

// ----------------------------------------------------------------------------
//  READ  -> obtenerRegistros() / buscarRegistros()
// ----------------------------------------------------------------------------
async function obtenerRegistros(pagina = 1, termino = "") {
    const sb = getSupabase();
    const desde = (pagina - 1) * REGISTROS_POR_PAGINA;
    const hasta = desde + REGISTROS_POR_PAGINA - 1;

    let query = sb
        .from(SUPABASE_TABLA)
        .select("*", { count: "exact" })
        .order("created_at", { ascending: false })
        .range(desde, hasta);

    // Si hay término de búsqueda, filtramos por nombre/teléfono/email.
    if (termino && termino.trim().length > 0) {
        query = aplicarFiltroBusqueda(query, termino.trim());
    }

    const { data, error, count } = await query;

    if (error) throw error;
    return { data: data || [], total: count || 0 };
}

// Aplica filtro OR sobre nombre, teléfono y email (búsqueda insensible a
// mayúsculas usando ilike).
function aplicarFiltroBusqueda(query, termino) {
    const t = `%${termino}%`;
    return query.or(
        `nombre.ilike.${t},telefono.ilike.${t},email.ilike.${t}`
    );
}

async function buscarRegistros(termino) {
    estadoApp.terminoBusqueda = termino;
    estadoApp.paginaActual = 1;
    await cargarRegistros();
}

async function cargarRegistros() {
    try {
        mostrarSpinner(true);
        const { data, total } = await obtenerRegistros(
            estadoApp.paginaActual,
            estadoApp.terminoBusqueda
        );
        renderTabla(data);
        renderPaginacion(total);
        actualizarContador(total);
    } catch (err) {
        console.error(err);
        mostrarMensaje("error", "No se pudieron cargar los registros");
    } finally {
        mostrarSpinner(false);
    }
}

// ----------------------------------------------------------------------------
//  DELETE  -> eliminarRegistro()
// ----------------------------------------------------------------------------
async function eliminarRegistro(id) {
    const sb = getSupabase();
    const { error } = await sb
        .from(SUPABASE_TABLA)
        .delete()
        .eq("id", id);

    if (error) throw error;
}

async function confirmarEliminar(id) {
    const ok = window.confirm(
        "¿Está seguro de que desea eliminar este registro?"
    );
    if (!ok) return;

    try {
        deshabilitarBotones(true);
        mostrarSpinner(true);
        await eliminarRegistro(id);
        mostrarMensaje("exito", "Registro eliminado correctamente");
        await cargarRegistros();
    } catch (err) {
        console.error(err);
        mostrarMensaje("error", "No se pudo eliminar el registro");
    } finally {
        deshabilitarBotones(false);
        mostrarSpinner(false);
    }
}

// ----------------------------------------------------------------------------
//  EDICIÓN (cargar datos al formulario)
// ----------------------------------------------------------------------------
async function cargarParaEditar(id) {
    try {
        mostrarSpinner(true);
        const sb = getSupabase();
        const { data, error } = await sb
            .from(SUPABASE_TABLA)
            .select("*")
            .eq("id", id)
            .single();

        if (error) throw error;

        estadoApp.editandoId = id;

        el.idInput.value = data.id;
        el.nombre.value = data.nombre || "";
        el.telefono.value = data.telefono || "";
        el.email.value = data.email || "";
        el.direccion.value = data.direccion || "";
        el.estado.value = data.estado || "";
        el.comentarios.value = data.comentarios || "";

        // Cambiar botón a "Actualizar" y mostrar cancelar.
        el.btnGuardar.textContent = "Actualizar";
        el.btnCancelar.classList.remove("oculto");

        // Llevar el foco al primer campo y desplazar al formulario.
        el.nombre.focus();
        el.form.scrollIntoView({ behavior: "smooth", block: "start" });
    } catch (err) {
        console.error(err);
        mostrarMensaje("error", "No se pudo cargar el registro para editar");
    } finally {
        mostrarSpinner(false);
    }
}

function cancelarEdicion() {
    limpiarFormulario();
}

// ----------------------------------------------------------------------------
//  LIMPIAR FORMULARIO
// ----------------------------------------------------------------------------
function limpiarFormulario() {
    el.form.reset();
    el.idInput.value = "";
    estadoApp.editandoId = null;
    el.btnGuardar.textContent = "Guardar";
    el.btnCancelar.classList.add("oculto");
    ocultarMensajes();
}

// ----------------------------------------------------------------------------
//  RENDER: tabla
// ----------------------------------------------------------------------------
function renderTabla(registros) {
    el.tablaBody.innerHTML = "";

    if (!registros || registros.length === 0) {
        el.sinRegistros.classList.remove("oculto");
        return;
    }
    el.sinRegistros.classList.add("oculto");

    const fragment = document.createDocumentFragment();

    registros.forEach((r) => {
        const tr = document.createElement("tr");

        tr.appendChild(crearCelda(cortarTexto(r.id, 8) + "…", "mono"));
        tr.appendChild(crearCelda(r.nombre || ""));
        tr.appendChild(crearCelda(r.telefono || "—"));
        tr.appendChild(crearCelda(r.email || "—"));
        tr.appendChild(crearCelda(r.direccion || "—"));
        tr.appendChild(crearCelda(r.estado || "—"));
        tr.appendChild(crearCelda(formatearFecha(r.created_at)));

        // Acciones
        const tdAcciones = document.createElement("td");

        const btnEditar = document.createElement("button");
        btnEditar.type = "button";
        btnEditar.className = "btn-accion btn-editar";
        btnEditar.textContent = "Editar";
        btnEditar.setAttribute("aria-label", "Editar registro de " + r.nombre);
        btnEditar.addEventListener("click", () => cargarParaEditar(r.id));

        const btnEliminar = document.createElement("button");
        btnEliminar.type = "button";
        btnEliminar.className = "btn-accion btn-eliminar";
        btnEliminar.textContent = "Eliminar";
        btnEliminar.setAttribute(
            "aria-label",
            "Eliminar registro de " + r.nombre
        );
        btnEliminar.addEventListener("click", () => confirmarEliminar(r.id));

        tdAcciones.appendChild(btnEditar);
        tdAcciones.appendChild(btnEliminar);
        tr.appendChild(tdAcciones);

        fragment.appendChild(tr);
    });

    el.tablaBody.appendChild(fragment);
}

function crearCelda(texto, claseExtra = "") {
    const td = document.createElement("td");
    if (claseExtra) td.className = claseExtra;
    td.textContent = texto;
    return td;
}

// ----------------------------------------------------------------------------
//  RENDER: paginación
// ----------------------------------------------------------------------------
function renderPaginacion(total) {
    el.paginacion.innerHTML = "";

    const totalPaginas = Math.max(
        1,
        Math.ceil(total / REGISTROS_POR_PAGINA)
    );

    if (totalPaginas <= 1) return;

    const crearBtn = (label, pagina, deshabilitado, activo) => {
        const b = document.createElement("button");
        b.type = "button";
        b.className = "btn-pagina" + (activo ? " activo" : "");
        b.textContent = label;
        b.disabled = deshabilitado;
        if (!deshabilitado) {
            b.addEventListener("click", () => {
                estadoApp.paginaActual = pagina;
                cargarRegistros();
            });
        }
        return b;
    };

    el.paginacion.appendChild(
        crearBtn("« Anterior", estadoApp.paginaActual - 1,
            estadoApp.paginaActual === 1, false)
    );

    for (let p = 1; p <= totalPaginas; p++) {
        el.paginacion.appendChild(
            crearBtn(String(p), p, false, p === estadoApp.paginaActual)
        );
    }

    el.paginacion.appendChild(
        crearBtn("Siguiente »", estadoApp.paginaActual + 1,
            estadoApp.paginaActual === totalPaginas, false)
    );
}

function actualizarContador(total) {
    el.contador.textContent =
        total === 1
            ? "1 registro"
            : `${total} registros`;
}

// ----------------------------------------------------------------------------
//  EVENTOS: buscador
// ----------------------------------------------------------------------------
function alBuscar() {
    const valor = el.buscador.value;
    // Debounce simple para no consultar en cada tecla.
    clearTimeout(alBuscar._timer);
    alBuscar._timer = setTimeout(() => {
        buscarRegistros(valor);
    }, 300);
}

// ----------------------------------------------------------------------------
//  UI HELPERS
// ----------------------------------------------------------------------------
function mostrarSpinner(mostrar) {
    if (mostrar) el.spinner.classList.remove("oculto");
    else el.spinner.classList.add("oculto");
}

function deshabilitarBotones(deshabilitar) {
    el.btnGuardar.disabled = deshabilitar;
    el.btnLimpiar.disabled = deshabilitar;
    el.btnCancelar.disabled = deshabilitar;
}

function mostrarMensaje(tipo, texto) {
    const div = document.createElement("div");
    div.className = `toast toast-${tipo}`;
    div.setAttribute("role", "status");
    div.textContent = texto;
    el.mensajes.appendChild(div);

    // Auto-ocultar después de 4s.
    setTimeout(() => {
        div.classList.add("oculto");
        setTimeout(() => div.remove(), 400);
    }, 4000);
}

function ocultarMensajes() {
    el.mensajes.innerHTML = "";
}

// Utilidades
function cortarTexto(texto, n) {
    if (!texto) return "";
    return texto.length > n ? texto.substring(0, n) : texto;
}

function formatearFecha(iso) {
    if (!iso) return "—";
    try {
        const d = new Date(iso);
        return d.toLocaleString("es-ES", {
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
