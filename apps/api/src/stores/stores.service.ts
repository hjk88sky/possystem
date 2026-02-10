import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';

@Injectable()
export class StoresService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.store.findMany({
      where: { deletedAt: null },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const store = await this.prisma.store.findFirst({
      where: { id, deletedAt: null },
    });
    if (!store) {
      throw new NotFoundException('Store not found');
    }
    return store;
  }

  async create(dto: CreateStoreDto) {
    const existing = await this.prisma.store.findUnique({
      where: { code: dto.code },
    });
    if (existing) {
      throw new ConflictException('Store code already exists');
    }

    return this.prisma.store.create({
      data: {
        name: dto.name,
        code: dto.code,
        franchiseId: dto.franchiseId,
        address: dto.address,
        businessNumber: dto.businessNumber,
        timezone: dto.timezone,
      },
    });
  }

  async update(id: string, dto: UpdateStoreDto) {
    await this.findOne(id);
    return this.prisma.store.update({
      where: { id },
      data: dto,
    });
  }
}
