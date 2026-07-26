# ARCHITECTURE.md

이 문서는 정식 게임 전체를 설계하는 문서가 아니다. **싱글플레이 MVP-1을 안정적으로 구현하기 위한 최소 기술 구조**만 확정한다.

게임 기획 기준은 `docs/GAME_DESIGN.md`, 작업 규칙 기준은 `CLAUDE.md`다. 이 문서와 두 문서가 충돌하면 `docs/GAME_DESIGN.md` → `CLAUDE.md` 순으로 우선한다 (`CLAUDE.md` 섹션 9).

## 1. 문서 목적과 적용 범위

- 이 문서의 적용 범위는 **MVP-1**이다 (`docs/GAME_DESIGN.md` 섹션 27~28 기준).
- 차량, 온라인/로컬 멀티플레이, 파손·내구도 시스템, 저장 시스템, Steam 연동은 이 문서의 설계 대상에서 **제외**한다. 이 시스템들이 필요해지는 시점(`docs/GAME_DESIGN.md` 섹션 29의 Phase 5 이후)에 별도로 설계한다.
- Phase 5 이후 시스템은 MVP-1 구조를 막지 않기 위해 필요한 최소한의 확장 지점만 섹션 22에서 언급하며, 상세 설계는 하지 않는다.

## 2. 기술 환경

확인 가능한 실제 정보만 기록한다.

| 항목 | 값 | 확인 출처 |
|---|---|---|
| Godot 에디터 버전 | 4.7.1 (stable, win64) | `hell-delivery/.godot/editor/project_metadata.cfg`의 `executable_path` |
| project.godot 기록 버전 | `4.7` | `project.godot` → `config/features` |
| 스크립트 언어 | GDScript | `CLAUDE.md`, `docs/GAME_DESIGN.md` 확정 사항 |
| 렌더러 | Forward+ | `project.godot` → `config/features` |
| 렌더링 드라이버(Windows) | D3D12 | `project.godot` → `[rendering] rendering_device/driver.windows` |
| 물리 엔진 | Jolt Physics | `project.godot` → `[physics] 3d/physics_engine` |
| 프로젝트 차원 | 3D | `docs/GAME_DESIGN.md` 확정 사항 + Jolt Physics(3D 전용 물리 엔진) 설정으로 간접 확인 |
| 목표 실행 환경 | Windows PC | `docs/GAME_DESIGN.md` 확정 사항 |
| 창 스트레치 모드 | `canvas_items` / `expand` | `project.godot` → `[display]` |
| GDScript 들여쓰기 스타일 | **확인 필요** | `hell-delivery/.editorconfig`는 `charset = utf-8`만 지정, 들여쓰기 규칙 없음 (Godot 기본값은 탭이나, 프로젝트에서 명시적으로 확정된 값은 아님) |

프로젝트에는 아직 `scenes/`, `scripts/`, `assets/` 등 콘텐츠 폴더가 없다 (`project.godot`과 `icon.svg`만 존재하는 Phase 0 상태). 이 문서의 폴더/씬 구조는 이 상태를 기준으로 한 제안이다.

## 3. 프로젝트 폴더 구조

### 3.1 `scripts/` 전체 통합 vs 씬별 동봉 비교

| 방식 | 장점 | 단점 |
|---|---|---|
| `scripts/`에 전체 스크립트 통합 | 스크립트만 따로 검색하기 쉬움, 규모가 커졌을 때 레이어 분리가 명확함 | 씬과 스크립트가 물리적으로 분리되어 폴더를 오가야 함, MVP-1처럼 씬 수가 적을 때는 이점보다 탐색 비용이 큼 |
| 씬 폴더에 스크립트 동봉 | 하나의 기능(씬+스크립트)이 한 폴더에 모여 완결됨, 에디터에서 씬을 열면 관련 파일을 바로 찾을 수 있음, "각 기능은 에디터에서 테스트하기 쉬워야 한다"는 원칙과 직접 부합 | 스크립트가 아주 많아지면(수십 개) 폴더가 씬 단위로 흩어져 전체를 한눈에 보기 어려움 |

**선택**: MVP-1은 씬이 5~6개뿐이고 스크립트도 그와 거의 1:1로 대응되므로, **씬 폴더에 스크립트를 동봉하는 방식**을 채택한다. 별도의 최상위 `scripts/` 폴더는 MVP-1에서 만들지 않는다. 여러 씬이 공유하는 유틸리티 스크립트가 실제로 필요해지는 시점에 그때 `scripts/shared/` 같은 폴더를 도입한다 (지금은 존재하지 않는 문제를 미리 해결하지 않는다).

### 3.2 MVP-1 폴더 구조

```text
res://
├─ assets/
│  ├─ models/       (필요해지는 시점에 생성 — 지금은 빈 폴더를 만들지 않음)
│  ├─ materials/    (필요해지는 시점에 생성)
│  └─ textures/     (필요해지는 시점에 생성)
├─ scenes/
│  ├─ player/
│  │  ├─ Player.tscn
│  │  └─ Player.gd
│  ├─ package/
│  │  ├─ Package.tscn
│  │  └─ Package.gd
│  ├─ delivery/
│  │  ├─ DeliveryZone.tscn
│  │  └─ DeliveryZone.gd
│  ├─ level/
│  │  ├─ PrototypeLevel.tscn
│  │  └─ PrototypeLevel.gd
│  └─ ui/
│     ├─ DeliveryHUD.tscn
│     └─ DeliveryHUD.gd
└─ icon.svg (기존 파일)
```

실제 구현에서는 `ui/Hud.tscn`/`Hud.gd` 대신 `ui/DeliveryHUD.tscn`/`DeliveryHUD.gd`로 명명했다(사용자 명시적 지시, T052). 이 문서의 이후 섹션도 이 이름을 사용한다.

- 저장소 루트의 `docs/`(`GAME_DESIGN.md` 등)와 이 표의 `res://` 경로는 서로 다른 폴더다. `res://docs/`는 Godot 프로젝트 내부 경로이며, 설계 문서는 이미 저장소 루트 `docs/`에 있으므로 **`res://docs/`는 만들지 않는다** (중복 및 혼동 방지).
- `res://tests/`도 MVP-1에서 만들지 않는다. 자동 테스트 프레임워크를 아직 도입하지 않기 때문이다 (섹션 20).
- `assets/`는 실제 모델/텍스처 파일이 추가되는 시점에 하위 폴더를 생성한다. 빈 폴더를 미리 만들지 않는다.

## 4. MVP-1 씬 구성

| 씬 | 책임 | 루트 노드 | 비고 |
|---|---|---|---|
| `Main.tscn` | 게임 진입점, 향후 메뉴/씬 전환 지점 | (미생성) | MVP-1에서는 별도 파일로 만들지 않는다 — 섹션 5 참고 |
| `Player.tscn` | 이동, 카메라 조작, 상호작용 감지, 잡은 물체 요청 | `CharacterBody3D` | |
| `Package.tscn` | 물리 충돌, 잡힘/놓임/던져짐 상태와 그에 따른 물리 반응 | `RigidBody3D` | |
| `DeliveryZone.tscn` | 올바른 Package 도착 감지, 배송 성공 판정 및 통지 | `Area3D` | |
| `PrototypeLevel.tscn` | 지형 배치, 하위 씬 조립, 배송 성공 신호를 UI로 연결, `restart` 입력 처리, MVP-1에서 Main 역할 겸임 | `Node3D` | 프로젝트의 `run/main_scene`으로 지정 |
| `DeliveryHUD.tscn` | 성공/재시작 안내 텍스트 표시, 화면 중앙 조준점 표시(T073, `Crosshair` 자식 노드에 위임) | `CanvasLayer` | 게임 상태를 직접 판정하지 않음. 조준 대상 판정은 `Player.gd`가 하고 `DeliveryHUD`는 상태값만 받아 표시. 목표 안내(`GoalLabel`)는 아직 구현되지 않음(섹션 13 참고) |

### 4.1 `Player.tscn`

- **책임**: 이동 입력 처리, 마우스 기반 카메라 회전, 상호작용 대상 감지, 현재 잡고 있는 `Package` 참조 관리(요청만 — 실제 물리 반응은 `Package`가 스스로 처리).
- **예상 노드 구조(T073, 1인칭 전환 이후)**:
  ```text
  Player (CharacterBody3D)
  ├─ CollisionShape3D
  ├─ MeshInstance3D              (플레이스홀더 캡슐, Visual Layer 2 — 로컬 카메라 cull_mask에서 제외)
  ├─ GrabCollisionBarrier (AnimatableBody3D)   (T072 결함 수정, 섹션 10.4·16 참고)
  │  └─ CollisionShape3D
  └─ CameraPivot (Node3D)         (Player 눈높이로 이동, pitch만 담당 — yaw는 Player 자신)
     ├─ Camera3D                 (T073: SpringArm3D 제거, CameraPivot 원점에 직접 위치)
     ├─ HoldPoint (Marker3D)      (잡은 물체가 향할 목표 위치)
     └─ GrabShapeCast (ShapeCast3D)   (T073: Camera3D와 동일 원점으로 재배치, 화면 중앙과 항상 일치)
  ```
  `HoldPoint`와 `GrabShapeCast`를 `CameraPivot`의 자식으로 둔 이유는 카메라 방향과 상호작용/잡기 방향을 일치시키기 위해서다 (이전 버전에서는 `CameraPivot`의 형제 노드였고, 이 경우 카메라를 돌려도 상호작용 방향이 따라가지 않는 불일치가 있었다). `GrabShapeCast`는 T073에서 `Camera3D`와 완전히 같은 로컬 원점(0,0,0)으로 옮겨져, Grab 판정이 항상 화면 중앙(조준점)과 구조적으로 일치한다(섹션 10.4, 11 참고).
