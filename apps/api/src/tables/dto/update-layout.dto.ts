import { IsArray, IsNumber, IsUUID, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class TablePositionDto {
  @IsUUID()
  id: string;

  @IsNumber()
  @Type(() => Number)
  posX: number;

  @IsNumber()
  @Type(() => Number)
  posY: number;
}

export class UpdateLayoutDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TablePositionDto)
  tables: TablePositionDto[];
}
