# Home Assistant

Home Assistant (HA) 是开源的智能家居自动化平台，支持集成数千种智能设备和服务。

## 快速参考

### Home Assistant 介绍

| 特性 | 说明 |
|------|------|
| 开源协议 | Apache 2.0 |
| 核心语言 | Python |
| 设备支持 | 2500+ 官方集成，社区集成更多 |
| 自动化 | YAML/UI 配置、蓝图（Blueprint） |
| 前端 | Lovelace UI（可自定义仪表盘） |
| 语音助手 | 内置 Assist（可对接大模型） |
| 移动 App | iOS / Android 官方客户端 |
| Add-on 商店 | Supervisor 环境下可一键安装应用 |

### 安装方式对比

| 安装方式 | 推荐度 | 说明 |
|----------|--------|------|
| Home Assistant OS (HAOS) | ★★★★★ | 官方推荐，全功能，包含 Supervisor 和 Add-on 商店 |
| Home Assistant Container (Docker) | ★★★☆☆ | 仅核心，适合已有 Docker 环境，但无 Add-on |
| Home Assistant Supervised | ★★★★☆ | Debian 上手动安装 Supervisor，灵活但需维护 |
| Home Assistant Core (venv) | ★★☆☆☆ | Python 虚拟环境安装，仅核心，适合开发者 |

**推荐：** 树莓派 5 直接刷 HAOS 镜像使用最省心，参考安装文档。

### Docker 安装（Container 方式）

```bash
# 创建目录
mkdir -p ~/homeassistant

# 启动容器
docker run -d \
  --name homeassistant \
  --privileged \
  --restart=unless-stopped \
  -e TZ=Asia/Shanghai \
  -v /etc/localtime:/etc/localtime:ro \
  -v ~/homeassistant:/config \
  --network=host \
  ghcr.io/home-assistant/home-assistant:stable
```

```bash
# 查看日志
docker logs -f homeassistant

# 访问（启动需1-2分钟）
# http://<树莓派IP>:8123
```

**Docker Compose 配置：**
```yaml
# docker-compose.yml
version: '3'
services:
  homeassistant:
    container_name: homeassistant
    image: ghcr.io/home-assistant/home-assistant:stable
    volumes:
      - ./homeassistant:/config
      - /etc/localtime:/etc/localtime:ro
    restart: unless-stopped
    privileged: true
    network_mode: host
    environment:
      - TZ=Asia/Shanghai
```

### 初始配置

1. 浏览器访问 `http://<IP>:8123`
2. 创建管理员账户
3. 系统会自动发现局域网设备（如飞利浦Hue、小米设备、MQTT设备等）
4. 进入「设置」→「设备与服务」添加集成

### MQTT 集成配置

**前置条件：** 确保已部署 MQTT Broker（Mosquitto/EMQX）。

1. 进入「设置」→「设备与服务」→「添加集成」
2. 搜索 "MQTT"，点击添加
3. 配置 Broker 地址：
   - Broker：`localhost`（HA 与 Mosquitto 在同一机器）或树莓派IP
   - 端口：`1883`
   - 用户名：`mqtt_user`
   - 密码：对应密码
4. 点击提交，HA 将自动订阅并发现 MQTT 设备

**手动 MQTT 设备配置（configuration.yaml）：**
```yaml
# configuration.yaml
mqtt:
  broker: localhost
  port: 1883
  username: mqtt_user
  password: your_password
  discovery: true
  discovery_prefix: homeassistant

# 手动配置一个 MQTT 传感器
sensor:
  - platform: mqtt
    name: "客厅温度"
    state_topic: "aiguard/device/esp32-s3-001/sensor"
    value_template: "{{ value_json.temperature }}"
    unit_of_measurement: "°C"
    device_class: temperature
    state_class: measurement

switch:
  - platform: mqtt
    name: "小智开关"
    command_topic: "aiguard/device/esp32-s3-001/command"
    state_topic: "aiguard/device/esp32-s3-001/status"
    payload_on: '{"action":"power_on"}'
    payload_off: '{"action":"power_off"}'
    state_on: "ONLINE"
    state_off: "OFFLINE"
```

**修改配置后重启生效：**
- 开发者工具 → YAML → 检查配置 → 重启
- 或命令行：`docker restart homeassistant`

### 自动化配置示例

**UI 方式（推荐新手）：**
设置 → 自动化与场景 → 创建自动化，通过可视化界面配置触发器、条件、动作。

**YAML 方式：**
```yaml
# automations.yaml
- id: 'device_online_notification'
  alias: 设备上线通知
  trigger:
    - platform: state
      entity_id: binary_sensor.xiaozhi_online
      to: 'on'
  action:
    - service: notify.mobile_app_your_phone
      data:
        title: "设备上线"
        message: "小智已上线"

- id: 'temperature_alert'
  alias: 温度过高告警
  trigger:
    - platform: numeric_state
      entity_id: sensor.living_room_temperature
      above: 30
      for:
        minutes: 5
  action:
    - service: persistent_notification.create
      data:
        title: "温度告警"
        message: "客厅温度超过30°C，请检查"
```

