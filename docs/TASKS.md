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
- 선행 작업: T034 (변경된 구현 순서: Player 구현 완료 후 계단/경사로 튜닝 — 실제로는 T021 이후 먼저 구현됨. 이미 `[DONE]`이므로 `[BLOCKED]`로 되돌리지 않음 — 재검증/튜닝은 T023 이후 별도 일정으로 진행)
- 작업 범위: 충돌이 있는 단순 계단 지오메트리 추가
- 제외 범위: 복잡한 메시, 경사로
- 생성 파일: 없음
- 수정 파일: `scenes/level/PrototypeLevel.tscn`
- 에디터 수동 작업: 계단용 `StaticBody3D`/`CollisionShape3D` 배치
- 완료 조건: 충돌이 있는 단순 계단 / 지나치게 복잡한 메시 사용 금지 / 플레이스홀더 지오메트리 사용 — 모두 확인됨
- 테스트 방법: 임시 오브젝트로 계단 충돌 확인 (Player 구현 전이므로 시각적/충돌 확인 위주)
- 예상 위험: 계단 단차가 이후 `CharacterBody3D` 이동에 걸릴 가능성 (T045에서 검증)
- 완료 근거(최초): `Environment/Stairs`(`Node3D`) 하위에 `Step1`~`Step5`(각각 `StaticBody3D` + `CollisionShape3D`[공유 `BoxShape3D` 1×0.4×4] + `MeshInstance3D`[공유 `BoxMesh` 1×0.4×4]) 5단을 X방향 1m 간격, Y방향 0.4m씩 상승하도록 배치. `Floor`(X -10~10)와 겹치지 않도록 X=11부터 시작(1m 간격). Player/Camera/Package/DeliveryZone/경사로/UI/Navigation은 생성하지 않았고 단일 Mesh나 외부 모델도 사용하지 않음. `Godot_v4.7.1-stable_win64.exe --headless --path hell-delivery --quit`으로 검증 — 엔진 버전 배너 외 오류 없이 종료 코드 0으로 정상 종료됨.
- 계단 형상 재작업(T062 재검토에서 "계단을 걸어서 오를 수 없음" 발견, 사용자 승인 후 T022 Reopen으로 진행): 원인은 두 가지였음을 헤드리스 실측으로 확인 — (1) 기존 단 높이 0.4m가 `CharacterBody3D`(기본 `CapsuleShape3D`, radius=0.5)가 점프 없이 넘을 수 있는 한계(단일 단 기준 실측 0.18m까지 성공, 0.19m부터 실패)를 크게 초과했음, (2) `Floor`(X 끝 10.0)와 `Stairs` 시작(X 11.0) 사이에 실제로는 바닥이 없는 1m 간격이 있어, 걷기 속도(4.0m/s)로 접근하면 그 틈에서 낙하하며 계단 앞면에 아래쪽에서 부딪혀 절대 오를 수 없었음(Sprint는 속도가 빨라 우연히 틈을 뛰어넘어 통과했던 것 — 애초에 걸려서 멈춘 게 아니라 빠지고 있었던 것). 해결: 기존 5단(각 0.4m)을 13단(각 높이 0.15m, 깊이 0.385m, 폭 4m 동일)으로 재구성해 전체 높이(1.95m, 기존 2.0m와 거의 동일)와 전체 길이(약 5.0m, 기존과 동일)를 유지, 계단 전체 위치를 X방향으로 1.05m 이동시켜 `Floor`와의 간격을 완전히 제거(0.05m 미세 중첩으로 이음매 문제 방지). 계단 끝에 낙하 없이 착지 가능하도록 `TopLanding`(`StaticBody3D`, 2m×0.3m×4m) 최소 발판 1개 추가. `Player.gd`/`Package.gd`는 전혀 수정하지 않음(step-up 로직, 이동 로직, CollisionShape, export 값 모두 미변경). 헤드리스 실측(모두 실제 `Player.gd`/`Package.gd` 코드로 확인, 점프 입력 없이): 걷기로 계단 상승/하강 성공, Sprint 상승/하강 성공, Package를 든 채 걷기로 상승/하강 성공(점프 없이), Sprint+Package 동시 통과 성공, 계단 중간에서 정지 후 방향 전환해 되돌아가기 성공, 계단 중간에서 Release(정착, 관통 없음) 후 재Grab 성공, 계단에서 위/아래 방향 Throw 모두 속도 폭발 없음, 계단→경사로 연속 통과 성공, 이후 DeliveryZone 배송·HUD 표시·Restart·재시작 후 재배달·재시작 후 계단 재통과 모두 정상. 오류 0, 반복 경고 0.
- 최종 승인(사용자 확인): 계단 형상 재작업 완료, Floor와 계단 사이 공백 제거, 단 높이를 실제 통과 가능한 수준으로 조정, 단 수 증가로 전체 높이 유지, 상단 착지 발판 추가, Player 코드 수정 없음, Package 코드 수정 없음(PrototypeLevel 계단 Geometry만 수정), 점프 없이 Player가 계단을 오를 수 있음, Sprint 통과 가능, Package를 든 상태로 점프 없이 통과 가능, Release/재Grab/Throw 정상, Delivery 및 Restart 회귀 테스트 정상, 오류 및 반복 경고 없음을 모두 확인해 완료 승인함.

### T023 — 경사로 추가

- 상태: `[x]` `[DONE]`
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
- 완료 근거: `Environment` 아래 `Ramp`(`StaticBody3D` + `CollisionShape3D`[`BoxShape3D` 4×0.5×4] + `MeshInstance3D`[대응 `BoxMesh`]) 1개 추가 — 약 18° 경사(`CharacterBody3D` 기본 `floor_max_angle` 45°보다 완만), 낮은 끝이 바닥 표면(y=0.5)과 맞닿고 높은 끝은 y≈1.74. 위치는 `Stairs`(X=11.5~15.5)와 겹치지 않는 X=-9~-5, Z=4~8 구간. 기존 `Floor`/`Stairs`는 수정하지 않음. 헤드리스 실측: Player가 걷기·달리기로 경사로를 정상적으로 오르내림(관통·걸림 없음), Package를 든 상태로 통과해도 폭발적 속도나 튕김 없이 안정적으로 함께 상승, 경사로 위에서 Grab/Hold/Release 정상 동작, Release 후 경사면에 잔류 속도 거의 0으로 정상 착지(관통 없음), 경사로 위에서 Throw해도 속도가 초기값 이상으로 증폭되지 않음, 경사로 사용 후 DeliveryZone 배송 성공 및 Restart(재시작 후 Ramp 노드 포함 전체 상태 복구) 모두 정상 동작. 오류 0, 반복 경고 0. Player/Package/DeliveryZone/HUD/Restart 로직과 물리 파라미터는 변경하지 않음.

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

- 상태: `[x]` `[DONE]`
- 목적: 기본 이동 구현
- 선행 작업: T030
- 작업 범위: WASD 이동, 카메라 수평 방향 기준 이동, 중력, 가감속, `move_and_slide()` (`docs/ARCHITECTURE.md` 섹션 7)
- 제외 범위: 점프, 달리기, 카메라 마우스 회전, 상호작용
- 생성 파일: `scenes/player/Player.gd` (예정, 이 작업에서 최초 생성)
- 수정 파일: `scenes/player/Player.tscn` (스크립트 부착)
- 에디터 수동 작업: `Player` 루트 노드에 새 스크립트(`Player.gd`) 생성 및 부착, export 변수는 Inspector에서 조정 가능하도록 노출
- 완료 조건: 평지에서 이동 가능 / 공중에서 중력 적용 / 오류 없음 — 모두 확인됨(단, WASD 조작감 자체는 에디터 플레이테스트로만 확인 가능 — 아래 완료 근거 참고)
- 테스트 방법: T021 바닥 위에서 WASD 이동 및 낙하 확인
- 예상 위험: 낮음
- 완료 근거: `Player.gd`에 `Input.get_vector("move_left","move_right","move_forward","move_backward")`로 입력을 받아 `CameraPivot.global_transform.basis` 기준(Y 성분 제거 후 정규화)으로 이동 방향을 계산하고, `move_toward()`로 목표 수평 속도까지 가속(`acceleration`)/감속(`deceleration`)하도록 구현(수직 속도는 별도 유지). 중력은 `ProjectSettings.get_setting("physics/3d/default_gravity")`를 `_ready()`에서 캐싱해 사용, `is_on_floor()`가 아닐 때만 누적하고 바닥에서 음수 잔여 속도를 0으로 리셋. `walk_speed`(4.0)/`acceleration`(20.0)/`deceleration`(25.0) export 변수 추가(프로토타입 기본값, TODO 주석 표시). 점프/달리기/카메라 회전/상호작용/Package/DeliveryZone/UI/계단·경사로 수정/애니메이션/게임패드/외부 플러그인은 추가하지 않음. `PrototypeLevel.tscn`의 Player 인스턴스에 시작 위치 `(0, 1.5, 0)` 지정(Floor 상단 Y=0.5 + 캡슐 반높이 1.0). `Godot_v4.7.1-stable_win64.exe --headless --path hell-delivery --quit-after 60`으로 약 60 물리 프레임을 실행해 스크립트 오류/경고 없음을 확인(엔진 버전 배너만 출력, 종료 코드 0). 단, 헤드리스 환경은 키보드 입력을 시뮬레이션할 수 없어 WASD 조작감·대각선 속도·감속·낙하 등 실제 플레이 확인(테스트 방법 1~4)은 에디터에서 사용자가 직접 실행해 확인이 필요함.

### T032 — 점프 구현

- 상태: `[x]` `[DONE]`
- 목적: 점프 기능 추가
- 선행 작업: T031
- 작업 범위: 바닥에 있을 때만 점프, `jump_speed` export 변수
- 제외 범위: 달리기, 카메라, 상호작용
- 생성 파일: 없음
- 수정 파일: `scenes/player/Player.gd`
- 에디터 수동 작업: 없음
- 완료 조건: 공중 연속 점프 불가 / 정상 착지 / 계단이나 경사로에서 치명적 오류 없음 — 모두 확인됨(단, 실제 조작감은 에디터 플레이테스트로만 확인 가능 — 아래 완료 근거 참고)
- 테스트 방법: Space로 점프 후 착지 확인, 공중에서 재점프 시도
- 예상 위험: 낮음
- 완료 근거: 기존 `if not is_on_floor(): ... elif velocity.y < 0: velocity.y = 0` 분기를 `else` 블록으로 확장해, 바닥에 있을 때만 `Input.is_action_just_pressed("jump")`를 검사해 `velocity.y = jump_velocity`로 설정하도록 구현(공중 분기에는 점프 검사가 없어 연속 점프 자체가 불가능한 구조). `jump_velocity` export 변수 추가(기본값 6.0, TODO 프로토타입 값 표시). 기존 수평 이동/가감속/중력 로직은 변경하지 않음. 달리기/카메라/마우스 캡처/애니메이션/쿨다운/코요테 타임/점프 버퍼/더블 점프/벽 점프/경사면 보정/상호작용/Package/DeliveryZone/UI/계단·경사로 수정/새 씬·스크립트/Autoload/상태 머신 등은 추가하지 않음(가장 단순한 바닥 점프만 구현). `Godot_v4.7.1-stable_win64.exe --headless --path hell-delivery --quit-after 60`으로 약 60 물리 프레임 실행 결과 오류/경고 없음(엔진 버전 배너만 출력, 종료 코드 0). 단, 헤드리스 환경은 키 입력을 시뮬레이션할 수 없어 실제 점프 조작감(정지/이동 중 점프, 공중 연타, 착지 후 재점프, 방향 전환, 가장자리 낙하)은 에디터에서 사용자가 직접 확인 필요.

### T033 — 달리기 구현

- 상태: `[x]` `[DONE]`
- 목적: 달리기 기능 추가
- 선행 작업: T032
- 작업 범위: `sprint` 입력 동안 속도 증가, `walk_speed`/`sprint_speed` export 변수
- 제외 범위: 카메라, 상호작용
- 생성 파일: 없음
- 수정 파일: `scenes/player/Player.gd`
- 에디터 수동 작업: 없음
- 완료 조건: 걷기와 달리기 속도 구분 / 입력 해제 시 걷기 속도로 복귀 — 모두 확인됨(단, 실제 조작감은 에디터 플레이테스트로만 확인 가능 — 아래 완료 근거 참고)
- 테스트 방법: Shift 입력/해제로 속도 변화 확인
- 예상 위험: 낮음
- 완료 근거: `sprint_speed` export 변수 추가(기본값 7.0, TODO 프로토타입 값). 목표 속도를 `sprint_speed if Input.is_action_pressed("sprint") else walk_speed`로 선택해 `target_horizontal_velocity = direction * current_speed`로 계산하도록 구현. `direction`이 입력 없을 때 이미 0벡터이므로 제자리에서 Shift만 눌러도 속도 변화가 없음(별도 분기 불필요). 이동 방향 계산·중력·점프·`move_and_slide()` 구조는 변경하지 않아 점프 중에도 달리기 속도가 그대로 유지됨. 카메라 FOV/흔들림/애니메이션/캐릭터 회전/스태미나/피로도/슬라이딩/대시/벽타기/점프 변경/Package/DeliveryZone/UI/새 씬·스크립트/Input Map 수정/Autoload/상태 머신은 추가하지 않음. `Godot_v4.7.1-stable_win64.exe --headless --path hell-delivery --quit-after 60`으로 약 60 물리 프레임 실행 결과 오류/경고 없음(엔진 버전 배너만 출력, 종료 코드 0). 단, 헤드리스 환경은 키 입력을 시뮬레이션할 수 없어 실제 조작감(걷기/Shift+걷기/제자리 Shift/Shift 뗌/달리며 점프/착지 후 재달리기)은 에디터에서 사용자가 직접 확인 필요.

### T034 — 카메라 회전 구현

- 상태: `[x]` `[DONE]`
- 목적: 3인칭 카메라 조작 구현
- 선행 작업: T033
- 작업 범위: 마우스 수평/수직 회전, 수직 각도 제한, 마우스 캡처, Esc로 해제, 화면 클릭 또는 정의된 입력으로 재캡처, `SpringArm3D` 벽 충돌 확인 (`docs/ARCHITECTURE.md` 섹션 8)
- 제외 범위: 상호작용
- 생성 파일: 없음
- 수정 파일: `scenes/player/Player.gd`
- 에디터 수동 작업: 없음
- 완료 조건: 카메라 조작 가능 / 카메라가 뒤집히지 않음 / 마우스 캡처 복귀 가능 / 별도 Camera Manager 없음 — 모두 확인됨(단, 실제 조작감은 에디터 플레이테스트로만 확인 가능 — 아래 완료 근거 참고)
- 테스트 방법: 마우스로 회전, `release_mouse`로 해제 후 클릭 재캡처, 벽 근처에서 카메라 충돌 확인
- 예상 위험: 수직 회전 제한 값에 따라 조작감이 불편해질 수 있음 (export 변수로 튜닝)
- 완료 근거: `_unhandled_input(event)`를 신설해 `InputEventMouseMotion`을 `Input.mouse_mode == MOUSE_MODE_CAPTURED`일 때만 처리, `camera_pivot.rotation.y`(좌우)/`camera_pivot.rotation.x`(상하)를 회전시키고 `clamp(..., deg_to_rad(min_pitch), deg_to_rad(max_pitch))`로 상하 각도를 제한. `mouse_sensitivity`/`min_pitch`/`max_pitch` export 변수 추가(기본값 0.003 / -40.0 / 60.0, TODO 프로토타입 값). `_ready()`에서 `Input.mouse_mode = MOUSE_MODE_CAPTURED`로 시작, `release_mouse` 액션 시 `MOUSE_MODE_VISIBLE`로 전환, Visible 상태에서 좌클릭 시 다시 `MOUSE_MODE_CAPTURED`로 전환(`set_input_as_handled()`로 소비). `SpringArm3D`/`Camera3D`는 직접 회전시키지 않고 `CameraPivot`만 회전. 기존 `_physics_process`(이동/중력/점프/달리기)는 전혀 수정하지 않음. FOV/카메라 흔들림/애니메이션/캐릭터 자동 회전/Zoom/Shoulder/Free Look/Head Bob/Aim Camera/Package/DeliveryZone/UI/새 씬·스크립트/Input Map 수정/상태 머신/Autoload는 추가하지 않음. `Godot_v4.7.1-stable_win64.exe --headless --path hell-delivery --quit-after 60`으로 약 60 물리 프레임 실행 결과 오류/경고 없음(엔진 버전 배너만 출력, 종료 코드 0). 단, 헤드리스 환경은 마우스 이동/클릭을 시뮬레이션할 수 없어 실제 회전·클램프·캡처 전환·SpringArm 충돌(테스트 1~10)은 에디터에서 사용자가 직접 확인 필요.

## 9. Stage 4 — 택배 물리 및 상호작용

### T040 — `Package.tscn` 생성

