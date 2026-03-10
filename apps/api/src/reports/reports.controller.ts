import { Controller, Get, Query } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { GetSalesSummaryQueryDto } from './dto/get-sales-summary-query.dto';
import { ReportsService } from './reports.service';

@Controller('reports')
export class ReportsController {
  constructor(private reportsService: ReportsService) {}

  @Get('sales/summary')
  getSalesSummary(
    @CurrentUser('storeId') storeId: string,
    @Query() query: GetSalesSummaryQueryDto,
  ) {
    return this.reportsService.getSalesSummary(storeId, query);
  }
}
