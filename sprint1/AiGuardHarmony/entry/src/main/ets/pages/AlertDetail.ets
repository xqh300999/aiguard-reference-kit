import { promptAction, router } from '@kit.ArkUI';
import { StorageKeys } from '../common/StorageKeys';
import { Alert } from '../models/Alert';
import { ApiService } from '../services/ApiService';

interface AlertDetailParams {
  alertId?: number;
  id?: number;
}

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
struct AlertDetail {
  @State alertId: number = 0;
  @State alert: Alert = EMPTY_ALERT;
  @State hasAlert: boolean = false;
  @State loading: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    let params = router.getParams() as AlertDetailParams;
    this.alertId = params === undefined ? 0 : (params.alertId ?? params.id ?? 0);
    if (this.alertId <= 0) {
      this.errorMessage = '缺少告警 ID';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }
    this.loadAlertDetail();
  }

  private async loadAlertDetail(): Promise<void> {
    this.loading = true;
    this.errorMessage = '';

    let result = await ApiService.getAlertDetail(this.alertId);
    this.loading = false;

    if (!ApiService.isSuccess<Alert>(result) || result.data === null) {
      this.errorMessage = result.message || '告警详情加载失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    this.alert = result.data;
    this.hasAlert = true;
    if (this.alert.type === 'SOS') {
      this.markSosRead();
    }
  }

  private markSosRead(): void {
    if (this.alert.notificationId !== undefined) {
      ApiService.markNotificationRead(this.alert.notificationId);
    }
    let unreadCount = AppStorage.get<number>(StorageKeys.UNREAD_ALERT_COUNT) ?? 0;
    AppStorage.setOrCreate<number>(StorageKeys.UNREAD_ALERT_COUNT, unreadCount > 0 ? unreadCount - 1 : 0);
    AppStorage.setOrCreate<boolean>(StorageKeys.HAS_NEW_SOS_ALERT, false);
    AppStorage.setOrCreate<number>(StorageKeys.LATEST_SOS_ALERT_ID, 0);
  }

  private contactElderly(): void {
    promptAction.showToast({ message: '请尽快通过电话联系老人' });
  }

  private statusColor(status: string): string {
    if (status === 'PENDING') {
      return '#D92D20';
    }
    if (status === 'PROCESSING') {
      return '#E69100';
    }
    if (status === 'RESOLVED') {
      return '#12B76A';
    }
    return '#667085';
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Row() {
          Button('返回')
            .height(38)
            .backgroundColor('#EEF4FF')
            .fontColor('#246BFD')
            .borderRadius(8)
            .onClick(() => {
              router.back();
            })
          Text('告警详情')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
            .margin({ left: 12 })
          Blank()
        }
        .width('100%')

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
        } else if (this.hasAlert) {
          Column({ space: 12 }) {
            Text(this.alert.type === 'SOS' ? '紧急求助' : this.alert.typeName)
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.alert.type === 'SOS' ? '#D92D20' : '#172033')
              .width('100%')
            Text(this.alert.type === 'SOS' ? '请尽快确认老人情况，并关注社区处理进度。' : '告警详情如下')
              .fontSize(14)
              .fontColor('#667085')
              .width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(this.alert.type === 'SOS' ? '#FFF1F0' : Color.White)
          .borderRadius(8)

          Column({ space: 12 }) {
            Row() {
              Text('告警状态')
                .fontSize(14)
                .fontColor('#667085')
              Blank()
              Text(this.alert.statusName)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.statusColor(this.alert.status))
            }
            Row() {
              Text('家属查看状态')
                .fontSize(14)
                .fontColor('#667085')
              Blank()
              Text(this.alert.type === 'SOS' ? '已读' : '-')
                .fontSize(14)
                .fontColor(this.alert.type === 'SOS' ? '#12B76A' : '#667085')
            }
            Row() {
              Text('优先级')
                .fontSize(14)
                .fontColor('#667085')
              Blank()
              Text(this.alert.priority)
                .fontSize(14)
                .fontColor(this.alert.priority === 'HIGH' ? '#D92D20' : '#E69100')
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)

          Column({ space: 11 }) {
            Text(`老人姓名：${this.alert.elderlyName}`)
              .fontSize(15)
              .fontColor('#344054')
            Text(`社区名称：${this.alert.communityName}`)
              .fontSize(15)
              .fontColor('#344054')
            Text(`发生时间：${this.alert.happenedAt}`)
              .fontSize(15)
              .fontColor('#344054')
            Text(`解决时间：${this.alert.resolvedAt || '-'}`)
              .fontSize(15)
              .fontColor('#344054')
            Text(`处理人：${this.alert.handlerName || '-'}`)
              .fontSize(15)
              .fontColor('#344054')
            Text(`告警来源：${this.alert.source || '-'}`)
              .fontSize(15)
              .fontColor('#344054')
            Text(`位置信息：${this.alert.lat ?? '-'} / ${this.alert.lng ?? '-'}`)
              .fontSize(15)
              .fontColor('#344054')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)

          Column({ space: 10 }) {
            Text('告警说明')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#172033')
            Text(this.alert.cause || '-')
              .fontSize(15)
              .fontColor('#344054')
              .lineHeight(22)
            Text(this.alert.details || '-')
              .fontSize(15)
              .fontColor('#667085')
              .lineHeight(22)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)

          Button('联系老人')
            .width('100%')
            .height(50)
            .fontSize(16)
            .backgroundColor('#246BFD')
            .borderRadius(8)
            .onClick(() => {
              this.contactElderly();
            })

          Button('返回告警列表')
            .width('100%')
            .height(50)
            .fontSize(16)
            .backgroundColor('#EEF4FF')
            .fontColor('#246BFD')
            .borderRadius(8)
            .onClick(() => {
              router.replaceUrl({ url: 'pages/AlertList' });
            })
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
