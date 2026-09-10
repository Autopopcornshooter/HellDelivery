# Windows 플레이 테스트 07

빌드 ID: 2026-09-10-villa-07 · Windows x86_64 · Godot 4.7.1 debug export

## 사용자 확인 및 변경

사용자가 villa-06 환경 개선 빌드를 확인 완료했다. 이번 단계는 배포 용량과 설정 재실행 검증이다.

- export_filter를 전체 리소스에서 명시한 리소스 및 의존성으로 전환했다.
- tools/Update-ExportManifest.ps1이 씬·스크립트·캐릭터 정의·셰이더와 동적 경로로 로드하는 City/Factory 모델 9개를 명시한다. 현재 72개 진입 리소스와 엔진이 수집하는 의존성을 포함한다.
- 원본 팩의 미사용 모델·미리보기와 다른 형식 파일은 배포에서 제외한다. 프로젝트 원본 자산은 삭제하지 않았다.
- PCK: 57,402,056 → 13,740,976 bytes (약 76.1% 감소). FPS 향상을 뜻하지 않는다.
- 캐릭터 18종, 빌라 아트·오디오·팔·물리·배송 루프를 유지했다.
- GameSettings 저장/읽기 함수에 선택적 경로 인자를 추가했다. 기본 경로는 기존 settings.cfg이며 테스트는 별도 파일을 이용한다.
- Run-Godot.ps1은 export 전에 목록을 갱신한다. 이전 보고서를 제거하고 exit code·오류/경고 로그·완료 보고서를 확인해 미완료 검사가 통과하지 않도록 했다.

## 검증

- 최종 EXE BuildVisual: EXIT 0 checks=106 failures=0.
- 최종 EXE BuildRouteVisual: EXIT 0 checks=15 failures=0. 달리기 입력 포함 배송 완료.
- SettingsWrite: EXIT 0 checks=1 failures=0. 별도 settings-fixture.cfg 저장.
- 새 프로세스 SettingsRead: EXIT 0 checks=7 failures=0. 파일 존재 및 캐릭터/FOV/음량/감도/해상도/안내 상태 읽기 확인.
- 테스트 파일은 validation/villa-07에 생성한다. 사용자 settings.cfg를 테스트 값으로 덮어쓰지 않는다.
- 최종 export 및 검사 로그 ERROR/WARNING 없음.
- Windows D3D12 / RTX 2070 SUPER 실제 렌더링에서 위층 운반 화면과 에셋 로딩 확인.
- 새 빌드 사람 직접 플레이, 다른 PC/GPU, 장시간·성능 벤치마크는 미실시. 설정 검사는 저장·읽기 구현의 별도 프로세스 검사이며 모든 UI 조작을 자동화한 것은 아니다.

## 전달 및 다음 작업

ZIP: builds/HellDelivery-2026-09-10-villa-07.zip
실행 폴더: builds/HellDelivery-Windows-Test-07
전체 압축 해제 후 HellDelivery.exe 실행. PCK를 함께 둔다.
재현: tools/Run-Godot.ps1 Export → BuildVisual → BuildRouteVisual → SettingsWrite → SettingsRead.
이전 빌드·미커밋 사용자 작업 보존. commit/push 없음.

다음 플레이에서 기존 캐릭터와 설정 유지 및 환경 소품 누락 여부를 확인한다.
이후 대표 레벨의 플레이 확인 이력과 남은 데모 완료 항목을 점검한다. 다른 Windows PC 호환성은 미완료다. 온라인 협동·차량은 별도 후속 목표다.

## 압축 후 인수 확인

- ZIP: 37,088,072 bytes (약 35.4 MiB). villa-06 ZIP 46,539,615 bytes보다 약 20.3% 감소.
- SHA-256: 4D097DE0E38AB9EF5141D8A8C40773A1CE20CB55955A687DD0085A88A8558DE3
- 별도 압축 해제 후 파일 31개 SHA-256 일치.
- 압축 해제한 EXE 기본 메뉴 headless smoke exit 0, 오류·경고 없음.
- git diff --check 통과. 이 압축 후 기록은 저장소에만 추가한다.