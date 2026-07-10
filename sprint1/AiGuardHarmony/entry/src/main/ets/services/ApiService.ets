import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../common/Constants';
import { Alert, AlertPage } from '../models/Alert';
import { Elderly, ElderlyForm, ElderlySearchItem } from '../models/Elderly';
import { Result } from '../models/Result';
import { BindByContactRequest, RegisterFamilyRequest, User, UserAccount } from '../models/User';
import { FamilyHomeData, MockService, UnreadCountData } from './MockService';

type RequestData = string | number | boolean | object | null;

interface RequestHeader {
  'Content-Type': string;
  Authorization?: string;
}

interface LoginRequest {
  username: string;
  password: string;
}

export class ApiService {
  private static readonly SUCCESS_CODE: number = 0;
  private static readonly PATCH_METHOD: http.RequestMethod = 'PATCH' as http.RequestMethod;

  // 后端完成后：
  // 1. Constants.USE_MOCK 改为 false。
  // 2. Constants.API_BASE_URL 改为后端地址，例如 http://192.168.1.100:8080。
  // 3. 本文件只使用接口文档中已有接口：
  //    POST /api/v1/auth/login
  //    GET  /api/v1/elderly/{id}
  //    GET  /api/v1/elderly/{id}/alerts?page=1&size=20
  //    GET  /api/v1/alerts/{id}
  //    GET  /api/v1/notifications/unread-count?userId={userId}
  //    PATCH /api/v1/notifications/{id}/read
  //    POST /api/v1/auth/register
  //    PUT  /api/v1/users/{userId}/bind-by-contact
  //    POST /api/v1/elderly/register
  //    GET  /api/v1/elderly/search?keyword=王
  //    PUT  /api/v1/elderly
  //    PUT  /api/v1/elderly/update-by-contact
  // 4. SOS 实时接收后续替换为：WS /ws/alerts?token=<JWT_TOKEN>。

  static isSuccess<T>(result: Result<T>): boolean {
    return result.code === ApiService.SUCCESS_CODE;
  }

