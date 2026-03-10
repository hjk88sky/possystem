# POS Flutter App

Windows/Android POS 클라이언트입니다.

## 로컬 검증

```powershell
flutter pub get
dart analyze lib test
flutter test
```

## API 기본 주소

- `http://localhost:3000/v1`

## 연결 기능

- 로그인 / 토큰 갱신
- 메뉴 조회
- 주문 생성
- 결제 처리
- 디바이스 등록 / 하트비트
- 매장 단위 실시간 이벤트 수신

## Windows 실행 조건

- Flutter SDK
- Visual Studio Build Tools 또는 Visual Studio
- Desktop development with C++ 구성요소
- Windows Developer Mode
