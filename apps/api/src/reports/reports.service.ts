import { BadRequestException, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { GetSalesSummaryQueryDto } from './dto/get-sales-summary-query.dto';

@Injectable()
export class ReportsService {
  constructor(private prisma: PrismaService) {}

  async getSalesSummary(storeId: string, query: GetSalesSummaryQueryDto) {
    const { dateFrom, dateTo } = this.resolveDateRange(query);
    const topItemsLimit = query.topItemsLimit ?? 5;

    const paidOrdersWhere: Prisma.OrderWhereInput = {
      storeId,
      status: 'PAID',
      closedAt: {
        gte: dateFrom,
        lte: dateTo,
      },
    };

    const approvedPaymentsWhere: Prisma.PaymentWhereInput = {
      status: 'APPROVED',
      approvedAt: {
        gte: dateFrom,
        lte: dateTo,
      },
      order: {
        storeId,
      },
    };

    const approvedRefundsWhere: Prisma.RefundWhereInput = {
      status: 'APPROVED',
      approvedAt: {
        gte: dateFrom,
        lte: dateTo,
      },
      payment: {
        order: {
          storeId,
        },
      },
    };

    const [paidOrders, refunds, paymentsByMethod, ordersByChannel, topItems, openOrders] =
      await Promise.all([
        this.prisma.order.aggregate({
          where: paidOrdersWhere,
          _count: { _all: true },
          _sum: {
            subtotal: true,
            discount: true,
            couponDiscount: true,
            tax: true,
            total: true,
            paidAmount: true,
            changeAmount: true,
          },
        }),
        this.prisma.refund.aggregate({
          where: approvedRefundsWhere,
          _count: { _all: true },
          _sum: {
            amount: true,
          },
        }),
        this.prisma.payment.groupBy({
          by: ['method'],
          where: approvedPaymentsWhere,
          _count: { _all: true },
          _sum: {
            amount: true,
          },
          orderBy: {
            _sum: {
              amount: 'desc',
            },
          },
        }),
        this.prisma.order.groupBy({
          by: ['channel'],
          where: paidOrdersWhere,
          _count: { _all: true },
          _sum: {
            total: true,
          },
          orderBy: {
            _count: {
              channel: 'desc',
            },
          },
        }),
        this.prisma.orderItem.groupBy({
          by: ['itemId', 'setId', 'nameSnapshot'],
          where: {
            order: paidOrdersWhere,
          },
          _sum: {
            qty: true,
            totalPrice: true,
          },
          orderBy: {
            _sum: {
              totalPrice: 'desc',
            },
          },
          take: topItemsLimit,
        }),
        this.prisma.order.count({
          where: {
            storeId,
            status: 'OPEN',
          },
        }),
      ]);

    const grossSales = paidOrders._sum.total ?? new Prisma.Decimal(0);
    const refundAmount = refunds._sum.amount ?? new Prisma.Decimal(0);
    const orderCount = paidOrders._count._all;

    return {
      period: {
        dateFrom: dateFrom.toISOString(),
        dateTo: dateTo.toISOString(),
      },
      summary: {
        grossSales,
        refundAmount,
        netSales: grossSales.sub(refundAmount),
        orderCount,
        openOrders,
        averageOrderValue:
          orderCount > 0
            ? grossSales.div(orderCount).toDecimalPlaces(2)
            : new Prisma.Decimal(0),
        subtotal: paidOrders._sum.subtotal ?? new Prisma.Decimal(0),
        tax: paidOrders._sum.tax ?? new Prisma.Decimal(0),
        discount: paidOrders._sum.discount ?? new Prisma.Decimal(0),
        couponDiscount: paidOrders._sum.couponDiscount ?? new Prisma.Decimal(0),
        paidAmount: paidOrders._sum.paidAmount ?? new Prisma.Decimal(0),
        changeAmount: paidOrders._sum.changeAmount ?? new Prisma.Decimal(0),
        refundCount: refunds._count._all,
      },
      paymentsByMethod: paymentsByMethod.map((entry) => ({
        method: entry.method,
        count: entry._count._all,
        amount: entry._sum.amount ?? new Prisma.Decimal(0),
      })),
      ordersByChannel: ordersByChannel.map((entry) => ({
        channel: entry.channel,
        count: entry._count._all,
        sales: entry._sum.total ?? new Prisma.Decimal(0),
      })),
      topItems: topItems.map((entry) => ({
        itemId: entry.itemId,
        setId: entry.setId,
        name: entry.nameSnapshot,
        qty: entry._sum.qty ?? 0,
        sales: entry._sum.totalPrice ?? new Prisma.Decimal(0),
      })),
    };
  }

  private resolveDateRange(query: GetSalesSummaryQueryDto) {
    const now = new Date();

    let dateFrom: Date;
    let dateTo: Date;

    if (query.dateFrom && query.dateTo) {
      dateFrom = this.startOfDay(new Date(query.dateFrom));
      dateTo = this.endOfDay(new Date(query.dateTo));
    } else if (query.dateFrom) {
      dateFrom = this.startOfDay(new Date(query.dateFrom));
      dateTo = now;
    } else if (query.dateTo) {
      dateFrom = this.startOfDay(new Date(query.dateTo));
      dateTo = this.endOfDay(new Date(query.dateTo));
    } else {
      dateFrom = this.startOfDay(now);
      dateTo = now;
    }

    if (dateFrom > dateTo) {
      throw new BadRequestException('dateFrom must be earlier than or equal to dateTo');
    }

    return { dateFrom, dateTo };
  }

  private startOfDay(date: Date) {
    const value = new Date(date);
    value.setHours(0, 0, 0, 0);
    return value;
  }

  private endOfDay(date: Date) {
    const value = new Date(date);
    value.setHours(23, 59, 59, 999);
    return value;
  }
}
