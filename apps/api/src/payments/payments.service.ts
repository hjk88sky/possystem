import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { CreateRefundDto } from './dto/create-refund.dto';

@Injectable()
export class PaymentsService {
  constructor(private prisma: PrismaService) {}

  async createPayment(storeId: string, orderId: string, dto: CreatePaymentDto) {
    return this.prisma.transaction(async (tx) => {
      const order = await tx.order.findFirst({
        where: { id: orderId, storeId },
      });
      if (!order) {
        throw new NotFoundException('Order not found');
      }
      if (order.status !== 'OPEN') {
        throw new BadRequestException('Order is not in OPEN status');
      }

      const amount = new Prisma.Decimal(dto.amount);

      // Mock VAN approval for card payments
      const mockApproval = this.mockVanApproval(dto.method as string, amount);

      const payment = await tx.payment.create({
        data: {
          orderId,
          method: dto.method as any,
          amount,
          status: mockApproval.status as any,
          approvedAt: mockApproval.status === 'APPROVED' ? new Date() : null,
          vanProvider: mockApproval.vanProvider,
          vanTxId: mockApproval.vanTxId,
          approvalCode: mockApproval.approvalCode,
          cardBrand: mockApproval.cardBrand,
          cardNumberMasked: mockApproval.cardNumberMasked,
          installmentMonths: dto.installmentMonths || 0,
        },
      });

      // Record payment attempt
      await tx.paymentAttempt.create({
        data: {
          paymentId: payment.id,
          status: mockApproval.status as any,
          requestPayload: { method: dto.method, amount: dto.amount },
          responsePayload: mockApproval,
        },
      });

      if (mockApproval.status === 'APPROVED') {
        const newPaidAmount = order.paidAmount.add(amount);
        const orderTotal = order.total;

        const updateData: any = {
          paidAmount: newPaidAmount,
          version: { increment: 1 },
        };

        if (newPaidAmount.gte(orderTotal)) {
          updateData.status = 'PAID';
          updateData.closedAt = new Date();

          // Calculate change for cash
          if (dto.method === 'CASH' && newPaidAmount.gt(orderTotal)) {
            updateData.changeAmount = newPaidAmount.sub(orderTotal);
          }
        }

        await tx.order.update({
          where: { id: orderId },
          data: updateData,
        });
      }

      return payment;
    });
  }

  async createRefund(storeId: string, orderId: string, dto: CreateRefundDto) {
    return this.prisma.transaction(async (tx) => {
      const order = await tx.order.findFirst({
        where: { id: orderId, storeId },
      });
      if (!order) {
        throw new NotFoundException('Order not found');
      }

      const payment = await tx.payment.findFirst({
        where: { id: dto.paymentId, orderId },
      });
      if (!payment) {
        throw new NotFoundException('Payment not found');
      }
      if (payment.status !== 'APPROVED') {
        throw new BadRequestException('Payment is not approved');
      }

      const refundAmount = new Prisma.Decimal(dto.amount);
      if (refundAmount.gt(payment.amount)) {
        throw new BadRequestException('Refund amount exceeds payment amount');
      }

      const refund = await tx.refund.create({
        data: {
          paymentId: payment.id,
          amount: refundAmount,
          reason: dto.reason,
          status: 'APPROVED',
          approvedAt: new Date(),
          vanTxId: `RF-${Date.now()}`,
        },
      });

      // Update order paid amount
      await tx.order.update({
        where: { id: orderId },
        data: {
          paidAmount: { decrement: refundAmount },
          status: 'OPEN',
          closedAt: null,
          version: { increment: 1 },
        },
      });

      return refund;
    });
  }

  private mockVanApproval(method: string, amount: Prisma.Decimal) {
    if (method === 'CASH') {
      return {
        status: 'APPROVED',
        vanProvider: null,
        vanTxId: null,
        approvalCode: null,
        cardBrand: null,
        cardNumberMasked: null,
      };
    }

    // Mock card approval
    return {
      status: 'APPROVED',
      vanProvider: 'KFTC',
      vanTxId: `VAN-${Date.now()}`,
      approvalCode: Math.random().toString(36).substring(2, 10).toUpperCase(),
      cardBrand: 'VISA',
      cardNumberMasked: '****-****-****-1234',
    };
  }
}
