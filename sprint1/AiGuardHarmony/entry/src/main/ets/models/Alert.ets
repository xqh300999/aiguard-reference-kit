export interface Alert {
  id: number;
  type: string;
  typeName: string;
  elderlyId: number;
  elderlyName: string;
  communityId: number;
  communityName: string;
  status: string;
  statusName: string;
  priority: string;
  happenedAt: string;
  resolvedAt?: string;
  handlerName?: string;
  cause?: string;
  details?: string;
  lat?: number;
  lng?: number;
  source?: string;
  notificationId?: number;
}

export interface AlertPage {
  records: Alert[];
  total: number;
  page: number;
  size: number;
}
