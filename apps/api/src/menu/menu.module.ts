import { Module } from '@nestjs/common';
import { CategoriesService } from './categories/categories.service';
import { CategoriesController } from './categories/categories.controller';
import { ItemsService } from './items/items.service';
import { ItemsController } from './items/items.controller';

@Module({
  controllers: [CategoriesController, ItemsController],
  providers: [CategoriesService, ItemsService],
  exports: [CategoriesService, ItemsService],
})
export class MenuModule {}
