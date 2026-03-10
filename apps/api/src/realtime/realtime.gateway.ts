import { Logger } from '@nestjs/common';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

export interface StoreEventEnvelope<T = unknown> {
  event: string;
  storeId: string;
  timestamp: string;
  entity?: {
    type: string;
    id?: string;
  };
  data: T;
}

@WebSocketGateway({
  namespace: 'realtime',
  cors: {
    origin: true,
    credentials: true,
  },
})
export class RealtimeGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  private readonly logger = new Logger(RealtimeGateway.name);

  @WebSocketServer()
  server?: Server;

  handleConnection(client: Socket) {
    const storeId = this.extractStoreId(
      client.handshake.auth.storeId,
      client.handshake.query.storeId,
    );

    if (storeId) {
      void client.join(this.getStoreRoom(storeId));
    }

    client.emit('realtime.connected', {
      clientId: client.id,
      storeId,
      timestamp: new Date().toISOString(),
    });
  }

  handleDisconnect(client: Socket) {
    this.logger.debug(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('store.subscribe')
  handleStoreSubscribe(
    @ConnectedSocket() client: Socket,
    @MessageBody() body?: { storeId?: string },
  ) {
    const storeId = this.normalizeStoreId(body?.storeId);
    if (!storeId) {
      return {
        ok: false,
        message: 'storeId is required',
      };
    }

    void client.join(this.getStoreRoom(storeId));

    return {
      ok: true,
      storeId,
      timestamp: new Date().toISOString(),
    };
  }

  @SubscribeMessage('store.unsubscribe')
  handleStoreUnsubscribe(
    @ConnectedSocket() client: Socket,
    @MessageBody() body?: { storeId?: string },
  ) {
    const storeId = this.normalizeStoreId(body?.storeId);
    if (!storeId) {
      return {
        ok: false,
        message: 'storeId is required',
      };
    }

    void client.leave(this.getStoreRoom(storeId));

    return {
      ok: true,
      storeId,
      timestamp: new Date().toISOString(),
    };
  }

  emitStoreEvent<T>(envelope: StoreEventEnvelope<T>) {
    if (!this.server) {
      this.logger.warn(
        `Socket server is not ready. Event skipped: ${envelope.event}`,
      );
      return;
    }

    const payload = {
      ...envelope,
      timestamp: envelope.timestamp ?? new Date().toISOString(),
    };
    const room = this.getStoreRoom(envelope.storeId);

    this.server.to(room).emit(envelope.event, payload);
    this.server.to(room).emit('store.event', payload);
  }

  private getStoreRoom(storeId: string) {
    return `store:${storeId}`;
  }

  private extractStoreId(...values: unknown[]) {
    for (const value of values) {
      const normalized = this.normalizeStoreId(value);
      if (normalized) {
        return normalized;
      }
    }

    return null;
  }

  private normalizeStoreId(value: unknown): string | null {
    if (Array.isArray(value)) {
      return this.normalizeStoreId(value[0]);
    }

    if (typeof value !== 'string') {
      return null;
    }

    const trimmed = value.trim();
    return trimmed ? trimmed : null;
  }
}
