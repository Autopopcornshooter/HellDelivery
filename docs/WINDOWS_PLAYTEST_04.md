# Windows 플레이 테스트 04

빌드 ID: 2026-09-10-villa-04 · Windows x86_64 · Godot 4.7.1 debug export

## 사용자 피드백 반영

- 운반 팔이 시야를 많이 가린다는 피드백: 전방 운반 자세를 16도 낮추고, 잡은 동안 팔 두께를 원래의 72%로 부드럽게 조정한다. 팔 길이는 유지한다.
- 놓으면 원본 팔 비율로 복원한다. 캐시한 원래 스케일에서 계산하므로 프레임마다 축소가 누적되지 않는다.
- 계단 방향 피드백: 빌라 route_hint와 골목·계단 표지의 안내를 왼쪽으로 수정했다. 계단 표지 화살표도 ←로 변경했다. 위층 현관 안내는 별도 방향이다.
- FOV, 카메라 위치, 운반 힘, HoldPoint, 통로 충돌은 유지한다.
- 기존 Blocky Characters, City Kit, Factory Kit 자산을 계속 사용한다. 이번 단계는 운반 시야와 길 안내 보정이다.

## 검증 범위와 한계

검사 결과는 아래 최종 인수 기록을 참조한다.
기존 배송·복구·재시작·메뉴/오디오 검사와 18종 팔 전방 방향, 상하 시선 추종, 팔 비율 복원 및 계단 안내 검사를 수행한다.
입력 기반 운반 경로와 Windows D3D12 렌더링 화면을 확인한다.
자동 검증은 직접 사람 플레이 평가와 구분한다. 다른 PC/GPU, 장시간 플레이는 미검증이다.
손이 택배 표면에 정확히 붙는 IK는 없다. 좁은 코너에서 잡기가 풀리면 다시 잡거나 F5로 복구한다.

## 전달 및 다음 작업

- ZIP: builds/HellDelivery-2026-09-10-villa-04.zip
- 실행 폴더: builds/HellDelivery-Windows-Test-04
- ZIP 전체 압축 해제 후 HellDelivery.exe 실행. HellDelivery.pck를 함께 둔다.
- 재현: tools/Run-Godot.ps1의 Export → BuildTest → BuildRouteVisual.
- 로그: validation/villa-04. 이전 빌드 01~03 보존. 미커밋 사용자 작업 보존, commit/push 없음.
- 다음 플레이: 팔이 충분히 보이면서 길과 택배를 덜 가리는지, 계단의 왼쪽 안내가 접근 방향에서 맞는지 확인.
- 피드백 이후 환경 에셋 배치와 길 안내를 계속 다듬고 다른 Windows PC 실행을 확인한다. 온라인 협동·차량은 후속 목표로 유지한다.
## 최종 검사 결과

- BuildTest: EXIT 0 checks=104 failures=0.
- BuildRouteVisual: EXIT 0 checks=14 failures=0.
- 최종 Export / BuildTest / BuildRouteVisual 로그 ERROR/WARNING 없음.
- 실제 렌더링한 시작 운반·위층 운반 화면에서 팔이 하단으로 내려가 화면 가림이 줄었음을 확인했다. HUD의 왼쪽 계단 문구 확인.
- 새 빌드 직접 사람 플레이 미실시. 자동 입력 운반과 시각 검사를 수행했다.
## 압축 후 인수 확인

- ZIP: 45,333,251 bytes (약 43.2 MiB).
- SHA-256: 605C996FC561BFE62C074EDDA433E6D746A2B6428189ABD5BA3341C57C4B4A11
- verify-unpacked-villa-04에 압축 해제 후 파일 18개 SHA-256 일치.
- 압축 해제한 기본 EXE 메뉴 headless smoke exit 0, 오류·경고 없음.
- git diff --check 통과. 이 압축 후 기록은 저장소에만 추가한다.