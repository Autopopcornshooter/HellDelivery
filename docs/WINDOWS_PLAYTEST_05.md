# Windows 플레이 테스트 05

빌드 ID: 2026-09-10-villa-05 · Windows x86_64 · Godot 4.7.1 debug export

## 수정

사용자가 일반 걷기는 괜찮지만 달릴 때 팔이 위아래로 부자연스럽게 흔들린다고 보고했다.
운반 팔의 로컬 회전만 덮어쓰던 코드가 부모 몸통의 달리기 변위를 그대로 상속한 것이 원인이었다.
캐릭터 교체 시 원래 어깨 기준 변환을 보관하고, 운반 중에는 캐릭터 기준 위치·방향을 부모의 현재 변환으로 역변환해 적용한다.
몸통·다리의 달리기 애니메이션은 계속 재생한다. 놓으면 어깨의 로컬 위치와 원래 팔 비율로 복원한다.
이전 빌드의 낮춘 팔 자세·두께, FOV, HoldPoint, 이동·운반 물리, 왼쪽 계단 안내와 기존 에셋을 유지했다.

## 재현 및 검증

- 수정 전 실제 달리기 애니메이션 90프레임에서 팔 어깨 높이 범위 0.0794214m. 새 회귀 검사는 실패하여 문제 재현.
- 수정 후 같은 검사에서 0.000000954m (부동소수점 오차 수준).
- 기존 검사의 로컬 팔 회전 비교를 캐릭터 기준 최종 방향 비교로 보강. 걷기→달리기→걷기, 상하 시선 추종, 놓기 후 원복 검사.
- BuildVisual: EXIT 0 checks=106 failures=0. 최종 Windows EXE에서 렌더러를 켜고 회귀 검사.
- BuildRouteVisual: EXIT 0 checks=15 failures=0. 실제 sprint 입력을 넣은 골목 운반 후 계단·현관 배송 완료.
- 최종 Export / BuildVisual / BuildRouteVisual 로그 ERROR/WARNING 없음.
- Windows D3D12 / RTX 2070 SUPER에서 운반 팔 화면 검사. 정지한 플레이어에 달리기 애니메이션을 적용한 검사와 실제 입력 운반 검사를 구분한다.
- 새 빌드 사람 직접 플레이는 미실시. 다른 PC/GPU와 장시간 플레이도 미검증.
- SprintBefore.log는 수정 전 재현 실패 기록이며 최종 통과 로그와 구분한다.

## 전달 및 다음 작업

ZIP: builds/HellDelivery-2026-09-10-villa-05.zip
실행 폴더: builds/HellDelivery-Windows-Test-05
ZIP 전체 압축 해제 후 HellDelivery.exe 실행. PCK를 함께 둔다.
재현: tools/Run-Godot.ps1 Export → BuildVisual → BuildRouteVisual. 로그 validation/villa-05.
이전 빌드와 사용자 미커밋 작업 보존. commit/push 없음.

다음 플레이는 택배를 잡은 상태에서 Shift를 반복해 누르고 놓으며 팔 안정성과 전환을 확인한다.
손과 상자 표면의 정확한 IK는 아직 없다. 물리 택배 자체의 흔들림과 계단 보행 높이 변화는 유지한다.
피드백 이후 기존 에셋을 활용한 환경 보강과 다른 Windows PC 검증을 이어간다. 온라인 협동·차량은 후속 목표다.
## 압축 후 인수 확인

- ZIP: 45,989,199 bytes (약 43.9 MiB).
- SHA-256: 51A23D3C5DEB108C9D2DC21F3AB85CCB5D7D654937FC35D5319CA4992F086314
- 별도 압축 해제 후 파일 27개 SHA-256 일치.
- 압축 해제한 EXE 기본 메뉴 headless smoke exit 0, 오류·경고 없음.
- git diff --check 통과. 이 압축 후 기록은 저장소에만 추가한다.