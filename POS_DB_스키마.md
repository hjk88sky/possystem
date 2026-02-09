# POS DB 스키마 (v1.1)

## 1. 개요
- **대상 DB**: PostgreSQL 15+
- **ORM**: Prisma
- **멀티테넌트 구조**: Franchise → Store → Device
- **동시성 제어**: `orders.version`, `tables.version`
- **동기화**: `updated_at` 기준 증분 동기화
- **소프트 삭제**: 주요 테이블에 `deleted_at` 컬럼

## 2. ENUM 정의

```sql
-- 디바이스
CREATE TYPE device_type AS ENUM ('POS', 'KIOSK', 'CUSTOMER_DISPLAY', 'KDS');
CREATE TYPE device_os AS ENUM ('WINDOWS', 'ANDROID');
CREATE TYPE device_status AS ENUM ('ACTIVE', 'INACTIVE', 'OFFLINE');

-- 주문
CREATE TYPE order_status AS ENUM ('OPEN', 'PAID', 'CANCELLED', 'VOID');
CREATE TYPE order_channel AS ENUM ('POS', 'KIOSK', 'QR', 'DELIVERY');
CREATE TYPE order_item_status AS ENUM ('ORDERED', 'COOKING', 'SERVED', 'CANCELLED');

-- 결제
CREATE TYPE payment_method AS ENUM ('CARD', 'CASH', 'TRANSFER', 'POINT', 'OTHER');
CREATE TYPE payment_status AS ENUM ('PENDING', 'APPROVED', 'DECLINED', 'CANCELLED');

-- 재고
CREATE TYPE stock_movement_type AS ENUM ('IN', 'OUT', 'ADJUST');

-- 고객
CREATE TYPE loyalty_txn_type AS ENUM ('EARN', 'REDEEM', 'EXPIRE', 'ADJUST');

-- 메뉴
CREATE TYPE tax_type AS ENUM ('TAXABLE', 'ZERO', 'EXEMPT');

-- 쿠폰
CREATE TYPE coupon_type AS ENUM ('FIXED', 'PERCENT', 'FREE_ITEM');

-- 영수증
CREATE TYPE receipt_type AS ENUM ('CUSTOMER', 'KITCHEN', 'PICKUP');

-- 테이블
CREATE TYPE table_shape AS ENUM ('RECT', 'CIRCLE');

-- QR
CREATE TYPE qr_type AS ENUM ('TABLE_ORDER', 'PICKUP');

-- 상태
CREATE TYPE entity_status AS ENUM ('ACTIVE', 'INACTIVE');
```

## 3. 핵심 테이블

### 조직 (Organization)

```sql
-- 본사
CREATE TABLE franchises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  status entity_status NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- 매장
CREATE TABLE stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  franchise_id UUID REFERENCES franchises(id),
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  address TEXT,
  business_number TEXT,
  van_provider TEXT DEFAULT 'KFTC',
  van_merchant_id TEXT,
  timezone TEXT NOT NULL DEFAULT 'Asia/Seoul',
  status entity_status NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX ux_stores_code ON stores(code) WHERE deleted_at IS NULL;

-- 디바이스
CREATE TABLE devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  type device_type NOT NULL,
  os device_os NOT NULL,
  device_code TEXT NOT NULL,
  device_name TEXT,
  app_version TEXT,
  hardware_model TEXT,
  last_seen_at TIMESTAMPTZ,
  status device_status NOT NULL DEFAULT 'ACTIVE',
  config_json JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX ux_devices_code ON devices(device_code);
CREATE INDEX ix_devices_store_id ON devices(store_id);
```

### 사용자 (User)

```sql
-- 역할
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  permissions_json JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 사용자
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  role_id UUID REFERENCES roles(id),
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  pin_hash TEXT,
  status entity_status NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX ix_users_store_id ON users(store_id);
CREATE UNIQUE INDEX ux_users_phone ON users(store_id, phone) WHERE phone IS NOT NULL AND deleted_at IS NULL;

-- 근무/시재
CREATE TABLE shifts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  device_id UUID REFERENCES devices(id),
  opened_by UUID REFERENCES users(id),
  opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  closed_by UUID REFERENCES users(id),
  closed_at TIMESTAMPTZ,
  cash_open NUMERIC(12,2) DEFAULT 0,
  cash_close NUMERIC(12,2),
  cash_sales NUMERIC(12,2) DEFAULT 0,
  card_sales NUMERIC(12,2) DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_shifts_store_id ON shifts(store_id);
```

### 메뉴 (Menu)

