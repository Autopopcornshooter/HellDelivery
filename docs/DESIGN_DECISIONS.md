# DESIGN_DECISIONS.md

이 문서는 프로젝트에서 내린 중요한 설계 결정을 기록한다.

**역할**: 왜 이렇게 설계했는가. "무엇을 만들 것인가"는 `ROADMAP.md`, "지금 구조가 어떤가"는 `docs/ARCHITECTURE.md`를 참고한다. 이 문서는 결정의 배경과 대안, 그로 인한 결과를 기록해 나중에 "왜 이렇게 했더라?"를 다시 조사하지 않아도 되게 한다.

각 항목은 실제 구현 및 `docs/TASKS.md` 작업 기록을 근거로 작성했다.

---

## DD-001 — Hold 입력 방식 (변경됨: T067에서 토글 방식으로, T071에서 다시 마우스 좌클릭 Hold 방식으로 전환, `DD-017`·`DD-019` 참고)

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

## DD-016 — 좁은 문(T066)을 두 잠벽(jamb) + 상인방으로 구성하고 Player/Package 실측 크기로 폭을 역산

- **Decision**: `NarrowDoorwayTestArea`를 `LeftWall`/`RightWall`(각각 Z축 방향으로 분리 배치된 `StaticBody3D`)과 `Lintel`(문 상단을 막는 `StaticBody3D`) 3개로 구성했다. 문 폭(clear width)은 Player `CapsuleShape3D`(기본값, 지름 1.0m)와 Package `BoxShape3D`(폭 0.8m)라는 실제 씬 값을 먼저 확인한 뒤 1.4m로 정했고, clear height는 Player 캡슐 높이(2.0m)보다 여유 있는 2.2m로 정해 수직 방향은 제약이 되지 않게 했다. 새 Collision Layer를 만들지 않고 기존 World 레이어(미지정 시 기본값 1, `TestWall`과 동일한 방식)를 그대로 사용했다.
- **Reason**: 요구된 체감 목표("Player 혼자는 어렵지 않게, Package를 정면으로 안정적으로 운반하면 통과 가능, 비스듬하거나 부주의하면 문틀에 걸릴 수 있음")를 만들려면 Player 지름(1.0m)보다는 넉넉하되 Package(0.8m)를 포함한 오블리크 접근에서는 여유가 줄어드는 폭이 필요했다. `Lintel`을 별도 오브젝트로 분리한 이유는 문 상단을 막되 clear height 이상에서만 존재하게 해 "바닥과 문틀 사이 틈 없음"과 "수직 방향은 제약하지 않음"을 동시에 만족시키기 위함이다.
- **Alternatives**: `Player.gd`/`Package.gd`의 크기나 `HoldPoint` 위치를 조정해 통과 난이도를 맞추는 방식 — 사용자가 명시적으로 배제함(기존 씬 값 변경 금지). 벽 전체를 하나의 오브젝트로 만들고 중앙에 구멍(Boolean 형상)을 뚫는 방식 — Godot `BoxShape3D`로는 직접 표현할 수 없어 배제, 대신 `TestWall`과 동일하게 여러 개의 단순 Box로 조합했다(기존 지오메트리 스타일과 일관).
- **Consequences**: 문 폭 1.4m는 여러 후보값을 헤드리스로 비교 실측한 결과가 아니라 실측 크기 기반의 단일 추론값이다(`TECH_DEBT.md` TD-011). Player 단독 중앙 통과는 헤드리스로 성공을 확인했지만, "조심하면 통과 가능"이라는 체감 난이도 자체는 사용자 수동 테스트 결과에 따라 폭을 재조정해야 할 수 있다. 상호작용 가시선 검사·Hold 차단 자동 Release(T065, DD-015)는 코드 변경 없이 이 새 지오메트리에도 그대로 적용되어 문틀에 걸리는 상황을 별도 구현 없이 처리했다.

## DD-017 — 잡기 조작을 Hold 방식에서 Toggle 방식으로 변경 (T067, 변경됨: T071에서 다시 좌클릭 Hold+스윙 릴리즈로 전환, `DD-019` 참고)

