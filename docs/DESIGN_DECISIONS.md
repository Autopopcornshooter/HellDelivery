# DESIGN_DECISIONS.md

이 문서는 프로젝트에서 내린 중요한 설계 결정을 기록한다.

**역할**: 왜 이렇게 설계했는가. "무엇을 만들 것인가"는 `ROADMAP.md`, "지금 구조가 어떤가"는 `docs/ARCHITECTURE.md`를 참고한다. 이 문서는 결정의 배경과 대안, 그로 인한 결과를 기록해 나중에 "왜 이렇게 했더라?"를 다시 조사하지 않아도 되게 한다.

각 항목은 실제 구현 및 `docs/TASKS.md` 작업 기록을 근거로 작성했다.

---

## DD-001 — Hold 입력 방식

- **Decision**: `E`를 누르는 동안 잡은 상태를 유지하는 홀드(hold) 방식. 누를 때마다 전환되는 토글 방식은 사용하지 않는다.
- **Reason**: `docs/ARCHITECTURE.md` 섹션 10.2에서 이미 확정. 놓기 입력을 별도로 두지 않아도 되어 조작이 단순해진다.
- **Alternatives**: 토글 방식(한 번 누르면 잡고, 다시 누르면 놓음) — 검토했으나 채택하지 않음.
- **Consequences**: `E` 해제와 놓기가 같은 입력 생명주기 안에 있어 로직이 단순해졌다(`Player.gd`의 `_handle_interact_input()` 하나로 처리). 다만 장시간 운반 시 키를 계속 눌러야 한다.

## DD-002 — Package = RigidBody3D + 물리적 추종

- **Decision**: `Package`를 `RigidBody3D`로 유지하고, 잡힌 동안 목표 위치(`HoldPoint`)로 매 물리 프레임 속도를 계산해 추종시킨다(`docs/ARCHITECTURE.md` 섹션 10.1의 A안).
- **Reason**: 구현이 단순하고, 잡힌 동안에도 계속 물리 바디로 존재해 지형과의 충돌이 자연스럽게 유지된다.
- **Alternatives**: `PinJoint3D` 등 임시 Joint 결합(B안, 강성/감쇠 튜닝이 까다로움), `Player`의 자식으로 재부모화 + Freeze(C안, 구현은 단순하지만 다인 운반 확장을 구조적으로 막음).
- **Consequences**: 잡는 동안에도 물리 시뮬레이션이 계속되어 holder와의 충돌 처리가 필요해졌다 — 이 문제가 DD-007(Collision Exception)과 DD-008(Delayed Collision Restore)로 이어졌다.

## DD-003 — HoldPoint 구조

- **Decision**: `HoldPoint`(`Marker3D`)를 `CameraPivot`의 자식으로 두고, 전방(-Z) 1.5m 오프셋을 적용한다.
- **Reason**: 최초 설계는 오프셋 없이 `CameraPivot` 원점(=Player 원점)에 위치했으나, 실측 중 Package가 Player 캡슐 중심으로 파고들어 충돌 반응이 계속 부딪히는 불안정을 발견했다(T042).
- **Alternatives**: 오프셋 없음(최초 설계), 카메라 회전과 무관하게 수평 회전만 따르는 별도 피벗으로 `HoldPoint`를 분리(`ARCHITECTURE.md`에서 향후 검토 대상으로만 남겨둠, MVP-1에서는 채택하지 않음).
- **Consequences**: 짐칸 위치가 카메라 정면에 자연스럽게 형성된다. 카메라를 위아래로 크게 돌리면 `HoldPoint`도 함께 움직여 운반 조작에 영향을 주지만(T045에서 실측), 불안정성(진동, 튕김)은 확인되지 않았다.

## DD-004 — DeliveryZone 구조

- **Decision**: `Area3D` + `body_entered` 시그널 + `is_delivered: bool` 플래그로 최초 1회만 성공 판정.
- **Reason**: 상시 겹침 목록 관리 없이 가장 단순하게 구현 가능. `package` 그룹 검사로 타입 결합도를 낮춘다.
- **Alternatives**: 검토되지 않음 — 원 설계(`docs/ARCHITECTURE.md` 섹션 12) 그대로 구현됨.
- **Consequences**: T050(감지만, 재진입마다 재출력)과 T051(성공 상태 관리, 최초 1회만) 두 단계로 나누어 구현해 각 단계를 독립적으로 검증할 수 있었다.

## DD-005 — Restart 방식

