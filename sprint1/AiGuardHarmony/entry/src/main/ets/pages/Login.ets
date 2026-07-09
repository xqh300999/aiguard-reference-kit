import { promptAction, router } from '@kit.ArkUI';
import { StorageKeys } from '../common/StorageKeys';
import { User } from '../models/User';
import { ApiService } from '../services/ApiService';

@Entry
@Component
struct Login {
  @State username: string = 'family';
  @State password: string = '123456';
  @State loading: boolean = false;
  @State errorMessage: string = '';

  private saveLoginState(user: User): void {
    AppStorage.setOrCreate<string>(StorageKeys.TOKEN, user.token);
    AppStorage.setOrCreate<number>(StorageKeys.USER_ID, user.userId);
    AppStorage.setOrCreate<string>(StorageKeys.ROLE, user.role);
    AppStorage.setOrCreate<string>(StorageKeys.REAL_NAME, user.realName);
    AppStorage.setOrCreate<number>(StorageKeys.ELDERLY_ID, user.elderlyId ?? 0);
    AppStorage.setOrCreate<string>(StorageKeys.ELDERLY_NAME, user.elderlyName ?? '');
    AppStorage.setOrCreate<number>(StorageKeys.COMMUNITY_ID, user.communityId ?? 0);
    AppStorage.setOrCreate<string>(StorageKeys.COMMUNITY_NAME, user.communityName ?? '');
    AppStorage.setOrCreate<number>(StorageKeys.LATEST_SOS_ALERT_ID, 0);
    AppStorage.setOrCreate<number>(StorageKeys.UNREAD_ALERT_COUNT, 0);
    AppStorage.setOrCreate<boolean>(StorageKeys.HAS_NEW_SOS_ALERT, false);
  }

  private async handleLogin(): Promise<void> {
    if (this.username.trim().length === 0 || this.password.length === 0) {
      this.errorMessage = '请输入账号和密码';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    this.loading = true;
    this.errorMessage = '';

    let result = await ApiService.login(this.username.trim(), this.password);
    this.loading = false;

    if (!ApiService.isSuccess<User>(result) || result.data === null) {
      this.errorMessage = result.message || '登录失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    if (result.data.role !== 'FAMILY') {
      this.errorMessage = '当前 App 仅支持家人端账号登录';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    if ((result.data.elderlyId ?? 0) <= 0) {
      this.errorMessage = '登录成功，但缺少绑定老人信息，请后端返回 elderlyId';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    this.saveLoginState(result.data);
    promptAction.showToast({ message: '登录成功' });
    router.replaceUrl({ url: 'pages/FamilyHome' });
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Column({ space: 10 }) {
          Text('AiGuard')
            .fontSize(38)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text('智慧养老管理系统')
            .fontSize(18)
            .fontColor('#DDE7FF')
          Text('家人端')
            .fontSize(15)
            .fontColor('#AFC4F8')
            .margin({ top: 4 })
        }
        .width('100%')
        .height(260)
        .padding({ left: 26, right: 26, top: 72 })
        .alignItems(HorizontalAlign.Start)
        .backgroundColor('#123B7A')

        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FB')

      Column({ space: 18 }) {
        Text('欢迎登录')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#172033')
          .width('100%')

        Text('查看老人状态、设备状态和紧急告警')
          .fontSize(14)
          .fontColor('#667085')
          .width('100%')

        Column({ space: 10 }) {
          Text('账号')
            .fontSize(14)
            .fontColor('#344054')
            .width('100%')
          TextInput({ placeholder: '请输入账号', text: this.username })
            .height(52)
            .fontSize(16)
            .backgroundColor('#F7F9FC')
            .borderRadius(8)
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.username = value;
            })
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('密码')
            .fontSize(14)
            .fontColor('#344054')
            .width('100%')
          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(InputType.Password)
            .height(52)
            .fontSize(16)
            .backgroundColor('#F7F9FC')
            .borderRadius(8)
            .padding({ left: 14, right: 14 })
            .onChange((value: string) => {
              this.password = value;
            })
        }
        .width('100%')

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#D92D20')
            .width('100%')
            .padding(10)
            .backgroundColor('#FFF1F0')
            .borderRadius(8)
        }

        Button(this.loading ? '登录中...' : '登录')
          .width('100%')
          .height(52)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#246BFD')
          .borderRadius(8)
          .enabled(!this.loading)
          .onClick(() => {
            this.handleLogin();
          })

        Text('当前为 Mock 演示模式，不连接数据库。后端完成后在 Constants 中切换真实地址。')
          .fontSize(12)
          .fontColor('#98A2B3')
          .lineHeight(18)
          .width('100%')
      }
      .width('88%')
      .padding(22)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .shadow({ radius: 18, color: '#1A000000', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .height('100%')
  }
}
