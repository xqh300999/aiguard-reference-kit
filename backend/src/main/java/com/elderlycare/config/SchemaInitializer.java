package com.elderlycare.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ScriptUtils;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

/**
 * 自动在应用启动时执行 schema.sql 初始化数据库表与种子数据。
 * 仅当 spring.profiles.active=prod 时生效（避免污染本地数据库）。
 */
@Slf4j
@Component
@Order(1)
public class SchemaInitializer implements CommandLineRunner {

    private final DataSource dataSource;
    private final String activeProfile;

    public SchemaInitializer(DataSource dataSource,
                             @Value("${spring.profiles.active:}") String activeProfile) {
        this.dataSource = dataSource;
        this.activeProfile = activeProfile == null ? "" : activeProfile.toLowerCase();
    }

    @Override
    public void run(String... args) throws Exception {
        if (!activeProfile.contains("prod")) {
            log.info("[SchemaInitializer] 非 prod 环境，跳过 SQL 初始化。当前 profile={}", activeProfile);
            return;
        }
        log.info("[SchemaInitializer] 开始执行 db/schema.sql ...");
        try {
            ScriptUtils.executeSqlScript(
                    dataSource.getConnection(),
                    new ClassPathResource("db/schema.sql")
            );
            log.info("[SchemaInitializer] db/schema.sql 执行完成 ✓");
        } catch (Exception e) {
            log.error("[SchemaInitializer] db/schema.sql 执行失败：{}", e.getMessage(), e);
            // 不阻断启动，让后端至少能起来排查问题
        }
    }
}