- **Decision**: `get_tree().reload_current_scene()`으로 현재 씬 전체를 재로드한다. 개별 노드 리셋 로직은 만들지 않는다.
- **Reason**: MVP-1에는 저장해야 할 영속 상태가 없어 씬 재로드만으로 충분하다(`docs/ARCHITECTURE.md` 섹션 12).
- **Alternatives**: 각 노드(Player 위치, Package 상태 등)를 스크립트로 개별 초기화 — 검토했으나 복잡도 대비 이점이 없어 채택하지 않음.
- **Consequences**: 구현이 매우 단순하고, 잡기 참조·collision exception·pending restore 상태까지 전부 새 인스턴스로 자동 초기화된다(실측 확인). 다만 향후 저장/진행도 시스템이 생기면(Phase 8 이후) 이 방식은 재검토가 필요하다.

## DD-006 — Player Push Helper

- **Decision**: `Player.gd`에 `_push_away_rigid_bodies()`를 추가해, `get_slide_collision()` 순회로 접촉한 `RigidBody3D`에 수평 방향 impulse를 직접 적용한다. Player의 이동 의도 방향과 접촉 법선이 일치할 때만, 대상의 push_direction 성분 속도가 `max_push_speed`를 넘지 않을 때만 적용한다.
- **Reason(최초 판단 — T064에서 정정됨)**: 최초 구현 당시에는 "`CharacterBody3D.move_and_slide()`는 부딪힌 `RigidBody3D`에 힘을 자동으로 전달하지 않는다(Godot의 기본 동작)"고 판단해, "Package를 몸으로 밀 수 있다"는 요구사항을 만족하려면 직접 구현이 유일한 방법이라고 결론지었다.
  - **정정(T064, PhysicsCrate를 밀 때 발생한 화면 떨림 원인 조사 중 확인)**: `push_force`를 0으로 두고 격리 헤드리스 테스트를 한 결과, Godot/Jolt의 `CharacterBody3D`(kinematic) ↔ `RigidBody3D`(dynamic) 접촉 해석만으로도 RigidBody가 Player 속도만큼 밀려나가는 것을 확인했다. 즉 "move_and_slide가 힘을 전혀 전달하지 않는다"는 최초 서술은 부정확했다 — 엔진의 kinematic-vs-dynamic 접촉 해석 자체가 raw한 형태로 RigidBody를 이동시킨다.
  - `_push_away_rigid_bodies()`는 이 움직임을 **"처음 가능하게 만드는 유일한 수단"이 아니라**, 엔진의 raw 접촉 해석 위에 **이동 의도·충돌 법선·최대 밀기 속도 제한**이라는 명시적 규칙을 얹어 수평 밀기 반응을 더 예측 가능하고 통제된 형태로 만드는 보조 로직이다.
- **Alternatives**: 없음 — 정정 이후에도 "이동 의도와 무관할 때는 밀지 않기", "상하 접촉 필터링", "최대 밀기 속도 제한" 같은 통제된 반응은 엔진 raw 동작만으로는 얻을 수 없어 이 로직 자체는 여전히 유효하다.
- **Consequences**: `push_force` 값을 여러 차례 실측 조정해야 했다(8.0 → 40.0 → 220.0, mass=15/friction=0.7 기준 정지마찰 저항 ≈103N을 확실히 넘도록). 상하 접촉(상자 위에 서 있는 경우)은 필터링해 오작동을 방지했다. 위 정정에도 불구하고 기존 구현은 변경하지 않았다 — 통제된 밀기 반응을 위해 여전히 필요하기 때문이다(`DD-014` 참고).

## DD-007 — Collision Exception (holder-Package 충돌 예외)

- **Decision**: `grab()` 성공 시 `add_collision_exception_with()`를 Package-holder 양방향으로 등록하고, `release()`에서 해제한다.
- **Reason**: 잡힌 Package가 holder와 여전히 물리적 충돌 관계라, 추종 힘이 엔진의 충돌 반응과 부딪혀 Player가 밀리거나 Package를 발밑의 바닥으로 오인해 함께 공중부양하는 문제가 실제 플레이 피드백과 헤드리스 실측으로 확인되었다(T042).
- **Alternatives**: `collision_layer`/`mask` 전체 변경 — 사용자가 명시적으로 배제함. Package는 World·다른 Package와는 계속 충돌해야 하고, 향후 다인 멀티플레이 확장 시 레이어 전체 토글은 여러 Player를 구분해서 처리할 수 없어 정확성이 떨어진다.
- **Consequences**: 놓는 순간 두 물체가 겹쳐 있으면 예외를 즉시 해제할 수 없다는 새로운 문제로 이어졌다 — DD-008로 해결.

