import { Alert, AlertPage } from '../models/Alert';
import { Device } from '../models/Device';
import { Elderly } from '../models/Elderly';
import { Result } from '../models/Result';
import { User } from '../models/User';

const MOCK_TS: string = '2026-07-05T10:00:00Z';
const SOS_TS: string = '2026-07-05T10:30:00Z';

export interface FamilyHomeData {
  elderly: Elderly;
  device: Device;
  latestAlert: Alert;
  unreadCount: number;
}

export interface UnreadCountData {
  unreadCount: number;
}

export class MockService {
  static emptyAlert(): Alert {
    return {
      id: 0,
      type: '',
      typeName: '',
      elderlyId: 0,
      elderlyName: '',
      communityId: 0,
      communityName: '',
      status: '',
      statusName: '',
      priority: '',
      happenedAt: ''
    };
  }

  private static buildDevice(): Device {
    return {
      id: 1,
      name: '王大爷的智能手表',
      type: 'WATCH',
      status: 'ONLINE',
      battery: 85,
      lastHeartbeat: '2026-07-05T09:59:00Z'
    };
  }

  private static buildElderly(): Elderly {
    return {
      id: 1,
      name: '王大爷',
      age: 78,
      gender: 'MALE',
      communityId: 1,
      communityName: '幸福社区',
      address: '幸福社区3号楼101',
      phone: '010-88886666',
      emergencyContact: '13800138001',
      healthNotes: '高血压，每天服药',
      status: 'ACTIVE',
      healthStatus: '良好',
      todayStatus: '今日状态正常，设备在线',
      recentAlertCount: 4,
      device: MockService.buildDevice()
    };
  }

  private static buildSosAlert(): Alert {
    return {
      id: 999,
      type: 'SOS',
      typeName: '紧急求助',
      elderlyId: 1,
      elderlyName: '王大爷',
      communityId: 1,
      communityName: '幸福社区',
      status: 'PENDING',
      statusName: '待处理',
      priority: 'HIGH',
      happenedAt: SOS_TS,
      resolvedAt: '',
      handlerName: '',
      cause: '老人端或设备端触发 SOS',
      details: '系统收到紧急求助告警，请家属尽快确认老人情况，并等待社区人员处理结果。',
      lat: 30.5728,
      lng: 104.0668,
      source: 'WATCH',
      notificationId: 9001
    };
  }

  private static buildAlertList(): Alert[] {
    let sos = MockService.buildSosAlert();
    let fall: Alert = {
      id: 2,
      type: 'FALL',
      typeName: '跌倒告警',
      elderlyId: 1,
      elderlyName: '王大爷',
      communityId: 1,
      communityName: '幸福社区',
      status: 'PROCESSING',
      statusName: '处理中',
      priority: 'HIGH',
      happenedAt: '2026-07-04T18:20:00Z',
      handlerName: '社区值班员',
      cause: '手表检测到疑似跌倒',
      details: '社区人员已接单并联系老人确认情况。',
      source: 'WATCH',
      notificationId: 9002
    };
    let lowBattery: Alert = {
      id: 3,
      type: 'LOW_BATTERY',
      typeName: '低电量告警',
      elderlyId: 1,
      elderlyName: '王大爷',
      communityId: 1,
      communityName: '幸福社区',
      status: 'RESOLVED',
      statusName: '已解决',
      priority: 'MEDIUM',
      happenedAt: '2026-07-03T08:10:00Z',
      resolvedAt: '2026-07-03T09:00:00Z',
      handlerName: '系统提醒',
      cause: '设备电量低于 20%',
      details: '已提醒家属及时充电。',
      source: 'WATCH',
      notificationId: 9003
    };
    let offline: Alert = {
      id: 4,
      type: 'DEVICE_OFFLINE',
      typeName: '设备离线',
      elderlyId: 1,
      elderlyName: '王大爷',
      communityId: 1,
      communityName: '幸福社区',
      status: 'RESOLVED',
      statusName: '已解决',
      priority: 'MEDIUM',
      happenedAt: '2026-07-02T22:10:00Z',
      resolvedAt: '2026-07-02T22:30:00Z',
      handlerName: '系统提醒',
      cause: '设备短暂离线',
      details: '设备已恢复在线。',
      source: 'SYSTEM',
      notificationId: 9004
    };
    return [sos, fall, lowBattery, offline];
  }

  static mockLogin(username: string, password: string): Result<User> {
    if (username.length === 0 || password.length === 0) {
      return {
        code: 400,
        message: '请输入账号和密码',
        data: null,
        ts: MOCK_TS
      };
    }

    return {
      code: 0,
      message: 'success',
      data: {
        token: 'mock-family-token',
        userId: 1001,
        role: 'FAMILY',
        realName: '王小明',
        elderlyId: 1,
        elderlyName: '王大爷',
        communityId: 1,
        communityName: '幸福社区'
      },
      ts: MOCK_TS
    };
  }

  static mockGetFamilyHome(): Result<FamilyHomeData> {
    let alerts = MockService.buildAlertList();
    return {
      code: 0,
      message: 'success',
      data: {
        elderly: MockService.buildElderly(),
        device: MockService.buildDevice(),
        latestAlert: alerts[1],
        unreadCount: 0
      },
      ts: MOCK_TS
    };
  }

  static mockReceiveSosAlert(): Result<Alert> {
    return {
      code: 0,
      message: '收到新的 SOS 告警',
      data: MockService.buildSosAlert(),
      ts: SOS_TS
    };
  }

  static mockGetAlertList(): Result<AlertPage> {
    let records = MockService.buildAlertList();
    return {
      code: 0,
      message: 'success',
      data: {
        records: records,
        total: records.length,
        page: 1,
        size: 20
      },
      ts: MOCK_TS
    };
  }

  static mockGetUnreadCount(): Result<UnreadCountData> {
    return {
      code: 0,
      message: 'success',
      data: {
        unreadCount: 0
      },
      ts: MOCK_TS
    };
  }

  static mockMarkNotificationRead(notificationId: number): Result<UnreadCountData> {
    return {
      code: 0,
      message: `通知 ${notificationId} 已读`,
      data: {
        unreadCount: 0
      },
      ts: MOCK_TS
    };
  }

  static mockGetAlertDetail(alertId: number): Result<Alert> {
    let records = MockService.buildAlertList();
    for (let index = 0; index < records.length; index++) {
      if (records[index].id === alertId) {
        return {
          code: 0,
          message: 'success',
          data: records[index],
          ts: MOCK_TS
        };
      }
    }

    return {
      code: 404,
      message: '告警不存在',
      data: null,
      ts: MOCK_TS
    };
  }

  static mockGetElderlyStatus(): Result<Elderly> {
    return {
      code: 0,
      message: 'success',
      data: MockService.buildElderly(),
      ts: MOCK_TS
    };
  }
}
