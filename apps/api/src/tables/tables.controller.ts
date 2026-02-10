import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  ParseUUIDPipe,
} from '@nestjs/common';
import { IsString, IsNotEmpty, IsInt, IsOptional } from 'class-validator';
import { Type } from 'class-transformer';
import { TablesService } from './tables.service';
import { CreateTableDto } from './dto/create-table.dto';
import { UpdateTableDto } from './dto/update-table.dto';
import { UpdateLayoutDto } from './dto/update-layout.dto';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

class CreateZoneDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsInt()
  @IsOptional()
  @Type(() => Number)
  sortOrder?: number;
}

@Controller('tables')
export class TablesController {
  constructor(private tablesService: TablesService) {}

  @Get()
  findAll(@CurrentUser('storeId') storeId: string) {
    return this.tablesService.findAll(storeId);
  }

  @Post()
  create(
    @CurrentUser('storeId') storeId: string,
    @Body() dto: CreateTableDto,
  ) {
    return this.tablesService.create(storeId, dto);
  }

  @Patch(':id')
  update(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateTableDto,
  ) {
    return this.tablesService.update(storeId, id, dto);
  }

  @Post('layout')
  updateLayout(
    @CurrentUser('storeId') storeId: string,
    @Body() dto: UpdateLayoutDto,
  ) {
    return this.tablesService.updateLayout(storeId, dto);
  }

  @Get('zones')
  findAllZones(@CurrentUser('storeId') storeId: string) {
    return this.tablesService.findAllZones(storeId);
  }

  @Post('zones')
  createZone(
    @CurrentUser('storeId') storeId: string,
    @Body() dto: CreateZoneDto,
  ) {
    return this.tablesService.createZone(storeId, dto.name, dto.sortOrder);
  }
}
