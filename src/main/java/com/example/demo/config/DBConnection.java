package com.example.demo.config;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class DBConnection {

    private static String url = "jdbc:mysql://localhost:3306/bd_portafolio?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static String user = "root";
    private static String password = "";
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
        // 1. Cargar desde application.properties como base/fallback local
        try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (input != null) {
                Properties prop = new Properties();
                prop.load(input);
                if (prop.getProperty("db.url") != null && !prop.getProperty("db.url").trim().isEmpty()) {
                    url = prop.getProperty("db.url").trim();
                }
                if (prop.getProperty("db.user") != null) {
                    user = prop.getProperty("db.user").trim();
                }
                if (prop.getProperty("db.password") != null) {
                    password = prop.getProperty("db.password").trim();
                }
                if (prop.getProperty("db.driver") != null && !prop.getProperty("db.driver").trim().isEmpty()) {
                    driver = prop.getProperty("db.driver").trim();
                }
            }
        } catch (Exception e) {
            System.err.println("[DBConnection] Aviso al leer application.properties: " + e.getMessage());
        }

        // 2. Sobrescribir con variables de entorno (Render / TiDB Cloud / etc.)
        String envDbUrl = System.getenv("DATABASE_URL");
        if (envDbUrl == null || envDbUrl.trim().isEmpty()) {
            envDbUrl = System.getenv("DB_URL");
        }

        String envHost = System.getenv("DB_HOST");
        String envPort = System.getenv("DB_PORT");
        String envName = System.getenv("DB_NAME");
        String envSsl = System.getenv("DB_SSL");
        String envUser = System.getenv("DB_USER");
        String envPass = System.getenv("DB_PASSWORD");

        if (envDbUrl != null && !envDbUrl.trim().isEmpty()) {
            url = envDbUrl.trim();
            System.out.println("[DBConnection] URL de BD cargada desde variable de entorno.");
        } else if (envHost != null && !envHost.trim().isEmpty()) {
            String host = envHost.trim();
            String port = (envPort != null && !envPort.trim().isEmpty()) ? envPort.trim() : "4000";
            String dbName = (envName != null && !envName.trim().isEmpty()) ? envName.trim() : "bd_portafolio";
            boolean useSsl = envSsl != null && Boolean.parseBoolean(envSsl.trim());

            if (useSsl) {
                url = String.format(
                        "jdbc:mysql://%s:%s/%s?useSSL=true&requireSSL=true&enabledTLSProtocols=TLSv1.2,TLSv1.3",
                        host, port, dbName);
            } else {
                url = String.format(
                        "jdbc:mysql://%s:%s/%s?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true",
                        host, port, dbName);
            }
            System.out.println("[DBConnection] URL de BD construida desde DB_HOST / DB_PORT / DB_NAME.");
        }

        if (envUser != null && !envUser.trim().isEmpty()) {
            user = envUser.trim();
        }
        if (envPass != null) {
            password = envPass.trim();
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
        try (Statement checkStmt = conn.createStatement();
                ResultSet rs = checkStmt.executeQuery("SELECT id, nombre_completo FROM usuarios LIMIT 1")) {
            System.out.println("[DBConnection] Tablas y esquema verificados (base de datos activa).");
            return;
        } catch (SQLException e) {
            System.out.println("[DBConnection] Inicializando esquema de base de datos desde bd_portafolio.sql...");
        }

        try (InputStream is = DBConnection.class.getClassLoader().getResourceAsStream("bd_portafolio.sql")) {
            if (is == null) {
                System.err.println("[DBConnection] No se encontró el recurso bd_portafolio.sql en classpath.");
                return;
            }
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
                    Statement stmt = conn.createStatement()) {

                StringBuilder currentQuery = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    String trimmed = line.trim();
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