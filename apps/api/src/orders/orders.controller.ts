import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  Query,
  ParseUUIDPipe,
} from '@nestjs/common';
import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { GetOrdersQueryDto } from './dto/get-orders-query.dto';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('orders')
export class OrdersController {
  constructor(private ordersService: OrdersService) {}

  @Post()
  create(
    @CurrentUser('storeId') storeId: string,
    @Body() dto: CreateOrderDto,
  ) {
    return this.ordersService.create(storeId, dto);
  }

  @Get()
  findAll(
    @CurrentUser('storeId') storeId: string,
    @Query() query: GetOrdersQueryDto,
  ) {
    return this.ordersService.findAll(storeId, query);
  }

  @Get(':id')
  findOne(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.ordersService.findOne(storeId, id);
  }

  @Patch(':id')
  update(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateOrderDto,
  ) {
    return this.ordersService.update(storeId, id, dto);
  }
}
