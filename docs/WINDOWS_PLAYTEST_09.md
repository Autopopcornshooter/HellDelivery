# Windows 플레이 테스트 09 — 현재 빌라 맵 완성 작업

빌드 ID: 2026-09-10-villa-09 · Windows x86_64 · Godot 4.7.1 debug export

## 목표와 변경

사용자의 최신 방향은 두 번째 스테이지가 아니라 **현재 맵 완성**이다. 이번 묶음은 배송 트럭·실제 바닥·주변 동네·빌라 구조를 함께 보완한다.

- 임시 상자 조합 트럭을 Kenney Car Kit 3.1의 delivery.glb로 교체했다. 운전석·바퀴·차체·후면 문이 있는 실제 차량 모델이며 뒤쪽에 배송 표기를 추가했다.
- 차량 크기에 맞춘 고정 충돌체를 배치했다. 기존 트럭의 보이지 않는 잔여 충돌은 제거했다. 차량 운전 기능은 추가하지 않았다.
- 맵 전체에 64×76m의 연속 지면과 충돌을 추가했다. 기존 길의 높이는 유지하고 주변 지면 상단은 -0.08m로 연결했다.
- 도로 차선·주차 구획·택배 대기 영역, 보도 재질, 화단·나무·가로등·주차 차량을 추가했다.
- 주변 건물을 지면 높이에 맞추고 실제 건물 충돌을 추가했다. 과거 -18m의 장식 지면과 길쭉한 받침은 제거했다.
- 맵 경계를 보이는 담장·식재와 대응하는 충돌로 구성했다. 외부로 나간 택배의 낙하 복구와 F5 복구는 유지한다.
- 빌라 복도·현관 하부와 지붕, 계단 아래의 구조를 채웠다. 하늘은 절차적 하늘 재질로 변경했다.
- 운반 테스트에서 새 난간 간섭을 발견해 제거했다. 위층 코너의 택배 걸림을 줄이도록 남쪽 벽을 0.4m 옮기고 해당 복도 바닥 폭을 넓혔다.
- 기존 캐릭터 18종·팔 안정화·FOV·그림자 설정·배송 목표 1개를 유지한다.

## 구조 및 에셋

- VillaPresentation은 기존 장식과 건물 모델을 담당한다.
- VillaNeighborhood는 실제 지면·건물·경계·차량 충돌과 주변 구조를 담당한다. 장식 전용 노드에 몰래 물리 노드를 섞지 않았다.
- Car Kit의 delivery.glb와 sedan.glb 및 참조 텍스처만 프로젝트에 추가했다. 기존 사용자 에셋을 삭제하지 않았다.
- 출처: https://kenney.nl/assets/car-kit (공식 페이지). CC0 라이선스 원문을 assets/environment/kenney_car-kit/License.txt 및 배포 licenses/Kenney-Car-Kit.txt에 동봉한다.
- export 목록에 동적 차량 리소스를 추가했다. 원본 ZIP은 build-tools에 보관한다.

## 검증 범위

최종 결과는 아래 인수 기록에 추가한다.
- 연속 바닥 4지점의 물리 Ray 검사와 확장 지면에서 플레이어 착지 검사.
- 트럭 에셋 포함, 캐릭터·팔·그림자·목표·복구·메뉴·재시작 회귀.
- 실제 이동/달리기/잡기 입력으로 트럭 뒤→골목→계단→현관 배송 완료.
- 현재 PC의 Windows 렌더링에서 시작 화면·전체 맵·위층 운반 화면 검사.
- 새 난간/코너의 중간 실패 로그는 BeforeRailAdjustment.log / BeforeHallClearance.log에 보존한다. 최종 통과 로그와 구분한다.

## 한계와 다음 확인

새 맵을 사람이 직접 플레이한 평가는 아직 받지 않았다. 이번 작업을 최종 아트 승인이나 게임 전체 완성으로 간주하지 않는다.
다른 PC/GPU, 장시간 플레이, 모든 우회 경로는 미검증이다. 나무 잎·차량의 세밀한 부품까지 정확한 충돌을 만들지는 않았으며 고정 소품에 단순 충돌체를 쓴다.
택배는 여전히 물리 접촉으로 놓칠 수 있다. 다시 잡기·F5 복구·R 재시작을 제공한다.

다음 플레이는 트럭 외형과 잡기 위치, 바닥의 연결감, 새 구조물의 끼임·우회 동선, 지붕 아래 가독성을 확인한다. 후속 작업도 현재 빌라 맵 마감에 집중한다. 두 번째 스테이지·온라인 협동·차량 운전은 이번 범위가 아니다.

## 전달

ZIP: builds/HellDelivery-2026-09-10-villa-09.zip
폴더: builds/HellDelivery-Windows-Test-09
전체 압축 해제 후 HellDelivery.exe 실행. PCK를 함께 둔다.
재현: tools/Run-Godot.ps1 Export → BuildRouteVisual → BuildVisual → SettingsWrite → SettingsRead. 성능 검사는 단독 Performance 모드.
이전 빌드와 사용자 미커밋 작업 보존. commit/push·공개 배포 없음.

## 최종 빌드 검사 결과

- BuildVisual: EXIT 0 checks=115 failures=0. 확장 바닥 4지점과 실제 플레이어 착지 포함.
- BuildRouteVisual: EXIT 0 checks=15 failures=0. 최종 경로는 재잡기 없이 전체 배송 완료.
- SettingsWrite 1개 / SettingsRead 8개 통과.
- 최종 export·실행 검사 로그 SCRIPT ERROR/ERROR/WARNING 없음.
- 15-neighbourhood-overview.png, 02-villa-start.png, 07-route-grab.png, 08-route-upstairs.png에서 전체 맵·트럭·지면·지붕·운반 화면 시각 확인.
## 현재 PC 짧은 성능 표본

1280×720 / D3D12 / RTX 2070 SUPER, 고정 출발 장면, 모드별 600프레임.
그림자 켜짐 평균 4.170ms·p95 4.509ms, 꺼짐 평균 4.171ms·p95 4.518ms.
Performance EXIT 0 checks=2 failures=0. 단독 검사이며 표시 동기화 영향을 분리하지 않았다. 다른 GPU 성능이나 최소 사양을 보장하지 않는다.
## 압축 후 인수 확인

- ZIP: 39,604,246 bytes (약 37.8 MiB).
- SHA-256: EEED6202A494CC630A6E8AF839C1E7EDCC9B674E2CC8EA12612F35525C5451E6
- 별도 압축 해제 후 파일 40개 SHA-256 일치.
- 압축 해제한 EXE 기본 메뉴 headless smoke exit 0, 오류·경고 없음.
- git diff --check 통과. 이 압축 후 기록은 저장소에만 추가한다.