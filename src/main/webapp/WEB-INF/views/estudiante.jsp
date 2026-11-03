<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Estudiante | Programación de Aplicación Profesional</title>
    <meta name="description" content="Panel del estudiante: semanas del curso, entregas, portafolio web y perfil.">
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
            --accent-green: #34d399;
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
            width: 260px;
            min-height: 100vh;
            background: rgba(14,12,31,0.98);
            border-right: 1px solid var(--border-pink);
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 32px 16px;
            position: fixed;
            top: 0; left: 0; height: 100%;
            overflow-y: auto;
            z-index: 100;
        }
        .sidebar-avatar {
            width: 82px; height: 82px;
            border-radius: 50%;
            overflow: hidden;
            border: 3px solid var(--accent-pink);
            box-shadow: 0 0 20px rgba(255,42,133,.4);
            margin-bottom: 12px;
        }
        .sidebar-avatar img { width:100%; height:100%; object-fit:cover; }
        .sidebar-name { font-size:.92rem; font-weight:700; text-align:center; margin-bottom:4px; }
        .sidebar-badge {
            background: rgba(255,42,133,.15);
            color: var(--accent-pink);
            border: 1px solid var(--border-pink);
            font-size:.7rem; padding:3px 12px;
            border-radius: var(--radius-pill);
            text-transform:uppercase; letter-spacing:1px;
            margin-bottom:24px;
        }
        .sidebar-divider { width:100%; height:1px; background:var(--border-pink); margin:14px 0; }
        .sidebar-menu { width:100%; list-style:none; display:flex; flex-direction:column; gap:5px; }
        .sidebar-menu a {
            display:flex; align-items:center; gap:10px;
            padding:10px 12px; border-radius:var(--radius-md);
            color:var(--text-sub); text-decoration:none;
            font-size:.83rem; font-weight:500;
            transition:var(--transition);
        }
        .sidebar-menu a:hover, .sidebar-menu a.active {
            background: rgba(255,42,133,.1); color:var(--accent-pink);
        }
        .sidebar-menu a.active { border-left:3px solid var(--accent-pink); }
        .sidebar-menu a i { width:16px; text-align:center; }
        .logout-btn {
            width:100%; display:flex; align-items:center; gap:8px;
            padding:10px 14px; border-radius:var(--radius-md);
            background:rgba(255,42,133,.1); color:var(--accent-pink);
            text-decoration:none; font-size:.83rem; font-weight:600;
            transition:var(--transition); border:1px solid var(--border-pink);
            justify-content:center; margin-top:auto;
        }
        .logout-btn:hover { background:rgba(255,42,133,.2); }

        /* ── MAIN ── */
        .main-content { margin-left:260px; flex:1; padding:32px; min-height:100vh; }
        .page-header { margin-bottom:26px; }
        .page-header h1 { font-size:1.6rem; font-weight:800; }
        .page-header p  { color:var(--text-sub); font-size:.88rem; margin-top:4px; }

        /* ── TABS ── */
        .tabs-bar {
            display:flex; gap:6px; margin-bottom:26px;
            border-bottom:1px solid var(--border-card); padding-bottom:0;
        }
        .tab-link { text-decoration:none; }
        .tab-btn {
            background:none; border:none; cursor:pointer;
            color:var(--text-sub); font-size:.86rem; font-weight:500;
            padding:9px 16px; border-radius:var(--radius-md) var(--radius-md) 0 0;
            transition:var(--transition); font-family:inherit;
            border-bottom:2px solid transparent;
        }
        .tab-btn:hover { color:var(--text-main); }
        .tab-btn.active { color:var(--accent-pink); border-bottom:2px solid var(--accent-pink); }

        /* ── STATS ── */
        .stats-grid {
            display:grid; grid-template-columns:repeat(auto-fit,minmax(140px,1fr));
            gap:14px; margin-bottom:26px;
        }
        .stat-card {
            background:var(--bg-card); border:1px solid var(--border-card);
            border-radius:var(--radius-lg); padding:18px; text-align:center;
            transition:var(--transition);
        }
        .stat-card:hover { border-color:var(--border-pink); }
        .stat-num { font-size:1.8rem; font-weight:800; color:var(--accent-pink); }
        .stat-lbl { font-size:.74rem; color:var(--text-sub); text-transform:uppercase; letter-spacing:.5px; margin-top:3px; }

        /* ── SEMANAS GRID ── */
        .semanas-grid {
            display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr));
            gap:16px;
        }
        .semana-card {
            background:var(--bg-card); border:1px solid var(--border-card);
            border-radius:var(--radius-lg); padding:20px;
            transition:var(--transition); text-decoration:none; color:inherit;
            display:block;
        }
        .semana-card:hover { border-color:var(--border-pink); transform:translateY(-3px); }
        .semana-num-badge {
            display:inline-block; background:rgba(255,42,133,.15);
            color:var(--accent-pink); font-size:.72rem; font-weight:700;
            padding:3px 10px; border-radius:var(--radius-pill);
            margin-bottom:8px; text-transform:uppercase; letter-spacing:.5px;
        }
        .semana-titulo { font-size:.92rem; font-weight:600; margin-bottom:6px; }
        .semana-desc { font-size:.8rem; color:var(--text-sub); line-height:1.5;
                       display:-webkit-box; -webkit-line-clamp:2;
                       -webkit-box-orient:vertical; overflow:hidden; }
        .semana-footer {
            display:flex; justify-content:space-between; align-items:center;
            margin-top:14px; padding-top:12px;
            border-top:1px solid var(--border-card);
        }
        .semana-date { font-size:.76rem; color:var(--text-sub); }
        .semana-count {
            font-size:.76rem; font-weight:600;
            color:var(--accent-cyan);
        }

        /* ── TABLA DE TRABAJOS ── */
        .table-wrap { overflow-x:auto; }
        .trabajos-table {
            width:100%; border-collapse:collapse;
            background:var(--bg-card); border:1px solid var(--border-card);
            border-radius:var(--radius-lg); overflow:hidden;
        }
        .trabajos-table th {
            background:rgba(255,42,133,.08);
            padding:11px 14px; text-align:left;
            font-size:.76rem; font-weight:600;
            text-transform:uppercase; letter-spacing:.5px; color:var(--text-sub);
        }
        .trabajos-table td {
            padding:11px 14px; font-size:.84rem;
            border-top:1px solid var(--border-card); vertical-align:middle;
        }
        .trabajos-table tr:hover td { background:rgba(255,42,133,.03); }
        .badge {
            display:inline-block; padding:3px 10px;
            border-radius:var(--radius-pill); font-size:.7rem; font-weight:600;
        }
        .badge-entregado { background:rgba(0,212,255,.12); color:var(--accent-cyan); }
        .badge-calificado { background:rgba(52,211,153,.12); color:var(--accent-green); }
        .badge-pendiente  { background:rgba(251,191,36,.12); color:#fbbf24; }
        .badge-observado  { background:rgba(255,42,133,.12); color:var(--accent-pink); }

        /* ── PORTAFOLIO ── */
        .portafolio-grid {
            display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr));
            gap:18px;
        }
        .proyecto-card {
            background:var(--bg-card); border:1px solid var(--border-card);
            border-radius:var(--radius-lg); padding:22px;
            transition:var(--transition);
        }
        .proyecto-card:hover { border-color:var(--border-pink); transform:translateY(-3px); }
        .proyecto-titulo { font-size:1rem; font-weight:700; margin-bottom:6px; }
        .proyecto-desc {
            font-size:.82rem; color:var(--text-sub); line-height:1.5; margin-bottom:10px;
            display:-webkit-box; -webkit-line-clamp:3;
            -webkit-box-orient:vertical; overflow:hidden;
        }
        .proyecto-techs {
            display:flex; flex-wrap:wrap; gap:6px; margin-bottom:12px;
        }
        .tech-tag {
            background:rgba(157,78,221,.15); color:#c084fc;
            border:1px solid rgba(157,78,221,.3);
            font-size:.7rem; padding:2px 8px;
            border-radius:var(--radius-pill);
        }
        .proyecto-links { display:flex; gap:8px; margin-bottom:14px; }
        .proyecto-link {
            font-size:.78rem; padding:5px 12px;
            border-radius:var(--radius-md); text-decoration:none;
            font-weight:600; transition:var(--transition);
            display:flex; align-items:center; gap:5px;
        }
        .proyecto-link.demo {
            background:rgba(0,212,255,.12); color:var(--accent-cyan);
            border:1px solid rgba(0,212,255,.3);
        }
        .proyecto-link.repo {
            background:rgba(157,78,221,.12); color:#c084fc;
            border:1px solid rgba(157,78,221,.3);
        }
        .proyecto-link:hover { opacity:.8; transform:translateY(-1px); }
        .proyecto-footer {
            display:flex; justify-content:space-between; align-items:center;
            padding-top:12px; border-top:1px solid var(--border-card);
        }
        .proyecto-categoria {
            font-size:.72rem; color:var(--text-sub);
            background:var(--bg-card); border:1px solid var(--border-card);
            padding:2px 8px; border-radius:var(--radius-pill);
        }
        .proyecto-actions { display:flex; gap:6px; }
        .btn-edit-sm {
            background:rgba(0,212,255,.1); color:var(--accent-cyan);
            border:1px solid rgba(0,212,255,.25);
            padding:4px 10px; border-radius:var(--radius-md);
            font-size:.74rem; cursor:pointer; font-family:inherit;
            transition:var(--transition);
        }
        .btn-edit-sm:hover { background:rgba(0,212,255,.2); }
        .btn-del-sm {
            background:rgba(255,42,133,.1); color:var(--accent-pink);
            border:1px solid var(--border-pink);
            padding:4px 10px; border-radius:var(--radius-md);
            font-size:.74rem; cursor:pointer; font-family:inherit;
            transition:var(--transition);
        }
        .btn-del-sm:hover { background:rgba(255,42,133,.2); }
        .destacado-star { color:#fbbf24; font-size:.8rem; margin-right:4px; }

        /* ── FORMS ── */
        .form-card {
            background:var(--bg-card); border:1px solid var(--border-card);
            border-radius:var(--radius-lg); padding:24px; margin-bottom:20px;
        }
        .form-card h3 {
            font-size:.96rem; font-weight:700; margin-bottom:16px;
            display:flex; align-items:center; gap:8px;
        }
        .form-card h3 i { color:var(--accent-pink); }
        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:14px; margin-bottom:14px; }
        .form-row.full { grid-template-columns:1fr; }
        .form-row.three { grid-template-columns:1fr 1fr 1fr; }
        .form-group { display:flex; flex-direction:column; gap:5px; }
        .form-group label { font-size:.78rem; color:var(--text-sub); font-weight:500; }
        .form-group input,
        .form-group select,
        .form-group textarea {
            background:rgba(255,255,255,.05); border:1px solid var(--border-card);
            color:var(--text-main); padding:9px 12px;
            border-radius:var(--radius-md); font-size:.86rem;
            font-family:inherit; transition:var(--transition); resize:vertical;
        }
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color:var(--accent-pink); outline:none;
            box-shadow: 0 0 0 3px rgba(255,42,133,.12);
        }
        .btn-primary {
            background: linear-gradient(135deg, var(--accent-pink), var(--accent-purple));
            color:#fff; border:none; padding:10px 20px;
            border-radius:var(--radius-md); font-size:.85rem; font-weight:600;
            cursor:pointer; font-family:inherit; transition:var(--transition);
        }
        .btn-primary:hover { opacity:.87; transform:translateY(-1px); }
        .btn-add {
            background:rgba(52,211,153,.12); color:var(--accent-green);
            border:1px solid rgba(52,211,153,.3);
            padding:9px 18px; border-radius:var(--radius-md);
            font-size:.84rem; font-weight:600; cursor:pointer;
            font-family:inherit; transition:var(--transition);
            display:flex; align-items:center; gap:6px;
        }
        .btn-add:hover { background:rgba(52,211,153,.2); }

        /* ── MODAL ── */
        .modal-overlay {
            position:fixed; inset:0;
            background:rgba(0,0,0,.65); backdrop-filter:blur(4px);
            display:none; align-items:center; justify-content:center;
            z-index:1000; padding:20px;
        }
        .modal-overlay.open { display:flex; }
        .modal-box {
            background:#0e0c1f; border:1px solid var(--border-pink);
            border-radius:var(--radius-lg); padding:28px;
            max-width:580px; width:100%; max-height:90vh; overflow-y:auto;
            position:relative;
        }
        .modal-box h3 {
            font-size:1rem; font-weight:700; margin-bottom:18px;
            display:flex; align-items:center; gap:8px;
        }
        .modal-box h3 i { color:var(--accent-pink); }
        .modal-close {
            position:absolute; top:14px; right:16px;
            background:none; border:none; color:var(--text-sub);
            font-size:1.1rem; cursor:pointer;
        }
        .modal-footer { display:flex; gap:10px; justify-content:flex-end; margin-top:18px; }
        .btn-cancel {
            background:rgba(255,255,255,.07); border:1px solid var(--border-card);
            color:var(--text-sub); padding:9px 16px;
            border-radius:var(--radius-md); font-size:.84rem;
            cursor:pointer; font-family:inherit; transition:var(--transition);
        }
        .btn-cancel:hover { color:var(--text-main); }

        /* ── SUBTABS DE EDICIÓN DE PORTAFOLIO ── */
        .subtabs-bar {
            display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 22px;
            background: rgba(255,255,255,0.02); padding: 8px;
            border-radius: var(--radius-lg); border: 1px solid var(--border-card);
        }
        .subtab-btn {
            background: transparent; border: 1px solid transparent;
            color: var(--text-sub); padding: 9px 16px; border-radius: var(--radius-md);
            font-size: .83rem; font-weight: 600; cursor: pointer;
            transition: var(--transition); display: flex; align-items: center; gap: 7px;
            font-family: inherit;
        }
        .subtab-btn:hover { color: var(--text-main); background: rgba(255,255,255,0.04); }
        .subtab-btn.active {
            color: #fff; background: linear-gradient(135deg, rgba(255,42,133,0.25), rgba(157,78,221,0.25));
            border-color: var(--border-pink); box-shadow: 0 0 12px rgba(255,42,133,0.2);
        }
        .subtab-pane { display: none; }
        .subtab-pane.active { display: block; animation: fadeInSubtab .25s ease; }
        @keyframes fadeInSubtab { from { opacity: 0; transform: translateY(4px); } to { opacity: 1; transform: translateY(0); } }
        
        .hint-box {
            background: rgba(0,212,255,0.05); border: 1px dashed rgba(0,212,255,0.25);
            border-radius: var(--radius-md); padding: 12px 14px; margin-bottom: 14px;
            font-size: .8rem; color: #a5f3fc; line-height: 1.5;
        }
        .hint-box code { background: rgba(0,0,0,0.3); padding: 2px 6px; border-radius: 4px; color: var(--accent-pink); }
        .file-upload-box {
            display: flex; align-items: center; gap: 16px;
            background: rgba(255,255,255,0.02); border: 1px solid var(--border-card);
            padding: 12px; border-radius: var(--radius-md); margin-top: 6px;
        }

        /* ── ALERTS ── */
        .alert {
            padding:11px 16px; border-radius:var(--radius-md);
            font-size:.86rem; margin-bottom:18px;
            display:flex; align-items:center; gap:8px;
        }
        .alert-success { background:rgba(52,211,153,.1); border:1px solid rgba(52,211,153,.3); color:var(--accent-green); }
        .alert-error   { background:rgba(255,42,133,.1);  border:1px solid var(--border-pink);   color:var(--accent-pink); }

        .empty-state {
            text-align:center; padding:50px 20px; color:var(--text-sub);
        }
        .empty-state i { font-size:2.5rem; margin-bottom:12px; opacity:.35; display:block; }
    </style>
