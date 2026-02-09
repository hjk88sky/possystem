# POS 데이터 모델 (v1.1)

## 1. 설계 원칙
- 멀티테넌트 구조: 프랜차이즈(본사) → 매장 → 디바이스 계층
- 멀티 POS 동시성 대비: 주문/테이블은 `version` 필드로 충돌 감지
- 오프라인 대비: 주요 엔티티는 `updated_at` 기준 동기화 가능
- 소프트 삭제: 주요 엔티티는 `deleted_at` 필드로 복구 가능

## 2. 핵심 엔티티

### 조직/인증
- `Franchise`: 본사 정보
- `Store`: 매장 정보
- `Device`: POS/키오스크/디스플레이 장치
- `User`: 직원
- `Role`: 권한
- `Shift`: 근무 교대/시재

### 메뉴
- `MenuCategory`: 메뉴 카테고리
- `MenuItem`: 메뉴 아이템
- `MenuOptionGroup`: 옵션 그룹 (예: 사이즈, 토핑)
- `MenuOption`: 옵션 항목
- `MenuItemOptionGroup`: 메뉴-옵션 연결
- `MenuSet`: 세트 메뉴 (추가)
- `MenuSetItem`: 세트 구성 아이템 (추가)
- `PriceRule`: 시간대/특정 조건 가격

### 테이블/공간
- `TableZone`: 구역 (홀, 테라스 등)
- `Table`: 테이블
- `QrCode`: QR 테이블 오더용 (추가)

### 주문/결제
- `Order`: 주문
- `OrderItem`: 주문 항목
- `OrderItemOption`: 주문 항목 옵션
- `Payment`: 결제
- `PaymentAttempt`: VAN 결제 시도 기록
- `Refund`: 취소/환불
- `Receipt`: 영수증

### 재고
- `InventoryItem`: 재고 품목
- `StockMovement`: 입출고

### 고객/마케팅
- `Customer`: 고객
- `LoyaltyTxn`: 포인트 적립/사용
- `Coupon`: 쿠폰 정의 (추가)
- `CouponUsage`: 쿠폰 사용 이력 (추가)
- `Promotion`: 프로모션 (추가)

### 시스템
- `AuditLog`: 감사 로그 (추가)

## 3. 주요 필드 (상세)

### 조직
```
Franchise
├── id: uuid (PK)
├── name: string
├── status: enum (ACTIVE, INACTIVE)
├── created_at: timestamp
├── updated_at: timestamp
└── deleted_at: timestamp (nullable)

Store
├── id: uuid (PK)
├── franchise_id: uuid (FK, nullable - 단독 매장 가능)
├── name: string
├── code: string (unique)
├── address: string
├── business_number: string (사업자번호)
├── van_provider: string (KFTC, KIS, KPN)
├── van_merchant_id: string (가맹점 ID) -- 추가
├── status: enum (ACTIVE, INACTIVE)
├── timezone: string (default: Asia/Seoul) -- 추가
├── created_at: timestamp
├── updated_at: timestamp
└── deleted_at: timestamp (nullable)

Device
├── id: uuid (PK)
├── store_id: uuid (FK)
├── type: enum (POS, KIOSK, CUSTOMER_DISPLAY, KDS)
├── os: enum (WINDOWS, ANDROID)
├── device_code: string (unique)
├── device_name: string -- 추가
├── app_version: string -- 추가
├── hardware_model: string -- 추가
├── last_seen_at: timestamp
├── status: enum (ACTIVE, INACTIVE, OFFLINE)
├── config_json: jsonb
├── created_at: timestamp
└── updated_at: timestamp
```

### 사용자
```
User
├── id: uuid (PK)
├── store_id: uuid (FK)
├── role_id: uuid (FK)
├── name: string
├── phone: string
├── email: string -- 추가
├── pin_hash: string (4자리 PIN)
├── status: enum (ACTIVE, INACTIVE)
├── created_at: timestamp
├── updated_at: timestamp
└── deleted_at: timestamp (nullable)

Role
├── id: uuid (PK)
├── store_id: uuid (FK, nullable - 전역 역할 가능)
├── name: string
├── permissions_json: jsonb
├── created_at: timestamp
└── updated_at: timestamp

Shift
├── id: uuid (PK)
├── store_id: uuid (FK)
├── device_id: uuid (FK) -- 추가
├── opened_by: uuid (FK -> User)
├── opened_at: timestamp
├── closed_by: uuid (FK -> User, nullable)
├── closed_at: timestamp (nullable)
├── cash_open: decimal
├── cash_close: decimal (nullable)
├── cash_sales: decimal -- 추가
├── card_sales: decimal -- 추가
├── created_at: timestamp
└── updated_at: timestamp
```

