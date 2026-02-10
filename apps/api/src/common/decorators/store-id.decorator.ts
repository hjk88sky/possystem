import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const StoreId = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): string | undefined => {
    const request = ctx.switchToHttp().getRequest();
    return request.headers['x-store-id'] || request.user?.storeId;
  },
);