## DD-008 — Delayed Collision Restore (지연된 충돌 복구)

- **Decision**: `release()`를 물리적 놓기(즉시, `is_held=false`)와 충돌 예외 해제(지연)로 분리한다. 매 물리 스텝 `intersect_shape()`로 holder와의 실제 겹침을 검사해, 연속 3프레임 미겹침이 확인된 뒤에만 `remove_collision_exception_with()`를 실행한다. 겹침이 5초 이상 지속되면 경고를 1회만 출력하고 강제 복구는 하지 않는다.
- **Reason**: 겹친 상태에서 충돌을 즉시 복구하면 침투 해소 충격으로 Player가 튕기거나 밀리는 문제가 실제 플레이에서 발견되었다.
- **Alternatives**: 고정 타이머로 일정 시간 후 강제 복구 — 사용자가 명시적으로 배제함(겹침 여부와 무관하게 복구되어 근본 해결이 아님).
- **Consequences**: `intersect_shape()`가 collision exception과 무관하게 실제 겹침을 정확히 반환한다는 사실을 헤드리스로 직접 검증한 뒤 채택했다. 대기 중 Package가 `sleep` 상태로 넘어가면 겹침 감시 자체가 멈추는 부작용을 발견해, 대기 중에는 `sleeping=false`를 강제하는 로직을 추가했다.

## DD-009 — Safe Margin 조정

- **Decision**: Player(`CharacterBody3D`)의 `safe_margin`을 기본값 0.001에서 0.08로 상향한다.
- **Reason**: `RigidBody3D`(Package) 위에 설 때 매 프레임 겹침 보정이 과도하게 발생해 폭발적으로 튕기는 문제의 근본 원인이 `safe_margin`이었음을 헤드리스 실측으로 확인했다(T040).
- **Alternatives**: 문제의 근본 원인을 찾기 전에는 Package의 `mass`/`friction`/`damp` 등을 조정하는 시행착오를 거쳤으나 효과가 없었다.
- **Consequences**: 이 발견 이후, "겉보기 증상"이 아니라 엔진 파라미터의 실제 동작을 실측으로 먼저 확인하는 접근이 프로젝트 전반의 작업 방식으로 자리잡았다(예: 계단 통과 불가 문제의 근본 원인을 Floor-Stairs 간 1m 간격으로 추적한 것도 동일한 접근).

## DD-010 — PrototypeLevel 구조 (Environment / Gameplay / UI 그룹)

- **Decision**: `PrototypeLevel` 루트 아래 `Environment`(지형)/`Gameplay`(`Player`+`Package`+`DeliveryZone`)/`UI`(`DeliveryHUD`) 3개 그룹 노드로 구성한다.
- **Reason**: 최초 씬 뼈대 생성(T020) 시점에 도입되어, 관련 노드를 목적별로 그룹화해 씬 트리 탐색을 쉽게 한다.
- **Alternatives**: `docs/ARCHITECTURE.md`의 원래 다이어그램은 `Player`/`Package`/`DeliveryZone`/`Hud`를 루트 직계 자식으로 그렸다(그룹 없음).
- **Consequences**: 기능적 차이는 없다(단순 계층 구조 차이). 문서와 구현이 T063 이전까지 불일치했던 사례 중 하나로, T063에서 문서를 실제 구현에 맞춰 동기화했다.

## DD-011 — 계단 형상을 실측 기반으로 결정

- **Decision**: 계단 단 높이를 문서에서 미리 확정하지 않고, `CharacterBody3D`(기본 `CapsuleShape3D`, radius 0.5)가 점프 없이 넘을 수 있는 한계를 헤드리스로 직접 측정(단일 단 기준 0.18m까지 성공, 0.19m부터 실패)한 뒤 안전 마진을 둔 0.15m로 확정했다.
- **Reason**: 최초 계단(단 높이 0.4m)이 실제로는 걸어서 오를 수 없다는 문제가 T062 재검토에서 발견되었다(T045가 원래 이 위험을 검증하는 작업이었으나 일정상 T050 이후로 순서가 밀리며 뒤늦게 발견됨).
- **Alternatives**: 경험적 감(느낌으로 적당한 높이 선택) — 배제하고 반드시 실측으로 확정.
- **Consequences**: 단 수를 5 → 13으로 늘려 전체 높이(2.0m)를 유지해야 했다. 또한 `Floor`와 `Stairs` 사이에 실제로 존재하던 1m 간격(설계 당시 의도치 않게 남은 공백)이 더 결정적인 원인이었음도 함께 발견되어 제거했다.

