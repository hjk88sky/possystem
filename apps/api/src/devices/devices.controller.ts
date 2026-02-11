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
import { DevicesService } from './devices.service';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { UpdateDeviceDto } from './dto/update-device.dto';
import { HeartbeatDto } from './dto/heartbeat.dto';
import { GetDevicesQueryDto } from './dto/get-devices-query.dto';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('devices')
export class DevicesController {
  constructor(private devicesService: DevicesService) {}

  @Post('register')
  register(
    @CurrentUser('storeId') storeId: string,
    @Body() dto: RegisterDeviceDto,
  ) {
    return this.devicesService.register(storeId, dto);
  }

  @Get()
  findAll(
    @CurrentUser('storeId') storeId: string,
    @Query() query: GetDevicesQueryDto,
  ) {
    return this.devicesService.findAll(storeId, query);
  }

  @Get(':id')
  findOne(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.devicesService.findOne(storeId, id);
  }

  @Patch(':id')
  update(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateDeviceDto,
  ) {
    return this.devicesService.update(storeId, id, dto);
  }

  @Post(':id/heartbeat')
  heartbeat(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: HeartbeatDto,
  ) {
    return this.devicesService.heartbeat(storeId, id, dto);
  }
}