- **연결 스크립트**: `Player.gd` (루트에 부착).
- **다른 씬과의 관계**: `PrototypeLevel.tscn`이 자식으로 인스턴스화. 잡은 대상(`GrabbableBody`)은 직접 자식으로 삼지 않고(재부모화하지 않음) 참조만 보유한다 — 이유는 섹션 10 참고.
- **직접 소유하면 안 되는 책임**: 잡은 대상의 물리 상태 전환(그 책임은 `GrabbableBody`/`Package.gd`), 배송 성공 판정(그 책임은 `DeliveryZone.gd`), UI 표시(그 책임은 `DeliveryHUD.gd`), `restart` 입력 처리와 씬 재로드(그 책임은 `PrototypeLevel.gd` — 섹션 12, 17 참고).
- **실제 구현에서 추가된 책임**: `_push_away_rigid_bodies()`(이동 중 부딪힌 `RigidBody3D`를 제한된 힘으로 밀어내는 보조 — 잡고 있는 대상은 제외). `collision_layer=2`, `collision_mask=5`(World+Package), `safe_margin=0.08`(기본값 0.001에서 상향 — `RigidBody3D` 위에 설 때 매 프레임 겹침 보정이 과도해 폭발적으로 튕기는 문제의 근본 원인이었음, T040에서 실측 확인). T071에서 `_handle_throw_input()`과 `throw_impulse_strength`는 완전히 삭제되었다(고정 Throw 제거, 섹션 10 참고).

### 4.2 `Package.tscn` / `GrabbableBody.gd` (T071에서 일반화, T072에서 Force-Based Grab으로 재설계)

T071 이전에는 잡기·놓기·던지기·추종 로직 전체가 `Package.gd`에만 있었다. T071에서 이 로직을 `scenes/objects/GrabbableBody.gd`(`class_name GrabbableBody extends RigidBody3D`)로 전부 이관하고, `Package.gd`는 `class_name Package extends GrabbableBody` 두 줄로 축소되었다. PhysicsBarrel/PhysicsCrate/SmallPhysicsBox(섹션 4.4)도 동일하게 `GrabbableBody.gd`를 스크립트로 사용해 잡을 수 있게 되었다. T072에서는 이 클래스 구조(상속·그룹 분리)는 그대로 유지한 채, 내부 이동 방식만 속도 강제 추종에서 Force-Based Spring-Damper Grab으로 재설계했다(자세한 내용은 섹션 10 참고).

- **`GrabbableBody`(공용) 책임**: 물리 충돌, 여러 Grabber의 Grab Connection 관리(`grab_connections: Dictionary`), 잡힌 동안 각 연결의 실제 Grab Point에 제한된 Spring-Damper 힘(`apply_force()`) 적용, 정적 장애물에 의한 연결별 자동 해제. Player collision exception은 T072 최초 구현에서 완전히 제거되었으나, 뒤이은 결함 수정(Player가 밀리는 문제)에서 Grabber별 exception + `GrabCollisionBarrier`로 다시 관리하게 되었다(섹션 10.4).
- **`Package`(개별) 책임**: `package`/`grabbable` 그룹 소속(상호작용·배송 대상 식별용, 섹션 11·12·17), 기존 크기·물리값. 그 외 로직은 없음.
- **예상 노드 구조**(4종 공통):
  ```text
  Package / PhysicsBarrel / PhysicsCrate / SmallPhysicsBox (RigidBody3D)
  ├─ CollisionShape3D
  └─ MeshInstance3D             (플레이스홀더 메시)
  ```
- **연결 스크립트**: 4종 모두 `GrabbableBody.gd`(Package는 `Package.gd`를 통해 상속). 4종 모두 `grabbable` 그룹, `Package`만 추가로 `package` 그룹에 속한다.
- **다른 씬과의 관계**: `PrototypeLevel.tscn`이 시작 위치에 인스턴스화. `Player`가 참조를 들고 있는 동안에도 씬 트리 소속은 그대로 유지한다(재부모화하지 않음).
- **직접 소유하면 안 되는 책임**: 입력 처리(그 책임은 `Player.gd`), 배송 성공 판정(그 책임은 `DeliveryZone.gd`, `Package`만 대상).
- **Package 실제 물리값**(T040 실측 튜닝, T061 Baseline Freeze로 확정): `collision_layer=4`, `collision_mask=7`(World+Player+Package), `mass=15.0`, `PhysicsMaterial`(`friction=0.7`, `bounce=0.0`), `linear_damp=2.0`, `angular_damp=2.0`. PhysicsBarrel/Crate/SmallBox의 물리값은 섹션 4.4·18 참고 — T071에서 변경되지 않았다.
- **잡힌 동안의 충돌 처리(T042→T072로 변경 이력)**: 원래 설계(섹션 10.1)만으로는 잡힌 대상이 여전히 holder(`Player`)와 물리적으로 충돌 관계라, 추종 힘이 엔진 충돌 반응과 부딪혀 `Player`가 밀리거나 공중부양하는 문제가 실측으로 확인됨(T042). 당시 해결책은 `grab()`/`release()`에서 `add_collision_exception_with()`/`remove_collision_exception_with()`를 holder와 양방향으로 관리하는 것이었다. T072 최초 구현에서는 이 메커니즘을 완전히 제거했었다 — HoldPoint가 항상 Player 캡슐 바깥(전방 1.5m)에 위치하고 힘이 제한되어 있으니 exception 없이도 충분할 것으로 판단했으나, 실제로는 Spring 힘이 Player를 압박하면 `move_and_slide()`가 Player를 반대로 밀어내는 반작용이 발생함이 사용자 재현으로 드러났다. 이에 따라 결함 수정에서 전용 `GrabCollisionBarrier`(`AnimatableBody3D`)와 Grabber별 collision exception(지연 복구 포함)을 재도입했다 — "물체와 Player가 항상 정상 충돌한다"는 목표 자체는 유지하되, 실제 Player 몸과의 충돌과 "잡은 물체 차단"을 분리하는 방식으로 달성한다(자세한 내용은 섹션 10.4 참고).

### 4.3 `DeliveryZone.tscn`

- **책임**: 올바른 `Package`가 영역에 들어왔는지 감지하고, 최초 1회만 배송 성공으로 판정해 통지.
- **예상 노드 구조**:
  ```text
  DeliveryZone (Area3D)
  ├─ CollisionShape3D            (트리거 볼륨)
  └─ MeshInstance3D              (시각 확인용 — 실제 구현은 반투명이 아닌 기본 불투명 재질의 `CylinderMesh`/`CylinderShape3D` 사용, `collision_layer=8`, `collision_mask=4`)
  ```
- **연결 스크립트**: `DeliveryZone.gd`.
- **다른 씬과의 관계**: `PrototypeLevel.tscn`이 목적지 위치에 인스턴스화. 성공 시 시그널로 `PrototypeLevel.gd`에 통지한다.
- **직접 소유하면 안 되는 책임**: UI 표시, 재시작 처리, Player/Package의 물리 상태 변경.

### 4.4 `PrototypeLevel.tscn`

- **책임**: 지형(바닥, 계단, 경사로) 배치, `Player`/`Package`/`DeliveryZone`/`DeliveryHUD` 조립, `DeliveryZone`의 성공 신호를 받아 `DeliveryHUD`에 전달, `restart` 입력을 감지해 씬을 재로드, MVP-1 한정으로 `Main`의 역할(진입점) 겸임.
- **예상 노드 구조**: 섹션 5 참고. 실제 구현은 루트 아래 `Environment`(지형)/`Gameplay`(`Player`/`Package`/`DeliveryZone`)/`UI`(`DeliveryHUD`) 3개 그룹 노드로 나뉘어 있다(초기 씬 뼈대 단계에서 도입, 섹션 5 참고).
- **연결 스크립트**: `PrototypeLevel.gd` — 신호 연결과 재시작 입력 처리만 담당하는 얇은 스크립트.
- **직접 소유하면 안 되는 책임**: 이동/카메라/상호작용 세부 로직(각 하위 씬의 책임), 배송 판정 세부 로직(`DeliveryZone`의 책임).

### 4.5 `DeliveryHUD.tscn`

