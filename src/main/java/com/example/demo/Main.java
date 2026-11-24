package com.example.demo;

import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.core.StandardContext;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;

public class Main {

    public static void main(String[] args) throws Exception {
        // Leer puerto desde variable de entorno PORT (utilizado por plataformas cloud
        // como Render)
        String envPort = System.getenv("PORT");
        int port = (envPort != null && !envPort.trim().isEmpty()) ? Integer.parseInt(envPort.trim()) : 8080;

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(port);
        tomcat.getConnector();

        String webappDir = new File("src/main/webapp").getAbsolutePath();
        if (!new File(webappDir).exists()) {
            webappDir = new File("webapp").getAbsolutePath();
        }

        StandardContext ctx = (StandardContext) tomcat.addWebapp("", webappDir);

        File classesDir = new File("classes");
        if (!classesDir.exists()) {
            classesDir = new File("target/classes");
        }

        if (classesDir.exists()) {
            WebResourceRoot resources = new StandardRoot(ctx);
            resources.addPreResources(new DirResourceSet(
                    resources,
                    "/WEB-INF/classes",
                    classesDir.getAbsolutePath(),
                    "/"));
            ctx.setResources(resources);
        }

        System.out.println("====================================================================");
        System.out.println("🚀 [LMS / Portafolio] Servidor Apache Tomcat iniciado en puerto: " + port);
        System.out.println("👉 URL de Acceso Local: http://localhost:" + port + "/");
        System.out.println("====================================================================");

        tomcat.start();
        tomcat.getServer().await();
    }
}