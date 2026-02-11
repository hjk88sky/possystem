import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { UpdateDeviceDto } from './dto/update-device.dto';
import { HeartbeatDto } from './dto/heartbeat.dto';
import { GetDevicesQueryDto } from './dto/get-devices-query.dto';

@Injectable()
export class DevicesService {
  constructor(private prisma: PrismaService) {}

  async register(storeId: string, dto: RegisterDeviceDto) {
    const existing = await this.prisma.device.findUnique({
      where: { deviceCode: dto.deviceCode },
    });

    if (existing && existing.storeId !== storeId) {
      throw new ConflictException(
        'Device is already registered to another store',
      );
    }

    if (existing && existing.storeId === storeId) {
      return this.prisma.device.update({
        where: { id: existing.id },
        data: {
          type: dto.type as any,
          os: dto.os as any,
          deviceName: dto.deviceName,
          appVersion: dto.appVersion,
          hardwareModel: dto.hardwareModel,
          status: 'ACTIVE',
          lastSeenAt: new Date(),
        },
      });
    }

    return this.prisma.device.create({
      data: {
        storeId,
        deviceCode: dto.deviceCode,
        type: dto.type as any,
        os: dto.os as any,
        deviceName: dto.deviceName,
        appVersion: dto.appVersion,
        hardwareModel: dto.hardwareModel,
        status: 'ACTIVE',
        lastSeenAt: new Date(),
      },
    });
  }

  async findAll(storeId: string, query?: GetDevicesQueryDto) {
    const { type, status } = query ?? {};

    const where: Prisma.DeviceWhereInput = { storeId };
    if (type) {
      where.type = type as any;
    }
    if (status) {
      where.status = status as any;
    }

    return this.prisma.device.findMany({
      where,
      orderBy: { createdAt: 'asc' },
    });
  }

  async findOne(storeId: string, id: string) {
    const device = await this.prisma.device.findFirst({
      where: { id, storeId },
    });
    if (!device) {
      throw new NotFoundException('Device not found');
    }
    return device;
  }

  async update(storeId: string, id: string, dto: UpdateDeviceDto) {
    await this.findOne(storeId, id);

    if (dto.status === 'OFFLINE') {
      throw new BadRequestException(
        'Cannot manually set device status to OFFLINE',
      );
    }

    return this.prisma.device.update({
      where: { id },
      data: {
        ...(dto.deviceName !== undefined && { deviceName: dto.deviceName }),
        ...(dto.appVersion !== undefined && { appVersion: dto.appVersion }),
        ...(dto.hardwareModel !== undefined && {
          hardwareModel: dto.hardwareModel,
        }),
        ...(dto.status !== undefined && { status: dto.status as any }),
        ...(dto.configJson !== undefined && { configJson: dto.configJson }),
      },
    });
  }

  async heartbeat(storeId: string, id: string, dto: HeartbeatDto) {
    const device = await this.findOne(storeId, id);

    const data: Prisma.DeviceUpdateInput = {
      lastSeenAt: new Date(),
    };

    if (dto.appVersion) {
      data.appVersion = dto.appVersion;
    }

    // OFFLINE -> ACTIVE (auto-recover)
    if (device.status === 'OFFLINE') {
      data.status = 'ACTIVE';
    }
    // INACTIVE -> keep INACTIVE (only update lastSeenAt)

    const updated = await this.prisma.device.update({
      where: { id },
      data,
    });

    return { lastSeenAt: updated.lastSeenAt };
  }
}
