import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateItemDto } from '../dto/create-item.dto';
import { UpdateItemDto } from '../dto/update-item.dto';
import { RealtimeService } from '../../realtime/realtime.service';

@Injectable()
export class ItemsService {
  constructor(
    private prisma: PrismaService,
    private realtime: RealtimeService,
  ) {}

  async findAll(storeId: string) {
    return this.prisma.menuItem.findMany({
      where: { storeId, deletedAt: null },
      include: { category: true },
      orderBy: { sortOrder: 'asc' },
    });
  }

  async findOne(storeId: string, id: string) {
    const item = await this.prisma.menuItem.findFirst({
      where: { id, storeId, deletedAt: null },
      include: {
        category: true,
        menuItemOptionGroups: {
          include: {
            group: { include: { options: true } },
          },
        },
      },
    });
    if (!item) {
      throw new NotFoundException('Menu item not found');
    }
    return item;
  }

  async create(storeId: string, dto: CreateItemDto) {
    const item = await this.prisma.menuItem.create({
      data: {
        storeId,
        name: dto.name,
        categoryId: dto.categoryId,
        description: dto.description,
        sku: dto.sku,
        barcode: dto.barcode,
        price: dto.price,
        costPrice: dto.costPrice,
        taxType: dto.taxType as any,
        imageUrl: dto.imageUrl,
        isActive: dto.isActive,
        sortOrder: dto.sortOrder,
      },
    });

    this.realtime.emitStoreEvent(
      storeId,
      'menu.items.created',
      { item },
      { type: 'menu-item', id: item.id },
    );

    return item;
  }

  async update(storeId: string, id: string, dto: UpdateItemDto) {
    await this.findOne(storeId, id);
    const item = await this.prisma.menuItem.update({
      where: { id },
      data: dto as any,
    });

    this.realtime.emitStoreEvent(
      storeId,
      'menu.items.updated',
      { item },
      { type: 'menu-item', id: item.id },
    );

    return item;
  }

  async toggleSoldOut(storeId: string, id: string) {
    const item = await this.findOne(storeId, id);
    const updatedItem = await this.prisma.menuItem.update({
      where: { id },
      data: { isSoldOut: !item.isSoldOut },
    });

    this.realtime.emitStoreEvent(
      storeId,
      'menu.items.sold-out-toggled',
      { item: updatedItem },
      { type: 'menu-item', id: updatedItem.id },
    );

    return updatedItem;
  }

  async remove(storeId: string, id: string) {
    await this.findOne(storeId, id);
    const item = await this.prisma.menuItem.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    this.realtime.emitStoreEvent(
      storeId,
      'menu.items.deleted',
      { itemId: item.id },
      { type: 'menu-item', id: item.id },
    );

    return item;
  }
}
