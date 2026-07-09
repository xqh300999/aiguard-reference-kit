import { promptAction, router } from '@kit.ArkUI';
import { StorageKeys } from '../common/StorageKeys';
import { ElderlySearchItem } from '../models/Elderly';
import { UserAccount } from '../models/User';
import { ApiService } from '../services/ApiService';

@Entry
@Component
struct BindElderly {
  @StorageLink('userId') userId: number = 0;
  @StorageLink('communityId') communityId: number = 0;
  @State name: string = '';
  @State phone: string = '';
  @State keyword: string = '';
  @State searchList: ElderlySearchItem[] = [];
  @State loading: boolean = false;
  @State errorMessage: string = '';

  private saveBindState(account: UserAccount): void {
    AppStorage.setOrCreate<number>(StorageKeys.ELDERLY_ID, account.elderlyId ?? 0);
    AppStorage.setOrCreate<number>(StorageKeys.COMMUNITY_ID, account.communityId ?? this.communityId);
    AppStorage.setOrCreate<string>(StorageKeys.ELDERLY_NAME, this.name.trim());
  }

  private async bindByContact(): Promise<void> {
    if (this.userId <= 0) {
      this.errorMessage = '缺少用户 ID，请重新登录';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }
    if (this.name.trim().length === 0 || this.phone.trim().length === 0) {
      this.errorMessage = '请填写老人姓名和电话';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    this.loading = true;
    this.errorMessage = '';
    let result = await ApiService.bindElderlyByContact(this.userId, this.name.trim(), this.phone.trim());
    this.loading = false;

    if (!ApiService.isSuccess<UserAccount>(result) || result.data === null) {
      this.errorMessage = result.message || '绑定失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    this.saveBindState(result.data);
    promptAction.showToast({ message: '绑定成功' });
    router.replaceUrl({ url: 'pages/FamilyHome' });
  }

  private async searchElderly(): Promise<void> {
    if (this.keyword.trim().length === 0) {
      this.errorMessage = '请输入老人姓名关键词';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    this.loading = true;
    this.errorMessage = '';
    let result = await ApiService.searchElderly(this.keyword.trim());
    this.loading = false;

    if (!ApiService.isSuccess<ElderlySearchItem[]>(result) || result.data === null) {
      this.errorMessage = result.message || '搜索失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }
    this.searchList = result.data;
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('绑定老人')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#172033')
          .width('100%')

        Text('请输入老人姓名和电话，系统会按联系方式匹配并绑定。')
          .fontSize(14)
          .fontColor('#667085')
          .lineHeight(20)
          .width('100%')
          .padding(12)
          .backgroundColor('#EEF4FF')
          .borderRadius(8)

        TextInput({ placeholder: '老人姓名', text: this.name })
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.name = value;
          })
        TextInput({ placeholder: '老人电话', text: this.phone })
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.phone = value;
          })

        Button(this.loading ? '绑定中...' : '绑定老人')
          .width('100%')
          .height(50)
          .backgroundColor('#246BFD')
          .borderRadius(8)
          .enabled(!this.loading)
          .onClick(() => {
            this.bindByContact();
          })

        Button('还没有老人档案，先注册老人')
          .width('100%')
          .height(48)
          .backgroundColor('#172033')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/ElderlyEdit', params: { mode: 'create' } });
          })

        Column({ space: 10 }) {
          Text('搜索老人')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
            .width('100%')
          Row({ space: 8 }) {
            TextInput({ placeholder: '输入姓名关键词', text: this.keyword })
              .layoutWeight(1)
              .height(46)
              .backgroundColor('#F7F9FC')
              .borderRadius(8)
              .onChange((value: string) => {
                this.keyword = value;
              })
            Button('搜索')
              .height(46)
              .backgroundColor('#EEF4FF')
              .fontColor('#246BFD')
              .borderRadius(8)
              .onClick(() => {
                this.searchElderly();
              })
          }
          .width('100%')

          ForEach(this.searchList, (item: ElderlySearchItem) => {
            Column({ space: 6 }) {
              Text(`${item.name} · ${item.age ?? '-'}岁`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#172033')
              Text(`电话：${item.phone || '-'}`)
                .fontSize(14)
                .fontColor('#667085')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F7F9FC')
            .borderRadius(8)
            .onClick(() => {
              this.name = item.name;
              this.phone = item.phone || '';
            })
          }, (item: ElderlySearchItem) => item.id.toString())
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Color.White)
        .borderRadius(8)

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#D92D20')
            .width('100%')
            .padding(10)
            .backgroundColor('#FFF1F0')
            .borderRadius(8)
        }

        Button('退出登录')
          .width('100%')
          .height(48)
          .backgroundColor('#FFF1F0')
          .fontColor('#D92D20')
          .borderRadius(8)
          .onClick(() => {
            AppStorage.setOrCreate<string>(StorageKeys.TOKEN, '');
            router.replaceUrl({ url: 'pages/Login' });
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
