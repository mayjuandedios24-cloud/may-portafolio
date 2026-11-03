package com.example.demo.config;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {

    private static String url = "jdbc:mysql://bqenrefor3qwi6hqj6hz-mysql.services.clever-cloud.com:3306/bqenrefor3qwi6hqj6hz?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static String user = "uo7hvyboj7v7c9ml";
    private static String password = "UyqXX4wSgor64soRp45U";
    private static String driver = "com.mysql.cj.jdbc.Driver";

    static {
        cargarConfiguracion();
        try {
            Class.forName(driver);
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] Driver MySQL no encontrado en el classpath: " + e.getMessage());
        }
    }

    private static void cargarConfiguracion() {
        // 1. Intentar cargar desde variables de entorno (útil para Render / Heroku / Railway / Docker)
        String envDbUrl = System.getenv("DATABASE_URL");
        if (envDbUrl == null) {
            envDbUrl = System.getenv("DB_URL");
        }
        String envDbUser = System.getenv("DB_USER");
        String envDbPass = System.getenv("DB_PASSWORD");

        if (envDbUrl != null && !envDbUrl.trim().isEmpty()) {
            url = envDbUrl.trim();
            if (envDbUser != null) user = envDbUser.trim();
            if (envDbPass != null) password = envDbPass.trim();
            System.out.println("[DBConnection] Configuración cargada desde variables de entorno.");
            return;
        }

        // 2. Cargar desde application.properties
        try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (input != null) {
                Properties prop = new Properties();
                prop.load(input);
                if (prop.getProperty("db.url") != null) {
                    url = prop.getProperty("db.url").trim();
                }
                if (prop.getProperty("db.user") != null) {
                    user = prop.getProperty("db.user").trim();
                }
                if (prop.getProperty("db.password") != null) {
                    password = prop.getProperty("db.password").trim();
                }
                if (prop.getProperty("db.driver") != null) {
                    driver = prop.getProperty("db.driver").trim();
                }
                System.out.println("[DBConnection] Configuración cargada desde application.properties.");
            }
        } catch (Exception e) {
            System.err.println("[DBConnection] Aviso al leer application.properties: " + e.getMessage());
        }
    }

    private static volatile boolean inicializado = false;

    public static Connection getConnection() throws SQLException {
        Connection conn = DriverManager.getConnection(url, user, password);
        if (!inicializado) {
            synchronized (DBConnection.class) {
                if (!inicializado) {
                    ejecutarScriptInicial(conn);
                    inicializado = true;
                }
            }
        }
        return conn;
    }

    private static void ejecutarScriptInicial(Connection conn) {
        // Verificar si las tablas principales ya existen y están completas
        try (java.sql.Statement checkStmt = conn.createStatement();
             java.sql.ResultSet rs = checkStmt.executeQuery("SELECT id, nombre_completo FROM usuarios LIMIT 1")) {
            // La tabla existe y tiene el esquema moderno; no es necesario re-ejecutar el script
            System.out.println("[DBConnection] Tablas y esquema verificados (base de datos activa).");
            return;
        } catch (SQLException e) {
            // La tabla no existe o tiene esquema antiguo, procedemos a inicializar con el script
            System.out.println("[DBConnection] Inicializando esquema de base de datos desde bd_portafolio.sql...");
        }

        try (InputStream is = DBConnection.class.getClassLoader().getResourceAsStream("bd_portafolio.sql")) {
            if (is == null) {
                System.err.println("[DBConnection] No se encontró el recurso bd_portafolio.sql en classpath.");
                return;
            }
            try (java.io.BufferedReader reader = new java.io.BufferedReader(
                    new java.io.InputStreamReader(is, java.nio.charset.StandardCharsets.UTF_8));
                 java.sql.Statement stmt = conn.createStatement()) {

                StringBuilder currentQuery = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    String trimmed = line.trim();
                    // Omitir líneas de comentario y vacías
                    if (trimmed.isEmpty() || trimmed.startsWith("--") || trimmed.startsWith("/*")) {
                        continue;
                    }
                    currentQuery.append(line).append("\n");
                    if (trimmed.endsWith(";")) {
                        String query = currentQuery.toString().trim();
                        if (query.endsWith(";")) {
                            query = query.substring(0, query.length() - 1).trim();
                        }
                        if (!query.isEmpty()) {
                            try {
                                stmt.execute(query);
                            } catch (SQLException ex) {
                                // Avisar de cualquier error no crítico (ej. base de datos ya existente)
                                System.err.println("[DBConnection] Nota ejecutando sentencia: " + ex.getMessage());
                            }
                        }
                        currentQuery.setLength(0);
                    }
                }
            }
            System.out.println("[DBConnection] Base de datos e inicialización de tablas completadas exitosamente.");
        } catch (Exception e) {
            System.err.println("[DBConnection] Aviso durante la verificación de esquema inicial: " + e.getMessage());
        }
    }
}
