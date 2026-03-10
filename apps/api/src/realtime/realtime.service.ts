import { Injectable } from '@nestjs/common';
import { RealtimeGateway } from './realtime.gateway';

@Injectable()
export class RealtimeService {
  constructor(private readonly realtimeGateway: RealtimeGateway) {}

  emitStoreEvent<T>(
    storeId: string,
    event: string,
    data: T,
    entity?: {
      type: string;
      id?: string;
    },
  ) {
    this.realtimeGateway.emitStoreEvent({
      event,
      storeId,
      timestamp: new Date().toISOString(),
      entity,
      data,
    });
  }
}