- **Decision**: `Player.gd`의 `_handle_interact_input()`을 `E`(`interact`) `just_pressed` 엣지 하나만으로 판단하는 토글 로직으로 바꿨다. 잡은 것이 없을 때 누르면 감지된 대상에 `grab()`을, 잡은 것이 있을 때 누르면 `release()`를 호출한다(`if/elif` 단일 분기라 같은 입력에서 놓기와 잡기가 동시에 일어나지 않는다). `just_released`에는 아무 로직도 남기지 않았다. Toggle 전용 상태 변수는 추가하지 않았다 — 기존 `held_package`/`Package.is_held`를 그대로 현재 상태의 단일 기준으로 사용한다.
- **Reason**: WASD 이동과 `E`를 동시에 계속 눌러야 하는 홀드 방식(DD-001)이 손가락에 부담을 준다는 사용자 피드백에 따른 명시적 조작 방식 변경 요청.
- **Alternatives**: 검토하지 않음 — 사용자가 정확한 토글 규칙(잡기/놓기 전환, `just_released` 무반응)을 직접 지정했다.
- **Consequences**: 벽 차단·`max_hold_distance` 초과 등 `Package.gd` 내부에서 발생하는 자동 Release(DD-008, DD-015)는 `E` 입력과 완전히 무관하게 동작하므로 이번 변경의 영향을 받지 않는다. 자동 Release 이후 재잡기는 여전히 새로운 `E` `just_pressed` 엣지가 있어야만 가능한데, 이는 토글 로직이 애초에 `is_action_pressed`(레벨 상태)가 아니라 `is_action_just_pressed`(엣지)만 검사하기 때문에 별도의 "자동 재잡기 방지" 상태 없이도 자연히 보장된다. 헤드리스 검증 중 연속으로 빠르게 여러 번 `E`를 누르는 시나리오에서 idle 프레임과 물리 틱이 1:1로 대응하지 않는 헤드리스 하네스 특유의 타이밍 아티팩트(각 입력 사이에 최소 한 번의 물리 틱을 보장하지 않으면 엣지를 놓칠 수 있음)를 발견해 테스트 스크립트에만 프레임 여유를 추가했다 — 실제 플레이(매 입력 사이 여러 렌더 프레임 간격)에는 영향이 없는 테스트 환경 한정 이슈로 판단했다.

## DD-018 — `max_follow_speed`를 6.0에서 7.5로 조정 (T068, 순수 스프린트 중 발생하던 Auto Release 해소)

- **Decision**: `Package.gd`의 `max_follow_speed`를 T061 Baseline Freeze 값 6.0에서 7.5로 조정했다. `follow_strength`(8.0), `follow_acceleration`(40.0), `max_hold_distance`(3.0) 등 나머지 잡기·운반 관련 값은 변경하지 않았다.
- **Reason**: T068에서 확장된 환경(계단/경사로/`TestWall`/`NarrowDoorway`/`PhysicsObjects` 포함) 재검증 중, 장애물이 전혀 없는 순수 직선 스프린트만으로도 문제가 재현됨을 헤드리스로 확인했다 — `max_follow_speed`(6.0)가 `sprint_speed`(7.0)보다 낮아 Package가 구조적으로 Player를 따라잡을 수 없고, 지속 스프린트 시 HoldPoint와의 거리가 계속 벌어지다 결국 `max_hold_distance`(3.0)를 초과해 Auto Release가 발생했다(약 18m 직선 구간에서 최대 지연 3.16~3.21m 관측). 이는 장애물·충돌과 무관하게 "정상 이동만으로 반복되는 Auto Release"에 해당하는 객관적 문제로 판단해 수정했다.
- **Alternatives**: `sprint_speed`를 낮추는 방식 — 이동 조작감(T061에서 이미 검증된 값) 자체를 바꾸는 더 넓은 범위의 변경이라 배제. `max_hold_distance`를 늘리는 방식 — 근본 원인(따라잡기 속도 부족)을 해결하지 않고 증상만 미루는 것이라 배제. `follow_strength`나 `follow_acceleration`을 함께 조정하는 방식 — 문제와 직접 관련 없는 값까지 바꾸는 것이라 배제(작업 원칙: 하나의 문제에 직접 관련된 최소 값만 수정).
- **Consequences**: `max_follow_speed`(7.5) > `sprint_speed`(7.0)가 되어, 지속 스프린트 중 발생하는 지연이 특정 평형 거리(약 follow_strength 대비 sprint_speed 비율)에서 더 이상 커지지 않고 수렴한다 — 재검증 결과 동일 구간 최대 지연이 1.02m로 감소했다. 걷기(`walk_speed=4.0`)·급회전·계단·경사로·좁은 문 등 다른 이동 시나리오에서는 원래도 문제가 없었으므로(자동 검증 확인) 영향이 없다. 조작감 자체(더 빠릿하게 느껴지는지 등)는 자동 검증 대상이 아니라 사용자 수동 테스트가 필요하다.

