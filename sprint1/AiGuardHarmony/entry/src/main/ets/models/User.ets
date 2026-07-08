export interface User {
  token: string;
  userId: number;
  role: string;
  realName: string;
  elderlyId?: number;
  elderlyName?: string;
  communityId?: number;
  communityName?: string;
}
