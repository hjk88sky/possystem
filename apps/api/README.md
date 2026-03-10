# POS API (NestJS)

## 1. 실행
- 개발 모드: `npm run dev`
- 빌드: `npm run build`
- 실행: `npm run start`

## 2. 환경변수
- `PORT` (기본 3000)
- `DATABASE_URL` (PostgreSQL 접속 문자열)

## 3. 상태 확인
- `GET /v1/health`

## 4. 실시간 동기화
- WebSocket namespace: `/realtime`
- 연결 후 `store.subscribe` 이벤트로 `{ "storeId": "<store-id>" }` 전송
- 같은 매장(room)으로 주문/결제/테이블/디바이스/메뉴 변경 이벤트가 브로드캐스트됨
- 모든 이벤트는 개별 이벤트명과 `store.event` 공통 채널로 동시에 수신 가능

## 5. DB 마이그레이션/시드
- 마이그레이션 적용: `npx prisma migrate dev`
- 프로덕션 적용: `npx prisma migrate deploy`
- 시드 실행: `npm run db:seed`

---

다음 단계에서 DB 연결 설정과 도메인 모듈을 추가합니다.
