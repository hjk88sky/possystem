import {
  Injectable,
  UnauthorizedException,
  NotFoundException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async login(dto: LoginDto) {
    const store = await this.prisma.store.findUnique({
      where: { code: dto.store_code },
    });
    if (!store) {
      throw new NotFoundException('Store not found');
    }

    const user = await this.prisma.user.findFirst({
      where: {
        storeId: store.id,
        phone: dto.phone,
        deletedAt: null,
        status: 'ACTIVE',
      },
      include: { role: true },
    });
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.pinHash) {
      throw new UnauthorizedException('PIN not set for this user');
    }

    const pinValid = await bcrypt.compare(dto.pin, user.pinHash);
    if (!pinValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = {
      sub: user.id,
      storeId: store.id,
      role: user.role?.name || 'STAFF',
    };

    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN', '7d'),
    });

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'Bearer',
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        role: user.role?.name,
        storeId: store.id,
        storeName: store.name,
      },
    };
  }

  async refresh(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken);
      const newPayload = {
        sub: payload.sub,
        storeId: payload.storeId,
        role: payload.role,
      };

      const accessToken = this.jwtService.sign(newPayload);
      const newRefreshToken = this.jwtService.sign(newPayload, {
        expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN', '7d'),
      });

      return {
        access_token: accessToken,
        refresh_token: newRefreshToken,
        token_type: 'Bearer',
      };
    } catch {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
  }

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        role: true,
        store: { select: { id: true, name: true, code: true } },
      },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      id: user.id,
      name: user.name,
      phone: user.phone,
      email: user.email,
      role: user.role?.name,
      store: user.store,
    };
  }
}
