import { promptAction, router } from '@kit.ArkUI';
import { StorageKeys } from '../common/StorageKeys';
import { Alert } from '../models/Alert';
import { Device } from '../models/Device';
import { Elderly } from '../models/Elderly';
import { ApiService } from '../services/ApiService';
import { AlertPushService } from '../services/AlertPushService';
import { FamilyHomeData } from '../services/MockService';

const EMPTY_DEVICE: Device = {
  id: 0,
  name: '',
  type: '',
  status: ''
};

const EMPTY_ELDERLY: Elderly = {
  id: 0,
  name: '',
  age: 0,
  gender: '',
  communityName: '',
  address: '',
  status: '',
  healthStatus: '',
  todayStatus: '',
  device: EMPTY_DEVICE
};

const EMPTY_ALERT: Alert = {
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

@Entry
@Component
struct FamilyHome {
  @StorageLink('realName') realName: string = '';
  @StorageLink('elderlyId') elderlyId: number = 0;
  @StorageLink('unreadAlertCount') unreadAlertCount: number = 0;
  @State elderly: Elderly = EMPTY_ELDERLY;
  @State device: Device = EMPTY_DEVICE;
  @State latestAlert: Alert = EMPTY_ALERT;
  @State hasData: boolean = false;
  @State errorMessage: string = '';
  @State sosPushStatus: string = 'Mock SOS 监听未启动';

  aboutToAppear(): void {
    this.loadHome();
    this.sosPushStatus = 'Mock SOS 监听已启动，5 秒后模拟接收告警';
    AlertPushService.startMockSosPush((alert: Alert) => {
      this.handleReceivedSosAlert(alert);
    });
  }

  aboutToDisappear(): void {
    AlertPushService.stopMockSosPush();
  }

  private async loadHome(): Promise<void> {
    let result = await ApiService.getFamilyHome(this.elderlyId);
    if (!ApiService.isSuccess<FamilyHomeData>(result) || result.data === null) {
      this.errorMessage = result.message || '首页数据加载失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }
    this.elderly = result.data.elderly;
    this.device = result.data.device;
    this.latestAlert = result.data.latestAlert;
    this.unreadAlertCount = result.data.unreadCount;
    AppStorage.setOrCreate<number>(StorageKeys.UNREAD_ALERT_COUNT, result.data.unreadCount);
    this.hasData = true;
  }

  private handleReceivedSosAlert(alert: Alert): void {
    this.latestAlert = alert;
    this.unreadAlertCount = AppStorage.get<number>(StorageKeys.UNREAD_ALERT_COUNT) ?? this.unreadAlertCount + 1;
    this.sosPushStatus = `已收到 SOS 告警：${alert.elderlyName}正在求助`;

    router.pushUrl({
      url: 'pages/SosAlert',
      params: {
        alertId: alert.id
      }
    });
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text(`你好，${this.realName || '子女用户'}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Text('子女端首页')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)

        Text(this.sosPushStatus)
          .fontSize(14)
          .fontColor(this.latestAlert.type === 'SOS' ? Color.Red : Color.Gray)

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor(Color.Red)
        }

        if (this.hasData) {
          Column({ space: 8 }) {
            Text('老人状态')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Text(`老人姓名：${this.elderly.name}`)
            Text(`年龄：${this.elderly.age}`)
            Text(`所属社区：${this.elderly.communityName}`)
            Text(`今日状态：${this.elderly.todayStatus}`)
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#F7F8FA')
          .borderRadius(8)

          Column({ space: 8 }) {
            Text('设备状态')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Text(`设备名称：${this.device.name}`)
            Text(`在线状态：${this.device.status}`)
            Text(`电量：${this.device.battery ?? 0}%`)
            Text(`最近心跳：${this.device.lastHeartbeat || '-'}`)
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#F7F8FA')
          .borderRadius(8)

          Column({ space: 8 }) {
            Text('最新告警')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Text(`告警类型：${this.latestAlert.typeName}`)
              .fontColor(this.latestAlert.type === 'SOS' ? Color.Red : Color.Black)
            Text(`告警状态：${this.latestAlert.statusName}`)
            Text(`告警时间：${this.latestAlert.happenedAt}`)
            Text(`未读告警数量：${this.unreadAlertCount}`)
              .fontColor(Color.Red)
          }
          .width('100%')
          .padding(14)
          .backgroundColor(this.latestAlert.type === 'SOS' ? '#FFF0F0' : '#F7F8FA')
          .borderRadius(8)
        }

        Button('查看老人档案')
          .width('100%')
          .height(44)
          .onClick(() => {
            router.pushUrl({ url: 'pages/ElderlyProfile' });
          })
        Button('查看告警记录')
          .width('100%')
          .height(44)
          .onClick(() => {
            router.pushUrl({ url: 'pages/AlertList' });
          })
        Button('个人中心')
          .width('100%')
          .height(44)
          .onClick(() => {
            router.pushUrl({ url: 'pages/PersonalCenter' });
          })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}
