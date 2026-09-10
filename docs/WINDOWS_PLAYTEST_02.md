# Windows 플레이 테스트 02

빌드 ID: 2026-09-10-villa-02 · Godot 4.7.1 · Windows x86_64 debug export

## 사용자 피드백과 범위

사용자는 villa-01의 스테이지 클리어에 문제가 없고 현재 시야도 플레이 가능한 상태라고 확인했다. FOV의 소폭 조정은 후속으로 남겼다. 이는 모든 캐릭터·하드웨어·효과음 검증 완료를 뜻하지 않는다.
이번 단계는 같은 빌라의 위치 식별과 물리 소리 피드백 보강이다. 기존 FOV와 통로 충돌·배송 목표를 유지했다. 온라인 협동·차량은 후속 목표다.

## 구현

- VillaPresentation: 출발·골목·계단 위·배송 현관 표지, 계단 끝 노란 표시, 창문과 현관, 트럭 바퀴·유리, 기존 Kenney City Kit 배경 건물 3개.
- 장식에는 CollisionObject3D가 없으며 배송 상태나 입력을 담당하지 않는다.
- LevelAudio: 절차적으로 만든 점프·착지·물건 충돌 소리, 속도에 따른 발걸음 간격과 착지·충돌 음량. 충돌음은 120ms 간격 제한.
- PrototypeLevel: 실제 접지 전환과 물리 접촉에서 오디오 호출. 외부 음원이나 새 전역 관리자를 추가하지 않았다.
- City Kit 리소스를 Windows export에 포함. 이전 실행 폴더와 ZIP을 보존하고 Test-02 폴더로 출력.
- Run-Godot.ps1 기본 BuildName은 HellDelivery-Windows-Test-02, 로그는 validation/villa-02.

## 검증 결과

- 최종 EXE/PCK 자체의 BuildTest: EXIT 0, 82 checks, 0 failures.
- 회귀 범위: 캐릭터 18종 로드·적용, 목표/HUD/안내 일치, 운반 자세, 낙하·수동 복구, 중복 배송 방지, 완료·재시작·메뉴.
- 추가 범위: 장식 충돌 노드 없음, 점프 입력과 착지 시 소리 이벤트, 택배 충격 시 소리 이벤트, 중복 충돌음 제한.
- 최종 EXE의 BuildRouteVisual: EXIT 0, 14 checks, 0 failures. 순간이동 없이 입력 기반으로 시작→계단→현관 운반·배송 완료.
- Windows D3D12 / RTX 2070 SUPER에서 실제 렌더링한 07-route-grab, 08-route-upstairs, 09-route-complete 화면을 시각 검사했다.
- Export, BuildTest, BuildRouteVisual 로그에서 ERROR/WARNING 없음.
- git diff --check 통과. LF/CRLF 변환 안내만 존재.
- 새 빌드의 사람 직접 조작과 주관적 청음 평가는 미실시. 자동 이벤트 확인은 소리의 체감 품질 평가와 다르다.

## 알려진 문제

- 기본 지형 중심의 초기 아트 보강이며 완성 환경 아트·배경음악은 아니다. 일부 표지는 가까이서 화면 밖으로 잘릴 수 있다.
- 좁은 코너와 계단에서 물건이 부딪히면 잡기가 풀릴 수 있다. F5 복구 / R 재시작 사용.
- FOV 미세 조정, 다른 GPU/PC와 장시간 플레이는 후속. OpenGL 호환 모드는 이전 시야 문제 때문에 검증 통과 범위에 포함하지 않는다.
- 기존 로컬 협동 개발 씬은 이번 메뉴와 필수 검사 범위에 포함하지 않는다.

## 다음 세션

1. 새 표지로 경로를 찾기 쉬워졌는지, 착지·충돌음 크기와 반복감에 대한 사용자 피드백 수집.
2. 재현되는 운반·시야 문제를 우선 수정하고 환경 아트 보강 범위를 결정.
3. 다른 Windows PC의 실제 실행 검증. 온라인 협동·차량으로 자동 확대하지 않는다.

## 재현 및 전달

tools/Run-Godot.ps1의 Export → BuildTest → BuildRouteVisual 순서로 실행한다.
Windows PowerShell이 PATH에 없으면 C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe를 사용한다.
빌드 폴더: builds/HellDelivery-Windows-Test-02
ZIP: builds/HellDelivery-2026-09-10-villa-02.zip
README.md, 라이선스, 검증 로그·보고서·화면을 동봉한다.
브랜치 work/windows-playtest-20260910 유지. 사용자 미커밋 작업 보존. commit/push 없음.
## 압축 후 최종 전달 확인

- ZIP 크기: 41,298,811 bytes (약 39.4 MiB).
- ZIP SHA-256: CABD9C19F5D26A6A484E45243C78039E2481E2D1321F0E0C61FE209364E7453E
- builds/verify-unpacked-villa-02에 압축 해제하여 17개 파일 SHA-256 일치 확인.
- 압축 해제한 EXE의 기본 메뉴 headless smoke: exit 0. 로그 validation/villa-02/UnpackedSmoke.log.
- 이전 villa-01 ZIP 및 실행 폴더 보존. 이 압축 후 기록은 저장소에만 추가한다.