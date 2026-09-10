# Windows 플레이 테스트 10 — 빌라 건물 연결과 주차선 마감

2026-09-10-villa-10 · Windows x86_64 · Godot 4.7.1 debug export

## 변경

- 승용차 아래 반복 줄무늬를 차량 방향에 맞는 열린 주차 구획으로 교체했다. 트럭 주차선 길이와 후면 위치를 차량에 맞췄다. 도로 교차부의 겹치는 차선을 비웠다.
- 노출 계단에 외벽과 지붕을 추가해 계단실로 구성했다. 골목 입구와 위층 출구는 운반 공간을 확보한 개방 출입구로 연결한다.
- 위층 L자 복도의 남쪽 열린 끝과 현관 북쪽 벽 접합부를 막았다. 벽과 천장은 실제 충돌을 갖는다.
- 계단실 창 형태 장식·층 안내, 출입구 테두리와 실내 조명을 추가했다. 창은 통과하거나 여는 창이 아닌 장식이다.
- 기존 Kenney 차량·건물·소품 및 캐릭터를 유지한다. 새 외부 에셋 구매나 기능 범위 확대는 없다.

## 검증

- 초기 진입부 벽에 택배가 걸리는 실패를 확인하고 입구 공간을 넓혔다. 중간 기록: validation/villa-10/BeforeEntranceClearance.log.
- 수정 후 소스 Route 15개 통과, 재잡기 없이 배송 완료. 해당 소스 실행 종료 시 ObjectDB 누수 경고가 콘솔에 있었으므로 무경고 통과로 취급하지 않는다.
- 최종 Windows BuildVisual: 119개 통과. 새 계단실 외벽·지붕과 복도 끝의 물리 Ray 4개 검사 포함. 캐릭터 18종, 팔 자세, 목표·HUD·완료·복구·재시작·메뉴 회귀 포함.
- Windows 렌더링의 전체 맵 및 위층 복도 캡처를 직접 검토했다. 자동 이동 검사는 사람이 직접 플레이한 평가와 구분한다.
- 최종 운반 검사 및 압축 인수 결과는 아래에 기록한다.

## 알려진 한계와 다음 작업

다른 PC/GPU, 장시간 플레이, 모든 우회 동선은 미검증이다. 벽·차량은 단순 충돌체이며 창은 장식이다. 물리 접촉으로 물건을 놓치면 다시 잡기 또는 F5 복구가 가능하다.

사용자 확인: 주차 구획의 방향과 간격, 계단실 입구 인지, 내부 밝기, 계단 회전 및 위층 코너의 택배 끼임, 현관 배송 후 재시작.

다음 작업도 현재 빌라 맵 마감이다. 사용자 플레이에서 남은 접합부·동선·가독성을 우선 수정한다. 두 번째 레벨·온라인 협동·차량 운전은 후속 범위로 유지한다. 기존 미커밋 변경·이전 빌드는 보존했으며 commit/push하지 않았다.

## 실행

builds/HellDelivery-2026-09-10-villa-10.zip 전체 압축 해제 후 HellDelivery.exe 실행. PCK 동봉 필요.
재현: tools/Run-Godot.ps1 -Mode Export / BuildVisual / BuildRouteVisual.

## 최종 Windows 결과
BuildVisual EXIT 0 checks=119 failures=0. BuildRouteVisual EXIT 0 checks=15 failures=0, 재잡기 없이 배송 완료. 최종 export 및 두 Windows 검사 로그에 SCRIPT ERROR/ERROR/WARNING 없음. 16-stairwell-interior.png의 창 장식·층 안내도 직접 확인. git diff --check 통과.


압축 인수: 30개 파일 SHA-256 일치. 별도 압축 해제 EXE 메뉴 headless smoke exit 0, 오류·경고 없음. ZIP 39146628 bytes. SHA-256: 426114837CFF23466BB9A2A9642D26E84AEA0082227061C57029B1C6FF331FA6. 이 기록은 저장소에만 추가한다.
