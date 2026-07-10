import { webSocket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../common/Constants';
import { StorageKeys } from '../common/StorageKeys';
import { Alert } from '../models/Alert';
import { Result } from '../models/Result';
import { MockService } from './MockService';

type SosAlertCallback = (alert: Alert) => void;

interface WsAlertData {
  alertId: number;
  type: string;
  typeName?: string;
  elderlyId?: number;
  elderlyName: string;
  communityId: number;
  communityName?: string;
  status?: string;
  priority?: string;
  happenedAt: string;
}

interface WsMessage {
  type: string;
  data: WsAlertData;
}

export class AlertPushService {
  private static timerId: number = -1;
  private static ws: webSocket.WebSocket | null = null;
  private static reconnectTimer: number = -1;
  private static sosCallback: SosAlertCallback | null = null;

  static startMockSosPush(callback: SosAlertCallback): void {
    AlertPushService.stopMockSosPush();
    AlertPushService.sosCallback = callback;

    if (!Constants.USE_MOCK) {
      AlertPushService.connectWebSocket(callback);
      return;
    }

    if (!Constants.ENABLE_MOCK_SOS_PUSH) {
      return;
    }

    AlertPushService.timerId = setTimeout(() => {
      let result: Result<Alert> = MockService.mockReceiveSosAlert();
      if (result.code !== 0 || result.data === null) {
        return;
      }

      let unreadCount = AppStorage.get<number>(StorageKeys.UNREAD_ALERT_COUNT) ?? 0;
      AppStorage.setOrCreate<boolean>(StorageKeys.HAS_NEW_SOS_ALERT, true);
      AppStorage.setOrCreate<number>(StorageKeys.LATEST_SOS_ALERT_ID, result.data.id);
      AppStorage.setOrCreate<number>(StorageKeys.UNREAD_ALERT_COUNT, unreadCount + 1);
      callback(result.data);
    }, Constants.MOCK_SOS_DELAY);
  }

  static stopMockSosPush(): void {
    if (AlertPushService.timerId >= 0) {
      clearTimeout(AlertPushService.timerId);
      AlertPushService.timerId = -1;
    }
    AlertPushService.disconnectWebSocket();
    AlertPushService.sosCallback = null;
  }

  private static connectWebSocket(callback: SosAlertCallback): void {
    let token = AppStorage.get<string>(StorageKeys.TOKEN);
    if (!token) {
      return;
    }

    let baseUrl = Constants.API_BASE_URL;
    let wsUrl = baseUrl.replace('http://', 'ws://').replace('https://', 'wss://');
    wsUrl = wsUrl + '/ws/alerts?token=' + token;

    try {
      AlertPushService.ws = webSocket.createWebSocket();
      let ws = AlertPushService.ws;

      ws.connect(wsUrl, (err: BusinessError, value: boolean) => {
        if (!err) {
          console.info('[WebSocket] 连接成功');
          AlertPushService.clearReconnect();
        } else {
          console.error('[WebSocket] 连接失败: ' + JSON.stringify(err));
          AlertPushService.scheduleReconnect(callback);
        }
      });

      ws.on('message', (err: BusinessError, data: string | ArrayBuffer) => {
        if (err) {
          console.error('[WebSocket] 消息接收错误: ' + JSON.stringify(err));
          return;
        }
        if (typeof data === 'string') {
          AlertPushService.handleMessage(data, callback);
        }
      });

      ws.on('close', (err: BusinessError, value: Object) => {
        console.info('[WebSocket] 连接关闭');
        AlertPushService.ws = null;
        AlertPushService.scheduleReconnect(callback);
      });

      ws.on('error', (err: BusinessError) => {
        console.error('[WebSocket] 连接错误: ' + JSON.stringify(err));
        AlertPushService.ws = null;
        AlertPushService.scheduleReconnect(callback);
      });
    } catch (error) {
      console.error('[WebSocket] 创建失败: ' + JSON.stringify(error));
      AlertPushService.scheduleReconnect(callback);
    }
  }

  private static handleMessage(data: string, callback: SosAlertCallback): void {
    try {
      let message: WsMessage = JSON.parse(data) as WsMessage;
      if (message.type === 'NEW_ALERT') {
        let alertData = message.data;
        let alert: Alert = {
          id: alertData.alertId,
          type: alertData.type,
          typeName: alertData.typeName ?? alertData.type,
          elderlyId: alertData.elderlyId ?? 0,
          elderlyName: alertData.elderlyName,
          communityId: alertData.communityId,
          communityName: alertData.communityName ?? '',
          status: alertData.status ?? 'PENDING',
          statusName: '待处理',
          priority: alertData.priority ?? 'HIGH',
          happenedAt: alertData.happenedAt
        };

        let unreadCount = AppStorage.get<number>(StorageKeys.UNREAD_ALERT_COUNT) ?? 0;
        AppStorage.setOrCreate<boolean>(StorageKeys.HAS_NEW_SOS_ALERT, true);
        AppStorage.setOrCreate<number>(StorageKeys.LATEST_SOS_ALERT_ID, alert.id);
        AppStorage.setOrCreate<number>(StorageKeys.UNREAD_ALERT_COUNT, unreadCount + 1);
        callback(alert);
      }
    } catch (error) {
      console.error('[WebSocket] 消息解析失败: ' + JSON.stringify(error));
    }
  }

  private static disconnectWebSocket(): void {
    AlertPushService.clearReconnect();
    if (AlertPushService.ws) {
      try {
        AlertPushService.ws.close((err: BusinessError) => {
          if (err) {
            console.error('[WebSocket] 关闭失败: ' + JSON.stringify(err));
          }
        });
      } catch (error) {
      }
      AlertPushService.ws = null;
    }
  }

  private static scheduleReconnect(callback: SosAlertCallback): void {
    AlertPushService.clearReconnect();
    AlertPushService.reconnectTimer = setTimeout(() => {
      let token = AppStorage.get<string>(StorageKeys.TOKEN);
      if (token) {
        AlertPushService.connectWebSocket(callback);
      }
    }, 5000);
  }

  private static clearReconnect(): void {
    if (AlertPushService.reconnectTimer >= 0) {
      clearTimeout(AlertPushService.reconnectTimer);
      AlertPushService.reconnectTimer = -1;
    }
  }
}
