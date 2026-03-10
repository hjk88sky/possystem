import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTableDto } from './dto/create-table.dto';
import { UpdateTableDto } from './dto/update-table.dto';
import { UpdateLayoutDto } from './dto/update-layout.dto';
import { RealtimeService } from '../realtime/realtime.service';

@Injectable()
export class TablesService {
  constructor(
    private prisma: PrismaService,
    private realtime: RealtimeService,
  ) {}

  async findAll(storeId: string) {
    return this.prisma.table.findMany({
      where: { storeId },
      include: {
        zone: true,
        orders: {
          where: { status: 'OPEN' },
          take: 1,
        },
      },
      orderBy: { name: 'asc' },
    });
  }

  async findOne(storeId: string, id: string) {
    const table = await this.prisma.table.findFirst({
      where: { id, storeId },
      include: {
        zone: true,
        orders: {
          where: { status: 'OPEN' },
          take: 1,
          include: { orderItems: true },
        },
      },
    });
    if (!table) {
      throw new NotFoundException('Table not found');
    }
    return table;
  }

  async create(storeId: string, dto: CreateTableDto) {
    if (dto.zoneId) {
      const zone = await this.prisma.tableZone.findFirst({
        where: { id: dto.zoneId, storeId },
      });
      if (!zone) {
        throw new NotFoundException('Zone not found');
      }
    }

    const table = await this.prisma.table.create({
      data: {
        storeId,
        name: dto.name,
        zoneId: dto.zoneId,
        capacity: dto.capacity ?? 0,
        posX: dto.posX ?? 0,
        posY: dto.posY ?? 0,
        width: dto.width ?? 80,
        height: dto.height ?? 80,
        shape: (dto.shape as any) ?? 'RECT',
      },
      include: { zone: true },
    });

    this.realtime.emitStoreEvent(
      storeId,
      'tables.created',
      { table },
      { type: 'table', id: table.id },
    );

    return table;
  }

  async update(storeId: string, id: string, dto: UpdateTableDto) {
    await this.findOne(storeId, id);

    if (dto.zoneId) {
      const zone = await this.prisma.tableZone.findFirst({
        where: { id: dto.zoneId, storeId },
      });
      if (!zone) {
        throw new NotFoundException('Zone not found');
      }
    }

    const table = await this.prisma.table.update({
      where: { id },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.zoneId !== undefined && { zoneId: dto.zoneId }),
        ...(dto.capacity !== undefined && { capacity: dto.capacity }),
        ...(dto.posX !== undefined && { posX: dto.posX }),
        ...(dto.posY !== undefined && { posY: dto.posY }),
        ...(dto.width !== undefined && { width: dto.width }),
        ...(dto.height !== undefined && { height: dto.height }),
        ...(dto.shape !== undefined && { shape: dto.shape as any }),
        ...(dto.isActive !== undefined && { isActive: dto.isActive }),
      },
      include: { zone: true },
    });

    this.realtime.emitStoreEvent(
      storeId,
      'tables.updated',
      { table },
      { type: 'table', id: table.id },
    );

    return table;
  }

  async updateLayout(storeId: string, dto: UpdateLayoutDto) {
    const tables = await this.prisma.transaction(async (tx) => {
      for (const item of dto.tables) {
        const table = await tx.table.findFirst({
          where: { id: item.id, storeId },
        });
        if (!table) {
          throw new NotFoundException(`Table ${item.id} not found`);
        }

        await tx.table.update({
          where: { id: item.id },
          data: { posX: item.posX, posY: item.posY },
        });
      }

      return tx.table.findMany({
        where: { storeId },
        include: { zone: true },
        orderBy: { name: 'asc' },
      });
    });

    this.realtime.emitStoreEvent(
      storeId,
      'tables.layout.updated',
      { tables },
      { type: 'table-layout' },
    );

    return tables;
  }

  async findAllZones(storeId: string) {
    return this.prisma.tableZone.findMany({
      where: { storeId },
      include: { tables: true },
      orderBy: { sortOrder: 'asc' },
    });
  }

  async createZone(storeId: string, name: string, sortOrder?: number) {
    const zone = await this.prisma.tableZone.create({
      data: {
        storeId,
        name,
        sortOrder: sortOrder ?? 0,
      },
    });

    this.realtime.emitStoreEvent(
      storeId,
      'tables.zones.created',
      { zone },
      { type: 'table-zone', id: zone.id },
    );

    return zone;
  }
}
