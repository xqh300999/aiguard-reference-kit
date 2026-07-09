import { promptAction, router } from '@kit.ArkUI';
import { StorageKeys } from '../common/StorageKeys';
import { Elderly, ElderlyForm } from '../models/Elderly';
import { ApiService } from '../services/ApiService';

interface ElderlyEditParams {
  mode?: string;
}

@Entry
@Component
struct ElderlyEdit {
  @StorageLink('elderlyId') elderlyId: number = 0;
  @StorageLink('communityId') communityId: number = 0;
  @State mode: string = 'edit';
  @State name: string = '';
  @State ageText: string = '';
  @State gender: string = 'MALE';
  @State address: string = '';
  @State phone: string = '';
  @State emergencyContact: string = '';
  @State healthNotes: string = '';
  @State communityIdText: string = '';
  @State loading: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    let params = router.getParams() as ElderlyEditParams;
    this.mode = params === undefined ? (this.elderlyId > 0 ? 'edit' : 'create') : (params.mode ?? (this.elderlyId > 0 ? 'edit' : 'create'));
    this.communityIdText = this.communityId > 0 ? this.communityId.toString() : '1';
    if (this.mode !== 'create' && this.elderlyId > 0) {
      this.loadProfile();
    }
  }

  private async loadProfile(): Promise<void> {
    this.loading = true;
    let result = await ApiService.getElderlyStatus(this.elderlyId);
    this.loading = false;

    if (!ApiService.isSuccess<Elderly>(result) || result.data === null) {
      this.errorMessage = result.message || '老人档案加载失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    let profile = result.data;
    this.name = profile.name;
    this.ageText = profile.age > 0 ? profile.age.toString() : '';
    this.gender = profile.gender || 'MALE';
    this.address = profile.address || '';
    this.phone = profile.phone || '';
    this.emergencyContact = profile.emergencyContact || '';
    this.healthNotes = profile.healthNotes || '';
    this.communityIdText = (profile.communityId ?? this.communityId).toString();
  }

  private buildForm(): ElderlyForm | null {
    if (this.name.trim().length === 0) {
      this.errorMessage = '请填写老人姓名';
      return null;
    }
    let communityId = Number(this.communityIdText);
    if (communityId <= 0 || isNaN(communityId)) {
      this.errorMessage = '请填写正确的社区 ID';
      return null;
    }

    let age = Number(this.ageText);
    let form: ElderlyForm = {
      name: this.name.trim(),
      age: this.ageText.length > 0 && !isNaN(age) ? age : undefined,
      gender: this.gender,
      address: this.address.trim(),
      phone: this.phone.trim(),
      emergencyContact: this.emergencyContact.trim(),
      healthNotes: this.healthNotes.trim(),
      communityId: communityId
    };
    if (this.mode !== 'create' && this.elderlyId > 0) {
      form.id = this.elderlyId;
    }
    return form;
  }

  private async saveProfile(): Promise<void> {
    let form = this.buildForm();
    if (form === null) {
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    this.loading = true;
    this.errorMessage = '';

    if (this.mode === 'create') {
      let result = await ApiService.registerElderly(form);
      this.loading = false;
      if (!ApiService.isSuccess<Elderly>(result) || result.data === null) {
        this.errorMessage = result.message || '注册老人失败';
        promptAction.showToast({ message: this.errorMessage });
        return;
      }
      AppStorage.setOrCreate<number>(StorageKeys.COMMUNITY_ID, result.data.communityId ?? Number(this.communityIdText));
      promptAction.showToast({ message: '老人档案已创建，请返回绑定老人' });
      router.replaceUrl({ url: 'pages/BindElderly' });
      return;
    }

    let updateResult = await ApiService.updateElderly(form);
    this.loading = false;
    if (!ApiService.isSuccess<null>(updateResult)) {
      this.errorMessage = updateResult.message || '保存失败';
      promptAction.showToast({ message: this.errorMessage });
      return;
    }

    promptAction.showToast({ message: '老人档案已保存' });
    router.back();
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
          Text(this.mode === 'create' ? '注册老人档案' : '修改老人档案')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#172033')
            .margin({ left: 12 })
        }
        .width('100%')

        TextInput({ placeholder: '老人姓名', text: this.name })
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.name = value;
          })
        TextInput({ placeholder: '年龄', text: this.ageText })
          .type(InputType.Number)
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.ageText = value;
          })

        Row({ space: 10 }) {
          Button('男')
            .layoutWeight(1)
            .height(46)
            .backgroundColor(this.gender === 'MALE' ? '#246BFD' : '#EEF4FF')
            .fontColor(this.gender === 'MALE' ? Color.White : '#246BFD')
            .borderRadius(8)
            .onClick(() => {
              this.gender = 'MALE';
            })
          Button('女')
            .layoutWeight(1)
            .height(46)
            .backgroundColor(this.gender === 'FEMALE' ? '#246BFD' : '#EEF4FF')
            .fontColor(this.gender === 'FEMALE' ? Color.White : '#246BFD')
            .borderRadius(8)
            .onClick(() => {
              this.gender = 'FEMALE';
            })
        }
        .width('100%')

        TextInput({ placeholder: '电话，用于绑定', text: this.phone })
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.phone = value;
          })
        TextInput({ placeholder: '详细住址', text: this.address })
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.address = value;
          })
        TextInput({ placeholder: '紧急联系人', text: this.emergencyContact })
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.emergencyContact = value;
          })
        TextInput({ placeholder: '健康备注', text: this.healthNotes })
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onChange((value: string) => {
            this.healthNotes = value;
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

        Button(this.loading ? '保存中...' : '保存')
          .width('100%')
          .height(52)
          .backgroundColor('#246BFD')
          .borderRadius(8)
          .enabled(!this.loading)
          .onClick(() => {
            this.saveProfile();
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