- **책임**: 배송 성공 메시지와 재시작 안내 텍스트를 표시. (목표 안내는 아직 구현되지 않음 — 아래 참고)
- **실제 노드 구조**:
  ```text
  DeliveryHUD (CanvasLayer)
  └─ SuccessPanel (Control, 시작 시 숨김, mouse_filter=IGNORE)
     ├─ SuccessLabel (Label, "DELIVERY COMPLETE")
     └─ RestartLabel (Label, "Press R to Restart")
  ```
  원래 설계는 `MarginContainer`/`VBoxContainer`와 `GoalLabel`을 포함했으나, 실제 구현에서는 "성공 표시만 구현"하라는 사용자의 명시적 지시(T052)에 따라 `GoalLabel`(목표 안내)은 만들지 않았고, 컨테이너 없이 `SuccessPanel` 하나에 두 `Label`을 직접 배치했다. `GoalLabel`은 `GAME_DESIGN.md`의 MVP 완료 조건에 포함되어 있지 않아 MVP-1 완료 판정에는 영향이 없다(T062에서 확인).
- **연결 스크립트**: `DeliveryHUD.gd` — `show_success()` 표시 전용 함수만 제공.
- **주의(실제 발견된 버그와 수정, T052)**: `SuccessPanel`이 전체 화면을 덮는 `Control`인데 기본 `mouse_filter`(`STOP`)가 마우스 이동 이벤트를 GUI 단계에서 소비해, `Player`의 카메라 회전(`_unhandled_input`)이 HUD 표시 후 멈추는 문제가 있었다. `SuccessPanel`/각 `Label`에 `mouse_filter = MOUSE_FILTER_IGNORE`를 설정해 해결했다 — 비상호작용 UI를 화면에 표시할 때는 이 설정이 필수임을 기록해 둔다.
- **직접 소유하면 안 되는 책임**: 배송 성공 여부 판정, 재시작 실행 자체(입력 처리는 `PrototypeLevel.gd`가 담당하고 `DeliveryHUD`는 표시만 한다).

## 5. 메인 실행 구조

`Main.tscn`과 `PrototypeLevel.tscn`을 분리할 필요가 있는지 검토한 결과:

- MVP-1에는 타이틀 화면, 메뉴, 여러 레벨 간 전환이 없다 (`docs/GAME_DESIGN.md` MVP 필수 기능 기준).
- `Main`이 하는 일이 사실상 "`PrototypeLevel`을 띄운다" 하나뿐이라면, 별도 씬으로 분리하는 것은 섹션의 지시대로 불필요한 계층이다.

**결정**: MVP-1에서는 `PrototypeLevel.tscn`을 프로젝트의 실행 씬(`run/main_scene`)으로 직접 지정한다. `Main.tscn`은 별도 파일로 만들지 않는다. 메뉴/여러 레벨 전환이 필요해지는 Phase(예: Phase 8 정식 맵, Phase 9 Steam 준비)에서 `Main.tscn`을 다시 분리해 씬 전환 진입점으로 되살린다.

```text
PrototypeLevel   (프로젝트 실행 씬, MVP-1에서 Main 역할 겸임)
├─ Environment    (바닥, 계단, 경사로 — StaticBody3D 모음)
├─ Gameplay
│  ├─ Player
│  ├─ Package
│  └─ DeliveryZone
└─ UI
   └─ DeliveryHUD
```

(실제 구현은 `Player`/`Package`/`DeliveryZone`을 `Gameplay` 그룹 노드 아래, `DeliveryHUD`를 `UI` 그룹 노드 아래 배치한다 — 최초 씬 뼈대 생성 시점의 구조가 그대로 유지되었다. 기능상 차이는 없다.)

## 6. 플레이어 구조

`Player.tscn`의 책임을 4가지로 구분한다.

| 책임 | 담당 |
|---|---|
| 이동 (입력 → 속도 계산 → `move_and_slide()`) | `Player.gd` |
| 카메라 회전 (마우스 입력 → yaw는 Player 자신, pitch는 `CameraPivot`, T073) | `Player.gd` (`CameraPivot`/`Camera3D` 노드를 직접 참조) |
| 상호작용 감지 (`GrabShapeCast` 결과 확인) | `Player.gd` |
| 잡은 물체 관리 (어떤 `GrabbableBody`를 잡고 있는지 참조 보유, 놓기 요청) | `Player.gd` |
| (실제 추가) 부딪힌 `RigidBody3D` 밀어내기 보조 (`_push_away_rigid_bodies()`, 잡은 대상은 제외) | `Player.gd` |
| (실제 추가, T073) 조준점 UI가 참조할 상태 발신 (`grab_aim_state_changed`, 기존 감지·홀드 데이터 재사용) | `Player.gd` |

`HoldPoint`와 `GrabShapeCast`는 `CameraPivot`의 자식이므로 카메라 회전을 그대로 따라간다 (섹션 4.1 참고). T073부터 좌우 회전(yaw)은 Player 자신의 `rotation.y`이고, `CameraPivot`은 상하 회전(pitch)만 담당한다 — `CameraPivot`이 Player의 자식이므로 `HoldPoint`/`GrabShapeCast`는 결과적으로 yaw+pitch를 모두 그대로 따라간다는 점은 이전과 동일하다. `restart` 입력 처리는 `Player.gd`의 책임이 아니다 — `PrototypeLevel.gd`가 담당한다 (섹션 12, 17).

MVP-1에서는 이 4가지 책임을 모두 `Player.gd` 하나가 담당한다. 노드 수가 적고(6개 미만) 각 책임의 로직이 짧기 때문에, 지금 여러 컴포넌트 스크립트로 쪼개는 것은 과도한 추상화다.

**기록해 둘 위험**: `Player.gd`가 이동+카메라+상호작용+홀드 관리를 모두 가지므로, 기능이 추가될수록(예: Phase 7 차량 탑승) 하나의 스크립트가 비대해질 위험이 있다. 스크립트가 200줄을 넘거나 서로 무관한 책임이 늘어나면, 카메라 로직을 `CameraPivot`에 붙는 별도 스크립트로 분리하는 것을 그 시점에 재검토한다. MVP-1에서는 분리하지 않는다.

## 7. 플레이어 이동 방식

- **입력 벡터**: `Input.get_vector("move_left", "move_right", "move_forward", "move_backward")`로 2축 입력을 얻는다.
- **이동 방향 기준(T073)**: 입력 벡터를 Player 자신의 글로벌 기준(수평 성분만)으로 변환해 이동 방향을 계산한다 — yaw가 `CameraPivot`이 아닌 Player 자신에 있으므로(섹션 8), Player의 `transform.basis`를 그대로 쓴다.
- **중력**: 바닥에 닿아 있지 않을 때 매 물리 프레임 속도에 중력을 누적한다.
- **점프**: 바닥에 닿아 있고 `jump` 액션이 눌리면 수직 속도를 점프 속도로 설정한다.
- **달리기**: `sprint` 액션을 누르고 있는 동안 목표 속도를 달리기 속도로 전환한다.
- **감속/정지**: 즉시 정지가 아니라 `move_toward()`로 목표 속도까지 가감속시켜 급정지로 인한 부자연스러움을 줄인다.
- **이동 함수**: `move_and_slide()`를 사용한다.
- **처리 위치**: 위 로직 전부 `_physics_process(delta)`에서 수행한다 (`CLAUDE.md` 섹션 5).

정확한 이동/점프 속도 수치는 이 문서에서 확정하지 않는다. 모두 `Player.gd`의 export 변수로 두고 Inspector에서 조정한다 (섹션 18).

## 8. 카메라 구조

**T073에서 3인칭 → 1인칭으로 전환**: 3인칭 카메라가 캐릭터 Mesh로 잡은 물체·조준 대상을 가리는 문제를 사용자가 지적해, 기본 시점을 1인칭으로 바꿨다. `docs/GAME_DESIGN.md`가 명시하는 "3인칭 카메라 기본"(섹션 26, 29 등)과 배치되지만, 사용자의 명시적 지시가 `CLAUDE.md` 섹션 9 우선순위상 앞선다 — `GAME_DESIGN.md` 자체는 이 변경으로 갱신되지 않았다(`docs/TASKS.md` T073 "예상 위험" 참고). 아래는 전환 이후(T073) 기준이며, 이전(3인칭, `SpringArm3D` 기반) 구조는 더 이상 존재하지 않는다.