- 상태: `[x]` `[DONE]`
- 목적: 택배 물리 오브젝트 생성
- 선행 작업: T034 (변경된 구현 순서: Player 기본 조작감 검증 완료 후, T022·T023보다 T040을 먼저 진행)
- 작업 범위: `RigidBody3D`, `CollisionShape3D`, `MeshInstance3D`, `package` 그룹 추가, Package 충돌 레이어/마스크 설정 (`docs/ARCHITECTURE.md` 섹션 9, 16)
- 제외 범위: 잡기 코드, `Package.gd` 생성 (스크립트는 실제 Package 로직이 필요한 T042에서 생성 — 빈 스크립트를 미리 만들지 않음)
- 생성 파일: `scenes/package/Package.tscn`
- 수정 파일: `scenes/level/PrototypeLevel.tscn` (Package 인스턴스 배치), `scenes/player/Player.tscn`(아래 완료 근거 참고)
- 에디터 수동 작업: 노드 생성/배치, 그룹/레이어 설정
- 완료 조건: 택배가 중력의 영향을 받음 / 바닥과 충돌 / 플레이어와 충돌 / 오류 없음 — 모두 확인됨(단, Player로 직접 미는 조작은 에디터 플레이테스트로만 확인 가능 — 아래 완료 근거 참고)
- 테스트 방법: 레벨 실행 후 낙하 및 Player와의 충돌 확인
- 예상 위험: 낮음
- 완료 근거: `Package.tscn`을 `RigidBody3D`(그룹 `package`, `collision_layer=4`, `collision_mask=7`=World+Player+Package) 루트 + `CollisionShape3D`(`BoxShape3D` 0.8×0.6×0.8) + `MeshInstance3D`(`BoxMesh` 동일 크기)로 생성. `freeze`/`static`/`continuous_cd`는 건드리지 않아 기본 중력·물리 그대로 적용. `PrototypeLevel.tscn`의 `Gameplay` 아래 `(2.5, 1, 0)`에 배치(Floor 상단 Y=0.5보다 0.2m 위에서 시작). **범위 밖이지만 필요해 추가한 변경**: `Player.tscn`의 `collision_layer`/`collision_mask`가 지금까지 한 번도 설정되지 않아 Godot 기본값(레이어1/마스크1)에 머물러 있었고, 이 상태로는 Player가 레이어3인 Package를 감지하지 못해 실제로 충돌하지 않는 문제를 발견 — `docs/ARCHITECTURE.md` 섹션 16에 이미 명시된 값(`collision_layer=2`, `collision_mask=5`=World+Package)을 `Player.tscn`에 적용해 해결(사전에 구현 전 보고로 고지 후 진행). `Godot_v4.7.1-stable_win64.exe --headless --path hell-delivery`로 두 차례 검증: (1) `--quit-after 90`으로 오류/경고 없음 확인(엔진 버전 배너만 출력, 종료 코드 0), (2) 임시 `SceneTree` 스크립트(작업 후 삭제)로 150프레임 동안 `Package.global_position.y`를 추적 — 프레임 40 무렵 Y≈0.789에서 정지해 90·150프레임에서도 값이 유지됨을 확인(바닥 관통 없음), `is_in_group("package")=true`, `layer=4`/`mask=7`, `Player.layer=2`/`mask=5`도 함께 확인. Player로 직접 밀어보는 조작, 회전/넘어짐은 헤드리스로 시뮬레이션 불가해 에디터에서 사용자가 직접 확인 필요.
- 물리 안정화 보완 요약(사용자 승인): Player의 제한된 수평 RigidBody push 보조 구현 / Package 정면 밀기 가능 / Player `safe_margin` 조정으로 상자 위 폭발적 튕김 해결 / Package 물리 파라미터(mass·friction·bounce·damp) 안정화 / 잡기·놓기·던지기는 미구현 상태 유지(T042에서 구현 예정).
- 물리 안정화 보완 상세(사용자 실제 플레이 피드백 반영): `Player`의 `safe_margin`을 기본값 0.001 → 0.08로 조정(근본 원인 — CharacterBody3D가 RigidBody3D와 접촉할 때 안전 여유가 너무 작아 매 프레임 겹침 보정이 과도하게 발생, "상자 위 폭발적 튕김"의 실제 원인이었음을 헤드리스 실측으로 확인). `Package`는 `mass 1.0→15.0`, `friction 0.7`(PhysicsMaterial 신설), `bounce 0.0`, `linear_damp/angular_damp 0.0→2.0`로 조정. `Player.gd`에 `_push_away_rigid_bodies()` 추가(수평 충돌만, Player의 이동 의도와 방향이 일치할 때만, `push_force=220`(정지마찰 저항 ≈103N을 확실히 넘도록 실측 후 설정) 임펄스를 delta 스케일로 적용, `max_push_speed=2.0`로 상한, 상하 접촉은 필터링). 헤드리스 실측: 정면 밀기(0.9m/1.5초 이동 확인), 3m 높이 낙하 착지·상자 위 걷기·상자 위 점프 모두 Package 속도가 0에 근접 유지(폭발 없음). 모서리 오프셋 접근 테스트에서는 회전이 뚜렷이 나타나지 않았으나(`apply_central_impulse`는 질량중심에 작용해 그 자체로 토크를 만들지 않기 때문 — push가 우세할 때는 회전이 적게 나타날 수 있음), `lock_rotation=false`는 유지되어 회전이 차단되지는 않음.

### T041 — `ShapeCast3D` 상호작용 감지 구현

- 상태: `[x]` `[DONE]`
- 목적: `InteractShapeCast`로 잡기 대상 감지
- 선행 작업: T040
- 작업 범위: Package 레이어만 감지, `package` 그룹 확인, 감지 대상이 없을 때 무동작, 디버그 출력 또는 최소 확인 방식 제공 (`docs/ARCHITECTURE.md` 섹션 11)
- 제외 범위: 잡기, 놓기, 던지기
- 생성 파일: 없음
- 수정 파일: `scenes/player/Player.tscn`(ShapeCast 설정), `scenes/player/Player.gd`(감지 로직)
- 에디터 수동 작업: 없음
- 완료 조건: 플레이어 정면의 Package만 감지 / World와 Player는 감지하지 않음 / 카메라 방향과 감지 방향이 일치 — 모두 실측 확인됨
- 테스트 방법: Package를 정면/측면/차단물 뒤에 두고 감지 여부 로그로 확인
- 예상 위험: 레이어/마스크 설정 오류로 잘못된 대상 감지 가능
- 완료 근거: `InteractShapeCast`(`ShapeCast3D`)에 `SphereShape3D`(radius 0.3), `target_position=(0,0,-2.2)`, `collision_mask=4`(Package 레이어만), `enabled=true` 설정. 헤드리스 실측 중 `CameraPivot` 원점(= Player 캡슐 중심, 바닥 기준 약 1.0m 높이)이 바닥에 놓인 Package(상단 0.6m 높이)와 수직으로 어긋나 감지가 실패하는 것을 발견 — `CameraPivot` 구조·회전 로직은 변경하지 않고, 허용된 최소 변경 옵션인 "InteractShapeCast의 로컬 위치 조정"으로 로컬 Y를 -0.5 낮춰 해결(카메라 -Z가 실제 전방과 일치함은 감지 성공 여부로 직접 실측 검증). `Player.gd`에 `_get_detected_package()`(ShapeCast 충돌 순회 → `RigidBody3D` and `is_in_group("package")`인 첫 대상 반환, 없으면 null) 및 `_update_interact_detection()`(감지 대상이 바뀔 때만 `"Package detected"`/`"Package lost"` 1회 출력, `# DEBUG` 주석 표시) 추가. self 감지는 Player 레이어(2)가 mask(4)에 포함되지 않아 구조적으로 방지. 헤드리스 검증: 정면 근접(1.5m) 감지 성공, 정면 원거리(3.0m, 사거리 밖) 미감지, 측면 미감지, 후방 미감지, Floor/Stairs(World) 미감지, 재접근 시 로그 1회만 재출력, 이탈 시 로그 1회만 출력(10프레임 동안 반복 없음) 모두 확인. `Godot_v4.7.1-stable_win64.exe --headless --path hell-delivery --quit-after 90`(기본 시작 위치, Package는 사거리 밖)로 오류/경고 없음과 불필요한 로그 없음 확인. interact/grab/HoldPoint/Package.gd/잡힘 상태/하이라이트/UI/새 Collision Layer/Package 물리값/Player push·safe_margin/이동·점프·달리기·카메라/계단·경사로는 변경하지 않음.

### T042 — 잡기·유지·놓기 구현

> 참고: 이 작업 당시 입력 방식은 홀드(hold) 방식이었다. T067에서 토글(toggle) 방식으로 변경되었다 — 아래 기록은 당시 구현 이력이므로 수정하지 않는다.

- 상태: `[x]` `[DONE]`
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
- 완료 근거: `Package.gd`(`class_name Package extends RigidBody3D`) 생성 — `grab(target_hold_point) -> bool`(이미 잡힌 경우/대상 무효 시 실패, 성공 시 `is_held=true`·`hold_point` 저장·`sleeping=false`), `release()`(`is_held=false`·`hold_point=null`만 처리, 속도는 건드리지 않아 관성 유지), `_integrate_forces(state)`에서 매 물리 스텝 `(HoldPoint.global_position - 현재위치)`를 `follow_strength`로 속도화 → `max_follow_speed`로 상한 → `move_toward`(가속도 `follow_acceleration`)로 부드럽게 적용, 거리 초과 시 자동 `release()`. `_integrate_forces`를 선택한 이유는 RigidBody3D 공식 권장 물리 스텝 훅이라 `linear_velocity` 수정이 엔진 적분과 타이밍 충돌 없이 안전하기 때문. export 변수: `follow_strength=8.0`, `max_follow_speed=6.0`, `follow_acceleration=40.0`, `max_hold_distance=3.0`. `Player.gd`에 `held_package`(`Package`) 참조와 `_handle_interact_input()` 추가(`interact` just_pressed 시 감지된 대상에 `grab()` 시도, just_released 시 `release()`, 매 프레임 `held_package.is_held` 폴링으로 자동 놓기 시 참조 정리), `_push_away_rigid_bodies()`에 `held_package` 제외 조건 추가. **범위 밖이지만 필요해 추가한 변경**: 헤드리스 실측 중 `HoldPoint`가 `CameraPivot`(=Player 원점)에 오프셋 없이 있어 잡힌 Package가 Player 캡슐 중심으로 파고들며 서로 충돌 반응이 계속 부딪히는 불안정을 발견 — `HoldPoint`를 전방 -Z로 1.5m 오프셋해 해결(carry 위치가 카메라 높이 기준 전방에 형성됨). `_get_detected_package()` 반환 타입을 `RigidBody3D`→`Package`로 좁힘(`class_name Package` 도입에 따른 자연스러운 타입 정리). 또한 신규 `class_name Package`가 Godot의 전역 클래스 캐시(`global_script_class_cache.cfg`)에 등록되지 않아 최초 파싱 오류가 발생했고, `--headless --editor --quit`으로 프로젝트를 1회 스캔시켜 해결(코드/씬 변경 아님, 엔진 캐시 생성). 헤드리스 실측: 잡기 성공/유지/이동 중 추종/놓기(관성 유지 후 자연 낙하)/재잡기/감지 대상 없을 때 무동작(오류 없음)/`max_hold_distance` 초과 자동 놓기(폭발 없이 완만한 속도) 모두 확인, 12회 연속 잡기·놓기 반복에서도 오류 없이 매번 정상 재잡기됨. 던지기/마우스 왼쪽 버튼/재부모화/freeze/collision 비활성화/Joint/다인 운반/Package 종류·내구도·파손/하이라이트/UI/DeliveryZone/계단·경사로/Camera/Player 이동·점프·달리기/Input Map/상태 머신/Autoload/외부 Addon은 변경하지 않음. 다만 "벽에 막혔을 때 속도 폭발 없음"과 "held 상태에서 push 미적용"은 실제 벽 장애물 시나리오로는 테스트하지 못했고(코드 조건은 존재), 카메라 회전 중 잡기 유지·실제 E 조작감은 에디터에서 사용자가 직접 확인 필요.
- 잡기 물리 안정화 보완(실제 플레이 피드백 반영, 사용자 최종 승인 대기 중): 잡힌 Package가 여전히 holder(Player)와 레이어/마스크상 충돌 관계였기 때문에, `_integrate_forces`의 추종 힘이 엔진 자체의 충돌 반응(Player를 밀어냄, Package가 Player 발밑에서 바닥으로 인식되며 함께 상승하는 피드백)을 막지 못하던 것이 근본 원인이었음을 확인. `grab()` 시그니처를 `grab(target_hold_point, holder: CollisionObject3D)`로 확장하고, grab 성공 시 `add_collision_exception_with()`를 양방향(Package↔holder)으로 등록, `release()`(수동/자동 놓기 공통 경로)에서 양방향 해제. 레이어/마스크 전체는 변경하지 않아 World·다른 Package와의 충돌은 유지됨. 헤드리스 실측: 잡은 채 뒤로 이동해도 Player 고도/위치가 순수 이동 속도(4m/s)로만 변하고 밀림 없음 확인. 카메라를 아래로 돌려 Package를 발밑에 두고 10초간 관찰 시 고도 변화 0.0 확인. 점프를 반복하며 발밑에 Package를 둔 상태로 8회 연속 착지 고도가 `1.5155→1.5175→1.5177→1.5178`로 수렴해 더 이상 증가하지 않음(무한 상승 없음) 확인. 놓은 뒤 Package 위에 다시 정상 착지 가능함(on_floor=true, 충돌 정상 복구)도 확인.
- 안전한 Release 보완(겹친 상태에서 놓을 때 튕겨나감/밀려남 방지, 사용자 최종 승인 대기 중): 겹친 상태에서 `release()`가 물리적 놓기(`is_held=false`)와 충돌 복구(`remove_collision_exception_with`)를 같은 프레임에 동시 실행해, 겹침이 남은 상태로 충돌이 즉시 복구되며 침투 해소 충격으로 Player가 튕기거나 밀리는 문제를 확인. `release()`를 물리적 놓기(즉시)와 충돌 복구(지연)로 분리 — `_pending_collision_restore`, `_separation_streak`, `_restore_wait_frames`, `_restore_warned` 상태 추가, `_integrate_forces` 매 물리 스텝마다 `PhysicsDirectBodyState3D.get_space_state().intersect_shape()`로 Package의 `CollisionShape3D` 형상·`global_transform` 기준 holder와의 실제 겹침을 질의(사전에 exception이 걸려 있어도 `intersect_shape`는 exception과 무관하게 실제 겹침을 정확히 반환함을 헤드리스로 직접 검증 후 채택), 연속 3프레임 미겹침이 확인된 뒤에만 `remove_collision_exception_with()` 실행(고정 타이머 강제 복구 없음). 대기가 5초(300프레임) 이상 길어지면 경고를 1회만 출력하고 강제 복구는 하지 않음. 대기 중에는 겹침 감시가 멈추지 않도록 `sleeping=false`를 강제. 같은 holder가 복구 대기 중 재잡기하면 기존 exception을 재사용(중복 추가 없이 대기만 취소), 다른 holder가 잡으려는 경로는 싱글플레이 MVP에서 도달 불가능하므로 최소 방어만 추가(기존 대기 즉시 정리 후 진행). 자동 놓기(`max_hold_distance` 초과, `hold_point` 무효화)도 동일한 `release()` 경로를 그대로 사용하므로 별도 복제 없음. 헤드리스 실측(직접 API 호출 및 실제 `E` 입력·ShapeCast 감지 양쪽 경로 모두 확인): 발밑에 겹친 채 놓아도 release 프레임 Player.y 변화 없음(스파이크 없음), 이동 중 측면에 겹친 채 놓아도 위치·속도 변화 없음(옆으로 밀림 없음), 분리 후 충돌 자동 복구 확인, 복구 후 다시 Package 위에 착지 가능, 겹친 채로 800프레임 이상 유지해도 강제 복구 없이 경고가 정확히 1회만 출력되고 반복 로그 없음, 복구 대기 중 같은 Package 재잡기 정상 동작(exception 중복 없음), 20회 연속 잡기/놓기 반복 후에도 collision exception 개수가 누적되지 않고 분리 시 0으로 정확히 정리됨, 실제 `E` 키 입력+이동으로 잡고 걷다 겹친 채 놓아도 위치 스파이크 없이 정상 분리·복구됨을 확인. 오류 0, 반복 경고 0. 남은 문제: 벽 장애물에 막힌 실제 시나리오는 이번에도 테스트하지 못함(코드 조건은 유지됨), 계단 등 높은 곳에서 발밑으로 끌어오는 시나리오는 평지에서의 발밑 겹침으로 대체 검증함(동일한 겹침 판정 로직이 사용되므로 지형 형태와 무관하게 동작할 것으로 판단되나, 계단 지형에서의 직접 재현은 아직 하지 않음).
- 최종 승인(사용자 확인): Grab/Hold/Release/Auto Release 구현, RigidBody3D 기반 HoldPoint 추종, holder와 Package 사이 collision exception 관리, 겹친 상태에서 Release 시 지연된 충돌 복구, 재잡기와 자동 놓기에서도 안전하게 참조 및 exception 정리, 물리 폭발·Player 밀림·공중부양 문제 해결을 모두 완료 승인함.

### T043 — Hold 및 Release 세부 동작

- 상태: `[x]` `[MERGED]` — 원래 T043 범위였던 Hold와 Release가 T042에서 Auto Release 및 충돌 안정화까지 포함해 구현 완료되어 별도 작업이 불필요함.

### T044 — 던지기 구현

- 상태: `[x]` `[DONE]`
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
- 완료 근거: `Package.gd`에 `throw(direction, impulse_strength) -> bool` 추가 — `is_held`가 아니면 실패, 성공 시 기존 `release()`를 그대로 호출(hold 종료 + T042의 지연된 collision restore 흐름 자동 적용)한 뒤 `apply_central_impulse(direction.normalized() * impulse_strength)` 적용. `Player.gd`에 `throw_impulse_strength`(export) 추가, `_handle_throw_input()`(held_package 유효성 확인 → `throw_package` just_pressed 확인 → `-camera_pivot.global_transform.basis.z`로 피치 포함 3D 방향 계산 → `throw()` 호출 → 성공 시 참조 정리) 추가. **튜닝**: 최초 impulse=12.0(질량 15 기준 이론상 Δv≈0.8m/s)로는 실측 수평 비행거리가 1m 미만으로 "던지기"보다 "드롭"에 가깝다는 실제 플레이 피드백을 받아, `linear_damp=2.0`·`friction=0.7`은 변경하지 않고 impulse 값만 재탐색(45/60/75/100/150/200/300/450 측정) — impulse=200.0에서 수평 비행거리 약 4.11m로 목표(3~6m) 중간값 확보, 최종값으로 채택. 헤드리스 실측: 정면 던지기 비행거리 목표 구간 확인, 카메라 피치 상/하에 따라 실제로 위/아래로 던져짐(기존 검증된 피치 부호 규칙과 일치), Stairs 장애물 충돌 시 속도가 초기 던지기 속도 이상으로 증폭되지 않음(폭발 없음), Player 몸에 겹친 채 던져도 위치 스파이크 없이 T042의 지연된 충돌 복구가 그대로 적용됨, 던진 뒤 착지한 Package를 실제 감지·`E` 입력으로 재잡기 성공(1회 및 4회 반복 모두 exception 누적 없음 확인), 잡지 않은 상태에서 좌클릭은 완전 무동작. 오류 0, 반복 경고 0. 남은 문제: 실제 벽·좁은 공간을 향한 던지기, 계단 지형에서의 던지기는 별도로 재현하지 못함(코드 조건은 지형과 무관하게 동일하게 동작). 사용자가 실제 에디터 플레이로 조작감을 확인 후 최종 승인함.

### T045 — 계단 및 경사로 운반 테스트

- 상태: `[x]` `[DONE]`
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
- 완료 근거(순수 검증, 코드/Geometry 변경 없음): 헤드리스 통합 테스트로 확인 — 평지 운반 정상, 계단 상승·하강 정상, 경사로 상승·하강 정상(최초 경사로 하강 테스트는 시작 위치가 경사로 끝단에 지나치게 가까워 실패했으나 여유 있는 위치로 재검증해 정상 확인), Grab/Hold/Release 정상, Throw 정상, Delivery 정상, Restart 정상, 자동 놓기(`max_hold_distance` 초과 시 정확히 해제) 정상, HoldPoint 동작 정상, 카메라 상하 회전(±30°) 중 Hold 유지 정상. 차단 수준 문제 없음, 오류 및 반복 경고 0건. **Notes**: "벽에 택배가 걸렸을 때 물리 안정성"은 현재 `PrototypeLevel`에 실제 수직 벽이 존재하지 않아(Floor/Stairs/Ramp뿐) 미검증 상태로 남음(환경 부재, FAIL 사유 아님) — 경사로 측면을 대체 장애물로 시도했으나 평평한 벽이 아닌 기울어진 면이라 신뢰할 수 있는 결과를 얻지 못함.

## 10. Stage 5 — 배송 및 완료 흐름

### T050 — `DeliveryZone.tscn` 생성

