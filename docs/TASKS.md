# TASKS.md

## 1. 문서 목적

- 이 문서는 싱글플레이 MVP-1을 구현하기 위한 실행 체크리스트다.
- 우선순위 기준은 `docs/GAME_DESIGN.md` → `CLAUDE.md` → `docs/ARCHITECTURE.md` 순서다.
- 한 번에 하나의 작업만 수행한다.
- 사용자가 명시적으로 다음 작업을 승인하기 전에는 다음 작업을 구현하지 않는다.

## 2. 현재 프로젝트 상태

저장소를 직접 확인한 결과다 (확인 시점 기준, 추측 없음).

| 항목 | 상태 |
|---|---|
| Godot 프로젝트 생성 여부 | 생성됨 (`hell-delivery/project.godot` 존재) |
| 현재 Godot 버전 | 4.7.1 (stable, win64) — `.godot/editor/project_metadata.cfg`의 `executable_path`로 확인. `project.godot`에는 `config/features`로 `"4.7"`만 기록됨 |
| 존재하는 주요 파일 | 저장소 루트: `README.md`, `CLAUDE.md`, `docs/GAME_DESIGN.md`, `docs/ARCHITECTURE.md`, `docs/TASKS.md`(본 문서) / `hell-delivery/`: `project.godot`, `icon.svg`, `icon.svg.import`, `.editorconfig` |
| 존재하는 씬과 스크립트 | 없음 — `scenes/`, `scripts/` 폴더 자체가 아직 생성되지 않음 |
| Input Map 설정 여부 | 없음 — `project.godot`에 `[input]` 섹션이 없음 (Godot 기본 내장 액션만 존재, 커스텀 액션 없음) |
| 현재 실행 씬 설정 여부 | 없음 — `project.godot`의 `[application]` 섹션에 `run/main_scene` 키가 없음 |
| 현재 구현된 기능 | 없음 (Stage 0 문서 작업 및 T010 설정 확인만 완료, 실제 파일 생성·구현은 아직 없음) |
| 아직 구현되지 않은 기능 | MVP-1 전체 (섹션 3 완료 정의 참고) |

## 3. 완료 정의

`docs/GAME_DESIGN.md` 섹션 28 기준, MVP-1 최소 완료 조건:

- 플레이어가 이동 가능
- 카메라 조작 가능
- 점프와 달리기 가능
- 일반 택배 1개가 물리적으로 존재
- 택배를 잡고 유지 가능
- 택배를 놓을 수 있음
- 택배를 던질 수 있음
- 평지, 계단, 경사로를 통과 가능
- 배송 구역이 택배를 감지
- 배송 성공 메시지 표시
- 재시작 가능
- 치명적인 오류 없이 전체 루프 반복 가능

MVP 제외 항목(`docs/GAME_DESIGN.md` 섹션 27, `CLAUDE.md` 섹션 6)은 완료 조건에 넣지 않는다.

## 4. 작업 실행 규칙

각 작업을 시작할 때 다음 형식으로 먼저 보고한다.

```md
### 구현 전 보고

- 작업 목표
- 현재 상태
- 생성 파일
- 수정 파일
- 노드 구조
- Input Map 변경
- 구현 방식
- 예상 영향
- 위험 요소
- 테스트 방법
```

사용자의 구현 승인 전에는 파일을 수정하지 않는다.

각 작업 완료 후에는 다음 형식으로 보고한다.

```md
### 구현 후 보고

- 완료한 내용
- 생성 파일
- 수정 파일
- 에디터 수동 작업
- 테스트 방법
- 테스트 결과
- 남은 문제
- 다음 작업 진행 가능 여부
```

## 5. Stage 0 — 문서 및 프로젝트 준비

### T000 — Godot 프로젝트 생성 확인

- 상태: `[x]` `[DONE]`
- 목적: Godot 프로젝트가 정상적으로 생성되어 있는지 확인
- 선행 작업: 없음
- 작업 범위: `project.godot` 존재 확인, 에디터로 열리는지 확인, 버전 확인
- 제외 범위: 설정 변경
- 생성 파일: 없음
- 수정 파일: 없음
- 에디터 수동 작업: 없음
- 완료 조건: `project.godot` 존재 / Godot에서 프로젝트가 열림 / 프로젝트 버전 확인 가능
- 테스트 방법: `.godot/editor/project_metadata.cfg`의 `executable_path`로 확인 완료 (`Godot_v4.7.1-stable_win64.exe`)
- 예상 위험: 없음

### T001 — `GAME_DESIGN.md` 확정

- 상태: `[x]` `[DONE]`
- 목적: 게임 기획 확정 문서 완성
- 선행 작업: T000
- 작업 범위: MVP-1 범위, 제외 기능, Phase 구조, 미확정 사항 문서화
- 제외 범위: 코드 구현
- 생성 파일: `docs/GAME_DESIGN.md` (이미 존재)
- 수정 파일: 없음
- 에디터 수동 작업: 없음
- 완료 조건: MVP-1 범위 명시(섹션 27) / 제외 기능 명시(섹션 27) / Phase 구조 명시(섹션 29) / 미확정 사항 분리(섹션 33) — 모두 확인됨
- 테스트 방법: 문서 내용 검토
- 예상 위험: 없음

### T002 — `CLAUDE.md` 작성

- 상태: `[x]` `[DONE]`
- 목적: Claude Code 작업 규칙 정의
- 선행 작업: T001
- 작업 범위: 작업 규칙, MVP 금지 범위, 문서 우선순위 정의
- 제외 범위: 코드 구현
- 생성 파일: `CLAUDE.md` (프로젝트 루트, 이미 존재)
- 수정 파일: 없음
- 에디터 수동 작업: 없음
- 완료 조건: Claude 작업 규칙 명시(섹션 2~5) / MVP 금지 범위 명시(섹션 6) / 문서 우선순위 명시(섹션 9) — 모두 확인됨
- 테스트 방법: 문서 내용 검토
- 예상 위험: 없음

