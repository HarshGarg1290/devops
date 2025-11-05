package com.example.twitterapp.config;

import org.h2.tools.Server;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import java.sql.SQLException;

@Configuration
@Profile("dev")
public class H2ServerConfiguration {

    private Server webServer;
    private Server tcpServer;

    @PostConstruct
    public void start() throws SQLException {
        // Start H2 Web console and TCP server allowing remote connections
        this.webServer = Server.createWebServer("-web", "-webAllowOthers", "-ifNotExists").start();
        this.tcpServer = Server.createTcpServer("-tcp", "-tcpAllowOthers", "-ifNotExists").start();
        System.out.println("H2 Web console started and listening (webAllowOthers)");
    }

    @PreDestroy
    public void stop() {
        if (webServer != null) {
            webServer.stop();
        }
        if (tcpServer != null) {
            tcpServer.stop();
        }
    }
}
