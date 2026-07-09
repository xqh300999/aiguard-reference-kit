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
  @StorageLink('userId') userId: number = 0;
  @StorageLink('elderlyId') elderlyId: number = 0;
  @StorageLink('unreadAlertCount') unreadAlertCount: number = 0;
  @State elderly: Elderly = EMPTY_ELDERLY;
  @State device: Device = EMPTY_DEVICE;
  @State latestAlert: Alert = EMPTY_ALERT;
  @State hasData: boolean = false;
  @State loading: boolean = false;
  @State errorMessage: string = '';
  @State pushTip: string = '正在监听老人端与设备端告警';

  aboutToAppear(): void {
    if (this.elderlyId <= 0) {
      router.replaceUrl({ url: 'pages/BindElderly' });
      return;
    }
    this.loadHome();
    AlertPushService.startMockSosPush((alert: Alert) => {
      this.handleReceivedSosAlert(alert);
    });
  }

  aboutToDisappear(): void {
    AlertPushService.stopMockSosPush();
  }

  private async loadHome(): Promise<void> {
    this.loading = true;
    this.errorMessage = '';
    let result = await ApiService.getFamilyHome(this.elderlyId, this.userId);
    this.loading = false;

    if (!ApiService.isSuccess<FamilyHomeData>(result) || result.data === null) {
      this.errorMessage = result.message || '首页数据加载失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    this.elderly = result.data.elderly;
    this.device = result.data.device;
    this.latestAlert = result.data.latestAlert;
    this.unreadAlertCount = result.data.unreadCount;
    AppStorage.setOrCreate<number>(StorageKeys.UNREAD_ALERT_COUNT, this.unreadAlertCount);
    this.hasData = true;
  }

  private handleReceivedSosAlert(alert: Alert): void {
    this.latestAlert = alert;
    this.unreadAlertCount = AppStorage.get<number>(StorageKeys.UNREAD_ALERT_COUNT) ?? this.unreadAlertCount + 1;
    this.pushTip = `${alert.elderlyName} 触发紧急求助`;
    router.pushUrl({
      url: 'pages/SosAlert',
      params: {
        alertId: alert.id
      }
    });
  }

  private statusColor(status: string): string {
    if (status === 'ONLINE' || status === 'ACTIVE') {
      return '#12B76A';
    }
    if (status === 'PENDING' || status === 'HIGH') {
      return '#D92D20';
    }
    return '#667085';
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Column({ space: 14 }) {
          Row() {
            Column({ space: 5 }) {
              Text(`你好，${this.realName || '家人用户'}`)
                .fontSize(16)
                .fontColor('#DDE7FF')
              Text('家人守护中心')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
            }
            .layoutWeight(1)

            Column({ space: 2 }) {
              Text(`${this.unreadAlertCount}`)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text('未读')
                .fontSize(12)
                .fontColor('#DDE7FF')
            }
            .width(58)
            .height(58)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#D92D20')
            .borderRadius(8)
          }
          .width('100%')

          Text(this.pushTip)
            .fontSize(14)
            .fontColor('#EAF1FF')
            .width('100%')
            .padding(12)
            .backgroundColor('#245AA8')
            .borderRadius(8)
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 22, bottom: 18 })
        .backgroundColor('#123B7A')
        .borderRadius(8)

        if (this.loading) {
          Text('正在加载...')
            .fontSize(16)
            .fontColor('#667085')
        } else if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#D92D20')
            .padding(12)
            .width('100%')
            .backgroundColor('#FFF1F0')
            .borderRadius(8)
        } else if (this.hasData) {
          Row({ space: 10 }) {
            Column({ space: 8 }) {
              Text('老人状态')
                .fontSize(15)
                .fontColor('#667085')
              Text(this.elderly.name)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#172033')
              Text(`${this.elderly.age} 岁 · ${this.elderly.communityName}`)
                .fontSize(13)
                .fontColor('#667085')
              Text(this.elderly.todayStatus)
                .fontSize(14)
                .fontColor('#12B76A')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)

            Column({ space: 8 }) {
              Text('设备')
                .fontSize(15)
                .fontColor('#667085')
              Text(`${this.device?.battery ?? 0}%`)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor('#172033')
              Text((this.device?.status ?? '') === 'ONLINE' ? '在线' : '离线')
                .fontSize(14)
                .fontColor(this.statusColor(this.device?.status ?? ''))
              Text('电量')
                .fontSize(13)
                .fontColor('#98A2B3')
            }
            .width(112)
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
          }
          .width('100%')

          Column({ space: 12 }) {
            Row() {
              Text('最新告警')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#172033')
              Blank()
              Text(this.latestAlert.type === 'SOS' ? '紧急' : (this.latestAlert.priority || '普通'))
                .fontSize(13)
                .fontColor(this.latestAlert.type === 'SOS' ? '#D92D20' : '#246BFD')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(this.latestAlert.type === 'SOS' ? '#FFF1F0' : '#EEF4FF')
                .borderRadius(8)
            }
            .width('100%')

            Text(this.latestAlert.typeName || '暂无告警')
              .fontSize(21)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.latestAlert.type === 'SOS' ? '#D92D20' : '#172033')
            Text(`状态：${this.latestAlert.statusName || '-'}`)
              .fontSize(14)
              .fontColor('#344054')
            Text(`时间：${this.latestAlert.happenedAt || '-'}`)
              .fontSize(13)
              .fontColor('#667085')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.latestAlert.type === 'SOS' ? '#FFF1F0' : Color.White)
          .borderRadius(8)
          .onClick(() => {
            if (this.latestAlert.id > 0) {
              router.pushUrl({ url: 'pages/AlertDetail', params: { alertId: this.latestAlert.id } });
            }
          })

          Text('快捷入口')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
            .width('100%')
            .margin({ top: 4 })

          Row({ space: 10 }) {
            Button('老人档案')
              .layoutWeight(1)
              .height(50)
              .fontSize(15)
              .backgroundColor('#246BFD')
              .borderRadius(8)
              .onClick(() => {
                router.pushUrl({ url: 'pages/ElderlyProfile' });
              })
            Button('告警记录')
              .layoutWeight(1)
              .height(50)
              .fontSize(15)
              .backgroundColor('#172033')
              .borderRadius(8)
              .onClick(() => {
                router.pushUrl({ url: 'pages/AlertList' });
              })
          }
          .width('100%')

          Button('个人中心')
            .width('100%')
            .height(50)
            .fontSize(15)
            .backgroundColor('#EEF4FF')
            .fontColor('#246BFD')
            .borderRadius(8)
            .onClick(() => {
              router.pushUrl({ url: 'pages/PersonalCenter' });
            })

          Text(`最近心跳：${this.device?.lastHeartbeat || '-'}`)
            .fontSize(12)
            .fontColor('#98A2B3')
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 4 })
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
  }
}