## DD-019 — Package 전용 잡기 구조를 `GrabbableBody` 범용 클래스로 일반화 (T071, 클래스 구조는 T072에서도 유지)

- **Decision**: `Package.gd`에 있던 `grab()`/`release()`/`throw()`/HoldPoint 추종/자동 놓기/holder collision exception/지연된 충돌 복구 전체를 신규 `scenes/objects/GrabbableBody.gd`(`class_name GrabbableBody extends RigidBody3D`)로 이관했다. `Package.gd`는 `class_name Package extends GrabbableBody` 두 줄로 축소되고, `package`/`grabbable` 그룹과 고유 크기·물리값만 씬에 남는다. PhysicsBarrel/PhysicsCrate/SmallPhysicsBox도 `GrabbableBody.gd`를 스크립트로 붙이고 `grabbable` 그룹을 추가해 동일하게 잡을 수 있게 했다(물리 파라미터·collision layer/mask는 무변경).
- **Reason**: 사용자가 "Package뿐 아니라 PhysicsBarrel/Crate/SmallBox도 잡을 수 있어야 한다"고 명시적으로 요청했다. 상속을 통한 일반화가 가장 직접적인 해법이었다.
- **Alternatives**: 각 오브젝트에 별도 스크립트를 복사하는 방식 — 4곳에서 동일 로직을 유지보수해야 해 배제. Grabbable을 담당하는 별도 Manager/Component를 만들어 각 오브젝트에 붙이는 방식(컴포지션) — Godot의 `RigidBody3D` 상속 구조와 자연스럽게 맞지 않고, 이 프로젝트 규모에서 상속 하나로 충분한데 컴포지션 계층을 더하는 것은 과도한 추상화로 판단해 배제.
- **Consequences**: `Player.gd`가 참조하는 타입이 `Package`에서 `GrabbableBody`로 넓어져(`held_grabbable`, `_detected_grabbable`), 향후 잡을 수 있는 오브젝트가 늘어나도 `Player.gd`를 다시 수정할 필요가 없다. `DeliveryZone.gd`는 여전히 `package` 그룹만 검사하므로 Barrel/Crate/SmallBox를 배송해도 성공 처리되지 않는다(요구사항대로 유지).

## DD-020 — 질량 기반 이동 예산과 정적/동적 충돌 분리 (T071, 변경됨: T072에서 Force-Based Grab으로 대체, `DD-022`·`DD-023` 참고)

- **Decision**: 고정 `follow_acceleration`(Package 전용 40.0)을 모든 `GrabbableBody`가 공유하는 `max_carry_force`(600.0)로 대체하고, 실제 가속 상한은 `effective_acceleration = max_carry_force / mass`로 각 오브젝트의 질량에서 매 프레임 계산한다. 동시에 Hold 경로 차단(자동 놓기) 판정의 Ray Query 마스크를 기존 World+Package+PhysicsObject(21)에서 **World만(1)**으로 좁혔다.
- **Reason**: 사용자가 두 가지 문제를 지적했다 — (1) 무거운 Crate를 몸으로 밀 때와 달리, 잡은 Package로 Crate를 밀면 비현실적으로 쉽게 밀림(질량이 이동 저항에 반영되지 않음). (2) 잡은 오브젝트가 다른 Package나 환경 물리 오브젝트에 스치기만 해도 Hold가 풀림 — 기존 마스크(21)가 동적 오브젝트도 "차단"으로 인식했기 때문. `max_carry_force=600.0`은 기존 Package `follow_acceleration(40.0)×mass(15.0)`에서 역산한 값으로, Package 자신의 체감은 그대로 보존된다.
- **Alternatives**: 오브젝트별로 별도 `follow_acceleration` export 값을 두는 방식 — 질량과 별개로 값을 관리해야 해 "질량이 클수록 느리다"는 관계를 코드가 보장하지 못하고 매번 손으로 맞춰야 함, 배제. Hold 차단 마스크를 아예 없애는 방식(항상 거리 기반 자동 놓기만 사용) — 벽 뒤로 Hold가 계속 유지되는 T065의 원래 버그가 재발하므로 배제. 정적/동적 판정을 하나의 마스크로 유지하되 예외 목록을 추가하는 방식 — 예외 목록 관리가 오히려 더 복잡해 배제.
- **Consequences**: 헤드리스 검증으로 SmallBox(120)>Package(40)>Barrel(30)>Crate(24) 순서의 가속 차이를 확인했다. 동적 오브젝트 접촉은 이제 자동 놓기 사유가 아니며, 실제 거리가 `max_hold_distance`를 넘을 때만(정적 차단과 별개 조건으로) 자동 놓기된다. `TECH_DEBT.md` 후보: 정확한 `max_carry_force` 값은 실측 후보 비교가 아닌 역산값이라 사용자 수동 테스트 후 조정될 수 있다.

