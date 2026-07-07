export interface Device {
  id: number;
  name: string;
  type: string;
  status: string;
  battery?: number;
  lastHeartbeat?: string;
}