### 常用 MQTT 主题（与 AIguard 配合）

| 主题 | 方向 | 说明 |
|------|------|------|
| `homeassistant/status` | HA→设备 | HA 上线/离线（online/offline）|
| `aiguard/device/+/status` | 设备→HA | 设备状态 |
| `aiguard/device/+/sensor` | 设备→HA | 传感器数据 |
| `aiguard/device/+/event` | 设备→HA | 事件上报（唤醒、告警）|
| `aiguard/device/+/command` | HA→设备 | 控制指令 |
| `aiguard/ha/command` | 后端→HA | 通过 HA 控制设备 |

### Home Assistant API 调用

**REST API（长期访问令牌）：**
```bash
# 创建令牌：点击左下角用户名 → 安全 → 长期访问令牌

# 获取所有实体状态
curl -X GET \
  -H "Authorization: Bearer YOUR_LONG_LIVED_TOKEN" \
  -H "Content-Type: application/json" \
  http://<HA_IP>:8123/api/states

# 调用服务（如开灯）
curl -X POST \
  -H "Authorization: Bearer YOUR_LONG_LIVED_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "light.living_room"}' \
  http://<HA_IP>:8123/api/services/light/turn_on
```

**Java/Spring Boot 调用 HA API：**
```java
@Service
public class HomeAssistantService {

    @Value("${ha.base-url}")
    private String baseUrl;

    @Value("${ha.token}")
    private String token;

    private final RestTemplate restTemplate = new RestTemplate();

    public void callService(String domain, String service, Map<String, Object> data) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + token);
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(data, headers);
        String url = String.format("%s/api/services/%s/%s", baseUrl, domain, service);
        restTemplate.postForObject(url, entity, String.class);
    }

    public Map<String, Object> getEntityState(String entityId) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + token);
        HttpEntity<Void> entity = new HttpEntity<>(headers);

        String url = String.format("%s/api/states/%s", baseUrl, entityId);
        return restTemplate.exchange(url, HttpMethod.GET, entity, Map.class).getBody();
    }
}
```

## 常见坑点

1. **Docker 版无 Add-on 商店**
   - Container 方式只有核心，没有 Supervisor 和 Add-on
   - 需要 Add-on（如 Mosquitto、Node-RED、File Editor）建议安装 HAOS
   - Mosquitto、Node-RED 可用独立 Docker 容器部署

2. **`network_mode: host` 必须**
   - Home Assistant 需要发现局域网设备（mDNS/UPnP/SSDP），必须使用 host 网络
   - bridge 模式下设备发现无法工作
   - host 模式下 HA 直接占用 8123 端口，无需端口映射

3. **时区配置**
   - 必须设置 `TZ=Asia/Shanghai` 和挂载 `/etc/localtime`
   - 否则时间显示错误，自动化定时触发不按预期执行

4. **Zigbee/Z-Wave USB 设备**
   - 树莓派通过 USB 连接 Zigbee 协调器（如 Sonoff ZBDongle）
   - Docker 需要映射设备：`--device /dev/ttyUSB0:/dev/ttyUSB0`
   - 注意设备权限，可能需要 `--privileged` 或配置 udev 规则

5. **MQTT 发现前缀**
   - 默认发现前缀是 `homeassistant`
   - 设备发布配置到 `homeassistant/<component>/<object_id>/config`
   - retained 标志必须设为 true，否则 HA 重启后丢失设备配置

6. **配置编辑问题**
   - Docker 版没有 File Editor 插件，需通过 SSH 或挂载目录编辑
   - 每次修改 YAML 前建议「检查配置」避免格式错误导致无法启动
   - 建议将 `configuration.yaml` 中的配置拆分到不同文件

7. **SD 卡寿命问题**
   - HA 频繁写入数据库（home-assistant_v2.db），SD 卡容易损坏
   - 建议：使用 SSD 启动、配置数据库保留天数、禁用不必要的实体记录
   - 定期备份配置到外部存储

8. **小米/米家设备集成**
   - 局域网设备需要 Xiaomi Miot Auto 集成（HACS 安装）
   - 云端设备需要小米账号令牌获取，较复杂
   - 建议设备优先使用原生 MQTT 或 Zigbee2MQTT 接入

## 官方链接

详见 [official-links.md](official-links.md)。

- Home Assistant 官网：https://www.home-assistant.io/
- Home Assistant 中文文档：https://www.home-assistant.io/getting-started/
- HA 安装文档：https://www.home-assistant.io/installation/
- HA Docker 安装：https://www.home-assistant.io/installation/linux#install-home-assistant-container
- MQTT 集成文档：https://www.home-assistant.io/integrations/mqtt/
- HACS（社区应用商店）：https://hacs.xyz/
