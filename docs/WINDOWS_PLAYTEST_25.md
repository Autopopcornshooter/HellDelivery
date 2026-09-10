# Windows 플레이 테스트 25 — 모드별 조작법 보완

2026-09-11-villa-25 · Windows x86_64 · Godot 4.7.1 debug export

## 변경

기존 조작법은 협동에서도 키보드만 표시했고 점프/달리기가 없었다. F5도 내 위치 복구로 표시했다.
- 공통 ControlsPanel에 점프 Space/달리기 Shift 행 추가.
- VillaCoopLevel에서 configure_coop 호출: P1/P2 이동·시점·잡기/놓기·점프·달리기·Start와 메뉴 조작 주체를 구분.
- 같은 상자를 함께 잡기, 두 사람/미배송 택배 복구, 완료한 배송 유지 안내.
- 배송 목표 문구는 기존 레벨의 두 집 목표를 유지. Input Map/물리/게임 규칙 변경 없음.
- 기존 미커밋 작업/빌드 보존. commit/push/공개 배포 없음.

## 검증 구분

자동 검사는 실제 Windows export에서 안내 문구/목표/작은 창 경계/뒤로 가기를 검사하고, 기존 협동 입력 운반·12회 세션 반복·전체 회귀를 재실행한다.
960x540 캡처 직접 검토에서 문구/버튼 잘림 없음. 최초 크기 검사는 실제 창 픽셀과 Godot stretch 논리 좌표를 혼용해 실패했고 viewport 좌표로 통일했다. 최초 실패 보고서 InitialCoop.report.txt는 로컬 검증 폴더에 보존.
실제 사람이 조작법만 보고 처음 배우는 검증, 실물 패드 재연결, 다른 PC/장시간은 미검증.

## 플레이 확인

협동 → Esc/Start → 조작법에서 P1/P2 설명을 확인하고 뒤로 돌아가 재개한다. 점프/달리기/F5의 실제 동작과 안내가 일치하는지 확인한다.
실행은 ZIP 전체 압축 해제 후 HellDelivery.exe. 상세 조작은 README.md.
재현: tools/Run-Godot.ps1 -Mode Export / BuildCoopVisual / BuildVisual.
## 최종 검증
Windows export 성공. BuildCoopVisual 155/155, BuildVisual 167/167: 총 322개 자동 검사 통과. 최종 Godot 오류/경고 없음. UTF-8 117개 및 git diff --check 통과. 47-coop-controls-minimum.png(960x540), 48-coop-controls.png(1280x720) 직접 검토: 조작법과 뒤로 가기 버튼 잘림 없음. 실제 초보자 사용성 검증과 구분한다.

## 압축 후 전달 기록
ZIP HellDelivery-2026-09-11-villa-25.zip, 43540856 bytes. SHA-256 D01FBA3AA72422898C40A68CCB7FE5BB133A30FE2CBBBE0F67CDCE1E93041DEE
압축 해제본 48 파일 해시 일치. 해제본 HellDelivery.exe headless 180프레임 exit 0, 오류/경고 없음. README/VALIDATION/라이선스/최종 로그/캡처 포함.