## DD-021 — 카메라 스윙 기반 릴리즈로 고정 Throw 대체 (T071, 변경됨: T072에서 별도 release impulse 자체를 제거, `DD-024` 참고)

- **Decision**: `Player.gd`의 `_handle_throw_input()`과 `throw_impulse_strength`, `Package`의 고정 임펄스 `throw()`를 전부 제거했다. 대신 `GrabbableBody`가 잡힌 동안 매 물리 프레임 `HoldPoint`의 실제 이동 속도를 지수평활로 추적(`_smoothed_hold_velocity`)해 holder 자신의 이동 속도를 뺀 `_rotational_hold_velocity`를 유지하고, 수동 놓기(`release(true)`) 시 현재 `linear_velocity`는 보존한 채 이 스윙 속도(최대 `_MAX_SWING_SPEED=12.0`)만큼 순수 가산 임펄스(`_SWING_IMPULSE_GAIN=8.0`, 질량으로 나누지 않음)를 적용한다. 정적/거리 자동 놓기에는 이 임펄스를 적용하지 않는다.
- **Reason**: 사용자가 "고정 Throw 버튼과 고정 임펄스가 어색하다"고 지적하며, 화면을 빠르게 회전하며 놓으면 최근 회전 속도에 비례해 던져지는 스윙 방식을 명시적으로 요청했다.
- **Alternatives**: 카메라 각속도(라디안/초)를 직접 선속도로 환산하는 방식 — HoldPoint가 Player 중심에서 오프셋되어 있어 실제 물체가 그리는 원호 속도와 카메라 각속도가 비례하지 않아 부정확함, 배제. 목표 속도와 현재 속도의 차이를 그대로 impulse로 적용하는 방식(gap-closing) — 시제품 검증 중 정지 상태에서도 잔여 추종 속도를 "취소"하려는 보정 임펄스가 튀는 부작용을 헤드리스로 발견해, 순수 가산 방식(현재 속도 보존 + 스윙 속도만 추가)으로 변경했다. 오브젝트별 던지기 배율 추가 — 사용자가 명시적으로 배제(질량 기반 물리로 자연히 구분되어야 함).
- **Consequences**: 헤드리스 검증으로 정지 릴리즈는 거의 추가 속도가 없고(≈1.2), 빠른 회전 릴리즈가 느린 회전보다 빠르며, 동일 스윙에서 SmallBox>Package>Barrel>Crate 순으로 빠르게 날아감을 확인했다. 정확한 게인·최대 속도 값은 실측 후보 비교가 아닌 초기 추정값이므로 `TECH_DEBT.md` 후보로 남기고, 사용자 수동 테스트("던지기 손맛") 결과에 따라 조정될 수 있다.

## DD-022 — 속도 강제 추종(`move_toward`)을 Force-Based Spring-Damper Grab으로 전환 (T072)