  static login(username: string, password: string): Promise<Result<User>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockLogin(username, password));
    }
    let body: LoginRequest = {
      username: username,
      password: password
    };
    return ApiService.post<User>('/api/v1/auth/login', body, false);
  }

  static registerFamily(request: RegisterFamilyRequest): Promise<Result<UserAccount>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockRegisterFamily(request));
    }
    return ApiService.post<UserAccount>('/api/v1/auth/register', request, false);
  }

  static bindElderlyByContact(userId: number, name: string, phone: string): Promise<Result<UserAccount>> {
    let body: BindByContactRequest = {
      name: name,
      phone: phone
    };
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockBindElderlyByContact(userId, body));
    }
    return ApiService.put<UserAccount>(`/api/v1/users/${userId}/bind-by-contact`, body, true);
  }

  static async getFamilyHome(elderlyId: number, userId: number): Promise<Result<FamilyHomeData>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockGetFamilyHome());
    }

    // 接口文档没有单独的家人端首页接口，真实模式下由老人详情 + 告警历史 + 未读数聚合。
    let elderlyResult = await ApiService.get<Elderly>(`/api/v1/elderly/${elderlyId}`, true);
    if (!ApiService.isSuccess<Elderly>(elderlyResult) || elderlyResult.data === null) {
      return ApiService.buildErrorResult<FamilyHomeData>(elderlyResult.code, elderlyResult.message);
    }

    let alertResult = await ApiService.getElderlyAlertList(elderlyId, 1, 20);
    let latestAlert = MockService.emptyAlert();
    if (ApiService.isSuccess<AlertPage>(alertResult) && alertResult.data !== null && alertResult.data.records.length > 0) {
      latestAlert = alertResult.data.records[0];
    }

    let unreadResult = await ApiService.getUnreadAlertCount(userId);
    let unreadCount = 0;
    if (ApiService.isSuccess<UnreadCountData>(unreadResult) && unreadResult.data !== null) {
      unreadCount = unreadResult.data.unreadCount;
    }

    return {
      code: 0,
      message: 'success',
      data: {
        elderly: elderlyResult.data,
        device: elderlyResult.data.device ?? MockService.emptyDevice(),
        latestAlert: latestAlert,
        unreadCount: unreadCount
      },
      ts: 0
    };
  }

  static getElderlyAlertList(elderlyId: number, page: number = 1, pageSize: number = 20): Promise<Result<AlertPage>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockGetAlertList());
    }
    return ApiService.get<AlertPage>(`/api/v1/elderly/${elderlyId}/alerts?page=${page}&size=${pageSize}`, true);
  }

  static getAlertDetail(alertId: number): Promise<Result<Alert>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockGetAlertDetail(alertId));
    }
    return ApiService.get<Alert>(`/api/v1/alerts/${alertId}`, true);
  }

  static getElderlyStatus(elderlyId: number): Promise<Result<Elderly>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockGetElderlyStatus());
    }
    return ApiService.get<Elderly>(`/api/v1/elderly/${elderlyId}`, true);
  }

  static registerElderly(request: ElderlyForm): Promise<Result<Elderly>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockRegisterElderly(request));
    }
    return ApiService.post<Elderly>('/api/v1/elderly/register', request, true);
  }

  static updateElderly(request: ElderlyForm): Promise<Result<null>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockUpdateElderly(request));
    }
    return ApiService.put<null>('/api/v1/elderly', request, true);
  }

  static updateElderlyByContact(request: ElderlyForm): Promise<Result<Elderly>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockUpdateElderlyByContact(request));
    }
    return ApiService.put<Elderly>('/api/v1/elderly/update-by-contact', request, true);
  }

  static searchElderly(keyword: string): Promise<Result<ElderlySearchItem[]>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockSearchElderly(keyword));
    }
    return ApiService.get<ElderlySearchItem[]>(`/api/v1/elderly/search?keyword=${encodeURIComponent(keyword)}`, true);
  }

  static getUnreadAlertCount(userId: number): Promise<Result<UnreadCountData>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockGetUnreadCount());
    }
    return ApiService.get<UnreadCountData>(`/api/v1/notifications/unread-count?userId=${userId}`, true);
  }

  static markNotificationRead(notificationId: number): Promise<Result<UnreadCountData>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockMarkNotificationRead(notificationId));
    }
    return ApiService.patch<UnreadCountData>(`/api/v1/notifications/${notificationId}/read`, null, true);
  }

  static get<T>(path: string, needAuth: boolean = true): Promise<Result<T>> {
    return ApiService.request<T>(http.RequestMethod.GET, path, null, needAuth);
  }

  static post<T>(path: string, data: RequestData, needAuth: boolean = true): Promise<Result<T>> {
    return ApiService.request<T>(http.RequestMethod.POST, path, data, needAuth);
  }

  static put<T>(path: string, data: RequestData, needAuth: boolean = true): Promise<Result<T>> {
    return ApiService.request<T>(http.RequestMethod.PUT, path, data, needAuth);
  }

  static patch<T>(path: string, data: RequestData, needAuth: boolean = true): Promise<Result<T>> {
    // 部分 HarmonyOS SDK 没有 http.RequestMethod.PATCH 枚举，接口文档又要求 PATCH，
    // 因此这里使用字符串兼容写法，页面仍统一调用 ApiService。
    return ApiService.request<T>(ApiService.PATCH_METHOD, path, data, needAuth);
  }

  static delete<T>(path: string, needAuth: boolean = true): Promise<Result<T>> {
    return ApiService.request<T>(http.RequestMethod.DELETE, path, null, needAuth);
  }

  private static getBaseUrl(): string {
    let baseUrl = Constants.API_BASE_URL;
    return baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
  }

  private static appendAuthHeader(header: RequestHeader): void {
    let token = AppStorage.get<string>('token') ?? '';
    if (token.length > 0) {
      header.Authorization = `Bearer ${token}`;
    }
  }

  private static buildUrl(path: string): string {
    let baseUrl = ApiService.getBaseUrl();
    if (baseUrl.length === 0) {
      throw new Error('请先配置后端服务地址');
    }
    return `${baseUrl}${path}`;
  }

  private static parseResult<T>(response: http.HttpResponse): Result<T> {
    let rawResult = response.result;
    let text = typeof rawResult === 'string' ? rawResult : JSON.stringify(rawResult);
    return JSON.parse(text) as Result<T>;
  }

  private static buildErrorResult<T>(code: number, message: string): Result<T> {
    return {
      code: code,
      message: message,
      data: null,
      ts: 0
    };
  }

  private static async request<T>(
    method: http.RequestMethod,
    path: string,
    data: RequestData = null,
    needAuth: boolean = true
  ): Promise<Result<T>> {
    let httpRequest = http.createHttp();
    let headers: RequestHeader = {
      'Content-Type': 'application/json'
    };

    if (needAuth) {
      ApiService.appendAuthHeader(headers);
    }

    try {
      let options: http.HttpRequestOptions = {
        method: method,
        header: headers,
        extraData: data === null ? undefined : JSON.stringify(data),
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 10000,
        readTimeout: 10000
      };
      let response = await httpRequest.request(ApiService.buildUrl(path), options);
      return ApiService.parseResult<T>(response);
    } catch (error) {
      let businessError = error as BusinessError;
      return ApiService.buildErrorResult<T>(businessError.code || -1, businessError.message || '网络请求失败');
    } finally {
      httpRequest.destroy();
    }
  }
}