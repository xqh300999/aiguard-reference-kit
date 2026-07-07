export interface Result<T> {
  code: number;
  message: string;
  data: T | null;
  ts: string;
}