## DD-012 — 던지기 힘을 실측 재탐색으로 결정

- **Decision**: `throw_impulse_strength`를 질량 기반 이론값(12.0, Δv≈0.8m/s)에서 시작해, 8개 후보 값(45~450)의 실제 비행거리를 헤드리스로 측정한 뒤 목표 체감(3~6m)에 맞는 200.0으로 확정했다.
- **Reason**: 이론값(12.0)으로는 "던지기"가 아니라 "드롭"처럼 느껴진다는 실제 플레이 피드백을 받았다. `Package`의 `linear_damp=2.0`이 예상보다 강하게 감속시켜, 초기 속도만으로는 비행거리를 예측하기 어려웠다.
- **Alternatives**: `linear_damp`/`friction` 등 다른 물리값을 함께 조정 — 사용자가 명시적으로 배제(이번 튜닝 범위를 `throw_impulse_strength` 하나로 제한).
- **Consequences**: 물리 파라미터 사이의 상호작용(damping이 impulse의 실제 효과를 크게 좌우함)이 이론 계산만으로는 예측하기 어렵다는 것을 확인했다(`TECH_DEBT.md` TD-002와 연결).

## DD-013 — 환경 물리 오브젝트를 위한 신규 Collision Layer(16)와 스크립트 없는 순수 씬 구조

- **Decision**: T064(PhysicsBarrel/PhysicsCrate/SmallPhysicsBox)에서 기존 4개 레이어(1=World, 2=Player, 4=Package, 8=DeliveryZone)에 이어 **레이어 16(PhysicsObject)을 신규 도입**하고, 세 오브젝트 모두 이 레이어를 공유(`collision_layer=16`, `collision_mask=23=1+2+4+16`)한다. 세 씬 모두 커스텀 로직이 없어 `.gd` 스크립트를 만들지 않고 `RigidBody3D` + `CollisionShape3D` + `MeshInstance3D`만으로 구성했다.
- **Reason**: Godot의 물리 충돌은 두 오브젝트 중 한쪽이라도 상대를 자신의 `collision_mask`에 포함하면 성립한다(기존 `Floor`의 `mask=1`이 `Player`(`layer=2`)를 포함하지 않는데도 정상적으로 충돌하는 것이 실증 사례). 새 오브젝트의 `mask`에 World/Player/Package/자기 레이어를 포함시키는 것만으로 `Player.tscn`/`Package.tscn`을 전혀 수정하지 않고 상호 충돌을 구현할 수 있었다. 잡기 감지(`InteractShapeCast`, mask=4)와 배송 판정(`is_in_group("package")`)도 새 레이어·그룹을 쓰지 않아 코드 변경 없이 자동으로 새 오브젝트를 무시한다.
- **Alternatives**: 오브젝트 타입별로 레이어를 분리(예: Barrel=16, Crate=32, SmallBox=64) — 세 타입 간 상호 충돌 규칙에 차이가 없어 불필요한 추상화로 판단해 배제. `Player.tscn`/`Package.tscn`의 `collision_mask`에 새 레이어를 추가하는 방식도 가능했으나, 기존 파일을 건드리지 않는 쪽이 회귀 위험이 더 낮아 채택하지 않음.
- **Consequences**: `Player.gd`/`Package.gd`/`DeliveryZone.gd`/`Player.tscn`/`Package.tscn` 무변경으로 T064를 완료할 수 있었다(헤드리스 회귀 테스트로 확인). PhysicsBarrel은 "옆으로 쓰러졌을 때 자연스럽게 굴러감" 요구사항을 만족시키기 위해 `BoxShape3D` 대신 `CylinderShape3D`(Jolt 지원 기본 프리미티브)를 사용했다 — 실제 원통 형상을 그대로 물리 형태로 써서 별도 로직 없이 구름 거동을 얻는 가장 단순한 방법으로 판단했다.

## DD-014 — Physics Interpolation 활성화 (T064 화면 떨림 조사)

