-- ====================================================================
-- SISTEMA LMS / PORTAFOLIO ACADÉMICO PROFESIONAL  v2.0
-- Curso: PROGRAMACIÓN DE APLICACIÓN PROFESIONAL
-- Base de Datos: bd_portafolio
-- Compatible con MySQL 8.x / MySQL Workbench / XAMPP
-- Preparado para despliegue en Render / Railway / PlanetScale
-- ====================================================================

CREATE DATABASE IF NOT EXISTS bd_portafolio
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE bd_portafolio;

-- Desactivar revisión de FK durante la carga inicial
SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------------------
-- 1. TABLA: usuarios
--    Roles: 'ESTUDIANTE' | 'DOCENTE'
--    Ambos roles pueden actualizar su username, password y perfil.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(100)    NOT NULL UNIQUE,
    password        VARCHAR(255)    NOT NULL COMMENT 'Contraseña en texto plano (upgradar a BCrypt en producción)',
    nombre_completo VARCHAR(150)    NOT NULL,
    email           VARCHAR(150)    NOT NULL UNIQUE,
    rol             ENUM('ESTUDIANTE','DOCENTE') NOT NULL DEFAULT 'ESTUDIANTE',
    avatar          VARCHAR(255)    DEFAULT 'assets/img/user.jpeg',
    fecha_creacion  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_usuario_username  (username),
    INDEX idx_usuario_rol       (rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tabla de usuarios con soporte para roles ESTUDIANTE y DOCENTE';

-- --------------------------------------------------------------------
-- 2. TABLA: cursos
--    Un único curso académico: Programación de Aplicación Profesional.
--    total_semanas: campo numérico para configurar dinámicamente las
--    semanas del curso (default 16, modificable por el docente).
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cursos (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    codigo          VARCHAR(20)     NOT NULL UNIQUE,
    nombre          VARCHAR(200)    NOT NULL,
    descripcion     TEXT,
    creditos        INT             NOT NULL DEFAULT 5,
    ciclo           VARCHAR(20)     NOT NULL DEFAULT '2026-II',
    icono           VARCHAR(60)     NOT NULL DEFAULT 'fa-laptop-code',
    total_semanas   INT             NOT NULL DEFAULT 16 COMMENT 'Cantidad de semanas configurables por el docente',
    docente_id      BIGINT          NULL,
    fecha_creacion  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cursos_docente FOREIGN KEY (docente_id)
        REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_cursos_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Cursos académicos. El campo total_semanas es configurable dinámicamente';

-- --------------------------------------------------------------------
-- 3. TABLA: semanas
--    Relacionada al curso. numero no tiene CHECK fijo para que el
--    docente pueda configurar dinámicamente entre 1 y total_semanas.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS semanas (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    curso_id        BIGINT          NOT NULL,
    numero          INT             NOT NULL COMMENT 'Número de semana (1..total_semanas del curso)',
    titulo          VARCHAR(250)    NOT NULL,
    descripcion     TEXT,
    fecha_limite    DATE            NULL,
    CONSTRAINT fk_semanas_curso FOREIGN KEY (curso_id)
        REFERENCES cursos(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uq_curso_semana UNIQUE (curso_id, numero),
    INDEX idx_semanas_curso_num (curso_id, numero)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Semanas académicas del curso. Cantidad definida por total_semanas en cursos';

-- --------------------------------------------------------------------
-- 4. TABLA: trabajos / entregas
--    Estudiantes suben archivos ZIP/RAR o enlaces de proyectos.
--    El docente puede calificar y añadir observaciones.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS trabajos (
    id                  VARCHAR(50)     PRIMARY KEY COMMENT 'ID único generado: T + timestamp',
    curso_id            BIGINT          NOT NULL,
    semana_id           BIGINT          NULL,
    semana_numero       INT             NOT NULL,
    estudiante_id       BIGINT          NULL,
    titulo              VARCHAR(255)    NOT NULL,
    descripcion         TEXT,
    fecha_entrega       VARCHAR(30)     NOT NULL,
    archivo_nombre      VARCHAR(255)    NULL COMMENT 'Nombre del archivo físico en /uploads/',
    url_proyecto        VARCHAR(500)    NULL COMMENT 'URL desplegada en Render/Netlify/GitHub Pages',
    estado              ENUM('Pendiente','Entregado','En revisión','Calificado','Observado')
                                        NOT NULL DEFAULT 'Entregado',
    nota_personal       TEXT            COMMENT 'Notas del estudiante sobre el trabajo',
    categoria_tag       VARCHAR(100)    DEFAULT 'Proyecto Práctico',
    calificacion        VARCHAR(30)     NULL COMMENT 'Nota vigesimal: ej. 18/20',
    observacion_docente TEXT            COMMENT 'Retroalimentación del docente',
    fecha_registro      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_trabajos_curso      FOREIGN KEY (curso_id)      REFERENCES cursos(id)    ON DELETE CASCADE  ON UPDATE CASCADE,
    CONSTRAINT fk_trabajos_semana     FOREIGN KEY (semana_id)     REFERENCES semanas(id)   ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_trabajos_estudiante FOREIGN KEY (estudiante_id) REFERENCES usuarios(id)  ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_trabajos_curso_semana   (curso_id, semana_numero),
    INDEX idx_trabajos_estudiante     (estudiante_id),
    INDEX idx_trabajos_estado         (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Entregas académicas: archivos ZIP/RAR o URLs de proyectos desplegados';

-- --------------------------------------------------------------------
-- 5. TABLA: portafolio_proyectos
--    Portafolio web del estudiante: proyectos personales, descripción,
--    tecnologías usadas, URL del proyecto y repositorio GitHub.
--    Cada estudiante puede registrar, editar y actualizar sus proyectos.
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS portafolio_proyectos (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    estudiante_id   BIGINT          NOT NULL,
    titulo          VARCHAR(200)    NOT NULL COMMENT 'Nombre del proyecto',
    descripcion     TEXT            COMMENT 'Descripción detallada del proyecto',
    tecnologias     VARCHAR(300)    COMMENT 'Stack tecnológico: Java, Spring, MySQL, etc.',
    url_demo        VARCHAR(500)    NULL COMMENT 'URL de la aplicación desplegada en producción',
    url_repositorio VARCHAR(500)    NULL COMMENT 'URL del repositorio en GitHub/GitLab',
    imagen_preview  VARCHAR(255)    NULL COMMENT 'Ruta de imagen preview del proyecto',
    categoria       VARCHAR(100)    DEFAULT 'Aplicación Web' COMMENT 'Tipo: Web, Móvil, API REST, etc.',
    destacado       TINYINT(1)      DEFAULT 0 COMMENT '1 = proyecto destacado en el portafolio',
    orden           INT             DEFAULT 0 COMMENT 'Orden de visualización en el portafolio',
    fecha_creacion  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_portafolio_estudiante FOREIGN KEY (estudiante_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_portafolio_estudiante (estudiante_id),
    INDEX idx_portafolio_destacado  (estudiante_id, destacado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Portafolio web del estudiante: proyectos personales con URLs y tecnologías';

-- Reactivar revisión de FK
SET FOREIGN_KEY_CHECKS = 1;

-- ====================================================================
-- DATOS INICIALES: USUARIOS, CURSO Y 16 SEMANAS ACADÉMICAS
-- ====================================================================

-- 1. Usuarios del Sistema (INSERT IGNORE para conservar cambios de usuario)
INSERT IGNORE INTO usuarios (id, username, password, nombre_completo, email, rol, avatar) VALUES
(1, 'estudiante', '123456', 'Maylin Zamudio JD',    'estudiante@continental.edu.pe', 'ESTUDIANTE', 'assets/img/user.jpeg'),
(2, 'docente',    '123456', 'Ing. Docente Titular',  'docente@continental.edu.pe',   'DOCENTE',     'assets/img/anime_portrait.jpg');

-- 2. Curso Académico Principal (INSERT IGNORE para conservar configuración docente)
INSERT IGNORE INTO cursos (id, codigo, nombre, descripcion, creditos, ciclo, icono, total_semanas, docente_id) VALUES
(1, 'CS-501', 'Programación de Aplicación Profesional',
 'Desarrollo de aplicaciones empresariales escalables con Java Servlets, JSP, JDBC, arquitectura MVC y despliegue en la nube.',
 5, '2026-II', 'fa-laptop-code', 16, 2);

-- 3. Las 16 Semanas Académicas (INSERT IGNORE para conservar ediciones docentes)
INSERT IGNORE INTO semanas (curso_id, numero, titulo, descripcion, fecha_limite) VALUES
(1,  1, 'Semana 1: Fundamentos de Arquitectura Web & HTML5 Semántico',        'Diseño de la estructura base del portafolio con HTML5 semántico, layout responsivo y flexbox.',                                                                '2026-09-15'),
(1,  2, 'Semana 2: Estilos Avanzados con CSS Moderno & Glassmorphism',         'Implementación de variables CSS personalizadas, sombras complejas y paleta Cyber-Sakura con efectos neón.',                                                      '2026-09-22'),
(1,  3, 'Semana 3: Introducción a Servlets en Jakarta EE',                     'Configuración del ciclo de vida de los Servlets, manejo de HttpServletRequest y HttpServletResponse.',                                                              '2026-09-29'),
(1,  4, 'Semana 4: JavaServer Pages (JSP) & Taglibs JSTL',                    'Separación de capas con JSP, directivas de página, expresiones EL (Expression Language) y Core JSTL.',                                                            '2026-10-06'),
(1,  5, 'Semana 5: Patrón Arquitectónico Modelo-Vista-Controlador (MVC)',      'Estructuración modular del proyecto separando modelos de datos, controladores y vistas protegidas en WEB-INF.',                                                   '2026-10-13'),
(1,  6, 'Semana 6: Conectividad a Bases de Datos Relacionales con JDBC',       'Conexión a MySQL mediante JDBC Driver, gestión de conexiones seguras y consultas con PreparedStatement.',                                                           '2026-10-20'),
(1,  7, 'Semana 7: Implementación del Patrón DAO (Data Access Object)',        'Encapsulamiento del acceso a datos, desacoplamiento de la lógica de persistencia y manejo de transacciones.',                                                       '2026-10-27'),
(1,  8, 'Semana 8: Evaluación Parcial — Integración del Sistema LMS',          'Presentación del prototipo funcional con autenticación de usuarios y gestión básica de cursos.',                                                                    '2026-11-03'),
(1,  9, 'Semana 9: Manejo de Sesiones HTTP & Filtros de Seguridad',            'Gestión de HttpSession, control de acceso basado en roles (RBAC) y filtros WebFilter para rutas protegidas.',                                                      '2026-11-10'),
(1, 10, 'Semana 10: Subida Segura de Archivos Multipart en Servlets',          'Carga de archivos en disco con @MultipartConfig, validación de extensiones y almacenamiento de rutas relativas.',                                                   '2026-11-17'),
(1, 11, 'Semana 11: Registro y Visualización de Proyectos Prácticos',          'Soporte para enlaces a repositorios GitHub y URLs de aplicaciones desplegadas en vivo.',                                                                            '2026-11-24'),
(1, 12, 'Semana 12: Módulo Docente — Calificaciones y Retroalimentación',      'Panel de evaluación para docentes, asignación de notas vigesimales y observaciones personalizadas.',                                                               '2026-12-01'),
(1, 13, 'Semana 13: Optimización de Consultas SQL e Índices en MySQL',         'Afinamiento de rendimiento en base de datos, creación de índices compuestos y consultas optimizadas.',                                                             '2026-12-08'),
(1, 14, 'Semana 14: Seguridad Web & Sanitización de Datos',                    'Prevención de XSS, SQL Injection, validación de entradas y cabeceras de seguridad HTTP.',                                                                          '2026-12-15'),
(1, 15, 'Semana 15: Preparación para Despliegue en la Nube (Render / Cloud)',  'Empaquetado WAR con Maven, parametrización por variables de entorno y Tomcat embebido.',                                                                           '2026-12-22'),
(1, 16, 'Semana 16: Sustentación Final del Portafolio Académico',              'Evaluación final y presentación del sistema LMS desplegado en producción con todas las evidencias académicas.',                                                     '2026-12-29');

-- --------------------------------------------------------------------
-- 6. TABLA: portafolio_config (Configuración dinámica del portafolio público)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS portafolio_config (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id       BIGINT NOT NULL UNIQUE,
    hero_nombre         VARCHAR(150) DEFAULT 'MAYLIN ZAMUDIO',
    hero_titulo         VARCHAR(200) DEFAULT 'Hola, soy MAYLIN',
    hero_frases         VARCHAR(500) DEFAULT 'Ingeniera de Software, Desarrolladora Full Stack Java, Creadora de Experiencias Web',
    hero_descripcion    TEXT,
    hero_imagen         VARCHAR(255) DEFAULT 'assets/img/Img_May.jpeg',
    github_url          VARCHAR(255) DEFAULT 'https://github.com',
    linkedin_url        VARCHAR(255) DEFAULT 'https://linkedin.com',
    instagram_url       VARCHAR(255) DEFAULT 'https://instagram.com',
    whatsapp_numero     VARCHAR(50)  DEFAULT '51952374069',
    about_titulo        VARCHAR(200) DEFAULT 'Sobre Mí',
    about_descripcion   TEXT,
    about_filosofia     TEXT,
    about_mision        TEXT,
    about_imagen        VARCHAR(255) DEFAULT 'assets/img/sakura_fan.jpg',
    educacion_data      TEXT,
    habilidades_data    TEXT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_portafolio_config_estudiante FOREIGN KEY (estudiante_id)
        REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO portafolio_config (estudiante_id, hero_nombre, hero_titulo, hero_frases, hero_descripcion, hero_imagen, github_url, linkedin_url, instagram_url, whatsapp_numero, about_titulo, about_descripcion, about_filosofia, about_mision, about_imagen, educacion_data, habilidades_data)
VALUES (1, 'MAYLIN ZAMUDIO', 'Hola, soy MAYLIN', 'Ingeniera de Software, Desarrolladora Full Stack Java, Creadora de Experiencias Web',
'Desarrolladora de software apasionada por transformar conceptos complejos en experiencias web interactivas, seguras y de alto rendimiento. Especializada en Java, Jakarta Servlets, JSP, JDBC, MySQL y Arquitectura MVC.',
'assets/img/Img_May.jpeg', 'https://github.com', 'https://linkedin.com', 'https://instagram.com', '51952374069',
'Sobre Mí', 'Desarrollo de experiencias web y sistemas académicos de alto impacto a través de código estructurado, diseño responsivo y arquitectura modular.',
'Combinar la disciplina técnica con un diseño de interfaz intuitivo y estilizado, garantizando código mantenible, libre de vulnerabilidades y de alto rendimiento.',
'Construir plataformas educativas y soluciones empresariales con arquitectura robusta en Java, facilitando la gestión de evidencias, código fuente y aplicaciones desplegadas.',
'assets/img/sakura_fan.jpg',
'Programación de Aplicación Profesional | Instituto Andres A. Caceres D. • Ciclo 2026-II | Enfoque en Arquitectura MVC, Servlets, JSP y JDBC
Desarrollo de Aplicaciones Web y Gestión de Datos | Ecosistema Java Empresarial, MySQL y Apache Tomcat | Modelado relacional, PreparedStatement y seguridad web
Diseño UI/UX y Desarrollo Frontend Cyber-Sakura | Interfaces Modernas con CSS3, Glassmorphism y Responsive Design | 2026',
'Java 21 & Jakarta Servlets (MVC) | 95
JavaServer Pages (JSP) & JSTL | 92
HTML5 / CSS3 / Glassmorphism | 90
MySQL & MySQL Workbench (JDBC) | 92
Apache Tomcat 10 & Despliegue Cloud | 88
Gestión de Repositorios & Git/GitHub | 90');
