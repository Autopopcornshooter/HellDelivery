# Windows 플레이 테스트 20 — 캐릭터 앞뒤 방향 정상화

2026-09-11-villa-20 · Windows x86_64 · Godot 4.7.1 debug export

## 원인과 수정

사용자가 협동에서 사람 모델이 뒤집혀 보인다고 보고했다. Kenney 캐릭터의 앞 방향은 +Z인데 Player/Camera3D/이동 방향은 -Z였다. 실제 모델에는 방향 보정이 없고 팔 운반 포즈만 반대로 보정돼 있어 상대가 보는 몸 방향과 실제 시선이 일치하지 않았다.

- CharacterVisual에서 실제 플레이 모델에만 Y축 180도 회전을 적용했다. 미리보기 회전/원본 GLB/캐릭터 크기는 유지한다.
- 전신이 정렬됐으므로 팔 단독 180도 보정을 제거했다. 모델 좌표계에 맞춰 시선 pitch와 16도 하향 포즈 부호를 맞췄다.
- 카메라·충돌·운반 물리와 P1/P2 입력은 변경하지 않았다.
- 자동 검증은 18개 캐릭터의 전방/수직 축, 전방 운반, 애니메이션 전환, 달리기 어깨 안정, 상하 시선 추종을 확인한다. 기존 전환 검사에서 모델 공간 포즈를 플레이어 공간으로 간주하던 기대값을 실제 게임 전방 16도 하향 기준으로 수정했다.
- 협동 검사에 상대가 같은 방향을 보는 장면과 마주 보는 장면을 추가했다. 사용자 미커밋 변경/이전 빌드는 보존하고 commit/push/공개 배포하지 않았다.

## 검증

최종 검사 수치와 화면 확인은 아래 기록한다. Windows EXE/PCK를 사용하며 자동 입력·fixture·캡처 검토는 실물 패드/두 사람 직접 플레이와 구분한다. P2 협동 운반 및 P1 싱글 운반 경로는 실제 이동/잡기 입력으로 검사한다.

## 전달 및 확인

builds/HellDelivery-2026-09-11-villa-20.zip 전체 압축 해제 후 HellDelivery.exe 실행. 빌라 협동 · 2인 분할 화면 선택. P1 키보드·마우스 + P2 게임패드 조합은 유지한다.

상대가 나를 바라볼 때 얼굴, 돌아설 때 등이 보이는지 확인해 주세요. 걷기·달리기·상자 운반 중 몸 방향과 팔도 함께 확인하면 됩니다. [REVIEW] 사용자 확인 대기. 실물 패드 기종별/장시간/다른 PC는 미검증이며 온라인은 없다.

재현: tools/Run-Godot.ps1 -Mode Export / BuildVisual / BuildCoopVisual / BuildRouteVisual. GPU 검사는 순차 실행한다.

## 최종 결과

- BuildVisual: EXIT 0 checks=144 failures=0
- BuildCoopVisual: EXIT 0 checks=34 failures=0
- BuildRouteVisual: EXIT 0 checks=15 failures=0
- 총 193개 검사 통과. 18개 캐릭터 모델 축/팔 방향, 시선 추종·달리기 안정, P2 협동 계단 운반, P1 싱글 배송을 확인했다.
- 41-partner-facing-away.png 및 42-partner-facing-player.png에서 상대의 등/얼굴이 실제 바라보는 방향과 일치하는 것을 직접 검토했다.
- Export 및 세 최종 실행 로그 오류·경고 없음. UTF-8 112개 및 git diff --check 통과.

압축 인수: 49 개 파일 해시 일치. 별도 압축 해제 EXE headless 메뉴 실행 exit 0, 오류·경고 없음. ZIP 43418567 bytes, SHA-256 DCCB8D19DF1121DEFAC3765E0C97B74031E1621F95D42C4D2D865FC6F0CA709D. 압축 후 기록은 저장소에만 추가한다.
