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
import { CategoriesService } from './categories.service';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';

@Controller('menu/categories')
export class CategoriesController {
  constructor(private categoriesService: CategoriesService) {}

  @Get()
  findAll(@CurrentUser('storeId') storeId: string) {
    return this.categoriesService.findAll(storeId);
  }

  @Post()
  create(
    @CurrentUser('storeId') storeId: string,
    @Body() dto: CreateCategoryDto,
  ) {
    return this.categoriesService.create(storeId, dto);
  }

  @Get(':id')
  findOne(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.categoriesService.findOne(storeId, id);
  }

  @Patch(':id')
  update(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCategoryDto,
  ) {
    return this.categoriesService.update(storeId, id, dto);
  }

  @Delete(':id')
  remove(
    @CurrentUser('storeId') storeId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.categoriesService.remove(storeId, id);
  }
}
