# POS API 명세 (v1.1)

## 1. 공통 규칙

### Base URL
- 개발: `http://localhost:3000/v1`
- 운영: `https://api.pos.example.com/v1`

### 인증
- Bearer Token (JWT)
- Access Token 만료: 1시간
- Refresh Token 만료: 7일

### 헤더
```
Authorization: Bearer {access_token}
X-Store-Id: {store_uuid}           # 멀티 매장 스코프
X-Device-Id: {device_uuid}         # POS 디바이스 식별
Content-Type: application/json
```

### 날짜/시간
- ISO 8601 형식: `2026-02-05T09:30:00+09:00`
- 타임존: 서버는 UTC 저장, 응답 시 매장 타임존 변환

### 동시성 처리
- `version` 필드를 사용한 Optimistic Locking
- 불일치 시 `409 Conflict` 응답

### 페이지네이션
```json
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "hasNext": true
  }
}
```

### 에러 응답
```json
{
  "error": {
    "code": "ORD-001",
    "message": "Order not found",
    "details": {}
  }
}
```

### 에러 코드 체계
| 접두사 | 영역 |
|--------|------|
| AUTH | 인증/권한 |
| STR | 매장 |
| MNU | 메뉴 |
| ORD | 주문 |
| PAY | 결제 |
| TBL | 테이블 |
| INV | 재고 |
| CUS | 고객 |

---

## 2. 인증/권한

### POST /v1/auth/login
직원 로그인 (PIN 또는 비밀번호)
```json
// Request
{
  "store_code": "STORE001",
  "phone": "01012345678",
  "pin": "1234"
}

// Response 200
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": {
    "id": "uuid",
    "name": "홍길동",
    "role": "CASHIER"
  },
  "store": {
    "id": "uuid",
    "name": "강남점"
  }
}
```

### POST /v1/auth/refresh
토큰 갱신
```json
// Request
{
  "refresh_token": "eyJ..."
}

// Response 200
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ..."
}
```

### GET /v1/me
현재 사용자 정보

### POST /v1/auth/logout
로그아웃

---

## 3. 매장/본사

### GET /v1/franchises
본사 목록 (본사 관리자용)

### GET /v1/stores
매장 목록
```json
// Response 200
{
  "data": [
    {
      "id": "uuid",
      "name": "강남점",
      "code": "STORE001",
      "address": "서울시 강남구...",
      "status": "ACTIVE",
      "van_provider": "KFTC"
    }
  ]
}
```

### POST /v1/stores
매장 생성 (본사 관리자)

### GET /v1/stores/{id}
매장 상세

### PATCH /v1/stores/{id}
매장 수정

---

## 4. 디바이스

### POST /v1/devices/register
디바이스 등록
```json
// Request
{
  "store_id": "uuid",
  "device_code": "POS-001",
  "device_name": "계산대1",
  "type": "POS",
  "os": "WINDOWS",
  "app_version": "1.0.0",
  "hardware_model": "POSBANK A11"
}

// Response 201
{
  "id": "uuid",
  "device_code": "POS-001",
  "status": "ACTIVE"
}
```

### GET /v1/devices
디바이스 목록

### PATCH /v1/devices/{id}
디바이스 수정

### POST /v1/devices/{id}/heartbeat
디바이스 상태 보고 (1분마다)
```json
// Request
{
  "app_version": "1.0.0",
  "is_online": true,
  "last_sync_at": "2026-02-05T09:30:00+09:00"
}
```

---

## 5. 메뉴

### GET /v1/menu/categories
카테고리 목록
```json
// Response 200
{
  "data": [
    {
      "id": "uuid",
      "name": "커피",
      "sort_order": 1,
      "color": "#8B4513",
      "is_active": true,
      "item_count": 15
    }
  ]
}
```

### POST /v1/menu/categories
카테고리 생성

### PATCH /v1/menu/categories/{id}
카테고리 수정

### DELETE /v1/menu/categories/{id}
카테고리 삭제 (소프트)

---

### GET /v1/menu/items
메뉴 아이템 목록
```json
// Query params
?category_id=uuid
&is_active=true
&search=아메리카노

// Response 200
{
  "data": [
    {
      "id": "uuid",
      "name": "아메리카노",
      "price": 4500,
      "category_id": "uuid",
      "sku": "CF001",
      "barcode": "8801234567890",
      "is_active": true,
      "is_sold_out": false,
      "image_url": "https://...",
      "option_groups": [
        {
          "id": "uuid",
          "name": "사이즈",
          "is_required": true,
          "options": [
            {"id": "uuid", "name": "Tall", "price_delta": 0},
            {"id": "uuid", "name": "Grande", "price_delta": 500}
          ]
        }
      ]
    }
  ]
}
```

### POST /v1/menu/items
메뉴 아이템 생성

### GET /v1/menu/items/{id}
메뉴 아이템 상세

### PATCH /v1/menu/items/{id}
메뉴 아이템 수정

### DELETE /v1/menu/items/{id}
메뉴 아이템 삭제 (소프트)