- **Decision**: `project.godot`에 `physics/common/physics_interpolation=true`를 추가해 프로젝트 전역으로 물리 바디 렌더링 보간을 활성화했다.
- **Reason**: T064 사용자 수동 테스트에서 PhysicsCrate를 계속 밀 때 화면·카메라 떨림이 보고되었다. 헤드리스 `physics_frame`(실제 물리 틱) 기준으로 재측정한 결과 Player 위치는 5초 연속 푸시 동안 stall·급점프 0건으로 물리 시뮬레이션 자체는 완전히 안정적이었다 — 즉 물리 로직에는 실제 결함이 없었다. 근본 원인은 물리 틱(60Hz)과 렌더 프레임 사이에 보간이 없는 것으로 판단했다: Crate는 Barrel(구름으로 매끄럽게 흡수)이나 SmallBox(접촉이 짧음)보다 접촉이 길고 카메라에 가까워, 이 렌더링 격차가 가장 두드러지게 체감되었다(DD-006 정정 내용과 연결).
- **Alternatives**: 카메라에 스무딩/lerp를 추가해 떨림을 가리는 방식 — 사용자가 명시적으로 배제함(증상을 가릴 뿐 렌더링 정확도를 개선하지 않고, 조작 응답에 인위적 지연을 추가함). Crate의 mass/friction/damp를 낮추는 방식 — 물리 시뮬레이션 자체가 안정적이었다는 근거가 있어 채택하지 않음(근거 없는 변경 금지 원칙).
- **Consequences**: 프로젝트 전역 설정이라 Player/Package/모든 물리 오브젝트의 렌더링에 동일하게 적용된다(개별 물리 로직·수치는 변경하지 않음). 사용자 2차 수동 테스트에서 떨림 개선을 확인받아 T064 완료 승인을 받았다.

## DD-015 — 상호작용/Hold 유지에 물리적 가시선(Ray Query) 검사 추가

- **Decision**: 기존 `InteractShapeCast`(사거리 안 후보 탐색)와 `max_hold_distance`(거리 기반 자동 놓기)는 그대로 유지하고, 그 위에 물리적 가시선 검사를 별도로 추가했다. `Player.gd`는 후보를 감지 대상으로 확정하기 전에 상호작용 기준점→후보 Package 중심 Ray Query로 첫 충돌이 그 Package인지 확인한다(`_has_line_of_sight_to()`). `Package.gd`는 잡힌 동안 매 물리 프레임 HoldPoint→Package 중심 Ray Query로 차단 여부를 확인하고, 연속 3프레임 차단되면 기존 `release()` 경로를 호출한다(`_is_hold_path_blocked()`). 두 Ray Query 모두 동일한 mask(World 1 + Package 4 + PhysicsObject 16 = 21)를 사용하되, 새 Collision Layer는 만들지 않고 T064에서 이미 도입된 레이어만 재사용했다.
- **Reason**: T065 벽 테스트 구역 추가 후 사용자 수동 테스트에서 두 가지 문제가 발견되었다 — (1) 벽 너머 Package가 ShapeCast 사거리 안에만 있으면 그대로 잡힘, (2) Package를 잡은 뒤 벽이 Player-Package 사이에 들어와도 Hold가 계속 유지됨. 기존 감지·유지 로직은 거리와 사거리만 검사했을 뿐 "그 사이에 물리적으로 막힌 것이 있는가"는 전혀 검사하지 않아 발생한 문제였다.
- **Alternatives**: `InteractShapeCast`나 `HoldPoint` 자체의 크기·거리를 줄여 증상을 우회하는 방식 — 사용자가 명시적으로 배제함(문제를 가릴 뿐 벽이 없는 다른 상황에서도 사거리가 부당하게 줄어듦). 벽 collision을 비활성화하거나 Package를 순간이동시키는 방식 — 벽의 실제 물리적 존재 의미를 훼손하므로 배제. 별도의 "가시선 판정 시스템"을 공용 유틸리티/Autoload로 분리하는 방식 — 현재 사용처가 Player·Package 두 곳뿐이고 로직도 단순해 과도한 추상화로 판단해 배제, 대신 동일한 상수(mask=21)를 각 스크립트에 짧은 주석과 함께 중복 선언했다.
- **Consequences**: 상호작용 판정에 매 프레임 Ray Query가 1회, Hold 유지 중에는 물리 프레임마다 1회 추가된다(단일 Player/단일 Package 기준 비용은 무시할 수준). 차단 판정에 3프레임의 유예를 둬서 벽을 스치는 정도의 일시적 접촉으로는 놓이지 않도록 했다(`_RESTORE_SEPARATION_FRAMES`와 동일한 완충 패턴, DD-008 참고). Player와 Package 양쪽에 유사한 상수·로직이 중복되지만, 두 클래스가 서로 다른 시점(감지 vs 유지)에 서로 다른 기준점에서 검사하므로 하나로 합치면 오히려 결합도가 높아진다고 판단했다.
