import { IsEnum, IsNumber, IsOptional, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';

enum PaymentMethod {
  CARD = 'CARD',
  CASH = 'CASH',
  TRANSFER = 'TRANSFER',
  POINT = 'POINT',
  OTHER = 'OTHER',
}

export class CreatePaymentDto {
  @IsEnum(PaymentMethod)
  method: PaymentMethod;

  @IsNumber()
  @Type(() => Number)
  @Min(0)
  amount: number;

  @IsInt()
  @IsOptional()
  installmentMonths?: number;
}
