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
    AppStorage.setOrCreate<number>(StorageKeys.ELDERLY_ID, user.elderlyId);
    AppStorage.setOrCreate<string>(StorageKeys.ELDERLY_NAME, user.elderlyName);
    AppStorage.setOrCreate<number>(StorageKeys.COMMUNITY_ID, user.communityId);
    AppStorage.setOrCreate<string>(StorageKeys.COMMUNITY_NAME, user.communityName);
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
      this.errorMessage = '当前 App 仅支持子女端账号登录';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    this.saveLoginState(result.data);
    promptAction.showToast({ message: '登录成功' });
    router.replaceUrl({ url: 'pages/FamilyHome' });
  }

  build() {
    Column({ space: 18 }) {
      Text('AiGuard 智慧养老管理系统')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      Text('子女端')
        .fontSize(18)
        .fontColor(Color.Gray)

      TextInput({ placeholder: '账号', text: this.username })
        .height(48)
        .onChange((value: string) => {
          this.username = value;
        })

      TextInput({ placeholder: '密码', text: this.password })
        .type(InputType.Password)
        .height(48)
        .onChange((value: string) => {
          this.password = value;
        })

      if (this.errorMessage.length > 0) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor(Color.Red)
      }

      Button(this.loading ? '登录中...' : '登录')
        .width('100%')
        .height(46)
        .enabled(!this.loading)
        .onClick(() => {
          this.handleLogin();
        })

      Text('当前为子女端 Mock 版本，不连接数据库，不依赖真实后端。')
        .fontSize(12)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
  }
}
