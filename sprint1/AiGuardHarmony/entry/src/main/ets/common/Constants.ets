export class Constants {
  static readonly APP_NAME: string = 'AiGuard';

  // 后端完成后：把 USE_MOCK 改为 false，并把 API_BASE_URL 改成后端地址，例如 http://192.168.1.100:8080
  // SOS 实时接收优先切换为接口文档中的 WebSocket：WS /ws/alerts?token=<JWT_TOKEN>
  static readonly API_BASE_URL: string = 'http://172.29.8.105:8080';
  static readonly USE_MOCK: boolean = false;
  static readonly ENABLE_MOCK_SOS_PUSH: boolean = true;
  static readonly MOCK_SOS_DELAY: number = 5000;
}