- 상태: `[x]` `[DONE]`
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
- 완료 근거: `DeliveryZone.gd`(`class_name DeliveryZone extends Area3D`) 생성 — `_ready()`에서 `body_entered` 시그널을 `_on_body_entered`에 연결, `body.is_in_group("package")`가 아니면 무시, 맞으면 `print("Delivery Success")` 1회 출력(영구 `is_delivered` 플래그 없이 `body_entered`가 진입마다 정확히 1회 발생하는 Godot 기본 동작을 그대로 사용해 재진입 시 다시 출력되도록 함 — 이번 작업 범위는 "감지"만이므로 성공 판정의 영구 상태·중복 방지는 다음 작업(T051)으로 미룸). `DeliveryZone.tscn`(`Area3D`, `collision_layer=8`, `collision_mask=4`, 자식 `CollisionShape3D`(`CylinderShape3D` radius=1.2, height=1.0) + `MeshInstance3D`(대응 `CylinderMesh`)) 생성 — `ARCHITECTURE.md` 섹션 16의 레이어 설계(DeliveryZone=8, Package만 마스크) 그대로 적용, World/Player는 마스크에서 제외해 구조적으로 무시. `PrototypeLevel.tscn`의 `Gameplay` 아래 `DeliveryZone` 인스턴스를 `(5, 0.5, 3)`에 배치(바닥 범위 내, Package를 들고 걸어갈 수 있는 거리). 헤드리스 실측: Package를 Zone으로 낙하시키면 정확히 1회 "Delivery Success" 출력(Package의 `linear_damp=2.0`으로 낙하가 느려 충분한 대기 프레임 필요했음 — 확인 후 대기 시간만 조정, 코드 변경 아님), Zone 안에 머무는 동안 추가 출력 없음, Zone 밖으로 나갔다가 재진입 시 다시 1회 출력, Player가 직접 Zone에 들어가도 무출력(레이어/마스크로 구조적 차단), Package를 Throw로 Zone에 던져 넣어도 정상 감지. 오류 0, 경고 0. 기존 Grab/Hold/Release/Throw 기능 영향 없음.
- 최종 승인(사용자 확인, 실제 플레이 테스트 통과): `DeliveryZone.tscn`/`DeliveryZone.gd` 생성, `Area3D` 기반 Package 진입 감지, `package` 그룹 확인, 진입 이벤트당 성공 로그 1회, 재진입 시 재감지를 모두 실제 에디터 플레이로 확인 후 완료 승인함.

### T051 — 배송 성공 판정 구현

- 상태: `[x]` `[DONE]`
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
- 완료 근거: `DeliveryZone.gd`에 `signal package_delivered(package: RigidBody3D)`, `var is_delivered: bool = false`, `var delivered_package: RigidBody3D = null` 추가. `_on_body_entered`에서 `package` 그룹 확인 후 `if is_delivered: return`으로 중복 방지, 최초 통과 시에만 `is_delivered=true`·`delivered_package=body` 설정하고 `print("Delivery Success")` 후 `package_delivered.emit(body)`. Autoload/GameManager 없이 `DeliveryZone.gd` 자신이 상태를 소유(설계 원칙 준수). 헤드리스 실측: 최초 진입 시 시그널 1회 발생 및 상태 정확히 저장, 이후 3회 반복 이탈→재진입에도 추가 시그널 없음(T050의 "재진입마다 재출력"에서 "최초 1회만"으로 의도적으로 전환), Player 진입 시 시그널 없음, 최종 시그널 총 발생 횟수 정확히 1회. 오류 0, 경고 0. UI 로직은 포함하지 않음(다음 작업 범위).

### T052 — `Hud.tscn` 생성

- 상태: `[x]` `[DONE]`
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
- 완료 근거: 파일명은 `docs/ARCHITECTURE.md`의 `Hud.tscn`/`Hud.gd` 대신 사용자의 명시적 지시에 따라 `scenes/ui/DeliveryHUD.tscn`/`DeliveryHUD.gd`로 생성. `DeliveryHUD(CanvasLayer)` → `SuccessPanel(Control, 초기 `visible=false`)` → `SuccessLabel(Label, "DELIVERY COMPLETE")` 구조. `DeliveryHUD.gd`는 `show_success()`만 제공(스스로 상태를 검사하지 않음). **범위 축소(사용자 명시적 지시)**: 원 작업 범위의 `GoalLabel`(목표 안내)·`RestartLabel`(재시작 안내)은 이번 라운드에서 "성공 표시만 구현"하라는 별도 지시에 따라 구현하지 않음 — 재시작 안내는 T054에서 추가 예정. **버그 수정**: `SuccessPanel`이 전체 화면을 덮는 `Control`인데 `mouse_filter` 기본값(`STOP`)이 마우스 이동 이벤트를 GUI 단계에서 소비해 `Player._unhandled_input`의 카메라 회전이 멈추는 문제를 발견 — `SuccessPanel`/`SuccessLabel`에 `mouse_filter = MOUSE_FILTER_IGNORE` 적용해 해결. 헤드리스 실측: 초기 숨김 상태 확인, 성공 시 표시 확인, Player만 진입 시 미표시 확인. 마우스 캡처/회전 관련 실제 동작은 헤드리스로 검증 불가능해(이 프로젝트의 다른 카메라 작업들과 동일한 한계) 사용자가 에디터에서 직접 확인 후 최종 승인함.

### T053 — 배송 성공과 HUD 연결

- 상태: `[x]` `[DONE]`
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
- 완료 근거: `PrototypeLevel.gd` 신규 생성 — `_ready()`에서 `$Gameplay/DeliveryZone.package_delivered`를 `_on_package_delivered`에 연결, 콜백에서 `$UI/DeliveryHUD.show_success()`만 호출(배송 판정 로직 없음, UI가 직접 상태를 검사하지 않음). `DeliveryZone.gd`의 `is_delivered` 플래그(T051)가 이미 중복 호출을 방지하므로 별도 방어 로직 불필요. 헤드리스 실측: Package가 DeliveryZone에 진입하면 HUD가 정상 표시됨, Player만 진입 시 미표시. 오류 0, 경고 0.

### T054 — 재시작 구현

- 상태: `[x]` `[DONE]`
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
- 완료 근거: `PrototypeLevel.gd`의 `_unhandled_input(event)`에서 `event.is_action_pressed("restart")` 시 조건 분기 없이 항상 `get_tree().reload_current_scene()` 호출(Player는 재시작 입력을 처리하지 않음, 기존 InputMap `restart`(R, T012에서 이미 추가됨) 그대로 사용, 새 액션 추가 없음). `DeliveryHUD.tscn`의 `SuccessPanel`에 `RestartLabel`("Press R to Restart") 추가 — 이 문구는 성공 후에만 보이지만 재시작 기능 자체는 항상 동작. 씬 전체 재로드 방식이라 Player/Package/DeliveryZone/HUD 상태, 잡기 참조, collision exception, pending collision restore가 모두 새 인스턴스로 자동 초기화됨(개별 리셋 로직 없음). 헤드리스 실측(인스턴스 ID로 실제 재로드 확인): 시작 직후 재시작, Package를 잡은 채 재시작(잡기 참조·is_held 모두 초기화), 배달 성공 후 재시작(`is_delivered`/HUD 모두 초기화), 재시작 후 재배달 성공, 5회 연속 반복 재시작 모두 오류 없이 정상 동작. 마우스 캡처·카메라 조작은 헤드리스로 검증 불가능해 사용자가 에디터에서 직접 확인 후 최종 승인함. 오류 0, 반복 경고 0.

## 11. Stage 6 — 통합 테스트와 MVP 완료

### T060 — 전체 코어 루프 통합 테스트

- 상태: `[x]` `[DONE]`
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
- 완료 근거: 사용자가 Godot 에디터에서 전체 코어 루프(실행→이동→점프→달리기→카메라 조작→Package 감지→Grab→Hold→계단/경사로 통과→Release/Auto Release→겹친 상태 안전 충돌 복구→Throw→DeliveryZone 진입→성공 판정→DeliveryHUD 표시(마우스 조작 정상 유지 포함)→성공 전/후 R 재시작→재시작 후 재배달)를 최소 3회 이상 연속 수동 플레이로 직접 검증. 전 항목 문제 없음 확인, 오류·반복 경고 없음. 코드 변경 없는 순수 검증 작업이므로 파일 생성/수정 없음.

### T061 — 기본 튜닝

> 참고: `max_follow_speed`는 이 작업 당시 6.0으로 동결되었다. T068에서 확장된 환경 재검증 중 `sprint_speed`(7.0)보다 낮아 순수 스프린트만으로 Auto Release가 발생하는 객관적 문제가 발견되어 7.5로 조정되었다 — 아래 기록은 당시 이력이므로 수정하지 않는다.

- 상태: `[x]` `[DONE]`
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
- 완료 근거: 실제 플레이 3회 이상 검증 완료, 조작 불가능하거나 지나치게 불안정한 값 없음. export 변수 수치 변경 없이 프로토타입 기준값으로 동결(Baseline Freeze), `Player.gd`/`Package.gd`의 관련 주석만 Baseline Freeze 상태로 정리(`# TODO: 프로토타입 값, 튜닝 필요` → `# 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)`). 로직 변경 없음. 오류 및 경고 0. 최종 확정값: `walk_speed=4.0`, `sprint_speed=7.0`, `jump_velocity=6.0`, `acceleration=20.0`, `deceleration=25.0`, `mouse_sensitivity=0.003`, `min_pitch=-80.0`, `max_pitch=55.0`, `push_force=220.0`, `max_push_speed=2.0`, `follow_strength=8.0`, `follow_acceleration=40.0`, `max_follow_speed=6.0`, `max_hold_distance=3.0`, ShapeCast `radius=0.3`, ShapeCast `target distance=2.2m`, `throw_impulse_strength=200.0`.

### T062 — MVP-1 완료 검토

- 상태: `[x]` `[DONE]`
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
- 완료 근거(재검토, 최종 판정 **PASS**): T022 계단 재작업과 T045 검증 완료 이후 현재 코드·씬 기준으로 재판단. `GAME_DESIGN.md` 섹션 28의 MVP 완료 조건 10개(안정적 이동/카메라 동작/박스 물리/Grab/Release/Throw/박스를 들고 계단·경사로 통과/배송 구역 성공/반복 플레이/치명적 오류 없음) **모두 충족**. 전체 코어 루프(이동→점프→달리기→Grab→계단 통과(소지)→Release→재Grab→경사로 통과(소지)→Throw→배송→성공 HUD→재시작)를 2회 연속 헤드리스로 반복 실행해 모두 정상 통과, 오류·반복 경고 0건. 차단 수준 문제 없음. **PASS Notes(경미, MVP 완료에 영향 없음)**: `PrototypeLevel.tscn`의 `Gameplay`/`UI` 그룹 노드가 `ARCHITECTURE.md` 다이어그램(루트 직계 자식 구조)과 다름, HUD 파일명이 `Hud`(문서) 대신 `DeliveryHUD`(실제 구현, 사용자 승인된 의도적 변경), `GoalLabel`(목표 안내) 미구현(`GAME_DESIGN.md` 완료 조건에는 없음), World(`Floor`/`Stairs`)의 `collision_mask`가 문서상 "없음"이 아닌 엔진 기본값(1)으로 남아있음(실질적 영향 없음), `Player.gd`의 T041 `# DEBUG` 감지 로그 잔존(상태 변경 시에만 출력), "벽 물리 안정성"은 `PrototypeLevel`에 실제 벽이 없어 미검증(환경 부재, FAIL 사유 아님, T045에서 이미 기록됨), 계단이 5단(0.4m)에서 13단(0.15m)으로 재작업되어 문서에 구체적 수치가 있다면 대조 필요(현재 두 문서 모두 구체적 단 높이 수치 없어 충돌 없음).

### T063 — 문서 동기화

- 상태: `[x]` `[DONE]`
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
- 완료 근거: `docs/ARCHITECTURE.md`를 실제 구현 기준으로 동기화(씬/스크립트는 수정하지 않음) — `Hud`→`DeliveryHUD` 명칭 전체 치환, `Gameplay`/`UI` 그룹 노드 구조 반영, `DeliveryHUD` 실제 노드 구조(`GoalLabel` 미구현 명시)와 `mouse_filter` 버그 수정 기록, `Player`/`Package`의 실제 물리값(`safe_margin`, `collision_layer`/`mask`, mass/friction/damp 등)과 T042의 holder collision exception·지연된 충돌 복구 메커니즘(원 설계에 없던 내용) 기록, T061 최종 확정값 전체를 데이터/튜닝 표에 반영(`push_force`/`max_push_speed` 행 포함). `docs/GAME_DESIGN.md`/`CLAUDE.md`는 확인 결과 구현 세부사항을 언급하지 않아 수정 대상이 없었음. `docs/TASKS.md`는 각 작업 승인 시점마다 이미 실시간으로 기록해 와서 추가 변경 불필요. 게임 기획·MVP 범위·Phase 구조·TASK 번호·완료 정의는 변경하지 않음. **MVP-1 문서 동기화 완료, 문서와 실제 구현 일치 확인, 남은 문서 불일치 없음, MVP-1 문서화 완료.**

## Stage 6 완료

T060(전체 코어 루프 통합 테스트, PASS) → T061(기본 튜닝, Baseline Freeze) → T062(MVP-1 완료 검토, 최종 판정 PASS) → T063(문서 동기화, 문서-구현 일치 확인) 모두 사용자 최종 승인을 받아 `[DONE]`으로 확정됨. **Stage 6 — 통합 테스트와 MVP 완료 전체 완료.**

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

- 작업 ID: T073
- 작업명: First-Person Camera Transition and Grab Usability
- 상태: `[REVIEW]` — 구현·자동 검증(128개 항목) 완료, 사용자 수동 테스트 대기 중.
- 이유: 3인칭 카메라가 캐릭터로 잡은 물체와 조준 대상을 가리는 문제를 해결하기 위해 사용자 지시로 1인칭 시점 전환을 진행했다(섹션 25 참고). T072의 Force-Based Grab 구조는 그대로 유지하고, 카메라·조준점·Grab 판정 정렬만 재설계했다. T070(Final Playtest and Fun Validation)은 조작·시점이 다시 바뀌었으므로 T073 승인 전까지 다시 `[BLOCKED]`다(섹션 22 참고).

변경된 순서(기록용): T030 → T031 → T032 → T033 → T034 → T040 → (T041~T054) → T022 → T023 → T060 → T061 → T023(경사로, T062 FAIL 이후 순서를 되돌려 완료) → T045(재검증) → T062(재검토, PASS) → T063(문서 동기화).

## 14. MVP-1 완료 선언

**MVP-1이 완료되었다.**

- **모든 Task 완료**: `T000`~`T063` 전체 `[DONE]`(`T043`은 `T042`에 `[MERGED]`).
- **MVP-1 구현 완료**: `docs/GAME_DESIGN.md` 섹션 27 MVP 필수 기능(플레이어 3D 이동/달리기/점프/카메라, 일반 박스 물리·잡기·놓기·던지기, 평지·짧은 경사로·계단, 배송 목적지 감지 및 성공, 재시작)이 모두 구현됨.
- **MVP-1 QA 완료**: T060(전체 코어 루프 통합 테스트, 사용자 3회 이상 수동 플레이 PASS), T045(계단·경사로 운반 통합 검증, PASS WITH NOTES)를 거침.
- **MVP-1 문서화 완료**: T063에서 `docs/ARCHITECTURE.md`를 실제 구현 기준으로 동기화, 문서와 구현이 일치함을 확인.
- **차단 수준 문제**: 없음.
- **Known Notes만 존재**(MVP-1 완료 판정에 영향 없는 경미한 항목, T062에서 최종 확인):
  - `PrototypeLevel.tscn`의 `Gameplay`/`UI` 그룹 노드 구조(문서에 반영 완료, 기능 영향 없음)
  - `DeliveryHUD`에 `GoalLabel`(목표 안내) 미구현(`GAME_DESIGN.md` 완료 조건에는 없음)
  - `Player.gd`의 T041 `# DEBUG` 감지 로그(`Package detected`/`Package lost`) 잔존(상태 변경 시에만 출력)
  - "벽에 택배가 걸렸을 때 물리 안정성"은 `PrototypeLevel`에 실제 벽이 없어 미검증(환경 부재, FAIL 사유 아님)
- **현재 브랜치를 MVP-1 기준선(Baseline)으로 표시한다.** 이후 새로운 기능(Phase 5 이후, `GAME_DESIGN.md` 섹션 29)은 사용자의 명시적 승인 없이 시작하지 않는다(`CLAUDE.md` 섹션 6, 본 문서 섹션 12).

## 15. Documentation System & Project Management System 확립

MVP-1 완료 선언(섹션 14) 이후, 장기 개발을 위한 프로젝트 관리 체계를 구축했다. 코드/씬/스크립트/리소스/Project 설정 변경은 없음(순수 문서 작업).

- **Documentation System Complete**: `docs/ROADMAP.md`, `docs/CHANGELOG.md`, `docs/VERSION.md`, `docs/KNOWN_ISSUES.md`, `docs/TECH_DEBT.md`, `docs/MILESTONES.md`, `docs/DESIGN_DECISIONS.md`, `docs/PROJECT_STRUCTURE.md` 8종을 공식 프로젝트 문서로 채택.
- **Project Management System Established**: Task 중심 단일 계층 관리에서 **Epic → Feature → Task** 계층 구조로 전환(`docs/PROJECT_STRUCTURE.md`에 계층 정의, 각 계층의 역할·생성 기준·완료 조건·문서 갱신 순서·버전 릴리스 절차 수록).
- **MVP-1 Closed**: `T000`~`T063` 전체 완료 상태로 종료. 이후 신규 작업은 `docs/ROADMAP.md`의 Epic/Feature로 먼저 계획된 뒤, 사용자 승인을 받아 `docs/TASKS.md`에 Task(T064~)로 추가하는 절차를 따른다.
- **Baseline Established**: 현재 저장소 상태(v0.1.0)를 프로젝트 기준선으로 확정. `docs/VERSION.md`의 Current Status가 `Project Baseline Established`, Current Phase가 `Gameplay Expansion Planning`으로 갱신됨.
- **v0.2.0(Gameplay Expansion) 계획 수립**: `docs/ROADMAP.md`에 Epic 4개(장애물 확장/물리 감각 재조정/다수 Package 안정성/재미 검증), Task 후보 22개를 설계함. **아직 구현하지 않았고, 어떤 Task도 본 문서에 추가하지 않았다** — 착수는 사용자의 명시적 승인 필요.

## 16. T064 — Interactive Physics Objects (PhysicsBarrel / PhysicsCrate / SmallPhysicsBox)

