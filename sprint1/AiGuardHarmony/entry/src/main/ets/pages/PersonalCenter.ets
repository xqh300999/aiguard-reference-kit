import { router } from '@kit.ArkUI';
import { StorageKeys } from '../common/StorageKeys';

@Entry
@Component
struct PersonalCenter {
  @StorageLink('realName') realName: string = '';
  @StorageLink('role') role: string = '';
  @StorageLink('userId') userId: number = 0;
  @StorageLink('elderlyName') elderlyName: string = '';
  @StorageLink('communityName') communityName: string = '';

  private logout(): void {
    AppStorage.setOrCreate<string>(StorageKeys.TOKEN, '');
    AppStorage.setOrCreate<number>(StorageKeys.USER_ID, 0);
    AppStorage.setOrCreate<string>(StorageKeys.ROLE, '');
    AppStorage.setOrCreate<string>(StorageKeys.REAL_NAME, '');
    AppStorage.setOrCreate<number>(StorageKeys.ELDERLY_ID, 0);
    AppStorage.setOrCreate<string>(StorageKeys.ELDERLY_NAME, '');
    AppStorage.setOrCreate<number>(StorageKeys.COMMUNITY_ID, 0);
    AppStorage.setOrCreate<string>(StorageKeys.COMMUNITY_NAME, '');
    AppStorage.setOrCreate<number>(StorageKeys.LATEST_SOS_ALERT_ID, 0);
    AppStorage.setOrCreate<number>(StorageKeys.UNREAD_ALERT_COUNT, 0);
    AppStorage.setOrCreate<boolean>(StorageKeys.HAS_NEW_SOS_ALERT, false);
    router.replaceUrl({ url: 'pages/Login' });
  }

  build() {
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
        Text('个人中心')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#172033')
          .margin({ left: 12 })
      }
      .width('100%')

      Column({ space: 8 }) {
        Text(this.realName || '家人用户')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor('#172033')
        Text('AiGuard 家人端账号')
          .fontSize(14)
          .fontColor('#667085')
        Text(this.role || '-')
          .fontSize(13)
          .fontColor('#246BFD')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#EEF4FF')
          .borderRadius(8)
          .margin({ top: 4 })
      }
      .width('100%')
      .padding(18)
      .backgroundColor(Color.White)
      .borderRadius(8)

      Column({ space: 12 }) {
        Text('账号信息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#172033')
        Text(`用户 ID：${this.userId}`)
          .fontSize(15)
          .fontColor('#344054')
        Text(`绑定老人：${this.elderlyName || '-'}`)
          .fontSize(15)
          .fontColor('#344054')
        Text(`所属社区：${this.communityName || '-'}`)
          .fontSize(15)
          .fontColor('#344054')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(8)

      Column({ space: 8 }) {
        Text('说明')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#172033')
        Text('家人端只负责接收通知、查看老人档案与告警状态，不进行派单或告警处理。')
          .fontSize(14)
          .fontColor('#667085')
          .lineHeight(22)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(8)

      Button('绑定老人')
        .width('100%')
        .height(48)
        .backgroundColor('#246BFD')
        .borderRadius(8)
        .onClick(() => {
          router.pushUrl({ url: 'pages/BindElderly' });
        })

      Button('注册老人档案')
        .width('100%')
        .height(48)
        .backgroundColor('#EEF4FF')
        .fontColor('#246BFD')
        .borderRadius(8)
        .onClick(() => {
          router.pushUrl({ url: 'pages/ElderlyEdit', params: { mode: 'create' } });
        })

      Blank()

      Button('退出登录')
        .width('100%')
        .height(52)
        .fontSize(16)
        .backgroundColor('#D92D20')
        .borderRadius(8)
        .onClick(() => {
          this.logout();
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F5F7FB')
  }
}
