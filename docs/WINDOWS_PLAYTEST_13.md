# Windows 플레이 테스트 13 — 2층 호수 정정·기준 빌드 안정화

2026-09-10-villa-13 · Windows x86_64 · Godot 4.7.1 debug export

## 변경 및 다음 단계 진행

- 사용자 확인: villa-12의 입구·난간·바닥 접합부 수정은 수용되었고, 2층 호수는 200번대여야 한다.
- 배송 세대 101→201, 이웃 세대 102→202, 복도 방향 표지를 201호로 정정했다.
- DeliveryZone.destination_name을 ‘언덕 빌라 2층 201호’로 설정해 HUD·목표 마커·조작/온보딩 안내가 같은 목적지를 사용한다. 과거 빌드 보고서의 호수는 당시 기록으로 보존한다.
- 다음 단계로 현재 맵의 기준 빌드 안정화를 수행한다. 기존 회귀·전체 배송 입력 경로, 별도 프로세스 설정 저장/읽기, 출발 지점 및 새 계단실·복도 성능 표본을 검사한다.
- 새 기능을 추가하기보다 사용자가 확인한 현재 맵을 기준으로 작업 상태를 정리한다. 온라인 협동·차량 운전·새 레벨은 이번 작업에 포함하지 않는다.

## 검증 구분

자동 입력 검사와 화면 캡처 검토는 사용자 직접 플레이와 구분한다. 사용자 설정 파일은 덮어쓰지 않고 저장/읽기는 검사 전용 파일을 사용한다. 성능은 현재 PC에서 각 장면 600프레임의 짧은 표본이며 장시간/다른 GPU 검증이 아니다.

최종 실행 결과는 아래 인수 기록에 추가한다.

## 전달 및 남은 범위

builds/HellDelivery-2026-09-10-villa-13.zip 전체 압축 해제 후 HellDelivery.exe 실행. PCK 동봉 필요. controls: WASD/마우스 이동, 왼쪽 마우스 유지 운반, Shift 달리기, Space 점프, F5 복구, R 재시작, Esc 메뉴.

플레이 확인: 2층 201호/202호 표시와 201호 배송 완료. 현재 맵의 이전 사용자 확인 사항은 유지하되, 다른 PC/GPU·장시간 플레이·모든 예외 동선은 미검증이다. 문과 도어벨은 장식이며 차량은 고정 소품이다.

재현: tools/Run-Godot.ps1 -Mode Export / BuildVisual / BuildRouteVisual / SettingsWrite / SettingsRead / Performance. GPU 검사는 순차 실행한다.

이전 빌드·미커밋 작업 보존, commit/push·공개 배포 없음.

## 최종 결과

- BuildVisual 126개, BuildRouteVisual 15개 통과. 재잡기 없이 201호 배송 완료.
- SettingsWrite 1개 / SettingsRead 8개 통과. 검사 전용 파일을 사용한 별도 프로세스 검증.
- Performance 2개 상태 검사 통과. 각 장면 600프레임, 1280×720 D3D12 / RTX 2070 SUPER. 출발 그림자 켜짐 평균 4.171ms·p95 4.516ms, 꺼짐 평균 4.171ms·p95 4.535ms. 계단실 평균 4.171ms·p95 4.530ms, 복도 평균 4.171ms·p95 4.515ms. 표시 주기 영향을 분리하지 않았으므로 GPU 성능 향상이나 최소 사양 보장으로 해석하지 않는다.
- Export 및 최종 5개 실행 검사 로그에 SCRIPT ERROR/ERROR/WARNING 없음.
- 20-apartment-hall.png에서 201호·202호와 HUD·목표 문구를 직접 확인했다.
- UTF-8 소스/문서 100개 검사 및 git diff --check 통과.

압축 인수: 파일 49개 SHA-256 일치, 별도 압축 해제 EXE 메뉴 headless smoke exit 0, 오류·경고 없음. ZIP 43300340 bytes. SHA-256 2E762BB4042A05D68B96D88C8FF7D42AE8BB9E9EA014CBD8C9050FE53F65DFEE. 이 압축 후 기록은 저장소에만 추가한다.
