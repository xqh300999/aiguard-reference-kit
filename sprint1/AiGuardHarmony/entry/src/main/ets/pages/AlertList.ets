import { promptAction, router } from '@kit.ArkUI';
import { Alert, AlertPage } from '../models/Alert';
import { ApiService } from '../services/ApiService';

@Entry
@Component
struct AlertList {
  @StorageLink('elderlyId') elderlyId: number = 0;
  @StorageLink('latestSosAlertId') latestSosAlertId: number = 0;
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

    let result = await ApiService.getElderlyAlertList(this.elderlyId, this.page, this.pageSize);
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

  private priorityText(priority: string): string {
    if (priority === 'HIGH') {
      return '高优先级';
    }
    if (priority === 'MEDIUM') {
      return '中优先级';
    }
    return priority || '普通';
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
    Column({ space: 12 }) {
      Row() {
        Button('返回')
          .height(38)
          .backgroundColor('#EEF4FF')
          .fontColor('#246BFD')
          .borderRadius(8)
          .onClick(() => {
            router.back();
          })
        Column({ space: 2 }) {
          Text('告警记录')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
          Text('来自老人端、设备端和系统规则')
            .fontSize(12)
            .fontColor('#98A2B3')
        }
        .margin({ left: 12 })
        .layoutWeight(1)

        Button('刷新')
          .height(38)
          .backgroundColor('#246BFD')
          .borderRadius(8)
          .onClick(() => {
            this.loadAlerts();
          })
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
      } else if (this.alerts.length === 0) {
        Column({ space: 8 }) {
          Text('暂无告警')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
          Text('老人状态正常时，这里会保持安静。')
            .fontSize(14)
            .fontColor('#667085')
        }
        .width('100%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(8)
      } else {
        List({ space: 10 }) {
          ForEach(this.alerts, (item: Alert) => {
            ListItem() {
              Column({ space: 10 }) {
                Row() {
                  Text(item.typeName)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(item.type === 'SOS' ? '#D92D20' : '#172033')
                  Blank()
                  Text(this.priorityText(item.priority))
                    .fontSize(12)
                    .fontColor(item.priority === 'HIGH' ? '#D92D20' : '#E69100')
                    .padding({ left: 9, right: 9, top: 4, bottom: 4 })
                    .backgroundColor(item.priority === 'HIGH' ? '#FFF1F0' : '#FFF7E6')
                    .borderRadius(8)
                }
                .width('100%')

                Row() {
                  Text(item.elderlyName)
                    .fontSize(14)
                    .fontColor('#344054')
                  Text(item.communityName)
                    .fontSize(14)
                    .fontColor('#667085')
                    .margin({ left: 12 })
                }

                Row() {
                  Text(item.statusName)
                    .fontSize(13)
                    .fontColor(this.statusColor(item.status))
                    .padding({ left: 9, right: 9, top: 4, bottom: 4 })
                    .backgroundColor('#F7F9FC')
                    .borderRadius(8)
                  if (item.type === 'SOS') {
                    Text(this.latestSosAlertId === item.id ? '家属未读' : '家属已读')
                      .fontSize(13)
                      .fontColor(this.latestSosAlertId === item.id ? '#D92D20' : '#12B76A')
                      .padding({ left: 9, right: 9, top: 4, bottom: 4 })
                      .backgroundColor(this.latestSosAlertId === item.id ? '#FFF1F0' : '#ECFDF3')
                      .borderRadius(8)
                      .margin({ left: 8 })
                  }
                  Blank()
                  Text(item.source || '-')
                    .fontSize(13)
                    .fontColor('#667085')
                }
                .width('100%')

                Text(item.happenedAt)
                  .fontSize(13)
                  .fontColor('#98A2B3')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(item.type === 'SOS' ? '#FFF8F7' : Color.White)
              .borderRadius(8)
              .border({ width: item.type === 'SOS' ? 1 : 0, color: '#F97066' })
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
    .backgroundColor('#F5F7FB')
  }
}
