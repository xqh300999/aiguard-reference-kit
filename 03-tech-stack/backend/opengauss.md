# openGauss

openGauss 是华为开源的高性能、高安全、高可靠的关系型数据库，基于 PostgreSQL 内核深度优化。

## 快速参考

### openGauss 简介

| 特性 | 说明 |
|------|------|
| 起源 | 基于 PostgreSQL 9.2/10 内核演进 |
| 许可证 | MulanPSL-2.0（木兰宽松许可证） |
| 存储引擎 | 支持行存、列存、内存引擎 |
| 高可用 | 主备同步、异步复制、自动切换 |
| AI 特性 | 智能索引推荐、参数调优、慢 SQL 诊断 |
| 企业特性 | 全密态计算、账本数据库、多模融合 |

**版本选择建议：**
- openGauss 3.x/5.x LTS：企业级生产环境，长期支持
- openGauss 轻量版（Lite）：树莓派 ARM64 等资源受限环境

### 安装（树莓派 ARM64）

**方法1：Docker 安装（推荐）**
```bash
# 拉取 ARM64 兼容镜像（需使用第三方适配或 openGauss Lite）
# openGauss 官方镜像以 x86 为主，ARM 平台建议使用以下方式：
docker run --name opengauss \
  --privileged=true \
  -e GS_PASSWORD=Aiguard@123 \
  -p 5432:5432 \
  -d enmotech/opengauss:latest
```

**方法2：从源码编译（ARM64）**
```bash
# 安装依赖
sudo apt install -y libreadline-dev zlib1g-dev bison flex

# 下载源码
git clone https://gitee.com/opengauss/openGauss-server.git
cd openGauss-server
git checkout 5.0.0

# 编译（参考官方文档）
./configure --gcc-version=11 --prefix=/opt/opengauss
make -j4 && make install
```

**方法3：使用 PostgreSQL 兼容替代（开发环境）**
```bash
# openGauss 兼容 PostgreSQL 协议
# 开发阶段可使用 PostgreSQL 14/15，迁移到 openGauss 改动较小
sudo apt install -y postgresql postgresql-contrib
```

### JDBC 连接

**Maven 依赖：**
```xml
<dependency>
    <groupId>org.opengauss</groupId>
    <artifactId>opengauss-jdbc</artifactId>
    <version>5.1.0-og</version>
</dependency>
```

**连接字符串：**
```
# 格式
jdbc:opengauss://host:port/database?user=username&password=password&ssl=false

# 示例
jdbc:opengauss://localhost:5432/aiguard?user=aiguard&password=Aiguard@123&ssl=false
```

**Spring Boot application.yml 配置：**
```yaml
spring:
  datasource:
    url: jdbc:opengauss://localhost:5432/aiguard
    username: aiguard
    password: Aiguard@123
    driver-class-name: org.opengauss.Driver
  jpa:
    hibernate:
      ddl-auto: update
    properties:
      hibernate:
        dialect: org.hibernate.dialect.OpenGaussDialect
        # 若使用 PostgreSQL 驱动测试可用：
        # dialect: org.hibernate.dialect.PostgreSQLDialect
```

**命令行连接：**
```bash
# gsql 是 openGauss 客户端工具（类似 psql）
gsql -d aiguard -U aiguard -W -h localhost -p 5432
```

### 常用 SQL

**数据库和用户管理：**
```sql
-- 创建用户
CREATE USER aiguard WITH PASSWORD 'Aiguard@123';

-- 创建数据库
CREATE DATABASE aiguard OWNER aiguard ENCODING 'UTF8';

-- 授权
GRANT ALL PRIVILEGES ON DATABASE aiguard TO aiguard;
```