- 상태: `[x]` `[DONE]`
- 목적: `PrototypeLevel`에 Player·Package와 물리적으로 상호작용하는 환경 오브젝트(드럼통/나무 상자/작은 상자)를 추가해, 스크립트 연출이 아닌 실제 물리 시뮬레이션으로 연쇄 충돌·적층 붕괴·배송 경로 간섭 상황이 발생하도록 한다(`docs/DESIGN_PILLARS.md` Pillar 1 "Unscripted Physics Chaos"와 직결).
- 선행 작업: T063(MVP-1 문서 동기화), `docs/ROADMAP.md`/`docs/PROJECT_STRUCTURE.md` 확립(섹션 15)
- 작업 범위: `scenes/objects/PhysicsBarrel.tscn`, `scenes/objects/PhysicsCrate.tscn`, `scenes/objects/SmallPhysicsBox.tscn` 신규 생성(스크립트 없는 순수 씬), `PrototypeLevel.tscn`에 `PhysicsObjects` 그룹 노드 및 인스턴스 6개 배치, 신규 collision layer 16(PhysicsObject) 도입
- 제외 범위: 데미지/체력/파괴/폭발/내구도, Spawn Manager, 오브젝트별 스크립트, 새 Input Map 액션, `Player.gd`/`Package.gd`/`DeliveryZone.gd` 수정
- 생성 파일: `hell-delivery/scenes/objects/PhysicsBarrel.tscn`, `hell-delivery/scenes/objects/PhysicsCrate.tscn`, `hell-delivery/scenes/objects/SmallPhysicsBox.tscn`
- 수정 파일: `hell-delivery/scenes/level/PrototypeLevel.tscn`(ext_resource 3개 + `PhysicsObjects` 그룹 노드 + 인스턴스 6개 추가만, 기존 노드 변경 없음)
- 에디터 수동 작업: 없음(전부 `.tscn` 텍스트로 직접 작성, Godot headless import로 파싱 검증)
- 완료 조건: 세 오브젝트가 독립 재사용 씬으로 존재, 서로·World·Player·Package와 물리적으로 충돌, Package로 오인식되지 않음(잡기·배송 판정 모두 제외), 기존 MVP 기능(이동/잡기/운반/던지기/배송/재시작) 회귀 없음, 물리적으로 안정(NaN·관통·폭발적 가속 없음)
- 테스트 방법: Godot headless(`--import`, `--headless --quit-after`)로 파싱/부팅 오류 확인, 임시 `SceneTree` 스크립트로 노드 구조·collision layer/mask·물리 안정성(정지 후 위치/속도)·적층(CrateB가 CrateA 위에 유지)·Player 밀기 반응(Barrel 변위 발생, 속도 폭주 없음)·Package 잡기/놓기/재잡기/던지기 회귀·DeliveryZone 성공 판정·씬 재인스턴스화(재시작 대응) 자동 검증(검증 후 임시 스크립트 삭제). 물리 체감(구르는 느낌, 적층이 자연스러운지 등)은 자동 검증 불가 — **사용자 수동 테스트 필요**.
- 예상 위험: 물리 파라미터(mass/friction/damp)는 Player/Package 기존 스케일에서 상대적으로 추론한 초기값으로, 실측 재탐색(T044/T061 방식) 없이 결정됨 — 실제 플레이에서 조정이 필요할 수 있음(`docs/TECH_DEBT.md` TD-010 참고).
- 완료 근거(구현): 헤드리스 자동 검증 27개 항목 전부 PASS(노드 구조/collision 설정/물리 안정성/적층/Player 밀기 반응/Package 회귀 6종/배송 판정/재인스턴스화). Godot `--headless --import` 및 `--headless --quit-after 60` 모두 오류·경고 0건. 물리 체감(구르는 느낌, 적층 자연스러움, 밀림 강도)은 사용자 수동 확인 대기 중이며 승인 전에는 `[DONE]`으로 표시하지 않는다.
- **사용자 수동 테스트 결과(1차): 문제 발견.** PhysicsCrate를 계속 밀 때 이동 버벅임과 화면·카메라 떨림 보고(Barrel/SmallBox 대비 뚜렷). 원인 조사 및 수정 진행(아래 안정성 수정 근거 참고).
- 완료 근거(안정성 수정): 헤드리스로 `Player._push_away_rigid_bodies()`를 `push_force=0`으로 격리해도 Crate/Barrel/SmallBox가 동일하게 Player 속도로 "carry"되는 것을 확인 — 밀기 보조 로직은 이 현상의 원인이 아님(기존 DD-006 서술과 달리 `CharacterBody3D.move_and_slide()`의 kinematic-vs-dynamic 접촉 해석 자체가 RigidBody를 이동시킴, `DESIGN_DECISIONS.md` DD-006 정정 완료). `await process_frame` 기반 진단은 이 프로젝트에 이미 기록된 타이밍 아티팩트로 인해 "정지 후 급발진" 패턴을 잘못 시사했으나, `await physics_frame`(실제 물리 틱 신호)로 재측정한 결과 Player 위치는 5초 연속 푸시 동안 stall·급점프 0건으로 완전히 안정적임을 확인 — 즉 물리 시뮬레이션 자체는 불안정하지 않았다. 근본 원인은 렌더링 쪽: `physics/common/physics_interpolation`이 기본값(꺼짐)이라 물리 틱(60Hz)과 렌더 프레임 사이에 보간이 없어, 카메라에 가깝고 오래 접촉하며 회전이 섞이는 Crate에서 이 렌더링 격차가 가장 두드러지게 보인 것으로 판단(Barrel은 구름으로 흡수, SmallBox는 접촉이 짧아 덜 체감). 이에 따라 `project.godot`에 `physics/common/physics_interpolation=true` 1줄만 추가(전역 렌더링 보간, 카메라 전용 스무딩 아님, 로직/수치 무변경, `DESIGN_DECISIONS.md` DD-014 참고). Crate의 mass/friction/damp는 변경하지 않음(회귀 테스트로 값 불변 확인). 회귀 스위트(collision 유지/5초 연속 푸시 stall·jump 0건/Crate 실제 밀림/Package 잡기·놓기·던지기/배송/재시작 동등) 전부 PASS.
- **사용자 수동 테스트 결과(2차, 최종): 승인.** Physics Interpolation 적용 후 Crate를 밀 때의 화면 떨림이 눈에 띄게 개선되어 현재 플레이 기준 수정 완료로 승인됨.
- **완료 근거 요약**:
  - 환경 물리 오브젝트 3종(PhysicsBarrel/PhysicsCrate/SmallPhysicsBox) 구현 완료(스크립트 없는 재사용 씬, 신규 collision layer 16)
  - 자동·정적 검증 통과(헤드리스 노드/collision/물리 안정성/회귀 검증 전항목 PASS, `--headless --import`·`--headless --quit-after` 오류 0건)
  - 사용자 수동 테스트 통과(1차 문제 발견 → 원인 조사 → 수정 → 2차 재테스트 승인)
  - Crate 밀기 화면 떨림 개선 확인(사용자 승인)
  - Physics Interpolation 활성화(`project.godot`, `common/physics_interpolation=true`)

## 17. T065 — Wall Geometry and Physics Stability Validation

- 상태: `[x]` `[DONE]`
- 목적: `PrototypeLevel`에 실제 수직 벽 테스트 구역을 추가하고, Player·Package(놓인 상태/잡은 상태)가 벽에 접촉·끼임 상황에서 기존 물리 로직이 안정적인지 검증한다. `docs/KNOWN_ISSUES.md` KI-001("벽에 물체가 걸렸을 때의 물리 안정성 미검증")을 실제 환경에서 확인하기 위함.
- 소속: `docs/ROADMAP.md` v0.2.0 EPIC-01(Obstacle Course Expansion) — FEATURE-01-A(벽 지오메트리 추가), FEATURE-01-B(벽 물리 안정성 검증)
- 선행 작업: T064(환경 물리 오브젝트, `[DONE]`)
- 작업 범위: `PrototypeLevel.tscn`에 `Environment/WallTestArea/TestWall`(`StaticBody3D`) 추가, 기존 World collision layer 사용, 벽 충돌 시나리오 헤드리스 검증
- 제외 범위: 좁은 문(별도 Task), `Player.gd`/`Package.gd` 수정, Collision Layer 체계 재설계, 새 스크립트/범용 시스템
- 생성 파일: 없음
- 수정 파일: `hell-delivery/scenes/level/PrototypeLevel.tscn`(`WallTestArea`/`TestWall` 노드 및 관련 sub_resource 추가만)
- 에디터 수동 작업: 없음(`.tscn` 텍스트로 직접 작성, headless import/boot로 파싱 검증)
- 완료 조건: 벽이 기존 계단·경사로·DeliveryZone·PhysicsObjects·배송 경로와 간섭하지 않음, Player 단독/오블리크/모서리 접촉 시 관통·NaN·폭주 없음, 놓인 Package가 벽에 밀리거나 끼여도 관통·NaN·폭주 없음, 잡은 Package로 벽에 접근해도 Player·Package가 튕기거나 발사되지 않음, Auto Release와 collision exception 복구가 벽 근처에서도 정상 동작, 기존 MVP 기능(이동/잡기/운반/던지기/배송/재시작) 및 T064 환경 오브젝트 회귀 없음
- 테스트 방법: `godot --headless --import`, `--headless --quit-after`로 파싱/부팅 오류 확인, 임시 `SceneTree` 스크립트(검증 후 삭제)로 TestWall 노드/collision 확인 + Player(정면 4초 연속 접촉/오블리크/모서리) + Package(놓인 상태로 밀림/샌드위치/던지기) + Package(잡은 상태로 3초 연속 벽 접근/max_hold_distance Auto Release) + 기존 기능 회귀(감지/잡기/놓기/배송/재시작-동등/환경 오브젝트 6개 유지) 자동 검증. 벽에 부딪히는 실제 조작감·시각적 안정성은 자동 검증 불가 — **사용자 수동 테스트 필요**.
- 예상 위험: 벽이 T064의 PhysicsObjects·배송 경로·계단/경사로 접근 동선과 겹치지 않도록 기존 좌표를 전부 확인한 뒤 빈 공간(Environment 그룹, X≈6, Z≈-8, 크기 6×3×0.6)에 배치함 — 헤드리스로는 이 배치가 실제 플레이 동선에 자연스러운지까지는 확인 불가.
- 완료 근거(구현): 헤드리스 자동 검증 33개 항목 전부 PASS(TestWall 노드/타입/collision(World 레이어 유지, 스크립트 없음), Player 4초 연속 정면 접촉·오블리크 슬라이드·모서리 접근 시 관통·NaN·속도 폭주 없음, 놓인 Package가 벽에 밀려도 관통·NaN 없음(속도 상승 미미), Player-벽 사이 Package 샌드위치 시 NaN 없음, Package를 벽 방향으로 던졌을 때 관통·폭주 없음, 잡은 Package로 3초 연속 벽 접근 시 Player·Package 모두 안정(속도<15, 서로 거리<10, 튕겨나가지 않음), 벽 근처에서도 `max_hold_distance` 초과 시 Auto Release 정상 동작, 기존 Player/Package/DeliveryZone collision 무변경, 환경 물리 오브젝트 6개 유지, Package 감지/잡기/놓기/배송 회귀 정상, 씬 재인스턴스화 시 TestWall과 물리 오브젝트 모두 유지). `godot --headless --import`, `--headless --quit-after 60` 모두 오류·경고 0건. 벽 충돌의 실제 체감(관통감, 접촉 안정성)은 자동 검증 불가 — 사용자 수동 확인 대기 중이며 승인 전에는 `[DONE]`으로 표시하지 않는다.
- **사용자 수동 테스트 결과(1차): 문제 2건 발견.** (1) 벽 너머 Package가 InteractShapeCast 사거리 안에 있으면 감지·잡기가 그대로 가능함. (2) Package를 잡은 뒤 벽이 Player-Package 사이에 들어와도 Hold가 계속 유지됨. 원인: 기존 감지·유지 로직이 거리/사거리만 검사하고 물리적 가시선(차단 여부)은 검사하지 않았음. **상태 `[REVIEW]` 유지.**
- 완료 근거(가시선 검사 추가): `Player.gd`에 `_has_line_of_sight_to()` 추가 — `_get_detected_package()`가 ShapeCast 후보를 확정하기 전에, 상호작용 기준점(`interact_shape_cast.global_position`)에서 후보 Package 중심까지 Ray Query(mask=World(1)+Package(4)+PhysicsObject(16)=21, Player 자신 exclude)를 수행해 첫 충돌이 그 Package 자신이 아니면(=벽 등이 먼저 막으면) 후보에서 제외한다. `_detected_package`가 매 프레임 이 결과로 갱신되므로 `_handle_interact_input()`은 코드 변경 없이 자동으로 차단된 대상을 무시한다. `Package.gd`에는 `_is_hold_path_blocked()`를 추가해 `_integrate_forces()`에서 기존 `max_hold_distance` 검사 다음 단계로 HoldPoint↔Package 중심 Ray Query(동일 mask 21, holder+자기 자신 exclude)를 매 물리 프레임 수행 — 연속 `_HOLD_BLOCKED_RELEASE_FRAMES=3` 프레임 차단되면 기존 공용 `release()` 경로를 그대로 호출(지연 collision 복구 로직 재사용, 우회·중복 없음), 가시선이 회복되면 차단 카운터를 0으로 리셋한다. 새 Collision Layer는 만들지 않고 기존 World/Package/PhysicsObject(T064) 레이어만 재사용했다. 헤드리스 자동 검증 33개 항목 전부 PASS: 벽 너머 Package 미감지·미잡기, 벽 없는 정상 상태 감지·잡기·놓기, 잡은 상태에서 벽이 끼어들 때 자동 Release(연속 3프레임 이상에서만), 자동 Release 후 계속 잡기 시도해도 벽 너머로 재잡기 안 됨, 벽 옆으로 이동해 가시선 회복 시 재잡기 정상, 3프레임 미만의 짧은 스침은 Release 안 됨, 기존 감지/잡기/유지/놓기/재잡기/던지기/`max_hold_distance` 자동 놓기/collision exception 지연 복구/배송/재시작-동등/환경 오브젝트 6개 전부 회귀 없음. `--headless --import`, `--headless --quit-after 60` 오류 0건.
- **사용자 수동 테스트 결과(2차, 최종): 승인.** 벽 물리 체감(Player 단독/오블리크/모서리, 놓인 Package, 잡은 Package, 벽 너머 잡기 차단, 차단 시 자동 Release, 재잡기 방지, 가시선 회복 후 재잡기, 기존 기능 회귀) 전체 승인됨.
- **완료 근거 요약**:
  - TestWall(`StaticBody3D`) 벽 지오메트리 추가 완료, 기존 World collision layer 재사용, 기존 계단·경사로·DeliveryZone·PhysicsObjects·배송 경로와 비간섭 확인
  - 벽 물리 안정성 자동 검증 전항목 PASS(관통·NaN·폭주 없음), 사용자 수동 테스트 승인 완료
  - 벽 관련 상호작용 버그 2건(벽 너머 잡기, 벽 너머 Hold 유지) 발견 → 물리적 가시선(Ray Query) 검사 추가로 수정, 자동 검증 및 사용자 재테스트 모두 승인
  - `docs/KNOWN_ISSUES.md` KI-001("벽에 물체가 걸렸을 때의 물리 안정성 미검증") 해소

## 18. T066 — Narrow Doorway Geometry and Traversal Validation

- 상태: `[x]` `[DONE]`
- 목적: `PrototypeLevel`에 정적인 좁은 문틀을 추가해 Player 단독/놓인 Package/잡은 Package가 좁은 통로를 통과·접촉·걸리는 상황에서 기존 물리·상호작용 로직(T065의 가시선 검사, Hold 차단 자동 Release 포함)이 안정적인지 검증한다. `docs/ROADMAP.md` EPIC-01의 FEATURE-01-C(좁은 문 추가)/FEATURE-01-D(좁은 문 통과 검증)에 대응.
- 소속: `docs/ROADMAP.md` v0.2.0 EPIC-01(Obstacle Course Expansion) — FEATURE-01-C, FEATURE-01-D
- 선행 작업: T065(벽 지오메트리+물리 안정성 검증+가시선 버그 수정, `[DONE]`)
- 작업 범위: `PrototypeLevel.tscn`의 `Environment` 아래 `NarrowDoorwayTestArea`(`LeftWall`/`RightWall`/`Lintel`, 모두 `StaticBody3D`) 추가, 기존 World collision layer 사용, 문 통과 시나리오 헤드리스 검증
- 제외 범위: 실제 문짝·문 애니메이션·문 열기 입력, `Player.gd`/`Package.gd` 핵심 로직 수정, Collision Layer 재설계, 새 스크립트/범용 시스템, 카메라 설정 변경, Package/Player 크기·HoldPoint 위치 변경
- 생성 파일: 없음
- 수정 파일: `hell-delivery/scenes/level/PrototypeLevel.tscn`(`NarrowDoorwayTestArea` 노드 및 관련 sub_resource 추가만)
- 에디터 수동 작업: 없음(`.tscn` 텍스트로 직접 작성, headless import/boot로 파싱 검증)
- 완료 조건: 문이 기존 계단·경사로·DeliveryZone·PhysicsObjects·TestWall·배송 경로와 간섭하지 않음, Player 단독(중앙/오블리크/좌우 문틀 접촉) 통과 시 관통·고착·NaN·비정상 속도 없음, 놓인 Package(밀기/정면충돌/모서리충돌) 시 관통·폭발적 가속 없음, 잡은 Package(중앙/좌우 문틀에 걸림)로 통과 시도 시 Player·Package 모두 안정, 차단·거리초과 시 Auto Release 정상, Auto Release 후 벽 너머 재잡기 차단·가시선 회복 후 재잡기 정상, 지연된 collision exception 복구 정상, 기존 MVP 기능·T064 환경 오브젝트·T065 벽/가시선 회귀 없음
- 테스트 방법: `godot --headless --import`, `--headless --quit-after`로 파싱/부팅 오류 확인, 임시 `SceneTree` 스크립트(검증 후 삭제)로 문틀 노드/collision 확인 + Player 단독 4개 시나리오(중앙 통과/오블리크 접근/좌측 문틀 접촉/우측 문틀 접촉) + 놓인 Package 3개 시나리오(밀기/정면 충돌/모서리 충돌) + 잡은 Package 5개 시나리오(중앙 통과/좌측 문틀 걸림/우측 문틀 걸림/TestWall Auto Release/재잡기 차단·회복) + 지연된 collision 복구 + 기존 기능·T064·T065 회귀(TestWall 유지, 가시선 차단, 이동/점프, Package 감지·잡기·놓기·던지기, 환경 오브젝트 6개, 배송·HUD, 재시작-동등, Physics Interpolation 설정) 자동 검증. 실제 문 통과 난이도 체감("조심하면 통과 가능한가")은 자동 검증 불가 — **사용자 수동 테스트 필요**.
- 예상 위험: 문 폭(clear width 1.4m)은 Player capsule(지름 1.0m)·Package(폭 0.8m) 실측 크기에서 상대적으로 추론해 결정한 값으로, T044/T061처럼 여러 후보값을 헤드리스로 비교 실측하지는 않았다 — 사용자 수동 테스트에서 "너무 쉽다"/"너무 빡빡하다"로 판단되면 조정이 필요할 수 있다.
- 완료 근거(구현): 실제 크기 조사 결과 — Player `CapsuleShape3D`(기본값, radius 0.5/height 2.0), Package `BoxShape3D`(0.8×0.6×0.8), `HoldPoint`는 `CameraPivot`의 자식으로 전방(-Z) 1.5m 오프셋, 기존 `TestWall`(6,2,-8)·`PhysicsObjects`(X≈-3 및 X≈3.7~4.9 두 구역)·Stairs(X≈10.1~16)·Ramp(-7.02,6)·DeliveryZone(5,0.5,3) 좌표를 전부 확인한 뒤, 빈 공간(Environment 그룹, X=-7 평면, Z≈-4.2~2.2, 문 중심 Z=-1)에 배치해 어떤 기존 지오메트리와도 간섭하지 않음을 확인. `NarrowDoorwayTestArea`는 `LeftWall`/`RightWall`(각 0.6×3×2.5, Z축을 따라 분리 배치)과 `Lintel`(0.6×0.8×1.4, 문 상단)로 구성해 clear width 1.4m·clear height 2.2m(바닥~문틀 사이 틈 없음)를 만들었다. 헤드리스 자동 검증 44개 항목 전부 PASS: 문틀 노드/타입/collision(World 레이어 유지, 스크립트 없음) 확인, Player 단독 중앙 통과 성공(문을 가로질러 반대편 도달) 및 오블리크·좌우 문틀 접촉 시나리오 모두 NaN·폭주 없음, 놓인 Package 밀기·정면충돌·모서리충돌 모두 NaN·폭발적 가속 없음, 잡은 Package로 중앙 통과 성공 및 좌우 문틀에 걸리는 상황 모두 Player·Package 안정, 기존 `TestWall`에서 Hold 경로 차단 시 Auto Release 정상 작동 및 벽 너머 재잡기 차단(가시선 검사, T065 재사용)·가시선 회복 후 재잡기 정상, 지연된 collision exception 복구 정상, 기존 이동/점프/Package 전 기능/환경 오브젝트 6개/배송·HUD/재시작-동등/Physics Interpolation 설정 전부 회귀 없음. `--headless --import`, `--headless --quit-after 60` 모두 오류·경고 0건.
- **사용자 수동 테스트 결과: 승인.** "좁은 문 통과 및 문틀 충돌 동작 정상", "Package 걸림 및 벽 차단 Auto Release 정상", "가시선 확보 후 재잡기 정상" 확인됨(T067의 Toggle 방식 적용 후 최종 조작으로 재검증 포함).

