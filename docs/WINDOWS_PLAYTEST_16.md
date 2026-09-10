# Windows 플레이 테스트 16 — HUD 배경 자동 너비

2026-09-10-villa-16 · Windows x86_64 · Godot 4.7.1 debug export

사용자가 HUD가 시야를 많이 가리지는 않지만 배경을 글자 길이에 맞추기를 요청했다. DeliveryHUD는 Label의 실제 텍스트 최소 폭(폰트 조판 및 좌우 12px 여백 포함)을 사용해 가운데 기준 offsets를 갱신한다. minimum_size_changed 신호로 목표·진행·경로·배송/오배송 문구 변경을 반영한다. 고정 폭 배경을 매 프레임 다시 계산하지 않는다.

기존 빌라·배송 판정·캐릭터·에셋·입력·설정은 유지한다. 이전 미커밋 변경과 빌드를 보존했으며 commit/push/공개 배포하지 않았다.

## 검증

- Windows BuildMultiVisual 27개 통과. 판정용 물건 배치 검사이며 실제 운반 입력 검사가 아니다.
- 26-multi-stop-start.png 및 27-wrong-address.png를 직접 검토해 목표·진행·안내·긴 오배송 알림의 배경 폭과 중앙 정렬을 확인했다.
- 실제 왕복 경로는 물리/동선 무변경으로 이번에 재실행하지 않았다. villa-15의 41개 입력 경로 결과를 참고한다. 사용자 직접 플레이와 자동 검증·캡처 검토는 구분한다.
- 최종 회귀 및 압축 인수 결과는 아래 기록한다.

## 전달

builds/HellDelivery-2026-09-10-villa-16.zip 전체 압축 해제 후 HellDelivery.exe 실행. ‘새 배송 노선 · 201호 + 202호’를 선택한다. 문구가 바뀔 때 배경 폭과 정렬을 확인해 주세요. 상태 [REVIEW]. 다른 PC/GPU·장시간·모든 해상도 조합은 미검증이다.

재현: tools/Run-Godot.ps1 -Mode Export / BuildMultiVisual / BuildVisual. 다음은 현재 빌라의 남은 마감 피드백 반영이다. 온라인 협동·운전·새 맵은 후속 범위다.

최종 BuildVisual 126개 통과. Export 및 두 최종 실행 로그 오류·경고 없음. UTF-8 105개 및 git diff --check 통과.

압축 인수: 38 개 파일 해시 일치. 별도 압축 해제 EXE headless 메뉴 실행 exit 0, 오류·경고 없음. ZIP 41593094 bytes, SHA-256 1E44DE78E6F6279B4739C8F54413674C1189ACEDEF07BDAAC35251B9ED4EAA83. 압축 후 기록은 저장소에만 추가한다.
