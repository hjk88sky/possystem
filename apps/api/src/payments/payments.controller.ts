import { Controller, Post, Param, Body, ParseUUIDPipe } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { CreateRefundDto } from './dto/create-refund.dto';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('orders/:orderId')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  @Post('payments')
  createPayment(
    @CurrentUser('storeId') storeId: string,
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: CreatePaymentDto,
  ) {
    return this.paymentsService.createPayment(storeId, orderId, dto);
  }

  @Post('refunds')
  createRefund(
    @CurrentUser('storeId') storeId: string,
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: CreateRefundDto,
  ) {
    return this.paymentsService.createRefund(storeId, orderId, dto);
  }
}
