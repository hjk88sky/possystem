import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';

@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  async create(storeId: string, dto: CreateOrderDto) {
    return this.prisma.transaction(async (tx) => {
      const orderNo = await this.generateOrderNo(storeId, tx as any);

      let subtotal = new Prisma.Decimal(0);
      const orderItemsData: any[] = [];

      for (const item of dto.items) {
        let unitPrice = new Prisma.Decimal(0);
        let nameSnapshot = '';

        if (item.itemId) {
          const menuItem = await tx.menuItem.findUnique({
            where: { id: item.itemId },
          });
          if (!menuItem) {
            throw new NotFoundException(`Menu item ${item.itemId} not found`);
          }
          unitPrice = menuItem.price;
          nameSnapshot = menuItem.name;
        } else if (item.setId) {
          const menuSet = await tx.menuSet.findUnique({
            where: { id: item.setId },
          });
          if (!menuSet) {
            throw new NotFoundException(`Menu set ${item.setId} not found`);
          }
          unitPrice = menuSet.price;
          nameSnapshot = menuSet.name;
        }

        let optionsDelta = new Prisma.Decimal(0);
        const optionsData: any[] = [];

        if (item.options?.length) {
          for (const opt of item.options) {
            const menuOption = await tx.menuOption.findUnique({
              where: { id: opt.optionId },
            });
            if (!menuOption) {
              throw new NotFoundException(`Option ${opt.optionId} not found`);
            }
            optionsDelta = optionsDelta.add(menuOption.priceDelta);
            optionsData.push({
              optionId: opt.optionId,
              nameSnapshot: menuOption.name,
              priceDelta: menuOption.priceDelta,
            });
          }
        }

        const itemTotal = unitPrice.add(optionsDelta).mul(item.qty);
        subtotal = subtotal.add(itemTotal);

        orderItemsData.push({
          itemId: item.itemId,
          setId: item.setId,
          nameSnapshot,
          qty: item.qty,
          unitPrice: unitPrice.add(optionsDelta),
          totalPrice: itemTotal,
          note: item.note,
          options: optionsData,
        });
      }

      const tax = subtotal.mul(new Prisma.Decimal('0.1')).toDecimalPlaces(0);
      const total = subtotal.add(tax);

      const order = await tx.order.create({
        data: {
          storeId,
          orderNo,
          tableId: dto.tableId,
          customerId: dto.customerId,
          channel: dto.channel as any,
          note: dto.note,
          subtotal,
          tax,
          total,
          orderItems: {
            create: orderItemsData.map((oi) => ({
              itemId: oi.itemId,
              setId: oi.setId,
              nameSnapshot: oi.nameSnapshot,
              qty: oi.qty,
              unitPrice: oi.unitPrice,
              totalPrice: oi.totalPrice,
              note: oi.note,
              options: {
                create: oi.options,
              },
            })),
          },
        },
        include: {
          orderItems: { include: { options: true } },
        },
      });

      return order;
    });
  }

  async findAll(storeId: string) {
    return this.prisma.order.findMany({
      where: { storeId },
      include: {
        orderItems: true,
        payments: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(storeId: string, id: string) {
    const order = await this.prisma.order.findFirst({
      where: { id, storeId },
      include: {
        orderItems: { include: { options: true } },
        payments: true,
        table: true,
        customer: true,
      },
    });
    if (!order) {
      throw new NotFoundException('Order not found');
    }
    return order;
  }

  async update(storeId: string, id: string, dto: UpdateOrderDto) {
    const order = await this.findOne(storeId, id);

    if (order.version !== dto.version) {
      throw new ConflictException({
        errorCode: 'VERSION_CONFLICT',
        message: 'Order has been modified by another user',
        currentVersion: order.version,
      });
    }

    return this.prisma.order.update({
      where: { id },
      data: {
        status: dto.status as any,
        note: dto.note,
        version: { increment: 1 },
        ...(dto.status === 'CANCELLED' || dto.status === 'VOID'
          ? { closedAt: new Date() }
          : {}),
      },
      include: {
        orderItems: { include: { options: true } },
        payments: true,
      },
    });
  }

  private async generateOrderNo(
    storeId: string,
    tx: PrismaService,
  ): Promise<string> {
    const today = new Date();
    const dateStr =
      today.getFullYear().toString() +
      (today.getMonth() + 1).toString().padStart(2, '0') +
      today.getDate().toString().padStart(2, '0');

    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const endOfDay = new Date(startOfDay.getTime() + 24 * 60 * 60 * 1000);

    const count = await tx.order.count({
      where: {
        storeId,
        createdAt: {
          gte: startOfDay,
          lt: endOfDay,
        },
      },
    });

    const seq = (count + 1).toString().padStart(3, '0');
    return `${dateStr}-${seq}`;
  }
}