- **Decision**: `GrabbableBody._integrate_forces()`에서 `linear_velocity`를 목표 속도로 직접 덮어쓰던 `move_toward()` 방식을 완전히 제거하고, 매 프레임 `apply_force()`로 실제 물리적인 힘만 가하는 방식으로 바꿨다. `desired_force = displacement * grab_spring_strength + relative_velocity * grab_damping`(Spring-Damper)을 계산해 Grabber 1명의 힘 상한(`max_force_per_grabber`)으로 clamp한 뒤 적용한다. 잡힌 물체는 여전히 매 프레임 gravity를 그대로 받고, freeze/kinematic 전환도 하지 않는다.
- **Reason**: 사용자가 명시적으로 "플레이어가 물체의 위치나 속도를 직접 제어하지 않는다. 플레이어의 손이 물체의 실제 잡힌 지점에 제한된 힘을 지속적으로 가한다"는 설계 철학을 지정했다. 속도를 직접 clamp/move_toward하는 기존 방식은 이 철학과 근본적으로 맞지 않고(질량이 실제 이동 저항으로 작동하지 못함), 잡은 물체가 다른 물체를 밀 때 사실상 무한한 힘처럼 작동하는 문제의 구조적 원인이기도 했다.
- **Alternatives**: Godot 내장 `Generic6DOFJoint3D`/`PinJoint3D` 등 Joint 노드를 HandPoint와 물체 사이에 동적으로 생성하는 방식 — Joint는 일반적으로 두 `PhysicsBody3D` 사이의 고정 연결을 전제해, 여러 Grabber가 런타임에 자유롭게 추가/제거되는 구조나 Grabber별 힘 상한을 개별 적용하는 요구에는 `apply_force()`를 직접 쓰는 것보다 오히려 더 복잡한 우회가 필요해 배제. PID 컨트롤러(P+I+D) — 이 프로젝트 규모에서 적분(I) 항까지는 과도한 설계로 판단, Spring(P)+Damping(D)만으로 충분해 배제.
- **Consequences**: 물체는 이제 HandPoint를 정확히 따라가지 않고 뒤처지며(Spring 평형 처짐 `mass*gravity/grab_spring_strength`), 이 처짐이 질량이 클수록 자연히 커져 "무거운 물체가 손 아래에서 처지고 출렁인다"는 요구를 별도 분기 없이 만족한다. 헤드리스 실측(1 Grabber, 1초간 최고 상승 속도)으로 SmallBox 6.43>Package 2.80>Barrel 2.51>Crate 1.27 m/s 순서를 확인했다 — 정확한 `grab_spring_strength`/`grab_damping`/`max_force_per_grabber` 값은 `TECH_DEBT.md` TD-013 참고.

## DD-023 — 단일 `holder` 구조를 다중 Grab Connection(`grab_connections: Dictionary`) 구조로 재설계 (T072)

- **Decision**: `GrabbableBody`의 `holder: CollisionObject3D`/`hold_point: Node3D` 단일 참조를 `grab_connections: Dictionary`(Node3D grabber → `_GrabConnection`)로 바꿨다. 각 연결은 `grabber`/`target_point`/`local_grab_point`/`max_force`/속도 추적 상태를 개별로 갖고, `add_grabber()`/`remove_grabber()`/`has_grabber()`/`get_grabber_count()`로 조작한다. 거리 초과·정적 차단 판정도 연결 단위로 개별 수행해, 한 연결만 문제가 있어도 그 연결만 해제되고 나머지는 유지된다.
- **Reason**: 이번 작업의 설계 철학이 "여러 Grabber가 같은 물체를 동시에 잡을 수 있고, 각자의 제한된 힘이 합산된다"는 협동 운반을 전제로 했다. 기존 단일 `holder` 구조로는 애초에 두 번째 Grabber를 표현할 방법이 없었다(`TECH_DEBT.md` TD-009).
- **Alternatives**: `Area3D` 기반으로 근처 Grabber를 매 프레임 스캔해 자동으로 힘을 합산하는 방식 — "누가 명시적으로 grab을 시도했는가"라는 의도가 사라지고 우발적 다중 연결이 생길 위험이 있어 배제. Grabber마다 별도 `GrabbableBody` 파생 스크립트 인스턴스를 만드는 방식 — 오브젝트 하나에 스크립트가 여러 개 붙는 구조가 되어 Godot 노드 모델과 맞지 않아 배제.
- **Consequences**: `Player.gd`는 여전히 자신의 단일 `held_grabbable` 참조만 관리하면 되고(싱글플레이 조작 자체는 단순), `GrabbableBody` 쪽 구조만 다중을 전제한다. 실제 온라인/로컬 멀티플레이 네트워크 동기화는 이번 범위가 아니며, 이 구조는 그 물리적 기반만 제공한다(`TECH_DEBT.md` TD-009 해결 항목 참고). 헤드리스 검증으로 Grabber A를 제거해도 Grabber B 연결이 유지되고, 마지막 연결 제거 시 속도가 급변하지 않음(운동량 보존)을 확인했다.

