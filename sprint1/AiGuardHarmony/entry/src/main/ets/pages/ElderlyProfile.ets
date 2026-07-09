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

  private genderText(gender: string): string {
    if (gender === 'MALE') {
      return '男';
    }
    if (gender === 'FEMALE') {
      return '女';
    }
    return gender || '-';
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
          Text('老人档案')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
            .margin({ left: 12 })
        }
        .width('100%')

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#D92D20')
            .padding(12)
            .width('100%')
            .backgroundColor('#FFF1F0')
            .borderRadius(8)
        }

        if (this.hasData) {
          Column({ space: 8 }) {
            Text(this.profile.name)
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#172033')
            Text(`${this.profile.age} 岁 · ${this.genderText(this.profile.gender)} · ${this.profile.communityName}`)
              .fontSize(15)
              .fontColor('#667085')
            Text(this.profile.todayStatus)
              .fontSize(14)
              .fontColor('#12B76A')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor('#ECFDF3')
              .borderRadius(8)
              .margin({ top: 6 })
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Color.White)
          .borderRadius(8)

          Button('修改老人档案')
            .width('100%')
            .height(48)
            .backgroundColor('#246BFD')
            .borderRadius(8)
            .onClick(() => {
              router.pushUrl({ url: 'pages/ElderlyEdit', params: { mode: 'edit' } });
            })

          Column({ space: 12 }) {
            Text('基本信息')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#172033')
            Text(`住址：${this.profile.address}`)
              .fontSize(15)
              .fontColor('#344054')
            Text(`联系电话：${this.profile.phone || '-'}`)
              .fontSize(15)
              .fontColor('#344054')
            Text(`紧急联系人：${this.profile.emergencyContact || '-'}`)
              .fontSize(15)
              .fontColor('#344054')
            Text(`档案状态：${this.profile.status}`)
              .fontSize(15)
              .fontColor('#344054')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)

          Column({ space: 10 }) {
            Text('健康备注')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#172033')
            Text(this.profile.healthNotes || '-')
              .fontSize(15)
              .fontColor('#344054')
              .lineHeight(22)
            Text(`健康状态：${this.profile.healthStatus}`)
              .fontSize(15)
              .fontColor('#12B76A')
            Text(`最近告警：${this.profile.recentAlertCount ?? 0} 条`)
              .fontSize(15)
              .fontColor('#D92D20')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)

          Column({ space: 12 }) {
            Row() {
              Text('绑定设备')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#172033')
              Blank()
              Text((this.profile.device?.status ?? '') === 'ONLINE' ? '在线' : '离线')
                .fontSize(13)
                .fontColor((this.profile.device?.status ?? '') === 'ONLINE' ? '#12B76A' : '#D92D20')
                .padding({ left: 9, right: 9, top: 4, bottom: 4 })
                .backgroundColor((this.profile.device?.status ?? '') === 'ONLINE' ? '#ECFDF3' : '#FFF1F0')
                .borderRadius(8)
            }
            .width('100%')

            Text(this.profile.device?.name || '未绑定设备')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#172033')
            Text(`设备类型：${this.profile.device?.type || '-'}`)
              .fontSize(15)
              .fontColor('#344054')
            Text(`电量：${this.profile.device?.battery ?? 0}%`)
              .fontSize(15)
              .fontColor('#344054')
            Text(`最近心跳：${this.profile.device?.lastHeartbeat || '-'}`)
              .fontSize(14)
              .fontColor('#667085')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
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
