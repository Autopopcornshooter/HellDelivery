# CHANGELOG.md

이 문서는 버전별 변경 내역을 [Semantic Versioning](https://semver.org/) 스타일로 기록한다.

**역할**: 무엇이 변경되었는가. "앞으로 무엇을 만들 것인가"는 `ROADMAP.md`, "지금 프로젝트 상태가 어떤가"는 `VERSION.md`를 참고한다.

실제로 구현되어 `docs/TASKS.md`에서 완료(`[DONE]`) 확인된 항목만 기록한다. 계획 단계이거나 보류된 기능은 기록하지 않는다.

---

## [Unreleased] — Gameplay Expansion (In Progress)

v0.2.0 범위의 구현 작업. `docs/TASKS.md` T064 `[DONE]`, T065 `[DONE]`.

### Added

- 환경 물리 오브젝트 3종 신규 씬(`scenes/objects/`): `PhysicsBarrel.tscn`(원통형 드럼통, 옆으로 쓰러지면 굴러감), `PhysicsCrate.tscn`(나무 상자, 적층 가능), `SmallPhysicsBox.tscn`(작은 상자, 가볍게 밀림) — 모두 스크립트 없는 순수 `RigidBody3D` 씬
- 신규 collision layer 16(PhysicsObject) — World/Player/Package와 상호 충돌하되 잡기·배송 판정 대상에서는 제외
- `PrototypeLevel.tscn`에 `PhysicsObjects` 그룹 노드와 인스턴스 6개(Barrel 1, Crate 2[적층], SmallBox 3) 배치 — 굴림·연쇄 충돌 구역, 적층·붕괴 구역, 배송 경로 인접 구역 구성(T064)
- `PrototypeLevel.tscn`에 `WallTestArea/TestWall`(`StaticBody3D`) 수직 벽 테스트 구역 추가, 기존 World collision layer 사용(T065)
- 전역 Physics Interpolation 활성화(`project.godot`, `physics/common/physics_interpolation=true`)
- `Player.gd`/`Package.gd`에 상호작용·Hold 유지용 물리적 가시선(Ray Query) 검사 추가(T065) — 벽 등으로 막히면 감지·잡기 대상에서 제외되고, 잡은 상태에서 경로가 막히면 연속 3프레임 후 자동 Release

### Changed

- (해당 없음 — 기존 노드 구조는 무변경, `Player.gd`/`Package.gd`는 T065에서 상호작용 가시선 검사만 최소 추가)

### Fixed

- PhysicsCrate를 계속 밀 때 발생하던 화면·카메라 떨림 → 원인은 물리 시뮬레이션 불안정이 아니라 물리 틱(60Hz)과 렌더 프레임 사이 보간 부재로 확인, 전역 Physics Interpolation 활성화로 해결(T064, 사용자 재테스트 승인 완료)
- 벽 너머(가려진) Package가 사거리 안에 있으면 그대로 감지·잡기가 가능하던 문제 → 상호작용 판정에 물리적 가시선 검사 추가로 해결(T065)
- Package를 잡은 뒤 벽이 Player-Package 사이에 들어와도 Hold가 계속 유지되던 문제 → Hold 유지 중 경로 차단 검사와 자동 Release 추가로 해결(T065)

### Known Notes

- 환경 물리 오브젝트의 물리 파라미터(mass/friction/damp)는 실측 재탐색이 아닌 상대적 스케일 추론으로 결정된 초기값으로 유지 중(`TECH_DEBT.md` TD-010)

---

## [Unreleased] — Project Bootstrap

MVP-1 종료 후, 장기 개발을 위한 프로젝트 관리 체계를 구축했다. 게임 코드/씬/스크립트 변경은 없다.

### Added

- 공식 프로젝트 관리 문서 8종 채택: `ROADMAP.md`, `CHANGELOG.md`, `VERSION.md`, `KNOWN_ISSUES.md`, `TECH_DEBT.md`, `MILESTONES.md`, `DESIGN_DECISIONS.md`, `PROJECT_STRUCTURE.md`
- Task 중심 관리에서 **Epic → Feature → Task** 계층 구조로 전환(`PROJECT_STRUCTURE.md`)
- v0.2.0(Gameplay Expansion) Epic/Feature/Task 후보 설계(`ROADMAP.md`, 아직 미구현·미착수)

### Changed

- `VERSION.md`: Current Status를 "Project Baseline Established"로, Current Phase를 "Gameplay Expansion Planning"으로 갱신
- `ROADMAP.md`: Current Status를 "Ready for Gameplay Expansion"으로 갱신

### Fixed

- (해당 없음)

### Known Notes

- 이 항목은 게임 기능 변경이 아니라 프로젝트 관리 체계 구축이다 — 버전 번호를 올리지 않고 `[Unreleased]`로 표기한다.

---

## [0.1.0] — MVP Complete

### Added

- 3인칭 플레이어 이동(WASD), 중력, 가감속(`Player.gd`)
- 점프(바닥에 있을 때만, 공중 연속 점프 불가)
- 달리기(`sprint`)
- 마우스 기반 카메라 회전(수평/수직, 수직 각도 제한), 마우스 캡처/해제/재캡처
- 택배(`Package`) 물리 오브젝트(`RigidBody3D`) — 중력, World/Player 충돌
- Player의 제한된 `RigidBody3D` 밀기 보조(`_push_away_rigid_bodies()`)
- `ShapeCast3D` 기반 상호작용 감지(`InteractShapeCast`)
- 홀드(hold) 방식 잡기·유지·놓기(`E` 입력)
- `HoldPoint` 목표 위치로의 물리 추종(속도/가속도 상한, 최대 허용 거리 초과 시 자동 놓기)
- 던지기(마우스 왼쪽 버튼, 카메라 방향 기준 임펄스)
- 계단(13단) 및 경사로 지오메트리, 물리적으로 통과 가능
- 배송 구역(`DeliveryZone`, `Area3D`) — Package 진입 감지, 최초 1회 성공 판정, `package_delivered` 시그널
- 배송 성공 HUD(`DeliveryHUD`) — "DELIVERY COMPLETE" 및 재시작 안내 표시
- 재시작(`R` 입력, 현재 씬 전체 재로드) — 성공 전/후 모두 동작, 반복 가능
- Input Map 10개 액션(이동 4, 점프, 달리기, 상호작용, 던지기, 재시작, 마우스 해제)
- 충돌 레이어 4종(World/Player/Package/DeliveryZone) 체계

### Changed

- (해당 없음 — 최초 버전)

### Fixed

- `CharacterBody3D`의 `safe_margin` 기본값(0.001)이 `RigidBody3D`와의 접촉 시 폭발적 튕김을 유발하던 문제 → 0.08로 조정
- 잡힌 Package가 holder(Player)와 여전히 물리적으로 충돌 관계라 Player가 밀리거나 함께 공중부양하던 문제 → holder와의 `add_collision_exception_with()` 양방향 예외 처리로 해결
- 겹친 상태에서 Package를 놓을 때 침투 해소 충격으로 Player가 튕기거나 밀리던 문제 → 물리적 놓기와 충돌 예외 해제를 분리, 연속 3프레임 미겹침 확인 후 지연 복구
- HUD 표시 후 마우스로 카메라 회전이 되지 않던 문제(전체 화면 `Control`의 기본 `mouse_filter`가 마우스 입력을 소비) → `MOUSE_FILTER_IGNORE` 적용
- 계단을 걸어서 오를 수 없던 문제 → 원인 2가지 확인 후 해결: (1) Floor와 Stairs 사이 실제 존재하던 1m 간격 제거, (2) 단 높이를 0.4m → 0.15m로 낮추고 단 수를 5 → 13으로 늘려 전체 높이 유지
- 던지기 힘이 너무 약해 "던지기"가 아니라 "드롭"처럼 느껴지던 문제 → impulse 값을 실측 재탐색해 12.0 → 200.0으로 조정(수평 비행거리 약 4m)

### Known Notes

- 목표 안내(`GoalLabel`) UI 미구현(`GAME_DESIGN.md` 완료 조건에는 없음)
- 벽에 택배가 걸렸을 때의 물리 안정성 미검증(현재 레벨에 벽 지오메트리 없음)
- 상세 내용은 `KNOWN_ISSUES.md`, `TECH_DEBT.md` 참고
