import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { HealthModule } from './health/health.module';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { StoresModule } from './stores/stores.module';
import { MenuModule } from './menu/menu.module';
import { OrdersModule } from './orders/orders.module';
import { PaymentsModule } from './payments/payments.module';
import { TablesModule } from './tables/tables.module';
import { DevicesModule } from './devices/devices.module';
import { RealtimeModule } from './realtime/realtime.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    PrismaModule,
    RealtimeModule,
    HealthModule,
    AuthModule,
    StoresModule,
    MenuModule,
    OrdersModule,
    PaymentsModule,
    TablesModule,
    DevicesModule,
  ],
})
export class AppModule {}