</head>
<body>

<!-- ================================================================ -->
<!-- SIDEBAR ESTUDIANTE                                                -->
<!-- ================================================================ -->
<nav class="sidebar">
    <div class="sidebar-avatar">
        <img src="${pageContext.request.contextPath}/${usuario.avatar}"
             alt="${usuario.nombreCompleto}"
             onerror="this.src='${pageContext.request.contextPath}/assets/img/user.jpeg'">
    </div>
    <div class="sidebar-name">${usuario.nombreCompleto}</div>
    <div class="sidebar-badge"><i class="fa fa-user-graduate"></i> Estudiante</div>
    <div class="sidebar-divider"></div>
    <ul class="sidebar-menu">
        <li>
            <a href="${pageContext.request.contextPath}/panel-estudiante?tab=semanas"
               class="${tabActiva == 'semanas' ? 'active' : ''}">
                <i class="fa fa-calendar-week"></i> Mis Semanas
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/panel-estudiante?tab=portafolio"
               class="${tabActiva == 'portafolio' ? 'active' : ''}">
                <i class="fa fa-briefcase"></i> Mi Portafolio
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/panel-estudiante?tab=perfil"
               class="${tabActiva == 'perfil' ? 'active' : ''}">
                <i class="fa fa-user-circle"></i> Mi Perfil
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/curso">
                <i class="fa fa-book-open"></i> Ver Curso Completo
            </a>
        </li>
    </ul>
    <div class="sidebar-divider"></div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
        <i class="fa fa-sign-out-alt"></i> Cerrar Sesión
    </a>