### PATCH /v1/menu/items/{id}/sold-out
품절 상태 변경
```json
// Request
{
  "is_sold_out": true
}
```

---

### GET /v1/menu/option-groups
옵션 그룹 목록

### POST /v1/menu/option-groups
옵션 그룹 생성

### PATCH /v1/menu/option-groups/{id}
옵션 그룹 수정

---

### GET /v1/menu/sets
세트 메뉴 목록

### POST /v1/menu/sets
세트 메뉴 생성
```json
// Request
{
  "name": "모닝 세트",
  "description": "아메리카노 + 샌드위치",
  "price": 7000,
  "items": [
    {"item_id": "uuid", "qty": 1, "is_required": true},
    {"item_id": "uuid", "qty": 1, "is_required": true}
  ]
}
```

---

## 6. 테이블

### GET /v1/tables
테이블 목록 (좌석 배치 포함)
```json
// Response 200
{
  "data": [
    {
      "id": "uuid",
      "name": "A1",
      "zone": {"id": "uuid", "name": "홀"},
      "capacity": 4,
      "pos_x": 100,
      "pos_y": 200,
      "width": 80,
      "height": 80,
      "shape": "RECT",
      "is_active": true,
      "current_order": {
        "id": "uuid",
        "order_no": "20260205-001",
        "total": 25000,
        "status": "OPEN"
      }
    }
  ]
}
```

### POST /v1/tables
테이블 생성

### PATCH /v1/tables/{id}
테이블 수정

### POST /v1/tables/layout
대량 위치 변경 (드래그앤드롭 저장)
```json
// Request
{
  "tables": [
    {"id": "uuid", "pos_x": 100, "pos_y": 200},
    {"id": "uuid", "pos_x": 200, "pos_y": 200}
  ]
}
```

---

## 7. 주문

### POST /v1/orders
주문 생성
```json
// Request
{
  "table_id": "uuid",
  "channel": "POS",
  "items": [
    {
      "item_id": "uuid",
      "qty": 2,
      "options": [
        {"option_id": "uuid"}
      ],
      "note": "얼음 적게"
    }
  ],
  "customer_id": "uuid",
  "note": "포장"
}

// Response 201
{
  "id": "uuid",
  "order_no": "20260205-001",
  "status": "OPEN",
  "subtotal": 9000,
  "discount": 0,
  "tax": 900,
  "total": 9900,
  "version": 1,
  "items": [...]
}
```

### GET /v1/orders
주문 목록
```json
// Query params
?status=OPEN,PAID
&date_from=2026-02-05
&date_to=2026-02-05
&table_id=uuid
```

### GET /v1/orders/{id}
주문 상세

### PATCH /v1/orders/{id}
주문 수정 (상태 변경 등)
```json
// Request
{
  "status": "PAID",
  "version": 1  // 필수: 동시성 체크
}

// Response 409 (버전 충돌)
{
  "error": {
    "code": "ORD-002",
    "message": "Order has been modified",
    "current_version": 2
  }
}
```

### POST /v1/orders/{id}/items
주문에 아이템 추가

### PATCH /v1/orders/{id}/items/{itemId}
주문 아이템 수정 (수량 변경 등)

### DELETE /v1/orders/{id}/items/{itemId}
주문 아이템 삭제

### POST /v1/orders/{id}/items/{itemId}/send-kitchen
주방으로 전송
```json
// Response 200
{
  "item_id": "uuid",
  "status": "COOKING",
  "sent_to_kitchen_at": "2026-02-05T09:30:00+09:00"
}
```

---

## 8. 결제

### POST /v1/orders/{id}/payments
결제 요청
```json
// Request (카드)
{
  "method": "CARD",
  "amount": 9900,
  "installment_months": 0
}

// Request (현금)
{
  "method": "CASH",
  "amount": 10000,
  "received_amount": 10000
}

// Response 200
{
  "id": "uuid",
  "method": "CARD",
  "amount": 9900,
  "status": "APPROVED",
  "approval_code": "12345678",
  "card_brand": "VISA",
  "card_number_masked": "****-****-****-1234",
  "van_tx_id": "KFTC20260205001"
}
```

### POST /v1/orders/{id}/refunds
환불/취소 요청
```json
// Request
{
  "payment_id": "uuid",
  "amount": 9900,
  "reason": "고객 요청"
}
```

### POST /v1/orders/{id}/close
주문 마감 (결제 완료 후)

---

## 9. VAN 결제 (KFTC 연동)

### POST /v1/van/approve
카드 승인 요청 (POS → 서버 → KFTC Agent)
```json
// Request
{
  "order_id": "uuid",
  "amount": 9900,
  "installment_months": 0,
  "card_data": {
    "track2": "encrypted_data",  // 카드리더 데이터
    "encryption_type": "KFTC"
  }
}

// Response 200
{
  "success": true,
  "approval_code": "12345678",
  "van_tx_id": "KFTC20260205001",
  "card_brand": "VISA",
  "card_number_masked": "****-****-****-1234",
  "merchant_name": "강남점"
}

// Response 400 (승인 거절)
{
  "success": false,
  "error_code": "C001",
  "error_message": "한도 초과"
}
```

