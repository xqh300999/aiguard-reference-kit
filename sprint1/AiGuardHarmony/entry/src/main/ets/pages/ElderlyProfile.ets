import { promptAction, router } from '@kit.ArkUI';
import { Elderly } from '../models/Elderly';
import { ApiService } from '../services/ApiService';

const EMPTY_PROFILE: Elderly = {
  id: 0,
  name: '',
  age: 0,
  gender: '',
  communityName: '',
  address: '',
  status: '',
  healthStatus: '',
  todayStatus: '',
  device: {
    id: 0,
    name: '',
    type: '',
    status: ''
  }
};

@Entry
@Component
struct ElderlyProfile {
  @StorageLink('elderlyId') elderlyId: number = 0;
  @State profile: Elderly = EMPTY_PROFILE;
  @State hasData: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    this.loadProfile();
  }

  private async loadProfile(): Promise<void> {
    let result = await ApiService.getElderlyStatus(this.elderlyId);
    if (!ApiService.isSuccess<Elderly>(result) || result.data === null) {
      this.errorMessage = result.message || '老人档案加载失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }
    this.profile = result.data;
    this.hasData = true;
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
          Text('老人档案')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })
        }
        .width('100%')

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor(Color.Red)
        }

        if (this.hasData) {
          Column({ space: 10 }) {
            Text('基本信息')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Text(`姓名：${this.profile.name}`)
            Text(`年龄：${this.profile.age}`)
            Text(`性别：${this.profile.gender}`)
            Text(`所属社区：${this.profile.communityName}`)
            Text(`地址：${this.profile.address}`)
            Text(`健康状态：${this.profile.healthStatus}`)
            Text(`今日状态：${this.profile.todayStatus}`)
            Text(`最近告警数量：${this.profile.recentAlertCount ?? 0}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F7F8FA')
          .borderRadius(8)

          Column({ space: 10 }) {
            Text('设备信息')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Text(`设备名称：${this.profile.device.name}`)
            Text(`设备类型：${this.profile.device.type}`)
            Text(`在线状态：${this.profile.device.status}`)
            Text(`电量：${this.profile.device.battery ?? 0}%`)
            Text(`最近心跳：${this.profile.device.lastHeartbeat || '-'}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F7F8FA')
          .borderRadius(8)
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}