</nav>

<!-- ================================================================ -->
<!-- MAIN                                                              -->
<!-- ================================================================ -->
<main class="main-content">

    <!-- Alertas -->
    <c:if test="${not empty msgExito}">
        <div class="alert alert-success">
            <i class="fa fa-check-circle"></i>
            <c:choose>
                <c:when test="${msgExito == 'perfil'}">Perfil actualizado correctamente.</c:when>
                <c:when test="${msgExito == 'password'}">Contraseña cambiada exitosamente.</c:when>
                <c:when test="${msgExito == 'username'}">Username actualizado correctamente.</c:when>
                <c:when test="${msgExito == 'proyecto'}">Proyecto guardado en el portafolio.</c:when>
                <c:when test="${msgExito == 'eliminado'}">Proyecto eliminado del portafolio.</c:when>
                <c:otherwise>Operación realizada con éxito.</c:otherwise>
            </c:choose>
        </div>
    </c:if>
    <c:if test="${not empty msgError}">
        <div class="alert alert-error">
            <i class="fa fa-exclamation-circle"></i>
            <c:choose>
                <c:when test="${msgError == 'perfil'}">Error al actualizar el perfil. Verifica que el correo no esté repetido.</c:when>
                <c:when test="${msgError == 'password'}">Contraseña actual incorrecta.</c:when>
                <c:when test="${msgError == 'password_incorrecto'}">La contraseña actual ingresada es incorrecta.</c:when>
                <c:when test="${msgError == 'coincide'}">Las contraseñas nuevas no coinciden.</c:when>
                <c:when test="${msgError == 'username_tomado'}">Ese nombre de usuario ya está en uso.</c:when>
                <c:when test="${msgError == 'proyecto'}">Error al guardar el proyecto.</c:when>
                <c:otherwise>Ocurrió un error. Intenta de nuevo.</c:otherwise>
            </c:choose>
        </div>
    </c:if>

    <!-- Cabecera -->
    <div class="page-header">
        <h1><i class="fa fa-user-graduate" style="color:var(--accent-pink)"></i>
            Hola, ${usuario.nombreCompleto}</h1>
        <p>${curso.nombre} &bull; Ciclo ${curso.ciclo} &bull; ${curso.totalSemanas} semanas</p>
    </div>

    <!-- TABS -->
    <div class="tabs-bar">
        <a href="${pageContext.request.contextPath}/panel-estudiante?tab=semanas" class="tab-link">
            <button class="tab-btn ${tabActiva == 'semanas' ? 'active' : ''}">
                <i class="fa fa-calendar-week"></i> Semanas
            </button>
        </a>
        <a href="${pageContext.request.contextPath}/panel-estudiante?tab=portafolio" class="tab-link">
            <button class="tab-btn ${tabActiva == 'portafolio' ? 'active' : ''}">
                <i class="fa fa-briefcase"></i> Portafolio
            </button>
        </a>
        <a href="${pageContext.request.contextPath}/panel-estudiante?tab=perfil" class="tab-link">
            <button class="tab-btn ${tabActiva == 'perfil' ? 'active' : ''}">
                <i class="fa fa-user-circle"></i> Mi Perfil
            </button>
        </a>
    </div>

    <!-- ============================================================ -->
    <!-- TAB: SEMANAS                                                  -->
    <!-- ============================================================ -->
    <c:if test="${tabActiva == 'semanas'}">

        <!-- Estadísticas -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-num">${totalTrabajos}</div>
                <div class="stat-lbl">Entregas Totales</div>
            </div>
            <div class="stat-card">
                <div class="stat-num" style="color:var(--accent-green)">${calificadosCount}</div>
                <div class="stat-lbl">Calificados</div>
            </div>
            <div class="stat-card">
                <div class="stat-num" style="color:#fbbf24">${pendientesCount}</div>
                <div class="stat-lbl">En Revisión</div>
            </div>
            <div class="stat-card">
                <div class="stat-num" style="color:var(--accent-cyan)">${promedioNotas}</div>
                <div class="stat-lbl">Promedio</div>
            </div>
        </div>

        <!-- Grid de semanas -->
        <c:choose>
            <c:when test="${not empty semanas}">
                <div class="semanas-grid">
                    <c:forEach var="s" items="${semanas}">
                        <a href="${pageContext.request.contextPath}/curso?semana=${s.numero}"
                           class="semana-card">
                            <div class="semana-num-badge">Semana ${s.numero}</div>
                            <div class="semana-titulo">${s.titulo}</div>
                            <div class="semana-desc">${not empty s.descripcion ? s.descripcion : 'Actividades de la semana.'}</div>
                            <div class="semana-footer">
                                <div class="semana-date">
                                    <i class="fa fa-calendar-alt"></i>
                                    ${not empty s.fechaLimite ? s.fechaLimite : 'Sin fecha'}
                                </div>
                                <div class="semana-count">
                                    <i class="fa fa-upload"></i>
                                    Ver entregas
                                </div>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="fa fa-calendar-times"></i>
                    <p>No hay semanas configuradas aún.</p>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- Resumen de trabajos -->
        <c:if test="${not empty trabajos}">
            <h3 style="font-size:1rem; font-weight:700; margin: 24px 0 14px;">
                <i class="fa fa-clipboard-list" style="color:var(--accent-pink)"></i>
                Mis Últimas Entregas
            </h3>
            <div class="table-wrap">
                <table class="trabajos-table">
                    <thead>
                        <tr>
                            <th>Sem.</th>
                            <th>Título</th>
                            <th>Fecha</th>
                            <th>Estado</th>
                            <th>Nota</th>
                            <th>Observación</th>
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
                                           style="color:var(--accent-cyan); font-size:.74rem; margin-left:5px;">
                                            <i class="fa fa-external-link-alt"></i>
                                        </a>
                                    </c:if>
                                    <c:if test="${not empty t.archivoNombre}">
                                        <a href="${pageContext.request.contextPath}/download?file=${t.archivoNombre}"
                                           style="color:#c084fc; font-size:.74rem; margin-left:4px;">
                                            <i class="fa fa-download"></i>
                                        </a>
                                    </c:if>
                                </td>
                                <td style="font-size:.76rem; color:var(--text-sub)">${t.fechaEntrega}</td>
                                <td>
                                    <span class="badge
                                        ${t.estado == 'Calificado' ? 'badge-calificado' :
                                          t.estado == 'Entregado'  ? 'badge-entregado'  :
                                          t.estado == 'Pendiente'  ? 'badge-pendiente'  : 'badge-observado'}">
                                        ${t.estado}
                                    </span>
                                </td>
                                <td style="font-weight:700; color:var(--accent-green)">
                                    ${not empty t.calificacion ? t.calificacion : '—'}
                                </td>
                                <td style="font-size:.78rem; color:var(--text-sub); max-width:200px;">
                                    ${not empty t.observacionDocente ? t.observacionDocente : '—'}
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>
    </c:if>

    <!-- ============================================================ -->
    <!-- TAB: PORTAFOLIO WEB                                          -->
    <!-- ============================================================ -->
    <c:if test="${tabActiva == 'portafolio'}">
        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; margin-bottom:20px;">
            <div>
                <h2 style="font-size:1.3rem; font-weight:800; display:flex; align-items:center; gap:8px;">
                    <i class="fa fa-gem" style="color:var(--accent-pink)"></i>
                    Personalización del Portafolio Web
                </h2>
                <p style="color:var(--text-sub); font-size:.82rem; margin-top:3px;">
                    Modifica el contenido del Inicio, Sobre Mí, Educación, Habilidades y Proyectos. Sube imágenes desde tus archivos.
                </p>
            </div>
            <div style="display:flex; gap:10px; align-items:center;">
                <a href="${pageContext.request.contextPath}/index.jsp" target="_blank" class="btn-primary"
                   style="text-decoration:none; display:inline-flex; align-items:center; gap:8px; padding:9px 16px;">
                    <i class="fa fa-external-link-alt"></i> Ver Mi Portafolio en Vivo
                </a>
            </div>
        </div>

        <!-- Barra de Sub-Pestañas -->
        <div class="subtabs-bar">
            <button type="button" class="subtab-btn active" onclick="switchPortSubtab('tabHero', this)">
                <i class="fa fa-house"></i> 1. Inicio / Hero
            </button>
            <button type="button" class="subtab-btn" onclick="switchPortSubtab('tabAbout', this)">
                <i class="fa fa-user-astronaut"></i> 2. Sobre Mí
            </button>
            <button type="button" class="subtab-btn" onclick="switchPortSubtab('tabEdu', this)">
                <i class="fa fa-graduation-cap"></i> 3. Educación
            </button>
            <button type="button" class="subtab-btn" onclick="switchPortSubtab('tabSkills', this)">
                <i class="fa fa-bolt"></i> 4. Habilidades
            </button>
            <button type="button" class="subtab-btn" onclick="switchPortSubtab('tabProyectos', this)">
                <i class="fa fa-laptop-code"></i> 5. Mis Proyectos (${fn:length(proyectos)})
            </button>
        </div>

        <!-- Formulario General de Configuración Web -->
        <form method="post" action="${pageContext.request.contextPath}/panel-estudiante"
              enctype="multipart/form-data" id="formPortafolioConfig">
            <input type="hidden" name="action" value="guardarPortafolioWeb">

            <!-- SUBTAB 1: INICIO / HERO -->
            <div id="tabHero" class="subtab-pane active">
                <div class="form-card">
                    <h3><i class="fa fa-house"></i> Sección de Inicio (Hero) & Redes Sociales</h3>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Nombre Mostrado en Portada</label>
                            <input type="text" name="heroNombre" 
                                   value="<c:out value='${not empty portafolioConfig.heroNombre ? portafolioConfig.heroNombre : usuario.nombreCompleto}'/>" required>
                        </div>
                        <div class="form-group">
                            <label>Título / Saludo Principal</label>
                            <input type="text" name="heroTitulo" 
                                   value="<c:out value='${not empty portafolioConfig.heroTitulo ? portafolioConfig.heroTitulo : \"Hola, soy \" += usuario.nombreCompleto}'/>" required>
                        </div>
                    </div>

                    <div class="form-row full">
                        <div class="form-group">
                            <label>Frases Máquina de Escribir (separadas por comas)</label>
                            <input type="text" name="heroFrases" 
                                   value="<c:out value='${not empty portafolioConfig.heroFrases ? portafolioConfig.heroFrases : \"Ingeniera de Software, Desarrolladora Full Stack Java, Creadora de Experiencias Web\"}'/>" required>
                            <small style="color:var(--text-sub); font-size:.76rem; margin-top:2px;">
                                Ejemplo: Ingeniera de Software, Desarrolladora Java, Especialista en Base de Datos
                            </small>
                        </div>
                    </div>

                    <div class="form-row full">
                        <div class="form-group">
                            <label>Descripción de Presentación</label>
                            <textarea name="heroDescripcion" rows="3" required><c:out value="${not empty portafolioConfig.heroDescripcion ? portafolioConfig.heroDescripcion : 'Desarrolladora de software apasionada por transformar conceptos complejos en experiencias web interactivas, seguras y de alto rendimiento.'}"/></textarea>
                        </div>
                    </div>

                    <div class="form-row full">
                        <div class="form-group">
                            <label><i class="fa fa-image"></i> Foto de Portada / Hero</label>
                            <div class="file-upload-box">
                                <img id="heroImgPreview" 
                                     src="${pageContext.request.contextPath}/${not empty portafolioConfig.heroImagen ? portafolioConfig.heroImagen : 'assets/img/Img_May.jpeg'}"
                                     style="width:72px; height:72px; border-radius:50%; object-fit:cover; border:2px solid var(--accent-pink); box-shadow:0 0 14px rgba(255,42,133,0.4);">
                                <div style="flex:1;">
                                    <input type="file" name="heroImagenFile" id="heroImgFile" accept="image/*"
                                           onchange="previewImage(this, 'heroImgPreview')">
                                    <small style="color:var(--text-sub); display:block; margin-top:4px;">
                                        Selecciona una foto desde tus archivos para tu portada web.
                                    </small>
                                </div>
                            </div>
                            <input type="hidden" name="heroImagen" value="<c:out value='${portafolioConfig.heroImagen}'/>">
                        </div>
                    </div>

                    <h4 style="font-size:.88rem; margin:22px 0 10px; color:var(--accent-cyan); display:flex; align-items:center; gap:6px;">
                        <i class="fa fa-share-nodes"></i> Enlaces de Contacto y Redes Sociales
                    </h4>
                    <div class="form-row">
                        <div class="form-group">
                            <label><i class="fa-brands fa-github"></i> URL GitHub</label>
                            <input type="url" name="githubUrl" value="<c:out value='${portafolioConfig.githubUrl}'/>" placeholder="https://github.com/tu-usuario">
                        </div>
                        <div class="form-group">
                            <label><i class="fa-brands fa-linkedin"></i> URL LinkedIn</label>
                            <input type="url" name="linkedinUrl" value="<c:out value='${portafolioConfig.linkedinUrl}'/>" placeholder="https://linkedin.com/in/tu-perfil">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label><i class="fa-brands fa-instagram"></i> URL Instagram</label>
                            <input type="url" name="instagramUrl" value="<c:out value='${portafolioConfig.instagramUrl}'/>" placeholder="https://instagram.com/tu-perfil">
                        </div>
                        <div class="form-group">
                            <label><i class="fa-brands fa-whatsapp"></i> Número de WhatsApp (con código de país, ej: 51952374069)</label>
                            <input type="text" name="whatsappNumero" value="<c:out value='${portafolioConfig.whatsappNumero}'/>" placeholder="51952374069">
                        </div>
                    </div>

                    <div style="margin-top:22px; display:flex; justify-content:flex-end;">
                        <button type="submit" class="btn-primary">
                            <i class="fa fa-save"></i> Guardar Cambios de Inicio
                        </button>
                    </div>
                </div>
            </div>

            <!-- SUBTAB 2: SOBRE MÍ -->
            <div id="tabAbout" class="subtab-pane">
                <div class="form-card">
                    <h3><i class="fa fa-user-astronaut"></i> Sección Sobre Mí</h3>

                    <div class="form-row full">
                        <div class="form-group">
                            <label>Título de la Sección</label>
                            <input type="text" name="aboutTitulo" 
                                   value="<c:out value='${not empty portafolioConfig.aboutTitulo ? portafolioConfig.aboutTitulo : \"Sobre Mí\"}'/>" required>
                        </div>
                    </div>

                    <div class="form-row full">
                        <div class="form-group">
                            <label>Descripción / Introducción Personal</label>
                            <textarea name="aboutDescripcion" rows="3" required><c:out value="${not empty portafolioConfig.aboutDescripcion ? portafolioConfig.aboutDescripcion : 'Desarrollo de experiencias web y sistemas académicos de alto impacto a través de código estructurado, diseño responsivo y arquitectura modular.'}"/></textarea>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label><i class="fa fa-compass"></i> Mi Filosofía</label>
                            <textarea name="aboutFilosofia" rows="3"><c:out value="${not empty portafolioConfig.aboutFilosofia ? portafolioConfig.aboutFilosofia : 'Combinar la disciplina técnica con un diseño de interfaz intuitivo y estilizado, garantizando código mantenible, libre de vulnerabilidades y de alto rendimiento.'}"/></textarea>
                        </div>
                        <div class="form-group">
                            <label><i class="fa fa-bullseye"></i> La Misión</label>
                            <textarea name="aboutMision" rows="3"><c:out value="${not empty portafolioConfig.aboutMision ? portafolioConfig.aboutMision : 'Construir plataformas educativas y soluciones empresariales con arquitectura robusta en Java, facilitando la gestión de evidencias, código fuente y aplicaciones desplegadas.'}"/></textarea>
                        </div>
                    </div>

                    <div class="form-row full">
                        <div class="form-group">
                            <label><i class="fa fa-image"></i> Imagen / Ilustración Sobre Mí</label>
                            <div class="file-upload-box">
                                <img id="aboutImgPreview" 
                                     src="${pageContext.request.contextPath}/${not empty portafolioConfig.aboutImagen ? portafolioConfig.aboutImagen : 'assets/img/sakura_fan.jpg'}"
                                     style="width:80px; height:60px; border-radius:8px; object-fit:cover; border:1px solid var(--border-pink);">
                                <div style="flex:1;">
                                    <input type="file" name="aboutImagenFile" id="aboutImgFile" accept="image/*"
                                           onchange="previewImage(this, 'aboutImgPreview')">
                                    <small style="color:var(--text-sub); display:block; margin-top:4px;">
                                        Selecciona una imagen desde tus archivos para la sección Sobre Mí.
                                    </small>
                                </div>
                            </div>
                            <input type="hidden" name="aboutImagen" value="<c:out value='${portafolioConfig.aboutImagen}'/>">
                        </div>
                    </div>

                    <div style="margin-top:22px; display:flex; justify-content:flex-end;">
                        <button type="submit" class="btn-primary">
                            <i class="fa fa-save"></i> Guardar Cambios de Sobre Mí
                        </button>
                    </div>
                </div>
            </div>

            <!-- SUBTAB 3: EDUCACIÓN -->
            <div id="tabEdu" class="subtab-pane">
                <div class="form-card">
                    <h3><i class="fa fa-graduation-cap"></i> Sección Educación & Trayectoria Académica</h3>
                    <div class="hint-box">
                        <i class="fa fa-info-circle"></i> <strong>Instrucciones:</strong> Ingresa cada estudio o formación en una línea separada con el siguiente formato:<br>
                        <code>Título del Grado o Carrera | Institución Educativa | Período o Detalles</code>
                    </div>

                    <div class="form-row full">
                        <div class="form-group">
                            <label>Listado de Estudios (un registro por línea)</label>
                            <textarea id="educacionTextarea" name="educacionData" rows="8" style="font-family:monospace; font-size:.85rem; line-height:1.6;"><c:out value="${portafolioConfig.educacionData}"/></textarea>
                        </div>
                    </div>

                    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:16px;">
                        <button type="button" class="btn-cancel" onclick="insertarPlantillaEducacion()">
                            <i class="fa fa-magic"></i> Cargar Plantilla de Ejemplo
                        </button>
                        <button type="submit" class="btn-primary">
                            <i class="fa fa-save"></i> Guardar Educación
                        </button>
                    </div>
                </div>
            </div>

            <!-- SUBTAB 4: HABILIDADES -->
            <div id="tabSkills" class="subtab-pane">
                <div class="form-card">
                    <h3><i class="fa fa-bolt"></i> Sección de Habilidades Técnicas & Blandas</h3>
                    <div class="hint-box">
                        <i class="fa fa-info-circle"></i> <strong>Instrucciones:</strong> Ingresa cada habilidad y su porcentaje (del 1 al 100) en una línea separada con el formato:<br>
                        <code>Nombre de la Habilidad | Porcentaje</code><br>
                        <em>Ejemplo: Java 21 & Jakarta Servlets (MVC) | 95</em>
                    </div>

                    <div class="form-row full">
                        <div class="form-group">
                            <label>Listado de Habilidades (un registro por línea)</label>
                            <textarea id="habilidadesTextarea" name="habilidadesData" rows="8" style="font-family:monospace; font-size:.85rem; line-height:1.6;"><c:out value="${portafolioConfig.habilidadesData}"/></textarea>
                        </div>
                    </div>

                    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:16px;">
                        <button type="button" class="btn-cancel" onclick="insertarPlantillaHabilidades()">
                            <i class="fa fa-magic"></i> Cargar Plantilla de Ejemplo
                        </button>
                        <button type="submit" class="btn-primary">
                            <i class="fa fa-save"></i> Guardar Habilidades
                        </button>
                    </div>
                </div>
            </div>

        </form>

        <!-- SUBTAB 5: MIS PROYECTOS -->
        <div id="tabProyectos" class="subtab-pane">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:18px;">
                <h3 style="font-size:1.05rem; font-weight:700;">
                    <i class="fa fa-folder-open" style="color:var(--accent-pink)"></i> Proyectos en Exhibición
                </h3>
                <button class="btn-add" onclick="abrirModalProyecto()">
                    <i class="fa fa-plus"></i> Agregar Proyecto
                </button>
            </div>

            <c:choose>
                <c:when test="${not empty proyectos}">
                    <div class="portafolio-grid">
                        <c:forEach var="p" items="${proyectos}">
                            <div class="proyecto-card">
                                <c:if test="${not empty p.imagenPreview}">
                                    <div style="height:140px; border-radius:var(--radius-md); overflow:hidden; margin-bottom:12px; border:1px solid var(--border-card);">
                                        <img src="${pageContext.request.contextPath}/${p.imagenPreview}" alt="${p.titulo}"
                                             style="width:100%; height:100%; object-fit:cover;">
                                    </div>
                                </c:if>
                                <div class="proyecto-titulo">
                                    <c:if test="${p.destacado}">
                                        <span class="destacado-star"><i class="fa fa-star"></i></span>
                                    </c:if>
                                    ${p.titulo}
                                </div>
                                <div class="proyecto-desc">${p.descripcion}</div>

                                <c:if test="${not empty p.tecnologias}">
                                    <div class="proyecto-techs">
                                        <c:forEach var="tech" items="${fn:split(p.tecnologias, ',')}">
                                            <span class="tech-tag">${fn:trim(tech)}</span>
                                        </c:forEach>
                                    </div>
                                </c:if>

                                <div class="proyecto-links">
                                    <c:if test="${not empty p.urlDemo}">
                                        <a href="${p.urlDemo}" target="_blank" class="proyecto-link demo">
                                            <i class="fa fa-external-link-alt"></i> Demo
                                        </a>
                                    </c:if>
                                    <c:if test="${not empty p.urlRepositorio}">
                                        <a href="${p.urlRepositorio}" target="_blank" class="proyecto-link repo">
                                            <i class="fa-brands fa-github"></i> Código
                                        </a>
                                    </c:if>
                                </div>

                                <div class="proyecto-footer">
                                    <span class="proyecto-categoria">${p.categoria}</span>
                                    <div class="proyecto-actions">
                                        <button class="btn-edit-sm"
                                            data-id="${p.id}"
                                            data-titulo="<c:out value='${p.titulo}'/>"
                                            data-desc="<c:out value='${p.descripcion}'/>"
                                            data-tech="<c:out value='${p.tecnologias}'/>"
                                            data-demo="<c:out value='${p.urlDemo}'/>"
                                            data-repo="<c:out value='${p.urlRepositorio}'/>"
                                            data-cat="<c:out value='${p.categoria}'/>"
                                            data-dest="${p.destacado}"
                                            data-orden="${p.orden}"
                                            data-img="<c:out value='${p.imagenPreview}'/>"
                                            onclick="abrirEditarProyecto(this)">
                                            <i class="fa fa-pen"></i>
                                        </button>
                                        <button class="btn-del-sm"
                                            data-id="${p.id}"
                                            data-titulo="<c:out value='${p.titulo}'/>"
                                            onclick="abrirEliminarProyecto(this)">
                                            <i class="fa fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fa fa-folder-open"></i>
                        <p>Tu portafolio aún no tiene proyectos.</p>
                        <p style="font-size:.82rem; margin-top:6px;">Agrega tu primer proyecto con el botón de arriba.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </c:if>

    <!-- ============================================================ -->
    <!-- TAB: MI PERFIL                                               -->
    <!-- ============================================================ -->
    <c:if test="${tabActiva == 'perfil'}">
        <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px;">

            <!-- Actualizar perfil -->
            <div class="form-card">
                <h3><i class="fa fa-user-edit"></i> Actualizar Perfil</h3>
                <form method="post" action="${pageContext.request.contextPath}/panel-estudiante" enctype="multipart/form-data">
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
                            <input type="email" name="email" value="${usuario.email}" required>
                        </div>
                    </div>
                    <div class="form-row full">
                        <div class="form-group">
                            <label><i class="fa fa-image"></i> Foto de Perfil / Avatar</label>
                            <div style="display:flex; align-items:center; gap:16px; margin:6px 0;">
                                <img id="avatarPreviewEst" 
                                     src="${pageContext.request.contextPath}/${not empty usuario.avatar ? usuario.avatar : 'assets/img/Img_May.jpeg'}"
                                     style="width:65px; height:65px; border-radius:50%; object-fit:cover; border:2px solid var(--accent-pink); box-shadow:0 0 12px rgba(255,42,133,0.35);">
                                <div style="flex:1;">
                                    <input type="file" name="avatarFile" id="avatarFileEst" accept="image/*"
                                           onchange="previewImage(this, 'avatarPreviewEst')"
                                           style="font-size:.82rem; padding:6px;">
                                    <small style="color:var(--text-sub); display:block; margin-top:4px;">
                                        Selecciona una imagen desde tus archivos (JPG, PNG, WEBP).
                                    </small>
                                </div>
                            </div>
                            <input type="text" name="avatar" value="${usuario.avatar}"
                                   placeholder="assets/img/mi-foto.jpg (o deja vacío si subes archivo)">
                        </div>
                    </div>
                    <button type="submit" class="btn-primary" style="width:100%">
                        <i class="fa fa-save"></i> Guardar Perfil
                    </button>
                </form>
            </div>

            <!-- Seguridad -->
            <div style="display:flex; flex-direction:column; gap:20px;">

                <!-- Cambiar username -->
                <div class="form-card">
                    <h3><i class="fa fa-at"></i> Cambiar Username</h3>
                    <form method="post" action="${pageContext.request.contextPath}/panel-estudiante">
                        <input type="hidden" name="action" value="cambiarUsername">
                        <div class="form-group" style="margin-bottom:12px;">
                            <label>Username Actual</label>
                            <input type="text" value="${usuario.username}" disabled
                                   style="opacity:.5">
                        </div>
                        <div class="form-group" style="margin-bottom:14px;">
                            <label>Nuevo Username</label>
                            <input type="text" name="nuevoUsername" required minlength="3"
                                   placeholder="mi_nuevo_username">
                        </div>
                        <button type="submit" class="btn-primary" style="width:100%">
                            <i class="fa fa-user-check"></i> Cambiar Username
                        </button>
                    </form>
                </div>

                <!-- Cambiar contraseña -->
                <div class="form-card">
                    <h3><i class="fa fa-lock"></i> Cambiar Contraseña</h3>
                    <form method="post" action="${pageContext.request.contextPath}/panel-estudiante">
                        <input type="hidden" name="action" value="cambiarPassword">
                        <div class="form-group" style="margin-bottom:10px;">
                            <label>Contraseña Actual</label>
                            <input type="password" name="passwordActual" required>
                        </div>
                        <div class="form-group" style="margin-bottom:10px;">
                            <label>Nueva Contraseña</label>
                            <input type="password" name="passwordNueva" minlength="4" required>
                        </div>
                        <div class="form-group" style="margin-bottom:14px;">
                            <label>Confirmar Contraseña</label>
                            <input type="password" name="passwordConfirmar" minlength="4" required>
                        </div>
                        <button type="submit" class="btn-primary" style="width:100%">
                            <i class="fa fa-key"></i> Cambiar Contraseña
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Info de cuenta -->
        <div class="form-card" style="margin-top:6px;">
            <h3><i class="fa fa-id-card"></i> Información de la Cuenta</h3>
            <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:14px;">
                <div>
                    <div style="font-size:.74rem; color:var(--text-sub); margin-bottom:3px;">USERNAME</div>
                    <div style="font-weight:600">${usuario.username}</div>
                </div>
                <div>
                    <div style="font-size:.74rem; color:var(--text-sub); margin-bottom:3px;">ROL</div>
                    <span class="badge badge-entregado">ESTUDIANTE</span>
                </div>
                    <div style="font-size:.74rem; color:var(--text-sub); margin-bottom:3px;">ID</div>
                    <div style="color:var(--accent-pink); font-weight:600">#${usuario.id}</div>
                </div>
            </div>
        </div>
    </c:if>

