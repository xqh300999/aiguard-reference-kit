import { promptAction, router } from '@kit.ArkUI';
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
    this.alertId = params.alertId ?? 0;
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
  }

  build() {
    Column({ space: 18 }) {
      Text('紧急 SOS 告警')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      if (this.errorMessage.length > 0) {
        Text(this.errorMessage)
          .fontSize(16)
          .fontColor(Color.White)
      }

      if (this.hasAlert) {
        Text(`${this.alert.elderlyName} 正在紧急求助`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Column({ space: 10 }) {
          Text(`告警类型：${this.alert.typeName}`)
          Text(`所属社区：${this.alert.communityName}`)
          Text(`发生时间：${this.alert.happenedAt}`)
          Text(`告警状态：${this.alert.statusName}`)
          Text(`告警来源：${this.alert.source || '-'}`)
          Text(`提示信息：${this.alert.details || '请尽快关注老人状态并联系老人。'}`)
          Text(`位置：${this.alert.lat ?? '-'} / ${this.alert.lng ?? '-'}`)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFF0F0')
        .borderRadius(8)

        Button('查看告警详情')
          .width('100%')
          .height(48)
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
          .height(48)
          .onClick(() => {
            router.replaceUrl({ url: 'pages/FamilyHome' });
          })
      }
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#B00020')
  }
}