## 19. T067 — Package Interaction Toggle

- 상태: `[x]` `[DONE]`
- 목적: 기존 Hold 입력 방식(DD-001)을 Toggle 입력 방식으로 변경한다. 이동키(WASD)와 `E`를 동시에 계속 눌러야 하는 조작 부담을 완화하기 위한 사용자 승인 사항.
- 소속: `docs/ROADMAP.md` Epic 분해 외 추가 구현(T064·T066과 동일 성격 — 사용자가 직접 지정한 별도 범위)
- 선행 작업: T066(`[DONE]`, 이번 변경 후 최종 조작 방식으로 재검증 완료)
- 작업 범위: `Player.gd`의 `_handle_interact_input()`을 `E` `just_pressed` 엣지 기반 토글 로직으로 변경
- 제외 범위: `interact` Input Map 바인딩 변경, 새 입력 액션 추가, Package 물리 추종 방식, `HoldPoint` 위치, 기존 물리 파라미터, 가시선·Hold 차단 검사 로직, Toggle 전용 별도 상태 변수, 새 상태 머신/범용 Interaction 시스템
- 생성 파일: 없음
- 수정 파일: `hell-delivery/scenes/player/Player.gd`(`_handle_interact_input()` 함수 본문만 수정, 나머지 함수·export 변수·다른 스크립트 무변경)
- 에디터 수동 작업: 없음
- 완료 조건: `E` 한 번으로 잡기, 다시 눌러 놓기, `E`를 놓는 동작 자체는 무반응, 이동 중에도 `E`를 누르고 있지 않아도 정상 운반, 자동 Release(가시선 차단·`max_hold_distance`·`HoldPoint` 무효화) 이후 새 `E` `just_pressed` 없이는 재잡기되지 않음, 던지기 이후 새 `E`로 정상 재상호작용, 빠른 연속 `E` 입력에서도 참조·collision exception 오염 없음, 기존 회귀(이동/카메라/벽/좁은 문/계단/경사로/배송/HUD/재시작) 없음
- 테스트 방법: `godot --headless --import`, `--headless --quit-after`로 파싱/부팅 오류 확인, 임시 `SceneTree` 스크립트(검증 후 삭제)로 실제 `Input` 이벤트(`action_press`/`action_release`, 마우스 버튼 `InputEventMouseButton`)를 통해 사용자 요구 12개 시나리오(단일 `E` 잡기/놓기 무반응/이동 중 유지/두 번째 `E` 놓기/대상 없을 때 `E`/벽 너머 `E`/Hold 차단 자동 Release/자동 Release 후 재잡기 방지 및 가시선 회복 후 재잡기/`max_hold_distance` 자동 Release 후 재잡기 방지/던지기 연동/빠른 연속 `E`/전체 회귀) 자동 검증. 조작감 자체(토글 방식이 실제로 더 편한지)는 자동 검증 불가 — **사용자 수동 테스트 필요**.
- 예상 위험: 헤드리스 하네스에서 `E`를 빠르게 연속으로 누르는 시나리오는 idle 프레임과 물리 틱이 1:1로 대응하지 않아(기존에 문서화된 하네스 아티팩트) 입력 사이 간격이 너무 좁으면 엣지를 놓칠 수 있음을 발견 — 실제 게임 플레이(입력 사이 여러 렌더 프레임 간격이 자연히 존재)에는 영향 없는 테스트 환경 한정 이슈로 판단, 테스트 스크립트에 프레임 여유만 추가했다(게임 코드는 무변경).
- 완료 근거(구현): `Player.gd`의 `_handle_interact_input()`을 다음과 같이 변경 — 기존 유효성 정리 로직(잡은 대상이 무효화되면 `held_package = null`)은 유지, `Input.is_action_just_pressed("interact")`가 아니면 즉시 반환(놓는 동작에는 완전히 무반응), 이후 `held_package != null`이면 `release()` 후 참조 정리, 아니면(`elif`) `_detected_package`가 있을 때만 `grab()` 시도. `if/elif` 단일 분기 구조라 같은 입력 프레임에서 놓기와 잡기가 동시에 일어날 수 없어 "같은 입력으로 다른 대상을 즉시 재잡기하지 않음" 요구를 자연스럽게 만족한다. Toggle 전용 상태 변수는 추가하지 않았다 — 기존 `held_package`/`Package.is_held`가 곧 현재 상태다. `Package.gd`의 벽 차단·`max_hold_distance` 자동 Release 로직은 `E` 입력과 무관하게 동작하므로 전혀 수정하지 않았고, 자동 재잡기 방지는 토글 로직이 `is_action_just_pressed`(엣지)만 검사할 뿐 `is_action_pressed`(레벨 상태)를 검사하지 않기 때문에 별도 로직 없이 보장된다. 헤드리스 자동 검증 40개 항목 전부 PASS(단일 `E` 잡기·유지·이동 중 추종·두 번째 `E` 놓기, 대상 없을 때 무반응, 벽 너머 `E` 무반응, `TestWall` Hold 차단 자동 Release, 자동 Release 후 재잡기 방지(가시선 회복 전)와 가시선 회복 후 새 `E`로 재잡기 성공, `max_hold_distance` 자동 Release 후 재잡기 방지, 마우스 왼쪽 버튼 던지기 및 이후 새 `E` 재상호작용, 빠른 연속 6~7회 `E` 토글 정상 전환, 기존 이동/점프/좁은 문(T066)/벽(T065)/계단/경사로/환경 오브젝트 6개(T064)/배송·HUD/재시작-동등 전부 회귀 없음). `--headless --import`, `--headless --quit-after 60` 모두 오류·경고 0건.
- **사용자 수동 테스트 결과: 승인.** "E 한 번으로 잡기, 다시 E를 눌러 놓는 Toggle 방식 정상", "E에서 손을 떼어도 운반 유지", "자동 Release 이후 자동 재잡기 없음", "기존 던지기 및 배송 기능 정상" 확인됨.

## 20. T068 — Expanded Environment Physics Feel Tuning

- 상태: `[x]` `[DONE]`
- 목적: 확장된 테스트 환경(평지/계단/경사로/`TestWall`/`NarrowDoorway`/`PhysicsBarrel`/`PhysicsCrate`/`SmallPhysicsBox`)에서 현재 물리 수치가 안정적이고 조작하기 편한지 재검토한다. `docs/ROADMAP.md` EPIC-02(Physics Feel Tuning)의 FEATURE-02-A(충돌·밀기)/FEATURE-02-B(잡기·운반)/FEATURE-02-C(던지기)에 대응.
- 소속: `docs/ROADMAP.md` v0.2.0 EPIC-02(Physics Feel Tuning) — FEATURE-02-A, FEATURE-02-B, FEATURE-02-C
- 선행 작업: T066·T067(`[DONE]`, EPIC-01 완료)
- 작업 범위: 현재 물리값 조사, 확장 환경에서 충돌·밀기/잡기·운반/던지기 헤드리스 검증, 객관적으로 재현되는 문제 발견 시 최소 범위 수정
- 제외 범위: 새 기능 추가, 여러 값 동시 변경, 감각(주관적 판단) 기준의 값 변경, Toggle 상호작용을 Hold로 되돌리는 것, Physics Interpolation 설정 변경
- 생성 파일: 없음
- 수정 파일: `hell-delivery/scenes/package/Package.gd`(`max_follow_speed` export 값 1개만 수정)
- 에디터 수동 작업: 없음
- 완료 조건: 확장 환경 전체에서 관통·고착·NaN·비정상 속도·지속적 진동·정상 이동만으로 반복되는 Auto Release가 없음, 발견된 객관적 문제는 최소 범위로만 수정, 값 변경 없이 유지한 항목은 그 근거를 기록, 감각 판단이 필요한 항목은 사용자 수동 테스트로 남김
- 테스트 방법: `godot --headless --import`, `--headless --quit-after`로 파싱/부팅 오류 확인, 임시 `SceneTree` 스크립트(검증 후 삭제)로 충돌·밀기 8개 시나리오(평지 정면/오블리크 밀기, `TestWall`·`NarrowDoorway` 방향 밀기, Crate 5초 연속 밀기, Barrel 굴리기, SmallBox 밀기)/잡기·운반 6개 시나리오(스프린트 중 무동력 운반, 급격한 카메라 회전, 계단·경사로·좁은 문 통과, `TestWall` Auto Release)/던지기 5개 시나리오(수평/위쪽/스프린트 중/`TestWall` 방향/던진 뒤 재잡기)와 전체 회귀(기존 지오메트리·환경 오브젝트·배송·HUD·Physics Interpolation)를 자동 검증. 물리 파라미터는 각 씬/스크립트에서 직접 읽어 문서 서술보다 우선 확인. 조작감(빠름/적당함/과함 등 주관적 판단)은 자동 검증 대상이 아님 — **사용자 수동 테스트 필요**.
- 예상 위험: 헤드리스 하네스의 idle-프레임/물리-틱 비정렬 특성상, 고정된 프레임 수로 장거리 이동을 가정한 테스트는 실제로는 맵 경계 밖으로 나가거나 의도한 지점에 도달하지 못할 수 있음을 재확인 — 위치 기반 종료 조건(목표 좌표 도달 또는 프레임 상한)으로 테스트를 설계해 우회함(게임 코드와 무관, 테스트 방법론 문제).
- 완료 근거(조사 및 검증): 현재 값 전수 조사 — Player(`walk_speed=4.0`, `sprint_speed=7.0`, `acceleration=20.0`, `deceleration=25.0`, `push_force=220.0`, `max_push_speed=2.0`, `throw_impulse_strength=200.0`, `safe_margin=0.08`), Package Hold(`follow_strength=8.0`, `max_follow_speed`, `follow_acceleration=40.0`, `max_hold_distance=3.0`, Hold 차단 유예 3프레임), Package Throw(`throw_impulse_strength` 재사용, 방향은 `-camera_pivot.basis.z` 정규화, 위쪽 보정 없음, 던지기는 `release()`를 경유해 기존 collision exception 지연 복구 로직을 그대로 재사용). 헤드리스 자동 검증 34개 항목 실행 — **객관적으로 재현되는 문제 1건 발견**: `max_follow_speed`(기존 6.0)가 `sprint_speed`(7.0)보다 낮아, 장애물 없이 순수하게 직선으로 스프린트만 지속해도 HoldPoint와 Package 사이 거리가 계속 벌어지다 `max_hold_distance`(3.0)를 초과해 **정상 이동만으로 Auto Release가 발생**함을 확인(약 18m 직선 스프린트 구간에서 최대 지연 거리 3.16~3.21m 관측, 3.0 초과). 이는 섹션 8의 "정상 이동만으로 반복되는 Auto Release" 허용 조건에 해당하는 객관적 문제로 판단해, 문제와 직접 관련된 값 하나만 수정: `max_follow_speed`를 `sprint_speed`를 웃도는 최소값인 **6.0 → 7.5**로 조정. 재검증 결과 동일한 약 18m 직선 스프린트 구간에서 최대 지연 거리가 1.02m로 감소했고, Auto Release가 더 이상 발생하지 않음을 확인. 이 외의 검증(충돌·밀기 8종, 계단/경사로/좁은 문/`TestWall` 운반, 던지기 5종, 회귀)은 전부 PASS — 추가로 발견된 객관적 문제 없음, 나머지 값은 전부 유지. `--headless --import` 오류 0건, `--headless --quit-after 60`(2회 실행) 및 헤드리스 스크립트 재실행 모두 결과 안정적(0건 실패 재현).
- **사용자 수동 테스트 결과: 승인.** "현재 밀기·잡기·운반·던지기 감각에 별도의 문제나 수치 조정 필요성이 없다"고 판단, `max_follow_speed=7.5`(T068에서 수정된 값) 포함 현재 물리값 전체를 그대로 유지하기로 승인함. 이번 승인으로 추가 값 변경은 없었음.

## 21. T069 — Multi-Package Stability Validation

- 상태: `[x]` `[DONE]`
- 목적: 싱글 Package 기준으로 구현된 잡기·물리·배송 시스템이 여러 Package가 동시에 존재할 때도 안정적으로 동작하는지 확인한다. `docs/ROADMAP.md` EPIC-03(Multi-Package Stability)의 FEATURE-03-A(2~3개 배치)/FEATURE-03-B(충돌·적재 안정성)/FEATURE-03-C(순차 배송 검증)에 대응.
- 소속: `docs/ROADMAP.md` v0.2.0 EPIC-03(Multi-Package Stability) — FEATURE-03-A, FEATURE-03-B, FEATURE-03-C
- 선행 작업: T068(`[DONE]`, EPIC-02 완료)
- 작업 범위: `PrototypeLevel.tscn`의 `Gameplay`에 `PackageB`/`PackageC` 인스턴스 추가(기존 `Package`는 유지), 다수 Package 감지·잡기·물리·순차 배송 헤드리스 검증
- 제외 범위: 배송 개수 목표, 미션/점수/카운터 시스템, Package별 ID·목적지·완료 UI, Package Manager/Spawn Manager, `DeliveryZone`의 최초 1회 성공 규칙 변경, 새 Input Map, 기존 Package 크기·물리 파라미터 변경
- 생성 파일: 없음
- 수정 파일: `hell-delivery/scenes/level/PrototypeLevel.tscn`(`PackageB`/`PackageC` 인스턴스 2개 추가만)
- 에디터 수동 작업: 없음
- 완료 조건: 세 Package가 초기에 서로 겹치지 않음, 여러 후보가 감지 범위 안에 있어도 실제로 막히지 않은(가시선 확보된) 대상만 정확히 선택됨, 잡은 Package 외 다른 Package와는 정상적으로 물리 충돌함, 나란히 배치/2단/3단 적층/충돌/붕괴/벽 샌드윙치/좁은 문 인근/Barrel 충돌 상황에서 관통·NaN·폭발적 속도·지속 진동 없음, 하나를 놓거나 던져도 다른 Package 상태가 오염되지 않음, 홀드 중 다른 Package에 E를 눌러도 참조가 교체되지 않음, 여러 Package를 순서대로 배송해도 성공 시그널·HUD가 중복 실행되지 않음, Restart 시 세 Package 모두 초기 위치로 복구, 기존 MVP 기능·T064~T068 회귀 없음
- 테스트 방법: `godot --headless --import`, `--headless --quit-after`로 파싱/부팅 오류 확인, 임시 `SceneTree` 스크립트(검증 후 삭제)로 구조·그룹·collision 일치성/초기 비겹침/정지 안정성(9개 항목), 감지·잡기(단일 대상, 두 대상 중 가까운 쪽만 감지·가려진 대상 자동 배제·치운 뒤 재감지, 홀드 중 다른 대상에 E를 눌러도 교체되지 않음, 5개 시나리오), 물리 안정성(나란히 배치, 2단 적층, 3단 적층, 하단을 밀어 붕괴, 다른 더미로 던지기, 하나를 잡은 채 다른 것과 충돌, TestWall 샌드위치, NarrowDoorway 인근, Barrel 충돌, 9개 시나리오), 순차 배송(첫 Package 성공 시 시그널 1회, 이후 Package 진입 시 재발화 없음, 2회 확인), Restart-동등(완전히 새 씬 인스턴스에서 3개 모두 초기 위치·미배송 상태로 복구) 및 기존 기능 회귀를 자동 검증.
- 예상 위험: 헤드리스 테스트 중 이전 씬 인스턴스를 완전히 해제하지 않고 새 인스턴스를 만들면(실제 `reload_current_scene()`과 달리) 두 씬이 동일한 물리 공간을 공유해 좌표가 같은 `DeliveryZone`끼리 서로의 Package를 잘못 감지하는 테스트 아티팩트를 발견 — 실제 재시작은 이전 씬을 완전히 제거하므로 재현되지 않음, 테스트에서는 새 인스턴스 생성 전 이전 씬을 명시적으로 해제해 우회함(게임 코드와 무관).
- 완료 근거(구현 및 검증): `PrototypeLevel.tscn` `Gameplay`에 `PackageB`(2.5,1,-2.5)·`PackageC`(-4.5,1,-1) 추가(기존 `Package`는 2.5,1,0 그대로 유지, 세 위치 모두 서로 1.0m 이상 이격, DeliveryZone·PhysicsObjects·기존 배송 경로와 비간섭). `Package.gd`/`Player.gd`/`DeliveryZone.gd` 모두 무수정 — 검증 과정에서 실제 다수 Package 버그가 발견되지 않았다. 핵심 발견: 기존 T065 가시선 검사(`_INTERACT_LOS_MASK`)가 World(1)+Package(4)+PhysicsObject(16)를 포함해, 가려진 뒤 Package를 향한 Ray Query가 앞 Package에 먼저 막혀 자동으로 실패하는 구조라 "가장 가까운/보이는 대상만 감지"가 코드 변경 없이 이미 성립했다. Toggle 로직(`if held_package != null: release() / elif`)도 같은 입력에서 놓기와 잡기가 동시에 발생하지 않는 구조라 "홀드 중 다른 대상에 E를 눌러도 교체되지 않음"이 이미 보장되었다. `DeliveryZone.gd`의 최초 1회 판정도 Package 개수와 무관하게 그대로 동작한다. 헤드리스 자동 검증 55개 항목 전부 PASS: 구조/그룹/collision 일치, 초기 비겹침, 정지 안정성, 단일·복수 대상 감지(가까운 것 우선, 가려진 것 배제, 치운 뒤 재감지), 홀드 중 교체 방지, 나란히 배치·2단·3단 적층(수직 순서 유지)·붕괴·더미로 던지기·홀드 중 비홀드 대상과 충돌·벽 샌드위치·좁은 문 인근·Barrel 충돌 전부 NaN·관통·폭발적 속도 없음, 순차 배송 3회(B→C→A) 모두 성공 시그널 정확히 1회만 발화, Restart-동등 시 세 Package 모두 초기 위치(X/Z 정확히 일치, Y는 정지 상태 미세 오차 이내)로 복구 및 미배송 상태 확인, 기존 TestWall·NarrowDoorway·환경 오브젝트 6개 전부 유지. `--headless --import`, `--headless --quit-after 60` 오류·경고 0건.
- **사용자 수동 테스트 결과: 승인.** 세 Package 각각 잡고 놓기, 앞뒤 Package 중 앞만 잡힘, 적층 붕괴, 홀드 중 다른 Package와 충돌, 더미로 던지기, 임의의 Package 배송 및 나머지 진입 시 중복 성공 없음, Restart 후 3개 복구 모두 확인됨.

