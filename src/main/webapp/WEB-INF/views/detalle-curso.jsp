<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
        <html lang="es">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Detalle del Curso |
                <c:out value="${curso.nombre}" />
            </title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portfolio-cyber.css">
            <style>
                .course-header {
                    padding: 110px 8% 40px;
                    background: linear-gradient(180deg, rgba(255, 42, 133, 0.12) 0%, transparent 100%);
                    border-bottom: 1px solid var(--border-pink);
                }

                .back-btn {
                    color: var(--pink-light);
                    text-decoration: none;
                    font-size: 0.88rem;
                    font-weight: 600;
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    margin-bottom: 20px;
                    transition: var(--transition);
                }

                .back-btn:hover {
                    color: #fff;
                    text-shadow: 0 0 10px var(--pink-neon);
                }

                .course-title-box {
                    display: flex;
                    align-items: center;
                    gap: 20px;
                    flex-wrap: wrap;
                }

                .course-icon-lg {
                    width: 70px;
                    height: 70px;
                    border-radius: 16px;
                    background: rgba(255, 42, 133, 0.15);
                    border: 2px solid var(--border-pink-glow);
                    color: var(--pink-neon);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 2.2rem;
                    box-shadow: var(--pink-glow);
                }

                .trabajos-section {
                    padding: 40px 8%;
                }

                .trabajos-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 30px;
                    flex-wrap: wrap;
                    gap: 15px;
                }

                .btn-add-trabajo {
                    background: var(--pink-gradient);
                    color: #fff;
                    padding: 12px 24px;
                    border-radius: var(--radius-pill);
                    border: none;
                    font-weight: 600;
                    font-size: 0.88rem;
                    cursor: pointer;
                    box-shadow: var(--pink-glow);
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    transition: var(--transition);
                }

                .btn-add-trabajo:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 0 30px rgba(255, 42, 133, 0.8);
                }

                /* GRID DE LAS 16 SEMANAS */
                .semanas-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                    gap: 18px;
                    margin-bottom: 50px;
                }

                .semana-card {
                    background: var(--bg-card);
                    border: 1px solid var(--border-pink);
                    border-radius: var(--radius-md);
                    padding: 20px;
                    text-decoration: none;
                    color: inherit;
                    transition: var(--transition);
                    display: flex;
                    flex-direction: column;
                    justify-content: space-between;
                    position: relative;
                    overflow: hidden;
                }

                .semana-card:hover {
                    border-color: var(--pink-neon);
                    transform: translateY(-4px);
                    box-shadow: var(--pink-glow);
                    background: var(--bg-card-hover);
                }

                .semana-num-badge {
                    font-size: 0.75rem;
                    color: var(--pink-neon);
                    font-weight: 700;
                    letter-spacing: 1px;
                    margin-bottom: 6px;
                }

                .semana-card h4 {
                    color: #fff;
                    font-size: 0.95rem;
                    margin-bottom: 12px;
                    line-height: 1.4;
                }

                .semana-footer {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    font-size: 0.78rem;
                    color: var(--text-muted);
                    border-top: 1px dashed rgba(255, 42, 133, 0.2);
                    padding-top: 10px;
                    margin-top: 10px;
                }

                /* GRID DE TRABAJOS */
                .trabajos-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
                    gap: 22px;
                }

                .trabajo-card {
                    background: var(--bg-card);
                    border: 1px solid var(--border-pink);
                    border-radius: var(--radius-md);
                    padding: 24px;
                    display: flex;
                    flex-direction: column;
                    justify-content: space-between;
                    transition: var(--transition);
                }

                .trabajo-card:hover {
                    border-color: var(--pink-neon);
                    box-shadow: var(--pink-glow);
                }

                .badge-status {
                    padding: 4px 10px;
                    border-radius: var(--radius-pill);
                    font-size: 0.72rem;
                    font-weight: 600;
                    text-transform: uppercase;
                }

                .status-calificado {
                    background: rgba(34, 197, 94, 0.2);
                    color: #4ade80;
                    border: 1px solid #22c55e;
                }

                .status-entregado {
                    background: rgba(59, 130, 246, 0.2);
                    color: #60a5fa;
                    border: 1px solid #3b82f6;
                }

                .status-pendiente {
                    background: rgba(234, 179, 8, 0.2);
                    color: #facc15;
                    border: 1px solid #eab308;
                }

                .btn-action-sm {
                    padding: 6px 14px;
                    border-radius: var(--radius-pill);
                    font-size: 0.78rem;
                    font-weight: 600;
                    text-decoration: none;
                    display: inline-flex;
                    align-items: center;
                    gap: 6px;
                    transition: var(--transition);
                }

                .btn-download {
                    background: rgba(255, 42, 133, 0.15);
                    color: var(--pink-light);
                    border: 1px solid var(--border-pink);
                }

                .btn-download:hover {
                    background: var(--pink-neon);
                    color: #fff;
                }

                .btn-live-demo {
                    background: rgba(14, 165, 233, 0.15);
                    color: #38bdf8;
                    border: 1px solid rgba(14, 165, 233, 0.4);
                }

                .btn-live-demo:hover {
                    background: #0ea5e9;
                    color: #fff;
                }

                /* ESTILOS DEL MODAL POP-UP (EXPLÍCITOS) */
                .modal-overlay {
                    display: none;
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100vw;
                    height: 100vh;
                    background: rgba(5, 4, 15, 0.9);
                    backdrop-filter: blur(12px);
                    -webkit-backdrop-filter: blur(12px);
                    z-index: 99999;
                    justify-content: center;
                    align-items: center;
                    padding: 20px;
                }

                .modal-content-cyber {
                    background: #0e0c1f;
                    border: 2px solid var(--border-pink-glow);
                    border-radius: var(--radius-lg);
                    padding: 35px;
                    width: 100%;
                    max-width: 550px;
                    max-height: 90vh;
                    overflow-y: auto;
                    box-shadow: 0 0 50px rgba(255, 42, 133, 0.6);
                    position: relative;
                    animation: animModalIn 0.3s cubic-bezier(0.16, 1, 0.3, 1);
                }

                @keyframes animModalIn {
                    from {
                        opacity: 0;
                        transform: translateY(-25px) scale(0.96);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0) scale(1);
                    }
                }

                .close-btn-cyber {
                    position: absolute;
                    top: 16px;
                    right: 20px;
                    background: none;
                    border: none;
                    color: var(--text-sub);
                    font-size: 1.8rem;
                    line-height: 1;
                    cursor: pointer;
                    transition: var(--transition);
                }

                .close-btn-cyber:hover {
                    color: var(--pink-neon);
                    transform: rotate(90deg);
                }

                .form-group {
                    margin-bottom: 16px;
                }

                .form-group label {
                    display: block;
                    color: var(--text-sub);
                    font-size: 0.82rem;
                    margin-bottom: 6px;
                    font-weight: 500;
                }

                .form-control {
                    width: 100%;
                    background: rgba(14, 12, 31, 0.9);
                    border: 1px solid var(--border-pink);
                    border-radius: 8px;
                    padding: 11px 14px;
                    color: #fff;
                    font-family: var(--font-body);
                    font-size: 0.88rem;
                    outline: none;
                    transition: var(--transition);
                }

                .form-control:focus {
                    border-color: var(--pink-neon);
                    box-shadow: 0 0 12px rgba(255, 42, 133, 0.4);
                }
            </style>
        </head>

        <body>

            <!-- ENCABEZADO DEL CURSO -->
            <div class="course-header">
                <a href="${backUrl}" class="back-btn">
                    <i class="fa-solid fa-arrow-left"></i> Volver al Panel
                </a>
                <div class="course-title-box">
                    <div class="course-icon-lg">
                        <i class="fa-solid <c:out value='${curso.icono}'/>"></i>
                    </div>
                    <div>
                        <div
                            style="font-size: 0.8rem; color: var(--pink-neon); font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase;">
                            <c:out value=" " /> Ciclo
                            <c:out value="${curso.ciclo}" /> •
                            <c:out value="${curso.creditos}" /> Créditos
                        </div>
                        <h1
                            style="color: #fff; font-family: var(--font-heading); font-size: 1.8rem; margin: 4px 0 8px;">
                            <c:out value="${curso.nombre}" />
                        </h1>
                        <p style="color: var(--text-sub); font-size: 0.9rem; max-width: 800px;">
                            <c:out value="${curso.descripcion}" />
                        </p>
                        <div style="margin-top: 10px; font-size: 0.82rem; color: var(--text-muted);">
                            <i class="fa-solid fa-chalkboard-user" style="color: var(--pink-light);"></i> Docente a
                            cargo: <strong>
                                <c:out
                                    value="${curso.docenteNombre != null ? curso.docenteNombre : 'Ing. Docente Titular'}" />
                            </strong>
                        </div>
                    </div>
                </div>
            </div>

            <!-- CONTENIDO PRINCIPAL -->
            <div class="trabajos-section">

                <!-- SECCIÓN 1: CRONOGRAMA DE 16 SEMANAS -->
                <div class="trabajos-header">
                    <div>
                        <h2 style="color: #fff; font-size: 1.3rem; margin-bottom: 4px;">
                            <i class="fa-solid fa-calendar-days"
                                style="color: var(--pink-neon); margin-right: 8px;"></i>
                            Plan Académico (16 Semanas)
                        </h2>
                        <p style="color: var(--text-sub); font-size: 0.85rem;">
                            Selecciona una semana para ver sus actividades temáticas o registrar entregables prácticos.
                        </p>
                    </div>
                    <c:if test="${rolUsuario != 'DOCENTE'}">
                        <button type="button" class="btn-add-trabajo" onclick="abrirModalEntrega()">
                            <i class="fa-solid fa-cloud-arrow-up"></i> Nueva Entrega de Proyecto
                        </button>
                    </c:if>
                </div>

                <div class="semanas-grid">
                    <c:forEach var="sem" items="${semanas}">
                        <a href="${pageContext.request.contextPath}/curso?id=1&semana=${sem.numero}"
                            class="semana-card">
                            <div>
                                <div class="semana-num-badge">SEMANA ${sem.numero}</div>
                                <h4>
                                    <c:out value="${sem.titulo}" />
                                </h4>
                            </div>
                            <div class="semana-footer">
                                <span>
                                    <i class="fa-solid fa-file-code" style="color: var(--pink-light);"></i>
                                    <c:out
                                        value="${conteoSemanal[sem.numero] != null ? conteoSemanal[sem.numero] : 0}" />
                                    entregas
                                </span>
                                <span style="color: var(--pink-light); font-weight: 600;">
                                    Ver detalles <i class="fa-solid fa-chevron-right"></i>
                                </span>
                            </div>
                        </a>
                    </c:forEach>
                </div>

                <!-- SECCIÓN 2: TRABAJOS ENTREGADOS EN ESTE CURSO -->
                <div class="trabajos-header" style="border-top: 1px solid var(--border-pink); padding-top: 30px;">
                    <div>
                        <h2 style="color: #fff; font-size: 1.3rem; margin-bottom: 4px;">
                            <i class="fa-solid fa-folder-open" style="color: var(--pink-neon); margin-right: 8px;"></i>
                            Entregables y Proyectos Registrados (${totalTrabajos})
                        </h2>
                        <p style="color: var(--text-sub); font-size: 0.85rem;">
                            Repositorio consolidado de proyectos, código fuente y evaluaciones del curso.
                        </p>
                    </div>
                </div>

                <div class="trabajos-grid">
                    <c:choose>
                        <c:when test="${empty trabajos}">
                            <div
                                style="grid-column: 1 / -1; text-align: center; padding: 50px 20px; background: var(--bg-card); border: 1px dashed var(--border-pink); border-radius: var(--radius-lg);">
                                <i class="fa-solid fa-folder-open"
                                    style="font-size: 3rem; color: var(--pink-light); margin-bottom: 15px; display: inline-block;"></i>
                                <h3 style="color: #fff; margin-bottom: 8px;">No hay entregables registrados aún</h3>
                                <p style="color: var(--text-sub); font-size: 0.88rem; margin-bottom: 20px;">Comienza
                                    registrando tu primer laboratorio práctico o proyecto semanal.</p>
                                <c:if test="${rolUsuario != 'DOCENTE'}">
                                    <button type="button" class="btn-add-trabajo" onclick="abrirModalEntrega()">
                                        <i class="fa-solid fa-cloud-arrow-up"></i> Registrar Primer Trabajo
                                    </button>
                                </c:if>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="trabajo" items="${trabajos}">
                                <div class="trabajo-card">
                                    <div>
                                        <div
                                            style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                                            <span
                                                style="font-size: 0.75rem; color: var(--pink-neon); font-weight: 700; text-transform: uppercase;">
                                                SEMANA ${trabajo.semanaNumero} • ${trabajo.categoriaTag}
                                            </span>
                                            <span
                                                class="badge-status ${trabajo.estado == 'Calificado' ? 'status-calificado' : (trabajo.estado == 'Entregado' ? 'status-entregado' : 'status-pendiente')}">
                                                ${trabajo.estado}
                                            </span>
                                        </div>

                                        <h3
                                            style="color: #fff; font-size: 1.05rem; margin-bottom: 8px; line-height: 1.4;">
                                            <c:out value="${trabajo.titulo}" />
                                        </h3>

                                        <p
                                            style="color: var(--text-sub); font-size: 0.85rem; margin-bottom: 15px; line-height: 1.5;">
                                            <c:out value="${trabajo.descripcion}" />
                                        </p>

                                        <c:if test="${not empty trabajo.notaPersonal}">
                                            <div
                                                style="background: rgba(255, 42, 133, 0.08); border-left: 3px solid var(--pink-neon); padding: 8px 12px; border-radius: 4px; font-size: 0.78rem; color: var(--pink-light); margin-bottom: 12px;">
                                                <i class="fa-solid fa-note-sticky"></i>
                                                <c:out value="${trabajo.notaPersonal}" />
                                            </div>
                                        </c:if>

                                        <!-- OBSERVACIÓN DOCENTE SI ESTÁ CALIFICADO -->
                                        <c:if test="${not empty trabajo.observacionDocente}">
                                            <div
                                                style="background: rgba(34, 197, 94, 0.08); border-left: 3px solid #22c55e; padding: 8px 12px; border-radius: 4px; font-size: 0.78rem; color: #86efac; margin-bottom: 12px;">
                                                <i class="fa-solid fa-comment-dots"></i> <strong>Docente:</strong>
                                                <c:out value="${trabajo.observacionDocente}" />
                                            </div>
                                        </c:if>
                                    </div>

                                    <div>
                                        <!-- CALIFICACIÓN Y FECHA -->
                                        <div
                                            style="display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-top: 1px solid rgba(255, 42, 133, 0.15); border-bottom: 1px solid rgba(255, 42, 133, 0.15); margin-bottom: 12px;">
                                            <span style="font-size: 0.78rem; color: var(--text-muted);">
                                                <i class="fa-regular fa-calendar"></i> ${trabajo.fechaEntrega}
                                            </span>
                                            <span
                                                style="font-size: 0.88rem; font-weight: 700; color: ${trabajo.calificacion != null ? '#4ade80' : 'var(--text-muted)'};">
                                                <i class="fa-solid fa-award"></i> ${trabajo.calificacion != null ?
                                                trabajo.calificacion : 'Pendiente'}
                                            </span>
                                        </div>

                                        <!-- BOTONES DE ACCIÓN (DESCARGA ARCHIVO + LINK DESPLIEGUE) -->
                                        <div
                                            style="display: flex; flex-wrap: wrap; gap: 8px; justify-content: flex-start; align-items: center;">
                                            <c:if test="${not empty trabajo.archivoNombre}">
                                                <a href="${pageContext.request.contextPath}/download-archivo?nombre=${trabajo.archivoNombre}"
                                                    class="btn-action-sm btn-download" title="Descargar archivo físico">
                                                    <i class="fa-solid fa-file-arrow-down"></i> Archivo
                                                    (${trabajo.archivoNombre})
                                                </a>
                                            </c:if>

                                            <c:if test="${not empty trabajo.urlProyecto}">
                                                <a href="${trabajo.urlProyecto}" target="_blank"
                                                    rel="noopener noreferrer" class="btn-action-sm btn-live-demo"
                                                    title="Abrir despliegue en vivo o repositorio">
                                                    <i class="fa-solid fa-arrow-up-right-from-square"></i> Ver Proyecto
                                                    / Demo
                                                </a>
                                            </c:if>

                                            <c:if test="${rolUsuario != 'DOCENTE'}">
                                                <a href="${pageContext.request.contextPath}/trabajo?action=eliminar&id=${trabajo.id}&cursoId=1"
                                                    class="btn-action-sm"
                                                    style="color: #f87171; background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.3); margin-left: auto;"
                                                    onclick="return confirm('¿Seguro que deseas eliminar este entregable?');">
                                                    <i class="fa-solid fa-trash-can"></i>
                                                </a>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <c:if test="${rolUsuario != 'DOCENTE'}">
                <!-- MODAL DE NUEVA ENTREGA (POP-UP OVERLAY OCULTO POR DEFECTO) -->
                <div id="modalEntrega" class="modal-overlay">
                    <div class="modal-content-cyber">
                        <button type="button" class="close-btn-cyber" onclick="cerrarModalEntrega()">&times;</button>
                        <div class="login-header-cyber">
                            <h2>NUEVA ENTREGA ACADÉMICA</h2>
                            <p style="font-size: 0.8rem; color: var(--text-muted); margin-top: 4px;">
                                Registra evidencias de proyectos, código ZIP/RAR o URLs de aplicaciones desplegadas
                            </p>
                        </div>

                        <form action="${pageContext.request.contextPath}/trabajo" method="POST"
                            enctype="multipart/form-data" class="login-form-cyber">
                            <input type="hidden" name="action" value="guardar">
                            <input type="hidden" name="cursoId" value="1">

                            <div class="form-group">
                                <label><i class="fa-solid fa-calendar-week"></i> Semana Académica (1 - 16):</label>
                                <select name="semanaNumero" class="form-control" required>
                                    <c:forEach var="s" items="${semanas}">
                                        <option value="${s.numero}">Semana ${s.numero}:
                                            <c:out value="${s.titulo}" />
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-group">
                                <label><i class="fa-solid fa-heading"></i> Título del Proyecto / Actividad:</label>
                                <input type="text" name="titulo" class="form-control" required
                                    placeholder="Ej: Laboratorio 1: MVC con Servlets y JSP">
                            </div>

                            <div class="form-group">
                                <label><i class="fa-solid fa-tags"></i> Categoría / Tecnología:</label>
                                <input type="text" name="categoriaTag" class="form-control"
                                    placeholder="Ej: Java/JSP, Base de Datos, Full Stack, APK Móvil"
                                    value="Proyecto Práctico">
                            </div>

                            <div class="form-group">
                                <label><i class="fa-solid fa-align-left"></i> Resumen Técnico / Descripción:</label>
                                <textarea name="descripcion" class="form-control" style="height: 85px;"
                                    placeholder="Detalles de la implementación, arquitectura y objetivos logrados..."></textarea>
                            </div>

                            <div class="form-group">
                                <label><i class="fa-brands fa-github"></i> URL del Proyecto en Vivo / Repositorio
                                    GitHub:</label>
                                <input type="url" name="urlProyecto" class="form-control"
                                    placeholder="https://github.com/usuario/repo o https://mi-app.onrender.com">
                                <small style="color: var(--text-muted); font-size: 0.72rem;">Opcional: Si el trabajo
                                    requiere despliegue en la nube o revisión de código fuente.</small>
                            </div>

                            <div class="form-group">
                                <label><i class="fa-solid fa-file-zipper"></i> Archivo Adjunto (ZIP, RAR, PDF, APK,
                                    etc.):</label>
                                <input type="file" name="archivoFile" class="form-control" style="padding: 8px;">
                            </div>

                            <div class="form-group">
                                <label><i class="fa-solid fa-sticky-note"></i> Nota Personal / Recordatorio:</label>
                                <input type="text" name="notaPersonal" class="form-control"
                                    placeholder="Ej: Revisado con rúbrica, pendiente optimizar queries SQL">
                            </div>

                            <button type="submit" class="btn-add-trabajo"
                                style="width: 100%; justify-content: center; margin-top: 10px; padding: 13px;">
                                <i class="fa-solid fa-cloud-arrow-up"></i> GUARDAR Y ENTREGAR PROYECTO
                            </button>
                        </form>
                    </div>
                </div>
            </c:if>

            <script>
                function abrirModalEntrega() {
                    var modal = document.getElementById('modalEntrega');
                    if (modal) {
                        modal.style.display = 'flex';
                    }
                }

                function cerrarModalEntrega() {
                    var modal = document.getElementById('modalEntrega');
                    if (modal) {
                        modal.style.display = 'none';
                    }
                }

                document.addEventListener('DOMContentLoaded', function () {
                    var modal = document.getElementById('modalEntrega');
                    if (modal) {
                        modal.addEventListener('click', function (e) {
                            if (e.target === this) {
                                cerrarModalEntrega();
                            }
                        });
                    }

                    document.addEventListener('keydown', function (e) {
                        if (e.key === 'Escape') {
                            cerrarModalEntrega();
                        }
                    });
                });
            </script>

        </body>

        </html>