import { Constants } from '../common/Constants';
import { StorageKeys } from '../common/StorageKeys';
import { Alert } from '../models/Alert';
import { Result } from '../models/Result';
import { MockService } from './MockService';

type SosAlertCallback = (alert: Alert) => void;

export class AlertPushService {
  private static timerId: number = -1;

  static startMockSosPush(callback: SosAlertCallback): void {
    AlertPushService.stopMockSosPush();

    if (!Constants.ENABLE_MOCK_SOS_PUSH) {
      return;
    }

    // 后端完成后，这里替换为接口文档中的实时告警通道：
    // WS /ws/alerts?token=<JWT_TOKEN>
    // WebSocket 暂未完成时，可临时轮询：
    // GET /api/v1/alerts?type=SOS&status=PENDING&page=1&size=20
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
  }
}
