# HarmonyOS NEXT

HarmonyOS NEXT 是华为推出的纯血鸿蒙操作系统，不兼容 Android APK，使用 ArkTS + ArkUI 开发原生应用。

## 快速参考

### HarmonyOS NEXT 概述

| 特性 | 说明 |
|------|------|
| 内核 | 鸿蒙微内核 |
| 应用模型 | Stage 模型（推荐）|
| 开发语言 | ArkTS（TypeScript 扩展）|
| UI 框架 | ArkUI（声明式）|
| 开发工具 | DevEco Studio 5.0+ |
| 应用包格式 | .hap / .app |
| 应用市场 | 华为应用市场 (AppGallery) |
| 最低兼容 | HarmonyOS NEXT Developer Preview 及以上 |

**ArkTS 与 TypeScript 主要区别：**
- ArkTS 在 TS 基础上添加了声明式 UI 语法
- 强制静态类型检查，禁用 any 类型（严格模式）
- 内置 UI 组件和状态管理装饰器
- 不支持 DOM/BOM API（非 Web 环境）

### DevEco Studio 安装

1. 下载 DevEco Studio：https://developer.huawei.com/consumer/cn/deveco-studio/
2. 安装完成后首次启动配置 HarmonyOS SDK
3. 注册华为开发者账号：https://developer.huawei.com/
4. 配置签名证书（开发阶段使用自动调试签名）

**系统要求：**
- Windows 10/11 64位 或 macOS 12+
- 内存 16GB+ 推荐
- 硬盘空间 100GB+（SDK + 模拟器占用较大）

### 项目结构（Stage 模型）

```
entry/src/main/
├── ets/
│   ├── entryability/          # Ability 入口
│   │   └── EntryAbility.ets
│   ├── pages/                 # 页面
│   │   ├── Index.ets          # 首页
│   │   ├── DeviceList.ets
│   │   └── Settings.ets
│   ├── components/            # 自定义组件
│   ├── model/                 # 数据模型
│   ├── service/               # 业务逻辑/网络请求
│   └── common/                # 公共工具、常量
├── resources/                 # 资源文件
│   ├── base/
│   │   ├── element/           # 颜色、尺寸等
│   │   ├── media/             # 图片媒体
│   │   └── profile/
│   └── rawfile/
├── module.json5               # 模块配置
└── app.json5                  # 应用配置
```

### ArkUI 基础语法

**声明式组件：**
```typescript
// 页面组件示例
@Entry
@Component
struct Index {
  @State devices: Device[] = []
  @State loading: boolean = false

  aboutToAppear() {
    this.loadDevices()
  }

  async loadDevices() {
    this.loading = true
    try {
      this.devices = await DeviceService.list()
    } finally {
      this.loading = false
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Navigation() {
        Text('AIguard 智能家居')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
      }
      .titleMode(NavigationTitleMode.Mini)

      // 设备列表
      if (this.loading) {
        LoadingProgress()
          .width(48)
          .height(48)
          .margin({ top: 100 })
      } else {
        List({ space: 12 }) {
          ForEach(this.devices, (device: Device) => {
            ListItem() {
              DeviceItem({ device: device })
            }
          })
        }
        .padding(16)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

// 自定义组件
@Component
struct DeviceItem {
  @Prop device: Device

  build() {
    Row({ space: 12 }) {
      Image(this.device.online ? $r('app.media.ic_device_on') : $r('app.media.ic_device_off'))
        .width(40)
        .height(40)

      Column({ space: 4 }) {
        Text(this.device.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(this.device.online ? '在线' : '离线')
          .fontSize(14)
          .fontColor(this.device.online ? '#4CAF50' : '#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.device.online })
        .onChange((isOn: boolean) => {
          DeviceService.toggle(this.device.id, isOn)
        })
    }
    .padding(16)
    .borderRadius(12)
    .backgroundColor(Color.White)
    .shadow({ radius: 2, color: '#1A000000', offsetY: 1 })
  }
}
```

### 状态管理装饰器