### T003 — `ARCHITECTURE.md` 작성 및 승인

- 상태: `[x]` `[DONE]`
- 목적: MVP-1 최소 기술 구조 확정
- 선행 작업: T002
- 작업 범위: 씬 책임, 플레이어/택배/배송 구조, 잡기 방식, Input Map, 충돌 레이어, 구현 순서 정의
- 제외 범위: 코드/씬 구현
- 생성 파일: `docs/ARCHITECTURE.md` (이미 존재)
- 수정 파일: 없음
- 에디터 수동 작업: 없음
- 완료 조건: 씬 책임 정의(섹션 4) / 플레이어·택배·배송 구조 정의(섹션 6, 9, 12) / 잡기 방식 정의(섹션 10) / Input Map 정의(섹션 15) / 충돌 레이어 정의(섹션 16) / 구현 순서 정의(섹션 21) — 모두 확인됨
- 테스트 방법: 문서 내용 검토
- 예상 위험: 없음
- 비고: 사용자가 "조건부 승인"을 명시하며 5개 항목(HoldPoint/InteractShapeCast 위치, 재시작 책임 소재, 잡기 조작 확정, 물리 추종 안전 조건, 마우스 캡처 복귀) 수정을 요청했고, 해당 수정이 모두 반영됨. 추가 이견이 있으면 이 항목을 `[REVIEW]`로 되돌린다.

### T004 — `TASKS.md` 작성

- 상태: `[x]` `[DONE]`
- 목적: MVP-1 실행 체크리스트 작성
- 선행 작업: T003
- 작업 범위: 본 문서 작성
- 제외 범위: 코드/씬 구현
- 생성 파일: `docs/TASKS.md` (본 문서)
- 수정 파일: 없음
- 에디터 수동 작업: 없음
- 완료 조건: 본 문서 작성 완료
- 테스트 방법: 문서 내용 검토
- 예상 위험: 없음

## 6. Stage 1 — 프로젝트 기초 설정

### T010 — 프로젝트 설정 상태 확인

- 상태: `[x]` `[DONE]`
- 목적: 실제 변경 전 현재 `project.godot` 설정을 검증
- 선행 작업: T004
- 작업 범위: 현재 `project.godot` 설정 확인, 3D 렌더러/물리 엔진/실행 환경 확인, 변경이 필요한 항목만 보고
- 제외 범위: 실제 설정 변경
- 생성 파일: 없음
- 수정 파일: 없음 (확인만, 변경하지 않음)
- 에디터 수동 작업: 없음
- 완료 조건: 현재 설정 보고 / 변경 필요 여부 판단 / 불필요한 설정 변경 없음 — 모두 확인됨
- 테스트 방법: 보고 내용과 `project.godot` 실제 값 대조
- 예상 위험: 없음 (읽기 전용 작업)
- 완료 근거: `docs/ARCHITECTURE.md`, `docs/TASKS.md` 작성 과정에서 `project.godot` 및 에디터 메타데이터 검증이 이미 완료됨
  - Godot 4.7.1 확인
  - Forward+ 확인
  - D3D12 확인
  - Jolt Physics 확인
  - Input Map 없음 확인
  - `run/main_scene` 없음 확인
  - 현재 필수 설정 변경이 필요하지 않음을 확인

### T011 — MVP 폴더 구조 생성

- 상태: `[x]` `[DONE]`
- 목적: MVP-1에 필요한 최소 폴더만 생성
- 선행 작업: T010
- 작업 범위: `scenes/player/`, `scenes/package/`, `scenes/delivery/`, `scenes/level/`, `scenes/ui/` 생성
- 제외 범위: `assets/`, `tests/`, `scripts/` 생성, 코드/씬 파일 생성 (`docs/ARCHITECTURE.md` 섹션 3.2 기준)
- 생성 파일: 폴더만 (파일 없음)
- 수정 파일: 없음
- 에디터 수동 작업: Godot FileSystem 독에서 폴더 생성 (또는 OS 탐색기 생성 후 Godot에서 재스캔)
- 완료 조건: 필요한 폴더만 생성 / 코드와 씬은 아직 생성하지 않음 — 모두 확인됨
- 테스트 방법: Godot FileSystem 독에서 5개 폴더 확인
- 예상 위험: 낮음
- 완료 근거: `hell-delivery/scenes/` 하위에 `player/`, `package/`, `delivery/`, `level/`, `ui/` 5개 폴더 생성 완료. 생성 전 사전 확인 결과 5개 폴더 모두 신규 생성(기존에 존재하지 않았음). 폴더 내부에는 어떤 파일도 생성하지 않았으며(`.tscn`/`.gd`/플레이스홀더 없음), `assets/`/`scripts/`/`tests/`/`addons/`도 생성하지 않음. `project.godot`, Input Map, Main Scene, 기존 문서는 변경하지 않음. Git commit/push/branch 생성 없음.

### T012 — Input Map 설정

