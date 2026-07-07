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
    Column({ space: 16 }) {
      Row() {
        Button('返回')
          .height(36)
          .onClick(() => {
            router.back();
          })
        Text('个人中心')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
      }
      .width('100%')

      Column({ space: 10 }) {
        Text(`子女账号：${this.realName || '-'}`)
          .fontSize(18)
        Text(`角色：${this.role || '-'}`)
          .fontSize(16)
        Text(`用户 ID：${this.userId}`)
          .fontSize(16)
        Text(`绑定老人：${this.elderlyName || '-'}`)
          .fontSize(16)
        Text(`所属社区：${this.communityName || '-'}`)
          .fontSize(16)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F7F8FA')
      .borderRadius(8)

      Button('退出登录')
        .width('100%')
        .height(44)
        .backgroundColor(Color.Red)
        .onClick(() => {
          this.logout();
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