## DD-024 — Player collision exception 완전 제거, 실제 Grab Point에 힘 적용으로 torque 발생 (T072 최초 구현, **DD-025에서 collision exception 부분만 정정**)

- **Decision**: Grab 시 `add_collision_exception_with()`를 호출하던 코드와, release 후 지연된 예외 복구(`_pending_collision_restore` 등, T065부터 존재)를 전부 삭제했다. 대신 클릭 시점에 `GrabShapeCast.get_collision_point()`로 얻은 실제 표면 충돌 지점을 물체 로컬 좌표(`local_grab_point`)로 저장하고, 매 프레임 그 지점에 `apply_force(force, offset)`(offset = 월드 Grab Point − 물체 원점)으로 힘을 가한다.
- **Reason**: 사용자가 "Grab 중에도 물체와 Player가 정상적으로 충돌해야 하고, collision exception을 제거해야 한다"고 명시적으로 요청했다. HoldPoint가 항상 Player 캡슐 바깥(전방 1.5m)에 위치하므로, exception 없이도 물체가 자연스럽게 Player 앞에 머무를 것으로 판단했다. 또한 물체 중심이 아닌 실제 클릭 지점에 힘을 가하면 모서리를 잡았을 때 자연스러운 torque(기울어짐·회전)가 생긴다는 요구도 이 방식으로 함께 만족된다.
- **Alternatives**: exception은 유지하되 "물체가 Player 안으로 들어가면 매 프레임 바깥으로 밀어내는" 별도 보정 코드를 추가하는 방식 — 사용자가 명시적으로 금지("Player와 물체 충돌 비활성화", "물체를 Player 밖으로 매 프레임 텔레포트" 금지 목록에 해당)해 배제. 힘을 항상 물체 중심에만 적용하고 별도로 회전만 흉내 내는 방식(연출성 회전) — 실제 물리 시뮬레이션이 아니게 되어 이번 설계 철학("실제 힘을 가하는 Physics Grab")과 맞지 않아 배제.
- **Consequences**: 헤드리스 검증으로 Grab 중 `get_collision_exceptions()`가 항상 빈 배열임을 확인했고(예외가 전혀 생성되지 않음), Player가 3초간 계속 접근하거나 좌우로 빠르게 스윙해도 물체가 Player 몸 안으로 들어가지 않았다(최소 거리 0.35m 이상 유지). 무게중심을 정확히 잡고 당기면 회전이 거의 없는 반면, 중심에서 벗어난 지점을 잡으면 뚜렷한 회전이 발생함을 대조 실험으로 확인했다. 지연된 collision exception 복구 관련 코드(`_RESTORE_SEPARATION_FRAMES`, `_RESTORE_WARN_FRAMES`, `_is_overlapping_holder()` 등)는 더 이상 필요 없어 전부 삭제되었다. **정정(T072 결함 수정, DD-025)**: 이 판단은 실제 플레이에서 틀린 것으로 드러났다 — exception 없이 물체가 Player 몸에 직접 부딪히면 `move_and_slide()`가 Player를 밀어내는 반작용이 발생해, collision exception과 지연 복구 메커니즘 자체는 `GrabCollisionBarrier`를 매개로 재도입되었다. Grab Point에 직접 힘을 가해 torque가 발생한다는 부분은 변경 없이 유효하다.

## DD-025 — `GrabCollisionBarrier`로 Player collision exception 재도입 (T072 결함 수정 + 후속 정정)