- 상태: `[x]` `[DONE]`
- 목적: MVP-1에 필요한 Input Map 액션 정의
- 선행 작업: T011
- 작업 범위: `move_forward`, `move_backward`, `move_left`, `move_right`, `jump`, `sprint`, `interact`, `throw_package`, `restart`, `release_mouse` 10개 액션 추가, 기본 키 바인딩(W/S/A/D, Space, Shift, E, 마우스 왼쪽 버튼, R, Esc — `docs/ARCHITECTURE.md` 섹션 15 기준)
- 제외 범위: 차량 및 문 관련 입력, 씬/스크립트 생성
- 생성 파일: 없음
- 수정 파일: `project.godot` (`[input]` 섹션 추가)
- 에디터 수동 작업: 프로젝트 설정 → Input Map 탭에서 액션 10개 추가 및 키 바인딩 (`project.godot`을 텍스트로 직접 수정하지 않음 — `CLAUDE.md` 섹션 5)
- 완료 조건: 모든 액션이 `project.godot`에 존재 / 차량 및 문 입력 없음 / 중복 키와 잘못된 입력 없음 — 모두 확인됨
- 테스트 방법: 프로젝트 설정 Input Map 탭에서 10개 액션과 키 확인
- 예상 위험: 낮음, 다른 액션과의 키 중복 가능성
- 완료 근거: `hell-delivery/project.godot`에 `[input]` 섹션을 추가해 `move_forward`(W), `move_backward`(S), `move_left`(A), `move_right`(D), `jump`(Space), `sprint`(Shift), `interact`(E), `throw_package`(마우스 왼쪽 버튼), `restart`(R), `release_mouse`(Esc) 10개 액션을 물리 키 기준(`physical_keycode`)으로 등록. 수정 전 `[input]` 섹션이 존재하지 않아 기존 액션과의 충돌·중복 없음, 엔진 내장 `ui_cancel` 등은 변경하지 않음. GUI 접근이 불가능한 CLI 환경이라 승인된 대로 `project.godot`을 직접 편집했으며, 설치된 `Godot_v4.7.1-stable_win64.exe`를 `--headless --quit`으로 실행해 실제 파싱 검증 — 출력은 Main Scene 미설정에 대한 예상된 알림(`Error: Can't run project: no main scene defined in the project.`) 한 줄뿐이었고 `[input]` 섹션 관련 파싱 오류는 없었음(종료 코드 0). 차량/문 관련 액션과 게임패드 입력은 추가하지 않음. 씬/스크립트/Main Scene/`GAME_DESIGN.md`/`ARCHITECTURE.md` 변경 없음, Git commit/push/branch 없음.

## 7. Stage 2 — 프로토타입 레벨

### T020 — `PrototypeLevel.tscn` 빈 실행 씬 생성

- 상태: `[x]` `[DONE]`
- 목적: MVP 실행 진입점 생성
- 선행 작업: T012
- 작업 범위: 루트 `Node3D`, 최소 환경 노드 구조 생성, 프로젝트 실행 씬으로 지정 (`docs/ARCHITECTURE.md` 섹션 5)
- 제외 범위: 바닥, 계단, 경사로 생성, 임시 `Camera3D` 생성
- 생성 파일: `scenes/level/PrototypeLevel.tscn` (예정)
- 수정 파일: `project.godot` (`run/main_scene` 지정)
- 에디터 수동 작업: 씬 생성 및 노드 배치, 프로젝트 설정 → Run → Main Scene을 `PrototypeLevel.tscn`으로 지정
- 완료 조건:
  - `PrototypeLevel.tscn`이 오류 없이 로드되고 실행됨
  - `run/main_scene`이 올바르게 지정됨
  - `Camera3D` 미존재로 인한 시각 확인은 T030 이후 수행 (이 시점에는 요구하지 않음)
  — 모두 확인됨
- 테스트 방법: 프로젝트 실행 후 Godot 출력 창에 오류가 없는지 확인 (`Camera3D`가 없어 게임 화면이 비어 있거나 검게 나올 수 있으며, 이는 정상)
- 예상 위험: 낮음
- 완료 근거: `hell-delivery/scenes/level/PrototypeLevel.tscn`을 루트 `PrototypeLevel(Node3D)` + 자식 `Environment`/`Gameplay`/`UI`(모두 `Node3D`) 구조로 생성(Player/Package/DeliveryZone/Camera/DirectionalLight3D/WorldEnvironment/StaticBody3D/MeshInstance3D/CollisionShape3D는 아직 생성하지 않음, 사용자 승인 조건대로). `project.godot`의 `[application]` 섹션에 `run/main_scene="res://scenes/level/PrototypeLevel.tscn"` 추가. `Godot_v4.7.1-stable_win64.exe --headless --path hell-delivery --quit`으로 실행해 검증 — 엔진 버전 배너 외 오류 없이 종료 코드 0으로 정상 종료됨 (이전 T012 검증 때 나왔던 "no main scene defined" 알림도 더 이상 발생하지 않아 Main Scene이 정상 인식됨을 확인).

### T021 — 기본 바닥 및 조명 추가

- 상태: `[x]` `[DONE]`
- 목적: 플레이어 이동 테스트용 평지와 최소 조명 제공
- 선행 작업: T020
- 작업 범위: `StaticBody3D` 바닥, 최소 조명(예: `DirectionalLight3D`) 추가
- 제외 범위: 계단, 경사로
- 생성 파일: 없음 (`PrototypeLevel.tscn` 내부에 노드 추가)
- 수정 파일: `scenes/level/PrototypeLevel.tscn`
- 에디터 수동 작업: 바닥/조명 노드 배치
- 완료 조건: `StaticBody3D` 바닥과 충돌 존재 / 에디터 3D 뷰포트에서 바닥과 조명 배치 확인 가능 / 실행 오류 없음 — 모두 확인됨
- 테스트 방법:
  - Godot 에디터 3D 뷰포트에서 바닥과 조명 배치를 확인
  - 씬 실행 시 오류가 없는지 확인
  - 실제 게임 카메라 화면 확인은 T030 이후 수행 (이 시점에는 요구하지 않음)
