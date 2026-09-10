# Windows 플레이 테스트 06

빌드 ID: 2026-09-10-villa-06 · Windows x86_64 · Godot 4.7.1 debug export

## 피드백과 구현

사용자가 villa-05 달리기 팔 수정에 대해 "굿 좋았어 다음 진행"으로 플레이 확인했다.
이번 단계는 같은 대표 빌라의 환경 시각 개선이다.

- 빌라 외벽은 밝은 회벽, 바닥은 포장 타일, 출발지는 아스팔트로 구분했다. VillaSurface.gdshader는 월드 좌표 기반 줄눈과 미세한 타일 색 차이를 적용한다.
- 기존 벽 상단에 청록색 마감, 현관 문틀과 문 앞 매트를 추가했다.
- 트럭을 크림색·청록색으로 바꾸고 바닥에 적재 주차 구획을 표시했다.
- 출발 표지를 뒤쪽으로 옮기고 지지대를 추가해 가까이서 화면을 크게 가리지 않게 했다.
- 기존 City Kit 건물 3종을 확대 배치하고 building-d/e를 추가했다. Factory Kit 적재 소품의 높이를 실제 트럭 바닥에 맞췄다.
- 주변 건물과 주요 바닥 아래에 지형 받침을 추가했다. 먼 배경 지면은 기존 낙하 복구 높이(-12m)보다 낮은 -18m에 있으며 이동용 바닥이 아니다.
- 따뜻한 방향광과 그림자를 적용했다. 새 충돌체·이동 경로·배송 목표 변경 없음.
- 승인된 팔 안정화, 낮춘 팔 자세, FOV, 운반 물리를 유지했다. 외부 에셋 원본 수정 없음.

## 검증과 한계

최종 검사 결과는 아래 인수 기록을 참조한다.
최종 Windows EXE에서 회귀 검증과 sprint 입력을 포함한 전체 배송 경로를 수행한다.
Windows D3D12 / RTX 2070 SUPER에서 실제 렌더링 화면을 검사한다.
새 충돌체 없음, 팔 안정성, 복구, 배송·재시작·메뉴 흐름은 기존 회귀 검사로 확인한다.
사용자의 새 빌드 직접 플레이·다른 PC/GPU·장시간 플레이와 성능 벤치마크는 미실시다.
그림자 추가의 다른 GPU 성능 영향은 아직 확인하지 않았다.
여전히 초기 환경 아트이며 배경 건물은 진입용 공간이 아니다. 정확한 손 IK, 온라인 협동·차량은 후속 범위다.

## 실행·다음 작업

ZIP: builds/HellDelivery-2026-09-10-villa-06.zip
실행 폴더: builds/HellDelivery-Windows-Test-06
전체 압축 해제 후 HellDelivery.exe 실행. HellDelivery.pck를 함께 둔다.
재현: tools/Run-Godot.ps1 Export → BuildVisual → BuildRouteVisual. 로그 validation/villa-06.
이전 빌드·미커밋 사용자 작업 보존, commit/push 없음.

다음 플레이에서는 출발지·골목·현관 구분, 그림자 아래 택배 가독성, 프레임 저하 여부를 확인한다.
피드백 이후 환경 마감과 다른 Windows PC 호환성 확인을 이어간다. 팔 이슈는 사용자 확인 완료로 기록하되 새 문제가 보고되면 재현한다.
## 최종 검사 결과

- BuildVisual: EXIT 0 checks=106 failures=0.
- BuildRouteVisual: EXIT 0 checks=15 failures=0.
- 최종 Export / BuildVisual / BuildRouteVisual 로그 ERROR/WARNING 없음.
- 실제 렌더링한 시작 운반·위층 화면에서 재질·주변 건물·출발 표지 크기·조명 확인.
- 사람 직접 플레이와 다른 하드웨어 성능 검증은 미실시.
## 압축 후 인수 확인

- ZIP: 46,539,615 bytes (약 44.4 MiB).
- SHA-256: 5ED709DF58865ED32F64DED0E301494864CA875EB1C303A7E28710A88A97DEB5
- 별도 압축 해제 후 파일 26개 SHA-256 일치.
- 압축 해제한 EXE 기본 메뉴 headless smoke exit 0, 오류·경고 없음.
- git diff --check 통과. 이 압축 후 기록은 저장소에만 추가한다.