- **구조**: `Player` → `CameraPivot(Node3D, Player 눈높이)` → `Camera3D`(직계 자식, 별도 오프셋 없음). 기존 3인칭용 `SpringArm3D`(spring_length=4.5)는 제거되었다.
- **눈높이**: `CameraPivot`을 Player 로컬 좌표 y=0.7(TODO: 프로토타입 값, 기본 `CapsuleShape3D` radius 0.5/height 2.0 기준 추론, 실측 재검증 필요)에 배치한다.
- **수평 회전(yaw)**: 마우스 X 이동 → **Player 자신**의 `rotation.y`를 회전한다(T073 이전에는 `CameraPivot`이 담당). Player 본체가 실제로 바라보는 방향을 향하게 되어, 향후 다른 Player에게도 정확한 정면이 보인다(멀티플레이 전제).
- **수직 회전(pitch)**: 마우스 Y 이동 → `CameraPivot`을 로컬 X축 기준으로 회전, 위/아래 각도를 export 변수로 제한(clamp)한다(무변경).
- **벽 충돌 대응**: `SpringArm3D`를 사용하지 않으므로 해당 내장 충돌 검사도 없다 — 카메라가 Player 자신의 눈높이에 위치해 벽 뒤로 밀려날 여지 자체가 없다(3인칭 특유의 문제였음).
- **로컬 Player Mesh 은닉**: `MeshInstance3D.layers=2`, `Camera3D.cull_mask`에서 레이어 2만 제외(`1048573`)해 로컬 카메라가 자신의 몸을 렌더링하지 않는다. 전역 `visible=false`는 사용하지 않아, 씬 트리에는 여전히 존재하고 이론상 다른 카메라(향후 멀티플레이)에는 보인다 — 다만 현재는 싱글플레이라 여러 Player 인스턴스가 동일 레이어를 공유하는 구조까지는 만들지 않았다(과도한 설계 금지, `docs/TASKS.md` T073 "예상 위험" 참고).
- **마우스 캡처**: 게임 시작 시 `Input.MOUSE_MODE_CAPTURED`로 설정. `release_mouse` 액션 입력 시 `Input.MOUSE_MODE_VISIBLE`로 전환.
- **마우스 캡처 복귀**: 마우스가 해제된 상태(`MOUSE_MODE_VISIBLE`)에서 게임 화면을 클릭하면 다시 `Input.MOUSE_MODE_CAPTURED`로 전환한다. 이 클릭 입력은 `grab_object` 등 게임 조작 액션으로 동시에 처리되지 않는다 — 마우스가 해제된 상태에서는 클릭을 먼저 재캡처 용도로 소비하고, 게임 조작으로는 넘기지 않는다.

카메라 로직은 `Player.gd` 안에 둔다. 별도의 전역 카메라 Manager(Autoload 등)는 만들지 않는다 (`CLAUDE.md` 섹션 4).

## 9. 택배 구조

`Package.tscn`의 기본안:

- 루트 노드: `RigidBody3D`.
- `CollisionShape3D` + `MeshInstance3D`(플레이스홀더 박스 메시).
- **상호작용 식별 방식**: `package`/`grabbable` 그룹에 추가. `Player`의 `GrabShapeCast`가 감지한 노드가 `GrabbableBody` 타입인지로 판단하고(T071), 배송 판정은 별도로 `package` 그룹 여부만 확인한다 (섹션 11, 12, 17).
- **잡기 가능한 물체 표시**: MVP-1 완료 조건(`docs/GAME_DESIGN.md` 섹션 28)에 시각적 강조가 포함되어 있지 않으므로, 별도의 하이라이트 연출은 MVP-1 필수 범위가 아니다. 필요하면 이후 폴리싱 단계에서 머티리얼 강조를 추가한다.

MVP-1의 택배는 일반 박스 한 종류뿐이다 (`docs/GAME_DESIGN.md` 섹션 27). 다음은 이 문서의 설계 대상이 아니며 만들지 않는다:

- 내구도 / 파손
- 택배 종류 데이터베이스
- 상속 계층
- 복잡한 Item 시스템
- 멀티플레이 권한(authority) 구조

## 10. 잡기·놓기·던지기 구조

### 10.1 방식 비교

| 방식 | 요약 | 평가 |
|---|---|---|
| A. 목표 위치로 물리적 추종 | 잡힌 동안 매 물리 프레임 목표 위치와의 차이만큼 `linear_velocity`를 계산해 적용. `RigidBody3D` 물리는 항상 활성 상태 유지. | 세계 지형과의 충돌이 자연스럽게 유지되어(좁은 문에 끼임 등) 게임 컨셉과 잘 맞음. 다인 운반 확장 시 목표 위치를 여러 플레이어의 평균으로 바꾸기만 하면 되어 구조를 갈아엎지 않아도 됨. |
| B. 임시 Joint 결합 | `PinJoint3D` 등으로 `HoldPoint`와 `Package`를 연결. | 물리적으로 정교하지만 강성/감쇠 값 튜닝이 까다롭고 진동이 발생하기 쉬움. MVP-1에서 튜닝하기 어려움. |
| C. 자식으로 재부모화 + Freeze | 잡는 동안 `Package`를 `Player`의 자식으로 옮기고 물리를 얼림(freeze). | 구현은 가장 단순하지만, 부모가 하나뿐이라는 전제라서 향후 두 명이 동시에 드는 실험(Phase 5)을 시도하려면 이 구조 자체를 버려야 함 — "다인 운반 실험을 완전히 막지 않음" 조건에 위배. |

**선택**: **A. 목표 위치로 물리적 추종**. 아래 조건을 가장 균형 있게 만족한다.

- 구현이 단순함: 조인트 파라미터 튜닝이 필요 없고, 재부모화·freeze 전환 로직도 필요 없음.
- `RigidBody3D` 충돌이 깨지지 않음: 잡힌 동안에도 계속 물리 바디로 존재하므로 지형과 자연스럽게 부딪힘.
- 놓기/던지기가 자연스러움: 놓을 때는 추종을 멈추기만 하면 되고(현재 속도 유지), 던질 때는 추가 임펄스만 더하면 됨.
- 다인 운반을 막지 않음: 목표 위치를 단일 `HoldPoint` 대신 여러 `HoldPoint`의 평균으로 바꾸는 확장이 가능함 (Phase 5에서 검토).
- MVP에서 튜닝하기 쉬움: 추종 속도, 최대 속도를 export 변수로 노출하면 됨.

**T072에서의 재검토**: A안(목표 위치로 물리적 추종, `linear_velocity`를 직접 계산해 덮어씀)은 T071까지 유지되었으나, 사용자가 "위치나 속도를 직접 제어하지 않고 실제 힘만 가한다"는 설계 철학을 명시적으로 요구하면서 B안(Joint 결합)에 더 가까운 방향으로 진화했다. 다만 Godot 내장 Joint 노드를 그대로 쓰지 않고, `apply_force()`로 직접 구현한 커스텀 Spring-Damper를 사용한다 — 여러 Grabber가 런타임에 자유롭게 연결/해제되고 각자 힘 상한을 가지는 요구가 표준 Joint 노드로는 자연스럽게 표현되지 않기 때문이다(`DESIGN_DECISIONS.md` DD-022). "다인 운반을 막지 않음" 조건은 이 재설계로 오히려 더 직접적으로 충족된다(섹션 10.3의 `grab_connections` 참고).

### 10.2 잡기 조작 확정 (좌클릭 Hold + Force-Based Grab, T072)

조작 방식(무엇을 누르면 잡고 놓는지)은 T071에서 확정된 이후 바뀌지 않았다: 최초 **홀드(hold) 방식**(`E`를 누르고 있는 동안 유지, DD-001) → T067에서 **토글(toggle) 방식**(`E`로 잡기/놓기 전환, DD-017) → T071에서 **좌클릭 Hold**로 재변경(DD-019 이후). T072에서 바뀐 것은 입력 방식이 아니라 **잡은 동안의 내부 이동 방식**이다: T071의 "스윙 릴리즈"(놓는 순간 별도 임펄스를 계산해 추가로 적용)라는 개념 자체가 사라졌다.

- 마우스 왼쪽 버튼(`grab_object`)을 누르는 순간(`just_pressed`), 아무것도 잡고 있지 않으면 감지된 `GrabbableBody`(가시선 검사 통과 시에만)의 실제 클릭 표면 지점에 `add_grabber()`로 연결을 시도한다.
- 누르고 있는 동안 계속 잡은 상태가 유지된다(별도 입력 불필요 — `GrabbableBody`가 매 물리 프레임 그 연결의 Grab Point에 Spring-Damper 힘을 가한다).
- `grab_object`를 놓는 순간(`just_released`), 잡고 있었다면 `remove_grabber()`로 그 연결만 제거한다 — **별도의 release 임펄스는 전혀 적용되지 않는다.** 잡고 있는 동안 이미 Spring-Damper 힘이 물체에 실제 운동량을 축적해 두었으므로, 놓는 순간 물체는 그 순간 가지고 있던 `linear_velocity`/`angular_velocity`를 그대로 유지하며 날아간다(빠르게 화면을 돌리다 놓으면 그만큼 빠르게 날아가는 "스윙"처럼 느껴지지만, 이는 코드가 명시적으로 계산해 더하는 임펄스가 아니라 자연스러운 물리 결과다).
- `E`(`interact`)는 잡기·놓기와 완전히 분리되어 아무 동작도 하지 않는다 — 향후 버튼/문/레버 등 범용 상호작용을 위해 예약된 입력이다(T072 기준 미구현).
- 벽 등으로 인한 자동 해제(섹션 10.4)는 `grab_object` 입력과 무관하게 연결 단위로 발생한다. 자동 해제 이후에도 새로운 `grab_object` `just_pressed`가 있어야만 다시 잡을 수 있다(버튼이 눌린 채로 유지되고 있다는 이유로 자동 재잡기하지 않는다 — 로직 자체가 `just_pressed` 엣지에만 반응하므로 별도 방지 로직 없이 자연스럽게 보장됨).