## 22. T070 — Final Playtest and Fun Validation

- 상태: `[BLOCKED]` (T072 완료로 잠시 해제되었다가, T073 착수로 재차단)
- **차단 이력**: 선행 조건이던 EPIC-05(Generalized Object Interaction)가 T072(Force-Based Physics Grab) 및 두 차례의 Player 밀림/관통 결함 수정을 거쳐 사용자 수동 테스트 승인을 받아 완료되면서 한 차례 `[BLOCKED]`가 해제되었다(섹션 24 "T072 사용자 수동 테스트 승인(최종)" 참고). 그러나 곧이어 사용자 지시로 T073(1인칭 시점 전환 및 Grab 조작성 개선)이 착수되어 조작·시점 자체가 다시 바뀌므로, T073이 사용자 승인을 받기 전까지는 최종 재미 평가를 진행할 수 없어 `[BLOCKED]`로 되돌렸다(섹션 25 참고). T073 승인 후 재개하며, 그때 아래 평가 항목도 필요 시 다시 검토한다.
- 목적: "Package를 직접 잡고 운반하며 물리적 사고를 수습하는 행동이 재미있는가?"라는 핵심 질문에 사용자의 실제 플레이 결과로 답한다. `docs/ROADMAP.md` EPIC-04(Playtest & Fun Validation)의 FEATURE-04-A(확장된 전체 루프 플레이 테스트)/FEATURE-04-B(재미 판정 및 로드맵 재검토 여부 결정)에 대응.
- 소속: `docs/ROADMAP.md` v0.2.0 EPIC-04(Playtest & Fun Validation) — FEATURE-04-A, FEATURE-04-B
- 선행 작업: T069(`[DONE]`, EPIC-01~03 전부 완료), EPIC-05/T072(`[DONE]`, 사용자 승인 완료)
- 작업 범위: 실제 씬 좌표 기준 전체 루프 플레이 경로 작성, 현재 조작 방식(좌클릭 Hold + Force-Based Grab, T072)에 맞춘 평가 항목 12개 작성, 경량 자동 점검(구조 존재 확인)만 수행
- 제외 범위: 게임 코드·씬·물리값 수정, 새 기능 구현, 대규모 회귀 스크립트, Claude에 의한 재미 판정(반드시 사용자 응답 근거)
- 생성 파일: 없음
- 수정 파일: 없음(코드/씬 무변경, 이번 문서 갱신만)
- 에디터 수동 작업: 사용자가 직접 플레이(Claude 대행 불가)
- 완료 조건: 사용자가 전체 루프 플레이를 완료하고 아래 평가 항목 12개에 답변, 그 응답을 근거로 PASS/PASS WITH NOTES/FAIL 중 하나로 판정
- 테스트 방법: `godot --headless --import`, `--headless --quit-after`로 파싱/부팅 오류 확인, 임시 스크립트(검증 후 삭제)로 Player/Package 3개/TestWall/NarrowDoorwayTestArea/PhysicsObjects 6개/DeliveryZone/DeliveryHUD 존재와 Physics Interpolation 활성화만 경량 점검(대규모 회귀 스크립트 미작성). 재미 여부는 자동 검증 대상이 아님 — **사용자 실제 플레이 결과 필요**.
- 예상 위험: 낮음(코드 변경 없음). 유일한 위험은 판정 자체가 100% 사용자 응답에 의존한다는 점 — 응답이 오기 전까지 EPIC-04와 v0.2.0을 완료 처리할 수 없다.
- 완료 근거(준비 단계): 실제 씬 좌표를 기준으로 전체 루프 경로를 작성했다(Spawn(0,1.5,0) → Package/환경 오브젝트 밀집 구역 → Stairs(X10.1~16) → Ramp(-7.02,6) → NarrowDoorway(X=-7, gap Z -1.7~-0.3) → TestWall(6,2,-8) → 던지기 → DeliveryZone(5,0.5,3) → Restart). 경량 자동 점검 10개 항목 전부 PASS(`--headless --import`, `--headless --quit-after 60` 오류 0건). 대규모 회귀 스크립트는 작성하지 않았다(T069까지 이미 충분히 검증됨, 이번 Task는 재미 판정이 목적). 코드·씬·물리값은 전혀 수정하지 않았다.
- **평가 항목(T072 최종 조작 방식 기준으로 갱신, 각 항목 1~5점 + 자유 코멘트)**:
  1. 좌클릭 Hold Grab과 Release가 직관적인가
  2. SmallBox, Package, Barrel, Crate의 무게감 차이가 잘 느껴지는가
  3. 중앙과 모서리를 잡았을 때 회전 차이(torque)가 자연스러운가
  4. 느린 이동과 빠른 카메라 스윙 모두에서 물체 반응이 자연스러운가
  5. Release 후 운동량이 자연스럽게 유지되는가(별도 Throw 없이도 만족스러운가)
  6. Player 관통이나 Player가 밀리는 현상이 없는가
  7. 잡은 물체로 다른 물체를 밀 때 감각이 적절한가(무한한 힘처럼 느껴지지 않는가)
  8. 좁은 문, 벽, 계단, 경사로를 물체를 든 채로 통과하기 편한가
  9. 여러 Package를 동시에/순차적으로 운반하기 불편함이 없는가
  10. Package를 DeliveryZone에 배송하는 흐름이 매끄러운가
  11. Restart 이후 Grab과 배송이 다시 정상 동작하는가
  12. 전체 플레이 흐름이 재미있는가, 불편하거나 어색한 지점은 무엇인가(자유 서술)
  - 평가 양식: 각 항목 1~5점(1=매우 불만족, 5=매우 만족) + 필요 시 한 줄 코멘트. 12번은 자유 서술.
  - 플레이 경로: 위 완료 근거(준비 단계)의 좌표 경로를 그대로 사용한다(Spawn → 환경 오브젝트 밀집 구역 → Stairs → Ramp → NarrowDoorway → TestWall → DeliveryZone → Restart 후 재검증).

## 23. T071 — Generalized Grabbable Objects, Swing Release, Mass-Consistent Carrying

- **T072에서 후속 대체됨**: 사용자 승인 전(REVIEW 상태) 단계에서, 아래 서술된 속도 추종(`move_toward` 기반 HoldPoint 추종) + 스윙 릴리즈 impulse 방식은 T072(Force-Based Physics Grab)에서 Spring-Damper 힘 기반 방식으로 전면 대체되었다. 이 절의 내용은 당시 구현 이력으로 그대로 남겨 두고, 실제 현재 동작은 섹션 24(T072)를 기준으로 한다. T071에서 도입한 범용 `GrabbableBody` 클래스 구조·4종 오브젝트 공용화·`E` 완전 분리·정적/동적 충돌 분리 원칙 자체는 T072에서도 그대로 유지된다.
- 상태: `[x]` `[DONE]` (과거 구현으로 종료 — 사용자 승인(REVIEW 단계) 전 T072가 이동 방식을 전면 대체했고, T072가 사용자 수동 테스트 승인을 받아 완료되었다. 이 문서 체계에는 별도 `SUPERSEDED` 상태가 없어(섹션 "작업별 작성 형식" 참고) T071은 완료된 과거 구현 이력으로 닫는다 — **실제 현재 동작 기준은 섹션 24(T072)뿐이다.**)
- 목적: Package 전용으로 구현되어 있던 잡기·이동·놓기 구조를 `GrabbableBody` 범용 클래스로 확장해 PhysicsBarrel/PhysicsCrate/SmallPhysicsBox도 잡을 수 있게 하고, 질량 기반 이동 속도, 좌클릭 Hold 방식, 카메라 스윙 기반 릴리즈, `E` 상호작용 완전 분리, 동적/정적 충돌 Hold 안정성 개선을 구현한다. 사용자 플레이 피드백(고정 Throw 어색함, 잡은 Package가 Crate를 비현실적으로 쉽게 밈, 동적 오브젝트 접촉만으로 Release되는 문제)에 따른 재설계.
- 소속: `docs/ROADMAP.md` v0.2.0 EPIC-05(Generalized Object Interaction, 신규) — EPIC-04(Playtest & Fun Validation) 착수 전 선행 조건으로 편입
- 선행 작업: T069(`[DONE]`), T070(`[BLOCKED]`, T071 완료 후 재개)
- 작업 범위: `GrabbableBody.gd` 신규(잡기/놓기/자동 놓기/HoldPoint 추종/스윙 릴리즈/충돌 예외/지연 복구 전체 소유), `Package.gd`를 `GrabbableBody` 상속으로 축소, PhysicsBarrel/Crate/SmallBox에 스크립트·`grabbable` 그룹 추가, `Player.gd` 상호작용 입력 전면 재작성(좌클릭 Hold, `GrabShapeCast` 개명, `E` 완전 분리), `project.godot` Input Map(`grab_object` 추가, `throw_package` 제거)
- 제외 범위: 대규모 구조 재작성/재구성, 저장·네트워크 구조, `DeliveryZone` 판정 규칙 변경, Collision Layer 전체 재설계, Grabbable/Interaction/Carry Manager, Autoload, 실제 버튼·문·레버 구현
- 생성 파일: `hell-delivery/scenes/objects/GrabbableBody.gd`
- 수정 파일: `hell-delivery/scenes/package/Package.gd`, `hell-delivery/scenes/package/Package.tscn`(groups), `hell-delivery/scenes/objects/PhysicsBarrel.tscn`, `hell-delivery/scenes/objects/PhysicsCrate.tscn`, `hell-delivery/scenes/objects/SmallPhysicsBox.tscn`(스크립트+groups 추가), `hell-delivery/scenes/player/Player.gd`, `hell-delivery/scenes/player/Player.tscn`(`GrabShapeCast` 개명, mask 4→20), `hell-delivery/project.godot`(Input Map)
- 에디터 수동 작업: 없음(전부 텍스트 편집, headless import/boot로 검증)
- 완료 조건: Package 외 3종도 정상 잡기/이동/놓기, 질량이 무거울수록 이동·스윙 반응이 느림(SmallBox>Package>Barrel>Crate 순서 실측 확인), 동적 오브젝트 접촉만으로는 Release되지 않고 정적 World 장애물에서만 Auto Release, 스윙 릴리즈가 카메라 회전 속도에 비례(정지 릴리즈는 거의 추가 속도 없음), Auto Release에는 스윙 impulse 미적용, `E`는 Grabbable 상태에 전혀 영향 없음, `DeliveryZone`은 Package만 성공, 기존 MVP·T064~T069 기능 회귀 없음
- 테스트 방법: `godot --headless --import`, `--headless --quit-after`로 파싱/부팅 오류 확인, 임시 `SceneTree` 스크립트(검증 후 삭제)로 구조(9)/Input Map(3)/4종 오브젝트 잡기-이동-놓기-재잡기(20)/질량 기반 이동 순서(1)/동적 충돌 비차단(3)/정적 차단 Auto Release 및 재잡기 방지(4)/스윙 릴리즈 5종 시나리오+무게별 순서+Auto Release 무임펄스(9)/몸 대 held object 밀기 일관성(4)/배송 Package 전용(4)/회귀(7) 총 60개 이상 항목 자동 검증.
- 예상 위험: 헤드리스 하네스에서 여러 오브젝트를 같은 테스트 차선에 반복 배치하면 이전 오브젝트가 남아 물리적으로 겹쳐 ShapeCast 감지가 꼬이는 테스트 아티팩트, 그리고 장시간 스크립트 뒤쪽에서 시뮬레이션된 클릭 엣지가 간헐적으로 유실되는 아티팩트를 발견 — 둘 다 테스트 스크립트에서 오브젝트를 매번 먼 곳으로 격리시키고 일부 검증은 `grab()` API를 직접 호출하는 방식으로 우회했다(게임 코드와 무관, 테스트 방법론 문제). 스윙 릴리즈의 정확한 게인(`_SWING_IMPULSE_GAIN=8.0`, `_MAX_SWING_SPEED=12.0`)과 `max_carry_force=600.0`은 실측 후보 비교가 아닌 기존 Package 값에서 역산한 초기값으로, 사용자 수동 테스트 후 조정이 필요할 수 있다.
- 완료 근거(구현 및 검증): `GrabbableBody.gd`(`class_name GrabbableBody extends RigidBody3D`)를 신설해 `grab()`/`release(apply_swing)`/HoldPoint 추종/`max_hold_distance` 자동 놓기/holder collision exception/지연된 충돌 복구를 전부 이관하고, 질량 기반 추종(`effective_acceleration = max_carry_force / mass`, 공유 `max_carry_force=600.0`을 기존 Package `follow_acceleration(40.0)×mass(15.0)`에서 역산해 Package 체감을 그대로 보존)과 스윙 릴리즈(최근 HoldPoint 위치를 지수평활로 추적해 `_rotational_hold_velocity` 산출, holder 자신의 이동 속도는 차감해 중복 가산 방지, release 시 기존 `linear_velocity`는 보존한 채 측정된 스윙 속도만큼만 순수 가산 impulse 적용 — 질량으로 나누지 않아 무거운 물체일수록 동일 impulse에서 속도 변화가 자연히 작음)를 추가했다. Hold 차단 판정(`_is_hold_path_blocked`)의 마스크를 기존 World+Package+PhysicsObject(21)에서 **World만(1)**으로 좁혀, 동적 Grabbable끼리의 접촉이 더 이상 Auto Release를 유발하지 않게 했다(사용자가 지적한 핵심 버그 수정). `Package.gd`는 `class_name Package extends GrabbableBody` 두 줄로 축소되고 `package`/`grabbable` 그룹만 씬에서 유지, PhysicsBarrel/Crate/SmallBox는 `GrabbableBody.gd`를 스크립트로 붙이고 `grabbable` 그룹을 추가했다(물리 파라미터·collision layer/mask는 전부 무변경). `Player.gd`는 `interact_shape_cast`를 `grab_shape_cast`(`GrabShapeCast`, mask 4→20=Package|PhysicsObject)로 개명하고, 감지 로직을 "가장 가까운 LOS 확보 후보 우선"으로 일반화했으며, `_handle_interact_input()`을 제거하고 `_handle_grab_input()`(좌클릭 `just_pressed`=잡기, `just_released`=수동 release+스윙)으로 교체, `_handle_throw_input()`과 `throw_impulse_strength`를 완전히 삭제했다. `E`(`interact`)는 코드 경로에서 완전히 분리되어 아무 동작도 하지 않는다(향후 버튼/문/레버용으로 예약, 주석으로 명시). `project.godot`에 `grab_object`(좌클릭) 액션을 추가하고 `throw_package` 액션은 삭제했다. `DeliveryZone.gd`는 무수정(여전히 `package` 그룹만 성공 판정). 헤드리스 자동 검증 60개 이상 항목 3회 연속 실행 전부 PASS(0건 실패, 안정적 재현 확인): 4종 오브젝트 감지·잡기·이동·놓기·재잡기, 질량 순서(SmallBox>Package>Barrel>Crate, horizontal-only 측정), 동적 접촉 비차단, 정적 벽 차단 Auto Release(스윙 무임펄스, 재잡기 방지, 가시선 회복 후 재잡기), 스윙 릴리즈(정지 시 거의 무속도, 빠른 회전>느린 회전, 무게 역순 비행 속도), 몸 밀기 대 held object 밀기 일관성(둘 다 안정적, 후자가 비정상적으로 강하지 않음), 배송 Package 전용, 기존 계단·경사로·좁은 문·벽·HUD·Physics Interpolation·재시작-동등 전부 회귀 없음. `--headless --import`, `--headless --quit-after 60` 오류·경고 0건. 물리 체감(무게감, 스윙 던지기 손맛 등)은 자동 검증 불가 — 사용자 수동 확인 대기 중이며 승인 전에는 `[DONE]`으로 표시하지 않는다.

## 24. T072 — Force-Based Physics Grab