| 装饰器 | 用途 | 说明 |
|--------|------|------|
| `@State` | 组件内部状态 | 修改触发 UI 更新 |
| `@Prop` | 父→子单向传递 | 子组件修改不同步父组件 |
| `@Link` | 父子双向同步 | 子组件修改同步父组件 |
| `@Provide` / `@Consume` | 跨组件层级传递 | 类似 React Context |
| `@Observed` / `@ObjectLink` | 嵌套对象观察 | 用于观察类对象属性变化 |
| `@StorageProp` / `@StorageLink` | AppStorage 持久化 | 应用级状态存储 |
| `@AppStorage` | 应用全局状态 | 跨 Ability 共享 |

```typescript
// 状态管理示例
@Entry
@Component
struct CounterPage {
  @State count: number = 0       // 组件内状态
  @StorageLink('token') token: string = ''  // 持久化状态

  build() {
    Column({ space: 20 }) {
      Text(`Count: ${this.count}`)
        .fontSize(24)

      Button('Add')
        .onClick(() => {
          this.count++
        })

      ChildComponent({ parentCount: this.count })

      // 双向绑定
      ToggleSwitch({ isOn: $count })
    }
  }
}

@Component
struct ChildComponent {
  @Prop parentCount: number  // 单向接收

  build() {
    Text(`From parent: ${this.parentCount}`)
  }
}

@Component
struct ToggleSwitch {
  @Link isOn: number  // 双向绑定

  build() {
    Toggle({ type: ToggleType.Switch, isOn: this.isOn > 0 })
      .onChange((on: boolean) => {
        this.isOn = on ? 1 : 0
      })
  }
}
```

### 网络请求（HTTP / WebSocket）

**HTTP 请求封装：**
```typescript
// service/Request.ets
import http from '@ohos.net.http';
import { preferences } from '@kit.ArkData';

const BASE_URL = 'http://192.168.1.100:8080/api';

export class Request {
  private static async getToken(): Promise<string> {
    const store = await preferences.getPreferences(getContext(this), 'auth');
    return store.get('token', '') as string;
  }

  static async get<T>(url: string, params?: Record<string, Object>): Promise<T> {
    let fullUrl = BASE_URL + url;
    if (params) {
      const query = Object.entries(params)
        .map(([k, v]) => `${k}=${encodeURIComponent(String(v))}`)
        .join('&');
      fullUrl += '?' + query;
    }

    const httpRequest = http.createHttp();
    const token = await this.getToken();

    try {
      const response = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.GET,
        header: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const result = JSON.parse(response.result as string);
      if (result.code === 0) {
        return result.data as T;
      }
      throw new Error(result.message);
    } finally {
      httpRequest.destroy();
    }
  }

  static async post<T>(url: string, data?: Object): Promise<T> {
    const httpRequest = http.createHttp();
    const token = await this.getToken();

    try {
      const response = await httpRequest.request(BASE_URL + url, {
        method: http.RequestMethod.POST,
        header: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(data),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const result = JSON.parse(response.result as string);
      if (result.code === 0) {
        return result.data as T;
      }
      throw new Error(result.message);
    } finally {
      httpRequest.destroy();
    }
  }
}
```

**WebSocket：**
```typescript
// service/WebSocketService.ets
import webSocket from '@ohos.net.webSocket';

export class WebSocketService {
  private ws: webSocket.WebSocket | null = null;
  private messageHandlers: ((data: any) => void)[] = [];

  connect(url: string): void {
    this.ws = webSocket.createWebSocket();

    this.ws.on('open', () => {
      console.info('WebSocket connected');
    });

    this.ws.on('message', (err, data) => {
      if (!err && data) {
        const message = JSON.parse(data as string);
        this.messageHandlers.forEach(handler => handler(message));
      }
    });

    this.ws.on('close', () => {
      console.info('WebSocket closed, reconnecting...');
      setTimeout(() => this.connect(url), 3000);
    });

    this.ws.on('error', (err) => {
      console.error('WebSocket error:', err);
    });

    this.ws.connect(url, (err) => {
      if (err) console.error('Connect failed:', err);
    });
  }

  send(data: Object): void {
    if (this.ws) {
      this.ws.send(JSON.stringify(data));
    }
  }

  onMessage(handler: (data: any) => void): void {
    this.messageHandlers.push(handler);
  }

  disconnect(): void {
    this.ws?.close();
    this.ws = null;
  }
}

export const wsService = new WebSocketService();
```

