<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Docente | Programación de Aplicación Profesional</title>
    <meta name="description" content="Panel de administración del docente: calificaciones, configuración de semanas y perfil.">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-dark:      #07060f;
            --bg-card:      rgba(255,255,255,0.04);
            --accent-pink:  #ff2a85;
            --accent-purple:#9d4edd;
            --accent-cyan:  #00d4ff;
            --text-main:    #f0eaff;
            --text-sub:     #a0899f;
            --border-pink:  rgba(255,42,133,0.25);
            --border-card:  rgba(255,255,255,0.07);
            --radius-md:    12px;
            --radius-lg:    18px;
            --radius-pill:  50px;
            --transition:   all .25s ease;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { scroll-behavior: smooth; }
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-dark);
            color: var(--text-main);
            display: flex;
            min-height: 100vh;
        }

        /* ── SIDEBAR ── */
        .sidebar {
            width: 270px;
            min-height: 100vh;
            background: rgba(14,12,31,0.98);
            border-right: 1px solid var(--border-pink);
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 36px 18px;
            position: fixed;
            top: 0; left: 0;
            height: 100%;
            overflow-y: auto;
            z-index: 100;
        }
        .sidebar-avatar {
            width: 88px; height: 88px;
            border-radius: 50%;
            overflow: hidden;
            border: 3px solid var(--accent-pink);
            box-shadow: 0 0 22px rgba(255,42,133,.45);
            margin-bottom: 14px;
        }
        .sidebar-avatar img { width:100%; height:100%; object-fit:cover; }
        .sidebar-name { font-size:.98rem; font-weight:700; text-align:center; margin-bottom:4px; }
        .sidebar-badge {
            background: rgba(157,78,221,.2);
            color: #c084fc;
            border: 1px solid #9d4edd;
            font-size:.7rem; padding: 3px 12px;
            border-radius: var(--radius-pill);
            text-transform:uppercase; letter-spacing:1px;
            margin-bottom:28px;
        }
        .sidebar-divider { width:100%; height:1px; background:var(--border-pink); margin:18px 0; }
        .sidebar-menu { width:100%; list-style:none; display:flex; flex-direction:column; gap:6px; }
        .sidebar-menu a {
            display:flex; align-items:center; gap:10px;
            padding:11px 14px; border-radius:var(--radius-md);
            color:var(--text-sub); text-decoration:none;
            font-size:.85rem; font-weight:500;
            transition:var(--transition);
        }
        .sidebar-menu a:hover, .sidebar-menu a.active {
            background: rgba(255,42,133,.12);
            color: var(--accent-pink);
        }
        .sidebar-menu a.active { border-left:3px solid var(--accent-pink); }
        .sidebar-menu a i { width:18px; text-align:center; }
        .logout-btn {
            margin-top: auto;
            width:100%;
            display:flex; align-items:center; gap:10px;
            padding:11px 14px; border-radius:var(--radius-md);
            background: rgba(255,42,133,.1);
            color: var(--accent-pink);
            text-decoration:none; font-size:.85rem; font-weight:600;
            transition:var(--transition); border:1px solid var(--border-pink);
            text-align:center; justify-content:center;
        }
        .logout-btn:hover { background: rgba(255,42,133,.2); }

        /* ── MAIN ── */
        .main-content {
            margin-left: 270px;
            flex: 1;
            padding: 36px;
            min-height: 100vh;
        }
        .page-header {
            margin-bottom: 30px;
        }
        .page-header h1 { font-size:1.7rem; font-weight:800; }
        .page-header p  { color:var(--text-sub); font-size:.9rem; margin-top:4px; }

        /* ── TABS ── */
        .tabs-bar {
            display:flex; gap:8px; margin-bottom:28px;
            border-bottom:1px solid var(--border-card);
            padding-bottom:0;
        }
        .tab-btn {
            background:none; border:none; cursor:pointer;
            color:var(--text-sub); font-size:.88rem; font-weight:500;
            padding:10px 18px; border-radius:var(--radius-md) var(--radius-md) 0 0;
            transition:var(--transition); font-family:inherit;
            border-bottom:2px solid transparent;
        }
        .tab-btn:hover { color:var(--text-main); }
        .tab-btn.active {
            color:var(--accent-pink);
            border-bottom:2px solid var(--accent-pink);
        }

        /* ── STATS ── */
        .stats-grid {
            display:grid; grid-template-columns: repeat(auto-fit, minmax(170px,1fr));
            gap:18px; margin-bottom:28px;
        }
        .stat-card {
            background:var(--bg-card);
            border:1px solid var(--border-card);
            border-radius:var(--radius-lg);
            padding:20px; text-align:center;
            transition:var(--transition);
        }
        .stat-card:hover { border-color:var(--border-pink); }
        .stat-num { font-size:2rem; font-weight:800; color:var(--accent-pink); }
        .stat-lbl { font-size:.78rem; color:var(--text-sub); margin-top:4px; text-transform:uppercase; letter-spacing:.5px; }

        /* ── FILTER BAR ── */
        .filter-bar {
            display:flex; gap:10px; flex-wrap:wrap;
            margin-bottom:22px; align-items:center;
        }
        .filter-bar select, .filter-bar button {
            background:var(--bg-card); border:1px solid var(--border-card);
            color:var(--text-main); padding:9px 16px;
            border-radius:var(--radius-md); font-size:.85rem;
            cursor:pointer; font-family:inherit; transition:var(--transition);
        }
        .filter-bar select:focus, .filter-bar button:hover {
            border-color:var(--accent-pink); outline:none;
        }
        .btn-primary {
            background: linear-gradient(135deg, var(--accent-pink), var(--accent-purple));
            color:#fff; border:none; padding:10px 20px;
            border-radius:var(--radius-md); font-size:.85rem; font-weight:600;
            cursor:pointer; font-family:inherit; transition:var(--transition);
        }
        .btn-primary:hover { opacity:.88; transform:translateY(-1px); }

        /* ── TABLA DE TRABAJOS ── */
        .trabajos-table {
            width:100%; border-collapse:collapse;
            background:var(--bg-card);
            border:1px solid var(--border-card);
            border-radius:var(--radius-lg);
            overflow:hidden;
        }
        .trabajos-table th {
            background:rgba(157,78,221,.12);
            padding:12px 16px; text-align:left;
            font-size:.78rem; font-weight:600;
            text-transform:uppercase; letter-spacing:.5px;
            color:var(--text-sub);
        }
        .trabajos-table td {
            padding:12px 16px; font-size:.85rem;
            border-top:1px solid var(--border-card);
            vertical-align:middle;
        }
        .trabajos-table tr:hover td { background:rgba(255,42,133,.04); }
        .badge {
            display:inline-block; padding:3px 10px;
            border-radius:var(--radius-pill); font-size:.72rem; font-weight:600;
        }
        .badge-entregado { background:rgba(0,212,255,.15); color:#00d4ff; }
        .badge-calificado { background:rgba(52,211,153,.15); color:#34d399; }
        .badge-pendiente  { background:rgba(251,191,36,.15); color:#fbbf24; }
        .badge-observado  { background:rgba(255,42,133,.15); color:var(--accent-pink); }

        /* Botón calificar en tabla */
        .btn-calificar {
            background:rgba(157,78,221,.2); color:#c084fc;
            border:1px solid var(--accent-purple);
            padding:5px 12px; border-radius:var(--radius-md);
            font-size:.78rem; cursor:pointer; font-family:inherit;
            transition:var(--transition);
        }
        .btn-calificar:hover { background:rgba(157,78,221,.35); }

        /* ── CARDS DEL FORMULARIO ── */
        .form-card {
            background:var(--bg-card);
            border:1px solid var(--border-card);
            border-radius:var(--radius-lg);
            padding:28px; margin-bottom:22px;
        }
        .form-card h3 {
            font-size:1rem; font-weight:700; margin-bottom:18px;
            display:flex; align-items:center; gap:8px;
            color:var(--text-main);
        }
        .form-card h3 i { color:var(--accent-pink); }
        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-bottom:16px; }
        .form-row.full { grid-template-columns:1fr; }
        .form-group { display:flex; flex-direction:column; gap:6px; }
        .form-group label { font-size:.8rem; color:var(--text-sub); font-weight:500; }
        .form-group input,
        .form-group select,
        .form-group textarea {
            background:rgba(255,255,255,.06);
            border:1px solid var(--border-card);
            color:var(--text-main); padding:10px 14px;
            border-radius:var(--radius-md); font-size:.88rem;
            font-family:inherit; transition:var(--transition);
            resize:vertical;
        }
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color:var(--accent-pink);
            outline:none;
            box-shadow: 0 0 0 3px rgba(255,42,133,.15);
        }

        /* ── SEMANAS GRID ── */
        .semanas-config-grid {
            display:grid; grid-template-columns:repeat(auto-fill, minmax(320px,1fr));
            gap:18px; margin-top:22px;
        }
        .semana-config-card {
            background:var(--bg-card);
            border:1px solid var(--border-card);
            border-radius:var(--radius-lg);
            padding:20px; transition:var(--transition);
        }
        .semana-config-card:hover { border-color:var(--border-pink); }
        .semana-config-card .semana-num {
            font-size:.72rem; color:var(--accent-pink);
            font-weight:700; text-transform:uppercase;
            letter-spacing:.8px; margin-bottom:6px;
        }
        .semana-config-card .semana-titulo {
            font-size:.92rem; font-weight:600; margin-bottom:10px;
        }
        .semana-config-card .semana-fecha {
            font-size:.78rem; color:var(--text-sub); margin-bottom:14px;
        }
        .btn-edit-semana {
            background:rgba(0,212,255,.1); color:var(--accent-cyan);
            border:1px solid rgba(0,212,255,.3);
            padding:6px 14px; border-radius:var(--radius-md);
            font-size:.78rem; cursor:pointer; font-family:inherit;
            transition:var(--transition);
        }
        .btn-edit-semana:hover { background:rgba(0,212,255,.2); }

        /* ── MODAL ── */
        .modal-overlay {
            position:fixed; inset:0;
            background:rgba(0,0,0,.65); backdrop-filter:blur(4px);
            display:none; align-items:center; justify-content:center;
            z-index:1000; padding:20px;
        }
        .modal-overlay.open { display:flex; }
        .modal-box {
            background:#0e0c1f;
            border:1px solid var(--border-pink);
            border-radius:var(--radius-lg);
            padding:32px; max-width:520px; width:100%;
            max-height:90vh; overflow-y:auto;
        }
        .modal-box h3 {
            font-size:1.05rem; font-weight:700; margin-bottom:20px;
            display:flex; align-items:center; gap:8px;
        }
        .modal-box h3 i { color:var(--accent-pink); }
        .modal-close {
            position:absolute; top:16px; right:18px;
            background:none; border:none; color:var(--text-sub);
            font-size:1.2rem; cursor:pointer;
        }
        .modal-footer { display:flex; gap:10px; justify-content:flex-end; margin-top:20px; }
        .btn-cancel {
            background:rgba(255,255,255,.07); border:1px solid var(--border-card);
            color:var(--text-sub); padding:9px 18px;
            border-radius:var(--radius-md); font-size:.85rem;
            cursor:pointer; font-family:inherit; transition:var(--transition);
        }
        .btn-cancel:hover { color:var(--text-main); }

        /* ── ALERT ── */
        .alert {
            padding:12px 18px; border-radius:var(--radius-md);
            font-size:.88rem; margin-bottom:20px;
            display:flex; align-items:center; gap:10px;
        }
        .alert-success { background:rgba(52,211,153,.12); border:1px solid rgba(52,211,153,.3); color:#34d399; }
        .alert-error   { background:rgba(255,42,133,.12);  border:1px solid var(--border-pink);   color:var(--accent-pink); }

        .empty-state {
            text-align:center; padding:60px 20px; color:var(--text-sub);
        }
        .empty-state i { font-size:3rem; margin-bottom:14px; opacity:.4; }
    </style>
</head>
<body>

<!-- ================================================================ -->
<!-- SIDEBAR DOCENTE                                                   -->
<!-- ================================================================ -->
<nav class="sidebar">
    <div class="sidebar-avatar">
        <img src="${pageContext.request.contextPath}/${usuario.avatar}"
             alt="${usuario.nombreCompleto}"
             onerror="this.src='${pageContext.request.contextPath}/assets/img/user.jpeg'">
    </div>
    <div class="sidebar-name">${usuario.nombreCompleto}</div>
    <div class="sidebar-badge"><i class="fa fa-chalkboard-teacher"></i> Docente</div>
    <div class="sidebar-divider"></div>
    <ul class="sidebar-menu">
        <li>
            <a href="${pageContext.request.contextPath}/panel-docente?tab=entregas"
               class="${tabActiva == 'entregas' ? 'active' : ''}">
                <i class="fa fa-tasks"></i> Entregas
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/panel-docente?tab=semanas"
               class="${tabActiva == 'semanas' ? 'active' : ''}">
                <i class="fa fa-calendar-week"></i> Configurar Semanas
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/panel-docente?tab=perfil"
               class="${tabActiva == 'perfil' ? 'active' : ''}">
                <i class="fa fa-user-circle"></i> Mi Perfil
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/curso">
                <i class="fa fa-book-open"></i> Ver Curso
            </a>
        </li>
    </ul>
    <div class="sidebar-divider"></div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
        <i class="fa fa-sign-out-alt"></i> Cerrar Sesión
    </a>
</nav>

<!-- ================================================================ -->
<!-- CONTENIDO PRINCIPAL                                               -->
<!-- ================================================================ -->
<main class="main-content">

    <!-- Alertas de éxito / error -->
    <c:if test="${not empty msgExito}">
        <div class="alert alert-success">
            <i class="fa fa-check-circle"></i>
            <c:choose>
                <c:when test="${msgExito == 'perfil'}">Perfil actualizado correctamente.</c:when>
                <c:when test="${msgExito == 'password'}">Contraseña cambiada exitosamente.</c:when>
                <c:when test="${msgExito == 'semanas'}">Configuración de semanas guardada.</c:when>
                <c:when test="${msgExito == 'semana'}">Semana actualizada correctamente.</c:when>
                <c:when test="${msgExito == 'calificado'}">Calificación guardada exitosamente.</c:when>
                <c:otherwise>Operación realizada con éxito.</c:otherwise>
            </c:choose>
        </div>
    </c:if>
    <c:if test="${not empty msgError}">
        <div class="alert alert-error">
            <i class="fa fa-exclamation-circle"></i>
            <c:choose>
                <c:when test="${msgError == 'perfil'}">Error al actualizar el perfil. Intenta de nuevo.</c:when>
                <c:when test="${msgError == 'password'}">Contraseña actual incorrecta.</c:when>
                <c:when test="${msgError == 'password_incorrecto'}">La contraseña actual ingresada es incorrecta.</c:when>
                <c:when test="${msgError == 'coincide'}">Las contraseñas nuevas no coinciden.</c:when>
                <c:when test="${msgError == 'semanas'}">Error al configurar semanas.</c:when>
                <c:when test="${msgError == 'semana'}">Error al guardar la semana.</c:when>
                <c:when test="${msgError == 'calificar'}">Error al guardar la calificación.</c:when>
                <c:otherwise>Ocurrió un error. Intenta de nuevo.</c:otherwise>
            </c:choose>
        </div>
    </c:if>

    <!-- Cabecera -->
    <div class="page-header">
        <h1><i class="fa fa-chalkboard-teacher" style="color:var(--accent-pink)"></i>
            Panel del Docente</h1>
        <p>${cursoActual.nombre} &bull; Ciclo ${cursoActual.ciclo} &bull; ${cursoActual.totalSemanas} semanas</p>
    </div>

    <!-- TABS DE NAVEGACIÓN -->
    <div class="tabs-bar">
        <a href="${pageContext.request.contextPath}/panel-docente?tab=entregas">
            <button class="tab-btn ${tabActiva == 'entregas' ? 'active' : ''}">
                <i class="fa fa-tasks"></i> Entregas
            </button>
        </a>
        <a href="${pageContext.request.contextPath}/panel-docente?tab=semanas">
            <button class="tab-btn ${tabActiva == 'semanas' ? 'active' : ''}">
                <i class="fa fa-calendar-week"></i> Semanas
            </button>
        </a>
        <a href="${pageContext.request.contextPath}/panel-docente?tab=perfil">
            <button class="tab-btn ${tabActiva == 'perfil' ? 'active' : ''}">
                <i class="fa fa-user-circle"></i> Mi Perfil
            </button>
        </a>
    </div>

    <!-- ============================================================ -->
    <!-- TAB: ENTREGAS                                                -->
    <!-- ============================================================ -->
    <c:if test="${tabActiva == 'entregas'}">

        <!-- Estadísticas -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-num">${totalEntregables}</div>
                <div class="stat-lbl">Total Entregas</div>
            </div>
            <div class="stat-card">
                <div class="stat-num" style="color:#34d399">${calificadosCount}</div>
                <div class="stat-lbl">Calificados</div>
            </div>
            <div class="stat-card">
                <div class="stat-num" style="color:#fbbf24">${pendientesCount}</div>
                <div class="stat-lbl">Por Calificar</div>
            </div>
            <div class="stat-card">
                <div class="stat-num" style="color:var(--accent-cyan)">${cursoActual.totalSemanas}</div>
                <div class="stat-lbl">Semanas</div>
            </div>
        </div>

        <!-- Filtro por semana -->
        <form method="get" action="${pageContext.request.contextPath}/panel-docente" class="filter-bar">
            <input type="hidden" name="tab" value="entregas">
            <select name="semana" id="filtroSemana" onchange="this.form.submit()">
                <option value="">— Todas las Semanas —</option>
                <c:forEach var="s" items="${listaSemanas}">
                    <option value="${s.numero}" ${semanaFiltro == s.numeroStr ? 'selected' : ''}>
                        Semana ${s.numero}
                    </option>
                </c:forEach>
            </select>
            <c:if test="${not empty semanaFiltro}">
                <a href="${pageContext.request.contextPath}/panel-docente?tab=entregas"
                   style="color:var(--text-sub); font-size:.82rem; text-decoration:none; padding:9px 14px;">
                    <i class="fa fa-times"></i> Limpiar filtro
                </a>
            </c:if>
        </form>

        <!-- Tabla de trabajos -->
        <c:choose>
            <c:when test="${not empty trabajos}">
                <table class="trabajos-table">
                    <thead>
                        <tr>
                            <th>Semana</th>
                            <th>Título</th>
                            <th>Estudiante</th>
                            <th>Fecha</th>
                            <th>Estado</th>
                            <th>Nota</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="t" items="${trabajos}">
                            <tr>
                                <td><span style="color:var(--accent-pink);font-weight:700">S${t.semanaNumero}</span></td>
                                <td>
                                    ${t.titulo}
                                    <c:if test="${not empty t.urlProyecto}">
                                        <a href="${t.urlProyecto}" target="_blank"
                                           style="color:var(--accent-cyan); font-size:.75rem; margin-left:6px;">
                                            <i class="fa fa-external-link-alt"></i>
                                        </a>
                                    </c:if>
                                    <c:if test="${not empty t.archivoNombre}">
                                        <a href="${pageContext.request.contextPath}/download?file=${t.archivoNombre}"
                                           style="color:#c084fc; font-size:.75rem; margin-left:4px;">
                                            <i class="fa fa-download"></i>
                                        </a>
                                    </c:if>
                                </td>
                                <td>${t.estudianteNombre}</td>
                                <td style="font-size:.78rem; color:var(--text-sub)">${t.fechaEntrega}</td>
                                <td>
                                    <span class="badge
                                        ${t.estado == 'Calificado' ? 'badge-calificado' :
                                          t.estado == 'Entregado'  ? 'badge-entregado'  :
                                          t.estado == 'Pendiente'  ? 'badge-pendiente'  : 'badge-observado'}">
                                        ${t.estado}
                                    </span>
                                </td>
                                <td style="font-weight:700; color:#34d399">${not empty t.calificacion ? t.calificacion : '—'}</td>
                                <td>
                                    <button class="btn-calificar"
                                        data-id="${t.id}"
                                        data-semana="${t.semanaNumero}"
                                        data-estado="${t.estado}"
                                        data-cal="<c:out value='${t.calificacion}'/>"
                                        data-obs="<c:out value='${t.observacionDocente}'/>"
                                        onclick="abrirCalificar(this)">
                                        <i class="fa fa-star"></i> Calificar
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="fa fa-inbox"></i>
                    <p>No hay entregas en este filtro todavía.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </c:if>

    <!-- ============================================================ -->
    <!-- TAB: CONFIGURAR SEMANAS                                      -->
    <!-- ============================================================ -->
    <c:if test="${tabActiva == 'semanas'}">

        <!-- Configurar total de semanas -->
        <div class="form-card">
            <h3><i class="fa fa-sliders-h"></i> Configurar Total de Semanas del Curso</h3>
            <form method="post" action="${pageContext.request.contextPath}/panel-docente">
                <input type="hidden" name="action" value="configurarSemanas">
                <div class="form-row">
                    <div class="form-group">
                        <label>Total de Semanas (1 – 52)</label>
                        <input type="number" name="totalSemanas" min="1" max="52"
                               value="${cursoActual.totalSemanas}" required>
                    </div>
                    <div class="form-group" style="justify-content:flex-end; align-items:flex-end;">
                        <button type="submit" class="btn-primary">
                            <i class="fa fa-save"></i> Guardar Configuración
                        </button>
                    </div>
                </div>
                <p style="font-size:.8rem; color:var(--text-sub); margin-top:8px;">
                    <i class="fa fa-info-circle"></i>
                    Si aumentas el número, se crean semanas vacías. Si reduces, las semanas sobrantes
                    dejan de mostrarse (los registros existen en BD).
                </p>
            </form>
        </div>

        <!-- Editar cada semana -->
        <h3 style="font-size:1rem; font-weight:700; margin-bottom:16px;">
            <i class="fa fa-pen-to-square" style="color:var(--accent-pink)"></i>
            Editar Semanas del Curso
        </h3>
        <div class="semanas-config-grid">
            <c:forEach var="s" items="${listaSemanas}">
                <div class="semana-config-card">
                    <div class="semana-num">SEMANA ${s.numero}</div>
                    <div class="semana-titulo">${s.titulo}</div>
                    <div class="semana-fecha">
                        <i class="fa fa-calendar-alt"></i>
                        ${not empty s.fechaLimite ? s.fechaLimite : 'Sin fecha límite'}
                    </div>
                    <button type="button" class="btn-edit-semana"
                        data-id="${s.id}"
                        data-titulo="<c:out value='${s.titulo}'/>"
                        data-desc="<c:out value='${s.descripcion}'/>"
                        data-fecha="<c:out value='${s.fechaLimite}'/>"
                        onclick="abrirEditarSemana(this)">
                        <i class="fa fa-pen"></i> Editar
                    </button>
                </div>
            </c:forEach>
        </div>
    </c:if>

    <!-- ============================================================ -->
    <!-- TAB: MI PERFIL                                               -->
    <!-- ============================================================ -->
    <c:if test="${tabActiva == 'perfil'}">
        <div style="display:grid; grid-template-columns:1fr 1fr; gap:22px;">

            <!-- Actualizar datos de perfil -->
            <div class="form-card">
                <h3><i class="fa fa-user-edit"></i> Actualizar Perfil</h3>
                <form method="post" action="${pageContext.request.contextPath}/panel-docente" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="actualizarPerfil">
                    <div class="form-row full">
                        <div class="form-group">
                            <label>Nombre Completo</label>
                            <input type="text" name="nombreCompleto"
                                   value="${usuario.nombreCompleto}" required>
                        </div>
                    </div>
                    <div class="form-row full">
                        <div class="form-group">
                            <label>Correo Electrónico</label>
                            <input type="email" name="email"
                                   value="${usuario.email}" required>
                        </div>
                    </div>
                    <div class="form-row full">
                        <div class="form-group">
                            <label><i class="fa fa-image"></i> Foto de Perfil / Avatar</label>
                            <div style="display:flex; align-items:center; gap:16px; margin:6px 0;">
                                <img id="avatarPreviewDoc" 
                                     src="${pageContext.request.contextPath}/${not empty usuario.avatar ? usuario.avatar : 'assets/img/anime_portrait.jpg'}"
                                     style="width:60px; height:60px; border-radius:50%; object-fit:cover; border:2px solid var(--accent-pink); box-shadow:0 0 12px rgba(255,42,133,0.35);">
                                <div style="flex:1;">
                                    <input type="file" name="avatarFile" id="avatarFileDoc" accept="image/*"
                                           onchange="previewImage(this, 'avatarPreviewDoc')"
                                           style="font-size:0.83rem; color:var(--text-sub); width:100%;">
                                    <small style="color:var(--text-sub); display:block; margin-top:4px;">
                                        Selecciona una foto desde tu equipo (JPG, PNG, WEBP).
                                    </small>
                                </div>
                            </div>
                            <input type="hidden" name="avatar" value="${usuario.avatar}">
                        </div>
                    </div>
                    <button type="submit" class="btn-primary" style="width:100%; margin-top:8px;">
                        <i class="fa fa-save"></i> Guardar Perfil
                    </button>
                </form>
            </div>

            <!-- Cambiar contraseña -->
            <div class="form-card">
                <h3><i class="fa fa-lock"></i> Cambiar Contraseña</h3>
                <form method="post" action="${pageContext.request.contextPath}/panel-docente">
                    <input type="hidden" name="action" value="cambiarPassword">
                    <div class="form-row full">
                        <div class="form-group">
                            <label>Contraseña Actual</label>
                            <input type="password" name="passwordActual" required>
                        </div>
                    </div>
                    <div class="form-row full">
                        <div class="form-group">
                            <label>Nueva Contraseña (mín. 4 caracteres)</label>
                            <input type="password" name="passwordNueva" minlength="4" required>
                        </div>
                    </div>
                    <div class="form-row full">
                        <div class="form-group">
                            <label>Confirmar Nueva Contraseña</label>
                            <input type="password" name="passwordConfirmar" minlength="4" required>
                        </div>
                    </div>
                    <button type="submit" class="btn-primary" style="width:100%; margin-top:8px;">
                        <i class="fa fa-key"></i> Cambiar Contraseña
                    </button>
                </form>
            </div>
        </div>

        <!-- Info actual -->
        <div class="form-card" style="margin-top:8px;">
            <h3><i class="fa fa-id-badge"></i> Información de la Cuenta</h3>
            <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:14px;">
                <div>
                    <div style="font-size:.75rem; color:var(--text-sub); margin-bottom:4px;">USERNAME</div>
                    <div style="font-weight:600">${usuario.username}</div>
                </div>
                <div>
                    <div style="font-size:.75rem; color:var(--text-sub); margin-bottom:4px;">ROL</div>
                    <div><span class="badge" style="background:rgba(157,78,221,.2);color:#c084fc">DOCENTE</span></div>
                </div>
                <div>
                    <div style="font-size:.75rem; color:var(--text-sub); margin-bottom:4px;">ID</div>
                    <div style="color:var(--accent-pink); font-weight:600">#${usuario.id}</div>
                </div>
            </div>
        </div>
    </c:if>

</main>

<!-- ================================================================ -->
<!-- MODAL: CALIFICAR TRABAJO                                          -->
<!-- ================================================================ -->
<div class="modal-overlay" id="modalCalificar">
    <div class="modal-box" style="position:relative;">
        <h3><i class="fa fa-star"></i> Calificar Entrega</h3>
        <button class="modal-close" onclick="cerrarModal('modalCalificar')">
            <i class="fa fa-times"></i>
        </button>
        <form method="post" action="${pageContext.request.contextPath}/panel-docente" id="formCalificar">
            <input type="hidden" name="action" value="calificar">
            <input type="hidden" name="id"     id="calId">
            <input type="hidden" name="semana" id="calSemana">
            <div class="form-row full" style="margin-bottom:14px;">
                <div class="form-group">
                    <label>Estado</label>
                    <select name="estado" id="calEstado">
                        <option value="Calificado">Calificado</option>
                        <option value="En revisión">En revisión</option>
                        <option value="Observado">Observado</option>
                    </select>
                </div>
            </div>
            <div class="form-row full" style="margin-bottom:14px;">
                <div class="form-group">
                    <label>Nota (ej. 18/20)</label>
                    <input type="text" name="calificacion" id="calNota"
                           placeholder="18/20" pattern="\d{1,2}(/20)?" maxlength="6">
                </div>
            </div>
            <div class="form-row full">
                <div class="form-group">
                    <label>Observación / Retroalimentación</label>
                    <textarea name="observacionDocente" id="calObs" rows="4"
                              placeholder="Excelente trabajo, pero considera..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="cerrarModal('modalCalificar')">Cancelar</button>
                <button type="submit" class="btn-primary"><i class="fa fa-save"></i> Guardar Calificación</button>
            </div>
        </form>
    </div>
</div>

<!-- ================================================================ -->
<!-- MODAL: EDITAR SEMANA                                              -->
<!-- ================================================================ -->
<div class="modal-overlay" id="modalSemana">
    <div class="modal-box" style="position:relative;">
        <h3><i class="fa fa-calendar-week"></i> Editar Semana</h3>
        <button class="modal-close" onclick="cerrarModal('modalSemana')">
            <i class="fa fa-times"></i>
        </button>
        <form method="post" action="${pageContext.request.contextPath}/panel-docente">
            <input type="hidden" name="action"    value="editarSemana">
            <input type="hidden" name="semanaId"  id="editSemanaId">
            <div class="form-row full" style="margin-bottom:14px;">
                <div class="form-group">
                    <label>Título de la Semana</label>
                    <input type="text" name="tituloSemana" id="editSemTitulo" required maxlength="250">
                </div>
            </div>
            <div class="form-row full" style="margin-bottom:14px;">
                <div class="form-group">
                    <label>Descripción / Tarea</label>
                    <textarea name="descripcionSemana" id="editSemDesc" rows="4"></textarea>
                </div>
            </div>
            <div class="form-row full">
                <div class="form-group">
                    <label>Fecha Límite de Entrega</label>
                    <input type="date" name="fechaLimite" id="editSemFecha">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="cerrarModal('modalSemana')">Cancelar</button>
                <button type="submit" class="btn-primary"><i class="fa fa-save"></i> Guardar Semana</button>
            </div>
        </form>
    </div>
</div>

<script>
    function abrirCalificar(btn) {
        var d = btn.dataset;
        document.getElementById('calId').value     = d.id || '';
        document.getElementById('calSemana').value = d.semana || '';
        document.getElementById('calEstado').value = d.estado || 'Calificado';
        document.getElementById('calNota').value   = d.cal || '';
        document.getElementById('calObs').value    = d.obs || '';
        document.getElementById('modalCalificar').classList.add('open');
    }

    function abrirEditarSemana(btn) {
        var d = btn.dataset;
        document.getElementById('editSemanaId').value = d.id || '';
        document.getElementById('editSemTitulo').value = d.titulo || '';
        document.getElementById('editSemDesc').value   = d.desc || '';
        document.getElementById('editSemFecha').value  = d.fecha || '';
        document.getElementById('modalSemana').classList.add('open');
    }

    function cerrarModal(id) {
        document.getElementById(id).classList.remove('open');
    }

    // Cerrar modales clicando fuera
    document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) overlay.classList.remove('open');
        });
    });

    // Previsualización de imágenes seleccionadas
    function previewImage(input, previewId) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var img = document.getElementById(previewId);
                if (img) img.src = e.target.result;
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    // Auto-ocultar alertas
    setTimeout(function() {
        document.querySelectorAll('.alert').forEach(function(a) {
            a.style.transition = 'opacity .5s';
            a.style.opacity = '0';
            setTimeout(function() { a.remove(); }, 500);
        });
    }, 4000);
</script>
</body>
</html>