```sql
-- 카테고리
CREATE TABLE menu_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES menu_categories(id),
  name TEXT NOT NULL,
  color TEXT DEFAULT '#333333',
  sort_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX ix_menu_categories_store_id ON menu_categories(store_id);

-- 메뉴 아이템
CREATE TABLE menu_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  category_id UUID REFERENCES menu_categories(id),
  name TEXT NOT NULL,
  description TEXT,
  sku TEXT,
  barcode TEXT,
  price NUMERIC(12,2) NOT NULL,
  cost_price NUMERIC(12,2),
  tax_type tax_type NOT NULL DEFAULT 'TAXABLE',
  image_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  is_sold_out BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX ix_menu_items_store_id ON menu_items(store_id);
CREATE INDEX ix_menu_items_category_id ON menu_items(category_id);
CREATE UNIQUE INDEX ux_menu_items_sku ON menu_items(store_id, sku) WHERE sku IS NOT NULL AND deleted_at IS NULL;
CREATE UNIQUE INDEX ux_menu_items_barcode ON menu_items(store_id, barcode) WHERE barcode IS NOT NULL AND deleted_at IS NULL;

-- 세트 메뉴
CREATE TABLE menu_sets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  category_id UUID REFERENCES menu_categories(id),
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC(12,2) NOT NULL,
  discount_amount NUMERIC(12,2) DEFAULT 0,
  image_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- 세트 구성 아이템
CREATE TABLE menu_set_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  set_id UUID NOT NULL REFERENCES menu_sets(id) ON DELETE CASCADE,
  item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
  qty INT NOT NULL DEFAULT 1,
  is_required BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 옵션 그룹
CREATE TABLE menu_option_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  min_select INT NOT NULL DEFAULT 0,
  max_select INT NOT NULL DEFAULT 1,
  is_required BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 옵션
CREATE TABLE menu_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES menu_option_groups(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  price_delta NUMERIC(12,2) NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 메뉴-옵션그룹 연결
CREATE TABLE menu_item_option_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
  group_id UUID NOT NULL REFERENCES menu_option_groups(id) ON DELETE CASCADE,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (item_id, group_id)
);

-- 가격 규칙
CREATE TABLE price_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  item_id UUID REFERENCES menu_items(id) ON DELETE CASCADE,
  rule_type TEXT NOT NULL,
  start_at TIMESTAMPTZ,
  end_at TIMESTAMPTZ,
  price NUMERIC(12,2) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 테이블 (Table)

```sql
-- 구역
CREATE TABLE table_zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 테이블
CREATE TABLE tables (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  zone_id UUID REFERENCES table_zones(id),
  name TEXT NOT NULL,
  capacity INT NOT NULL DEFAULT 0,
  pos_x NUMERIC(10,2) NOT NULL DEFAULT 0,
  pos_y NUMERIC(10,2) NOT NULL DEFAULT 0,
  width NUMERIC(10,2) NOT NULL DEFAULT 80,
  height NUMERIC(10,2) NOT NULL DEFAULT 80,
  shape table_shape NOT NULL DEFAULT 'RECT',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  current_order_id UUID,
  version INT NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_tables_store_id ON tables(store_id);

-- QR 코드
CREATE TABLE qr_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  table_id UUID REFERENCES tables(id),
  code TEXT NOT NULL,
  type qr_type NOT NULL DEFAULT 'TABLE_ORDER',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX ux_qr_codes_code ON qr_codes(code);
```

### 주문 (Order)

```sql
-- 주문
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  device_id UUID REFERENCES devices(id),
  table_id UUID REFERENCES tables(id),
  customer_id UUID,
  order_no TEXT NOT NULL,
  status order_status NOT NULL DEFAULT 'OPEN',
  channel order_channel NOT NULL DEFAULT 'POS',
  subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
  discount NUMERIC(12,2) NOT NULL DEFAULT 0,
  coupon_discount NUMERIC(12,2) NOT NULL DEFAULT 0,
  tax NUMERIC(12,2) NOT NULL DEFAULT 0,
  total NUMERIC(12,2) NOT NULL DEFAULT 0,
  paid_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  change_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  note TEXT,
  version INT NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  closed_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX ux_orders_order_no ON orders(store_id, order_no);
CREATE INDEX ix_orders_store_id ON orders(store_id);
CREATE INDEX ix_orders_status ON orders(status);
CREATE INDEX ix_orders_created_at ON orders(created_at);

-- 주문 항목
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  item_id UUID REFERENCES menu_items(id),
  set_id UUID REFERENCES menu_sets(id),
  name_snapshot TEXT NOT NULL,
  qty INT NOT NULL DEFAULT 1,
  unit_price NUMERIC(12,2) NOT NULL,
  total_price NUMERIC(12,2) NOT NULL,
  status order_item_status NOT NULL DEFAULT 'ORDERED',
  note TEXT,
  sent_to_kitchen_at TIMESTAMPTZ,
  served_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_order_items_order_id ON order_items(order_id);

-- 주문 항목 옵션
CREATE TABLE order_item_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_item_id UUID NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
  option_id UUID REFERENCES menu_options(id),
  name_snapshot TEXT NOT NULL,
  price_delta NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 결제 (Payment)

```sql
-- 결제
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  method payment_method NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  status payment_status NOT NULL DEFAULT 'PENDING',
  approved_at TIMESTAMPTZ,
  van_provider TEXT,
  van_tx_id TEXT,
  card_brand TEXT,
  card_number_masked TEXT,
  approval_code TEXT,
  installment_months INT DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_payments_order_id ON payments(order_id);
CREATE INDEX ix_payments_van_tx_id ON payments(van_tx_id) WHERE van_tx_id IS NOT NULL;

-- 결제 시도 기록
CREATE TABLE payment_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  request_payload JSONB,
  response_payload JSONB,
  status payment_status NOT NULL,
  error_code TEXT,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 환불
CREATE TABLE refunds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  amount NUMERIC(12,2) NOT NULL,
  reason TEXT,
  status TEXT NOT NULL DEFAULT 'REQUESTED',
  approved_at TIMESTAMPTZ,
  van_tx_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 영수증
CREATE TABLE receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  receipt_no TEXT NOT NULL,
  type receipt_type NOT NULL DEFAULT 'CUSTOMER',
  printed_at TIMESTAMPTZ,
  printer_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 재고 (Inventory)

```sql
-- 재고 품목
CREATE TABLE inventory_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  sku TEXT,
  unit TEXT,
  current_qty NUMERIC(12,3) NOT NULL DEFAULT 0,
  min_qty NUMERIC(12,3),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_inventory_items_store_id ON inventory_items(store_id);

-- 재고 이동
CREATE TABLE stock_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  inventory_item_id UUID NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
  type stock_movement_type NOT NULL,
  qty NUMERIC(12,3) NOT NULL,
  reason TEXT,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 고객/마케팅 (Customer/Marketing)

```sql
-- 고객
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  franchise_id UUID REFERENCES franchises(id),
  phone TEXT,
  name TEXT,
  email TEXT,
  points INT NOT NULL DEFAULT 0,
  total_spent NUMERIC(12,2) NOT NULL DEFAULT 0,
  visit_count INT NOT NULL DEFAULT 0,
  last_visit_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX ix_customers_store_id ON customers(store_id);
CREATE INDEX ix_customers_phone ON customers(phone) WHERE phone IS NOT NULL;

-- 포인트 거래
CREATE TABLE loyalty_txns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
  points INT NOT NULL,
  type loyalty_txn_type NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 쿠폰
CREATE TABLE coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  franchise_id UUID REFERENCES franchises(id),
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  type coupon_type NOT NULL,
  value NUMERIC(12,2) NOT NULL,
  min_order_amount NUMERIC(12,2) DEFAULT 0,
  max_discount NUMERIC(12,2),
  valid_from TIMESTAMPTZ NOT NULL,
  valid_until TIMESTAMPTZ NOT NULL,
  usage_limit INT,
  usage_count INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX ux_coupons_code ON coupons(code);

-- 쿠폰 사용 이력
CREATE TABLE coupon_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  customer_id UUID REFERENCES customers(id),
  discount_amount NUMERIC(12,2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 시스템 (System)

```sql
-- 감사 로그
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE SET NULL,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  device_id UUID REFERENCES devices(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  before_data JSONB,
  after_data JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_audit_logs_store_id ON audit_logs(store_id);
CREATE INDEX ix_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX ix_audit_logs_entity ON audit_logs(entity_type, entity_id);
```

## 4. 트리거

```sql
-- updated_at 자동 업데이트 함수
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 주요 테이블에 트리거 적용
CREATE TRIGGER trg_stores_updated_at
  BEFORE UPDATE ON stores
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_devices_updated_at
  BEFORE UPDATE ON devices
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_menu_items_updated_at
  BEFORE UPDATE ON menu_items
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_menu_categories_updated_at
  BEFORE UPDATE ON menu_categories
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_tables_updated_at
  BEFORE UPDATE ON tables
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_customers_updated_at
  BEFORE UPDATE ON customers
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

## 5. 인덱스 요약

| 테이블 | 인덱스 | 용도 |
|--------|--------|------|
| stores | ux_stores_code | 매장 코드 유니크 |
| devices | ux_devices_code | 디바이스 코드 유니크 |
| orders | ux_orders_order_no | 주문번호 유니크 (매장별) |
| orders | ix_orders_status | 상태별 조회 |
| orders | ix_orders_created_at | 날짜별 조회 |
| menu_items | ux_menu_items_sku | SKU 유니크 (매장별) |
| menu_items | ux_menu_items_barcode | 바코드 유니크 (매장별) |
| coupons | ux_coupons_code | 쿠폰 코드 유니크 |
| qr_codes | ux_qr_codes_code | QR 코드 유니크 |

## 6. Prisma 스키마 파일 위치

```
apps/api/prisma/schema.prisma
```

## 7. 마이그레이션 명령어

```bash
# 스키마 변경 후 마이그레이션 생성
npx prisma migrate dev --name <migration_name>

# 프로덕션 마이그레이션
npx prisma migrate deploy

# Prisma Client 재생성
npx prisma generate
```

---

*문서 버전: v1.1 (2026-02-05 업데이트)*