</main>

<!-- ================================================================ -->
<!-- MODAL: AGREGAR / EDITAR PROYECTO                                  -->
<!-- ================================================================ -->
<div class="modal-overlay" id="modalProyecto">
    <div class="modal-box">
        <h3 id="modalProyectoTitulo"><i class="fa fa-plus-circle"></i> Nuevo Proyecto</h3>
        <button class="modal-close" onclick="cerrarModal('modalProyecto')">
            <i class="fa fa-times"></i>
        </button>
        <form method="post" action="${pageContext.request.contextPath}/panel-estudiante"
              enctype="multipart/form-data" id="formProyecto">
            <input type="hidden" name="action"     id="proyectoAction" value="agregarProyecto">
            <input type="hidden" name="proyectoId" id="proyectoId"     value="">
            <input type="hidden" name="imagenPreview" id="pImgPreview" value="">

            <div class="form-row full" style="margin-bottom:12px;">
                <div class="form-group">
                    <label>Título del Proyecto *</label>
                    <input type="text" name="titulo" id="pTitulo" required maxlength="200">
                </div>
            </div>
            <div class="form-row full" style="margin-bottom:12px;">
                <div class="form-group">
                    <label>Descripción</label>
                    <textarea name="descripcion" id="pDesc" rows="3"
                              placeholder="Descripción breve del proyecto..."></textarea>
                </div>
            </div>

            <!-- Selector de Imagen de Proyecto desde archivos -->
            <div class="form-row full" style="margin-bottom:12px;">
                <div class="form-group">
                    <label><i class="fa fa-image"></i> Imagen o Captura del Proyecto</label>
                    <div style="display:flex; align-items:center; gap:14px; margin-top:4px;">
                        <img id="previewImgProy" src="" 
                             style="width:80px; height:55px; border-radius:8px; object-fit:cover; border:1px solid var(--border-pink); display:none;">
                        <div style="flex:1;">
                            <input type="file" name="imagenPreviewFile" id="pImgFile" accept="image/*"
                                   onchange="previewImage(this, 'previewImgProy')"
                                   style="font-size:.82rem; padding:6px;">
                            <small style="color:var(--text-sub); display:block; margin-top:3px;">
                                Elige una captura desde tus archivos (PNG, JPG, WEBP).
                            </small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="form-row" style="margin-bottom:12px;">
                <div class="form-group">
                    <label>Tecnologías (separadas por coma)</label>
                    <input type="text" name="tecnologias" id="pTech"
                           placeholder="Java, JSP, MySQL">
                </div>
                <div class="form-group">
                    <label>Categoría</label>
                    <select name="categoria" id="pCategoria">
                        <option value="Aplicación Web">Aplicación Web</option>
                        <option value="API REST">API REST</option>
                        <option value="Móvil">Móvil</option>
                        <option value="Escritorio">Escritorio</option>
                        <option value="Base de Datos">Base de Datos</option>
                        <option value="Otro">Otro</option>
                    </select>
                </div>
            </div>
            <div class="form-row" style="margin-bottom:12px;">
                <div class="form-group">
                    <label>URL Demo (opcional)</label>
                    <input type="url" name="urlDemo" id="pUrlDemo"
                           placeholder="https://mi-app.render.com">
                </div>
                <div class="form-group">
                    <label>URL Repositorio (opcional)</label>
                    <input type="url" name="urlRepositorio" id="pUrlRepo"
                           placeholder="https://github.com/usuario/repo">
                </div>
            </div>
            <div class="form-row" style="margin-bottom:14px;">
                <div class="form-group">
                    <label>Orden de Visualización</label>
                    <input type="number" name="orden" id="pOrden" value="0" min="0" max="100">
                </div>
                <div class="form-group" style="justify-content:flex-end;">
                    <label style="display:flex; align-items:center; gap:8px; cursor:pointer; margin-top:22px;">
                        <input type="checkbox" name="destacado" id="pDestacado" value="true"
                                style="width:18px; height:18px; accent-color:var(--accent-pink);">
                        <span style="font-size:.84rem; color:var(--text-main);">Marcar como destacado</span>
                    </label>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="cerrarModal('modalProyecto')">Cancelar</button>
                <button type="submit" class="btn-primary">
                    <i class="fa fa-save"></i> Guardar Proyecto
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Modal confirmar eliminación -->
<div class="modal-overlay" id="modalEliminar">
    <div class="modal-box" style="max-width:380px;">
        <h3><i class="fa fa-trash-alt"></i> Eliminar Proyecto</h3>
        <p style="font-size:.88rem; color:var(--text-sub); margin-bottom:18px;">
            ¿Seguro que deseas eliminar <strong id="elimProyTitulo"></strong>?
            Esta acción no se puede deshacer.
        </p>
        <form method="post" action="${pageContext.request.contextPath}/panel-estudiante">
            <input type="hidden" name="action"     value="eliminarProyecto">
            <input type="hidden" name="proyectoId" id="elimProyId">
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="cerrarModal('modalEliminar')">Cancelar</button>
                <button type="submit" class="btn-primary" style="background:var(--accent-pink)">
                    <i class="fa fa-trash"></i> Sí, Eliminar
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    // Conmutador de subtabs de portafolio
    function switchPortSubtab(subtabId, btn) {
        document.querySelectorAll('.subtab-pane').forEach(function(pane) {
            pane.classList.remove('active');
        });
        document.querySelectorAll('.subtab-btn').forEach(function(b) {
            b.classList.remove('active');
        });
        var target = document.getElementById(subtabId);
        if (target) target.classList.add('active');
        if (btn) btn.classList.add('active');
    }

    // Previsualización de imágenes seleccionadas en inputs tipo file
    function previewImage(input, previewId) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var preview = document.getElementById(previewId);
                if (preview) {
                    preview.src = e.target.result;
                    preview.style.display = 'block';
                }
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    // Plantillas de ejemplo para Educación y Habilidades
    function insertarPlantillaEducacion() {
        var txt = document.getElementById('educacionTextarea');
        if (txt) {
            txt.value = "Programación de Aplicación Profesional | Instituto Andres A. Caceres D. • Ciclo 2026-II | Enfoque en Arquitectura MVC, Servlets, JSP y JDBC\n" +
                        "Desarrollo de Aplicaciones Web y Gestión de Datos | Ecosistema Java Empresarial, MySQL y Apache Tomcat | Modelado relacional, PreparedStatement y seguridad web\n" +
                        "Diseño UI/UX y Desarrollo Frontend Cyber-Sakura | Interfaces Modernas con CSS3, Glassmorphism y Responsive Design | 2026";
        }
    }

    function insertarPlantillaHabilidades() {
        var txt = document.getElementById('habilidadesTextarea');
        if (txt) {
            txt.value = "Java 21 & Jakarta Servlets (MVC) | 95\n" +
                        "JavaServer Pages (JSP) & JSTL | 92\n" +
                        "HTML5 / CSS3 / Glassmorphism | 90\n" +
                        "MySQL & MySQL Workbench (JDBC) | 92\n" +
                        "Apache Tomcat 10 & Despliegue Cloud | 88\n" +
                        "Gestión de Repositorios & Git/GitHub | 90";
        }
    }

    function abrirModalProyecto() {
        document.getElementById('modalProyectoTitulo').innerHTML =
            '<i class="fa fa-plus-circle"></i> Nuevo Proyecto';
        document.getElementById('proyectoAction').value = 'agregarProyecto';
        document.getElementById('proyectoId').value = '';
        document.getElementById('pImgPreview').value = '';
        var prev = document.getElementById('previewImgProy');
        if (prev) { prev.src = ''; prev.style.display = 'none'; }
        document.getElementById('formProyecto').reset();
        document.getElementById('modalProyecto').classList.add('open');
    }

    function abrirEditarProyecto(btn) {
        var d = btn.dataset;
        document.getElementById('modalProyectoTitulo').innerHTML =
            '<i class="fa fa-pen"></i> Editar Proyecto';
        document.getElementById('proyectoAction').value = 'editarProyecto';
        document.getElementById('proyectoId').value     = d.id || '';
        document.getElementById('pTitulo').value        = d.titulo || '';
        document.getElementById('pDesc').value          = d.desc   || '';
        document.getElementById('pTech').value          = d.tech   || '';
        document.getElementById('pUrlDemo').value       = d.demo   || '';
        document.getElementById('pUrlRepo').value       = d.repo   || '';
        document.getElementById('pCategoria').value     = d.cat    || 'Aplicación Web';
        document.getElementById('pDestacado').checked   = (d.dest === 'true');
        document.getElementById('pOrden').value         = d.orden  || 0;
        document.getElementById('pImgPreview').value    = d.img    || '';
        
        var prev = document.getElementById('previewImgProy');
        if (prev) {
            if (d.img && d.img.trim() !== '') {
                prev.src = '${pageContext.request.contextPath}/' + d.img;
                prev.style.display = 'block';
            } else {
                prev.src = '';
                prev.style.display = 'none';
            }
        }
        document.getElementById('modalProyecto').classList.add('open');
    }

    function abrirEliminarProyecto(btn) {
        var d = btn.dataset;
        document.getElementById('elimProyId').value        = d.id || '';
        document.getElementById('elimProyTitulo').textContent = d.titulo || '';
        document.getElementById('modalEliminar').classList.add('open');
    }

    function cerrarModal(id) {
        document.getElementById(id).classList.remove('open');
    }

    document.querySelectorAll('.modal-overlay').forEach(function(o) {
        o.addEventListener('click', function(e) {
            if (e.target === o) o.classList.remove('open');
        });
    });

    // Auto-ocultar alertas a los 4s
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
