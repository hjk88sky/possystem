import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateItemDto } from '../dto/create-item.dto';
import { UpdateItemDto } from '../dto/update-item.dto';

@Injectable()
export class ItemsService {
  constructor(private prisma: PrismaService) {}

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
    return this.prisma.menuItem.create({
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
  }

  async update(storeId: string, id: string, dto: UpdateItemDto) {
    await this.findOne(storeId, id);
    return this.prisma.menuItem.update({
      where: { id },
      data: dto as any,
    });
  }

  async toggleSoldOut(storeId: string, id: string) {
    const item = await this.findOne(storeId, id);
    return this.prisma.menuItem.update({
      where: { id },
      data: { isSoldOut: !item.isSoldOut },
    });
  }

  async remove(storeId: string, id: string) {
    await this.findOne(storeId, id);
    return this.prisma.menuItem.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }
}