- 예상 위험: 낮음
- 완료 근거: `Environment` 노드 하위에 `Floor`(`StaticBody3D` + `CollisionShape3D`[`BoxShape3D` 20×1×20] + `MeshInstance3D`[`BoxMesh` 20×1×20]), `DirectionalLight3D`(엔진 기본값), `WorldEnvironment`(`Environment` 리소스, `background_mode=Sky` + 기본 `ProceduralSkyMaterial`만 지정, Fog/Bloom/SSAO/Glow 등 미설정) 추가. Player/Camera/계단/경사로 등은 생성하지 않았고 Collision Layer·Input Map은 변경하지 않음(엔진 기본 레이어 1 그대로 사용). `Godot_v4.7.1-stable_win64.exe --headless --path hell-delivery --quit`으로 검증 — 엔진 버전 배너 외 오류 없이 종료 코드 0으로 정상 종료됨.

### T022 — 계단 추가

- 상태: `[x]` `[DONE]`
- 목적: 플레이어와 택배 통과 테스트용 단순 계단 생성
- 선행 작업: T034 (변경된 구현 순서: Player 구현 완료 후 계단/경사로 튜닝 — 실제로는 T021 이후 먼저 구현됨)
- 작업 범위: 충돌이 있는 단순 계단 지오메트리 추가
- 제외 범위: 복잡한 메시, 경사로
- 생성 파일: 없음
- 수정 파일: `scenes/level/PrototypeLevel.tscn`
- 에디터 수동 작업: 계단용 `StaticBody3D`/`CollisionShape3D` 배치
- 완료 조건: 충돌이 있는 단순 계단 / 지나치게 복잡한 메시 사용 금지 / 플레이스홀더 지오메트리 사용 — 모두 확인됨
- 테스트 방법: 임시 오브젝트로 계단 충돌 확인 (Player 구현 전이므로 시각적/충돌 확인 위주)
- 예상 위험: 계단 단차가 이후 `CharacterBody3D` 이동에 걸릴 가능성 (T045에서 검증)
- 완료 근거: `Environment/Stairs`(`Node3D`) 하위에 `Step1`~`Step5`(각각 `StaticBody3D` + `CollisionShape3D`[공유 `BoxShape3D` 1×0.4×4] + `MeshInstance3D`[공유 `BoxMesh` 1×0.4×4]) 5단을 X방향 1m 간격, Y방향 0.4m씩 상승하도록 배치. `Floor`(X -10~10)와 겹치지 않도록 X=11부터 시작(1m 간격). Player/Camera/Package/DeliveryZone/경사로/UI/Navigation은 생성하지 않았고 단일 Mesh나 외부 모델도 사용하지 않음. `Godot_v4.7.1-stable_win64.exe --headless --path hell-delivery --quit`으로 검증 — 엔진 버전 배너 외 오류 없이 종료 코드 0으로 정상 종료됨.

### T023 — 경사로 추가

- 상태: `[ ]` `[BLOCKED]` — 선행 작업 T022는 이미 완료됨. 변경된 구현 순서상 T030~T034(Player 구현) 완료 후 진행
- 목적: 플레이어와 택배 운반 테스트용 경사로 생성
- 선행 작업: T022
- 작업 범위: 충돌이 있는 단순 경사로 지오메트리 추가
- 제외 범위: 계단과의 상호 간섭 요소
- 생성 파일: 없음
- 수정 파일: `scenes/level/PrototypeLevel.tscn`
- 에디터 수동 작업: 경사로용 `StaticBody3D`/`CollisionShape3D` 배치
- 완료 조건: 충돌이 있는 단순 경사로 / 계단과 서로 간섭하지 않음
- 테스트 방법: 시각적/충돌 확인
- 예상 위험: 낮음

## 8. Stage 3 — 플레이어 기본 구현

### T030 — `Player.tscn` 기본 노드 구조 생성

- 상태: `[x]` `[DONE]`
- 목적: 승인된 `docs/ARCHITECTURE.md` 노드 구조로 `Player.tscn` 뼈대 생성
- 선행 작업: T021 (변경된 구현 순서: 계단/경사로보다 Player를 먼저 구현)
- 작업 범위:
  ```text
  Player (CharacterBody3D)
  ├─ CollisionShape3D
  ├─ MeshInstance3D
  └─ CameraPivot
     ├─ HoldPoint
     ├─ InteractShapeCast
     └─ SpringArm3D
        └─ Camera3D
  ```
  충돌 형태와 플레이스홀더 모델 포함 (`docs/ARCHITECTURE.md` 섹션 4.1)
- 제외 범위: 이동 코드 (단, `Player.gd`는 이번 지시로 `extends CharacterBody3D` 한 줄짜리 클래스 선언만 생성 — 최신 사용자 지시에 따라 원래의 "빈 스크립트를 미리 만들지 않음" 제외 범위를 이번 작업에 한해 override함)
- 생성 파일: `scenes/player/Player.tscn`, `scenes/player/Player.gd`
- 수정 파일: `scenes/level/PrototypeLevel.tscn` (Player 인스턴스 배치)
- 에디터 수동 작업: 노드 생성/배치, 충돌 레이어 설정(`docs/ARCHITECTURE.md` 섹션 16)
- 완료 조건: 노드 구조 생성 / 충돌과 플레이스홀더 모델 존재 / 씬 단독 실행 또는 레벨 배치 시 오류 없음 — 모두 확인됨
- 테스트 방법: 레벨에 배치 후 실행 오류 없는지 확인
- 예상 위험: 낮음
- 완료 근거: `Player.tscn`을 `CharacterBody3D` 루트 + `CollisionShape3D`(`CapsuleShape3D` 기본값) + `MeshInstance3D`(`CapsuleMesh` 기본값) + `CameraPivot`(`Node3D`) 하위 `HoldPoint`(`Marker3D`), `InteractShapeCast`(`ShapeCast3D`), `SpringArm3D`→`Camera3D` 구조로 생성. `Player.gd`는 `extends CharacterBody3D` 한 줄만 작성(이동 코드 없음), export 변수 없음. `PrototypeLevel.tscn`의 `Gameplay` 아래에 인스턴스 배치. **InteractShapeCast는 shape 미지정 상태이므로 T041까지 disabled 처리** — `shape`가 `null`인 채로 `enabled=true`이면 물리 프레임마다 "Null reference to shape" 오류가 반복 발생하는 것을 헤드리스 검증 중 확인했고, 임시 placeholder shape를 넣는 대신 `enabled=false`로 두어 오류를 제거함(실제 shape 종류/크기/target_position/collision mask/감지 거리는 T041에서 확정, 노드 자체는 삭제하지 않음). `Godot_v4.7.1-stable_win64.exe --headless --path hell-delivery --quit`으로 재검증 — 엔진 버전 배너 외 오류 없이 종료 코드 0으로 정상 종료됨. `docs/ARCHITECTURE.md`는 수정하지 않음.

### T031 — `Player.gd` 이동 구현

- 상태: `[ ]` `[READY]`
- 목적: 기본 이동 구현
- 선행 작업: T030
- 작업 범위: WASD 이동, 카메라 수평 방향 기준 이동, 중력, 가감속, `move_and_slide()` (`docs/ARCHITECTURE.md` 섹션 7)
- 제외 범위: 점프, 달리기, 카메라 마우스 회전, 상호작용
- 생성 파일: `scenes/player/Player.gd` (예정, 이 작업에서 최초 생성)
- 수정 파일: `scenes/player/Player.tscn` (스크립트 부착)
- 에디터 수동 작업: `Player` 루트 노드에 새 스크립트(`Player.gd`) 생성 및 부착, export 변수는 Inspector에서 조정 가능하도록 노출
- 완료 조건: 평지에서 이동 가능 / 공중에서 중력 적용 / 오류 없음
- 테스트 방법: T021 바닥 위에서 WASD 이동 및 낙하 확인
- 예상 위험: 낮음

### T032 — 점프 구현

- 상태: `[ ]` `[BLOCKED]` — T031 완료 필요
- 목적: 점프 기능 추가
- 선행 작업: T031
- 작업 범위: 바닥에 있을 때만 점프, `jump_speed` export 변수
- 제외 범위: 달리기, 카메라, 상호작용
- 생성 파일: 없음
- 수정 파일: `scenes/player/Player.gd`
- 에디터 수동 작업: 없음
- 완료 조건: 공중 연속 점프 불가 / 정상 착지 / 계단이나 경사로에서 치명적 오류 없음
- 테스트 방법: Space로 점프 후 착지 확인, 공중에서 재점프 시도
- 예상 위험: 낮음

### T033 — 달리기 구현

- 상태: `[ ]` `[BLOCKED]` — T032 완료 필요
- 목적: 달리기 기능 추가
- 선행 작업: T032
- 작업 범위: `sprint` 입력 동안 속도 증가, `walk_speed`/`sprint_speed` export 변수
- 제외 범위: 카메라, 상호작용
- 생성 파일: 없음
- 수정 파일: `scenes/player/Player.gd`
- 에디터 수동 작업: 없음
- 완료 조건: 걷기와 달리기 속도 구분 / 입력 해제 시 걷기 속도로 복귀
- 테스트 방법: Shift 입력/해제로 속도 변화 확인
- 예상 위험: 낮음

### T034 — 카메라 회전 구현

- 상태: `[ ]` `[BLOCKED]` — T033 완료 필요
- 목적: 3인칭 카메라 조작 구현
- 선행 작업: T033
- 작업 범위: 마우스 수평/수직 회전, 수직 각도 제한, 마우스 캡처, Esc로 해제, 화면 클릭 또는 정의된 입력으로 재캡처, `SpringArm3D` 벽 충돌 확인 (`docs/ARCHITECTURE.md` 섹션 8)
- 제외 범위: 상호작용
- 생성 파일: 없음
- 수정 파일: `scenes/player/Player.gd`
- 에디터 수동 작업: 없음
- 완료 조건: 카메라 조작 가능 / 카메라가 뒤집히지 않음 / 마우스 캡처 복귀 가능 / 별도 Camera Manager 없음
- 테스트 방법: 마우스로 회전, `release_mouse`로 해제 후 클릭 재캡처, 벽 근처에서 카메라 충돌 확인
- 예상 위험: 수직 회전 제한 값에 따라 조작감이 불편해질 수 있음 (export 변수로 튜닝)

## 9. Stage 4 — 택배 물리 및 상호작용

### T040 — `Package.tscn` 생성

- 상태: `[ ]` `[BLOCKED]` — T023 완료 필요
- 목적: 택배 물리 오브젝트 생성
- 선행 작업: T023 (변경된 구현 순서: T022·T023이 T034 이후로 이동함에 따라 갱신)
- 작업 범위: `RigidBody3D`, `CollisionShape3D`, `MeshInstance3D`, `package` 그룹 추가, Package 충돌 레이어/마스크 설정 (`docs/ARCHITECTURE.md` 섹션 9, 16)
- 제외 범위: 잡기 코드, `Package.gd` 생성 (스크립트는 실제 Package 로직이 필요한 T042에서 생성 — 빈 스크립트를 미리 만들지 않음)
- 생성 파일: `scenes/package/Package.tscn` (예정)
- 수정 파일: `scenes/level/PrototypeLevel.tscn` (Package 인스턴스 배치)
- 에디터 수동 작업: 노드 생성/배치, 그룹/레이어 설정
- 완료 조건: 택배가 중력의 영향을 받음 / 바닥과 충돌 / 플레이어와 충돌 / 오류 없음
- 테스트 방법: 레벨 실행 후 낙하 및 Player와의 충돌 확인
- 예상 위험: 낮음

### T041 — `ShapeCast3D` 상호작용 감지 구현

- 상태: `[ ]` `[BLOCKED]` — T040 완료 필요
- 목적: `InteractShapeCast`로 잡기 대상 감지
- 선행 작업: T040
- 작업 범위: Package 레이어만 감지, `package` 그룹 확인, 감지 대상이 없을 때 무동작, 디버그 출력 또는 최소 확인 방식 제공 (`docs/ARCHITECTURE.md` 섹션 11)
- 제외 범위: 잡기, 놓기, 던지기
- 생성 파일: 없음
- 수정 파일: `scenes/player/Player.gd`
- 에디터 수동 작업: 없음
- 완료 조건: 플레이어 정면의 Package만 감지 / World와 Player는 감지하지 않음 / 카메라 방향과 감지 방향이 일치
- 테스트 방법: Package를 정면/측면/차단물 뒤에 두고 감지 여부 로그로 확인
- 예상 위험: 레이어/마스크 설정 오류로 잘못된 대상 감지 가능

### T042 — 잡기·유지·놓기 구현

- 상태: `[ ]` `[BLOCKED]` — T041 완료 필요
- 목적: 홀드 방식에서는 잡기와 놓기가 하나의 입력 생명주기이므로, 잡기·유지·놓기와 물리 추종을 하나의 작업으로 구현
- 선행 작업: T041
- 작업 범위:
  - `E`를 누르면 잡기 시도
  - `E`를 누르는 동안 잡기 유지
  - `E`를 놓으면 놓기
  - `Package`의 `HoldPoint` 물리 추종
  - 최대 추종 속도 제한
  - 추종 반응 강도 또는 가속도 제한
  - 최대 허용 거리
  - 거리 초과 시 자동 놓기
  - 벽에 막혔을 때 속도 과증가 방지
  - 놓을 때 Player와 Package의 참조 정리
  - 놓은 Package 재잡기 가능
  (`docs/ARCHITECTURE.md` 섹션 10.2~10.4)
- 제외 범위: 던지기, 다인 운반, 임시 해제 입력이나 임시 테스트 코드
- 생성 파일: `scenes/package/Package.gd` (예정, 이 작업에서 최초 생성)
- 수정 파일: `scenes/package/Package.tscn` (스크립트 부착), `scenes/player/Player.gd` (잡기 요청 로직 추가)
- 에디터 수동 작업: `Package` 루트 노드에 새 스크립트(`Package.gd`) 생성 및 부착
- 완료 조건:
  - `E`를 누르면 잡기 시도, 누르고 있는 동안 유지, 떼면 자연스럽게 놓임
  - 잡은 동안 `Package`가 `HoldPoint`를 안정적으로 추종
  - 안전 조건(최대 추종 속도, 가속도 제한, 최대 허용 거리, 자동 놓기, 벽 충돌 시 속도 제한) 동작
  - 놓은 뒤 재잡기 가능
  - Player/Package에 잘못된 참조가 남지 않음
- 테스트 방법: `E`를 눌러 Package를 잡고 이동, 누르고 있는 동안 유지되는지 확인, `E`를 떼서 자연스럽게 놓이고 재잡기가 되는지 확인, 장애물에 막히거나 멀어질 때 안전 조건이 동작하는지 확인
- 예상 위험: 물리 추종 튜닝 값에 따라 진동/떨림 발생 가능 (섹션 10.4 안전 조건으로 완화)

### T044 — 던지기 구현

- 상태: `[ ]` `[BLOCKED]` — T042 완료 필요
- 목적: 잡은 상태에서 던지기 기능 구현
- 선행 작업: T042
- 작업 범위: 잡은 상태에서 좌클릭(`throw_package`), 카메라 전방 방향으로 임펄스 적용, 던지는 즉시 잡기 상태 해제, 던지기 힘 export 변수
- 제외 범위: 없음
- 생성 파일: 없음
- 수정 파일: `scenes/package/Package.gd`, `scenes/player/Player.gd`
- 에디터 수동 작업: 없음
- 완료 조건: 잡지 않은 상태에서는 무동작 / 던진 뒤 다시 잡기 가능 / 과도한 속도나 오류 없음
- 테스트 방법: 잡은 상태에서 좌클릭으로 던지고 재잡기 시도
- 예상 위험: 낮음

### T045 — 계단 및 경사로 운반 테스트

- 상태: `[ ]` `[BLOCKED]` — T044 완료 필요
- 목적: 기능 통합 검증 (신규 기능 추가 아님)
- 선행 작업: T044
- 작업 범위: 평지 운반 / 계단 상승·하강 / 경사로 상승·하강 / 벽에 택배가 걸렸을 때 물리 안정성 / 택배가 멀어졌을 때 자동 놓기 / 카메라 상하 회전 시 `HoldPoint` 동작 확인
- 제외 범위: 새로운 시스템 추가
- 생성 파일: 없음
- 수정 파일: 없음 (필요시 T042의 export 값만 조정)
- 에디터 수동 작업: 없음
- 완료 조건: 치명적인 진동이나 폭발적 속도 없음 / 조작 불가능한 문제가 없거나 문제 목록이 기록됨 / 필요한 튜닝 값이 보고됨
- 테스트 방법: 위 작업 범위 항목을 순서대로 수동 플레이
- 예상 위험: 계단/경사로 형상에 따라 추가 튜닝 필요 가능

## 10. Stage 5 — 배송 및 완료 흐름

### T050 — `DeliveryZone.tscn` 생성

- 상태: `[ ]` `[BLOCKED]` — T045 완료 필요
- 목적: 배송 구역 오브젝트 생성
- 선행 작업: T045
- 작업 범위: `Area3D`, `CollisionShape3D`, 확인용 Mesh, DeliveryZone 충돌 레이어/마스크 설정 (`docs/ARCHITECTURE.md` 섹션 12, 16)
- 제외 범위: 성공 UI
- 생성 파일: `scenes/delivery/DeliveryZone.tscn` (예정), `scenes/delivery/DeliveryZone.gd` (예정)
- 수정 파일: `scenes/level/PrototypeLevel.tscn` (DeliveryZone 인스턴스 배치)
- 에디터 수동 작업: 노드 생성/배치, 레이어 설정
- 완료 조건: Package만 감지 / Player와 World는 무시
- 테스트 방법: Player/Package가 각각 진입할 때 감지 로그로 구분 확인
- 예상 위험: 낮음

### T051 — 배송 성공 판정 구현

- 상태: `[ ]` `[BLOCKED]` — T050 완료 필요
- 목적: 배송 성공 판정 로직 구현
- 선행 작업: T050
- 작업 범위: `package` 그룹 확인, 최초 1회 성공, `is_delivered` 중복 방지, `package_delivered` 시그널 발생 (`docs/ARCHITECTURE.md` 섹션 12)
- 제외 범위: UI 표시
- 생성 파일: 없음
- 수정 파일: `scenes/delivery/DeliveryZone.gd`
- 에디터 수동 작업: 없음
- 완료 조건: 잘못된 물체는 무시 / Package 진입 시 한 번만 시그널 발생 / UI 로직 포함 금지
- 테스트 방법: Package를 여러 번 넣었다 빼며 시그널 발생 횟수 확인
- 예상 위험: `Area3D` 겹침으로 인한 중복 호출 가능성 (`is_delivered` 플래그로 방지)

### T052 — `Hud.tscn` 생성

- 상태: `[ ]` `[BLOCKED]` — T051 완료 필요
- 목적: MVP UI 생성
- 선행 작업: T051
- 작업 범위: 목표 안내, 성공 메시지, 재시작 안내 레이블, 시작 시 성공/재시작 안내 숨김 (`docs/ARCHITECTURE.md` 섹션 4.5, 13)
- 제외 범위: 배송 판정, 재시작 로직
- 생성 파일: `scenes/ui/Hud.tscn` (예정), `scenes/ui/Hud.gd` (예정)
- 수정 파일: `scenes/level/PrototypeLevel.tscn` (Hud 인스턴스 배치)
- 에디터 수동 작업: `CanvasLayer`/`Label` 노드 생성 및 배치
- 완료 조건: 세 요소(목표/성공/재시작 안내) 존재 / 시작 시 성공·재시작 안내 숨김 상태
- 테스트 방법: 씬 실행 시 목표 안내만 보이는지 확인
- 예상 위험: 낮음

### T053 — 배송 성공과 HUD 연결

- 상태: `[ ]` `[BLOCKED]` — T052 완료 필요
- 목적: `DeliveryZone` 성공 신호를 `Hud`에 연결
- 선행 작업: T052
- 작업 범위: `PrototypeLevel.gd`가 `DeliveryZone`의 `package_delivered` 시그널 수신, `Hud.show_success()` 호출, 책임 관계가 `docs/ARCHITECTURE.md`와 일치 (섹션 12, 13, 17)
- 제외 범위: 배송 판정 로직 변경, 재시작 로직
- 생성 파일: `scenes/level/PrototypeLevel.gd` (예정, 아직 없다면 이 시점에 생성)
- 수정 파일: `scenes/level/PrototypeLevel.tscn`, `scenes/level/PrototypeLevel.gd`
- 에디터 수동 작업: 시그널 연결(에디터 또는 코드에서 `connect()`)
- 완료 조건: 배송 성공 시 메시지 표시 / 중복 호출 문제 없음 / UI가 직접 배송 상태를 검사하지 않음
- 테스트 방법: Package를 DeliveryZone에 넣고 성공 메시지 표시 및 중복 여부 확인
- 예상 위험: 낮음

### T054 — 재시작 구현

- 상태: `[ ]` `[BLOCKED]` — T053 완료 필요
- 목적: `restart` 입력으로 씬 재로드 구현
- 선행 작업: T053
- 작업 범위: `PrototypeLevel.gd`가 `restart` 입력 처리, `get_tree().reload_current_scene()` 호출, Player가 재시작 입력을 처리하지 않음 (`docs/ARCHITECTURE.md` 섹션 12, 17)
- 제외 범위: 저장/영속 상태 처리 (MVP-1에는 없음)
- 생성 파일: 없음
- 수정 파일: `scenes/level/PrototypeLevel.gd`
- 에디터 수동 작업: 없음
- 완료 조건: `R` 입력 시 전체 레벨 초기화 / 성공 전후 모두 재시작 가능 / Package, Player, DeliveryZone, UI 상태 초기화
- 테스트 방법: 성공 전/후 각각 `R` 입력 후 초기 상태 확인
- 예상 위험: 낮음

## 11. Stage 6 — 통합 테스트와 MVP 완료

### T060 — 전체 코어 루프 통합 테스트

- 상태: `[ ]` `[BLOCKED]` — T054 완료 필요
- 목적: MVP-1 전체 흐름 연속 검증
- 선행 작업: T054
- 작업 범위:
  ```text
  실행
  → 이동
  → 택배 접근
  → 잡기
  → 운반
  → 계단 또는 경사로 통과
  → 필요 시 놓기/재잡기
  → 던지기
  → 배송 구역 진입
  → 성공 메시지
  → 재시작
  ```
- 제외 범위: 신규 기능 추가
- 생성 파일: 없음
- 수정 파일: 없음 (검증 작업)
- 에디터 수동 작업: 없음
- 완료 조건: 전체 흐름을 연속 수행 가능 / Godot 디버거에 치명적 오류 없음 / 반복 재시작 가능
- 테스트 방법: 위 흐름을 처음부터 끝까지 수동 플레이, 3회 이상 반복
- 예상 위험: 개별 기능은 정상이어도 통합 시 예상치 못한 상호작용 문제 가능

### T061 — 기본 튜닝

- 상태: `[ ]` `[BLOCKED]` — T060 완료 필요
- 목적: export 변수 수치를 프로토타입 테스트로 확정
- 선행 작업: T060
- 작업 범위: 걷기 속도, 달리기 속도, 점프 속도, 가감속, 마우스 감도, 카메라 제한, 상호작용 거리, `HoldPoint` 거리, 추종 반응, 최대 추종 속도, 자동 놓기 거리, 던지기 힘
- 제외 범위: 신규 기능 추가
- 생성 파일: 없음
- 수정 파일: `scenes/player/Player.gd`, `scenes/package/Package.gd` (export 변수 값만 조정)
- 에디터 수동 작업: Inspector에서 값 조정
- 완료 조건: 각 값의 최종 프로토타입 수치 기록 / 조작 불가능하거나 지나치게 불안정한 값 제거 / 변경 이유 요약
- 테스트 방법: 각 값 조정 후 재생 테스트 반복
- 예상 위험: 낮음

### T062 — MVP-1 완료 검토

- 상태: `[ ]` `[BLOCKED]` — T061 완료 필요
- 목적: `GAME_DESIGN.md` MVP 완료 조건과 실제 결과 대조
- 선행 작업: T061
- 작업 범위: 섹션 3의 완료 조건을 하나씩 대조해 `충족` / `부분 충족` / `미충족` / `범위 제외`로 분류
- 제외 범위: `docs/GAME_DESIGN.md` Phase 5 이후 기능 구현 (TASKS.md 자체의 Stage 구분과 무관, `GAME_DESIGN.md` 섹션 29의 Phase 번호를 가리킴)
- 생성 파일: 없음
- 수정 파일: 없음 (보고서 형태로 제공, 필요 시 본 문서에 결과 반영)
- 에디터 수동 작업: 없음
- 완료 조건: 모든 필수 조건 검토 / 남은 버그 목록 작성 / MVP-1 완료 여부를 사용자가 판단할 수 있는 보고서 제공
- 테스트 방법: 섹션 3 체크리스트 전체 재확인
- 예상 위험: 없음

### T063 — 문서 동기화

- 상태: `[ ]` `[BLOCKED]` — T062 완료 필요 (조건부 작업, 구현 결과가 문서와 달라진 경우에만 수행)
- 목적: 구현 결과와 설계 문서의 불일치 해소
- 선행 작업: T062
- 작업 범위: `docs/ARCHITECTURE.md`, `docs/TASKS.md`, 필요한 경우 `docs/GAME_DESIGN.md` 검토 및 수정
- 제외 범위: 사용자 승인 없는 기획 변경
- 생성 파일: 없음
- 수정 파일: 불일치가 확인된 문서만
- 에디터 수동 작업: 없음
- 완료 조건: 구현과 문서 간 불일치 해소 (불일치가 없으면 이 작업은 생략 가능)
- 테스트 방법: 문서와 실제 씬/스크립트 대조
- 예상 위험: 없음

## 12. MVP-1 이후 금지 작업

MVP-1 완료 및 사용자의 명시적 승인 전에는 다음 작업을 생성하거나 수행하지 않는다.

- 온라인 멀티플레이
- 로컬 분할 화면
- 다인 운반
- 차량
- 문 조작
- 좁은 문 테스트
- 파손과 내구도
- 랜덤 이벤트
- 경제
- 저장
- NPC
- 여러 택배 종류
- Steamworks
- 정식 애니메이션 시스템
- 정식 사운드 시스템

## 13. 현재 다음 작업

- 작업 ID: `T031`
- 작업명: `Player.gd` 이동 구현
- 상태: `[READY]`
- 이유: T030(`Player.tscn` 기본 노드 구조 생성)이 완료되어 `[DONE]`으로 확정됨(헤드리스 실행으로 파싱 검증 완료, `InteractShapeCast`는 `enabled=false`로 오류 없이 대기 중). 기본 이동 코드를 작성하는 다음 순서임
- 이 작업에서 파일 수정: `scenes/player/Player.gd` (이동 코드 작성)

후속 작업(T032 이후)은 T031 완료 및 사용자 승인 전까지 `[READY]`로 지정하지 않는다. 변경된 순서: T030 → T031 → T032 → T033 → T034 → T022 → T023 → T040 (이하 기존 순서 유지).

## 작업별 작성 형식

각 작업은 아래 형식을 따른다.

```md
### T000 — 작업명

- 상태: `[READY]`, `[BLOCKED]`, `[REVIEW]`, `[DONE]` 중 하나
- 목적:
- 선행 작업:
- 작업 범위:
- 제외 범위:
- 생성 파일:
- 수정 파일:
- 에디터 수동 작업:
- 완료 조건:
- 테스트 방법:
- 예상 위험:
```

파일이 아직 존재하지 않으면 `예정`이라고 표시한다.
