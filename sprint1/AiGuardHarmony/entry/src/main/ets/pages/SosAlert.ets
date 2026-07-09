import { promptAction, router } from '@kit.ArkUI';
import { StorageKeys } from '../common/StorageKeys';
import { Alert } from '../models/Alert';
import { ApiService } from '../services/ApiService';

interface SosAlertParams {
  alertId?: number;
}

const EMPTY_SOS_ALERT: Alert = {
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
struct SosAlert {
  @State alertId: number = 0;
  @State alert: Alert = EMPTY_SOS_ALERT;
  @State hasAlert: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    let params = router.getParams() as SosAlertParams;
    this.alertId = params === undefined ? 0 : (params.alertId ?? 0);
    if (this.alertId <= 0) {
      this.errorMessage = '缺少 SOS 告警 ID';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }
    this.loadAlert();
  }

  private async loadAlert(): Promise<void> {
    let result = await ApiService.getAlertDetail(this.alertId);
    if (!ApiService.isSuccess<Alert>(result) || result.data === null) {
      this.errorMessage = result.message || 'SOS 告警加载失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }
    this.alert = result.data;
    this.hasAlert = true;
    this.markSosRead();
  }

  private async markSosRead(): Promise<void> {
    if (this.alert.notificationId !== undefined) {
      await ApiService.markNotificationRead(this.alert.notificationId);
    }
    let unreadCount = AppStorage.get<number>(StorageKeys.UNREAD_ALERT_COUNT) ?? 0;
    AppStorage.setOrCreate<number>(StorageKeys.UNREAD_ALERT_COUNT, unreadCount > 0 ? unreadCount - 1 : 0);
    AppStorage.setOrCreate<boolean>(StorageKeys.HAS_NEW_SOS_ALERT, false);
    AppStorage.setOrCreate<number>(StorageKeys.LATEST_SOS_ALERT_ID, 0);
  }

  build() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('SOS')
          .fontSize(58)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        Text('紧急求助告警')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        Text('家人端已收到新的紧急告警')
          .fontSize(15)
          .fontColor('#FFE3E0')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      if (this.errorMessage.length > 0) {
        Text(this.errorMessage)
          .fontSize(16)
          .fontColor(Color.White)
      }

      if (this.hasAlert) {
        Column({ space: 14 }) {
          Text(`${this.alert.elderlyName} 正在紧急求助`)
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
            .textAlign(TextAlign.Center)
            .width('100%')

          Column({ space: 10 }) {
            Row() {
              Text('告警类型')
                .fontSize(14)
                .fontColor('#667085')
              Blank()
              Text(this.alert.typeName)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#D92D20')
            }
            Row() {
              Text('所属社区')
                .fontSize(14)
                .fontColor('#667085')
              Blank()
              Text(this.alert.communityName)
                .fontSize(15)
                .fontColor('#172033')
            }
            Row() {
              Text('发生时间')
                .fontSize(14)
                .fontColor('#667085')
              Blank()
              Text(this.alert.happenedAt)
                .fontSize(15)
                .fontColor('#172033')
            }
            Row() {
              Text('来源')
                .fontSize(14)
                .fontColor('#667085')
              Blank()
              Text(this.alert.source || '-')
                .fontSize(15)
                .fontColor('#172033')
            }
            Row() {
              Text('处理状态')
                .fontSize(14)
                .fontColor('#667085')
              Blank()
              Text(this.alert.statusName)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#D92D20')
            }
          }
          .width('100%')

          Text(this.alert.details || '请尽快关注老人状态并联系老人。')
            .fontSize(15)
            .fontColor('#344054')
            .lineHeight(22)
            .width('100%')
            .padding(12)
            .backgroundColor('#FFF8F7')
            .borderRadius(8)
        }
        .width('100%')
        .padding(18)
        .backgroundColor(Color.White)
        .borderRadius(8)

        Button('查看告警详情')
          .width('100%')
          .height(52)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.White)
          .fontColor('#B42318')
          .borderRadius(8)
          .onClick(() => {
            router.replaceUrl({
              url: 'pages/AlertDetail',
              params: {
                alertId: this.alert.id
              }
            });
          })

        Button('返回首页')
          .width('100%')
          .height(52)
          .fontSize(16)
          .backgroundColor('#7A0015')
          .fontColor(Color.White)
          .borderRadius(8)
          .onClick(() => {
            router.replaceUrl({ url: 'pages/FamilyHome' });
          })
      }
    }
    .width('100%')
    .height('100%')
    .padding(22)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#B42318')
  }
}