### 10.3 책임 분리

- `Player.gd`: `grab_object` 입력을 감지해 "이 대상을 잡아라 / 놓아라"를 `GrabbableBody`에 요청만 한다. 감지 시 `GrabShapeCast.get_collision_point()`로 실제 클릭 표면 지점도 함께 기록해 `add_grabber()`에 전달한다. `E`(`interact`)는 감지·수신하지 않는다(입력 맵에는 남아있으나 코드 경로 없음).
- `GrabbableBody.gd`(모든 잡을 수 있는 오브젝트의 공통 부모): 여러 Grabber의 연결(`grab_connections: Dictionary`)을 스스로 관리하고, 잡힌 동안 `_integrate_forces()`에서 각 연결의 실제 Grab Point에 Spring-Damper 힘을 `apply_force()`로 직접 가하는 물리 계산을 수행한다. 놓일 때는 해당 연결을 제거만 할 뿐, 속도를 전혀 건드리지 않는다.

```text
Player: grab_object 누르는 순간(just_pressed) & 잡은 것 없음
  → _detected_grabbable(가시선 검사 통과, 가장 가까운 후보 우선)가 있으면
    GrabbableBody.add_grabber(self, hold_point, 실제 클릭 지점) 호출
Player: grab_object를 누르고 있는 동안
  → 아무 동작 없음. 잡은 상태는 매 물리 프레임 GrabbableBody가 해당 연결에
    Spring-Damper 힘을 가하며 유지됨
Player: grab_object 놓는 순간(just_released) & 잡은 것 있음
  → GrabbableBody.remove_grabber(self) 호출 (속도 변경 없음, 현재 운동량 유지)
Player: interact(E) 입력
  → 아무 동작 없음 (T072 기준 예약된 입력)
```

Spring 상수, 감쇠 계수, Grabber별 힘 상한 등 정확한 수치는 export 변수로 관리한다 (섹션 18).

### 10.4 물리 추종 안전 조건

목표 위치 추종 방식(섹션 10.1의 A안)은 아무 제한 없이 구현하면 `Package`가 벽/지형에 막혔을 때 속도가 비정상적으로 커지거나, 플레이어가 좁은 틈으로 빠르게 이동할 때 `Package`가 멀리서 순간적으로 튕겨오는 문제가 발생할 수 있다. 이를 막기 위해 다음 안전 조건이 필요하다.

- **최대 추종 속도 제한**: 목표 위치와의 거리가 아무리 멀어도 `linear_velocity`가 일정 값 이상으로 커지지 않도록 상한을 둔다.
- **추종 반응 강도(가속도) 제한**: 매 프레임 속도가 급격히 튀지 않도록, 목표 속도로의 변화량 자체에도 상한을 둔다 (즉시 목표 속도로 스냅하지 않는다).
- **플레이어-`Package` 최대 허용 거리**: `HoldPoint`와 `Package`의 실제 위치 차이가 일정 거리를 넘지 않도록 감시한다.
- **최대 거리 초과 시 자동 놓기**: 위 거리를 초과하면(예: 벽에 막혀 추종이 계속 실패하는 경우) `Package.release()`를 자동 호출해 잡은 상태를 강제로 해제한다 — 물리량이 비정상적으로 누적되는 것을 막는다.
- **장애물에 막혔을 때 속도 과다 증가 방지**: 추종 속도 계산 자체를 "최대 추종 속도" 상한으로 clamp하므로, 장애물에 막혀 목표와의 거리가 벌어져도 속도가 무한정 커지지 않는다.

정확한 수치(최대 추종 속도, 가속도 제한, 최대 허용 거리)는 이 문서에서 확정하지 않는다. 모두 `Package.gd`의 export 변수로 두고 프로토타입 테스트로 조정한다 (섹션 18).

**T042~T071 사이 존재했으나 T072에서 제거된 안전 조건(역사 기록)**:

- **holder와의 충돌 예외**(T042 도입): `grab()` 성공 시 대상과 holder(`Player`) 사이에 `add_collision_exception_with()`를 양방향으로 걸어, 추종 힘이 엔진의 충돌 반응과 충돌해 `Player`가 밀리거나 발밑의 대상을 바닥으로 오인해 함께 상승하는 문제를 막았다.
- **겹친 상태에서의 지연된 충돌 복구**(T042 도입): `release()`(수동/자동 공통)가 물리적 놓기(즉시)와 충돌 예외 해제(지연, `intersect_shape()`로 실제 겹침이 연속 3프레임 이상 해소된 뒤에만 복구)를 분리해 침투 해소 충격을 막았다.
- **T072 최초 구현에서 제거된 이유**: 사용자가 "Grab 중에도 Player와 물체가 항상 정상적으로 충돌해야 한다"고 명시적으로 요구했다. Force-Based Grab에서는 HoldPoint가 항상 Player 캡슐 바깥에 위치하고 힘이 `max_force_per_grabber`로 제한되어 있어, exception이나 지연 복구 로직 없이도 자연스럽게 관통이 방지될 것으로 판단했다(`DESIGN_DECISIONS.md` DD-024).
- **결함 발견과 재도입(T072 결함 수정)**: 위 판단과 달리, 실제로는 Spring 힘이 물체를 Player 쪽으로 계속 압박하면 `move_and_slide()`가 이를 겹침으로 해석해 Player를 반대 방향으로 밀어내는 반작용이 발생함이 사용자 재현으로 확인되었다. `Player.tscn`에 `GrabCollisionBarrier`(`AnimatableBody3D`, Player 캡슐보다 약간 큰 `CylinderShape3D`, 신규 collision layer 6 `GrabBarrier`(값 32), `collision_mask=0`)를 추가하고, `Player.gd`가 매 물리 프레임(`move_and_slide()` 직후) `grab_collision_barrier.global_transform = global_transform`으로 명시적으로 동기화한다(`AnimatableBody3D`는 일반 자식 노드처럼 부모 Transform을 자동으로 따라가지 않기 때문에 필요 — 이 동기화 누락이 최초 결함 수정 시도가 실제로는 작동하지 않았던 원인이었다). `GrabbableBody.add_grabber()`는 grabber가 `CollisionObject3D`이면 실제 Player 몸과의 collision exception을 걸고 자신의 `collision_mask`에 barrier 비트(32)를 추가해 대신 `GrabCollisionBarrier`와 충돌하게 하며, `remove_grabber()`는 `intersect_shape()`로 연속 3프레임 미겹침이 확인된 뒤에만 exception과 mask 비트를 복구한다(여러 Grabber가 있으면 마지막 Grabber가 분리될 때만 복구). Spring-Damper 힘 계산·질량·중력·torque·다중 Grabber 힘 합산 로직은 이 결함 수정으로 변경되지 않았다.

**T065에서 추가된 안전 조건 — 상호작용·Hold 유지 가시선 검사(T072에서도 원칙 유지)**: `Player.gd`가 후보를 확정하기 전에 물리적 가시선(Ray Query)을 검사해 벽 등에 가려진 대상을 잡기 후보에서 제외한다. `GrabbableBody`가 잡힌 동안 HandPoint↔Grab Point 사이의 차단 여부를 매 프레임 검사해 연속 3프레임 이상 차단되면 해당 연결을 자동 해제하는 원칙도 그대로 유지되며, T072에서는 이 판정이 연결(Grab Connection) 단위로 개별 수행된다(`DESIGN_DECISIONS.md` DD-015, DD-023).

**T071에서 도입되었다가 T072에서 대체된 안전 조건(역사 기록)**:

- **질량 기반 이동 예산**(T071): `max_carry_force`(공유 600.0)를 각자의 `mass`로 나눈 `effective_acceleration = max_carry_force / mass`로 매 프레임 속도 변화량을 제한했다. **T072에서 이 방식 자체가 폐기**되었다 — 속도를 직접 계산해 clamp하는 대신, 실제 mass×gravity가 자연스러운 저항으로 작동하는 Force-Based Grab으로 대체되었다(아래 참고).
- **Hold 차단 판정을 정적 장애물로 한정**(T071): 판정 마스크를 World만(1)으로 좁혀 동적 오브젝트 접촉만으로는 자동 놓기가 발생하지 않게 한 원칙은 T072에서도 그대로 유지된다(아래 참고).
- **스윙 릴리즈**(T071): `HoldPoint`의 회전 이동 속도를 추적해 놓는 순간 별도의 가산 임펄스를 적용하던 방식. **T072에서 완전히 제거**되었다(아래 참고).

