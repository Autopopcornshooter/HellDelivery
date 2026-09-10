# Windows 플레이 테스트 03

빌드 ID: 2026-09-10-villa-03 · Godot 4.7.1 · Windows x86_64 debug export

## 피드백과 변경

사용자는 villa-02에서 잡은 택배 쪽으로 팔을 뻗었으면 좋겠고 그 외는 괜찮다고 피드백했다. 추가한 에셋의 적극 사용을 요청했다.

- Kenney holding-both 팔 자세는 +Z를 향하지만 게임 전방은 -Z였다. 원본 애니메이션의 팔 회전을 전방에 맞게 보정했다.
- 잡은 동안 양팔이 앞을 향하고 카메라의 위아래 각도를 따른다. 이동·달리기 중에도 유지하며 놓으면 기존 애니메이션으로 돌아온다.
- FOV, 카메라 위치, 잡기 물리·택배 충돌 크기를 변경하지 않았다.
- City Kit: 기존 배경 건물 3종에 골목 차양(detail-awning), 현관 처마(detail-overhang-wide)를 추가했다.
- Factory Kit: 실제 배송 상자를 box-small 모델로 교체하고 트럭 위 적재 상자와 cone 소품을 배치했다.
- 실제 택배 모델은 기존 0.8 × 0.6 × 0.8 충돌체에 맞춰 크기를 보정했다. 소품은 장식이며 배송 목표가 아니다.
- 기존 Blocky Characters 18종을 계속 사용한다. Modular Cave는 빌라와 맞지 않아 아직 사용하지 않는다.
- 추가 에셋 원본은 수정하지 않았다. Factory/City의 동봉 CC0 라이선스를 배포 폴더에 포함한다.

## 검증

최종 실행 파일 검사 결과와 압축 후 확인은 아래 인수 기록에 추가한다.
검사 범위: 기존 배송·복구·재시작·메뉴 및 오디오 회귀, 18종 양팔 전방 방향, 시선 상하 각도 추종, 운반 자세 유지·해제.
운반 경로는 입력 기반으로 순간이동 없이 출발→계단→위층→현관 배송을 실행한다.
Windows D3D12 / RTX 2070 SUPER에서 실제 렌더링한 잡기·위층 운반 화면에서 전방 팔과 새 상자 모델을 확인했다.
검사 작성 중 타입 추론·카메라 프로퍼티 참조 오류를 발견하고 수정했다. 오류가 있던 실행 결과는 통과로 인정하지 않는다.

## 한계와 다음 작업

- 팔은 기존 모델의 단일 팔 파트를 회전하는 방식이다. 손이 상자 표면에 정확히 붙는 IK는 없다. 팔·상자의 화면 점유감에 대한 사용자 플레이 확인이 필요하다.
- 환경 아트는 초기 단계이며 트럭 위 소품에는 개별 상호작용이 없다.
- 좁은 코너에서 잡기가 풀리면 다시 잡거나 F5로 복구한다.
- 다른 PC/GPU 및 장시간 플레이는 미검증. OpenGL은 검증 통과 범위 밖이다.
- 다음: 팔 위치·화면 가림 피드백 반영, 기존 에셋을 활용한 빌라 환경 보강과 다른 Windows PC 검증.
- 온라인 협동·차량은 후속 목표를 유지한다.

## 실행과 재현

ZIP 전체를 압축 해제하고 HellDelivery.exe 실행. HellDelivery.pck를 같은 폴더에 둔다.
빌드 폴더: builds/HellDelivery-Windows-Test-03
ZIP: builds/HellDelivery-2026-09-10-villa-03.zip
tools/Run-Godot.ps1: Export → BuildTest → BuildRouteVisual. 로그: validation/villa-03.
이전 01/02 빌드를 보존한다. 기존 작업 브랜치와 미커밋 사용자 변경을 유지하며 commit/push하지 않았다.
## 최종 빌드 검사 결과

- BuildTest: EXIT 0 checks=102 failures=0.
- BuildRouteVisual: EXIT 0 checks=14 failures=0.
- 최종 Export / BuildTest / BuildRouteVisual 로그 ERROR/WARNING 없음.
- 새 빌드 직접 사람 플레이는 미실시. 자동 입력 운반과 렌더링 화면 검사를 수행했다.
## 압축 후 인수 확인

- ZIP: 45,504,837 bytes (약 43.4 MiB).
- SHA-256: 73A3BAC95ED0D3F1F3FE62A4EDFE08EF52BAD70C969D73586DAACBA4E8A66414
- verify-unpacked-villa-03에 압축 해제 후 파일 18개 SHA-256 일치 확인.
- 압축 해제한 기본 EXE 메뉴 headless smoke exit 0, 오류·경고 없음.
- git diff --check 통과. 이 압축 후 기록은 저장소에만 추가한다.