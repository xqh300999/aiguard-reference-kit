import { promptAction, router } from '@kit.ArkUI';
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
    this.alertId = params.alertId ?? params.id ?? 0;
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
  }

  private contactElderly(): void {
    promptAction.showToast({ message: '请尽快通过电话联系老人' });
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Row() {
          Button('返回')
            .height(36)
            .onClick(() => {
              router.back();
            })
          Text('告警详情')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })
        }
        .width('100%')

        if (this.loading) {
          Text('加载中...')
            .fontSize(16)
        } else if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor(Color.Red)
        } else if (this.hasAlert) {
          if (this.alert.type === 'SOS') {
            Text('紧急求助')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Red)
          }

          Column({ space: 12 }) {
            Text(`告警类型：${this.alert.typeName}`)
            Text(`老人姓名：${this.alert.elderlyName}`)
            Text(`社区名称：${this.alert.communityName}`)
            Text(`告警状态：${this.alert.statusName}`)
            Text(`优先级：${this.alert.priority}`)
            Text(`发生时间：${this.alert.happenedAt}`)
            Text(`解决时间：${this.alert.resolvedAt || '-'}`)
            Text(`处理人：${this.alert.handlerName || '-'}`)
            Text(`告警原因：${this.alert.cause || '-'}`)
            Text(`处理详情：${this.alert.details || '-'}`)
            Text(`来源：${this.alert.source || '-'}`)
            Text(`位置：${this.alert.lat ?? '-'} / ${this.alert.lng ?? '-'}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.alert.type === 'SOS' ? '#FFF0F0' : '#F7F8FA')
          .borderRadius(8)

          Button('联系老人')
            .width('100%')
            .height(44)
            .onClick(() => {
              this.contactElderly();
            })

          Button('返回告警列表')
            .width('100%')
            .height(44)
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
  }
}
