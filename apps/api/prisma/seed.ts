import 'dotenv/config';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import * as bcrypt from 'bcrypt';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function main() {
  const franchiseName = 'Demo Franchise';
  const storeCode = 'STORE001';
  const storeName = '강남점';
  const deviceCode = 'POS-001';
  const userPhone = '01012345678';
  const defaultPin = '1234';
  const pinHash = await bcrypt.hash(defaultPin, 10);

  const franchise =
    (await prisma.franchise.findFirst({ where: { name: franchiseName } })) ??
    (await prisma.franchise.create({
      data: { name: franchiseName },
    }));

  const store = await prisma.store.upsert({
    where: { code: storeCode },
    update: {
      name: storeName,
      franchiseId: franchise.id,
    },
    create: {
      code: storeCode,
      name: storeName,
      franchiseId: franchise.id,
    },
  });

  const ownerRole =
    (await prisma.role.findFirst({
      where: { storeId: store.id, name: 'OWNER' },
    })) ??
    (await prisma.role.create({
      data: { storeId: store.id, name: 'OWNER' },
    }));

  await prisma.user.upsert({
    where: { storeId_phone: { storeId: store.id, phone: userPhone } },
    update: {
      name: '관리자',
      roleId: ownerRole.id,
    },
    create: {
      storeId: store.id,
      roleId: ownerRole.id,
      name: '관리자',
      phone: userPhone,
      pinHash,
    },
  });

  await prisma.device.upsert({
    where: { deviceCode },
    update: {
      storeId: store.id,
      deviceName: '계산대1',
      os: 'WINDOWS',
      type: 'POS',
    },
    create: {
      storeId: store.id,
      deviceCode,
      deviceName: '계산대1',
      os: 'WINDOWS',
      type: 'POS',
    },
  });

  console.log('Seed completed:', {
    franchiseId: franchise.id,
    storeId: store.id,
    ownerRoleId: ownerRole.id,
    deviceCode,
    userPhone,
  });
}

main()
  .catch((error) => {
    console.error('Seed failed:', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });
