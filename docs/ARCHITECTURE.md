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
│     ├─ Hud.tscn
│     └─ Hud.gd
└─ icon.svg (기존 파일)
```

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
| `PrototypeLevel.tscn` | 지형 배치, 하위 씬 조립, 배송 성공 신호를 UI로 연결, MVP-1에서 Main 역할 겸임 | `Node3D` | 프로젝트의 `run/main_scene`으로 지정 |
| `Hud.tscn` | 목표/성공/재시작 안내 텍스트 표시만 담당 | `CanvasLayer` | 게임 상태를 직접 판정하지 않음 |

### 4.1 `Player.tscn`

- **책임**: 이동 입력 처리, 마우스 기반 카메라 회전, 상호작용 대상 감지, 현재 잡고 있는 `Package` 참조 관리(요청만 — 실제 물리 반응은 `Package`가 스스로 처리).
- **예상 노드 구조**:
  ```text
  Player (CharacterBody3D)
  ├─ CollisionShape3D
  ├─ MeshInstance3D              (플레이스홀더 캡슐)
  └─ CameraPivot (Node3D)
     ├─ HoldPoint (Marker3D)      (잡은 물체가 향할 목표 위치)
     ├─ InteractShapeCast (ShapeCast3D)
     └─ SpringArm3D
        └─ Camera3D
  ```
  `HoldPoint`와 `InteractShapeCast`를 `CameraPivot`의 자식으로 둔 이유는 카메라 방향과 상호작용/잡기 방향을 일치시키기 위해서다 (이전 버전에서는 `CameraPivot`의 형제 노드였고, 이 경우 카메라를 돌려도 상호작용 방향이 따라가지 않는 불일치가 있었다). 수직 회전(위/아래를 볼 때) 때문에 `HoldPoint`가 함께 위아래로 움직여 운반 조작이 불편해지는 경우가 확인되면, 구현 테스트 후 `HoldPoint`/`InteractShapeCast`만 수평 회전만 따르는 별도 피벗으로 분리하는 것을 검토한다. MVP-1 설계 단계에서는 분리하지 않는다.
- **연결 스크립트**: `Player.gd` (루트에 부착).
- **다른 씬과의 관계**: `PrototypeLevel.tscn`이 자식으로 인스턴스화. `Package`는 직접 자식으로 삼지 않고(재부모화하지 않음) 참조만 보유한다 — 이유는 섹션 10 참고.
- **직접 소유하면 안 되는 책임**: `Package`의 물리 상태 전환(그 책임은 `Package.gd`), 배송 성공 판정(그 책임은 `DeliveryZone.gd`), UI 표시(그 책임은 `Hud.gd`), `restart` 입력 처리와 씬 재로드(그 책임은 `PrototypeLevel.gd` — 섹션 12, 17 참고).

### 4.2 `Package.tscn`

- **책임**: 물리 충돌, 잡힌 동안 목표 위치를 따라가는 물리 반응, 놓였을 때 물리 상태 복원, 던져졌을 때 힘 적용.
- **예상 노드 구조**:
  ```text
  Package (RigidBody3D)
  ├─ CollisionShape3D
  └─ MeshInstance3D             (플레이스홀더 박스)
  ```
- **연결 스크립트**: `Package.gd`. `package` 그룹에 추가한다 (상호작용 대상 식별용, 섹션 11·17).
- **다른 씬과의 관계**: `PrototypeLevel.tscn`이 시작 위치에 인스턴스화. `Player`가 참조를 들고 있는 동안에도 씬 트리 소속은 그대로 유지한다(재부모화하지 않음).
- **직접 소유하면 안 되는 책임**: 입력 처리(그 책임은 `Player.gd`), 배송 성공 판정(그 책임은 `DeliveryZone.gd`).

### 4.3 `DeliveryZone.tscn`

- **책임**: 올바른 `Package`가 영역에 들어왔는지 감지하고, 최초 1회만 배송 성공으로 판정해 통지.
- **예상 노드 구조**:
  ```text
  DeliveryZone (Area3D)
  ├─ CollisionShape3D            (트리거 볼륨)
  └─ MeshInstance3D              (반투명 시각 표시용)
  ```
- **연결 스크립트**: `DeliveryZone.gd`.
- **다른 씬과의 관계**: `PrototypeLevel.tscn`이 목적지 위치에 인스턴스화. 성공 시 시그널로 `PrototypeLevel.gd`에 통지한다.
- **직접 소유하면 안 되는 책임**: UI 표시, 재시작 처리, Player/Package의 물리 상태 변경.

### 4.4 `PrototypeLevel.tscn`

- **책임**: 지형(바닥, 계단, 경사로) 배치, `Player`/`Package`/`DeliveryZone`/`Hud` 조립, `DeliveryZone`의 성공 신호를 받아 `Hud`에 전달, `restart` 입력을 감지해 씬을 재로드, MVP-1 한정으로 `Main`의 역할(진입점) 겸임.
- **예상 노드 구조**: 섹션 5 참고.
- **연결 스크립트**: `PrototypeLevel.gd` — 신호 연결과 재시작 입력 처리만 담당하는 얇은 스크립트.
- **직접 소유하면 안 되는 책임**: 이동/카메라/상호작용 세부 로직(각 하위 씬의 책임), 배송 판정 세부 로직(`DeliveryZone`의 책임).

### 4.5 `Hud.tscn`

- **책임**: 현재 목표 안내, 배송 성공 메시지, 재시작 안내 텍스트를 표시.
- **예상 노드 구조**:
  ```text
  Hud (CanvasLayer)
  └─ MarginContainer
     └─ VBoxContainer
        ├─ GoalLabel (Label)
        ├─ SuccessLabel (Label, 시작 시 숨김)
        └─ RestartLabel (Label, 시작 시 숨김)
  ```
- **연결 스크립트**: `Hud.gd` — `show_success()` 같은 표시 전용 함수만 제공.
- **직접 소유하면 안 되는 책임**: 배송 성공 여부 판정, 재시작 실행 자체(입력 처리는 `PrototypeLevel.gd`가 담당하고 `Hud`는 표시만 한다).

## 5. 메인 실행 구조

`Main.tscn`과 `PrototypeLevel.tscn`을 분리할 필요가 있는지 검토한 결과:

- MVP-1에는 타이틀 화면, 메뉴, 여러 레벨 간 전환이 없다 (`docs/GAME_DESIGN.md` MVP 필수 기능 기준).
- `Main`이 하는 일이 사실상 "`PrototypeLevel`을 띄운다" 하나뿐이라면, 별도 씬으로 분리하는 것은 섹션의 지시대로 불필요한 계층이다.

**결정**: MVP-1에서는 `PrototypeLevel.tscn`을 프로젝트의 실행 씬(`run/main_scene`)으로 직접 지정한다. `Main.tscn`은 별도 파일로 만들지 않는다. 메뉴/여러 레벨 전환이 필요해지는 Phase(예: Phase 8 정식 맵, Phase 9 Steam 준비)에서 `Main.tscn`을 다시 분리해 씬 전환 진입점으로 되살린다.

```text
PrototypeLevel   (프로젝트 실행 씬, MVP-1에서 Main 역할 겸임)
├─ Environment    (바닥, 계단, 경사로 — StaticBody3D 모음)
├─ Player
├─ Package
├─ DeliveryZone
└─ Hud
```

## 6. 플레이어 구조

`Player.tscn`의 책임을 4가지로 구분한다.

| 책임 | 담당 |
|---|---|
| 이동 (입력 → 속도 계산 → `move_and_slide()`) | `Player.gd` |
| 카메라 회전 (마우스 입력 → `CameraPivot` 회전) | `Player.gd` (`CameraPivot`/`SpringArm3D`/`Camera3D` 노드를 직접 참조) |
| 상호작용 감지 (`InteractShapeCast` 결과 확인) | `Player.gd` |
| 잡은 물체 관리 (어떤 `Package`를 잡고 있는지 참조 보유, 놓기/던지기 요청) | `Player.gd` |

`HoldPoint`와 `InteractShapeCast`는 `CameraPivot`의 자식이므로 카메라 회전을 그대로 따라간다 (섹션 4.1 참고). `restart` 입력 처리는 `Player.gd`의 책임이 아니다 — `PrototypeLevel.gd`가 담당한다 (섹션 12, 17).

MVP-1에서는 이 4가지 책임을 모두 `Player.gd` 하나가 담당한다. 노드 수가 적고(6개 미만) 각 책임의 로직이 짧기 때문에, 지금 여러 컴포넌트 스크립트로 쪼개는 것은 과도한 추상화다.

**기록해 둘 위험**: `Player.gd`가 이동+카메라+상호작용+홀드 관리를 모두 가지므로, 기능이 추가될수록(예: Phase 7 차량 탑승) 하나의 스크립트가 비대해질 위험이 있다. 스크립트가 200줄을 넘거나 서로 무관한 책임이 늘어나면, 카메라 로직을 `CameraPivot`에 붙는 별도 스크립트로 분리하는 것을 그 시점에 재검토한다. MVP-1에서는 분리하지 않는다.

## 7. 플레이어 이동 방식

- **입력 벡터**: `Input.get_vector("move_left", "move_right", "move_forward", "move_backward")`로 2축 입력을 얻는다.
- **카메라 방향 기준 이동**: 입력 벡터를 `CameraPivot`의 글로벌 기준(수평 성분만)으로 변환해 이동 방향을 계산한다.
- **중력**: 바닥에 닿아 있지 않을 때 매 물리 프레임 속도에 중력을 누적한다.
- **점프**: 바닥에 닿아 있고 `jump` 액션이 눌리면 수직 속도를 점프 속도로 설정한다.
- **달리기**: `sprint` 액션을 누르고 있는 동안 목표 속도를 달리기 속도로 전환한다.
- **감속/정지**: 즉시 정지가 아니라 `move_toward()`로 목표 속도까지 가감속시켜 급정지로 인한 부자연스러움을 줄인다.
- **이동 함수**: `move_and_slide()`를 사용한다.
- **처리 위치**: 위 로직 전부 `_physics_process(delta)`에서 수행한다 (`CLAUDE.md` 섹션 5).

정확한 이동/점프 속도 수치는 이 문서에서 확정하지 않는다. 모두 `Player.gd`의 export 변수로 두고 Inspector에서 조정한다 (섹션 18).

## 8. 카메라 구조

- **구조**: `Player` → `CameraPivot(Node3D)` → `SpringArm3D` → `Camera3D`.
- **수평 회전**: 마우스 X 이동 → `CameraPivot`을 Y축 기준으로 회전.
- **수직 회전**: 마우스 Y 이동 → `CameraPivot`을 로컬 X축 기준으로 회전, 위/아래 각도를 export 변수로 제한(clamp)한다.
- **벽 충돌 대응**: `SpringArm3D`의 내장 충돌 검사 기능을 그대로 사용한다 (별도 카메라 충돌 로직을 직접 구현하지 않는다).
- **마우스 캡처**: 게임 시작 시 `Input.MOUSE_MODE_CAPTURED`로 설정. `release_mouse` 액션 입력 시 `Input.MOUSE_MODE_VISIBLE`로 전환.
- **마우스 캡처 복귀**: 마우스가 해제된 상태(`MOUSE_MODE_VISIBLE`)에서 게임 화면을 클릭하면 다시 `Input.MOUSE_MODE_CAPTURED`로 전환한다. 이 클릭 입력은 `throw_package` 등 게임 조작 액션으로 동시에 처리되지 않는다 — 마우스가 해제된 상태에서는 클릭을 먼저 재캡처 용도로 소비하고, 게임 조작으로는 넘기지 않는다.

카메라 로직은 `Player.gd` 안에 둔다. 별도의 전역 카메라 Manager(Autoload 등)는 만들지 않는다 (`CLAUDE.md` 섹션 4).

## 9. 택배 구조

`Package.tscn`의 기본안:

- 루트 노드: `RigidBody3D`.
- `CollisionShape3D` + `MeshInstance3D`(플레이스홀더 박스 메시).
- **상호작용 식별 방식**: `package` 그룹에 추가. `Player`의 `InteractShapeCast`가 감지한 노드가 이 그룹에 속하는지로 판단한다 (섹션 11, 17).
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

### 10.2 잡기 조작 확정 (홀드 방식)

MVP-1은 **홀드(hold) 방식**을 사용한다. 토글(누를 때마다 잡기/놓기 전환) 방식은 사용하지 않는다.

- `E`(`interact`)를 누르는 순간 잡기를 시도한다.
- `E`를 누르고 있는 동안 잡은 상태를 유지한다.
- `E`를 놓는 순간 `Package`를 놓는다.
- 잡은 상태에서 마우스 왼쪽 버튼(`throw_package`)을 누르면 `Package`를 던지고, 동시에 잡은 상태를 해제한다.

### 10.3 책임 분리

- `Player.gd`: `interact`/`throw_package` 입력을 감지해 "이 `Package`를 잡아라 / 놓아라 / 던져라"를 `Package`에 요청만 한다.
- `Package.gd`: 잡힌 상태(`is_held`)를 스스로 관리하고, 잡힌 동안 `_physics_process()`에서 자신의 위치를 `HoldPoint` 목표 위치로 추종시키는 물리 계산을 직접 수행한다. 놓일 때 추종을 멈추고, 던져질 때 `Player`가 전달한 방향으로 임펄스를 추가한다.

```text
Player: interact 누르는 순간 & 잡은 것 없음
  → InteractShapeCast 결과가 "package" 그룹이면 Package.grab(hold_point) 호출
Player: interact를 누르고 있는 동안
  → 잡은 상태 유지 (매 프레임 Package가 HoldPoint를 추종)
Player: interact 놓는 순간 & 잡은 것 있음
  → Package.release() 호출
Player: throw_package 누르는 순간 & 잡은 것 있음
  → Package.throw(camera_forward_direction) 호출 (내부적으로 release 겸함, 잡은 상태 즉시 해제)
```

추종 속도, 최대 추종 속도, 던지기 힘 등 정확한 수치는 확정하지 않고 export 변수로 관리한다 (섹션 18). **이 섹션은 설계만 정의하며, 지금 구현하지 않는다.**

### 10.4 물리 추종 안전 조건

목표 위치 추종 방식(섹션 10.1의 A안)은 아무 제한 없이 구현하면 `Package`가 벽/지형에 막혔을 때 속도가 비정상적으로 커지거나, 플레이어가 좁은 틈으로 빠르게 이동할 때 `Package`가 멀리서 순간적으로 튕겨오는 문제가 발생할 수 있다. 이를 막기 위해 다음 안전 조건이 필요하다.

- **최대 추종 속도 제한**: 목표 위치와의 거리가 아무리 멀어도 `linear_velocity`가 일정 값 이상으로 커지지 않도록 상한을 둔다.
- **추종 반응 강도(가속도) 제한**: 매 프레임 속도가 급격히 튀지 않도록, 목표 속도로의 변화량 자체에도 상한을 둔다 (즉시 목표 속도로 스냅하지 않는다).
- **플레이어-`Package` 최대 허용 거리**: `HoldPoint`와 `Package`의 실제 위치 차이가 일정 거리를 넘지 않도록 감시한다.
- **최대 거리 초과 시 자동 놓기**: 위 거리를 초과하면(예: 벽에 막혀 추종이 계속 실패하는 경우) `Package.release()`를 자동 호출해 잡은 상태를 강제로 해제한다 — 물리량이 비정상적으로 누적되는 것을 막는다.
- **장애물에 막혔을 때 속도 과다 증가 방지**: 추종 속도 계산 자체를 "최대 추종 속도" 상한으로 clamp하므로, 장애물에 막혀 목표와의 거리가 벌어져도 속도가 무한정 커지지 않는다.

정확한 수치(최대 추종 속도, 가속도 제한, 최대 허용 거리)는 이 문서에서 확정하지 않는다. 모두 `Package.gd`의 export 변수로 두고 프로토타입 테스트로 조정한다 (섹션 18).

## 11. 상호작용 감지 방식

| 방식 | 특징 |
|---|---|
| `RayCast3D` | 얇은 선 하나로 판정 — 파티 게임 특성상 조준이 까다로워 잘 놓칠 수 있음 |
| `ShapeCast3D` | 구/캡슐 형태로 판정 — 관대한 감지 범위, API는 `RayCast3D`와 유사하게 단순함 |
| `Area3D` | 상시 겹침 목록을 관리 — 가장 관대하지만 겹침 목록 관리 로직이 추가로 필요함 |

**선택**: `ShapeCast3D`. 코미디 협동 게임 특성상 정밀한 조준을 요구하지 않는 편이 낫고, `Area3D`의 겹침 목록 관리 없이도 충분히 관대한 판정을 얻을 수 있다.

- **감지 거리/형태**: `CameraPivot` 정면 방향으로 짧은 캡슐/구 캐스트. `InteractShapeCast`가 `CameraPivot`의 자식이므로 카메라가 보는 방향과 감지 방향이 항상 일치한다 (섹션 4.1). 거리는 export 변수 `interact_distance`로 관리.
- **감지 대상 식별**: `get_collider()` 결과가 `package` 그룹에 속하는지 확인 (`is_in_group("package")`).
- **그룹 사용 여부**: 사용한다 — 특정 클래스 타입 검사 대신 그룹 검사를 사용해 결합도를 낮춘다.
- **충돌 레이어/마스크**: `InteractShapeCast`의 마스크는 `Package` 레이어만 포함한다 (섹션 16). `World`/`Player` 레이어는 제외해 지형이나 자기 자신이 걸리지 않게 한다.
- **잘못된 대상 방지**: 마스크로 1차 필터링, 그룹 검사로 2차 확인. 이미 다른 상태(예: 이미 잡힌 상태)인 `Package`는 `Package.is_held`를 확인해 무시한다.

처음부터 범용 `Interactable` 인터페이스나 상호작용 프레임워크는 만들지 않는다 — MVP-1의 상호작용 대상은 `Package` 하나뿐이다.

## 12. 배송 구역 구조

`DeliveryZone.tscn` 기본 구조:

- `Area3D` + `CollisionShape3D`(트리거) + `MeshInstance3D`(시각 확인용).
- **감지 방법**: `body_entered(body: Node3D)` 시그널을 연결한다.
- **성공 조건**: `body.is_in_group("package")`이고 아직 `is_delivered`가 `false`인 경우.
- **성공 이벤트 전달**: `DeliveryZone.gd`가 커스텀 시그널 `package_delivered`를 발생시킨다. `PrototypeLevel.gd`가 이 시그널을 구독해 `Hud.show_success()`를 호출한다. (발신: `DeliveryZone` / 수신: `PrototypeLevel`)
- **중복 성공 방지**: `DeliveryZone.gd` 내부의 `var is_delivered: bool = false` 플래그를 최초 성공 시 `true`로 바꾸고, 이후 진입은 무시한다.
- **다시 시작 흐름**: `restart` 액션 입력은 `DeliveryZone.gd`가 아니라 `PrototypeLevel.gd`가 감지한다. `PrototypeLevel.gd`가 `get_tree().reload_current_scene()`을 호출해 현재 씬(`PrototypeLevel.tscn`)을 다시 로드한다. MVP-1에는 저장해야 할 영속 상태가 없으므로 씬 재로드만으로 충분하다. (별도의 수동 리셋 로직을 만들지 않는다.)

## 13. UI 구조

MVP UI 요소 (`docs/GAME_DESIGN.md` MVP UI 범위와 동일):

- 현재 목표 안내 (`GoalLabel`, 고정 텍스트로 시작 시 표시)
- 배송 성공 메시지 (`SuccessLabel`, 성공 시에만 표시)
- 다시 시작 안내 (`RestartLabel`, 성공 시 `SuccessLabel`과 함께 표시)

`Hud.gd`는 `show_success()`처럼 표시 상태를 바꾸는 함수만 제공한다. 배송 성공 여부를 스스로 확인(폴링)하지 않고, `PrototypeLevel.gd`가 `DeliveryZone`의 시그널을 받아 호출해줄 때만 반응한다. 별도의 UI Manager(Autoload)는 만들지 않는다.

## 14. 게임 흐름 및 상태

```text
시작 → 플레이 가능 → 택배 배송 구역 진입 → 배송 성공 → 성공 메시지 → 재시작
```

MVP-1은 사실상 "성공 전 / 성공 후" 두 상태뿐이다. 이는 이미 `DeliveryZone.gd`의 `is_delivered: bool` 하나로 표현된다. 재시작은 상태를 이어가는 것이 아니라 씬 자체를 새로 로드하는 방식(섹션 12)이므로, 별도의 "재시작 상태"도 필요 없다.

**결정**: 정식 상태 머신(State Machine)을 도입하지 않는다. `PrototypeLevel.gd`는 자체 상태 변수를 두지 않고, `DeliveryZone`의 시그널만 받아 `Hud`를 갱신하는 얇은 연결 역할만 한다.

## 15. Input Map

| 액션 이름 | 기본 키 | 비고 |
|---|---|---|
| `move_forward` | `W` | |
| `move_backward` | `S` | |
| `move_left` | `A` | |
| `move_right` | `D` | |
| `jump` | `Space` | |
| `sprint` | `Shift` | |
| `interact` | `E` | 홀드 방식: 누르는 순간 잡기 시도, 누르고 있는 동안 유지, 놓으면 `Package` 놓기 (섹션 10.2) |
| `throw_package` | 마우스 왼쪽 버튼 | 잡고 있을 때만 유효, 누르면 던지며 잡은 상태 즉시 해제 (섹션 10.2) |
| `restart` | `R` | `PrototypeLevel.gd`가 처리, 씬 재로드 (섹션 12) |
| `release_mouse` | `Esc` | 마우스 캡처 해제 |

차량과 문 관련 입력(`CLAUDE.md` 섹션 6, `docs/GAME_DESIGN.md` 섹션 27 제외 기능)은 MVP-1 Input Map에 추가하지 않는다.

## 16. 충돌 레이어와 마스크

예시 후보로 제시된 5개 레이어(World/Player/Package/Interaction/DeliveryZone) 중 `Interaction`은 MVP-1에서 `Package` 레이어와 역할이 겹친다 — 상호작용 대상이 `Package` 하나뿐이므로 `InteractShapeCast`가 `Package` 레이어를 직접 목표로 삼으면 충분하다. 따라서 **4개 레이어**로 줄인다. 여러 종류의 상호작용 대상(문, 버튼 등)이 생기면 그때 `Interaction` 레이어 도입을 재검토한다.

| 레이어 번호 | 이름 | 사용 노드 |
|---|---|---|
| 1 | World | `PrototypeLevel`의 정적 지형(`StaticBody3D`: 바닥, 벽, 계단, 경사로) |
| 2 | Player | `Player` (`CharacterBody3D`) |
| 3 | Package | `Package` (`RigidBody3D`) |
| 4 | DeliveryZone | `DeliveryZone` (`Area3D`) |

| 노드 | 소속 레이어 | 충돌/감지 마스크 |
|---|---|---|
| `PrototypeLevel` 지형 | World(1) | 없음 (정적 지형은 스스로 감지할 필요 없음) |
| `Player` | Player(2) | World(1), Package(3) |
| `Player`의 `InteractShapeCast` | (물리 바디 아님) | Package(3) |
| `Package` | Package(3) | World(1), Player(2), Package(3) |
| `DeliveryZone` | DeliveryZone(4) | Package(3) — Player/World는 감지하지 않아 오작동 방지 |

## 17. 신호와 참조 관계

- **직접 참조가 적절한 경우**: 소유 관계가 명확한 부모-자식 (`Player.gd`가 자신의 `CameraPivot`/`SpringArm3D`/`Camera3D`/`InteractShapeCast`/`HoldPoint`를 `@onready var`로 참조, `PrototypeLevel.gd`가 자신이 배치한 `Player`/`Package`/`DeliveryZone`/`Hud`를 참조).
- **Signal이 적절한 경우**: 서로 다른 책임을 가진 씬 간 통지 (`DeliveryZone` → `PrototypeLevel`의 `package_delivered`). 발신자는 자신의 상태 변화만 알리고, 수신자가 무엇을 할지는 관여하지 않는다.
- **그룹 검색이 적절한 경우**: 타입을 강하게 결합하지 않고 여러 대상 중 식별만 하면 될 때 (`InteractShapeCast` 결과가 `package` 그룹인지, `DeliveryZone`에 들어온 `body`가 `package` 그룹인지).
- **`get_node()` 경로 의존성 축소**: `@onready var` + `%UniqueName`(고유 이름 노드)을 우선 사용한다. `../../..` 같은 깊은 상대 경로 탐색은 사용하지 않는다.

**주요 참조 흐름**:

```text
Player --(ShapeCast 감지)--> Package
Player --(grab / release / throw 호출)--> Package
Package --(body_entered)--> DeliveryZone
DeliveryZone --(signal: package_delivered)--> PrototypeLevel
PrototypeLevel --(직접 호출: show_success())--> Hud
PrototypeLevel --(restart 입력)--> get_tree().reload_current_scene()
```

## 18. 데이터와 튜닝 값

아래 값은 모두 export 변수로 두어 Inspector에서 조정한다. 정확한 수치는 이 문서에서 확정하지 않는다.

| 값 | 소속 스크립트 |
|---|---|
| 걷기 속도 | `Player.gd` |
| 달리기 속도 | `Player.gd` |
| 점프 속도 | `Player.gd` |
| 마우스 감도 | `Player.gd` |
| 카메라 수직 회전 제한(최소/최대) | `Player.gd` |
| 상호작용 감지 거리 | `Player.gd` |
| 잡기 반응 속도(추종 속도) | `Package.gd` |
| 잡기 최대 추종 속도 | `Package.gd` |
| 추종 가속도(반응 강도) 제한 | `Package.gd` |
| 플레이어-`Package` 최대 허용 거리(초과 시 자동 놓기) | `Package.gd` |
| 던지기 힘 | `Player.gd` (던질 때 `Package.throw()`에 전달) |

MVP-1에서는 별도의 설정 Resource나 데이터 테이블을 만들지 않는다 — 값이 10개 미만이고 스크립트별 소속이 명확하다.

## 19. 오류 처리와 방어 조건

| 상황 | 대응 원칙 |
|---|---|
| 잡던 `Package`가 삭제됨 (예: 씬 재로드 중 참조 끊김) | 참조 사용 전 `is_instance_valid()` 확인, 무효하면 보유 참조를 `null`로 정리하고 `push_warning()` 기록 |
| 잡을 대상이 없음 (`interact`를 눌렀지만 감지 결과 없음) | 오류 아님, 아무 동작도 하지 않음 |
| 배송 구역에 잘못된 물체가 들어옴 | `package` 그룹이 아니면 `DeliveryZone`이 무시 (오류 아님) |
| 필요한 노드 참조가 없음 (`@onready var` 대상이 씬에서 삭제/이름 변경됨) | `_ready()`에서 `assert()` 또는 `push_error()`로 즉시 드러나게 한다 — 조용히 넘어가지 않는다 |
| 이미 다른 상태인 `Package`를 다시 잡으려 함 | `Package.is_held`를 확인해 이미 잡힌 상태면 새 요청을 무시 |
| 성공 판정이 여러 번 발생 (Area3D가 겹치며 `body_entered`가 중복 호출될 가능성) | `DeliveryZone.is_delivered` 플래그로 최초 1회만 처리 (섹션 12) |
| `Package`가 플레이어와 최대 허용 거리를 벗어남 (장애물에 막혀 추종이 계속 실패하는 경우 등) | `Package.gd`가 자동으로 `release()`를 호출해 잡은 상태를 강제 해제한다 — 물리량이 비정상적으로 커지지 않게 한다 (섹션 10.4) |

경고와 오류는 숨기지 않고 Godot 출력 창에서 원인을 확인할 수 있게 한다 (`CLAUDE.md` 섹션 4).

## 20. 테스트 방법

MVP-1은 자동 테스트 프레임워크나 외부 Addon(GUT 등)을 도입하지 않는다. 아래 항목을 에디터에서 직접 플레이하며 수동으로 확인한다.

| 항목 | 확인 방법 |
|---|---|
| 이동 | WASD로 4방향 이동이 되는지 |
| 점프 | Space로 점프하고 정상적으로 착지하는지 |
| 달리기 | Shift를 누른 동안 이동 속도가 빨라지는지 |
| 카메라 | 마우스로 수평/수직 회전이 되고, 수직 회전이 제한되는지 |
| 마우스 재캡처 | `Esc`로 마우스를 해제한 뒤 게임 화면을 클릭하면 다시 캡처되는지, 그 클릭이 `throw_package`로 오작동하지 않는지 |
| 잡기 | `Package` 근처에서 `E`를 누르면 잡히고, 누르고 있는 동안 유지되는지 |
| 놓기 | `E`를 떼면 자연스럽게 놓이는지 |
| 던지기 | 잡은 상태에서 마우스 왼쪽 버튼으로 던져지고, 잡은 상태가 즉시 해제되는지 |
| 잡기 안전 조건 | `Package`를 든 채 장애물에 막히거나 최대 허용 거리를 넘으면 자동으로 놓이는지, 속도가 비정상적으로 커지지 않는지 |
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
6. 상호작용 감지 (`InteractShapeCast`)
7. 잡기와 놓기
8. 던지기
9. 계단과 경사로 통과 테스트
10. `DeliveryZone`
11. 성공 UI (`Hud`)
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
