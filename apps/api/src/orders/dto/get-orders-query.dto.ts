import { IsOptional, IsEnum, IsIn, IsInt, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

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

export class GetOrdersQueryDto {
  @IsEnum(OrderPriority)
  @IsOptional()
  priority?: OrderPriority;

  @IsEnum(OrderStatus)
  @IsOptional()
  status?: OrderStatus;

  @IsIn(['createdAt', 'priority'])
  @IsOptional()
  sortBy?: 'createdAt' | 'priority';

  @IsIn(['asc', 'desc'])
  @IsOptional()
  order?: 'asc' | 'desc';

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  @Type(() => Number)
  limit?: number = 20;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Type(() => Number)
  offset?: number = 0;
}
