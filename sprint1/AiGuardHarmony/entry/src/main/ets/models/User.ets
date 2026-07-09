export interface User {
  token: string;
  userId: number;
  role: string;
  realName: string;
  elderlyId?: number | null;
  elderlyName?: string;
  communityId?: number;
  communityName?: string;
}

export interface UserAccount {
  id: number;
  username: string;
  realName: string;
  phone?: string;
  role: string;
  communityId?: number | null;
  elderlyId?: number | null;
  status?: string;
}

export interface RegisterFamilyRequest {
  username: string;
  password: string;
  realName: string;
  phone?: string;
  role: string;
  communityId: number;
}

export interface BindByContactRequest {
  name: string;
  phone: string;
}
