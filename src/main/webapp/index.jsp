<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="com.example.demo.dao.PortafolioConfigDAO, com.example.demo.dao.PortafolioDAO, com.example.demo.model.PortafolioConfig, com.example.demo.model.PortafolioProyecto, java.util.List" %>
<%
    PortafolioConfig pConfig = (PortafolioConfig) request.getAttribute("pConfig");
    if (pConfig == null) {
        pConfig = new PortafolioConfigDAO().obtenerConfiguracionPrincipal();
        request.setAttribute("pConfig", pConfig);
    }
    List<PortafolioProyecto> proyectosDestacados = (List<PortafolioProyecto>) request.getAttribute("proyectosDestacados");
    if (proyectosDestacados == null) {
        Long estId = (pConfig != null && pConfig.getEstudianteId() != null && pConfig.getEstudianteId() > 0) ? pConfig.getEstudianteId() : 2L;
        proyectosDestacados = new PortafolioDAO().obtenerPorEstudiante(estId);
        request.setAttribute("proyectosDestacados", proyectosDestacados);
    }
%>
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${not empty pConfig.heroNombre ? pConfig.heroNombre : 'MAYLIN'}"/> | Portafolio Personal & LMS Académico</title>
            <!-- Google Fonts & FontAwesome Icons -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portfolio-cyber.css">
            <style>
                /* MODAL Y FORMULARIO DE ACCESO */
                .modal-overlay {
                    display: none;
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(5, 4, 15, 0.88);
                    backdrop-filter: blur(12px);
                    z-index: 2000;
                    justify-content: center;
                    align-items: center;
                }

                .modal-content-cyber {
                    background: #0e0c1f;
                    border: 2px solid var(--border-pink-glow);
                    border-radius: var(--radius-lg);
                    padding: 35px;
                    width: 90%;
                    max-width: 440px;
                    max-height: 88vh;
                    overflow-y: auto;
                    box-shadow: 0 0 45px rgba(255, 42, 133, 0.5);
                    position: relative;
                    animation: fadeInModal 0.3s ease-out;
                }

                @keyframes fadeInModal {
                    from {
                        opacity: 0;
                        transform: translateY(-20px) scale(0.95);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0) scale(1);
                    }
                }

                .close-btn-cyber {
                    position: absolute;
                    top: 15px;
                    right: 20px;
                    background: none;
                    border: none;
                    color: var(--text-sub);
                    font-size: 1.6rem;
                    cursor: pointer;
                    transition: var(--transition);
                }

                .close-btn-cyber:hover {
                    color: var(--pink-neon);
                    transform: rotate(90deg);
                }

                .login-header-cyber {
                    text-align: center;
                    margin-bottom: 22px;
                }

                .login-header-cyber h2 {
                    font-family: var(--font-heading);
                    font-size: 1.3rem;
                    color: #fff;
                    letter-spacing: 2px;
                }

                .error-message {
                    background: rgba(225, 29, 72, 0.2);
                    border: 1px solid #e11d48;
                    color: #fecdd3;
                    padding: 10px 14px;
                    border-radius: 8px;
                    font-size: 0.82rem;
                    margin-bottom: 18px;
                    text-align: center;
                }

                .login-form-cyber {
                    display: flex;
                    flex-direction: column;
                    gap: 16px;
                }

                .form-control {
                    width: 100%;
                    background: rgba(14, 12, 31, 0.8);
                    border: 1px solid var(--border-pink);
                    border-radius: 8px;
                    padding: 12px 14px;
                    color: #fff;
                    font-family: var(--font-body);
                    font-size: 0.9rem;
                    outline: none;
                    transition: var(--transition);
                }

                .form-control:focus {
                    border-color: var(--pink-neon);
                    box-shadow: 0 0 12px rgba(255, 42, 133, 0.4);
                }

                .form-group label {
                    display: block;
                    color: var(--text-sub);
                    font-size: 0.82rem;
                    margin-bottom: 6px;
                }

                .btn-send {
                    background: var(--pink-gradient);
                    color: #fff;
                    padding: 12px 24px;
                    border-radius: var(--radius-pill);
                    border: none;
                    font-weight: 600;
                    font-size: 0.9rem;
                    cursor: pointer;
                    box-shadow: var(--pink-glow);
                    transition: var(--transition);
                    width: 100%;
                    display: inline-flex;
                    justify-content: center;
                    align-items: center;
                    gap: 8px;
                }

                .btn-send:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 0 30px rgba(255, 42, 133, 0.8);
                }

                /* CAPA DE TRANSICIÓN */
                .circus-overlay {
                    display: none;
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: radial-gradient(circle, #2d0b4e 0%, #06040d 100%);
                    z-index: 3000;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                }

                .portal-vortex {
                    width: 110px;
                    height: 110px;
                    border: 6px dashed var(--pink-neon);
                    border-radius: 50%;
                    animation: spinVortex 1.5s linear infinite;
                    margin-bottom: 20px;
                }

                .transition-text {
                    font-family: var(--font-heading);
                    color: #fff;
                    letter-spacing: 3px;
                    font-size: 1.1rem;
                }

                @keyframes spinVortex {
                    0% {
                        transform: rotate(0deg) scale(1);
                    }

                    50% {
                        transform: rotate(180deg) scale(1.15);
                        border-color: #00f0ff;
                    }

                    100% {
                        transform: rotate(360deg) scale(1);
                    }
                }

                .mobile-open {
                    display: flex !important;
                    flex-direction: column;
                    position: absolute;
                    top: 70px;
                    left: 0;
                    width: 100%;
                    background: rgba(9, 7, 19, 0.95);
                    padding: 20px;
                    border-bottom: 1px solid var(--border-pink);
                }

                /* BURBUJA FLOTANTE DE WHATSAPP */
                .whatsapp-float-btn {
                    position: fixed;
                    bottom: 30px;
                    right: 30px;
                    width: 60px;
                    height: 60px;
                    background: linear-gradient(135deg, #25D366 0%, #128C7E 100%);
                    color: #ffffff !important;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 32px;
                    box-shadow: 0 4px 20px rgba(37, 211, 102, 0.45), 0 0 15px rgba(37, 211, 102, 0.3);
                    z-index: 2500;
                    text-decoration: none;
                    transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
                    animation: pulseWhatsapp 2.2s infinite;
                }

                .whatsapp-float-btn:hover {
                    transform: scale(1.12) translateY(-4px);
                    box-shadow: 0 8px 30px rgba(37, 211, 102, 0.7), 0 0 25px rgba(37, 211, 102, 0.5);
                    color: #ffffff !important;
                }

                .whatsapp-tooltip {
                    position: absolute;
                    right: 74px;
                    background: rgba(14, 12, 31, 0.95);
                    color: #ffffff;
                    padding: 8px 14px;
                    border-radius: 20px;
                    font-size: 0.82rem;
                    font-weight: 600;
                    white-space: nowrap;
                    border: 1px solid rgba(37, 211, 102, 0.4);
                    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5);
                    pointer-events: none;
                    opacity: 0;
                    transform: translateX(10px);
                    transition: all 0.3s ease;
                    display: flex;
                    align-items: center;
                    gap: 6px;
                }

                .whatsapp-float-btn:hover .whatsapp-tooltip {
                    opacity: 1;
                    transform: translateX(0);
                }

                @keyframes pulseWhatsapp {
                    0% {
                        box-shadow: 0 0 0 0 rgba(37, 211, 102, 0.6), 0 4px 20px rgba(37, 211, 102, 0.4);
                    }

                    70% {
                        box-shadow: 0 0 0 16px rgba(37, 211, 102, 0), 0 4px 20px rgba(37, 211, 102, 0.4);
                    }

                    100% {
                        box-shadow: 0 0 0 0 rgba(37, 211, 102, 0), 0 4px 20px rgba(37, 211, 102, 0.4);
                    }
                }
            </style>
        </head>

        <body>

            <!-- HEADER & BARRA DE NAVEGACIÓN -->
            <header class="cyber-header">
                <div class="brand-badge"><c:out value="${fn:substring(not empty pConfig.heroNombre ? pConfig.heroNombre : 'MAY', 0, 3)}"/></div>

                <button class="menu-toggle" id="mobileMenuBtn">
                    <i class="fa-solid fa-bars"></i>
                </button>

                <ul class="nav-links" id="navLinks">
                    <li><a href="#hero" class="active">INICIO</a></li>
                    <li><a href="#about">SOBRE MÍ</a></li>
                    <li><a href="#education">EDUCACIÓN</a></li>
                    <li><a href="#skills">HABILIDADES</a></li>
                    <c:if test="${not empty proyectosDestacados}">
                        <li><a href="#projects">PROYECTOS</a></li>
                    </c:if>
                </ul>

                <div style="display: flex; gap: 12px; align-items: center;">
                    <button id="openLoginBtn" class="btn-hire">
                        <i class="fa-solid fa-right-to-bracket"></i> ACCESO AL PORTAL LMS
                    </button>
                </div>
            </header>

            <!-- HERO SECTION -->
            <section id="hero" class="hero-section">
                <div class="hero-content">
                    <div class="hero-subtitle"><c:out value="${not empty pConfig.heroNombre ? pConfig.heroNombre : 'MAYLIN ZAMUDIO'}"/></div>
                    <h1 class="hero-title">
                        <span class="sakura-icon"></span> <c:out value="${not empty pConfig.heroTitulo ? pConfig.heroTitulo : 'Hola, soy MAYLIN'}"/> <span class="sakura-icon"></span>
                    </h1>

                    <div class="typing-container">
                        <span id="typingText"></span><span class="typing-cursor"></span>
                    </div>

                    <p class="hero-description">
                        <c:out value="${not empty pConfig.heroDescripcion ? pConfig.heroDescripcion : 'Desarrolladora de software apasionada por transformar conceptos complejos en experiencias web interactivas, seguras y de alto rendimiento. Especializada en Java, Jakarta Servlets, JSP, JDBC, MySQL y Arquitectura MVC.'}"/>
                    </p>

                    <div class="hero-cta">
                        <div class="social-links">
                            <c:if test="${not empty pConfig.githubUrl}">
                                <a href="${pConfig.githubUrl}" target="_blank" class="social-icon" title="GitHub"><i
                                        class="fa-brands fa-github"></i></a>
                            </c:if>
                            <c:if test="${not empty pConfig.linkedinUrl}">
                                <a href="${pConfig.linkedinUrl}" target="_blank" class="social-icon" title="LinkedIn"><i
                                        class="fa-brands fa-linkedin-in"></i></a>
                            </c:if>
                            <c:if test="${not empty pConfig.instagramUrl}">
                                <a href="${pConfig.instagramUrl}" target="_blank" class="social-icon" title="Instagram"><i
                                        class="fa-brands fa-instagram"></i></a>
                            </c:if>
                        </div>
                    </div>
                </div>

                <div class="hero-portrait-wrapper">
                    <div class="portrait-glow-ring"></div>
                    <img src="${pageContext.request.contextPath}/${not empty pConfig.heroImagen ? pConfig.heroImagen : 'assets/img/Img_May.jpeg'}" class="portrait-img"
                        alt="Portrait">
                </div>
            </section>

            <!-- TECH STACK BAR -->
            <div class="tech-stack-bar">
                <div class="tech-pill"><i class="fa-brands fa-java"></i> Java 21 & Servlets</div>
                <div class="tech-pill"><i class="fa-solid fa-code"></i> JSP & JSTL</div>
                <div class="tech-pill"><i class="fa-solid fa-database"></i> MySQL Relacional</div>
                <div class="tech-pill"><i class="fa-solid fa-server"></i> Apache Tomcat 10</div>
                <div class="tech-pill"><i class="fa-solid fa-cloud"></i> Ready for Cloud</div>
            </d            <!-- ABOUT ME SECTION -->
            <section id="about" class="section-container">
                <div class="section-tag">CONÓCEME</div>
                <h2 class="section-title">
                    <span class="sakura-icon"></span> <c:out value="${not empty pConfig.aboutTitulo ? pConfig.aboutTitulo : 'Sobre Mí'}"/> <span class="sakura-icon"></span>
                </h2>
                <p class="section-desc">
                    <c:out value="${not empty pConfig.aboutDescripcion ? pConfig.aboutDescripcion : 'Desarrollo de experiencias web y sistemas académicos de alto impacto a través de código estructurado, diseño responsivo y arquitectura modular.'}"/>
                </p>

                <div class="about-grid">
                    <div class="stats-container">
                        <div class="stat-card">
                            <div class="stat-number">1</div>
                            <div class="stat-label">Curso Especializado</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number">16</div>
                            <div class="stat-label">Semanas Académicas</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number">100%</div>
                            <div class="stat-label">Java & JSP Puro (MVC)</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-number">5</div>
                            <div class="stat-label">Créditos Técnicos</div>
                        </div>
                    </div>

                    <div class="about-visual">
                        <img src="${pageContext.request.contextPath}/${not empty pConfig.aboutImagen ? pConfig.aboutImagen : 'assets/img/sakura_fan.jpg'}" class="fan-img"
                            alt="Sobre Mí">
                    </div>

                    <div class="cards-column">
                        <div class="info-glass-card">
                            <h4><i class="fa-solid fa-compass"></i> Mi Filosofía</h4>
                            <p><c:out value="${not empty pConfig.aboutFilosofia ? pConfig.aboutFilosofia : 'Combinar la disciplina técnica con un diseño de interfaz intuitivo y estilizado, garantizando código mantenible, libre de vulnerabilidades y de alto rendimiento.'}"/></p>
                        </div>
                        <div class="info-glass-card">
                            <h4><i class="fa-solid fa-bullseye"></i> La Misión</h4>
                            <p><c:out value="${not empty pConfig.aboutMision ? pConfig.aboutMision : 'Construir plataformas educativas y soluciones empresariales con arquitectura robusta en Java, facilitando la gestión de evidencias, código fuente y aplicaciones desplegadas.'}"/></p>
                        </div>
                    </div>
                </div>
            </section>

            <!-- EDUCATION SECTION -->
            <section id="education" class="section-container">
                <div class="section-tag">TRAYECTORIA ACADÉMICA</div>
                <h2 class="section-title">
                    <span class="sakura-icon"></span> Educación & Formación <span class="sakura-icon"></span>
                </h2>
                <p class="section-desc">Formación técnica profesional especializada en ingeniería de software, arquitectura web backend y bases de datos relacionales.</p>

                <div class="education-container">
                    <div class="sakura-illustration">
                        <img src="${pageContext.request.contextPath}/assets/img/sakura_branch.jpg" class="sakura-img"
                            alt="Sakura Branch">
                    </div>

                    <div class="timeline-list">
                        <c:choose>
                            <c:when test="${not empty pConfig.listaEducacion}">
                                <c:forEach var="edu" items="${pConfig.listaEducacion}">
                                    <div class="timeline-card">
                                        <h4><c:out value="${edu.titulo}"/></h4>
                                        <div class="institution"><c:out value="${edu.institucion}"/></div>
                                        <div class="period"><c:out value="${edu.periodo}"/></div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="timeline-card">
                                    <h4>Programación de Aplicación Profesional</h4>
                                    <div class="institution">Instituto Andres A. Caceres D. • Ciclo 2026-II</div>
                                    <div class="period">Enfoque en Arquitectura MVC, Servlets, JSP y JDBC</div>
                                </div>
                                <div class="timeline-card">
                                    <h4>Desarrollo de Aplicaciones Web y Gestión de Datos</h4>
                                    <div class="institution">Ecosistema Java Empresarial, MySQL y Apache Tomcat</div>
                                    <div class="period">Modelado relacional, PreparedStatement y seguridad web</div>
                                </div>
                                <div class="timeline-card">
                                    <h4>Diseño UI/UX y Desarrollo Frontend Cyber-Sakura</h4>
                                    <div class="institution">Interfaces Modernas con CSS3, Glassmorphism y Responsive Design</div>
                                    <div class="period">2026</div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </section>

            <!-- MY SKILLS SECTION -->
            <section id="skills" class="section-container">
                <div class="section-tag">STACK TECNOLÓGICO</div>
                <h2 class="section-title">
                    <span class="sakura-icon"></span> Mis Habilidades <span class="sakura-icon"></span>
                </h2>
                <p class="section-desc">Dominio de tecnologías backend, modelado relacional en MySQL Workbench y construcción de interfaces interactivas.</p>

                <div class="skills-container">
                    <c:choose>
                        <c:when test="${not empty pConfig.listaHabilidades}">
                            <div>
                                <c:forEach var="sk" items="${pConfig.listaHabilidades}" varStatus="status">
                                    <c:if test="${status.index % 2 == 0}">
                                        <div class="skill-item">
                                            <div class="skill-info">
                                                <span class="skill-name"><c:out value="${sk.nombre}"/></span>
                                                <span class="skill-percent">${sk.porcentaje}%</span>
                                            </div>
                                            <div class="progress-bar-bg">
                                                <div class="progress-fill" style="width: ${sk.porcentaje}%;"></div>
                                            </div>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>

                            <div style="text-align: center;">
                                <img src="${pageContext.request.contextPath}/assets/img/sakura_branch.jpg"
                                    style="max-width: 180px; filter: drop-shadow(0 0 20px rgba(255,42,133,0.5));" alt="Branch">
                            </div>

                            <div>
                                <c:forEach var="sk" items="${pConfig.listaHabilidades}" varStatus="status">
                                    <c:if test="${status.index % 2 != 0}">
                                        <div class="skill-item">
                                            <div class="skill-info">
                                                <span class="skill-name"><c:out value="${sk.nombre}"/></span>
                                                <span class="skill-percent">${sk.porcentaje}%</span>
                                            </div>
                                            <div class="progress-bar-bg">
                                                <div class="progress-fill" style="width: ${sk.porcentaje}%;"></div>
                                            </div>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div>
                                <div class="skill-item">
                                    <div class="skill-info">
                                        <span class="skill-name">Java 21 & Jakarta Servlets (MVC)</span>
                                        <span class="skill-percent">95%</span>
                                    </div>
                                    <div class="progress-bar-bg">
                                        <div class="progress-fill" style="width: 95%;"></div>
                                    </div>
                                </div>
                                <div class="skill-item">
                                    <div class="skill-info">
                                        <span class="skill-name">JavaServer Pages (JSP) & JSTL</span>
                                        <span class="skill-percent">92%</span>
                                    </div>
                                    <div class="progress-bar-bg">
                                        <div class="progress-fill" style="width: 92%;"></div>
                                    </div>
                                </div>
                                <div class="skill-item">
                                    <div class="skill-info">
                                        <span class="skill-name">HTML5 / CSS3 / Glassmorphism</span>
                                        <span class="skill-percent">90%</span>
                                    </div>
                                    <div class="progress-bar-bg">
                                        <div class="progress-fill" style="width: 90%;"></div>
                                    </div>
                                </div>
                            </div>
                            <div style="text-align: center;">
                                <img src="${pageContext.request.contextPath}/assets/img/sakura_branch.jpg"
                                    style="max-width: 180px; filter: drop-shadow(0 0 20px rgba(255,42,133,0.5));" alt="Branch">
                            </div>
                            <div>
                                <div class="skill-item">
                                    <div class="skill-info">
                                        <span class="skill-name">MySQL & MySQL Workbench (JDBC)</span>
                                        <span class="skill-percent">92%</span>
                                    </div>
                                    <div class="progress-bar-bg">
                                        <div class="progress-fill" style="width: 92%;"></div>
                                    </div>
                                </div>
                                <div class="skill-item">
                                    <div class="skill-info">
                                        <span class="skill-name">Apache Tomcat 10 & Despliegue Cloud</span>
                                        <span class="skill-percent">88%</span>
                                    </div>
                                    <div class="progress-bar-bg">
                                        <div class="progress-fill" style="width: 88%;"></div>
                                    </div>
                                </div>
                                <div class="skill-item">
                                    <div class="skill-info">
                                        <span class="skill-name">Gestión de Repositorios & Git/GitHub</span>
                                        <span class="skill-percent">90%</span>
                                    </div>
                                    <div class="progress-bar-bg">
                                        <div class="progress-fill" style="width: 90%;"></div>
                                    </div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>

            <!-- PROYECTOS EN EXHIBICIÓN SECTION -->
            <c:if test="${not empty proyectosDestacados}">
                <section id="projects" class="section-container">
                    <div class="section-tag">PORTAFOLIO DE TRABAJOS</div>
                    <h2 class="section-title">
                        <span class="sakura-icon"></span> Mis Proyectos <span class="sakura-icon"></span>
                    </h2>
                    <p class="section-desc">Aplicaciones desarrolladas con Java puro, Servlets, JSP y JDBC.</p>
                    
                    <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(300px, 1fr)); gap:22px; margin-top:30px;">
                        <c:forEach var="proy" items="${proyectosDestacados}">
                            <div style="background:rgba(255,255,255,0.03); border:1px solid rgba(255,255,255,0.08); border-radius:18px; padding:22px; transition:all .3s ease;"
                                 onmouseover="this.style.borderColor='rgba(255,42,133,0.5)'; this.style.transform='translateY(-4px)';"
                                 onmouseout="this.style.borderColor='rgba(255,255,255,0.08)'; this.style.transform='none';">
                                <c:if test="${not empty proy.imagenPreview}">
                                    <div style="height:160px; border-radius:12px; overflow:hidden; margin-bottom:14px; border:1px solid rgba(255,42,133,0.2);">
                                        <img src="${pageContext.request.contextPath}/${proy.imagenPreview}" alt="${proy.titulo}"
                                             style="width:100%; height:100%; object-fit:cover;">
                                    </div>
                                </c:if>
                                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                                    <span style="font-size:.72rem; text-transform:uppercase; letter-spacing:1px; color:var(--pink-neon); background:rgba(255,42,133,0.12); padding:3px 10px; border-radius:50px;">
                                        ${proy.categoria}
                                    </span>
                                    <c:if test="${proy.destacado}">
                                        <span style="color:#fbbf24; font-size:.82rem;"><i class="fa fa-star"></i> Destacado</span>
                                    </c:if>
                                </div>
                                <h3 style="font-size:1.1rem; font-weight:700; margin-bottom:8px; color:#fff;">${proy.titulo}</h3>
                                <p style="font-size:.84rem; color:var(--text-sub); line-height:1.5; margin-bottom:14px;">${proy.descripcion}</p>
                                
                                <c:if test="${not empty proy.tecnologias}">
                                    <div style="display:flex; flex-wrap:wrap; gap:6px; margin-bottom:16px;">
                                        <c:forEach var="tech" items="${fn:split(proy.tecnologias, ',')}">
                                            <span style="font-size:.7rem; padding:2px 8px; border-radius:50px; background:rgba(157,78,221,0.15); color:#c084fc; border:1px solid rgba(157,78,221,0.3);">
                                                ${fn:trim(tech)}
                                            </span>
                                        </c:forEach>
                                    </div>
                                </c:if>
                                
                                <div style="display:flex; gap:10px;">
                                    <c:if test="${not empty proy.urlDemo}">
                                        <a href="${proy.urlDemo}" target="_blank"
                                           style="font-size:.78rem; padding:6px 12px; border-radius:8px; background:rgba(0,212,255,0.12); color:#00d4ff; border:1px solid rgba(0,212,255,0.3); text-decoration:none; display:inline-flex; align-items:center; gap:6px; font-weight:600;">
                                            <i class="fa fa-external-link-alt"></i> Demo
                                        </a>
                                    </c:if>
                                    <c:if test="${not empty proy.urlRepositorio}">
                                        <a href="${proy.urlRepositorio}" target="_blank"
                                           style="font-size:.78rem; padding:6px 12px; border-radius:8px; background:rgba(157,78,221,0.12); color:#c084fc; border:1px solid rgba(157,78,221,0.3); text-decoration:none; display:inline-flex; align-items:center; gap:6px; font-weight:600;">
                                            <i class="fa-brands fa-github"></i> Código
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </section>
            </c:if>

            <!-- BURBUJA FLOTANTE DE WHATSAPP -->
            <c:set var="numWa" value="${not empty pConfig.whatsappNumero ? pConfig.whatsappNumero : '51952374069'}"/>
            <a href="https://wa.me/${numWa}?text=Hola%20${pConfig.heroNombre},%20te%20contacto%20desde%20tu%20Portafolio%20Web%20LMS"
                target="_blank" rel="noopener noreferrer" class="whatsapp-float-btn"
                title="Escríbeme por WhatsApp (${numWa})">
                <i class="fa-brands fa-whatsapp"></i>
                <span class="whatsapp-tooltip">
                    <i class="fa-brands fa-whatsapp" style="color:#25D366;"></i> WhatsApp: ${numWa}
                </span>
            </a>

            <!-- FOOTER -->
            <footer
                style="text-align: center; padding: 30px; border-top: 1px solid var(--border-pink); font-size: 0.85rem; color: var(--text-muted); background: var(--bg-dark);">
                <p>© 2026 <c:out value="${not empty pConfig.heroNombre ? pConfig.heroNombre : 'MAYLIN ZAMUDIO'}"/> — Portafolio Personal & Sistema LMS Académico (Servlets, JSP, JDBC, Tomcat)</p>
            </footer>

            <!-- MODAL DE LOGIN (ESTILO CYBER-SAKURA NEÓN) -->
            <div id="loginModal" class="modal-overlay">
                <div class="modal-content-cyber">
                    <button id="closeModalBtn" class="close-btn-cyber">&times;</button>
                    <div class="login-header-cyber">
                        <h2>PORTAL ACADÉMICO LMS</h2>
                        <p style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">Ingresa tus
                            credenciales para acceder al sistema</p>
                    </div>

                    <c:if test="${param.error == 'true'}">
                        <div class="error-message"><i class="fa-solid fa-triangle-exclamation"></i> Credenciales
                            incorrectas. Inténtalo nuevamente.</div>
                    </c:if>

                    <c:if test="${param.restricted == 'true'}">
                        <div class="error-message"><i class="fa-solid fa-lock"></i> Acceso restringido. Por favor inicia
                            sesión primero.</div>
                    </c:if>

                    <form id="loginForm" action="${pageContext.request.contextPath}/login-process" method="POST"
                        class="login-form-cyber">
                        <div class="form-group">
                            <label><i class="fa-solid fa-user"></i> Usuario:</label>
                            <input type="text" id="loginUsernameInput" name="username" class="form-control" required
                                autocomplete="off" placeholder="estudiante / docente">
                        </div>
                        <div class="form-group">
                            <label><i class="fa-solid fa-key"></i> Contraseña:</label>
                            <div style="position: relative; display: flex; align-items: center;">
                                <input type="password" id="loginPasswordInput" name="password" class="form-control"
                                    required placeholder="123456" style="padding-right: 42px;">
                                <button type="button" id="togglePasswordBtn" onclick="toggleLoginPassword()"
                                    title="Ver / Ocultar contraseña"
                                    style="position: absolute; right: 10px; background: none; border: none; color: var(--pink-neon); cursor: pointer; font-size: 1.1rem; padding: 4px 8px; display: flex; align-items: center; justify-content: center; transition: var(--transition);">
                                    <i class="fa-solid fa-eye" id="togglePasswordIcon"></i>
                                </button>
                            </div>
                        </div>
                        <div
                            style="display: flex; align-items: center; gap: 8px; color: var(--text-sub); margin-top: 5px;">
                            <input type="checkbox" id="terms" required checked style="accent-color: var(--pink-neon);">
                            <label for="terms" style="font-size: 0.76rem; cursor: pointer;">Acepto las políticas de
                                seguridad y uso académico</label>
                        </div>

                        <!-- Accesos rápidos para prueba de credenciales -->
                        <div style="margin-top: 12px; text-align: center;">
                            <p style="font-size: 0.75rem; color: var(--text-muted); margin-bottom: 6px;">Clic para
                                autocompletar credenciales de prueba:</p>
                            <div style="display: flex; gap: 8px; justify-content: center; flex-wrap: wrap;">
                                <button type="button" onclick="setDemoCredentials('estudiante', '123456')"
                                    style="background: rgba(255, 42, 133, 0.15); border: 1px solid var(--pink-neon); color: #fff; padding: 5px 12px; border-radius: 20px; font-size: 0.75rem; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; transition: 0.2s;">
                                    <i class="fa-solid fa-user-graduate" style="color: var(--pink-neon);"></i>
                                    Estudiante
                                </button>
                                <button type="button" onclick="setDemoCredentials('docente', '123456')"
                                    style="background: rgba(0, 240, 255, 0.15); border: 1px solid var(--cyan-neon); color: #fff; padding: 5px 12px; border-radius: 20px; font-size: 0.75rem; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; transition: 0.2s;">
                                    <i class="fa-solid fa-chalkboard-user" style="color: var(--cyan-neon);"></i> Docente
                                </button>
                            </div>
                        </div>

                        <button type="submit" class="btn-send" style="margin-top: 14px;">
                            <i class="fa-solid fa-right-to-bracket"></i> INGRESAR AL PORTAL
                        </button>
                    </form>
                </div>
            </div>

            <!-- CAPA DE TRANSICIÓN Y VÓRTEX -->
            <div id="circusTransition" class="circus-overlay">
                <div class="portal-vortex"></div>
                <h2 class="transition-text">INGRESANDO AL SISTEMA ACADÉMICO...</h2>
            </div>

            <script>
                const openBtn = document.getElementById('openLoginBtn');
                const modal = document.getElementById('loginModal');
                const closeBtn = document.getElementById('closeModalBtn');
                const form = document.getElementById('loginForm');
                const transitionLayer = document.getElementById('circusTransition');

                function toggleLoginPassword() {
                    const pwdInput = document.getElementById('loginPasswordInput');
                    const pwdIcon = document.getElementById('togglePasswordIcon');
                    if (!pwdInput || !pwdIcon) return;
                    if (pwdInput.type === 'password') {
                        pwdInput.type = 'text';
                        pwdIcon.classList.remove('fa-eye');
                        pwdIcon.classList.add('fa-eye-slash');
                    } else {
                        pwdInput.type = 'password';
                        pwdIcon.classList.remove('fa-eye-slash');
                        pwdIcon.classList.add('fa-eye');
                    }
                }

                function setDemoCredentials(user, pass) {
                    const userInput = document.getElementById('loginUsernameInput');
                    const passInput = document.getElementById('loginPasswordInput');
                    const terms = document.getElementById('terms');
                    if (userInput) userInput.value = user;
                    if (passInput) passInput.value = pass;
                    if (terms) terms.checked = true;
                }

                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('error') === 'true' || urlParams.get('restricted') === 'true') {
                    modal.style.display = 'flex';
                }

                openBtn.addEventListener('click', () => modal.style.display = 'flex');
                closeBtn.addEventListener('click', () => modal.style.display = 'none');
                modal.addEventListener('click', (e) => {
                    if (e.target === modal) modal.style.display = 'none';
                });

                form.addEventListener('submit', (e) => {
                    e.preventDefault();
                    modal.style.display = 'none';
                    transitionLayer.style.display = 'flex';

                    setTimeout(() => {
                        form.submit();
                    }, 1000);
                });

                const rawWords = "<c:out value='${not empty pConfig.heroFrases ? pConfig.heroFrases : \"Ingeniera de Software, Desarrolladora Full Stack Java, Creadora de Experiencias Web\"}'/>";
                let words = rawWords.split(',').map(s => s.trim()).filter(s => s.length > 0);
                if (words.length === 0) {
                    words = ["Ingeniera de Software", "Desarrolladora Full Stack Java", "Creadora de Experiencias Web"];
                }
                let i = 0;
                let timer;

                function typingEffect() {
                    let word = words[i].split("");
                    var loopTyping = function () {
                        if (word.length > 0) {
                            document.getElementById('typingText').innerHTML += word.shift();
                        } else {
                            setTimeout(deletingEffect, 2000);
                            return false;
                        }
                        timer = setTimeout(loopTyping, 80);
                    };
                    loopTyping();
                }

                function deletingEffect() {
                    let word = words[i].split("");
                    var loopDeleting = function () {
                        if (word.length > 0) {
                            word.pop();
                            document.getElementById('typingText').innerHTML = word.join("");
                        } else {
                            if (words.length > (i + 1)) {
                                i++;
                            } else {
                                i = 0;
                            }
                            setTimeout(typingEffect, 400);
                            return false;
                        }
                        timer = setTimeout(loopDeleting, 40);
                    };
                    loopDeleting();
                }

                typingEffect();

                const menuBtn = document.getElementById('mobileMenuBtn');
                const navLinks = document.getElementById('navLinks');
                menuBtn.addEventListener('click', () => {
                    navLinks.classList.toggle('mobile-open');
                });

                window.addEventListener('scroll', () => {
                    let current = '';
                    const sections = document.querySelectorAll('section');
                    sections.forEach(section => {
                        const sectionTop = section.offsetTop;
                        if (window.pageYOffset >= sectionTop - 150) {
                            current = section.getAttribute('id');
                        }
                    });

                    document.querySelectorAll('.nav-links a').forEach(a => {
                        a.classList.remove('active');
                        if (a.getAttribute('href') === '#' + current) {
                            a.classList.add('active');
                        }
                    });
                });
            </script>

        </body>

        </html>