- **Decision**: `Player.tscn`에 `GrabCollisionBarrier`(`AnimatableBody3D`, Player 캡슐보다 약간 큰 `CylinderShape3D`, 신규 collision layer 6 `GrabBarrier`(값 32), `collision_mask=0`)를 자식으로 추가했다. `GrabbableBody.add_grabber()`가 grabber를 `CollisionObject3D`로 판별할 수 있으면 실제 Player 몸과 `add_collision_exception_with()`를 양방향으로 걸고, 자신의 `collision_mask`에 barrier 비트(32)를 추가해 대신 `GrabCollisionBarrier`와 충돌하게 한다. `remove_grabber()`는 즉시 복구하지 않고 `intersect_shape()`로 연속 3프레임 미겹침이 확인된 뒤에만 exception과 mask 비트를 복구한다(`_barrier_hold_count`로 여러 Grabber 중 마지막이 분리될 때만 복구). 이어서, `GrabCollisionBarrier`(`sync_to_physics=true`)가 일반 자식 노드처럼 부모 Transform 변경을 자동으로 따라가지 않는다는 것이 별도로 드러나, `Player.gd`의 `_physics_process()`에서 `move_and_slide()` 직후 `grab_collision_barrier.global_transform = global_transform`으로 매 프레임 명시 동기화를 추가했다.
- **Reason**: DD-024에서 "HoldPoint가 항상 Player 캡슐 바깥에 있으니 exception 없이도 관통이 방지된다"고 판단했으나, 사용자가 실제 플레이에서 "잡은 물체와 충돌하면 Player가 밀리거나 튄다"고 재현 보고했다. 원인은 Spring 힘이 물체를 Player 쪽으로 계속 압박하면 `move_and_slide()`가 이를 겹침으로 해석해 Player를 반대 방향으로 재배치하는 것이었다(T064 DD-006의 kinematic-vs-dynamic 접촉 해석 특성의 역방향 사례). "물체와 Player가 항상 정상 충돌해야 한다"는 원래 요구는 유지하면서 이 반작용만 없애려면, 실제 Player 몸과의 충돌과 "잡은 물체를 막는" 역할을 분리해야 했다. 이후 같은 결함이 재현된다는 재보고("아직 플레이어 통과하는데 의도한건가?")를 조사한 결과, `GrabCollisionBarrier`가 Player를 한 번도 따라 움직이지 않고 최초 스폰 위치에 고정되어 있었음이 헤드리스 격리 테스트로 드러났다 — `AnimatableBody3D`는 이동 플랫폼처럼 스크립트가 매 프레임 직접 옮겨줘야 하는 노드 타입이었다.
- **Alternatives**: exception을 완전히 없앤 채 물체 쪽 힘 계산 자체를 조정해 Player를 밀지 않도록 유도하는 방식 — Spring-Damper 힘은 목표(HoldPoint)를 향해 물체를 당기는 것이 전부이므로, "Player 근처에서는 힘을 줄인다"는 식의 특수 케이스를 추가해야 해 이번 설계 철학(위치 기반 특수 처리 없이 실제 힘만 가함)과 어긋나 배제. Player의 `CharacterBody3D` 자체를 물체에 대해 kinematic 무시하도록 설정하는 방식 — Godot에서 `CharacterBody3D`는 항상 자신의 이동 로직(`move_and_slide()`)으로 충돌을 해석하므로 임의의 RigidBody만 선택적으로 무시하게 만들 표준적인 방법이 없어 배제.
- **Consequences**: 헤드리스 검증(결함 수정 36개 + 후속 정정 37개, 모두 3회 연속 PASS)으로 Player 압착 시 수평 이동량 0.1m 미만, 빠른 연속 스윙 시에도 관통 없음(수정 전 최소 거리 0.51m → 수정 후 0.98m)을 확인했다. Grab 중 `get_collision_exceptions()`가 항상 비어있다는 DD-024의 서술은 더 이상 사실이 아니며, 이제는 Grabber별로 개별 관리되는 예외가 존재한다(`docs/TASKS.md` T072 결함 수정 섹션, `docs/ARCHITECTURE.md` 섹션 10.4·16 참고). `TECH_DEBT.md`에 새 항목을 만들지 않은 이유는 이 barrier 반경(0.55m)이 "Player capsule(0.5m)보다 약간 크게"라는 목표로 정한 값이며, 사용자가 T072 최종 승인에서 관통·밀림 없음을 이미 확인했기 때문이다.
