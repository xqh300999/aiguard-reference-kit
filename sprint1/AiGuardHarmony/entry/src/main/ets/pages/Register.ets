import { promptAction, router } from '@kit.ArkUI';
import { RegisterFamilyRequest, UserAccount } from '../models/User';
import { ApiService } from '../services/ApiService';

@Entry
@Component
struct Register {
  @State username: string = '';
  @State password: string = '';
  @State realName: string = '';
  @State phone: string = '';
  @State communityIdText: string = '1';
  @State loading: boolean = false;
  @State errorMessage: string = '';

  private async submitRegister(): Promise<void> {
    if (this.username.trim().length === 0 || this.password.length === 0 || this.realName.trim().length === 0) {
      this.errorMessage = '请填写账号、密码和真实姓名';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    let communityId = Number(this.communityIdText);
    if (communityId <= 0 || isNaN(communityId)) {
      this.errorMessage = '请填写正确的社区 ID';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    let request: RegisterFamilyRequest = {
      username: this.username.trim(),
      password: this.password,
      realName: this.realName.trim(),
      phone: this.phone.trim(),
      role: 'FAMILY',
      communityId: communityId
    };

    this.loading = true;
    this.errorMessage = '';
    let result = await ApiService.registerFamily(request);
    this.loading = false;

    if (!ApiService.isSuccess<UserAccount>(result) || result.data === null) {
      this.errorMessage = result.message || '注册失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    promptAction.showToast({ message: '注册成功，请登录后绑定老人' });
    router.replaceUrl({
      url: 'pages/Login',
      params: {
        username: this.username.trim()
      }
    });
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
          Text('家属注册')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
            .margin({ left: 12 })
        }
        .width('100%')

        Text('移动端仅支持注册 FAMILY 家属账号')
          .fontSize(14)
          .fontColor('#667085')
          .width('100%')
          .padding(12)
          .backgroundColor('#EEF4FF')
          .borderRadius(8)

        TextInput({ placeholder: '账号', text: this.username })
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.username = value;
          })
        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password)
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.password = value;
          })
        TextInput({ placeholder: '真实姓名', text: this.realName })
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.realName = value;
          })
        TextInput({ placeholder: '手机号，可选', text: this.phone })
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.phone = value;
          })
        TextInput({ placeholder: '社区 ID', text: this.communityIdText })
          .type(InputType.Number)
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.communityIdText = value;
          })

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#D92D20')
            .width('100%')
            .padding(10)
            .backgroundColor('#FFF1F0')
            .borderRadius(8)
        }

        Button(this.loading ? '注册中...' : '注册')
          .width('100%')
          .height(52)
          .backgroundColor('#246BFD')
          .borderRadius(8)
          .enabled(!this.loading)
          .onClick(() => {
            this.submitRegister();
          })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
  }
}
