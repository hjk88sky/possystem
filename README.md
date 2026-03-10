# POS System

로컬 개발 기준 실행 순서입니다.

## API 서버

작업 폴더: `apps/api`

```powershell
cd apps/api
npm install
npx prisma migrate deploy
npm run db:seed
npm run start
```

기본 주소:
- API: `http://localhost:3000/v1`
- Health: `http://localhost:3000/v1/health`

데모 로그인:
- 매장 코드: `STORE001`
- 전화번호: `01012345678`
- PIN: `1234`

## POS 앱

작업 폴더: `apps/pos`

정적 검증:

```powershell
cd apps/pos
flutter pub get
dart analyze lib test
flutter test
```

Windows 실행:

```powershell
cd apps/pos
flutter run -d windows
flutter build windows
```

필수 조건:
- Flutter SDK
- Visual Studio C++ 데스크톱 구성요소
- Windows Developer Mode
- PostgreSQL

## 현재 구현 상태

완료:
- 로그인 / 토큰 갱신
- 메뉴 조회
- 주문 생성
- 결제 mock 처리
- 디바이스 등록 / 하트비트
- 매장 단위 실시간 이벤트
- 매출 요약 API

남은 항목:
- KFTC 실제 결제 연동
- POSBANK A11 프린터 연동
- 오프라인 캐시 / 복구 동기화
- 백오피스 웹 관리자
- Android 실행 환경