**T072에서 변경된 안전 조건(Force-Based Physics Grab 재설계)**:

- **Spring-Damper 힘 + Grabber별 힘 상한**: `desired_force = displacement.limit_length(max_spring_distance) * grab_spring_strength + relative_velocity * grab_damping`을 계산한 뒤 `limit_length(max_force_per_grabber)`로 Grabber 1명분 힘 상한을 적용해 `apply_force()`로 실제 Grab Point에 가한다. `displacement`는 HandPoint와 Grab Point의 차이, `relative_velocity`는 HandPoint 속도에서 Grab Point의 실제 속도(`linear_velocity + angular_velocity.cross(offset)`, 회전 포함)를 뺀 값이다. 힘이 상한에 걸리는 동안에도 `mass`가 클수록 실제 가속도(`force/mass`)가 작아 무거운 물체가 자연히 느리게 반응한다 — 별도의 질량 나눗셈 공식 없이 뉴턴 제2법칙 자체가 이 효과를 만든다.
- **여러 Grabber의 힘 합산**: 각 연결(Grab Connection)이 독립적으로 자신의 힘을 계산하고 개별 `max_force_per_grabber` 상한을 적용한 뒤 각자의 Grab Point에 적용하므로, 물체에는 결과적으로 여러 힘이 자연히 합산된다. 전체 힘을 한 명의 상한으로 다시 제한하지 않는다.
- **Hold 차단 판정을 정적 장애물로 한정(연결 단위)**: 판정 마스크는 T071과 동일하게 World만(1)이지만, 이제 연결마다 개별적으로 `block_streak`을 추적한다 — 여러 Grabber 중 하나만 막혀도 그 연결만 해제되고 나머지는 유지된다.
- **거리 초과 시 자동 해제(연결 단위)**: `max_grab_distance`(3.0, 기존 `max_hold_distance` 값 승계)를 넘는 연결만 개별 해제된다.
- **Release 시 운동량 유지**: `remove_grabber()`는 `linear_velocity`/`angular_velocity`를 전혀 건드리지 않는다. 잡고 있는 동안 Spring-Damper 힘이 이미 실제 운동량을 만들어 두었으므로, 놓는 순간 별도 보정 없이 그 운동량이 그대로 유지된다. 정확한 `grab_spring_strength`/`grab_damping`/`max_force_per_grabber` 값은 실측 후보 비교가 아닌 초기 추정값으로, 사용자 수동 테스트 후 조정될 수 있다(`TECH_DEBT.md` TD-013).

## 11. 상호작용 감지 방식

| 방식 | 특징 |
|---|---|
| `RayCast3D` | 얇은 선 하나로 판정 — 파티 게임 특성상 조준이 까다로워 잘 놓칠 수 있음 |
| `ShapeCast3D` | 구/캡슐 형태로 판정 — 관대한 감지 범위, API는 `RayCast3D`와 유사하게 단순함 |
| `Area3D` | 상시 겹침 목록을 관리 — 가장 관대하지만 겹침 목록 관리 로직이 추가로 필요함 |

**선택**: `ShapeCast3D`. 코미디 협동 게임 특성상 정밀한 조준을 요구하지 않는 편이 낫고, `Area3D`의 겹침 목록 관리 없이도 충분히 관대한 판정을 얻을 수 있다.

- **감지 거리/형태**: `CameraPivot` 정면 방향으로 짧은 캡슐/구 캐스트. `GrabShapeCast`(T071에서 `InteractShapeCast`를 개명)가 `CameraPivot`의 자식이므로 카메라가 보는 방향과 감지 방향이 항상 일치한다 (섹션 4.1). T073부터는 `Camera3D`와 완전히 같은 로컬 원점에 위치해 화면 중앙(조준점)과 감지 방향이 구조적으로 정확히 일치한다(오프셋이 0이라 정렬 오차가 발생할 수 없음, 헤드리스 실측으로도 0px 확인). 거리는 노드 속성 `target_position`으로 관리(2.2m).
- **감지 대상 식별**: `get_collider()` 결과가 `GrabbableBody` 타입인지 확인(T071 이전에는 `package` 그룹 여부로 판단). 여러 후보가 감지 범위 안에 있으면 Player에 가장 가까운 후보를 우선한다.
- **실제 Grab Point 캡처(T072)**: 후보를 확정할 때 `GrabShapeCast.get_collision_point(i)`로 그 순간의 실제 표면 충돌 지점도 함께 기록한다(`_detected_grab_point`). 실제 클릭 시 이 지점이 물체 중심 대신 `add_grabber()`에 전달되어 잡은 표면 위치가 된다 — 모서리를 잡으면 회전(torque)이 발생하는 이유가 여기서 결정된다(섹션 10.4).
- **충돌 레이어/마스크**: `GrabShapeCast`의 마스크는 Package(4)+PhysicsObject(16)=20을 포함한다(T071에서 Package 전용 4에서 확장, T072에서 무변경). `World`/`Player` 레이어는 제외해 지형이나 자기 자신이 걸리지 않게 한다.
- **잘못된 대상 방지**: 마스크로 1차 필터링, `GrabbableBody` 타입 검사로 2차 확인, 별도 물리적 가시선(Ray Query, 섹션 10.4) 검사로 벽이나 다른 `Grabbable`에 가려진 후보를 3차 제외. 이미 다른 상태(이미 자신이 잡은 상태)인 대상은 `Player.held_grabbable`로 판단해 같은 물체를 중복 요청하지 않는다(다른 Grabber가 이미 잡은 대상은 `GrabbableBody.has_grabber()`가 개별 Grabber 기준이라 추가로 잡을 수 있다, T072).

처음부터 범용 `Interactable` 인터페이스나 상호작용 프레임워크는 만들지 않는다 — T072 기준으로도 잡기 대상은 `GrabbableBody` 계열뿐이고, `E`(`interact`)는 입력만 예약되어 있을 뿐 실제 처리 대상이 아직 없다.

## 12. 배송 구역 구조

`DeliveryZone.tscn` 기본 구조:

- `Area3D` + `CollisionShape3D`(트리거) + `MeshInstance3D`(시각 확인용).
- **감지 방법**: `body_entered(body: Node3D)` 시그널을 연결한다.
- **성공 조건**: `body.is_in_group("package")`이고 아직 `is_delivered`가 `false`인 경우.
- **성공 이벤트 전달**: `DeliveryZone.gd`가 커스텀 시그널 `package_delivered`를 발생시킨다. `PrototypeLevel.gd`가 이 시그널을 구독해 `DeliveryHUD.show_success()`를 호출한다. (발신: `DeliveryZone` / 수신: `PrototypeLevel`)
- **중복 성공 방지**: `DeliveryZone.gd` 내부의 `var is_delivered: bool = false` 플래그를 최초 성공 시 `true`로 바꾸고, 이후 진입은 무시한다.
- **다시 시작 흐름**: `restart` 액션 입력은 `DeliveryZone.gd`가 아니라 `PrototypeLevel.gd`가 감지한다. `PrototypeLevel.gd`가 `get_tree().reload_current_scene()`을 호출해 현재 씬(`PrototypeLevel.tscn`)을 다시 로드한다. MVP-1에는 저장해야 할 영속 상태가 없으므로 씬 재로드만으로 충분하다. (별도의 수동 리셋 로직을 만들지 않는다.)

## 13. UI 구조

MVP UI 요소 (`docs/GAME_DESIGN.md` MVP UI 범위와 동일):

- 현재 목표 안내 (`GoalLabel`, 고정 텍스트로 시작 시 표시) — **아직 구현되지 않음**(T052에서 "성공 표시만 구현"으로 범위 축소, `GAME_DESIGN.md` 완료 조건에는 포함되지 않아 MVP-1 판정에는 영향 없음)
- 배송 성공 메시지 (`SuccessLabel`, 성공 시에만 표시) — 구현됨
- 다시 시작 안내 (`RestartLabel`, 성공 시 `SuccessLabel`과 함께 표시) — 구현됨

`DeliveryHUD.gd`는 `show_success()`처럼 표시 상태를 바꾸는 함수만 제공한다. 배송 성공 여부를 스스로 확인(폴링)하지 않고, `PrototypeLevel.gd`가 `DeliveryZone`의 시그널을 받아 호출해줄 때만 반응한다. 별도의 UI Manager(Autoload)는 만들지 않는다.

## 14. 게임 흐름 및 상태

```text
시작 → 플레이 가능 → 택배 배송 구역 진입 → 배송 성공 → 성공 메시지 → 재시작
```

MVP-1은 사실상 "성공 전 / 성공 후" 두 상태뿐이다. 이는 이미 `DeliveryZone.gd`의 `is_delivered: bool` 하나로 표현된다. 재시작은 상태를 이어가는 것이 아니라 씬 자체를 새로 로드하는 방식(섹션 12)이므로, 별도의 "재시작 상태"도 필요 없다.