### POST /v1/van/cancel
카드 취소 요청
```json
// Request
{
  "original_tx_id": "KFTC20260205001",
  "amount": 9900,
  "reason": "고객 요청"
}
```

### GET /v1/van/transactions/{id}
거래 조회

---

## 10. 영수증

### GET /v1/receipts/{id}
영수증 조회

### POST /v1/receipts/{id}/print
영수증 출력 요청
```json
// Request
{
  "printer_id": "PRINTER-001",
  "copies": 1,
  "type": "CUSTOMER"  // CUSTOMER, KITCHEN
}
```

### POST /v1/orders/{id}/receipts
영수증 생성 및 출력
```json
// Request
{
  "type": "CUSTOMER",
  "include_details": true
}
```

---

## 11. 재고

### GET /v1/inventory/items
재고 목록

### POST /v1/inventory/items
재고 품목 등록

### POST /v1/inventory/movements
입출고 등록
```json
// Request
{
  "inventory_item_id": "uuid",
  "type": "IN",
  "qty": 100,
  "reason": "입고"
}
```

---

## 12. 고객/포인트

### GET /v1/customers
고객 목록
```json
// Query params
?phone=01012345678
&search=홍길동
```

### POST /v1/customers
고객 등록

### GET /v1/customers/{id}
고객 상세 (포인트, 주문 이력)

### POST /v1/customers/{id}/points
포인트 적립/사용
```json
// Request
{
  "type": "EARN",
  "points": 100,
  "order_id": "uuid"
}
```

---

## 13. 쿠폰

### GET /v1/coupons
쿠폰 목록

### POST /v1/coupons
쿠폰 생성

### POST /v1/coupons/validate
쿠폰 유효성 검증
```json
// Request
{
  "code": "WELCOME10",
  "order_amount": 20000
}

// Response 200
{
  "valid": true,
  "coupon": {
    "id": "uuid",
    "name": "웰컴 10% 할인",
    "type": "PERCENT",
    "value": 10,
    "discount_amount": 2000
  }
}
```

### POST /v1/coupons/{id}/use
쿠폰 사용

---

## 14. 리포트

### GET /v1/reports/sales/daily
일별 매출
```json
// Query params
?date_from=2026-02-01
&date_to=2026-02-05

// Response 200
{
  "data": [
    {
      "date": "2026-02-05",
      "total_sales": 1500000,
      "card_sales": 1200000,
      "cash_sales": 300000,
      "order_count": 150,
      "refund_amount": 50000
    }
  ]
}
```

### GET /v1/reports/sales/items
메뉴별 매출

### GET /v1/reports/sales/hourly
시간대별 매출

### GET /v1/reports/payments
결제 수단별 통계

---

## 15. 동기화

### GET /v1/sync/changes
변경 사항 조회 (오프라인 복구용)
```json
// Query params
?since=2026-02-05T09:00:00Z
&entities=menu_items,menu_categories,tables

// Response 200
{
  "changes": [
    {
      "entity": "menu_items",
      "id": "uuid",
      "action": "UPDATE",
      "data": {...},
      "updated_at": "2026-02-05T09:30:00Z"
    }
  ],
  "server_time": "2026-02-05T10:00:00Z"
}
```

### POST /v1/sync/push
로컬 변경 업로드
```json
// Request
{
  "changes": [
    {
      "entity": "orders",
      "local_id": "local-uuid",
      "action": "CREATE",
      "data": {...},
      "created_at": "2026-02-05T09:30:00Z"
    }
  ]
}

// Response 200
{
  "results": [
    {
      "local_id": "local-uuid",
      "server_id": "uuid",
      "status": "SUCCESS"
    }
  ]
}
```

---

## 16. 실시간 이벤트 (WebSocket)

### 연결
```
WS /v1/ws/events
Authorization: Bearer {token}
X-Store-Id: {store_id}
X-Device-Id: {device_id}
```

### 이벤트 타입
```json
// 주문 생성
{
  "type": "order.created",
  "data": {
    "id": "uuid",
    "order_no": "20260205-001",
    "table_id": "uuid",
    "total": 9900
  },
  "timestamp": "2026-02-05T09:30:00Z"
}

// 주문 수정
{
  "type": "order.updated",
  "data": {...}
}

// 테이블 상태 변경
{
  "type": "table.updated",
  "data": {
    "id": "uuid",
    "current_order_id": "uuid"
  }
}

// 메뉴 변경 (품절 등)
{
  "type": "menu.updated",
  "data": {
    "id": "uuid",
    "is_sold_out": true
  }
}

// 디바이스 상태
{
  "type": "device.status",
  "data": {
    "id": "uuid",
    "status": "OFFLINE"
  }
}

// 주방 아이템 상태
{
  "type": "kitchen.item_updated",
  "data": {
    "order_id": "uuid",
    "item_id": "uuid",
    "status": "SERVED"
  }
}
```

---

*문서 버전: v1.1 (2026-02-05 업데이트)*