### 数据模型

```typescript
// model/Device.ets
export enum DeviceType {
  VOICE_ASSISTANT = 'VOICE_ASSISTANT',
  SENSOR = 'SENSOR',
  CAMERA = 'CAMERA',
  GATEWAY = 'GATEWAY'
}

export enum DeviceStatus {
  ONLINE = 'ONLINE',
  OFFLINE = 'OFFLINE',
  ERROR = 'ERROR'
}

export interface Device {
  id: number;
  deviceId: string;
  name: string;
  type: DeviceType;
  status: DeviceStatus;
  online: boolean;
  lastOnline?: string;
  createdAt: string;
  updatedAt: string;
}
```

### 权限配置

在 `module.json5` 中声明所需权限：

```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",
        "reason": "$string:permission_internet_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "always"
        }
      },
      {
        "name": "ohos.permission.GET_WIFI_INFO",
        "reason": "$string:permission_wifi_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.GET_NETWORK_INFO",
        "reason": "$string:permission_network_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "always"
        }
      }
    ]
  }
}
```

**HTTP 网络安全配置（允许明文 HTTP）：**
在 `entry/src/main/resources/base/element/string.json` 或新建 `network_config.json`：
开发阶段可配置允许 HTTP 明文请求，生产环境建议使用 HTTPS。

## 常见坑点

1. **不支持 Android 应用**
   - HarmonyOS NEXT（鸿蒙 5.0 及以上）移除了 AOSP 兼容层
   - 无法安装 APK，必须使用 ArkTS 开发原生 hap 应用
   - 现有 Android 应用需重新开发或使用鸿蒙元服务

2. **ArkTS 与 TypeScript 语法差异**
   - 不允许使用 `any` 类型（严格模式）
   - 不支持 JSX，使用 ArkUI 声明式语法
   - 没有 DOM/BOM/window/setTimeout 等 Web API，需使用鸿蒙原生 API
   - `setTimeout`/`setInterval` 需导入对应的 timer 模块

3. **网络权限必须声明**
   - HTTP/HTTPS 请求必须在 `module.json5` 声明 `ohos.permission.INTERNET`
   - 否则运行时会报权限错误，不声明权限编译不报错但请求失败

4. **HTTP 明文请求限制**
   - 默认禁止 HTTP 明文请求，只允许 HTTPS
   - 开发阶段需要在 `module.json5` 或网络安全配置中允许明文流量
   - 生产环境必须使用 HTTPS

5. **UI 组件尺寸单位**
   - ArkUI 使用 `vp`（虚拟像素）、`fp`（字体像素）、`lpx`（逻辑像素）
   - 不要直接写数字，建议使用 `vp()` 函数或字符串如 `'16vp'`
   - 不同设备屏幕密度不同，vp 能自动适配

6. **生命周期区别**
   - 页面：`aboutToAppear`、`aboutToDisappear`、`onPageShow`、`onPageHide`
   - Ability：`onCreate`、`onForeground`、`onBackground`、`onDestroy`
   - 不要在 `aboutToAppear` 中执行耗时操作

7. **Stage 模型 vs FA 模型**
   - 新应用应使用 Stage 模型（API 9+）
   - FA 模型是旧版模型，已不推荐使用
   - 注意文档版本，不要混用旧 API

8. **模拟器问题**
   - DevEco Studio 内置模拟器，部分传感器功能需真机调试
   - 模拟器网络配置：默认使用宿主机网络，访问局域网设备需在同一网络

9. **状态更新限制**
   - `@State` 装饰的数组，直接 `push()` 可能不触发 UI 更新
   - 建议使用扩展运算符创建新数组：`this.devices = [...this.devices, newDevice]`

## 官方链接

详见 [official-links.md](official-links.md)。

- HarmonyOS NEXT 开发者文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide
- HarmonyOS 开发者官网：https://developer.huawei.com/consumer/cn/
- DevEco Studio 下载：https://developer.huawei.com/consumer/cn/deveco-studio/
- ArkTS 语言文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started
- ArkUI 声明式开发范式：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-get-started