**결정**: 정식 상태 머신(State Machine)을 도입하지 않는다. `PrototypeLevel.gd`는 자체 상태 변수를 두지 않고, `DeliveryZone`의 시그널만 받아 `DeliveryHUD`를 갱신하는 얇은 연결 역할만 한다.

## 15. Input Map

| 액션 이름 | 기본 키 | 비고 |
|---|---|---|
| `move_forward` | `W` | |
| `move_backward` | `S` | |
| `move_left` | `A` | |
| `move_right` | `D` | |
| `jump` | `Space` | |
| `sprint` | `Shift` | |
| `grab_object` | 마우스 왼쪽 버튼 | T072: 누르는 순간 실제 클릭 지점을 잡기, 누르고 있는 동안 Spring-Damper 힘으로 유지, 놓는 순간 그 시점의 운동량을 유지한 채 놓기(별도 릴리즈 임펄스 없음) (섹션 10.2) |
| `interact` | `E` | T072 기준 코드 경로 없음 — 향후 버튼/문/레버 등 범용 상호작용을 위해 예약 (섹션 10.2) |
| `restart` | `R` | `PrototypeLevel.gd`가 처리, 씬 재로드 (섹션 12) |
| `release_mouse` | `Esc` | 마우스 캡처 해제 |

차량과 문 관련 입력(`CLAUDE.md` 섹션 6, `docs/GAME_DESIGN.md` 섹션 27 제외 기능)은 MVP-1 Input Map에 추가하지 않는다.

## 16. 충돌 레이어와 마스크

예시 후보로 제시된 5개 레이어(World/Player/Package/Interaction/DeliveryZone) 중 `Interaction`은 MVP-1에서 `Package` 레이어와 역할이 겹친다 — 상호작용 대상이 `Package` 하나뿐이므로 `InteractShapeCast`(현 `GrabShapeCast`)가 `Package` 레이어를 직접 목표로 삼으면 충분하다. 따라서 **4개 레이어**로 줄였다. T064에서 환경 물리 오브젝트용으로 `PhysicsObject`(16) 레이어가 추가되어 현재는 5개 레이어(World/Player/Package/DeliveryZone/PhysicsObject)이며, T071은 `GrabShapeCast`의 마스크에 `PhysicsObject`를 추가(4→20)했을 뿐 레이어 체계 자체는 재설계하지 않았다. 문/버튼 등 실제 상호작용 대상이 생기면 그때 `Interaction` 레이어 도입을 재검토한다.

| 레이어 번호 | 이름 | 사용 노드 |
|---|---|---|
| 1 | World | `PrototypeLevel`의 정적 지형(`StaticBody3D`: 바닥, 벽, 계단, 경사로, T065 `TestWall`, T066 `NarrowDoorwayTestArea`) |
| 2 | Player | `Player` (`CharacterBody3D`) |
| 3 | Package | `Package` (`RigidBody3D`) |
| 4 | DeliveryZone | `DeliveryZone` (`Area3D`) |
| 5 | PhysicsObject | T064에서 추가: `PhysicsBarrel`/`PhysicsCrate`/`SmallPhysicsBox` (`RigidBody3D`) |
| 6 | GrabBarrier | T072 결함 수정에서 추가: `Player`의 자식 `GrabCollisionBarrier` (`AnimatableBody3D`) 전용 |

| 노드 | 소속 레이어 | 충돌/감지 마스크 |
|---|---|---|
| `PrototypeLevel` 지형 | World(1) | 없음 (정적 지형은 스스로 감지할 필요 없음). 실제로는 `collision_mask`를 명시적으로 설정하지 않아 엔진 기본값(1)이 남아있으나, `StaticBody3D`는 스스로 감지 질의를 하지 않으므로 실질적 영향은 없음 |
| `Player` | Player(2) | World(1), Package(3) |
| `Player`의 `GrabShapeCast`(T071에서 `InteractShapeCast`를 개명) | (물리 바디 아님) | Package(3), PhysicsObject(5) — T071에서 확장 |
| `Player`의 `GrabCollisionBarrier`(T072 결함 수정에서 추가) | GrabBarrier(6) | 없음(`collision_mask=0`) — 스스로 감지하지 않고, 잡힌 물체 쪽에서 이 레이어를 향해 충돌 |
| `Package`/`PhysicsBarrel`/`Crate`/`SmallBox`(잡히지 않은 상태) | Package(3) 또는 PhysicsObject(5) | World(1), Player(2), Package(3), (PhysicsObject 계열은 PhysicsObject(5)도 포함) |
| `Package`/`PhysicsBarrel`/`Crate`/`SmallBox`(잡힌 동안, T072 결함 수정) | 위와 동일 | 위 마스크에 GrabBarrier(6) 비트가 일시적으로 추가되고, 실제 Player 몸(Player 레이어)과는 `add_collision_exception_with()`로 개별 예외 처리됨 — 마지막 Grabber가 안전 분리(연속 3프레임 미겹침)된 뒤 원래 마스크로 복구 |
| `DeliveryZone` | DeliveryZone(4) | Package(3) — Player/World/PhysicsObject는 감지하지 않아 Package 외에는 배송 성공하지 않음(T071에서도 무변경) |

## 17. 신호와 참조 관계

- **직접 참조가 적절한 경우**: 소유 관계가 명확한 부모-자식 (`Player.gd`가 자신의 `CameraPivot`/`GrabShapeCast`/`HoldPoint`/`GrabCollisionBarrier`를 `@onready var`로 참조, `PrototypeLevel.gd`가 자신이 배치한 `Player`/`Package`/`DeliveryZone`/`DeliveryHUD`를 참조).
- **Signal이 적절한 경우(추가, T073)**: `Player.gd`의 `grab_aim_state_changed` → `PrototypeLevel.gd`가 중개해 `DeliveryHUD.set_crosshair_state()`로 전달. 조준점 UI는 Player의 감지 결과를 직접 참조하지 않고(Player와 DeliveryHUD는 서로 다른 그룹 하위의 형제 씬), 기존 `DeliveryZone.package_delivered → PrototypeLevel → DeliveryHUD.show_success()`와 동일한 패턴을 재사용한다.
- **Signal이 적절한 경우**: 서로 다른 책임을 가진 씬 간 통지 (`DeliveryZone` → `PrototypeLevel`의 `package_delivered`). 발신자는 자신의 상태 변화만 알리고, 수신자가 무엇을 할지는 관여하지 않는다.
- **그룹 검색이 적절한 경우**: 타입을 강하게 결합하지 않고 여러 대상 중 식별만 하면 될 때 (`DeliveryZone`에 들어온 `body`가 `package` 그룹인지). `GrabShapeCast` 결과는 T071부터 그룹이 아니라 `GrabbableBody` 타입 검사로 판단한다.
- **`get_node()` 경로 의존성 축소**: `@onready var` + `%UniqueName`(고유 이름 노드)을 우선 사용한다. `../../..` 같은 깊은 상대 경로 탐색은 사용하지 않는다.

**주요 참조 흐름**:

```text
Player --(GrabShapeCast 감지 + 실제 충돌 지점)--> GrabbableBody(Package/Barrel/Crate/SmallBox)
Player --(add_grabber / remove_grabber 호출)--> GrabbableBody
Package --(body_entered)--> DeliveryZone
DeliveryZone --(signal: package_delivered)--> PrototypeLevel
PrototypeLevel --(직접 호출: show_success())--> DeliveryHUD
PrototypeLevel --(restart 입력)--> get_tree().reload_current_scene()
```

## 18. 데이터와 튜닝 값

아래 값은 모두 export 변수로 두어 Inspector에서 조정한다. **T061에서 실제 플레이 검증을 거쳐 아래 값으로 최종 동결(Baseline Freeze)되었다.**

| 값 | 소속 스크립트 | 최종값(T061) |
|---|---|---|
| 걷기 속도(`walk_speed`) | `Player.gd` | 4.0 |
| 달리기 속도(`sprint_speed`) | `Player.gd` | 7.0 |
| 점프 속도(`jump_velocity`) | `Player.gd` | 6.0 |
| 가속도(`acceleration`) / 감속도(`deceleration`) | `Player.gd` | 20.0 / 25.0 |
| 마우스 감도(`mouse_sensitivity`) | `Player.gd` | 0.003 |
| 카메라 수직 회전 제한(`min_pitch`/`max_pitch`) | `Player.gd` | -80.0 / 55.0 |
| (실제 추가) 밀기 힘(`push_force`) / 최대 밀림 속도(`max_push_speed`) | `Player.gd` | 220.0 / 2.0 |
| 상호작용 감지 거리/형태 | `Player.tscn`의 `GrabShapeCast`(T071에서 `InteractShapeCast`를 개명, export 변수 아닌 노드 속성) | radius 0.3, target distance 2.2m |
| Spring 상수(`grab_spring_strength`, T072 신규) | `GrabbableBody.gd`(모든 Grabbable 공유) | 500.0 — TODO: 프로토타입 값, 실측 재검증 필요. HandPoint 방향으로 끌어당기는 힘의 세기, mass가 클수록 평형 처짐(mass×gravity/이 값)이 커짐 |
| 감쇠 계수(`grab_damping`, T072 신규) | `GrabbableBody.gd` | 60.0 — TODO: 프로토타입 값, 실측 재검증 필요. 진동 억제, 질량이 클수록 상대적으로 저감쇠(더 크게 출렁임) |
| Grabber 1명당 최대 힘(`max_force_per_grabber`, T072 신규) | `GrabbableBody.gd` | 300.0 — TODO: 프로토타입 값, 실측 재검증 필요. 여러 Grabber는 각자 이 상한 안에서 독립적으로 힘을 내고 합산됨 |
| Spring 힘 계산용 displacement 상한(`max_spring_distance`, T072 신규) | `GrabbableBody.gd` | 2.5 — 대부분 `max_force_per_grabber`가 먼저 힘을 제한하는 2차 안전장치 |
| 연결 유지 최대 거리(`max_grab_distance`, T072, 기존 `max_hold_distance` 값 승계) | `GrabbableBody.gd` | 3.0 |
| HandPoint 속도 상한(`max_target_speed`, T072 신규) | `GrabbableBody.gd` | 15.0 — 순간 이동/저프레임으로 인한 속도 폭주 방지 |

