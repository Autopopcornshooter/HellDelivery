# CHANGELOG.md

이 문서는 버전별 변경 내역을 [Semantic Versioning](https://semver.org/) 스타일로 기록한다.

**역할**: 무엇이 변경되었는가. "앞으로 무엇을 만들 것인가"는 `ROADMAP.md`, "지금 프로젝트 상태가 어떤가"는 `VERSION.md`를 참고한다.

실제로 구현되어 `docs/TASKS.md`에서 완료(`[DONE]`) 확인된 항목만 기록한다. 계획 단계이거나 보류된 기능은 기록하지 않는다.

---

## [Unreleased] — Gameplay Expansion (In Progress)

v0.2.0 범위의 구현 작업. `docs/TASKS.md` T064~T069·T072 전부 `[DONE]` — EPIC-01(Obstacle Course Expansion), EPIC-02(Physics Feel Tuning), EPIC-03(Multi-Package Stability), EPIC-05(Generalized Object Interaction) 완료, 사용자 최종 승인. EPIC-05는 T071 `[REVIEW]`(승인 전)로 시작했다가, 사용자 지시로 T072 "Force-Based Physics Grab"로 이동 방식 자체가 재설계되었고, Player 밀림·관통 결함 수정 2건을 거쳐 사용자 수동 테스트 승인으로 `[DONE]` 확정되었다. T070(EPIC-04, Playtest & Fun Validation)은 EPIC-05 완료로 한 차례 `[BLOCKED]`가 해제되었으나, 곧이어 사용자 지시로 T073(3인칭→1인칭 시점 전환 및 Grab 조작성 개선, `[REVIEW]`, 자동 검증 완료)이 착수되어 조작·시점이 다시 바뀌는 중이라 `[BLOCKED]`로 되돌아갔다. v0.2.0은 T073 승인과 그 이후 사용자의 실제 전체 루프 플레이·최종 재미 평가 전까지 완료 처리하지 않는다.

### Added

- 환경 물리 오브젝트 3종 신규 씬(`scenes/objects/`): `PhysicsBarrel.tscn`(원통형 드럼통, 옆으로 쓰러지면 굴러감), `PhysicsCrate.tscn`(나무 상자, 적층 가능), `SmallPhysicsBox.tscn`(작은 상자, 가볍게 밀림)(T064)
- 신규 collision layer 16(PhysicsObject) — World/Player/Package와 상호 충돌하되 배송 판정 대상에서는 제외
- `PrototypeLevel.tscn`에 `PhysicsObjects` 그룹 노드와 인스턴스 6개(Barrel 1, Crate 2[적층], SmallBox 3) 배치 — 굴림·연쇄 충돌 구역, 적층·붕괴 구역, 배송 경로 인접 구역 구성(T064)
- `PrototypeLevel.tscn`에 `WallTestArea/TestWall`(`StaticBody3D`) 수직 벽 테스트 구역 추가, 기존 World collision layer 사용(T065)
- 전역 Physics Interpolation 활성화(`project.godot`, `physics/common/physics_interpolation=true`)
- `Player.gd`/`Package.gd`에 상호작용·Hold 유지용 물리적 가시선(Ray Query) 검사 추가(T065) — 벽 등으로 막히면 감지·잡기 대상에서 제외되고, 잡은 상태에서 경로가 막히면 연속 3프레임 후 자동 Release
- `PrototypeLevel.tscn`에 `NarrowDoorwayTestArea`(`LeftWall`/`RightWall`/`Lintel`, `StaticBody3D`) 좁은 문 테스트 구역 추가, clear width 1.4m·height 2.2m, 기존 World collision layer 사용(T066)
- `PrototypeLevel.tscn`의 `Gameplay`에 `PackageB`/`PackageC` 인스턴스 추가(기존 `Package`는 유지) — 다수 Package 동시 존재 검증용(T069)
- `scenes/objects/GrabbableBody.gd` 신규(`class_name GrabbableBody extends RigidBody3D`) — 잡기/놓기/HoldPoint 추종/자동 놓기/충돌 예외/지연 복구/스윙 릴리즈를 전부 소유하는 범용 클래스(T071)
- PhysicsBarrel/PhysicsCrate/SmallPhysicsBox에 `GrabbableBody.gd` 스크립트와 `grabbable` 그룹 추가 — 3종 모두 Package처럼 직접 잡을 수 있게 됨(T071)
- Input Map에 `grab_object`(마우스 왼쪽 버튼) 액션 추가(T071)
- `GrabbableBody.gd`에 다중 Grab Connection 구조(`grab_connections: Dictionary`) 추가 — 여러 Grabber가 같은 물체를 동시에 잡고 각자의 힘이 합산되는 구조(로컬 싱글플레이에서는 항상 1개, 향후 멀티플레이 협동 운반의 물리적 기반, T072)
- `Player.tscn`에 `GrabCollisionBarrier`(`AnimatableBody3D`) 추가, 신규 collision layer 6(`GrabBarrier`, 값 32) — Grab 중인 물체만 이 레이어와 일시적으로 충돌해 Player 관통을 막으면서도 실제 Player 몸과는 항상 정상적으로 충돌하도록 분리(T072 결함 수정)
- `scenes/ui/Crosshair.gd` 신규(`class_name Crosshair extends Control`) — 화면 정중앙에 상태형 조준점(기본/조준/홀드 3단계)을 표시, `DeliveryHUD.tscn`의 자식으로 추가, `mouse_filter=IGNORE`(T073)
- `Player.gd`에 `grab_aim_state_changed(state: int)` 시그널 추가 — 기존 Grab 감지/보유 데이터를 그대로 재사용해 조준점 UI에 전달(중복 탐색 없음), `PrototypeLevel.gd`가 `DeliveryHUD.set_crosshair_state()`로 중개(T073)

### Changed

- `Player.gd`의 `E`(`interact`) 잡기 조작을 Hold 방식에서 Toggle 방식으로 변경(T067, `DD-017`) — 한 번 누르면 잡고, 다시 누르면 놓음.
- 잡기 조작을 다시 마우스 왼쪽 버튼(`grab_object`) Hold 방식으로 재변경(T071, `DD-019` 이후) — 누르면 잡고 누르고 있는 동안 유지, 놓으면 최근 카메라 스윙 속도에 비례한 릴리즈. `E`(`interact`)는 잡기·놓기와 완전히 분리되어 아무 동작도 하지 않음(향후 버튼/문/레버용으로 예약)
- `Package.gd`를 `GrabbableBody` 상속으로 축소(`class_name Package extends GrabbableBody` 두 줄), 잡기·이동·놓기 로직 전체를 `GrabbableBody.gd`로 이관(T071)
- `Player.gd`의 `InteractShapeCast`를 `GrabShapeCast`로 개명하고 감지 마스크를 Package(4)에서 Package+PhysicsObject(20)로 확장, 감지 로직을 "가장 가까운 가시선 확보 후보 우선"으로 일반화(T071)
- 잡힌 대상의 이동 가속을 고정값(`follow_acceleration`)에서 공유 `max_carry_force`를 질량으로 나눈 값으로 변경 — 무거운 오브젝트(Crate)일수록 반응이 느림(T071, **T072에서 완전히 폐기**)
- Hold 경로 차단(자동 Release) 판정을 World+Package+PhysicsObject에서 **World만**으로 좁힘 — 동적 오브젝트 접촉만으로는 더 이상 자동 Release되지 않음(T071, T072에서 연결 단위 판정으로 재구현하며 원칙 유지)
- **잡기·운반·놓기 방식을 속도 강제 추종(`move_toward`)에서 Force-Based Physics Grab으로 전면 재설계**(T072, `DD-022`~`DD-024`) — 플레이어는 물체의 위치·속도를 직접 제어하지 않고, 실제로 클릭한 표면 지점(Grab Point)에 제한된 Spring-Damper 힘만 가한다. 잡힌 물체는 항상 정상적인 `RigidBody3D`로 gravity/mass/충돌의 영향을 그대로 받는다
- Grab 중 Player collision exception을 완전히 제거(T072) — 이제 잡은 물체와 Player가 항상 정상적으로 충돌하며, 관통은 예외 처리가 아니라 HoldPoint가 항상 Player 몸 바깥에 있는 물리적 구조로 방지된다 → **T072 결함 수정에서 부분 정정**: 이 구조가 실제로는 Player를 밀어내는 반작용을 낳아, 전용 `GrabCollisionBarrier`와 Grabber별 collision exception(지연 복구 포함)을 재도입했다. HoldPoint가 항상 몸 바깥에 있다는 원래 전제 자체는 유지되지만, "예외 처리 없이" 관통을 막는다는 서술은 더 이상 사실이 아니다(아래 Fixed 참고)
- 고정 전방 Throw(T044~T068)에 이어 T071의 스윙 속도 측정+release impulse 방식도 완전히 제거(T072) — 놓는 순간 별도 impulse 없이, 잡고 있는 동안 Spring-Damper 힘이 이미 만들어 둔 실제 운동량을 그대로 유지하며 날아간다
- 단일 `holder`/`hold_point` 구조를 다중 `grab_connections` Dictionary 구조로 교체(T072) — `TECH_DEBT.md` TD-009 해소
- **기본 카메라 시점을 3인칭에서 1인칭으로 전환**(T073, 사용자 지시) — 3인칭 캐릭터 Mesh가 잡은 물체와 조준 대상을 가리는 문제를 해결하기 위함. `Player.tscn`의 3인칭용 `SpringArm3D`(spring_length=4.5)를 제거하고 `CameraPivot`을 Player 눈높이(로컬 y=0.7)로 옮겨 `Camera3D`를 그 원점에 직접 배치했다. 마우스 좌우 회전은 `CameraPivot`이 아닌 Player 자신의 `rotation.y`(yaw)가 담당하도록 분리했고(`CameraPivot`은 상하 회전만 담당), 이동 방향 계산도 Player 자신의 basis를 사용하도록 변경했다. `docs/GAME_DESIGN.md`의 "3인칭 카메라 기본" 서술과 배치되지만 사용자의 명시적 지시가 우선하며, `GAME_DESIGN.md` 자체는 이번 변경 범위에 포함되지 않아 수정하지 않았다
- `GrabShapeCast`를 `CameraPivot` 로컬 y=-0.5 오프셋에서 `Camera3D`와 완전히 같은 로컬 원점으로 재배치(T073) — Grab 판정이 항상 화면 중앙(조준점)과 구조적으로 일치하도록 함(정렬 오차 0px)
- 로컬 Player의 `MeshInstance3D`에 Visual Layer 2를 부여하고 `Camera3D.cull_mask`에서 해당 레이어를 제외(T073) — 전역 `visible=false`를 쓰지 않아 씬 트리·다른 카메라 기준으로는 여전히 존재, 자신의 카메라에서만 렌더링되지 않음

### Fixed

- PhysicsCrate를 계속 밀 때 발생하던 화면·카메라 떨림 → 원인은 물리 시뮬레이션 불안정이 아니라 물리 틱(60Hz)과 렌더 프레임 사이 보간 부재로 확인, 전역 Physics Interpolation 활성화로 해결(T064, 사용자 재테스트 승인 완료)
- 벽 너머(가려진) Package가 사거리 안에 있으면 그대로 감지·잡기가 가능하던 문제 → 상호작용 판정에 물리적 가시선 검사 추가로 해결(T065)
- Package를 잡은 뒤 벽이 Player-Package 사이에 들어와도 Hold가 계속 유지되던 문제 → Hold 유지 중 경로 차단 검사와 자동 Release 추가로 해결(T065)
- 장애물 없이 순수하게 직선으로 스프린트만 계속해도 Package Hold가 자동으로 풀리던 문제 → `max_follow_speed`(6.0)가 `sprint_speed`(7.0)보다 낮아 구조적으로 따라잡지 못하던 것이 원인, `max_follow_speed`를 7.5로 조정해 해결(T068, `DD-018`, 사용자 재테스트 승인 완료)
- 잡은 Package 등이 다른 Package/환경 물리 오브젝트에 스치기만 해도 Hold가 쉽게 풀리던 문제 → Hold 차단 판정에서 동적 오브젝트를 제외해 해결(T071, 사용자 피드백)
- 고정 Throw 임펄스가 어색하게 느껴지던 문제 → 카메라 스윙 속도 기반 릴리즈로 대체(T071, 사용자 피드백) → **T072에서 그 스윙 릴리즈 방식 자체도 제거하고 자연 운동량 유지로 재대체**
- 잡은 Package로 무거운 Crate를 밀면 비현실적으로 쉽게 밀리던 문제(속도 강제 추종 방식에서는 사실상 무한한 힘처럼 작동할 수 있었음) → Grabber 1명당 힘 상한(`max_force_per_grabber`)이 있는 Force-Based Grab으로 전환해 구조적으로 해결(T072, 사용자 지시)
- Player collision exception을 완전히 제거한 결과, 잡은 물체가 Spring 힘으로 Player 캡슐을 압박하면 `move_and_slide()` 충돌 해석상 Player가 반대로 밀려나던 문제(사용자 재현 보고) → 전용 `GrabCollisionBarrier`(`AnimatableBody3D`, 신규 collision layer 6)를 도입해 실제 Player 충돌과 "잡은 물체 차단"을 분리, Grabber별 collision exception + `intersect_shape()` 기반 지연된 안전 분리 확인으로 해결(T072 결함 수정)
- 위 수정 직후에도 실제 플레이(특히 빠른 카메라 스윙 중)에서 Player 관통이 그대로 재현되던 문제 → `GrabCollisionBarrier`가 Player의 자식 노드였음에도 `sync_to_physics` 특성상 부모 Transform 변경을 자동으로 따라가지 않아 사실상 한 번도 Player를 따라 움직이지 않고 있었던 것이 원인, `Player.gd`에서 `move_and_slide()` 직후 매 물리 프레임 명시적으로 `grab_collision_barrier.global_transform`을 동기화해 해결(T072 결함 수정 후속 정정)

### Known Notes

- 환경 물리 오브젝트의 물리 파라미터(mass/friction/damp), 좁은 문(1.4m) 폭, Export 값 전반은 모두 실측 비교가 아닌 추론/동결값으로 시작되었으나, T068 사용자 수동 테스트에서 전부 승인되어 `TECH_DEBT.md` TD-006/TD-010/TD-011이 해결 처리됨
- T071의 `max_carry_force`(600.0)·스윙 릴리즈 게인(`_SWING_IMPULSE_GAIN=8.0`, `_MAX_SWING_SPEED=12.0`)은 T072에서 이동 방식 자체가 대체되며 함께 폐기됨(`TECH_DEBT.md` TD-012, 역사 기록으로 유지)
- T072의 `grab_spring_strength`(500.0)·`grab_damping`(60.0)·`max_force_per_grabber`(300.0) 등은 각 오브젝트의 실제 mass×gravity를 기준으로 역산한 초기 추정값으로 시작했으나, 사용자 수동 테스트 승인으로 프로토타입 기준값(Baseline)으로 확정됨 — 완료를 막는 미해결 결함은 아니며, 추가 조정은 별도 Task로 진행(`TECH_DEBT.md` TD-013)
- T073의 카메라 눈높이(`CameraPivot` 로컬 y=0.7)는 여러 후보를 실측 비교하지 않은 초기 추정값 — 사용자 수동 테스트 승인 대기 중
- T073로 시점이 1인칭으로 바뀌었지만 `docs/GAME_DESIGN.md`(섹션 26, 29 등)는 여전히 "3인칭 카메라 기본"으로 서술되어 있음 — 이번 작업 문서 반영 범위 밖이라 갱신하지 않았고, 실제 구현과 불일치 상태로 남아 있음(`docs/TASKS.md` T073 "예상 위험" 참고)

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
