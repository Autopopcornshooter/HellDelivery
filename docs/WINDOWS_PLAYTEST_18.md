# Windows 플레이 테스트 18 — 현재 빌라 완성 기준 빌드

2026-09-10-villa-18 · Windows x86_64 · Godot 4.7.1 debug export

사용자가 villa-17 진행 유지 복구를 확인했다. 기존 캐릭터로 현재 빌라를 끝까지 플레이하고, 실내·트럭·지면·주소·두 집 왕복·HUD·복구를 마감하는 목표는 사용자 피드백 반영 완료다. 이번 빌드는 게임 내용을 바꾸지 않고 통합 인수 검사를 수행한 기준선이다. 온라인 협동·차량 운전·새 맵·Steam 공개 데모 전체 완료 판정은 아니다.

## 이번 변경

- Playtest.gd에 12회 연속 두 집 배송/복구/재시작/메뉴 복귀 검사를 추가했다. 배송 순서를 번갈아 바꾸고 매회 일시정지를 3번 재개한다. 약한 참조로 이전 레벨이 실제 해제되는지 확인한다.
- Run-Godot.ps1에 BuildRepeat 모드를 추가했다. 이전 실패 보고서 제거 및 최종 보고서 검증을 그대로 적용한다.
- 현재 맵 완료 상태와 후속 범위를 DEMO_READINESS/TASKS/ROADMAP에 정리했다. 기존 미커밋 변경 및 이전 ZIP은 보존한다. commit/push/공개 배포는 하지 않았다.

## 검증 구분

모두 export한 Windows EXE/PCK를 사용한다. BuildRepeat와 판정 검사는 물건을 시험 위치로 배치하므로 실제 운반 플레이가 아니다. BuildMultiRouteVisual은 별도로 이동·시점·잡기 입력만 사용해 201호 배송→트럭 복귀→202호 배송을 검사한다. 사용자 직접 플레이와 자동 검증/화면 검토는 구분한다.

반복 검사 12회는 장시간 플레이나 모든 물리 상태를 보장하지 않는다. 이전 레벨 해제를 검사하지만 전체 엔진 메모리 누수/VRAM 분석을 수행한 것은 아니다. 설정 검사는 검사 전용 파일을 사용하며 사용자 설정을 덮어쓰지 않는다. 성능은 현재 PC의 기본 1개 배송 맵 고정 장면 표본으로, 두 집 운반 중 부하·다른 PC 성능을 대표하지 않는다.

최종 검사별 결과와 성능 표본, 압축 인수 기록은 아래에 추가한다.

## 전달 및 이후

builds/HellDelivery-2026-09-10-villa-18.zip 전체 압축 해제 후 HellDelivery.exe 실행. 새 배송 노선 · 201호 + 202호 선택. 기본 배송 1개 모드도 유지한다. 조작은 README.md 참고.

현재 빌라를 반복 미세 수정하는 단계는 여기서 기준선을 고정한다. 이후 새로 발견되는 결함은 이 빌드와 비교한다. 다음 개발 목표는 사용자와 협동·운전·새 맵 등 별도 범위를 정해 진행한다. 실제 다른 Windows PC 검증과 장시간 실행은 미완료다.

재현: tools/Run-Godot.ps1 -Mode Export / BuildRepeat / BuildVisual / BuildMultiVisual / BuildMultiRouteVisual / SettingsWrite / SettingsRead / Performance. GPU 실행은 순차 진행한다.

## 최종 결과

- BuildRepeat: EXIT 0 checks=60 failures=0
- BuildVisual: EXIT 0 checks=126 failures=0
- BuildMultiVisual: EXIT 0 checks=35 failures=0
- BuildMultiRouteVisual: EXIT 0 checks=41 failures=0
- SettingsWrite: EXIT 0 checks=1 failures=0
- SettingsRead: EXIT 0 checks=8 failures=0
- Performance: EXIT 0 checks=2 failures=0
- 총 273개 검사 통과. Export 및 7개 최종 실행 로그 오류·경고 없음. UTF-8 107개 및 git diff --check 통과.
- 최종 왕복 결과 화면과 최소 창 크기 일시정지 화면을 직접 검토했다.
- 1280×720 D3D12 / RTX 2070 SUPER, 장면별 600프레임 표본. 아래 값은 표시 주기의 영향을 분리하지 않았으며 최소 사양 보장이 아니다.
- FRAME_SAMPLE shadows=true frames=600 mean_ms=4.170 median_ms=4.170 p95_ms=4.613
- FRAME_SAMPLE shadows=false frames=600 mean_ms=4.171 median_ms=4.168 p95_ms=4.594
- INTERIOR_SAMPLE view=stairwell frames=600 mean_ms=4.171 median_ms=4.171 p95_ms=4.534
- INTERIOR_SAMPLE view=hall frames=600 mean_ms=4.171 median_ms=4.165 p95_ms=4.532

압축 인수: 57 개 파일 해시 일치. 별도 압축 해제 EXE headless 메뉴 실행 exit 0, 오류·경고 없음. ZIP 43746049 bytes, SHA-256 D2B7E3E5AEE1CAD25346131EA3123274233D351D9962519C1A825310836C2F5E. 압축 후 기록은 저장소에만 추가한다.
