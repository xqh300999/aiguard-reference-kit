import { Device } from './Device';

export interface Elderly {
  id: number;
  name: string;
  age: number;
  gender: string;
  communityName: string;
  address: string;
  phone?: string;
  emergencyContact?: string;
  healthNotes?: string;
  communityId?: number;
  status: string;
  healthStatus: string;
  todayStatus: string;
  recentAlertCount?: number;
  device: Device;
}