### 메뉴
```
MenuCategory
├── id: uuid (PK)
├── store_id: uuid (FK)
├── parent_id: uuid (FK, nullable - 서브카테고리) -- 추가
├── name: string
├── sort_order: int
├── color: string -- 추가 (UI 표시용)
├── is_active: boolean
├── created_at: timestamp
├── updated_at: timestamp
└── deleted_at: timestamp (nullable)

MenuItem
├── id: uuid (PK)
├── store_id: uuid (FK)
├── category_id: uuid (FK)
├── name: string
├── description: string -- 추가
├── sku: string (unique per store)
├── barcode: string (unique per store)
├── price: decimal
├── cost_price: decimal -- 추가 (원가)
├── tax_type: enum (TAXABLE, ZERO, EXEMPT)
├── image_url: string -- 추가
├── is_active: boolean
├── is_sold_out: boolean -- 추가
├── sort_order: int -- 추가
├── created_at: timestamp
├── updated_at: timestamp
└── deleted_at: timestamp (nullable)

MenuSet (추가)
├── id: uuid (PK)
├── store_id: uuid (FK)
├── name: string
├── description: string
├── price: decimal
├── discount_amount: decimal (단품 대비 할인)
├── is_active: boolean
├── created_at: timestamp
└── updated_at: timestamp

MenuSetItem (추가)
├── id: uuid (PK)
├── set_id: uuid (FK -> MenuSet)
├── item_id: uuid (FK -> MenuItem)
├── qty: int (default: 1)
├── is_required: boolean
└── sort_order: int

MenuOptionGroup
├── id: uuid (PK)
├── store_id: uuid (FK)
├── name: string
├── min_select: int (최소 선택)
├── max_select: int (최대 선택)
├── is_required: boolean
├── created_at: timestamp
└── updated_at: timestamp

MenuOption
├── id: uuid (PK)
├── group_id: uuid (FK)
├── name: string
├── price_delta: decimal (추가 금액)
├── is_active: boolean
├── is_default: boolean -- 추가
├── sort_order: int -- 추가
├── created_at: timestamp
└── updated_at: timestamp
```

### 테이블
```
TableZone
├── id: uuid (PK)
├── store_id: uuid (FK)
├── name: string
├── sort_order: int
├── created_at: timestamp
└── updated_at: timestamp

Table
├── id: uuid (PK)
├── store_id: uuid (FK)
├── zone_id: uuid (FK, nullable)
├── name: string
├── capacity: int
├── pos_x: decimal (배치 좌표)
├── pos_y: decimal
├── width: decimal -- 추가
├── height: decimal -- 추가
├── shape: enum (RECT, CIRCLE) -- 추가
├── is_active: boolean
├── current_order_id: uuid (FK, nullable) -- 추가 (현재 진행 주문)
├── created_at: timestamp
└── updated_at: timestamp

QrCode (추가)
├── id: uuid (PK)
├── store_id: uuid (FK)
├── table_id: uuid (FK, nullable)
├── code: string (unique)
├── type: enum (TABLE_ORDER, PICKUP)
├── is_active: boolean
├── created_at: timestamp
└── expires_at: timestamp (nullable)
```

### 주문
```
Order
├── id: uuid (PK)
├── store_id: uuid (FK)
├── device_id: uuid (FK)
├── table_id: uuid (FK, nullable)
├── customer_id: uuid (FK, nullable) -- 추가
├── order_no: string (매장 단위 unique)
├── status: enum (OPEN, PAID, CANCELLED, VOID)
├── channel: enum (POS, KIOSK, QR, DELIVERY)
├── subtotal: decimal
├── discount: decimal
├── coupon_discount: decimal -- 추가
├── tax: decimal
├── total: decimal
├── paid_amount: decimal -- 추가
├── change_amount: decimal -- 추가
├── note: string -- 추가 (주문 메모)
├── version: int (동시성 제어)
├── created_at: timestamp
├── updated_at: timestamp
└── closed_at: timestamp (nullable)

OrderItem
├── id: uuid (PK)
├── order_id: uuid (FK)
├── item_id: uuid (FK -> MenuItem)
├── set_id: uuid (FK -> MenuSet, nullable) -- 추가
├── name_snapshot: string
├── qty: int
├── unit_price: decimal
├── total_price: decimal
├── status: enum (ORDERED, COOKING, SERVED, CANCELLED) -- ENUM 추가
├── sent_to_kitchen_at: timestamp -- 추가
├── served_at: timestamp -- 추가
├── created_at: timestamp
└── updated_at: timestamp

OrderItemOption
├── id: uuid (PK)
├── order_item_id: uuid (FK)
├── option_id: uuid (FK)
├── name_snapshot: string
├── price_delta: decimal
├── created_at: timestamp
└── updated_at: timestamp
```

