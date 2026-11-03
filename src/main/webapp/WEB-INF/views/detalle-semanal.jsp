<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${tituloSemana}"/> | <c:out value="${curso.nombre}"/></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portfolio-cyber.css">
    <style>
        .weekly-body {
            padding: 110px 8% 60px;
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
        .back-btn:hover { color: #fff; text-shadow: 0 0 10px var(--pink-neon); }
        
        .weekly-header-card {
            background: linear-gradient(135deg, rgba(255, 42, 133, 0.15) 0%, rgba(14, 12, 31, 0.95) 100%);
            border: 1px solid var(--border-pink-glow);
            padding: 30px;
            border-radius: var(--radius-lg);
            margin-bottom: 35px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            box-shadow: 0 0 25px rgba(255, 42, 133, 0.2);
        }
        .weekly-info h1 {
            font-family: var(--font-heading);
            font-size: 1.8rem;
            color: #fff;
            margin-bottom: 6px;
        }
        .weekly-info p {
            color: var(--text-sub);
            font-size: 0.92rem;
            max-width: 750px;
        }
        .weekly-stats-badge {
            background: rgba(255, 42, 133, 0.2);
            border: 1px solid var(--border-pink);
            padding: 8px 16px;
            border-radius: var(--radius-pill);
            color: #fff;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-top: 10px;
        }
        
        .btn-publish-weekly {
            background: var(--pink-gradient);
            color: #fff;
            padding: 12px 26px;
            border-radius: var(--radius-pill);
            border: none;
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
            box-shadow: var(--pink-glow);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
        }
        .btn-publish-weekly:hover {
            transform: translateY(-2px);
            box-shadow: 0 0 30px rgba(255, 42, 133, 0.8);
        }

        /* GRID DE EVIDENCIAS SEMANALES */
        .evidence-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
            gap: 24px;
        }
        .evidence-card {
            background: var(--bg-card);
            border: 1px solid var(--border-pink);
            border-radius: var(--radius-md);
            padding: 24px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: var(--transition);
        }
        .evidence-card:hover {
            border-color: var(--pink-neon);
            box-shadow: var(--pink-glow);
            background: var(--bg-card-hover);
        }
        .badge-status {
            padding: 4px 10px;
            border-radius: var(--radius-pill);
            font-size: 0.72rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        .status-calificado { background: rgba(34, 197, 94, 0.2); color: #4ade80; border: 1px solid #22c55e; }
        .status-entregado { background: rgba(59, 130, 246, 0.2); color: #60a5fa; border: 1px solid #3b82f6; }
        .status-pendiente { background: rgba(234, 179, 8, 0.2); color: #facc15; border: 1px solid #eab308; }

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

        /* MODAL POP-UP EXPLÍCITO */
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
            max-width: 530px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 0 50px rgba(255, 42, 133, 0.6);
            position: relative;
            animation: animModalIn 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes animModalIn {
            from { opacity: 0; transform: translateY(-25px) scale(0.96); }
            to { opacity: 1; transform: translateY(0) scale(1); }
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
            margin-bottom: 15px;
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

<div class="weekly-body">
    <!-- NAVEGACIÓN DE REGRESO -->
    <a href="${pageContext.request.contextPath}/curso?id=1" class="back-btn">
        <i class="fa-solid fa-arrow-left"></i> Volver al Cronograma General del Curso
    </a>

    <!-- CABECERA DE LA SEMANA -->
    <div class="weekly-header-card">
        <div class="weekly-info">
            <div style="font-size: 0.8rem; color: var(--pink-neon); font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase;">
                <c:out value="${curso.codigo}"/> • <c:out value="${curso.nombre}"/>
            </div>
            <h1>Semana ${semanaNum}: <c:out value="${semanaActual != null ? semanaActual.titulo : 'Actividades Académicas'}"/></h1>
            <p>
                <c:out value="${semanaActual != null && not empty semanaActual.descripcion ? semanaActual.descripcion : 'Laboratorios prácticos, desarrollo de proyectos y entregas evaluativas de esta semana.'}"/>
            </p>
            <div class="weekly-stats-badge">
                <i class="fa-solid fa-list-check" style="color: var(--pink-light);"></i>
                Total de Entregas: <strong>${fn:length(trabajos)}</strong>
            </div>
        </div>

        <div>
            <c:if test="${rolUsuario != 'DOCENTE'}">
            <button type="button" class="btn-publish-weekly" onclick="abrirModal()">
                <i class="fa-solid fa-cloud-arrow-up"></i> Entregar Trabajo en Semana ${semanaNum}
            </button>
            </c:if>
        </div>
    </div>

    <!-- LISTA DE ENTREGABLES DE LA SEMANA -->
    <div class="evidence-grid">
        <c:choose>
            <c:when test="${empty trabajos}">
                <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px; background: var(--bg-card); border: 1px dashed var(--border-pink); border-radius: var(--radius-lg);">
                    <i class="fa-solid fa-box-open" style="font-size: 3.5rem; color: var(--pink-light); margin-bottom: 16px; display: inline-block;"></i>
                    <h3 style="color: #fff; margin-bottom: 8px;">No hay evidencias entregadas en la Semana ${semanaNum}</h3>
                    <p style="color: var(--text-sub); font-size: 0.9rem; margin-bottom: 22px;">
                        Sube tu archivo ZIP/PDF o registra el enlace de tu repositorio/aplicación desplegada.
                    </p>
                    <c:if test="${rolUsuario != 'DOCENTE'}">
                    <button type="button" class="btn-publish-weekly" onclick="abrirModal()">
                        <i class="fa-solid fa-cloud-arrow-up"></i> Registrar Trabajo Ahora
                    </button>
                    </c:if>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="trabajo" items="${trabajos}">
                    <div class="evidence-card">
                        <div>
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                                <span style="font-size: 0.75rem; color: var(--pink-neon); font-weight: 700; text-transform: uppercase;">
                                    ${trabajo.categoriaTag}
                                </span>
                                <span class="badge-status ${trabajo.estado == 'Calificado' ? 'status-calificado' : (trabajo.estado == 'Entregado' ? 'status-entregado' : 'status-pendiente')}">
                                    ${trabajo.estado}
                                </span>
                            </div>

                            <h3 style="color: #fff; font-size: 1.1rem; margin-bottom: 8px; line-height: 1.4;">
                                <c:out value="${trabajo.titulo}"/>
                            </h3>

                            <p style="color: var(--text-sub); font-size: 0.86rem; margin-bottom: 15px; line-height: 1.5;">
                                <c:out value="${trabajo.descripcion}"/>
                            </p>

                            <c:if test="${not empty trabajo.notaPersonal}">
                                <div style="background: rgba(255, 42, 133, 0.08); border-left: 3px solid var(--pink-neon); padding: 8px 12px; border-radius: 4px; font-size: 0.78rem; color: var(--pink-light); margin-bottom: 12px;">
                                    <i class="fa-solid fa-note-sticky"></i> <c:out value="${trabajo.notaPersonal}"/>
                                </div>
                            </c:if>

                            <c:if test="${not empty trabajo.observacionDocente}">
                                <div style="background: rgba(34, 197, 94, 0.08); border-left: 3px solid #22c55e; padding: 8px 12px; border-radius: 4px; font-size: 0.78rem; color: #86efac; margin-bottom: 12px;">
                                    <i class="fa-solid fa-comment-dots"></i> <strong>Docente:</strong> <c:out value="${trabajo.observacionDocente}"/>
                                </div>
                            </c:if>
                        </div>

                        <div>
                            <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-top: 1px solid rgba(255, 42, 133, 0.15); border-bottom: 1px solid rgba(255, 42, 133, 0.15); margin-bottom: 12px;">
                                <span style="font-size: 0.78rem; color: var(--text-muted);">
                                    <i class="fa-regular fa-calendar"></i> ${trabajo.fechaEntrega}
                                </span>
                                <span style="font-size: 0.88rem; font-weight: 700; color: ${trabajo.calificacion != null ? '#4ade80' : 'var(--text-muted)'};">
                                    <i class="fa-solid fa-award"></i> ${trabajo.calificacion != null ? trabajo.calificacion : 'Pendiente'}
                                </span>
                            </div>

                            <div style="display: flex; flex-wrap: wrap; gap: 8px; justify-content: flex-start; align-items: center;">
                                <c:if test="${not empty trabajo.archivoNombre}">
                                    <a href="${pageContext.request.contextPath}/download-archivo?nombre=${trabajo.archivoNombre}" class="btn-action-sm btn-download" title="Descargar archivo físico">
                                        <i class="fa-solid fa-file-arrow-down"></i> Descargar (${trabajo.archivoNombre})
                                    </a>
                                </c:if>

                                <c:if test="${not empty trabajo.urlProyecto}">
                                    <a href="${trabajo.urlProyecto}" target="_blank" rel="noopener noreferrer" class="btn-action-sm btn-live-demo" title="Abrir despliegue en vivo o repositorio">
                                        <i class="fa-solid fa-arrow-up-right-from-square"></i> Ver Proyecto / Demo
                                    </a>
                                </c:if>

                                <c:if test="${rolUsuario != 'DOCENTE'}">
                                <a href="${pageContext.request.contextPath}/trabajo?action=eliminar&id=${trabajo.id}&cursoId=1&semanaOrigen=${semanaNum}" class="btn-action-sm" style="color: #f87171; background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.3); margin-left: auto;" onclick="return confirm('¿Seguro que deseas eliminar este entregable?');">
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
<!-- MODAL DE ENTREGA SEMANAL (POP-UP OVERLAY OCULTO POR DEFECTO) -->
<div id="modalSemanal" class="modal-overlay">
    <div class="modal-content-cyber">
        <button type="button" class="close-btn-cyber" onclick="cerrarModal()">&times;</button>
        <div class="login-header-cyber">
            <h2>ENTREGA - SEMANA ${semanaNum}</h2>
            <p style="font-size: 0.8rem; color: var(--text-muted); margin-top: 4px;">
                <c:out value="${curso.nombre}"/>
            </p>
        </div>

        <form action="${pageContext.request.contextPath}/trabajo" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="action" value="guardar">
            <input type="hidden" name="cursoId" value="1">
            <input type="hidden" name="semanaNumero" value="${semanaNum}">
            <input type="hidden" name="redirectSemana" value="${semanaNum}">

            <div class="form-group">
                <label><i class="fa-solid fa-heading"></i> Título de la Actividad / Proyecto:</label>
                <input type="text" name="titulo" class="form-control" required placeholder="Ej: Laboratorio Práctico Semana ${semanaNum}">
            </div>

            <div class="form-group">
                <label><i class="fa-solid fa-tags"></i> Categoría / Tag:</label>
                <input type="text" name="categoriaTag" class="form-control" placeholder="Ej: Java/JSP, Base de Datos, Full Stack" value="Laboratorio Práctico">
            </div>

            <div class="form-group">
                <label><i class="fa-solid fa-align-left"></i> Descripción / Detalles Técnicos:</label>
                <textarea name="descripcion" class="form-control" style="height: 80px;" placeholder="Detalles de la solución implementada y tecnologías empleadas..."></textarea>
            </div>

            <div class="form-group">
                <label><i class="fa-brands fa-github"></i> URL del Proyecto en Vivo / Repositorio GitHub:</label>
                <input type="url" name="urlProyecto" class="form-control" placeholder="https://github.com/usuario/repo o https://mi-app.onrender.com">
                <small style="color: var(--text-muted); font-size: 0.72rem;">Opcional: Si el trabajo requiere despliegue en la nube o revisión de código.</small>
            </div>

            <div class="form-group">
                <label><i class="fa-solid fa-file-zipper"></i> Archivo Adjunto (ZIP, RAR, PDF, APK, etc.):</label>
                <input type="file" name="archivoFile" class="form-control" style="padding: 6px;">
            </div>

            <div class="form-group">
                <label><i class="fa-solid fa-sticky-note"></i> Nota Personal:</label>
                <input type="text" name="notaPersonal" class="form-control" placeholder="Ej: Revisar rúbrica de evaluación">
            </div>

            <button type="submit" class="btn-publish-weekly" style="width: 100%; justify-content: center; margin-top: 10px;">
                <i class="fa-solid fa-cloud-arrow-up"></i> CONFIRMAR Y SUBIR ENTREGA
            </button>
        </form>
    </div>
</div>
</c:if>

<script>
    function abrirModal() {
        var modal = document.getElementById('modalSemanal');
        if (modal) {
            modal.style.display = 'flex';
        }
    }
    function cerrarModal() {
        var modal = document.getElementById('modalSemanal');
        if (modal) {
            modal.style.display = 'none';
        }
    }
    document.addEventListener('DOMContentLoaded', function() {
        var modal = document.getElementById('modalSemanal');
        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target === this) cerrarModal();
            });
        }
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') cerrarModal();
        });
    });
</script>

</body>
</html>
