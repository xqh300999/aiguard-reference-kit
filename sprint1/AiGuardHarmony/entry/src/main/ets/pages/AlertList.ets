import { promptAction, router } from '@kit.ArkUI';
import { Alert, AlertPage } from '../models/Alert';
import { ApiService } from '../services/ApiService';

@Entry
@Component
struct AlertList {
  @State alerts: Alert[] = [];
  @State loading: boolean = false;
  @State errorMessage: string = '';
  @State page: number = 1;
  @State pageSize: number = 20;

  aboutToAppear(): void {
    this.loadAlerts();
  }

  private async loadAlerts(): Promise<void> {
    this.loading = true;
    this.errorMessage = '';

    let result = await ApiService.getAlertList(this.page, this.pageSize);
    this.loading = false;

    if (!ApiService.isSuccess<AlertPage>(result) || result.data === null) {
      this.errorMessage = result.message || '告警列表加载失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    this.alerts = result.data.records;
  }

  private openDetail(alertId: number): void {
    router.pushUrl({
      url: 'pages/AlertDetail',
      params: {
        alertId: alertId
      }
    });
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Button('返回')
          .height(36)
          .onClick(() => {
            router.back();
          })
        Text('告警记录')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
        Blank()
        Button('刷新')
          .height(36)
          .onClick(() => {
            this.loadAlerts();
          })
      }
      .width('100%')

      if (this.loading) {
        Text('加载中...')
          .fontSize(16)
      } else if (this.errorMessage.length > 0) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor(Color.Red)
      } else if (this.alerts.length === 0) {
        Text('暂无告警')
          .fontSize(16)
          .fontColor(Color.Gray)
      } else {
        List({ space: 10 }) {
          ForEach(this.alerts, (item: Alert) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Text(item.typeName)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(item.type === 'SOS' ? Color.Red : Color.Black)
                  Blank()
                  Text(item.priority)
                    .fontSize(14)
                    .fontColor(item.priority === 'HIGH' ? Color.Red : '#E69100')
                }
                .width('100%')

                Text(`老人：${item.elderlyName}`)
                  .fontSize(14)
                Text(`社区：${item.communityName}`)
                  .fontSize(14)
                Text(`状态：${item.statusName}`)
                  .fontSize(14)
                  .fontColor('#1F5FBF')
                Text(`时间：${item.happenedAt}`)
                  .fontSize(14)
                  .fontColor(Color.Gray)
                Text(`来源：${item.source || '-'}`)
                  .fontSize(14)
                  .fontColor(Color.Gray)
              }
              .width('100%')
              .padding(14)
              .backgroundColor(item.type === 'SOS' ? '#FFF0F0' : '#F7F8FA')
              .borderRadius(8)
              .onClick(() => {
                this.openDetail(item.id);
              })
            }
          }, (item: Alert) => item.id.toString())
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
