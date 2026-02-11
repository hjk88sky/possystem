import { IsOptional, IsString, IsEnum, IsInt } from 'class-validator';

enum OrderStatus {
  OPEN = 'OPEN',
  PAID = 'PAID',
  CANCELLED = 'CANCELLED',
  VOID = 'VOID',
}

enum OrderPriority {
  URGENT = 'URGENT',
  HIGH = 'HIGH',
  NORMAL = 'NORMAL',
  LOW = 'LOW',
}

export class UpdateOrderDto {
  @IsEnum(OrderStatus)
  @IsOptional()
  status?: OrderStatus;

  @IsEnum(OrderPriority)
  @IsOptional()
  priority?: OrderPriority;

  @IsString()
  @IsOptional()
  note?: string;

  @IsInt()
  version: number;
}