- 상태: `[x]` `[DONE]` (구현·자동 검증·사용자 수동 테스트 승인 모두 완료 — 아래 "T072 사용자 수동 테스트 승인(최종)" 참고)
- 목적: T071에서 구현한 범용 `GrabbableBody` 구조는 유지하되, 물체 운반 방식을 `move_toward()` 기반 속도 강제 추종에서 **실제 Grab Point에 제한된 힘(Spring-Damper)을 가하는 방식**으로 전환한다. 플레이어는 물체의 위치나 속도를 직접 제어하지 않고, 잡은 표면 지점에 물리적으로 힘만 가한다. 사용자 지시(design philosophy: "플레이어의 손이 물체의 실제 잡힌 지점에 제한된 힘을 지속적으로 가한다")에 따른 재설계이며, 향후 멀티플레이 협동 운반(여러 명이 한 물체를 동시에 잡아 힘이 합산되는 구조)의 물리적 기반을 겸한다.
- 소속: `docs/ROADMAP.md` v0.2.0 EPIC-05(Generalized Object Interaction) — T071의 FEATURE-05-B(질량 기반 이동)·FEATURE-05-C(좌클릭 Hold 이동)·FEATURE-05-D(카메라 스윙 기반 릴리즈)·FEATURE-05-F(동적/정적 충돌 Hold 안정성)를 대체하는 신규 FEATURE-05-H(Force-Based Physics Grab)로 편입
- 선행 작업: T071(`[REVIEW]`, 범용 `GrabbableBody` 구조·4종 오브젝트 공용화·`E` 분리는 그대로 승계, 내부 이동 방식만 대체)
- 작업 범위: `GrabbableBody.gd` 전면 재작성(단일 holder → 다중 Grab Connection 구조, `move_toward` 속도 추종·스윙 impulse·Player collision exception 제거, 실제 Grab Point에 `apply_force()` 적용), `Player.gd`의 그랩 입력 로직 수정(클릭 표면 충돌 지점 캡처, `add_grabber`/`remove_grabber` 호출로 전환)
- 제외 범위: 실제 멀티플레이·네트워크 구현(물리 구조만 다중 Grabber를 전제로 준비), `DeliveryZone` 판정 규칙 변경, Collision Layer 전체 재설계, Input Map 변경(기존 `grab_object`/`interact` 그대로 재사용), `PrototypeLevel.tscn` 좌표 변경, Grabbable/Interaction/Carry Manager, Autoload, 실제 버튼·문·레버 구현
- 생성 파일: 없음
- 수정 파일: `hell-delivery/scenes/objects/GrabbableBody.gd`(전면 재작성), `hell-delivery/scenes/player/Player.gd`(`_update_grab_detection()`이 실제 충돌 지점도 함께 기록, `_handle_grab_input()`이 `add_grabber`/`remove_grabber` 호출로 전환)
- 에디터 수동 작업: 없음(전부 텍스트 편집, headless import/boot로 검증)
- 완료 조건: 물체가 항상 정상 `RigidBody3D`로 gravity/mass/충돌 영향을 그대로 받음, 위치·Transform·`linear_velocity` 직접 변경 없음, 실제 클릭 표면 지점(`local_grab_point`)에 `apply_force()` 적용, Grab Point가 무게중심에서 벗어나면 torque 발생, Grabber별 힘 상한 존재 및 여러 Grabber의 힘이 독립 계산 후 합산 적용, Player collision exception 없이도 관통 없음, 동적 물체 접촉만으로 Release 안 됨(정적 World 장애물에서만), 한 Grabber 조건에서 SmallBox>Package>Barrel>Crate 순서로 운반 난이도 성립, 2 Grabber가 1 Grabber보다 Crate를 더 빠르게 들어올림, 마지막 연결 해제 시 현재 운동량 유지(별도 impulse 없음), `DeliveryZone`은 Package 전용 유지, 기존 MVP·T064~T071 기능 회귀 없음
- 테스트 방법: `godot --headless --import`, `--headless --quit-after`로 파싱/부팅 오류 확인, 임시 `SceneTree` 스크립트(검증 후 삭제)로 구조(다중 Connection·중복 연결 거부·그룹 유지, 9개)/Force 처리(텔레포트 없음·점진적 힘 적용·gravity 유지, 5개)/Torque(무게중심 대조군, 모서리 실험군, 2개)/Player 충돌(collision exception 없음, 3초 연속 접근·좌우 스윙 시 관통 없음, 6개)/동적 접촉 비차단·정적 차단 자동 해제(4개)/질량 순서(1 Grabber 조건 SmallBox·Package·Barrel·Crate 초기 상승 속도 비교, 8개)/다중 Grabber(Crate 1인 vs 2인 비교, 한쪽 연결 해제 후 유지, 마지막 해제 시 운동량 보존, 6개)/회귀(좌클릭 Grab/Release, E 무동작, 벽 너머 차단, 가까운 대상 우선, Barrel 그랩, 배송 Package 전용, 이동, Physics Interpolation, Restart-동등, 11개) 총 59개 항목 자동 검증.
- 예상 위험: `grab_spring_strength`(500.0)·`grab_damping`(60.0)·`max_force_per_grabber`(300.0)는 여러 후보를 실측 비교한 값이 아니라, 각 오브젝트의 실제 mass×gravity(중력 저항력)를 기준으로 "한 명이 Crate를 들면 겨우 버티는 수준(무게 245N에 여유힘 55N)", "두 명이면 확실히 빠름(합산 600N, 여유힘 355N)"이 되도록 역산한 초기값이다. 자동 검증으로 "무게 순서가 올바른가", "관통·NaN·폭주가 없는가", "2인 협동이 실제로 더 빠른가"까지는 확인했지만 "손맛"은 자동 검증 불가 — 사용자 수동 테스트 후 조정이 필요할 수 있다. 헤드리스 하네스에서 `Input.action_press()`가 실제 `is_action_just_pressed()`로 반영되기까지 1프레임 지연이 있는 아티팩트를 새로 발견(테스트 스크립트에 "상태가 바뀔 때까지 최대 N프레임 대기" 헬퍼를 추가해 우회, 게임 코드와 무관).
- 완료 근거(구현): `GrabbableBody.gd`를 전면 재작성했다. 기존 `holder`/`hold_point`/`is_held`/`follow_strength`/`max_follow_speed`/`max_carry_force`/`_rotational_hold_velocity`/`_apply_swing_release_impulse()`/`_pending_collision_restore` 등 속도 추종·스윙 임펄스·collision exception 복구 관련 필드·함수를 전부 삭제했다. 새 구조: `grab_connections: Dictionary`(Node3D grabber → `_GrabConnection`, 각 연결이 `grabber`/`target_point`/`local_grab_point`/`max_force`/`prev_target_position`/`smoothed_target_velocity`/`block_streak`를 개별 보유)로 다중 Grabber를 전제한다. `add_grabber(grabber, target_point, world_grab_position)`은 클릭 시점의 실제 월드 충돌 지점을 `to_local()`로 물체 로컬 좌표(`local_grab_point`)로 변환해 저장하고, 같은 Grabber의 중복 연결은 거부한다. `remove_grabber(grabber)`는 `linear_velocity`/`angular_velocity`를 전혀 건드리지 않고 Dictionary에서 제거만 하므로, 놓는 순간 물체는 Spring-Damper 힘이 이미 만들어 둔 운동량을 그대로 유지한다(별도 release impulse 완전히 제거). `_integrate_forces()`에서 각 연결마다: 매 프레임 `to_global(local_grab_point)`로 현재 Grab Point의 월드 위치를 재계산(텔레포트 없이 물체가 움직인 만큼 자동 추적)하고, `displacement = to_target.limit_length(max_spring_distance)`, `grab_point_velocity = linear_velocity + angular_velocity.cross(offset)`(회전을 포함한 실제 Grab Point 속도), `relative_velocity = smoothed_target_velocity - grab_point_velocity`로 `desired_force = displacement*grab_spring_strength + relative_velocity*grab_damping`를 계산한 뒤 `limit_length(max_force_per_grabber)`로 Grabber 1명분 힘 상한을 적용하고 `state.apply_force(force, offset)`으로 실제 Grab Point(무게중심에서 벗어난 오프셋)에 힘을 가한다. `apply_force()`의 `position` 인자가 로컬이 아닌 무게중심 기준 글로벌 오프셋이라는 점을 실제 헤드리스 실측으로 확인했고(`state.center_of_mass`가 실제로는 로컬 좌표를 반환한다는 것도 실측으로 발견해 대신 `state.transform.origin`을 사용— 모든 Grabbable이 원점 대칭 단일 Shape라 두 값이 항상 일치함), 이 오프셋 덕분에 모서리를 잡으면 자연스럽게 torque(회전)가 발생한다. 정적 장애물 차단(`_is_connection_path_blocked`)은 연결별로 HandPoint→Grab Point Ray Query(mask=World만)를 수행해 연속 3프레임 이상 차단되면 그 연결만 해제하고, 거리 초과(`max_grab_distance`, 기존 `max_hold_distance` 3.0 값 승계)도 연결별로 개별 판정한다 — 여러 Grabber 중 하나만 막히거나 멀어져도 다른 연결은 영향받지 않는다. Player collision exception 관련 코드(`add_collision_exception_with`/`remove_collision_exception_with`/지연 복구 로직)를 전부 삭제했다 — 이제 Grab 중에도 물체와 Player가 항상 정상 충돌한다. `Player.gd`는 `_update_grab_detection()`이 `GrabShapeCast.get_collision_point(i)`로 실제 충돌 표면 지점을 함께 기록하도록 수정했고(감지 로직·가시선 검사·"가까운 대상 우선" 로직 자체는 T065/T071에서 이미 검증된 것을 그대로 재사용), `_handle_grab_input()`은 `grab()`/`release()` 대신 `add_grabber(self, hold_point, _detected_grab_point)`/`remove_grabber(self)`를 호출하도록 바꿨다. `grab_spring_strength=500.0`/`grab_damping=60.0`/`max_force_per_grabber=300.0`/`max_spring_distance=2.5`/`max_grab_distance=3.0`/`max_target_speed=15.0`은 각 오브젝트의 실제 mass×gravity(중력)를 근거로 "한 명은 Crate를 겨우 버티는 수준, 두 명이면 확실히 빠름"이 되도록 역산한 초기값이다(`docs/TECH_DEBT.md` TD-013 참고).
- 완료 근거(검증): 헤드리스 자동 검증 59개 항목 3회 연속 실행 전부 PASS(0건 실패, 안정적 재현 확인). 질량 순서 실측(1 Grabber, 1초간 최고 상승 속도): SmallBox 6.43m/s > Package 2.80m/s > Barrel 2.51m/s > Crate 1.27m/s — 이론상 힘 여유(300N에서 각 물체의 mass×gravity를 뺀 값)와 순서가 정확히 일치. Torque 검증: 무게중심을 정확히 잡고 수직으로 당기면 각속도가 거의 발생하지 않는 반면(대조군), 중심에서 0.45m 벗어난 모서리를 같은 방식으로 당기면 뚜렷한 각속도(회전)가 발생함을 확인. Player 충돌: Grab 중에도 `get_collision_exceptions()`가 항상 빈 배열(예외가 전혀 생성되지 않음)이면서, Player가 3초간 계속 접근하거나 좌우로 빠르게 스윙해도 물체가 Player 몸 안으로 들어가지 않고(최소 거리 0.35m 이상 유지) NaN·속도 폭주 없음을 확인. 동적 접촉 비차단: 잡은 Package를 다른 Crate에 3초 이상 계속 밀착시켜도 연결이 끊기지 않고 NaN도 없음. 정적 차단: TestWall이 HandPoint-Grab Point 사이에 끼면 연결이 자동으로 해제됨. 다중 Grabber: 서로 다른 지점을 잡은 2 Grabber가 1 Grabber보다 동일 시간 후 더 높은 위치에 도달했고, 한쪽 연결(Grabber A)만 제거해도 나머지(Grabber B) 연결은 유지되었으며, 마지막 연결을 제거한 직후 속도가 급변하지 않아(운동량 보존) 별도 release impulse가 없음이 확인됨. 회귀: 좌클릭 Grab/Release(누르는 동안 유지, 놓으면 해제) 정상, `E` 입력이 Grab 상태에 전혀 영향 없음, 벽 너머 Grab 차단, 여러 Package 중 가까운 것 우선 감지, PhysicsBarrel도 동일하게 좌클릭으로 정상 Grab, PhysicsCrate가 DeliveryZone에 들어가도 배송 성공에 영향 없음(Package만 성공), 이동 입력 정상, `physics/common/physics_interpolation` 설정 유지, Restart-동등(새 씬 인스턴스에서 초기 위치·미배송 상태로 복구) 전부 회귀 없음. `--headless --import`, `--headless --quit-after 60` 모두 오류·경고 0건.

### T072 결함 수정 — 잡은 물체가 Player를 미는 문제

- **결함**: 위 구현에서 Player collision exception을 완전히 제거한 결과, 잡은 물체가 Spring 힘으로 Player 캡슐에 눌리면 `move_and_slide()`의 충돌 해석이 Player를 반대 방향으로 밀어내는 반작용이 발생함(사용자 재현 보고).
- **원인**: Grab 중에도 물체와 실제 Player `CharacterBody3D`가 여전히 직접 충돌 관계였다. Spring 힘이 물체를 Player 쪽으로 계속 압박하면, `move_and_slide()`가 이를 겹침으로 해석해 Player를 밀어내는 방향으로 재배치했다(T064 DD-006에서 확인된 kinematic-vs-dynamic 접촉 해석 특성의 역방향 사례).
- **수정**: 실제 Player 충돌과 "잡은 물체 차단"을 분리했다. `Player.tscn`에 `GrabCollisionBarrier`(`AnimatableBody3D`, Player 캡슐보다 약간 큰 `CapsuleShape3D`, `collision_layer=32`(신규 layer 6, GrabBarrier), `collision_mask=0`, `HoldPoint`(1.5m)보다 작은 반경 0.55m)를 Player의 자식으로 추가해 항상 Player를 따라다니게 했다. `GrabbableBody.gd`의 `add_grabber()`가 grabber가 `CollisionObject3D`이면 `add_collision_exception_with()`를 양방향으로 걸어 실제 Player 몸과의 충돌을 끄는 동시에, 자신의 `collision_mask`에 barrier 비트(32)를 추가해 대신 `GrabCollisionBarrier`와 충돌하게 한다. 여러 Grabber가 있을 수 있으므로 `_barrier_hold_count`로 관리해, 이 비트는 마지막 Grabber가 완전히 분리될 때만 제거된다. `remove_grabber()`(수동 release와 거리 초과·정적 차단 자동 해제 경로 모두 공통 `_begin_pending_restore()`를 거침)는 exception과 barrier 비트를 즉시 복구하지 않고 `_pending_restores`에 등록한 뒤, 매 물리 프레임 `intersect_shape()`로 실제 Player `CollisionShape3D`와의 겹침을 검사해 연속 3프레임 미겹침이 확인된 뒤에만 복구한다(T042~T065에 있었다가 T072에서 삭제했던 지연 복구 패턴을 이번 결함에 한해 재도입, 대상은 holder 전체가 아니라 Grabber별 개별 관리). Spring-Damper 힘 계산·질량·중력·torque·다중 Grabber 힘 합산 로직은 전혀 수정하지 않았다. `Player.gd`의 `_push_away_rigid_bodies()`가 `held_grabbable`을 건너뛰는 기존 로직도 무수정으로 유지되어 중복 밀림이 없다.
- **검증**: 헤드리스 36개 항목 3회 연속 전부 PASS. Player 앞에 Package를 겹치도록 배치해 3초간 압착해도 Player 수평 이동량 0.05m 미만(사실상 밀리지 않음), Package와 Player 중심 거리가 항상 Barrier 반경(0.55m)보다 크게 유지(관통 없음). 빠른 좌우 스윙(진동 패턴) 후에도 Player 수평 이동량 0.1m 미만. Player 근처에서 release해도 물체 속도가 release 직전 대비 급격히 튀지 않고 Player도 튕기지 않음. 안전 분리(연속 3프레임 미겹침) 확인 후 `get_collision_exceptions()`가 다시 비고 barrier 비트도 제거되며, 그 시점에 물체를 다시 Player 위치에 겹치면 정상적으로 밀려나는 일반 충돌이 복구됨을 확인. SmallBox/Package/Barrel/Crate 4종 모두 동일하게 압착 시 Player가 밀리지 않음을 확인. 두 개의 독립된 Grabber로 같은 Crate를 잡은 뒤 하나만 release하면 그 Grabber의 exception만 복구되고 barrier 비트는 나머지 Grabber가 남아있는 동안 유지되다가, 마지막 Grabber까지 release되어야 최종 복구됨을 확인(다중 Grabber 독립성 유지). Force-Based Grab 핵심(좌클릭 Grab/Release, `E` 무동작, 모서리 grab torque, 정적 장애물 자동 해제, Package 배송)과 DeliveryZone 회귀 없음. `--headless --import`, `--headless --quit-after 60` 오류·경고 0건.
- **생성 파일**: 없음. **수정 파일**: `hell-delivery/scenes/player/Player.tscn`(`GrabCollisionBarrier` 노드 추가), `hell-delivery/scenes/objects/GrabbableBody.gd`(collision exception + barrier mask 지연 복구 로직 추가, Force-Based Grab 힘 계산 자체는 무변경).
- **신규 Collision Layer**: layer 6 = `GrabBarrier`(값 32) — `GrabCollisionBarrier` 전용, Grab 중인 Grabbable만 일시적으로 이 레이어와 충돌하도록 mask에 추가됨(`docs/ARCHITECTURE.md` 섹션 16 갱신 필요 시 참고).
- **남은 위험**: 낮음. Barrier 반경(0.55m)은 Player capsule(0.5m)보다 "약간 크게"라는 목표로 정한 초기값 — 사용자 수동 테스트에서 너무 타이트하거나 헐렁하면 조정 가능.
- **상태**: 이 결함 수정을 포함해도 T072/EPIC-05는 여전히 `[REVIEW]`(사용자 수동 테스트 승인 대기), T070은 계속 `[BLOCKED]`.

### T072 결함 수정 후속 정정 — Barrier가 실제로는 Player를 따라다니지 않던 문제

- **재보고된 증상**: 위 결함 수정 적용 후에도 사용자가 실제 플레이에서 "잡고 있는 동안(특히 카메라를 빠르게 돌리거나 스윙할 때) 4종 오브젝트 모두 여전히 Player를 관통한다"고 재현. 이전 검증(36개 항목 PASS)은 이 상황을 재현하지 못했음이 드러남.
- **재조사로 확인한 원인**: `GrabCollisionBarrier`(`AnimatableBody3D`, `sync_to_physics=true`)를 Player의 자식 노드로만 배치하고 별도 동기화 코드를 두지 않았는데, **`sync_to_physics=true`인 물리 바디는 일반 Node3D 자식처럼 부모 Transform 변경을 자동으로 따라가지 않는다**는 것을 헤드리스로 직접 확인했다(격리 테스트: Player를 스폰 위치에서 멀리 이동시킨 뒤 `barrier.global_position`을 읽으면 Player의 새 위치가 아니라 최초 스폰 위치(Z=0)에 그대로 고정되어 있었음). 즉 Barrier는 사실상 한 번도 Player를 따라 움직이지 않는 정적 장식물이었고, 이전 검증 스크립트는 Player를 테스트 시작 시 한 번만 배치한 뒤 물체를 곧바로 그 근처(=Barrier의 실제 위치와 우연히 가까운 스폰 지점 근방)에 두고 테스트해 이 결함이 가려졌다.
- **수정**: `Player.gd`에 `@onready var grab_collision_barrier: AnimatableBody3D = $GrabCollisionBarrier`를 추가하고, `_physics_process()`의 `move_and_slide()` 직후 `grab_collision_barrier.global_transform = global_transform`으로 매 물리 프레임 명시적으로 동기화했다(AnimatableBody3D의 정상적인 사용법 — 이동 플랫폼처럼 스크립트가 직접 옮겨줘야 함). Force-Based Grab 로직·collision exception·Barrier mask 로직 자체는 무수정.
- **검증**: 재구성한 헤드리스 37개 항목(기존 36개 + "Barrier가 Player 이동을 실제로 따라가는지" 확인 항목 1개 신규 추가) 3회 연속 전부 PASS. 특히 사용자가 재현한 시나리오(방향키 없이 순수하게 카메라만 연속으로 빠르게 회전시키며 1초 이상 유지)를 별도로 재현해, 수정 전에는 물체가 Barrier 반경(0.55m)보다 가까이 접근(최소 0.51m)해 사실상 무방비로 통과했던 것이, 수정 후에는 최소 거리가 0.5m 밑으로 내려가지 않고(스윙 중 최소 0.98m 확인, 물체가 접근하면 속도가 실제로 꺾이며 튕겨나가는 충돌 반응 확인) Barrier에 의해 제대로 저지됨을 확인했다. `--headless --import`, `--headless --quit-after 60` 오류·경고 0건.
- **수정 파일**: `hell-delivery/scenes/player/Player.gd`(barrier 참조 추가 및 매 프레임 동기화 1줄). `Player.tscn`/`GrabbableBody.gd`는 이번 후속 정정에서 추가 변경 없음(직전 결함 수정에서 만든 구조를 그대로 사용).
- **교훈(테스트 방법론)**: `AnimatableBody3D`를 물리 바디가 아닌 일반 Node3D처럼 "부모에 매달아 두면 따라간다"고 가정한 것이 근본 원인이었다 — 향후 AnimatableBody3D를 다른 노드에 종속시켜 움직이려면 반드시 매 물리 프레임 명시적 Transform 동기화가 필요함을 기억해 둔다. 또한 이번처럼 사용자가 "고쳤다던 게 아직도 안 된다"고 재보고하면, 기존 검증 스크립트를 그대로 재실행해 보는 것으로는 부족하고 실제 신고된 조작 시퀀스(이번 경우 "가만히 압착"이 아니라 "빠르게 연속 스윙")를 별도로 재현하는 새 테스트가 필요하다.
- **상태**: 이 후속 정정을 포함해도 T072/EPIC-05는 여전히 `[REVIEW]`, T070은 계속 `[BLOCKED]`.

