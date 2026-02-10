import { IsNumber, IsOptional, IsString, IsUUID, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateRefundDto {
  @IsUUID()
  paymentId: string;

  @IsNumber()
  @Type(() => Number)
  @Min(0)
  amount: number;

  @IsString()
  @IsOptional()
  reason?: string;
}
