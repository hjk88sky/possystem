import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';
import { RealtimeService } from '../../realtime/realtime.service';

@Injectable()
export class CategoriesService {
  constructor(
    private prisma: PrismaService,
    private realtime: RealtimeService,
  ) {}

  async findAll(storeId: string) {
    return this.prisma.menuCategory.findMany({
      where: { storeId, deletedAt: null },
      include: { children: { where: { deletedAt: null } } },
      orderBy: { sortOrder: 'asc' },
    });
  }

  async findOne(storeId: string, id: string) {
    const category = await this.prisma.menuCategory.findFirst({
      where: { id, storeId, deletedAt: null },
      include: {
        children: { where: { deletedAt: null } },
        menuItems: { where: { deletedAt: null }, orderBy: { sortOrder: 'asc' } },
      },
    });
    if (!category) {
      throw new NotFoundException('Category not found');
    }
    return category;
  }

  async create(storeId: string, dto: CreateCategoryDto) {
    const category = await this.prisma.menuCategory.create({
      data: {
        storeId,
        name: dto.name,
        parentId: dto.parentId,
        color: dto.color,
        sortOrder: dto.sortOrder,
        isActive: dto.isActive,
      },
    });

    this.realtime.emitStoreEvent(
      storeId,
      'menu.categories.created',
      { category },
      { type: 'menu-category', id: category.id },
    );

    return category;
  }

  async update(storeId: string, id: string, dto: UpdateCategoryDto) {
    await this.findOne(storeId, id);
    const category = await this.prisma.menuCategory.update({
      where: { id },
      data: dto,
    });

    this.realtime.emitStoreEvent(
      storeId,
      'menu.categories.updated',
      { category },
      { type: 'menu-category', id: category.id },
    );

    return category;
  }

  async remove(storeId: string, id: string) {
    await this.findOne(storeId, id);
    const category = await this.prisma.menuCategory.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    this.realtime.emitStoreEvent(
      storeId,
      'menu.categories.deleted',
      { categoryId: category.id },
      { type: 'menu-category', id: category.id },
    );

    return category;
  }
}