**建表示例：**
```sql
-- 设备表
CREATE TABLE devices (
    id BIGSERIAL PRIMARY KEY,
    device_id VARCHAR(64) UNIQUE NOT NULL,
    name VARCHAR(128) NOT NULL,
    type VARCHAR(32),
    status VARCHAR(16) DEFAULT 'OFFLINE',
    last_online TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 传感器数据表
CREATE TABLE sensor_data (
    id BIGSERIAL PRIMARY KEY,
    device_id VARCHAR(64) NOT NULL,
    metric VARCHAR(32) NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    unit VARCHAR(16),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX idx_sensor_data_device_time ON sensor_data(device_id, recorded_at DESC);
CREATE INDEX idx_devices_status ON devices(status);
```

**常用查询：**
```sql
-- 插入数据
INSERT INTO devices (device_id, name, type, status)
VALUES ('esp32-s3-001', '客厅小智', 'VOICE_ASSISTANT', 'ONLINE');

-- 查询在线设备
SELECT * FROM devices WHERE status = 'ONLINE';

-- 统计设备数量
SELECT status, COUNT(*) FROM devices GROUP BY status;

-- 最近24小时温度数据
SELECT device_id, AVG(value) as avg_temp, MAX(value) as max_temp
FROM sensor_data
WHERE metric = 'temperature'
  AND recorded_at >= NOW() - INTERVAL '24 hours'
GROUP BY device_id;

-- 更新设备状态
UPDATE devices SET status = 'OFFLINE', last_online = NOW()
WHERE device_id = 'esp32-s3-001';

-- 删除过期数据
DELETE FROM sensor_data WHERE recorded_at < NOW() - INTERVAL '30 days';
```

### 数据类型兼容说明

| openGauss | PostgreSQL | Java (JPA) |
|-----------|------------|------------|
| BIGSERIAL | BIGSERIAL / BIGINT GENERATED AS IDENTITY | Long |
| VARCHAR(n) | VARCHAR(n) | String |
| TIMESTAMP | TIMESTAMP | LocalDateTime |
| DOUBLE PRECISION | DOUBLE PRECISION | Double |
| TEXT | TEXT | String |
| JSON/JSONB | JSON/JSONB | String（自定义转换器）|

## 常见坑点

1. **ARM64 支持**
   - openGauss 官方主要提供 x86_64 版本
   - ARM64（树莓派）需要自行编译或使用社区适配版本
   - 开发阶段可用 PostgreSQL 替代，生产环境再迁移到 openGauss
   - JDBC 驱动 opengauss-jdbc 可在 ARM64 JDK 上运行

2. **密码复杂度策略**
   - openGauss 默认强制密码复杂度（至少8位，包含大小写、数字、特殊字符）
   - Docker 环境中 `GS_PASSWORD` 必须满足复杂度要求，否则容器启动失败
   - 测试环境可修改参数降低复杂度要求（不推荐生产环境）

3. **驱动兼容性**
   - `opengauss-jdbc` 与 PostgreSQL JDBC 驱动不完全兼容
   - 部分 PostgreSQL 特有功能（如某些扩展）openGauss 不支持
   - 使用 Hibernate 时若遇到方言问题，可临时使用 PostgreSQLDialect

4. **端口问题**
   - openGauss 默认端口是 5432，与 PostgreSQL 相同
   - 同一台机器不能同时运行 PostgreSQL 和 openGauss 默认实例
   - 修改端口：修改 `postgresql.conf` 中 `port = 5433`

5. **客户端工具**
   - openGauss 自带 gsql，psql 可连接但可能显示异常
   - DBeaver、DataGrip 等工具支持 openGauss，需选择 openGauss 驱动
   - Navicat 部分版本可通过 PostgreSQL 连接但功能受限

6. **自增主键**
   - 使用 `BIGSERIAL` 或 `IDENTITY` 列
   - 使用 JPA 时 `GenerationType.IDENTITY` 与 PostgreSQL 行为一致
   - 注意 `SERIAL` 类型隐式创建的序列权限问题

## 官方链接

详见 [official-links.md](official-links.md)。

- openGauss 官网：https://opengauss.org/
- openGauss 文档中心：https://docs.opengauss.org/
- openGauss Gitee 仓库：https://gitee.com/opengauss/openGauss-server
- openGauss JDBC 驱动：https://gitee.com/opengauss/openGauss-connector-jdbc
