import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../common/Constants';
import { Alert, AlertPage } from '../models/Alert';
import { Elderly } from '../models/Elderly';
import { Result } from '../models/Result';
import { User } from '../models/User';
import { FamilyHomeData, MockService } from './MockService';

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

  // 后端完成后：USE_MOCK=false，并填写 Constants.API_BASE_URL。
  // 登录：POST /api/v1/auth/login
  // 老人详情：GET /api/v1/elderly/{id}
  // 老人告警历史：GET /api/v1/elderly/{id}/alerts?page=1&size=20
  // 告警详情：GET /api/v1/alerts/{id}
  // SOS 实时接收：WS /ws/alerts?token=<JWT_TOKEN>；WebSocket 未完成时可轮询：
  // GET /api/v1/alerts?type=SOS&status=PENDING&page=1&size=20

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

  static async getFamilyHome(elderlyId: number): Promise<Result<FamilyHomeData>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockGetFamilyHome());
    }

    // 接口文档没有“家人首页聚合接口”，真实模式下用已存在接口组合：
    // 老人详情：GET /api/v1/elderly/{id}
    // 告警列表：GET /api/v1/alerts?page=1&size=20
    let elderlyResult = await ApiService.get<Elderly>(`/api/v1/elderly/${elderlyId}`, true);
    if (!ApiService.isSuccess<Elderly>(elderlyResult) || elderlyResult.data === null) {
      return ApiService.buildErrorResult<FamilyHomeData>(elderlyResult.code, elderlyResult.message);
    }

    let alertResult = await ApiService.getAlertList(1, 20);
    let latestAlert = MockService.emptyAlert();
    let unreadCount = 0;
    if (ApiService.isSuccess<AlertPage>(alertResult) && alertResult.data !== null && alertResult.data.records.length > 0) {
      latestAlert = alertResult.data.records[0];
      unreadCount = alertResult.data.total;
    }

    let data: FamilyHomeData = {
      elderly: elderlyResult.data,
      device: elderlyResult.data.device,
      latestAlert: latestAlert,
      unreadCount: unreadCount
    };
    let result: Result<FamilyHomeData> = {
      code: 0,
      message: 'success',
      data: data,
      ts: ''
    };
    return result;
  }

  static getAlertList(page: number = 1, pageSize: number = 20): Promise<Result<AlertPage>> {
    if (Constants.USE_MOCK) {
      return Promise.resolve(MockService.mockGetAlertList());
    }
    return ApiService.get<AlertPage>(`/api/v1/alerts?page=${page}&size=${pageSize}`, true);
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
    // 部分 HarmonyOS SDK 的 RequestMethod 不提供 PATCH 枚举；后端联调状态流转接口时再按实际 SDK 能力切换。
    return ApiService.request<T>(http.RequestMethod.PUT, path, data, needAuth);
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
    let result: Result<T> = {
      code: code,
      message: message,
      data: null,
      ts: ''
    };
    return result;
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
