import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ItemsService } from './items.service';
import { CreateItemDto } from '../dto/create-item.dto';
import { UpdateItemDto } from '../dto/update-item.dto';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';

@Controller('menu/items')
export class ItemsController {
  constructor(private itemsService: ItemsService) {}

  @Get()
  findAll(@CurrentUser('storeId') storeId: string) {
    return this.itemsService.findAll(storeId);
  }

  @Post()
  create(
    @CurrentUser('storeId') storeId: string,
    @Body() dto: CreateItemDto,
  ) {
    return this.itemsService.create(storeId, dto);
  }

  @Get(':id')
  findOne(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.itemsService.findOne(storeId, id);
  }

  @Patch(':id')
  update(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateItemDto,
  ) {
    return this.itemsService.update(storeId, id, dto);
  }

  @Patch(':id/sold-out')
  toggleSoldOut(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.itemsService.toggleSoldOut(storeId, id);
  }

  @Delete(':id')
  remove(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.itemsService.remove(storeId, id);
  }
}