`throw_impulse_strength`(고정 던지기 힘)는 T071에서 고정 Throw 자체가 제거되며 함께 삭제되었다. `follow_acceleration`(고정 추종 가속도)은 T071에서 `max_carry_force` 기반 질량 계산으로 대체되었다가, `follow_strength`/`max_follow_speed`/`max_carry_force`/`_MAX_SWING_SPEED`/`_SWING_IMPULSE_GAIN` 전부 **T072에서 Force-Based Grab으로 대체되며 완전히 삭제**되었다(`TECH_DEBT.md` TD-012, TD-013).

MVP-1에서는 별도의 설정 Resource나 데이터 테이블을 만들지 않는다 — 값의 개수가 적고 스크립트별 소속이 명확하다.

## 19. 오류 처리와 방어 조건

| 상황 | 대응 원칙 |
|---|---|
| 잡던 `GrabbableBody`가 삭제됨 (예: 씬 재로드 중 참조 끊김) | 참조 사용 전 `is_instance_valid()` 확인, 무효하면 보유 참조를 `null`로 정리 |
| 잡을 대상이 없음 (`grab_object`를 눌렀지만 감지 결과 없음) | 오류 아님, 아무 동작도 하지 않음 |
| 배송 구역에 잘못된 물체가 들어옴 | `package` 그룹이 아니면 `DeliveryZone`이 무시 (오류 아님) |
| 필요한 노드 참조가 없음 (`@onready var` 대상이 씬에서 삭제/이름 변경됨) | `_ready()`에서 `assert()` 또는 `push_error()`로 즉시 드러나게 한다 — 조용히 넘어가지 않는다 |
| 같은 Grabber가 같은 물체를 중복으로 잡으려 함 | `GrabbableBody.add_grabber()`가 `grab_connections.has(grabber)`를 확인해 중복 연결을 거부(false 반환) |
| 성공 판정이 여러 번 발생 (Area3D가 겹치며 `body_entered`가 중복 호출될 가능성) | `DeliveryZone.is_delivered` 플래그로 최초 1회만 처리 (섹션 12) |
| 연결이 Player와 최대 허용 거리를 벗어남 (장애물에 막혀 추종이 계속 실패하는 경우 등) | `GrabbableBody._integrate_forces()`가 그 연결만 `grab_connections`에서 제거한다(다른 Grabber의 연결에는 영향 없음) — 물리량이 비정상적으로 커지지 않게 한다 (섹션 10.4) |
| Spring-Damper 힘 계산 중 NaN 발생(비정상 delta 등) | `is_nan()` 검사로 해당 프레임의 힘 적용만 건너뛰고(`continue`) 연결 자체는 유지 |

경고와 오류는 숨기지 않고 Godot 출력 창에서 원인을 확인할 수 있게 한다 (`CLAUDE.md` 섹션 4).

## 20. 테스트 방법

MVP-1은 자동 테스트 프레임워크나 외부 Addon(GUT 등)을 도입하지 않는다. 아래 항목을 에디터에서 직접 플레이하며 수동으로 확인한다.

| 항목 | 확인 방법 |
|---|---|
| 이동 | WASD로 4방향 이동이 되는지 |
| 점프 | Space로 점프하고 정상적으로 착지하는지 |
| 달리기 | Shift를 누른 동안 이동 속도가 빨라지는지 |
| 카메라(T073, 1인칭) | 마우스로 좌우(Player yaw)/상하(CameraPivot pitch) 회전이 되고, 상하 회전이 제한되는지. 카메라가 Player 눈높이에 있고 3인칭처럼 뒤로 빠지지 않는지 |
| 로컬 Player Mesh 은닉(T073) | 자신의 캐릭터 Mesh가 시야를 가리지 않는지(카메라 cull_mask로 제외) |
| 조준점(T073) | 화면 정중앙에 항상 표시되는지, Grab 가능한 대상을 조준하면 표시가 바뀌는지, 잡고 있는 동안 또 다른 표시로 구분되는지 |
| 마우스 재캡처 | `Esc`로 마우스를 해제한 뒤 게임 화면을 클릭하면 다시 캡처되는지, 그 클릭이 `grab_object`로 오작동하지 않는지 |
| 잡기(T072) | `Package`/`PhysicsBarrel`/`PhysicsCrate`/`SmallPhysicsBox` 근처에서 마우스 왼쪽 버튼을 누르면 클릭한 표면 지점이 잡히고, 누르고 있는 동안 유지되는지. 모서리를 잡으면 자연스럽게 기울거나 회전하는지, 무거운 물체일수록 손 아래에서 처지고 출렁이는지 |
| 놓기(T072) | 마우스 왼쪽 버튼을 떼면 그 순간의 운동량을 유지한 채 놓이는지(별도 고정 Throw나 스윙 임펄스 없이), 정지 상태에서는 자연스럽게 떨어지고 빠르게 화면을 돌리며 놓으면 그 방향·속도에 비례해 날아가는지 |
| `E`(T072) | 아무 것도 잡거나 놓지 않는지(예약된 입력) |
| 잡기 안전 조건(T072) | 잡은 대상이 정적 장애물에 막히거나 최대 허용 거리를 넘으면 자동으로 연결이 해제되는지, 속도가 비정상적으로 커지지 않는지, 다른 Grabbable과 스치는 것만으로는 자동으로 놓이지 않는지, 잡은 Package로 Crate를 밀어도 무한한 힘처럼 작동하지 않는지, Player 쪽으로 물체를 당기거나 좌우로 스윙해도 관통하지 않는지 |
| 계단 이동 | `Package`를 든 채로 계단을 오르내릴 수 있는지 |
| 경사로 이동 | `Package`를 든 채로 경사로를 통과할 수 있는지 |
| 배송 성공 | `Package`를 `DeliveryZone`에 넣으면 성공 메시지가 뜨는지, 중복 발생하지 않는지 |
| 재시작 | `R` 입력 시 씬이 초기 상태로 재시작되는지 |

## 21. 구현 순서

기술 의존성을 고려한 순서다. 각 단계는 독립적으로 검증 가능한 단위로 나눈다.

1. 프로젝트 및 Input Map 확인/설정
2. `PrototypeLevel` 지형(바닥, 계단, 경사로) 배치
3. `Player` 이동
4. 카메라
5. `Package` 물리
6. 상호작용 감지 (`GrabShapeCast`)
7. 잡기와 놓기
8. 던지기
9. 계단과 경사로 통과 테스트
10. `DeliveryZone`
11. 성공 UI (`DeliveryHUD`)
12. 재시작
13. 통합 테스트와 튜닝

## 22. 의도적으로 미루는 결정

다음 항목은 MVP-1 범위 밖이며 지금 확정하지 않는다.

- 다인 운반 구현 방식 (Phase 5)
- 온라인 네트워크 구조 (Phase 6)
- 차량 구조 (Phase 7)
- 내구도와 파손 구조 (Phase 8)
- 정식 아이템 데이터 구조 (Phase 8)
- 저장 방식 (Phase 8 이후, 경제 시스템과 함께 검토)
- Steamworks 구조 (Phase 9)
- 정식 로컬 멀티플레이(분할 화면 등) (Phase 5 이후 재검토)
- 캐릭터 애니메이션 아키텍처
- 정식 사운드 시스템

## 23. 아키텍처 변경 규칙

- 문서와 실제 구현이 달라질 경우 먼저 이유를 설명한다.
- 구현 중 발견된 제약으로 구조 변경이 필요하면 승인 전에 대규모로 변경하지 않는다.
- 구현 완료 후 확정된 변경만 이 문서(`ARCHITECTURE.md`)에 반영한다.
- 아직 구현하지 않은 예상 구조를 확정 사실처럼 기록하지 않는다.