### 결제
```
Payment
├── id: uuid (PK)
├── order_id: uuid (FK)
├── method: enum (CARD, CASH, TRANSFER, POINT, OTHER)
├── amount: decimal
├── status: enum (PENDING, APPROVED, DECLINED, CANCELLED)
├── approved_at: timestamp
├── van_provider: string -- 추가
├── van_tx_id: string
├── card_brand: string (VISA, MASTER, etc)
├── card_number_masked: string -- 추가 (****-****-****-1234)
├── approval_code: string
├── installment_months: int -- 추가 (할부 개월)
├── created_at: timestamp
└── updated_at: timestamp

PaymentAttempt
├── id: uuid (PK)
├── payment_id: uuid (FK)
├── request_payload: jsonb
├── response_payload: jsonb
├── status: enum
├── error_code: string -- 추가
├── error_message: string -- 추가
└── created_at: timestamp

Refund
├── id: uuid (PK)
├── payment_id: uuid (FK)
├── amount: decimal
├── reason: string
├── status: enum (REQUESTED, APPROVED, DECLINED)
├── approved_at: timestamp
├── van_tx_id: string -- 추가
└── created_at: timestamp

Receipt
├── id: uuid (PK)
├── order_id: uuid (FK)
├── receipt_no: string
├── type: enum (CUSTOMER, KITCHEN, PICKUP) -- 추가
├── printed_at: timestamp
├── printer_id: string -- 추가
└── created_at: timestamp
```

### 고객/마케팅
```
Customer
├── id: uuid (PK)
├── store_id: uuid (FK, nullable - 프랜차이즈 통합 시)
├── franchise_id: uuid (FK, nullable) -- 추가
├── phone: string
├── name: string
├── email: string -- 추가
├── points: int
├── total_spent: decimal -- 추가
├── visit_count: int -- 추가
├── last_visit_at: timestamp -- 추가
├── created_at: timestamp
├── updated_at: timestamp
└── deleted_at: timestamp (nullable)

LoyaltyTxn
├── id: uuid (PK)
├── customer_id: uuid (FK)
├── order_id: uuid (FK, nullable)
├── points: int
├── type: enum (EARN, REDEEM, EXPIRE, ADJUST)
├── description: string -- 추가
└── created_at: timestamp

Coupon (추가)
├── id: uuid (PK)
├── store_id: uuid (FK, nullable)
├── franchise_id: uuid (FK, nullable)
├── code: string (unique)
├── name: string
├── type: enum (FIXED, PERCENT, FREE_ITEM)
├── value: decimal
├── min_order_amount: decimal
├── max_discount: decimal (nullable)
├── valid_from: timestamp
├── valid_until: timestamp
├── usage_limit: int (nullable)
├── usage_count: int
├── is_active: boolean
├── created_at: timestamp
└── updated_at: timestamp

CouponUsage (추가)
├── id: uuid (PK)
├── coupon_id: uuid (FK)
├── order_id: uuid (FK)
├── customer_id: uuid (FK, nullable)
├── discount_amount: decimal
└── created_at: timestamp
```

### 시스템
```
AuditLog (추가)
├── id: uuid (PK)
├── store_id: uuid (FK)
├── user_id: uuid (FK)
├── action: string (CREATE, UPDATE, DELETE, LOGIN, LOGOUT, etc)
├── entity_type: string (Order, MenuItem, etc)
├── entity_id: uuid
├── before_data: jsonb
├── after_data: jsonb
├── ip_address: string
├── device_id: uuid
└── created_at: timestamp
```

## 4. 관계 요약
```
Franchise 1:N Store
Store 1:N Device, User, Menu*, Order, Table
Order 1:N OrderItem
OrderItem 1:N OrderItemOption
Order 1:N Payment
Payment 1:N Refund, PaymentAttempt
Customer 1:N LoyaltyTxn, Order
Coupon 1:N CouponUsage
MenuSet 1:N MenuSetItem
```

## 5. 동시성/동기화 규칙
- `Order.version` 증가로 동시 수정 충돌 감지
- `updated_at` 기반 증분 동기화(웹 관리자 ↔ POS)
- 충돌 발생 시 서버 기준 최신 버전 반환 + 클라이언트 재시도
- 소프트 삭제(`deleted_at`)로 데이터 복구 가능

## 6. 인덱스/제약 (필수)
- `stores.code` UNIQUE
- `devices.device_code` UNIQUE
- `orders(store_id, order_no)` UNIQUE
- `menu_items(store_id, sku)` UNIQUE WHERE sku IS NOT NULL
- `menu_items(store_id, barcode)` UNIQUE WHERE barcode IS NOT NULL
- `coupons.code` UNIQUE
- `qr_codes.code` UNIQUE

## 7. ENUM 정의 (전체)
```sql
device_type: POS, KIOSK, CUSTOMER_DISPLAY, KDS
device_os: WINDOWS, ANDROID
order_status: OPEN, PAID, CANCELLED, VOID
order_channel: POS, KIOSK, QR, DELIVERY
order_item_status: ORDERED, COOKING, SERVED, CANCELLED
payment_method: CARD, CASH, TRANSFER, POINT, OTHER
payment_status: PENDING, APPROVED, DECLINED, CANCELLED
stock_movement_type: IN, OUT, ADJUST
loyalty_txn_type: EARN, REDEEM, EXPIRE, ADJUST
tax_type: TAXABLE, ZERO, EXEMPT
coupon_type: FIXED, PERCENT, FREE_ITEM
receipt_type: CUSTOMER, KITCHEN, PICKUP
table_shape: RECT, CIRCLE
qr_type: TABLE_ORDER, PICKUP
```

---

*문서 버전: v1.1 (2026-02-05 업데이트)*
