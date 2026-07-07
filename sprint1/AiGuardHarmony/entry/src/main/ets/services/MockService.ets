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

export class MockService {
  static emptyAlert(): Alert {
    let alert: Alert = {
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
    return alert;
  }

  private static buildSosAlert(): Alert {
    let alert: Alert = {
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
      cause: '老人主动发起 SOS 求助',
      details: '系统收到老人端或设备端发出的紧急求助信息，请子女尽快关注并联系老人。',
      lat: 30.5728,
      lng: 104.0668,
      source: 'APP'
    };
    return alert;
  }

  private static buildDevice(): Device {
    let device: Device = {
      id: 1,
      name: '王大爷的智能手表',
      type: 'WATCH',
      status: 'ONLINE',
      battery: 85,
      lastHeartbeat: '2026-07-05T09:59:00Z'
    };
    return device;
  }

  private static buildElderly(): Elderly {
    let elderly: Elderly = {
      id: 1,
      name: '王大爷',
      age: 78,
      gender: 'MALE',
      communityName: '幸福社区',
      address: '幸福社区3号楼101',
      phone: '010-88886666',
      emergencyContact: '13800138001',
      healthNotes: '高血压，每天服药',
      status: 'ACTIVE',
      healthStatus: '良好',
      todayStatus: '今日状态正常',
      recentAlertCount: 4,
      device: MockService.buildDevice()
    };
    return elderly;
  }

  private static buildAlertList(): Alert[] {
    let sos: Alert = MockService.buildSosAlert();
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
      cause: '手表检测到疑似跌倒',
      details: '社区人员已联系老人确认情况。',
      source: 'WATCH'
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
      source: 'WATCH'
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
      source: 'SYSTEM'
    };
    return [sos, fall, lowBattery, offline];
  }

  static mockLogin(username: string, password: string): Result<User> {
    if (username.length === 0 || password.length === 0) {
      let error: Result<User> = {
        code: 400,
        message: '请输入账号和密码',
        data: null,
        ts: MOCK_TS
      };
      return error;
    }

    let user: User = {
      token: 'mock-family-token',
      userId: 1001,
      role: 'FAMILY',
      realName: '王小明',
      elderlyId: 1,
      elderlyName: '王大爷',
      communityId: 1,
      communityName: '幸福社区'
    };
    let result: Result<User> = {
      code: 0,
      message: 'success',
      data: user,
      ts: MOCK_TS
    };
    return result;
  }

  static mockGetFamilyHome(): Result<FamilyHomeData> {
    let latestAlert: Alert = {
      id: 1,
      type: 'LOW_BATTERY',
      typeName: '低电量告警',
      elderlyId: 1,
      elderlyName: '王大爷',
      communityId: 1,
      communityName: '幸福社区',
      status: 'RESOLVED',
      statusName: '已解决',
      priority: 'MEDIUM',
      happenedAt: '2026-07-05T08:30:00Z',
      source: 'WATCH'
    };
    let data: FamilyHomeData = {
      elderly: MockService.buildElderly(),
      device: MockService.buildDevice(),
      latestAlert: latestAlert,
      unreadCount: 1
    };
    let result: Result<FamilyHomeData> = {
      code: 0,
      message: 'success',
      data: data,
      ts: MOCK_TS
    };
    return result;
  }

  static mockReceiveSosAlert(): Result<Alert> {
    let result: Result<Alert> = {
      code: 0,
      message: '收到新的 SOS 告警',
      data: MockService.buildSosAlert(),
      ts: SOS_TS
    };
    return result;
  }

  static mockGetAlertList(): Result<AlertPage> {
    let records: Alert[] = MockService.buildAlertList();
    let page: AlertPage = {
      records: records,
      total: records.length,
      page: 1,
      size: 20
    };
    let result: Result<AlertPage> = {
      code: 0,
      message: 'success',
      data: page,
      ts: MOCK_TS
    };
    return result;
  }

  static mockGetAlertDetail(alertId: number): Result<Alert> {
    let records: Alert[] = MockService.buildAlertList();
    for (let index = 0; index < records.length; index++) {
      if (records[index].id === alertId) {
        let success: Result<Alert> = {
          code: 0,
          message: 'success',
          data: records[index],
          ts: MOCK_TS
        };
        return success;
      }
    }

    let error: Result<Alert> = {
      code: 404,
      message: '告警不存在',
      data: null,
      ts: MOCK_TS
    };
    return error;
  }

  static mockGetElderlyStatus(): Result<Elderly> {
    let result: Result<Elderly> = {
      code: 0,
      message: 'success',
      data: MockService.buildElderly(),
      ts: MOCK_TS
    };
    return result;
  }
}
