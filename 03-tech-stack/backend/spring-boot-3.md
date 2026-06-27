# Spring Boot 3

Spring Boot 3 是 Spring 生态的最新框架版本，底层基于 Spring Framework 6，要求 JDK 17+。

## 快速参考

### 快速入门

**使用 Spring Initializr 创建项目：**
```bash
curl https://start.spring.io/starter.zip \
  -d type=maven-project \
  -d language=java \
  -d bootVersion=3.3.0 \
  -d basePackage=com.aiguard \
  -d name=aiguard-backend \
  -d dependencies=web,data-jpa,security,validation,websocket,amqp \
  -o aiguard-backend.zip
```

**项目结构：**
```
src/main/java/com/aiguard/
├── AiguardApplication.java    # 启动类
├── controller/                # REST 控制器
├── service/                   # 业务逻辑
├── repository/                # 数据访问层
├── entity/                    # JPA 实体
├── dto/                       # 数据传输对象
├── config/                    # 配置类
└── security/                  # 安全配置
src/main/resources/
├── application.yml            # 配置文件
└── schema.sql                 # 数据库初始化脚本
```

**启动类：**
```java
package com.aiguard;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class AiguardApplication {
    public static void main(String[] args) {
        SpringApplication.run(AiguardApplication.class, args);
    }
}
```

### REST API 开发

**REST Controller：**
```java
@RestController
@RequestMapping("/api/devices")
@RequiredArgsConstructor
public class DeviceController {

    private final DeviceService deviceService;

    @GetMapping
    public ResponseEntity<List<DeviceDTO>> getAllDevices() {
        return ResponseEntity.ok(deviceService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<DeviceDTO> getDevice(@PathVariable Long id) {
        return deviceService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public DeviceDTO createDevice(@Valid @RequestBody CreateDeviceRequest request) {
        return deviceService.create(request);
    }

    @PutMapping("/{id}")
    public DeviceDTO updateDevice(@PathVariable Long id,
                                   @Valid @RequestBody UpdateDeviceRequest request) {
        return deviceService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteDevice(@PathVariable Long id) {
        deviceService.delete(id);
    }
}
```

### 数据访问（Spring Data JPA）

**实体类：**
```java
@Entity
@Table(name = "devices")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Device {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String deviceId;

    private String name;

    @Enumerated(EnumType.STRING)
    private DeviceStatus status;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
```

**Repository：**
```java
public interface DeviceRepository extends JpaRepository<Device, Long> {
    Optional<Device> findByDeviceId(String deviceId);
    List<Device> findByStatus(DeviceStatus status);

    @Query("SELECT d FROM Device d WHERE d.name LIKE %:keyword%")
    List<Device> searchByName(@Param("keyword") String keyword);
}
```

### 安全配置（Spring Security）

```java
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**", "/ws/**", "/actuator/health").permitAll()
                .anyRequest().authenticated()
            )
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

### application.yml 常用配置

```yaml
server:
  port: 8080

spring:
  application:
    name: aiguard-backend
  datasource:
    url: jdbc:opengauss://localhost:5432/aiguard
    username: aiguard
    password: your_password
    driver-class-name: org.opengauss.Driver
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
    open-in-view: false
  mqtt:
    broker-url: tcp://localhost:1883
    client-id: aiguard-backend
    username: mqtt_user
    password: mqtt_password

logging:
  level:
    com.aiguard: DEBUG
    org.springframework.web: INFO
```

## 常见坑点

1. **JDK 版本要求**
   - Spring Boot 3.0+ 最低要求 JDK 17，JDK 8/11 无法使用
   - 注意 `javax.*` 包全部迁移到 `jakarta.*`，所有 import 需要修改

2. **包路径问题**
   - `@SpringBootApplication` 所在类必须在根包下，否则无法扫描到子包组件
   - 若组件不在子包，需使用 `@ComponentScan` 指定扫描路径

3. **JPA 懒加载异常**
   - `Open-in-view` 默认开启但生产环境建议关闭（设为 false）
   - 返回 JSON 时遇到懒加载对象不在 Session 会报 `LazyInitializationException`
   - 解决方案：使用 DTO 投影、JOIN FETCH 查询、EntityGraph

4. **循环依赖问题**
   - Spring Boot 2.6+ 默认禁止循环依赖
   - 解决方案：重构代码使用 `@Lazy` 注解，或调整设计

5. **CORS 跨域配置**
   ```java
   @Bean
   public CorsConfigurationSource corsConfigurationSource() {
       CorsConfiguration config = new CorsConfiguration();
       config.setAllowedOrigins(List.of("http://localhost:5173", "http://localhost:8081"));
       config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
       config.setAllowedHeaders(List.of("*"));
       config.setAllowCredentials(true);
       UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
       source.registerCorsConfiguration("/api/**", config);
       return source;
   }
   ```

6. **配置文件优先级**
   - 优先级：命令行参数 > 外部 application.yml > jar 内 application.yml
   - 敏感信息不建议直接写在配置文件中，使用环境变量或配置中心

## 官方链接

详见 [official-links.md](official-links.md)。

- Spring Boot 官方文档：https://docs.spring.io/spring-boot/docs/current/reference/html/
- Spring Boot 3.0 迁移指南：https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide
- Spring Initializr：https://start.spring.io/