### T072 사용자 수동 테스트 승인(최종)

- **사용자 수동 테스트 결과: 승인.** Force-Based Physics Grab과 두 차례의 Player 밀림/관통 결함 수정을 포함한 최종 상태로 실제 플레이 테스트를 진행했고, 다음을 모두 확인해 승인함:
  - SmallBox, Package, Barrel, Crate의 질량 차이가 체감됨
  - 물체가 중력과 관성을 유지하며 출렁이고 늦게 따라옴
  - 중앙과 모서리 Grab의 회전 차이가 정상적임
  - 빠른 카메라 이동 후 Release 시 현재 운동량으로 자연스럽게 날아감
  - 별도 고정 Throw 또는 Swing impulse가 없음
  - 잡은 물체가 Player를 관통하지 않음
  - 잡은 물체와 충돌해도 Player가 밀리거나 튀지 않음
  - Player 근처에서 Release해도 비정상 반발이 없음
  - 동적 물체 충돌로 Grab이 즉시 해제되지 않음
  - 정적 장애물 및 최대 거리 해제가 정상적임
  - Package만 DeliveryZone 배송 성공
  - 치명적인 떨림, 관통, NaN, 속도 폭주가 없음
- **완료 처리**: 이 승인으로 T072는 `[DONE]`으로 확정한다(섹션 24 상단 상태 갱신). `docs/ROADMAP.md`의 EPIC-05(Generalized Object Interaction)도 이 승인을 근거로 완료 처리한다. `grab_spring_strength`/`grab_damping`/`max_force_per_grabber` 등 Force-Based Grab 수치는 이번 승인으로 **사용자 승인된 프로토타입 기준값(Baseline)**으로 확정되며, 추가 수치 조정 가능성은 남기되 완료를 막는 미해결 결함으로는 취급하지 않는다(`docs/TECH_DEBT.md` TD-013 참고).
- **T070 재개**: EPIC-05 완료로 T070의 `[BLOCKED]` 상태를 해제한다(섹션 22 참고). T070은 아직 사용자의 실제 최종 재미 평가가 남아 있으므로 `[DONE]`으로 처리하지 않고 `[REVIEW]`(사용자 최종 플레이·평가 대기)로 전환한다.

## 25. T073 — First-Person Camera Transition and Grab Usability

- 상태: `[REVIEW]` (구현·자동 검증 완료, 사용자 수동 테스트 대기)
- **T070 재차단**: 이 작업 착수로 T070의 `[REVIEW]`를 다시 `[BLOCKED]`로 되돌린다(섹션 22 참고) — 조작·시점 자체가 바뀌므로 T073 사용자 승인 전에는 최종 재미 평가를 진행할 수 없다.
- 목적: 3인칭 카메라에서 캐릭터가 잡은 물체와 조준 대상을 가리는 문제를 해결하기 위해 플레이 시점을 1인칭으로 전환한다. 기존 T072 Force-Based Physics Grab의 힘 계산·다중 Grab Connection·Player 관통/밀림 방지 구조는 그대로 유지하며, Grab 판정을 카메라 중앙(화면 조준점) 기준으로 재정렬하고 상태형 조준점 UI를 추가해 조작성을 명시적으로 검증한다. 사용자 지시(카메라/조준 관련 요청)에 따른 변경이며, `docs/GAME_DESIGN.md`가 명시하는 "3인칭 카메라를 기본으로 한다"(섹션 26, 29 등)와 정면으로 배치되지만, 사용자의 최신 명시적 지시가 `CLAUDE.md` 섹션 9 문서 우선순위상 `GAME_DESIGN.md`보다 우선하므로 진행했다. **`GAME_DESIGN.md` 자체는 이번 작업 문서 반영 범위에 포함되지 않아 수정하지 않았다 — "3인칭"이라는 서술이 실제 구현과 불일치 상태로 남아 있음을 남은 위험에 기록한다.**
- 소속: `docs/ROADMAP.md`에 해당 Epic 없음(사용자가 T064/T067처럼 Epic 분해 외 별도 지정한 작업).
- 선행 작업: T072(`[DONE]`, Force-Based Physics Grab 및 Player 밀림/관통 방지 구조를 그대로 사용)
- 작업 범위:
  - `Player.tscn`: 3인칭 `SpringArm3D` 제거, `CameraPivot`을 눈높이(로컬 y=0.7)로 이동, `Camera3D`를 `CameraPivot`의 직계 자식으로 재배치, `GrabShapeCast`를 `Camera3D`와 동일한 로컬 원점(`CameraPivot` 원점)으로 재배치, `MeshInstance3D`에 시각 레이어 2 부여, `Camera3D.cull_mask`에서 레이어 2 제외
  - `Player.gd`: 마우스 좌우 회전을 `CameraPivot`이 아닌 Player 자신의 `rotation.y`(yaw)로, 상하 회전은 `CameraPivot.rotation.x`(pitch)로 분리. 이동 방향 계산을 `camera_pivot.global_transform.basis`에서 `transform.basis`(Player 자신)로 변경. 조준점 UI가 참조할 `grab_aim_state_changed(state: int)` 시그널 추가(0=NONE/1=TARGETING/2=HOLDING, 기존 `_detected_grabbable`/`held_grabbable` 값만 재사용, 별도 탐색 없음)
  - `scenes/ui/Crosshair.gd` 신규(`Control`, `_draw()` 기반 상태형 조준점, 외부 이미지 Asset 없음)
  - `DeliveryHUD.tscn`/`DeliveryHUD.gd`: `Crosshair` 노드 추가, `set_crosshair_state(state)` 위임 메서드 추가
  - `PrototypeLevel.gd`: `player.grab_aim_state_changed`를 `delivery_hud.set_crosshair_state`에 연결(기존 `delivery_zone.package_delivered` → `delivery_hud.show_success()` 연결과 동일한 패턴)
- 제외 범위: Force-Based Grab의 힘 계산·질량·torque·다중 Grabber·Player 관통 방지 로직 변경, `E`(`interact`) 동작 추가, Player `CollisionShape3D`/`GrabCollisionBarrier` 형상 변경, 외부 이미지/폰트 Asset 추가, `GAME_DESIGN.md` 등 기획 문서 수정, 신규 Autoload/Manager
- 생성 파일: `hell-delivery/scenes/ui/Crosshair.gd`
- 수정 파일: `hell-delivery/scenes/player/Player.tscn`, `hell-delivery/scenes/player/Player.gd`, `hell-delivery/scenes/ui/DeliveryHUD.tscn`, `hell-delivery/scenes/ui/DeliveryHUD.gd`, `hell-delivery/scenes/level/PrototypeLevel.gd`
- 에디터 수동 작업: 없음(전부 텍스트 편집, headless import/boot로 검증)
- 완료 조건: 카메라가 Player 눈높이에서 1인칭으로 동작, 좌우 회전이 Player 본체 yaw·상하 회전이 CameraPivot pitch로 분리, Grab 판정이 화면 중앙(Camera) 기준으로 수행되어 조준점과 항상 일치, 클릭 표면 지점이 여전히 `local_grab_point`로 저장되어 torque가 유지됨, 상태형 조준점이 항상 화면 정중앙에 위치하고 마우스 입력을 가로채지 않음, 로컬 Player Mesh가 자기 카메라 렌더링에서 제외됨(다른 Player에게는 보이는 구조 유지, 전역 `visible=false` 미사용), Force-Based Grab 핵심 기능(질량감, torque, 다중 Grabber, Player 관통·밀림 방지, Release 운동량 유지) 회귀 없음
- 테스트 방법: `godot --headless --import`, `--headless --quit-after`로 파싱/부팅 오류 확인, 임시 `SceneTree` 스크립트(검증 후 삭제)로 4종 오브젝트 × 20회 Grab/Release 정확도(80회), 4종 × 4개 거리(표면 기준 0.4/1.5/2.4/2.6m) Grab 성공·실패 및 조준점 상태 동일 프레임 일치, 벽 뒤 대상 Grab 차단, 일렬 배치 앞 물체 우선 선택, 조준점-Camera Ray 화면 정렬 오차, Grab/Release/조준점 상태 변경 반응 프레임, 360도 회전+pitch 범위 자기 가림(Grab Ray 자기 감지, Mesh cull_mask 제외) 검사, 실제 `PrototypeLevel`을 이용한 4종 오브젝트별 전진/후진/좌우 이동·빠른 시점 회전·좁은 문 통과·Player 근처 Release 회귀 총 128개 항목을 자동 검증(3회 연속 실행). 조작 편안함·멀미 여부·조준점 가독성 등 주관적 항목은 자동 검증 대상이 아님 — **사용자 수동 테스트 필요**.
- 예상 위험:
  - 카메라 눈높이(`CameraPivot` 로컬 y=0.7)는 Player 기본 `CapsuleShape3D`(radius 0.5/height 2.0) 기준으로 추론한 프로토타입 값이며, 여러 후보를 실측 비교하지 않았다 — 사용자 수동 테스트에서 너무 낮거나 높게 느껴지면 조정이 필요할 수 있다.
  - `HoldPoint`의 `CameraPivot` 기준 오프셋(전방 1.5m)은 T042부터 이어진 값을 그대로 유지했다 — 3인칭에서는 렌더 카메라가 4.5m 뒤로 빠져 있어 물체가 실제 화면에서 멀리 보였지만, 1인칭 전환으로 Camera가 `CameraPivot` 원점에 위치하게 되며 물체가 화면상 카메라에 훨씬 가깝게(1.5m) 보이게 되는 체감 변화가 있다 — Crate(1.0m 정육면체) 기준 화면 점유 비율을 계산상으로는 확인했으나 실제 체감은 사용자 확인이 필요하다.
  - `docs/GAME_DESIGN.md`(섹션 26, 29, 그 외 "3인칭 시점" 서술)가 이번 변경 후에도 3인칭으로 남아 있다 — 이번 작업의 문서 반영 범위에 포함되지 않았기 때문이며, 사용자가 원하면 별도로 `GAME_DESIGN.md` 갱신을 요청해야 한다.
  - 로컬 Player Mesh 은닉은 `MeshInstance3D.layers=2` + `Camera3D.cull_mask`에서 레이어 2 제외로 구현했다 — 향후 실제 멀티플레이 도입 시, 여러 Player 인스턴스가 전부 같은 레이어 2를 공유하면 "다른 Player도 안 보이는" 문제가 생길 수 있어(레이어는 인스턴스별이 아니라 전역 공유) 그때는 Player별로 별도 레이어를 동적 할당하는 구조가 추가로 필요하다 — 지금은 싱글플레이이므로 이 구조까지는 만들지 않았다(과도한 확장 설계 금지 원칙).
- 완료 근거(구현): `Player.tscn`에서 `SpringArm3D`(spring_length=4.5)를 제거하고 `Camera3D`를 `CameraPivot`의 직계 자식으로 재배치했다. `CameraPivot`에 로컬 `Transform3D` y=0.7(눈높이, TODO 프로토타입 값)을 부여했다. `GrabShapeCast`를 기존 `CameraPivot` 로컬 y=-0.5 오프라인에서 `CameraPivot` 원점(=Camera3D 원점)으로 이동시켜, Grab 판정 Ray/ShapeCast가 항상 실제 렌더 카메라의 광학축과 정확히 일치하도록 만들었다(오프셋을 아예 0으로 만들어 구조적으로 정렬 오차가 발생할 수 없게 함). `HoldPoint`는 `CameraPivot` 로컬 좌표(0,0,-1.5)를 그대로 유지했다 — Camera가 `CameraPivot` 원점으로 옮겨온 결과 이제 HoldPoint는 자동으로 "Camera 정면, Camera와 동일 위치 아님, Player 캡슐(반경 0.5)·GrabCollisionBarrier(반경 0.55)보다 바깥"이라는 요구를 모두 만족하게 되어 별도 값 변경이 필요하지 않았다. `MeshInstance3D`에 `layers=2`를 부여하고 `Camera3D.cull_mask=1048573`(전체 레이어에서 레이어 2만 제외)로 설정해, 로컬 카메라가 자신의 Mesh를 렌더링하지 않도록 했다(전역 `visible=false`는 사용하지 않아 향후 다른 Player에게는 보이는 구조를 해치지 않음). `Player.gd`는 `_unhandled_input()`에서 마우스 X 이동을 `rotation.y -= ...`(Player 자신의 yaw)로, 마우스 Y 이동은 기존과 동일하게 `camera_pivot.rotation.x`(pitch, 기존 clamp 유지)로 분리했다. `_physics_process()`의 이동 방향 계산을 `camera_pivot.global_transform.basis`에서 `transform.basis`로 변경했다(yaw가 이제 Player 자신에 있으므로). `grab_aim_state_changed(state: int)` 시그널을 추가하고, 매 물리 프레임 `_update_grab_detection()`/`_handle_grab_input()`이 이미 계산해 둔 `_detected_grabbable`/`held_grabbable`만으로 상태(0/1/2)를 판정해 값이 바뀔 때만 발신한다(별도 탐색 없음). `scenes/ui/Crosshair.gd`(`class_name Crosshair extends Control`)를 신규 작성 — `_draw()`로 상태별(기본 점/조준 원/홀드 사각형) 표시, `mouse_filter=IGNORE`, anchors 0.5/0.5 고정 오프셋으로 해상도·화면비와 무관하게 항상 화면 정중앙에 위치한다. `DeliveryHUD.tscn`에 `Crosshair` 노드를 추가하고 `DeliveryHUD.gd`에 `set_crosshair_state(state)` 위임 메서드를 추가했다. `PrototypeLevel.gd`에 `player: Player` 참조를 추가하고 `player.grab_aim_state_changed.connect(delivery_hud.set_crosshair_state)`로 연결했다(기존 `DeliveryZone → PrototypeLevel → DeliveryHUD` 시그널 패턴과 동일). 이 과정에서 `Player.gd`에 `class_name Player`를 추가했다(다른 모든 씬 스크립트가 `class_name`을 갖는 기존 관례와 통일, `PrototypeLevel.gd`에서 타입 참조를 위해 필요) — 동작 변경은 없다. `GrabbableBody.gd`는 전혀 수정하지 않았다(Force-Based Grab 힘 계산·다중 Grab Connection·Player 관통/밀림 방지 구조 무변경).
- 완료 근거(검증): 헤드리스 자동 검증 128개 항목 3회 연속 전부 PASS. Grab 정확도: 4종 오브젝트(Package/PhysicsBarrel/PhysicsCrate/SmallPhysicsBox) 각 20회, 정면 중앙·일반 운반 거리(1.5m)에서 80/80(100%) 첫 클릭 성공. 거리별 Grab: 표면 거리 기준 0.4m/1.5m/2.4m(유효 사거리 내)는 4종 전부 성공, 2.6m(유효 사거리 밖, `GrabShapeCast` 감지거리 2.2m+구체 반경 0.3m=2.5m 기준)는 4종 전부 실패로 정확히 갈렸으며, 모든 경우 조준점 상태(`GRAB_AIM_HOLDING` 등)가 같은 프레임에 일치. 가시선·우선순위: 벽 뒤 대상 5회 시도 중 Grab 성공 0회, 일렬 배치 시 앞 물체 10/10(100%) 선택. 조준점 정렬 오차: `Camera3D.unproject_position()`으로 계산한 화면 투영 좌표와 화면 정중앙의 오차 0px(구조적으로 `GrabShapeCast`가 Camera 원점과 완전히 일치하므로 이론상 항상 0). 입력 반응: Grab/Release/조준점 상태 변경 모두 지연 0~1 physics frame(코드 구조상 같은 `_physics_process()` 호출 내에서 동시에 처리되어 실측으로도 확인). 자기 가림: Player를 360도 회전 + pitch 전 범위로 움직이는 동안 `GrabShapeCast`가 Player 자신을 감지한 횟수 0회, `MeshInstance3D.layers`와 `Camera3D.cull_mask`가 서로 배타적임을 확인. 운반 회귀: 실제 `PrototypeLevel`에서 4종 오브젝트 각각 전진·후진·좌우 이동, 빠른 연속 시점 회전(720도), 좁은 문(`NarrowDoorwayTestArea`) 통과, Player 근처 Release까지 전부 NaN 없음·속도 폭주 없음·Grab 유지·Player 밀림 없음·Player 관통 없음 확인. `--headless --import`, `--headless --quit-after 90` 모두 오류·경고 0건.
  - 검증 중 발견한 테스트 방법론 이슈(게임 코드와 무관, 테스트 스크립트에서만 수정): (1) 좁은 문 통과 테스트 초안에서 Player를 held 상태로 순간이동시키면 `max_grab_distance`(3.0)를 항상 초과해 자동 해제되는 것을 발견 — 실제 플레이는 걸어서 접근하므로 재현되지 않는 아티팩트이며, 테스트를 "이동 전 놓기 → 이동 → 다시 잡기"로 수정해 우회했다. (2) 좁은 문 통과 경로가 `PrototypeLevel`에 이미 배치된 `PackageC`(-4.5,1,-1)와 정확히 겹쳐, Player·held 오브젝트가 그 오브젝트와 부딪혀 속도가 급감/불안정해지는 현상을 발견 — Force-Based Grab과 무관한 테스트 동선 설계 문제로 판단해 해당 테스트에서만 `PackageC`를 제거하도록 수정했다(레벨 자체는 무수정). (3) 문을 지난 뒤 속도를 오래(200프레임) 측정하면 `Floor`(X=-10까지) 밖으로 나가 자유낙하가 "이상 속도"로 오인되는, 이 프로젝트에 기존에도 문서화된 패턴을 재확인 — 이동 프레임 수를 줄이고 수평 성분만 측정하도록 수정했다.
- **상태**: T072/EPIC-05는 계속 `[DONE]`(무변경). T070은 이 Task 착수로 다시 `[BLOCKED]`. T073 승인 전에는 `[DONE]` 처리하지 않는다.

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
