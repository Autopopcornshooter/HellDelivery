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

- 상태: `[x]` `[DONE]` (사용자 최종 플레이 테스트 완료·승인 — 아래 "T070 사용자 최종 플레이 테스트 승인(최종)" 참고)
- **차단 이력**: 선행 조건이던 EPIC-05(Generalized Object Interaction)가 T072(Force-Based Physics Grab) 및 두 차례의 Player 밀림/관통 결함 수정을 거쳐 사용자 수동 테스트 승인을 받아 완료되면서 한 차례 `[BLOCKED]`가 해제되었다(섹션 24 "T072 사용자 수동 테스트 승인(최종)" 참고). 그러나 곧이어 사용자 지시로 T073(1인칭 시점 전환 및 Grab 조작성 개선)이 착수되어 조작·시점 자체가 다시 바뀌므로 `[BLOCKED]`로 되돌아갔다(섹션 25 참고). **T073이 이후 두 차례의 Push 결함 수정과 재검증을 거쳐 사용자 수동 테스트 승인을 받아 `[DONE]`으로 확정되면서(섹션 25 "T073 사용자 수동 테스트 승인(최종)" 참고), 조작·시점이 확정되었다고 보고 `[BLOCKED]`를 다시 해제한다.** 아래 평가 항목은 T073 확정 반영(1인칭 카메라, 조준점 포함)을 위해 2개 항목을 추가했다.
- 목적: "Package를 직접 잡고 운반하며 물리적 사고를 수습하는 행동이 재미있는가?"라는 핵심 질문에 사용자의 실제 플레이 결과로 답한다. `docs/ROADMAP.md` EPIC-04(Playtest & Fun Validation)의 FEATURE-04-A(확장된 전체 루프 플레이 테스트)/FEATURE-04-B(재미 판정 및 로드맵 재검토 여부 결정)에 대응.
- 소속: `docs/ROADMAP.md` v0.2.0 EPIC-04(Playtest & Fun Validation) — FEATURE-04-A, FEATURE-04-B
- 선행 작업: T069(`[DONE]`, EPIC-01~03 전부 완료), EPIC-05/T072(`[DONE]`, 사용자 승인 완료), T073(`[DONE]`, 1인칭 카메라·조준점·Grab 조작성 사용자 승인 완료 — 섹션 25 참고)
- 작업 범위: 실제 씬 좌표 기준 전체 루프 플레이 경로 작성, 현재 조작 방식(1인칭 카메라 + 조준점 + 좌클릭 Hold + Force-Based Grab, T072·T073)에 맞춘 평가 항목 14개(기존 12개 + T073 반영 2개) 작성, 경량 자동 점검(구조 존재 확인)만 수행
- 제외 범위: 게임 코드·씬·물리값 수정, 새 기능 구현, 대규모 회귀 스크립트, Claude에 의한 재미 판정(반드시 사용자 응답 근거)
- 생성 파일: 없음
- 수정 파일: 없음(코드/씬 무변경, 이번 문서 갱신만)
- 에디터 수동 작업: 사용자가 직접 플레이(Claude 대행 불가)
- 완료 조건: 사용자가 전체 루프 플레이를 완료하고 아래 평가 항목 14개에 답변, 그 응답을 근거로 PASS/PASS WITH NOTES/FAIL 중 하나로 판정
- 테스트 방법: `godot --headless --import`, `--headless --quit-after`로 파싱/부팅 오류 확인, 임시 스크립트(검증 후 삭제)로 Player/Package 3개/TestWall/NarrowDoorwayTestArea/PhysicsObjects 6개/DeliveryZone/DeliveryHUD 존재와 Physics Interpolation 활성화만 경량 점검(대규모 회귀 스크립트 미작성). 재미 여부는 자동 검증 대상이 아님 — **사용자 실제 플레이 결과 필요**.
- 예상 위험: 낮음(코드 변경 없음). 유일한 위험은 판정 자체가 100% 사용자 응답에 의존한다는 점 — 응답이 오기 전까지 EPIC-04와 v0.2.0을 완료 처리할 수 없다.
- 완료 근거(준비 단계): 실제 씬 좌표를 기준으로 전체 루프 경로를 작성했다(Spawn(0,1.5,0) → Package/환경 오브젝트 밀집 구역 → Stairs(X10.1~16) → Ramp(-7.02,6) → NarrowDoorway(X=-7, gap Z -1.7~-0.3) → TestWall(6,2,-8) → 던지기 → DeliveryZone(5,0.5,3) → Restart). 경량 자동 점검 10개 항목 전부 PASS(`--headless --import`, `--headless --quit-after 60` 오류 0건). 대규모 회귀 스크립트는 작성하지 않았다(T069까지 이미 충분히 검증됨, 이번 Task는 재미 판정이 목적). 코드·씬·물리값은 전혀 수정하지 않았다.
- **평가 항목(T072 최종 조작 방식 + T073 확정된 1인칭 카메라·조준점 반영, 각 항목 1~5점 + 자유 코멘트)**:
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
  13. 1인칭 카메라가 장시간 플레이에서도 편안한가(멀미·불편함 없는가)
  14. 화면 중앙 조준점이 실제 Grab 대상과 항상 일치한다고 느껴지는가
  - 평가 양식: 각 항목 1~5점(1=매우 불만족, 5=매우 만족) + 필요 시 한 줄 코멘트. 12번은 자유 서술.
  - 플레이 경로: 위 완료 근거(준비 단계)의 좌표 경로를 그대로 사용한다(Spawn → 환경 오브젝트 밀집 구역 → Stairs → Ramp → NarrowDoorway → TestWall → DeliveryZone → Restart 후 재검증).

### T070 최종 실행 준비 확인(코드 변경 없음)

- **목적**: T073이 `[DONE]`으로 확정된 이후, 사용자의 최종 재미 평가 플레이를 받을 수 있는 상태인지 재확인한다. 기능 추가나 물리값 튜닝은 하지 않았다.
- **자동 회귀(기존 headless 실행만 사용, 신규 임시 스크립트 미작성)**: `godot --headless --path . --import` — 오류 없이 완료. `godot --headless --path . --quit-after 180`(약 3초, 레벨 전체 로드 후 물리 정착 포함) — 오류·경고 0건. 코드가 이전 T073 승인 시점 이후 전혀 변경되지 않아(이번 세션은 문서만 수정), 이전에 기록된 자동 검증 결과(T073 18개 항목·128개 항목, T072 59개+회귀, T069 55개 등, 모두 3회 연속 PASS)가 그대로 유효하다.
- **테스트 경로 구조 확인(`PrototypeLevel.tscn` 직접 대조, 실행 없이 정적 확인)**: `Stairs`(Step1~13 + TopLanding, X 10.1~16), `Ramp`(X -7.02, Z 6), `NarrowDoorwayTestArea`(LeftWall/RightWall/Lintel, X -7, gap Z -1.7~-0.3), `WallTestArea/TestWall`(X 6, Z -8), `DeliveryZone`(X 5, Z 3), `PhysicsObjects`(Barrel 1 + Crate 2 + SmallBox 3), `Package`/`PackageB`/`PackageC` 전부 씬에 존재하고 좌표가 최근 검증 시점과 동일함을 확인(`git status`상 `PrototypeLevel.tscn` 무변경). 계단-Floor 접합부(T022에서 해결된 0.05m 중첩)를 포함해 구간 간 이동을 막는 새로운 간격은 발견되지 않았다.
- **결론**: 실행 불가 결함 없음. T070 사용자 최종 플레이 테스트 진행 가능.
- **상태**: `[REVIEW]` 유지(사용자 최종 플레이·평가 대기). T070/EPIC-04/v0.2.0 모두 `[DONE]`·완료 처리하지 않음. **(이후 사용자가 실제 최종 플레이 테스트를 완료·승인 — 아래 "T070 사용자 최종 플레이 테스트 승인(최종)" 참고)**

### T070 사용자 최종 플레이 테스트 승인(최종)

- **사용자 최종 플레이 테스트 결과: 승인.** 전체 테스트 경로(Spawn → 환경 오브젝트 밀집 구역 → Stairs → Ramp → NarrowDoorway → TestWall → DeliveryZone → Restart)와 14개 평가 항목 전체에서 치명적인 문제 없이 PASS로 확인함:
  1. 좌클릭 Hold Grab/Release가 직관적으로 작동
  2. SmallBox, Package, Barrel, Crate의 무게 차이가 체감됨
  3. 중앙과 모서리 Grab의 torque 차이가 자연스러움
  4. 저속 이동과 빠른 스윙에서 물체 반응이 정상적임
  5. Release 후 현재 운동량이 자연스럽게 유지됨
  6. 잡은 물체가 Player를 관통하거나 밀어내지 않음
  7. 잡은 물체로 다른 물체를 밀 때 과도한 힘이 발생하지 않음
  8. 좁은 문, 벽, 계단, 경사로 운반 가능
  9. 여러 Package 운반에 치명적인 불편 없음
  10. DeliveryZone 배송 흐름 정상
  11. Restart 후 Grab과 배송 정상
  12. 전체 플레이 흐름과 물리 조작 재미를 승인함(자유 서술 포함)
  13. 1인칭 카메라가 편안하고 시야 가림이 없음
  14. 조준점과 실제 Grab 대상이 일치함
  - 반드시 수정해야 할 결함 없음. NaN·속도 폭주·관통·비정상 튕김 없음.
- **완료 처리**: 이 승인으로 T070은 `[DONE]`으로 확정한다(섹션 22 상단 상태 갱신). "Package를 직접 잡고 운반하며 물리적 사고를 수습하는 행동이 재미있는가?"라는 핵심 질문에 **"재미있다"**는 실제 플레이 판단이 내려졌다. 추가 필수 수정 없이 현재 프로토타입(1인칭 카메라, 조준점, Force-Based Physics Grab, Body Push 질량 반영 등)을 그대로 승인한다.
- **상위 완료 처리**: 이 승인을 근거로 `docs/ROADMAP.md`의 EPIC-04(Playtest & Fun Validation)와 v0.2.0(Physics Playground)을 완료 처리한다(`docs/ROADMAP.md` 참고). Milestone 2(Gameplay Expansion)는 v0.2.0·v0.3.0에 걸쳐 있어, v0.3.0(로컬 다인 협동) 착수 전까지는 전체 완료로 처리하지 않는다(`docs/MILESTONES.md` 참고).

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

- 상태: `[x]` `[DONE]` (구현·자동 검증·재검증·사용자 수동 테스트 승인 모두 완료 — 아래 "T073 사용자 수동 테스트 승인(최종)" 참고)
- **T070 재차단(이력)**: 이 작업 착수로 T070의 `[REVIEW]`를 한 차례 `[BLOCKED]`로 되돌렸었다(섹션 22 참고) — 조작·시점 자체가 바뀌므로 T073 사용자 승인 전에는 최종 재미 평가를 진행할 수 없었기 때문. **이제 아래 사용자 승인으로 T070의 `[BLOCKED]`를 다시 해제한다(섹션 22 참고).**
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
  - ~~`docs/GAME_DESIGN.md`(섹션 26, 29, 그 외 "3인칭 시점" 서술)가 이번 변경 후에도 3인칭으로 남아 있다~~ — **사용자 승인 후 해결**: `docs/GAME_DESIGN.md` 섹션 "카메라"·섹션 26·섹션 32의 "3인칭" 서술을 "1인칭(T073)"으로 최소 수정해 실제 구현과 동기화했다(아래 "T073 사용자 수동 테스트 승인(최종)" 참고).
  - 로컬 Player Mesh 은닉은 `MeshInstance3D.layers=2` + `Camera3D.cull_mask`에서 레이어 2 제외로 구현했다 — 향후 실제 멀티플레이 도입 시, 여러 Player 인스턴스가 전부 같은 레이어 2를 공유하면 "다른 Player도 안 보이는" 문제가 생길 수 있어(레이어는 인스턴스별이 아니라 전역 공유) 그때는 Player별로 별도 레이어를 동적 할당하는 구조가 추가로 필요하다 — 지금은 싱글플레이이므로 이 구조까지는 만들지 않았다(과도한 확장 설계 금지 원칙).
- 완료 근거(구현): `Player.tscn`에서 `SpringArm3D`(spring_length=4.5)를 제거하고 `Camera3D`를 `CameraPivot`의 직계 자식으로 재배치했다. `CameraPivot`에 로컬 `Transform3D` y=0.7(눈높이, TODO 프로토타입 값)을 부여했다. `GrabShapeCast`를 기존 `CameraPivot` 로컬 y=-0.5 오프라인에서 `CameraPivot` 원점(=Camera3D 원점)으로 이동시켜, Grab 판정 Ray/ShapeCast가 항상 실제 렌더 카메라의 광학축과 정확히 일치하도록 만들었다(오프셋을 아예 0으로 만들어 구조적으로 정렬 오차가 발생할 수 없게 함). `HoldPoint`는 `CameraPivot` 로컬 좌표(0,0,-1.5)를 그대로 유지했다 — Camera가 `CameraPivot` 원점으로 옮겨온 결과 이제 HoldPoint는 자동으로 "Camera 정면, Camera와 동일 위치 아님, Player 캡슐(반경 0.5)·GrabCollisionBarrier(반경 0.55)보다 바깥"이라는 요구를 모두 만족하게 되어 별도 값 변경이 필요하지 않았다. `MeshInstance3D`에 `layers=2`를 부여하고 `Camera3D.cull_mask=1048573`(전체 레이어에서 레이어 2만 제외)로 설정해, 로컬 카메라가 자신의 Mesh를 렌더링하지 않도록 했다(전역 `visible=false`는 사용하지 않아 향후 다른 Player에게는 보이는 구조를 해치지 않음). `Player.gd`는 `_unhandled_input()`에서 마우스 X 이동을 `rotation.y -= ...`(Player 자신의 yaw)로, 마우스 Y 이동은 기존과 동일하게 `camera_pivot.rotation.x`(pitch, 기존 clamp 유지)로 분리했다. `_physics_process()`의 이동 방향 계산을 `camera_pivot.global_transform.basis`에서 `transform.basis`로 변경했다(yaw가 이제 Player 자신에 있으므로). `grab_aim_state_changed(state: int)` 시그널을 추가하고, 매 물리 프레임 `_update_grab_detection()`/`_handle_grab_input()`이 이미 계산해 둔 `_detected_grabbable`/`held_grabbable`만으로 상태(0/1/2)를 판정해 값이 바뀔 때만 발신한다(별도 탐색 없음). `scenes/ui/Crosshair.gd`(`class_name Crosshair extends Control`)를 신규 작성 — `_draw()`로 상태별(기본 점/조준 원/홀드 사각형) 표시, `mouse_filter=IGNORE`, anchors 0.5/0.5 고정 오프셋으로 해상도·화면비와 무관하게 항상 화면 정중앙에 위치한다. `DeliveryHUD.tscn`에 `Crosshair` 노드를 추가하고 `DeliveryHUD.gd`에 `set_crosshair_state(state)` 위임 메서드를 추가했다. `PrototypeLevel.gd`에 `player: Player` 참조를 추가하고 `player.grab_aim_state_changed.connect(delivery_hud.set_crosshair_state)`로 연결했다(기존 `DeliveryZone → PrototypeLevel → DeliveryHUD` 시그널 패턴과 동일). 이 과정에서 `Player.gd`에 `class_name Player`를 추가했다(다른 모든 씬 스크립트가 `class_name`을 갖는 기존 관례와 통일, `PrototypeLevel.gd`에서 타입 참조를 위해 필요) — 동작 변경은 없다. `GrabbableBody.gd`는 전혀 수정하지 않았다(Force-Based Grab 힘 계산·다중 Grab Connection·Player 관통/밀림 방지 구조 무변경).
- 완료 근거(검증): 헤드리스 자동 검증 128개 항목 3회 연속 전부 PASS. Grab 정확도: 4종 오브젝트(Package/PhysicsBarrel/PhysicsCrate/SmallPhysicsBox) 각 20회, 정면 중앙·일반 운반 거리(1.5m)에서 80/80(100%) 첫 클릭 성공. 거리별 Grab: 표면 거리 기준 0.4m/1.5m/2.4m(유효 사거리 내)는 4종 전부 성공, 2.6m(유효 사거리 밖, `GrabShapeCast` 감지거리 2.2m+구체 반경 0.3m=2.5m 기준)는 4종 전부 실패로 정확히 갈렸으며, 모든 경우 조준점 상태(`GRAB_AIM_HOLDING` 등)가 같은 프레임에 일치. 가시선·우선순위: 벽 뒤 대상 5회 시도 중 Grab 성공 0회, 일렬 배치 시 앞 물체 10/10(100%) 선택. 조준점 정렬 오차: `Camera3D.unproject_position()`으로 계산한 화면 투영 좌표와 화면 정중앙의 오차 0px(구조적으로 `GrabShapeCast`가 Camera 원점과 완전히 일치하므로 이론상 항상 0). 입력 반응: Grab/Release/조준점 상태 변경 모두 지연 0~1 physics frame(코드 구조상 같은 `_physics_process()` 호출 내에서 동시에 처리되어 실측으로도 확인). 자기 가림: Player를 360도 회전 + pitch 전 범위로 움직이는 동안 `GrabShapeCast`가 Player 자신을 감지한 횟수 0회, `MeshInstance3D.layers`와 `Camera3D.cull_mask`가 서로 배타적임을 확인. 운반 회귀: 실제 `PrototypeLevel`에서 4종 오브젝트 각각 전진·후진·좌우 이동, 빠른 연속 시점 회전(720도), 좁은 문(`NarrowDoorwayTestArea`) 통과, Player 근처 Release까지 전부 NaN 없음·속도 폭주 없음·Grab 유지·Player 밀림 없음·Player 관통 없음 확인. `--headless --import`, `--headless --quit-after 90` 모두 오류·경고 0건.
  - 검증 중 발견한 테스트 방법론 이슈(게임 코드와 무관, 테스트 스크립트에서만 수정): (1) 좁은 문 통과 테스트 초안에서 Player를 held 상태로 순간이동시키면 `max_grab_distance`(3.0)를 항상 초과해 자동 해제되는 것을 발견 — 실제 플레이는 걸어서 접근하므로 재현되지 않는 아티팩트이며, 테스트를 "이동 전 놓기 → 이동 → 다시 잡기"로 수정해 우회했다. (2) 좁은 문 통과 경로가 `PrototypeLevel`에 이미 배치된 `PackageC`(-4.5,1,-1)와 정확히 겹쳐, Player·held 오브젝트가 그 오브젝트와 부딪혀 속도가 급감/불안정해지는 현상을 발견 — Force-Based Grab과 무관한 테스트 동선 설계 문제로 판단해 해당 테스트에서만 `PackageC`를 제거하도록 수정했다(레벨 자체는 무수정). (3) 문을 지난 뒤 속도를 오래(200프레임) 측정하면 `Floor`(X=-10까지) 밖으로 나가 자유낙하가 "이상 속도"로 오인되는, 이 프로젝트에 기존에도 문서화된 패턴을 재확인 — 이동 프레임 수를 줄이고 수평 성분만 측정하도록 수정했다.
- **상태**: T072/EPIC-05는 계속 `[DONE]`(무변경). T070은 이 Task 착수로 다시 `[BLOCKED]`. T073 승인 전에는 `[DONE]` 처리하지 않는다.

### T073 결함 수정 — RigidBody 질량별 Player Push 차이

- **결함**: 사용자가 "Player가 몸으로 미는 상호작용에서 25kg `PhysicsCrate`가 `SmallPhysicsBox`(5kg)나 `PhysicsBarrel`과 거의 같은 속도로 밀린다"고 보고. `Player.gd`의 `_push_away_rigid_bodies()`는 `push_force`(220.0)를 모든 대상에 동일하게 `apply_central_impulse()`로 가하고 있었으나, 대상의 현재 속도가 `max_push_speed`(고정 절대값 2.0)를 넘으면 push를 멈추는 방식이었다.
- **원인(2단계로 확인)**:
  1. `max_push_speed`가 질량과 무관한 고정 절대값이라, 지속적인 접촉(Player가 계속 밀착해 걷는 상황)에서는 가벼운 물체든 무거운 물체든 결국 같은 `max_push_speed`로 수렴했다(질량이 클수록 수렴이 늦을 뿐, 도달하는 속도 자체는 동일).
  2. 더 근본적으로, `Player.tscn`의 `collision_mask`가 `5`(World+Package)였고 `PhysicsObject`(16, `PhysicsBarrel`/`PhysicsCrate`/`SmallPhysicsBox`가 속한 레이어)를 포함하지 않았다 — `GrabShapeCast`/`_DETECT_LOS_MASK`(21)에는 T064에서 PhysicsObject가 반영됐지만, Player 자신의 물리 `collision_mask`는 갱신되지 않은 채 남아 있었다. 그 결과 Player의 `move_and_slide()`는 이 3종 오브젝트를 `get_slide_collision()`으로 전혀 감지하지 못했고(`_push_away_rigid_bodies()`의 루프 자체가 실행되지 않음), 이들의 이동은 전적으로 Godot/Jolt의 kinematic(Player) vs dynamic(RigidBody) 접촉 해석이 자체적으로 만드는 raw 침투 해소 push에 의한 것이었다 — 이 raw push는 질량과 무관하게 RigidBody를 거의 Player 속도로 맞춰버린다(`DESIGN_DECISIONS.md` DD-006에서 이미 확인된 현상). 헤드리스 실측으로, 정지마찰(245N)이 `push_force`(220N)를 넘는 25kg Crate조차 이 raw push만으로 6m/s 이상 밀리는 것을 확인해 이 raw 채널이 지배적임을 검증했다.
- **수정**:
  - `Player.tscn`: `collision_mask`를 `5`→`21`(World+Package+PhysicsObject)로 수정 — `_DETECT_LOS_MASK`(21)와 동일한 값으로 통일. 이제 `move_and_slide()`가 3종 오브젝트와의 접촉을 정상적으로 `get_slide_collision()`에 보고한다.
  - `Player.gd`: `max_push_speed` export 제거, `_push_away_rigid_bodies()`의 `apply_central_impulse(...*delta)`를 `apply_central_force(push_direction * push_force)`(질량과 무관한 동일 힘, 매 프레임 지속 적용, `a=F/mass`가 자연히 성립)로 교체.
  - `push_mass`(export, 70.0, TODO 프로토타입 값) 신규 추가 — Player가 몸으로 미는 상호작용 전용 유효 질량(운동량 비율 계산용, `CharacterBody3D` 자체의 물리 질량이 아님). 신규 `_apply_push_resistance()`가 `move_and_slide()` 호출 **직전**, 직전 프레임에 실제로 밀고 있던 대상의 질량만을 이용해 reduced-mass 비율(`current_component * push_mass / (push_mass + object_mass)`)로 Player 자신의 전진 속도 성분을 미리 낮춘다. 처음에는 대상의 `linear_velocity`도 함께 참조하는 (반복 계산형) reduced-mass 공식을 시도했으나, 그 `linear_velocity` 자체가 이미 매 프레임 raw push로 오염돼 있어(질량과 무관하게 거의 Player 속도를 반영) 보정이 전혀 누적되지 않음을 헤드리스 실측으로 확인하고 폐기했다 — RigidBody의 속도를 전혀 참조하지 않는 현재의 단순 비율식으로 교체한 뒤에야 실제로 효과가 나타났다. `_push_away_rigid_bodies()`가 매 프레임 끝에 현재 접촉 정보(`push_direction`, `mass`)를 `_active_pushes`에 기록해 다음 프레임 `_apply_push_resistance()`가 사용한다.
  - 잡고 있는(Grab 중) Grabbable에는 Body Push를 중복 적용하지 않는 기존 제외 로직(`collider == held_grabbable`)을 `collider is GrabbableBody and collider.has_grabber(self)`로 일반화(다중 Grabber 구조와 의미상 일치, 동작은 동일).
  - `linear_velocity` 직접 대입, 질량별 속도 multiplier, mass 임시 조작은 전혀 사용하지 않음 — `apply_central_force`/Player 자신의 `velocity` 조정만 사용.
- **검증**: 임시 헤드리스 스크립트(검증 후 삭제)로 21개 항목 3회 연속 실행 전부 PASS. (1) 동일 `BoxShape3D`/`PhysicsMaterial`(friction 0.7), mass만 5/15/20/25로 변경한 격리 비교 — 1초 후 속도 3.65/3.23/2.87/1.34 m/s로 정확히 단조 감소, 25kg이 5kg의 약 37%(≤40% 권장 기준 충족). (2) 실제 4종 오브젝트(1초 연속 접촉) — `SmallPhysicsBox` 2.99, `Package` 2.76, `PhysicsBarrel` 3.22(원통형 굴림으로 예외적으로 잘 이동, 정상), `PhysicsCrate` ≈0(정지마찰 245N > push_force 220N이라 몸으로는 거의 밀리지 않음 — 이제 실제 물리와 일치, Crate가 SmallBox와 같은 속도로 끌려가지 않음 확인). (3) 회귀: Grab 중인 물체에 Body Push 중복 적용 없음(Grab 상태에서 NaN 없음, 폭주 없음), Grab하지 않은 물체는 정상 충돌·정상 Push 유지, Player가 물체를 관통하지 않음, Grab/DeliveryZone 관련 기능 무변화. `--headless --import`, `--headless --quit-after 60` 오류·경고 0건.
- **수정 파일**: `hell-delivery/scenes/player/Player.tscn`(`collision_mask` 5→21), `hell-delivery/scenes/player/Player.gd`(`max_push_speed` 제거, `push_mass` 추가, `_apply_push_resistance()` 신규, `_push_away_rigid_bodies()` 수정).
- **남은 위험**: `push_mass`(70.0)는 사람 평균 체중을 참고한 초기 추정값으로, 여러 후보를 실측 비교하지 않았다 — 사용자 수동 테스트에서 "무거운 물체를 밀 때 Player가 너무 많이/적게 느려진다"고 느끼면 조정이 필요할 수 있다(`TECH_DEBT.md`에 추가 검토 항목으로 남길 만함). `PhysicsCrate`가 이제 몸으로는 거의 밀리지 않게 된 것은 실제 friction/mass 값 기준으로 올바른 결과이지만, 이전까지의(버그가 있던) 체감과 달라지므로 사용자 재확인이 필요하다.
- **상태**: 이 결함 수정을 포함해도 T073은 여전히 `[REVIEW]`(사용자 수동 테스트 대기). T072/EPIC-05는 무변경. T070은 계속 `[BLOCKED]`.

### T073 결함 수정 — Held 상태에서 Body Push가 과도하게 강해지는 문제

- **결함**: 사용자가 "다른 물체(SmallBox/Package)를 잡은 채 몸으로 25kg `PhysicsCrate`를 밀면, 빈손일 때보다 Crate가 훨씬 가벼운 물체처럼 쉽게 밀린다"고 보고. 위 "RigidBody 질량별 Player Push 차이" 결함 수정(직전 항목) 이후에도 재현됨.
- **원인**: 헤드리스 실측(빈손/SmallBox 보유/Package 보유 3종 비교, 3초 연속 접촉)으로 Player가 Crate에 접근하면 **두 채널이 동시에 Crate에 힘을 가한다**는 것을 확인했다 — (1) `_push_away_rigid_bodies()`의 일반 Body Push(`push_force`=220N, `_apply_push_resistance()`로 질량 비율 감쇠), (2) 잡고 있는 물체(SmallBox/Package)가 Player보다 먼저 Crate에 맞닿아 `GrabbableBody._apply_grab_forces()`의 Spring-Damper 힘(최대 `max_force_per_grabber`=300N, 일반 Push보다 큰 상한)을 Crate에 그대로 전달하는 채널. 실측으로 `player_body_touched_crate_directly=true`가 Player 자신이 계속 전진하는 한 빈손/보유 여부와 무관하게 결국 항상 성립함을 확인했다 — 즉 잡은 물체가 먼저 Crate에 닿아 Spring 힘을 전달하는 동안에도 Player 몸이 뒤이어 Crate에 닿으면 일반 Body Push가 **추가로** 적용되어, 같은 대상에 두 힘이 중복 합산되고 있었다. `GrabCollisionBarrier`(layer 32, mask 0)는 Crate의 `collision_mask`(23, bit 32 없음)와 애초에 겹치지 않아 이 경로는 아니었음을 mask 값과 실측(barrier가 Crate와 실제 물리적 충돌을 생성하지 않음)으로 확인.
- **수정**:
  - `GrabbableBody.gd`: `_ready()`에서 `contact_monitor=true`/`max_contacts_reported=8` 활성화(기존 기본값은 비활성이라 실제 접촉 목록을 조회할 수 없었음), 신규 `is_touching(body)` 메서드 추가(`get_colliding_bodies()`에 대상이 있는지만 확인, Spring 힘 계산·`max_force_per_grabber`·질량 등은 전혀 건드리지 않음).
  - `Player.gd`의 `_push_away_rigid_bodies()`: 대상에 `push_force`를 적용하기 전, `held_grabbable != null and held_grabbable.is_touching(collider)`이면 이 프레임의 `apply_central_force()` 호출만 건너뛴다(이미 Grab Spring이 같은 대상에 힘을 전달 중이므로 중복 방지). `_active_pushes` 기록(다음 프레임 `_apply_push_resistance()`가 쓰는 Player 자신의 감속 정보)은 이 경우에도 그대로 유지 — Player 몸이 실제로 그 대상과 접촉했다는 사실 자체는 held 여부와 무관하게 반영되어야 하므로, held 여부에 따라 Player의 감속 계산 방식을 바꾸지 않았다.
  - 일반 Body Push 계산식(`push_force`, `_apply_push_resistance`), `max_force_per_grabber`, Spring-Damper 힘 계산, mass 값은 전혀 변경하지 않음 — held object가 대상과 닿지 않은 프레임에서는 기존과 완전히 동일하게 동작한다.
- **검증**: 임시 헤드리스 스크립트(검증 후 삭제)로 빈손/SmallBox 보유/Package 보유 3종 비교(동일 위치·동일 입력, 3초 연속 접근) — 수정 전 Package 보유 시 Crate 이동 거리 비율 2.00배(빈손 대비)였던 것이 수정 후 1.61배로 감소(권장 기준 1.5배에 근접, 완전히 일치하지는 않음 — 최대 속도 비율은 실측상 변동폭이 있어 이번 수정만으로 모든 지표를 1.5배 이내로 맞추지는 못했다). SmallBox 보유 시에는 원래도 빈손보다 낮은 비율(0.39~0.42배)이라 이번 수정으로 문제되지 않음. 회귀: 질량별 Push 순서(5>15>20>25, 25kg≤5kg의 40%) 3회 연속 PASS, 실제 4종 오브젝트 Push(SmallBox/Package/Barrel/Crate) 정상, Grab 중 물체에 Body Push 중복 미적용, `add_grabber` 성공, collision exception 정상, NaN·속도 폭주·관통 없음, `--headless --import`/`--headless --quit-after 90` 오류·경고 0건. Force-Based Grab 자체(Spring 계산·torque·다중 Grabber·`max_force_per_grabber`)는 무수정이라 별도 회귀 없음(코드 변경 범위 자체가 이를 건드리지 않음).
- **수정 파일**: `hell-delivery/scenes/objects/GrabbableBody.gd`(`_ready()`, `is_touching()` 추가), `hell-delivery/scenes/player/Player.gd`(`_push_away_rigid_bodies()`에 중복 방지 조건 1개 추가).
- **남은 위험**: Package를 보유한 채 Crate에 닿는 경우 이동 거리 비율이 여전히 사용자가 제시한 "1.5배를 크게 초과하지 않음" 초기 기준에 근접하되 완전히 이내는 아니다(1.61배) — Spring Force 자체(최대 300N, `max_force_per_grabber`)가 일반 Body Push(220N, 질량 비율로 추가 감쇠)보다 크게 설계돼 있어 held object가 대상에 닿아 있는 동안에는 어느 정도 더 강하게 밀리는 것이 구조적으로 자연스럽다 — 사용자가 명시한 대로 이 값(`max_force_per_grabber`)과 일반 Push 시스템 자체는 이번 수정에서 건드리지 않았으므로, 남은 차이의 최종 체감 허용 여부는 사용자 수동 테스트로 판단이 필요하다.
- **상태**: 이 결함 수정을 포함해도 T073은 여전히 `[REVIEW]`(사용자 수동 테스트 대기). T072/EPIC-05는 무변경. T070은 계속 `[BLOCKED]`. **(이후 사용자 승인으로 T073 `[DONE]` 확정 — 아래 "T073 사용자 수동 테스트 승인(최종)" 참고)**

### T073 재검증 — 1인칭·조준점·조작성 최종 확인(코드 변경 없음)

- **목적**: 위 두 차례의 Push 결함 수정(Player.gd 3회 수정, GrabbableBody.gd 1회 수정) 이후에도 T073의 원래 구현(1인칭 카메라, 화면 중앙 조준점, 조준점-Grab 판정 공유, HandPoint 구성)이 그대로 유지되는지, 그리고 원래 계획된 수치 기반 조작성 검증 항목이 여전히 통과하는지 재확인한다.
- **조사 결과(수정 전)**: `Player.gd`(카메라 yaw/pitch 분리, `grab_shape_cast`/`hold_point`가 `CameraPivot` 자식, `grab_aim_state_changed` 시그널), `Player.tscn`(`SpringArm3D` 없음, `Camera3D`가 `CameraPivot` 직계 자식, `MeshInstance3D.layers=2` + `Camera3D.cull_mask`가 레이어 2 제외, `GrabShapeCast`가 `CameraPivot` 원점), `scenes/ui/Crosshair.gd`(상태형 조준점, `mouse_filter=IGNORE`), `DeliveryHUD.gd`/`PrototypeLevel.gd`(조준점 상태 연결) 모두 기존 그대로 존재함을 확인 — Push 결함 수정 2건은 `_push_away_rigid_bodies()`/`_apply_push_resistance()`/`GrabbableBody.is_touching()`만 건드려 카메라·조준점·Grab 감지 코드와 겹치지 않는다. **재작성 없이 재검증만 수행**.
- **검증(임시 헤드리스 스크립트, 검증 후 삭제, 3회 연속 실행)**: 총 18개 항목 전부 PASS.
  - Grab 성공률: 4종(SmallBox/Package/Barrel/Crate) × 20회, 정면 유효 조준 상태에서 80/80(100%) 성공.
  - 거리 판정: 4종 × 4개 거리(표면 기준 0.4/1.5/2.4m은 유효 사거리 내, 2.6m은 사거리 밖)에서 16개 전부 기대와 일치(성공/실패 경계 정확).
  - 가시선: 벽 뒤 대상 Grab 시도 5회 중 성공 0회. 일렬 배치 시 앞 물체 선택 10/10(100%).
  - 자기 가림: Player 360도 회전 + pitch 전 범위(`min_pitch`~`max_pitch`) 이동 중 `GrabShapeCast`가 Player 자신을 감지한 횟수 0회, `MeshInstance3D.layers`(2)와 `Camera3D.cull_mask`가 서로 배타적임을 재확인.
  - 입력 반응성: Grab 입력→Connection 생성, Release 입력→Connection 제거, 조준 대상 변경→조준점 상태 변경 모두 같은 물리 tick 내 처리 확인(헤드리스 하네스에서는 `SceneTree.physics_frame` 시그널이 해당 tick의 노드 처리 *직전*에 발신되는 특성 때문에 측정값이 실제보다 1~2 커 보이는 아티팩트가 있어, 원 지연이 아니라 이 오프셋을 보정해 판정).
  - 화면 중앙 정렬: `GrabShapeCast`가 `Camera3D`와 정확히 같은 로컬 원점(오프셋 0.0m)이라 구조적으로 항상 화면 정렬 오차 0px.
  - 실제 레벨(`PrototypeLevel`) 운반 회귀: Package Grab 성공, 전진/후진/좌우 이동·빠른 카메라 회전 중 NaN 없음, 이동 후에도 Grab 유지, Player-Package 관통 없음.
  - Push 회귀(직전 두 결함 수정 유지 확인): 빈손 대비 SmallBox/Package 보유 시 거리비 정상 범위, `GrabCollisionBarrier`가 무관한 Crate에 힘을 전달하지 않음.
- **결론**: T073은 코드 수정 없이 재검증만으로 통과 — 원래 구현이 이후의 Push 결함 수정들과 정상적으로 공존하며, 계획된 자동 조작성 측정 항목(성공률/거리/가시선/자기가림/입력반응/화면정렬/운반회귀)을 모두 충족한다.
- **수정 파일**: 없음(문서만 갱신).
- **남은 위험**: 자동 검증은 조작 편안함·조준점 가독성·멀미 여부 등 주관적 항목을 판단할 수 없다 — 사용자 수동 테스트가 반드시 필요하다. `docs/GAME_DESIGN.md`의 "3인칭 카메라 기본" 서술과 실제 구현(1인칭)의 불일치는 T073 최초 작업 때부터 알려진 상태이며, 이번 재검증 범위에는 포함되지 않았다(아래 "T073 사용자 수동 테스트 승인(최종)"에서 별도로 해결).
- **상태**: T073은 여전히 `[REVIEW]`(사용자 수동 테스트 대기, `[DONE]` 처리하지 않음). T070은 계속 `[BLOCKED]`. EPIC-04 및 목표 버전 완료 처리하지 않음.

### T073 사용자 수동 테스트 승인(최종)

- **사용자 수동 테스트 결과: 승인.** 1인칭 카메라·조준점·Grab 조작성 전체(위 두 차례 Push 결함 수정 포함) 최종 상태로 실제 플레이 테스트를 진행했고, 다음을 모두 확인해 승인함:
  - 1인칭 카메라가 정상 작동
  - 로컬 Player 모델이 시야와 Grab 판정을 가리지 않음
  - 조준점 상태와 실제 Grab 대상이 일치
  - Package 반복 Grab에서 치명적인 오조작 없음
  - 중앙과 모서리 Grab의 torque 차이 정상
  - 운반 중 시야 확보 가능
  - 빠른 카메라 회전 후 Release가 자연스러움
  - 좁은 문, 계단, 경사로 운반 가능
  - held 상태에서 Crate Body Push가 과도하게 강해지지 않음
  - Package 배송과 Restart 회귀 정상
  - 심한 카메라 불편, 관통, NaN, 속도 폭주 없음
- **완료 처리**: 이 승인으로 T073은 `[DONE]`으로 확정한다(섹션 25 상단 상태 갱신). 카메라 눈높이(`CameraPivot` y=0.7), `HoldPoint` 오프셋(1.5m), 조준점 색상/크기 등 T073에서 도입된 프로토타입 값은 이번 승인으로 **사용자 승인된 Baseline**으로 확정되며, 추가 조정 가능성은 남기되 완료를 막는 미해결 결함으로는 취급하지 않는다.
- **문서 동기화**: `docs/GAME_DESIGN.md`의 "3인칭 카메라 기본" 서술(카메라 섹션, 섹션 26, 섹션 32)을 실제 구현(1인칭, T073)과 일치하도록 최소 수정했다 — 핵심 장르/코어 루프/MVP 범위는 변경하지 않고 카메라 시점 서술만 사실과 동기화(`CLAUDE.md` 섹션 9: 사용자의 최신 명시적 지시가 최우선).
- **T070 재개**: 위 섹션 22에서 T070의 `[BLOCKED]`를 해제하고 `[REVIEW]`(사용자 최종 플레이·재미 평가 대기)로 전환했다. 평가 항목을 12개→14개로 확장해 1인칭 카메라 편안함·조준점 일치 항목을 추가했다. EPIC-04(`docs/ROADMAP.md`)와 목표 버전(v0.2.0)은 T070의 실제 최종 재미 평가 결과가 나오기 전까지 완료 처리하지 않는다.

## 26. T074 — Local Co-op Test Environment

- 상태: `[x]` `[DONE]` (구현·자동 검증·사용자 수동 테스트 승인 모두 완료 — 아래 "T074 사용자 수동 테스트 승인(최종)" 참고)
- 목적: v0.2.0 완료 이후 v0.3.0(Fun Physics Update)의 첫 단계로, 로컬 환경에서 실제 Player 2명이 같은 물리 월드를 공유하고 하나의 물체를 동시에 잡을 수 있는 **로컬 2인 물리 검증 기반**을 구현한다. 온라인 멀티플레이가 아니다.
- 소속: `docs/ROADMAP.md` v0.3.0 EPIC-06(Local Co-op Foundation, 신규) — FEATURE-06-A(로컬 2인 분할 화면 테스트 환경)
- 선행 작업: v0.2.0 전체 완료(T070 `[DONE]`, EPIC-01~05 `[DONE]`)
- 작업 범위:
  - `Player.gd`: `InputProfile` enum(KEYBOARD_MOUSE/GAMEPAD) 및 `player_slot`/`input_profile`/`gamepad_device`/`gamepad_look_sensitivity`/`gamepad_deadzone` export 추가. 이동 입력을 `_get_movement_input_2d()`로 추출(GAMEPAD면 왼쪽 스틱+deadzone), 시점 회전을 `_apply_gamepad_look()`으로 추가(오른쪽 스틱, delta 곱)하고 기존 마우스 기반 `_unhandled_input()`은 `input_profile != KEYBOARD_MOUSE`면 즉시 반환하도록 가드. Grab 입력을 `_update_gamepad_grab_edge()`(게임패드 A 버튼, 프레임 간 edge 직접 추적)로 확장하고 `_handle_grab_input()`이 프로필에 따라 마우스 액션 또는 게임패드 edge를 선택하도록 분기. `jump`/`sprint`는 키보드 전용 전역 Input 상태라 `input_profile == KEYBOARD_MOUSE`로 게이트(안 그러면 한 Player의 Space/Shift가 다른 Player에도 적용되는 누수가 있었음 — 아래 "발견한 결함" 참고). `_apply_visual_layer_for_slot()` 신규 — `player_slot`마다 다른 시각 레이어를 계산해 MeshInstance3D.layers/Camera3D.cull_mask에 적용(slot 0 결과는 T073의 기존 고정값과 완전히 동일).
  - `Player.tscn`: `collision_mask`를 21→23(World+**Player**+Package+PhysicsObject)으로 수정 — Player끼리 전혀 충돌하지 않던 결함 수정(아래 참고). `layers=2`/`cull_mask=1048573` 하드코딩 값은 그대로 두되(초기값), `_ready()`가 매번 재계산해 덮어씀.
  - `scenes/level/LocalCoopTest.tscn`/`LocalCoopTest.gd` 신규 — `PrototypeLevel.tscn`을 통째로 인스턴스해 레벨·물리 오브젝트·Package·DeliveryZone을 재사용(중복 생성 없음)하고, 같은 `Gameplay` 아래 `Player2`(`player_slot=1`, `input_profile=GAMEPAD`)를 형제 노드로 추가. `SplitScreen`(CanvasLayer) 아래 `HBoxContainer`로 좌우 50/50 `SubViewportContainer` 2개를 배치하고, 각 `SubViewport`의 `world_3d`를 메인 뷰포트의 `world_3d`와 동일하게 설정(물리 월드 공유, 레벨 미중복)해 그 안에 `ViewCamera`(현재 카메라, 매 프레임 해당 Player의 실제 Camera3D transform을 복사)와 전용 `Crosshair`를 배치, 각각 해당 Player의 `grab_aim_state_changed`에 연결. 기존 `DeliveryHUD`의 조준점은 숨기고 성공 패널은 그대로 공유 사용.
- 제외 범위: 온라인 멀티플레이, RPC/네트워크 동기화, Steam 기능, 로비/매칭, 캐릭터 선택, 정식 메뉴 UI, 3인 이상, 기존 물리 수치 전면 재튜닝, `LocalCoopTest.tscn`을 Main Scene으로 지정.
- 생성 파일: `hell-delivery/scenes/level/LocalCoopTest.tscn`, `hell-delivery/scenes/level/LocalCoopTest.gd`
- 수정 파일: `hell-delivery/scenes/player/Player.gd`, `hell-delivery/scenes/player/Player.tscn`
- 에디터 수동 작업: 없음(전부 텍스트 편집, headless import/boot로 구조 검증). 실제 게임패드 연결·분할 화면 렌더링 확인은 사용자 수동 테스트 필요.
- **실행 방법**: Godot 에디터에서 `scenes/level/LocalCoopTest.tscn`을 열어 F6(현재 씬 실행)으로 실행한다. `project.godot`의 `run/main_scene`은 `PrototypeLevel.tscn` 그대로 두어(F5는 여전히 싱글플레이 실행), 이 Task 단계에서 협동 Scene을 기본 Main Scene으로 바꾸지 않는다.
- **발견한 결함(구현 중 발견, 함께 수정)**:
  1. `Player.tscn`의 `collision_mask`(21)에 Player 자신의 레이어(2)가 빠져 있어, 실제로 Player끼리는 전혀 물리적으로 충돌하지 않고 있었다(bidirectional-OR 규칙상 양쪽 다 상대 레이어를 마스크에 포함하지 않으면 접촉 쌍 자체가 생기지 않음) — `collision_mask`를 23으로 수정해 해결.
  2. `Input.is_action_pressed("sprint")`/`Input.is_action_just_pressed("jump")`가 전역 상태를 그대로 읽고 있어, 로컬 협동에서 한 Player가 Shift/Space를 누르면 **다른 Player도** 질주·점프해버리는 입력 누수가 있었다 — `input_profile == KEYBOARD_MOUSE`로 게이트해 해결(게임패드 슬롯은 원래 이 두 동작을 지원하지 않으므로 조용히 무시).
- **완료 조건**: 로컬 협동 Scene에서 Player 2명이 같은 물리 월드 공유, 좌우 분할 화면, 입력 슬롯 분리, Crosshair 독립, 실제 2인 동시 Grab(Grabber 수 0→1→2→1→0), GrabCollisionBarrier/충돌 예외가 연결 단위로 정상 동작, Player 간 비관통·비폭주 충돌, 싱글플레이 무회귀 — 모두 자동 검증으로 확인.
- 테스트 방법: `godot --headless --import`, `--headless --quit-after`로 파싱/부팅 오류 확인. 임시 헤드리스 `SceneTree` 스크립트(검증 후 삭제)로 `LocalCoopTest.tscn`을 직접 인스턴스해 46개 항목을 3회 연속 검증: 구조(Player 2개·별개 시각 레이어·SubViewport world_3d 공유, 12개), 입력 독립성(키보드 전진 시 P2 무변위, 게임패드 전진 시 P1 무변위, sprint 전역 누수 없음, 5개), Grab 입력 독립성(한쪽 Grab 입력이 다른 쪽 `held_grabbable`에 영향 없음, 2개), Crosshair 독립성(한쪽만 조준 시 반대쪽 Crosshair 상태 불변, 3개), 실제 2인 동시 Grab(Grabber 수 순서·서로 다른 Grab Point·충돌 예외·release 순서, 14개), 1인 vs 2인 Crate 들어올리기 비교(2인이 더 높이·목표 오차 더 작음, 3개), Player 간 충돌(관통 없음·정지 후 표류 없음, 3개), 싱글플레이 회귀(`PrototypeLevel.tscn` 단독 실행, 기존 값 무변경, Package Grab 정상, 4개).
- 완료 근거(검증): 헤드리스 자동 검증 46개 항목 3회 연속 전부 PASS. 구조: Player1(KEYBOARD_MOUSE)·Player2(GAMEPAD) 별개 인스턴스, 서로 다른 `MeshInstance3D.layers`, 각 뷰 카메라 `cull_mask`가 자기 Player만 제외하고 상대는 그대로 보이게 함, 두 SubViewport가 메인 뷰포트와 동일한 `World3D` 공유(레벨 미중복) 확인. 입력 독립성: 키보드 `move_forward`(30프레임) 시 P1 변위 >0.3m·P2 변위 <0.05m, 게임패드 왼쪽 스틱(`InputEventJoypadMotion` 합성 입력, 30프레임) 시 P2 변위 >0.3m·P1 변위 <0.05m, P1이 `sprint`를 누른 채 P2가 게임패드로 이동해도 P2 추정 속도가 `sprint_speed`에 도달하지 않음(전역 상태 누수 없음) 확인. Grab 입력 독립성: 한쪽의 `grab_object`/게임패드 A 버튼 입력이 반대쪽 `held_grabbable`을 바꾸지 않음 확인. Crosshair 독립성: Player1만 Package를 조준한 순간 왼쪽 Crosshair만 조준 상태(1), 오른쪽은 기본 상태(0) 확인. 실제 2인 동시 Grab: `add_grabber`로 Player1→Grabber 수 1, Player2(다른 지점)→Grabber 수 2, 두 `local_grab_point`가 서로 다름, Package가 Player1·Player2 실제 Body 모두와 collision exception 관계이면서 관통 없음, Player1 release→Grabber 수 1(Player2 연결 유지)→Player2 release→Grabber 수 0, 이후 NaN·속도 폭주 없이 자유 낙하 확인. 1인 vs 2인: 동일 Crate·동일 시간(2초) 조건에서 2인이 1인보다 더 높이 들어올리고(1인 height≈1.86m vs 2인≈2.26m) 목표점 오차가 더 작음(1인≈0.64m vs 2인≈0.24m) — `max_force_per_grabber`(300N) 그대로 두 Grabber의 힘이 합산된 결과이며 별도의 인원수 배율은 사용하지 않음. Player 간 충돌: 서로를 향해 걸어 접근시켜도 최소 거리 1.0m 초과(capsule 반지름 합 이상) 유지, 입력을 멈춘 뒤 30프레임 동안 위치·속도 완전히 정지(표류 없음, kinematic-vs-kinematic 접촉이 폭발적 반발을 일으키지 않음 확인). 싱글플레이 회귀: `PrototypeLevel.tscn` 단독 실행 시 Player의 `input_profile` 기본값·`MeshInstance3D.layers`(2)·`Camera3D.cull_mask`(1048573)가 T073 이전과 완전히 동일하고 Package Grab이 정상 동작. `--headless --import`, `--headless --quit-after 120`(실제 Main Scene) 오류·경고 0건.
  - 검증 중 발견한 테스트 방법론 이슈(게임 코드와 무관, 테스트 스크립트에서만 수정): (1) 첫 시도에서 Player-간-충돌 테스트를 좌표 (40,1.5,40) 부근에 배치했는데, 이는 실제 Floor(대략 X/Z -10~10) 밖이라 테스트 내내 자유낙하 중이었던 것을 뒤늦게 발견 — Floor 위 좌표(0,1.5,-9)로 옮겨 재검증했다. (2) 연속된 하위 테스트 사이에 Player의 감속(`deceleration=25.0`)이 끝나기 전(3프레임만 대기)에 다음 측정을 시작해 잔류 관성이 "입력 누수"로 오인된 아티팩트를 발견 — 하위 테스트 사이 대기 프레임을 늘려(20프레임) 해결.
- 예상 위험:
  - `gamepad_look_sensitivity`(2.5)·`gamepad_deadzone`(0.2)는 실측 후보 비교 없는 초기 추정값 — 사용자 수동 테스트에서 너무 둔하거나 예민하면 조정 필요.
  - Grab 버튼을 오른쪽 트리거(아날로그) 대신 `JOY_BUTTON_A`(디지털 페이스 버튼)로 선택했다 — 임계값 튜닝을 피하기 위한 의도적 선택이며, 사용자가 트리거를 선호하면 별도로 변경 가능.
  - 로컬 Player Mesh 은닉용 시각 레이어를 `player_slot`으로 동적 계산하도록 바꿨다(T073의 정적 하드코딩 대체) — 3인 이상으로 확장 시(이번 범위 밖) 레이어 개수(20개 제한)를 고려한 재검토가 필요할 수 있다.
  - 분할 화면 `SubViewportContainer` 2개가 화면 전체를 덮어도, 메인/루트 뷰포트 자체는 여전히 어떤 Player의 실제 Camera3D를 기준으로 별도 렌더링을 시도할 수 있어 약간의 렌더링 낭비가 있다 — 기능적으로 화면에는 영향 없으나(완전히 가려짐), 최적화 대상은 아니라 이번 범위에서는 손대지 않았다.
  - 실제 게임패드 연결 상태에서의 입력 반응감, 분할 화면 렌더링 품질, 두 SubViewport의 해상도 배분은 헤드리스로 확인할 수 없어 사용자 수동 테스트가 반드시 필요하다.
- **상태**: 사용자 수동 테스트 전까지 `[REVIEW]` 유지. v0.3.0과 Milestone 2는 완료 처리하지 않는다. v0.2.0 완료 상태는 변경하지 않는다. **(이후 사용자 승인으로 `[DONE]` 확정 — 아래 참고)**

### T074 사용자 수동 테스트 승인(최종)

- **사용자 수동 테스트 결과: 승인.** 로컬 2인 협동 기능(입력 슬롯 분리, 분할 화면, Player 간 충돌, 실제 2인 동시 Grab)이 정상 작동함을 확인함.
- **완료 처리**: 이 승인으로 T074는 `[DONE]`으로 확정한다(섹션 26 상단 상태 갱신).
- **TD-014 확정**: `gamepad_look_sensitivity`(2.5)·`gamepad_deadzone`(0.2)는 이번 승인으로 **사용자 승인된 프로토타입 기준값(Baseline)**으로 확정한다 — T061/T072와 같은 성격("여러 후보 실측 비교"는 아직 거치지 않은 초기값이지만, 완료를 막는 미해결 결함으로는 취급하지 않음). `docs/TECH_DEBT.md` TD-014에 반영.
- **EPIC-06/v0.3.0**: 아직 완료 처리하지 않는다 — T075(Local Co-op Interaction UX)가 이어서 진행된다.

## 27. T075 — Local Co-op Interaction UX

- 상태: `[x]` `[DONE]` (구현·자동 검증·사용자 수동 테스트 승인 모두 완료 — 아래 "T075 사용자 수동 테스트 승인(최종)" 참고)
- 목적: T074에서 확보한 로컬 2인 협동의 물리적 기반(동시 Grab, 분할 화면, 입력 슬롯 분리) 위에, 각 Player가 "누가 무엇을 잡고 있는지·같은 물체를 함께 잡고 있는지·물체의 어느 지점을 잡았는지·연결이 왜 끊겼는지·P2 게임패드 조작이 편안한지"를 직관적으로 알 수 있도록 UX를 보강한다. 기존 Force-Based Physics Grab과 물리 수치(spring/damping/max_force 등)는 변경하지 않는다.
- 소속: `docs/ROADMAP.md` v0.3.0 EPIC-06(Local Co-op Foundation) — FEATURE-06-A 후속
- 선행 작업: T074 `[DONE]`(사용자 수동 테스트 승인 완료)
- 작업 범위:
  1. **P2 게임패드 조작 개선**(`Player.gd`): 기존 단일 `gamepad_deadzone`을 `move_deadzone`(왼쪽 스틱)/`look_deadzone`(오른쪽 스틱) 두 export로 분리, `invert_gamepad_y`(오른쪽 스틱 상하 반전, 기본 false) 추가. Grab 입력을 오른쪽 트리거(`JOY_AXIS_TRIGGER_RIGHT`, 임계값 `gamepad_grab_trigger_threshold=0.5`)와 A 버튼의 OR 조합으로 확장(`_update_gamepad_grab_edge()`) — 두 입력이 동시에 눌려도 중복 Connection이 생기지 않고, 하나만 떼도 남은 입력이 눌려 있으면 즉시 Release되지 않도록(`pressed = trigger_pressed or button_pressed`로 단일 edge만 추적) 구현. P1 키보드/마우스 입력 경로는 전혀 건드리지 않음.
  2. **Player별 Grab Point 표시**(`GrabbableBody.gd`): `add_grabber()` 성공 시 해당 Grabber 전용 절차적 마커(`SphereMesh`, 반지름 0.04m, `SHADING_MODE_UNSHADED`)를 물체의 **자식 노드**로 생성해 `position = local_grab_point`로 고정 — 별도 프레임 동기화 없이 물체 이동/회전에 자동으로 따라감. Player 슬롯별 색 구분(slot 0=시안, slot 1=주황), CollisionShape 없음(물리 미참여). `remove_grabber()`/자동 해제 시 해당 Grabber 마커만 `queue_free()`(다른 Grabber 마커는 유지).
  3. **동시 Grab 피드백**(`LocalCoopTest.gd`/`.tscn`): 각 SubViewport에 `CoopStatus` Label(기본 숨김) 추가, `_physics_process()`에서 자기 Player의 `held_grabbable.get_grabber_count() >= 2`일 때만 표시. 같은 물체를 둘 다 잡을 때만 켜지고, 한쪽이 release하는 즉시(다음 physics frame 이내) 꺼짐. 각 Crosshair 상태는 기존과 동일하게 완전히 독립적으로 유지.
  4. **Release 피드백**(`GrabbableBody.gd`/`Crosshair.gd`/`LocalCoopTest.gd`): `GrabbableBody`에 `DisconnectReason` enum(MANUAL/DISTANCE_EXCEEDED/BLOCKED)과 `grabber_disconnected(grabber, reason)` 시그널 추가, `Player.gd`에 이를 중계하는 `grab_connection_lost(reason)` 시그널 추가. `Crosshair.gd`에 `flash(color)` 추가 — 사용자가 직접 놓은 경우(MANUAL)는 별도 표시 없이 조준점 상태 변화만으로 충분하다고 보고 점멸하지 않으며, DISTANCE_EXCEEDED(주황)·BLOCKED(빨강)만 0.4초 짧게 링 점멸. 텍스트 없음, 상대 Player가 여전히 들고 있으면 그 화면에는 아무 표시도 하지 않음(자기 연결 해제만 자기 화면에 표시).
  5. **분할 화면 HUD 정리**(`LocalCoopTest.tscn`): 각 SubViewport의 Crosshair를 화면 정중앙(`anchor 0.5/0.5`)에 고정, `PlayerTag` Label(좌상단, "P1"/"P2")과 `CoopStatus` Label(하단 중앙)을 기존 `DeliveryHUD`와 겹치지 않게 배치. 싱글플레이(`PrototypeLevel.tscn` 단독 실행)는 이 씬을 전혀 거치지 않으므로 기존 HUD 형태가 그대로 유지됨.
- 제외 범위: Force-Based Physics Grab의 물리 수치 변경, Player-vs-Player 충돌 로직 대규모 수정, 온라인 멀티플레이, 정식 메뉴/설정 UI, 3인 이상 지원, `LocalCoopTest.tscn`을 Main Scene으로 지정.
- 생성 파일: 없음(T074에서 생성된 `LocalCoopTest.tscn`/`.gd`를 수정)
- 수정 파일: `hell-delivery/scenes/player/Player.gd`, `hell-delivery/scenes/objects/GrabbableBody.gd`, `hell-delivery/scenes/ui/Crosshair.gd`, `hell-delivery/scenes/level/LocalCoopTest.gd`, `hell-delivery/scenes/level/LocalCoopTest.tscn`
- 에디터 수동 작업: 없음(전부 텍스트 편집). 실제 게임패드 드리프트 체감, 마커 시인성, 점멸 타이밍 체감은 사용자 수동 테스트 필요.
- 완료 조건: 게임패드 10초 무입력 드리프트 사실상 0, P1/P2 최고 이동 속도 일치, 트리거+A 동시 입력 시 중복 Connection·조기 Release 없음, Grab Point 마커가 실제 `local_grab_point`를 오차 0.03m 이내로 표시하고 이동/회전 중에도 추종, 동시 Grab 시에만 양쪽 협동 HUD 표시(0→1→2→1→0 정상 순서), Release 사유별 점멸 구분, 싱글플레이·좁은 문·Barrier 회귀 없음 — 모두 자동 검증으로 확인.
- 테스트 방법: 임시 헤드리스 `SceneTree` 스크립트(검증 후 삭제)로 `LocalCoopTest.tscn`을 직접 인스턴스해 39개 항목을 3회 연속 검증: 게임패드 드리프트(10초 무입력, 위치·yaw·pitch 변화, 3개), 최대 입력(P1/P2 최고 속도 비교, 180도 회전 소요 시간·프레임당 회전량, 3개), 입력 독립성 재검증(키보드/게임패드 이동 상호 무간섭, 2개), 트리거+A 동시 입력(중복 없음, 유지, 동시 해제, 순서 무관 재확인, 정리, 5개), Grab Point 표시(생성 개수, 위치 오차, 물리 미참여, Player별 색 구분, 이동/회전 추종, 개별 release 시 표시 개수 순서 0→1→2→1→0, 11개), 협동 HUD(1명/2명/release/다른 물체, 4개), Release 피드백(점멸 없음/거리초과 자동 해제/점멸함/수동 무점멸, 4개), 좁은 문 및 기타 회귀(NaN 없음, 자유낙하 없음, Barrier 무관 Crate 무영향, 3개), 싱글플레이·Delivery·Restart 회귀(4개).
- 완료 근거(검증): 헤드리스 자동 검증 39개 항목 3회 연속 전부 PASS. 드리프트: 10초간 위치 변화 0.0m, yaw 변화 0.0deg, pitch 변화 0.0deg(입력 없음, 완전 정지). 최대 속도: P1=4.0, P2=4.0(`walk_speed`와 동일, 차이 0%). 180도 회전: 소요 시간 약 1.267초, 프레임당 최대 회전 약 2.39deg(60fps 기준 상한 30deg/frame 대비 여유 큼, 폭주 없음). 트리거+A: 동시 입력 시 Connection 1개만 생성, 한쪽만 떼도 유지, 둘 다 떼야 Release, 순서를 바꿔도(A 먼저→트리거 추가) 중복 없음. Grab Point 표시: 마커 위치가 `local_grab_point`와 오차 0.03m 이내 일치, `CollisionObject3D` 아님·자식 없음(물리 미참여 확인), Player1(시안)·Player2(주황) 마커 색 다름, 60프레임 이동/회전 후에도 마커의 `global_position`이 실제 계산된 `local_grab_point`의 world 좌표와 오차 0.001m 이내(자식 노드 로컬 좌표라 항상 일치), Player1만 release 시 Player1 마커만 사라지고 Player2 마커는 유지, 모두 release 후 표시 0개(원래 자식 2개만 남음). 협동 HUD: 1명만 잡았을 때 양쪽 다 표시 없음, 2명이 같은 물체를 잡으면 1 physics frame 이내 양쪽 다 표시, 1명이 release하면 1 physics frame 이내 양쪽 다 표시 해제, 서로 다른 물체를 각각 잡을 때는 표시 0회. Release 피드백: Grab 직후에는 점멸 없음, 강제로 거리를 벌려 `DISTANCE_EXCEEDED`로 자동 해제되면 해당 Crosshair만 점멸, 수동 Release(`remove_grabber` 직접 호출)는 점멸하지 않음. 좁은 문 및 회귀: 좁은 문 통과 시도 중 NaN 없음, 두 Player 모두 자유낙하 없음(Y 좌표 정상 범위 유지), Barrier가 무관한 Crate를 밀지 않음(속도 거의 0). 싱글플레이·Delivery·Restart: `input_profile` 기본값 유지, Package만 DeliveryZone 성공 판정, PhysicsCrate는 성공 판정에 관여하지 않음. `--headless --import`, `--headless --quit-after 60`(실제 Main Scene) 오류·경고 0건.
  - 검증 중 발견한 테스트 방법론 이슈(게임 코드와 무관, 테스트 스크립트에서만 수정): Grab Point 표시 검증에서 이전 하위 섹션들(최대 속도·180도 회전 등)이 남긴 두 Player의 위치·회전 누적 상태를 그대로 이어받아 물체를 배치했더니, Player2의 `hold_point`가 `max_grab_distance`(3.0m) 밖에 위치해 `add_grabber()`는 성공(`true`)했지만 바로 다음 physics frame의 `_apply_grab_forces()`에서 거리 초과로 즉시 자동 해제되는 현상이 있었다(게임 코드는 설계대로 정상 동작 — Release 피드백 섹션에서 이미 검증한 것과 같은 정상적인 자동 해제 경로). Player2의 현재(이미 바닥 위에서 검증된) 위치를 기준으로 두 Player를 서로 마주보게 명시적으로 재배치한 뒤 실제 `hold_point.global_position`으로 물체 위치를 계산하도록 테스트 스크립트를 수정해 해결.
- 예상 위험:
  - `gamepad_grab_trigger_threshold`(0.5)·`invert_gamepad_y`(기본 false)는 이번에 새로 도입된 프로토타입 값으로, 여러 후보 실측 비교를 거치지 않았다 — 사용자 수동 테스트에서 트리거 반응감이 너무 이르거나 늦으면 조정 필요.
  - `move_deadzone`/`look_deadzone`은 T074의 단일 `gamepad_deadzone`(0.2, 사용자 승인된 Baseline)을 그대로 승계해 둘 다 0.2로 분리했을 뿐, 이동/시점을 서로 다른 값으로 튜닝하지는 않았다 — 실제 사용 중 둘 중 하나만 불편하면 개별 조정 가능.
  - Grab Point 마커·협동 HUD·Release 점멸은 헤드리스 자동 검증으로 "정확한 좌표·타이밍"만 확인했고, 실제 화면에서의 시인성(마커 크기, 점멸 눈에 띄는 정도, 텍스트 가독성)은 사용자 수동 테스트가 반드시 필요하다.
- **상태**: 사용자 수동 테스트 전까지 `[REVIEW]` 유지. EPIC-06과 v0.3.0은 완료 처리하지 않는다. v0.2.0 완료 상태는 변경하지 않는다. **(이후 사용자 승인으로 `[DONE]` 확정 — 아래 참고)**

### T075 사용자 수동 테스트 승인(최종)

- **사용자 수동 테스트 결과: 현재 구현 상태로 승인.** Grab Point 표시, 동시 Grab 협동 HUD, Release 피드백, P2 게임패드 조작(트리거+A OR 조합, `move_deadzone`/`look_deadzone` 분리)이 정상 작동함을 확인함.
- **완료 처리**: 이 승인으로 T075는 `[DONE]`으로 확정한다(섹션 27 상단 상태 갱신).
- **Baseline 확정**: 현재 게임패드 설정값(`gamepad_look_sensitivity=2.5`, `move_deadzone=0.2`, `look_deadzone=0.2`, `invert_gamepad_y=false`, `gamepad_grab_trigger_threshold=0.5`)과 협동 HUD 표시 방식(2인 동시 Grab 시 "협동 운반" 텍스트, Grab Point 마커, Release 점멸)을 **현재 프로토타입 기준값(Baseline)**으로 기록한다.
- **TD-015 유지**: `gamepad_grab_trigger_threshold`·`invert_gamepad_y`는 이번 승인에도 불구하고 여러 후보 실측 비교를 거치지 않은 값이므로, 완료를 막지 않는 **비차단(non-blocking) 튜닝 항목**으로 `docs/TECH_DEBT.md` TD-015에 유지한다.
- **EPIC-06/v0.3.0**: 아직 완료 처리하지 않는다 — T076(Local Co-op Final Validation, 전체 플레이 흐름 통합 검증)이 이어서 진행된다.

## 28. T076 — Local Co-op Final Validation

- 상태: `[x]` `[DONE]` (사용자 최종 협동 테스트 승인 + Held Light Object Push 결함 발견·수정·사용자 재검증 승인까지 모두 완료 — 아래 "T076 재오픈", "T076 결함 수정", "T076 재오픈 결함 사용자 재검증 승인(최종)" 참고. 중간의 `[BLOCKED]` 이력은 삭제하지 않고 그대로 보존함)
- 목적: 새 기능을 추가하지 않고, T074~T075에서 구현된 로컬 2인 협동 기능(입력 슬롯 분리, 실제 2인 동시 Grab, Grab Point 표시, 협동 HUD, Release 피드백)이 `LocalCoopTest.tscn`의 **전체 플레이 흐름**(Spawn → 독립 이동 → 서로 다른 물체 Grab → 같은 Package 동시 Grab → 한 명만 Release → Crate 1인/2인 운반 비교 → 좁은 문 통과 → 배송 → Restart → 재Grab)에서 통합적으로 안정적인지 확인한다.
- 소속: `docs/ROADMAP.md` v0.3.0 EPIC-06(Local Co-op Foundation) — FEATURE-06-B 최종 검증 단계
- 선행 작업: T075 `[DONE]`(사용자 수동 테스트 승인 완료)
- 작업 범위: 통합 검증(자동 헤드리스 테스트)만 수행. 명확한 실행 불가 결함이 발견된 경우에만 최소 수정.
- 발견한 결함(구현 중 발견, 최소 범위로 수정): `LocalCoopTest.gd`에 `PrototypeLevel.gd`와 달리 `restart` 입력 처리가 전혀 없어, 로컬 협동 씬에서는 R키를 눌러도 아무 효과가 없었다(요구된 검증 흐름의 "Restart" 단계 자체를 실행할 수 없는 결함) — `PrototypeLevel.gd`의 기존 패턴(`event.is_action_pressed("restart")` 시 `get_tree().reload_current_scene()`)을 그대로 승계해 `_unhandled_input()`에 추가. 새 기능이 아니라 기존에 이미 있어야 했던 동작의 누락을 보완한 것이며, Input Map 변경도 없다(기존 `restart` 액션 그대로 재사용).
- 제외 범위: Force-Based Grab 물리값 변경, 새로운 UX 기능 추가, `Player.gd`/`GrabbableBody.gd`/`Crosshair.gd` 로직 변경(Restart 처리 1건 제외), 버전 번호 변경, Git 작업
- 생성 파일: 없음
- 수정 파일: `hell-delivery/scenes/level/LocalCoopTest.gd` (Restart 입력 처리 추가)
- 에디터 수동 작업: 없음(전부 텍스트 편집). 실제 게임패드·분할 화면 체감, 재미 평가는 사용자 최종 테스트 필요.
- 완료 조건: 전체 플레이 흐름 10단계가 순서대로 오류 없이 진행되고, 입력·화면 독립성, 동시 Grab 순서(0→1→2→1→0), Crate 1인/2인 비교(2인이 확실히 더 우수, 인원수 배율 없음), 좁은 문 통과, Delivery(2인 Grab 중 포함), Restart 후 전체 상태 초기화, 싱글플레이 회귀가 모두 자동 검증으로 확인됨.
- 테스트 방법: 임시 헤드리스 `SceneTree` 스크립트(검증 후 삭제)로 `LocalCoopTest.tscn`을 직접 인스턴스해 46개 항목을 3회 연속 검증: 입력·화면 독립성 통합 재확인(2개), 서로 다른 물체 동시 Grab(4개), 같은 Package 동시 Grab 0→1→2→1→0 순서(12개), Crate 1인/2인 운반 비교(5개), 좁은 문 순차 통과(5개), DeliveryZone 배송(2인 Grab 중 포함, 3개), Restart-동등(새 인스턴스 상태 초기화 확인, 9개), 싱글플레이 회귀(6개).
- 완료 근거(검증): 헤드리스 자동 검증 46개 항목 3회 연속 전부 PASS. 입력·화면 독립성: P1 키보드 전진 시 P1만 이동(P2 무변위), P2 게임패드 전진 시 P2만 이동(P1 무변위) 재확인. 서로 다른 물체: P1이 box_a, P2가 box_b를 동시에 잡아도 `held_grabbable`이 서로 바뀌지 않고 각 물체 Grabber 수 1(협동 표시 대상 아님), 정리 후 둘 다 0. 같은 Package 순서: Grab 전 0 → P1 Grab 후 1(양쪽 협동 표시 없음, P1 마커만) → P2 Grab 후 2(1 physics frame 이내 양쪽 협동 표시, 두 마커 모두 존재) → P1 release 후 1(P2 연결 유지, 1 physics frame 이내 양쪽 협동 표시 해제, P1 마커만 사라짐) → 모두 release 후 0(마커 0개). Crate 1인/2인 비교(카메라를 위로 향해(pitch +55°) HoldPoint를 Crate보다 충분히 높은 곳에 두어 스프링이 오래 포화 상태를 유지하도록 구성): P1 단독 상승 0.240m(오차 0.018m), P2 단독 상승 0.240m(오차 0.018m, P1과 사실상 동일 — 대칭 설정이므로 예상대로), 협동 상승 1.472m(오차 0.515m)로 1인 대비 확실히 더 높음, 세 조건 모두 2초 동안 연결 유지·NaN/속도 폭주 없음, `grab_spring_strength`/`max_force_per_grabber`는 인원수와 무관한 상수이므로 인원수 배율이 코드에 존재하지 않음을 재확인. 좁은 문(NarrowDoorwayTestArea는 X=-7 평면을 Z -1.7~-0.3 구간만 뚫어둔 구조라 실제 통과 방향이 X축임을 재확인): P1·P2 모두 4초 이내 정체 없이 통과, NaN 없음, 속도 폭주(발사) 없음, 자유낙하 없음. Delivery: 두 명이 잡은 상태로 Package를 DeliveryZone에 넣어도 배송 판정 정상, PhysicsCrate는 여전히 배송 판정에 관여하지 않음. Restart-동등(완전히 새 씬 인스턴스로 교체): P1/P2 위치가 씬 기본값으로 복구, Grab Connection 0개, Grab Point marker 0개, 협동 HUD 숨김, DeliveryZone 미배송 상태로 초기화, collision exception 0개, 이후 다시 정상적으로 Grab 가능. 싱글플레이 회귀: `input_profile`/`player_slot` 기본값 유지, 키보드 이동·1인칭 Camera·Force-Based Grab·Delivery 모두 정상. `--headless --import`, `--headless --quit-after 60` 오류·경고 0건.
  - 검증 중 발견한 테스트 방법론 이슈 3건(게임 코드와 무관, 테스트 스크립트에서만 수정): (1) 좁은 문 통과 방향을 처음에 Z축으로 오인해 실제 문 구조(X=-7 평면을 Z구간만 뚫어둔 형태)와 다르게 접근시켰다가 항상 "정체"로 오판정됨을 발견 — 실제 벽 Shape 크기를 다시 계산해 X축 통과로 수정. (2) Crate 1인/2인 비교에서 Player가 Crate 바로 옆(가까운 거리)에서 들면 스프링이 금방 평형에 도달해 상승량이 거의 0에 가까워 1인/2인 차이가 드러나지 않음을 발견 — 카메라를 위로(pitch +55°) 향하게 해 HoldPoint를 충분히 높은 곳에 두는 방식으로 변경(T072/T074의 "확실한 차이" 측정 취지를 재현). (3) 이전 섹션에서 release 후에도 근처에 계속 서 있던 Player, 그리고 이전 섹션이 남긴 Package가 다음 섹션의 Crate teleport 위치와 겹쳐 순간적으로 밀려나는 아티팩트 2건을 발견 — Player를 release 즉시 멀리 격리하고, Crate 비교 섹션에 별도의 격리된 위치(`CRATE_BENCH_POS`)를 사용해 우회.
- 예상 위험:
  - Crate 1인/2인 비교는 실제 플레이 자세(선 채로 위를 올려보는 각도)를 반영한 합성 힘 테스트로, 실제 사용자가 이런 각도로 오래 들고 있을 일은 드물다 — 일상적인 낮은 각도에서의 체감(스프링이 빠르게 평형에 도달해 상승감이 약함)은 사용자 수동 테스트로만 확인 가능.
  - 좁은 문·Crate 비교의 정확한 좌표는 이번 검증에서 처음 정밀하게 재계산된 것으로, 향후 레벨 지오메트리가 바뀌면 테스트 좌표도 갱신이 필요하다(테스트 전용 상수라 게임 코드에는 영향 없음).
- **상태**: 사용자 최종 협동 테스트 전까지 `[REVIEW]` 유지. EPIC-06과 v0.3.0, Milestone 2는 완료 처리하지 않는다. **(이후 사용자 최종 승인으로 `[DONE]` 확정 — 아래 참고)**

### T076 사용자 최종 협동 테스트 승인(최종)

- **사용자 최종 협동 테스트 결과: 승인.** 14개 항목(P1/P2 독립 이동·시점, 양쪽 Crosshair/HUD 가독성, 서로 다른 물체 동시 Grab, 같은 Package 동시 Grab, 한 명만 Release 시 나머지 연결 유지, P1/P2 단독 Crate 무게감 비교, 1인/2인 운반 차이, 좁은 문 협동 운반, Player 간 관통·튕김 여부, Trigger+A 편의성, Grab Point marker/협동 HUD 시인성, Package 배송, Restart 후 초기화, 전체 협동 재미와 조작성) 전부 문제 없음으로 확인, 치명적인 입력·물리·충돌·HUD 결함 없음.
- **완료 처리**: 이 승인으로 T076은 `[DONE]`으로 확정한다(섹션 28 상단 상태 갱신). 헤드리스 자동 검증 46개 항목 3회 연속 PASS(위 "완료 근거" 참고)와 이번 사용자 최종 승인이 함께 완료 근거를 구성한다.
- **EPIC-06/v0.3.0/Milestone 2**: 이 승인으로 EPIC-06(Local Co-op Foundation)의 모든 Must Feature(FEATURE-06-A/B/C)가 완료되어, EPIC-06·v0.3.0(Fun Physics Update)·Milestone 2(Gameplay Expansion)를 완료 처리한다(`docs/ROADMAP.md`/`docs/MILESTONES.md`/`docs/VERSION.md`/`docs/CHANGELOG.md` 갱신 참고).

### T076 재오픈 — Held Light Object Push 결함(차단 결함)

- **사용자 발견**: 위 최종 승인 이후 진행된 사용자 수동 테스트에서, 가벼운 물체를 Grab한 상태로 무거운 물체(Heavy Crate)에 밀착해 전진하면 **빈손으로 직접 미는 것보다 무거운 물체가 훨씬 쉽게 밀리는** 차단 결함이 발견됨(의도한 물리 결과 아님).
- **처리**: T076을 `[DONE]`에서 `[BLOCKED]`로 되돌린다(섹션 상단 상태 갱신, 위 승인 기록은 삭제하지 않고 보존). EPIC-06·v0.3.0·Milestone 2 완료 처리를 취소하지 않되(과거 사실 자체는 보존), 이 결함이 수정·재검증되어 사용자 재승인을 받기 전까지는 v0.3.0 관련 완료 상태를 최종으로 간주하지 않는다. v0.4.0 착수는 보류한다.
- **원인·수정 내역**: 아래 "T076 결함 수정 — Held Light Object가 Heavy Object를 과도하게 미는 문제" 참고.

### T076 결함 수정 — Held Light Object가 Heavy Object를 과도하게 미는 문제

- **정확한 재현 조건**: 같은 Heavy Crate(25kg)를 대상으로 (1) 빈손 Body Push, (2) 가벼운 물체를 들었지만 접촉하지 않음, (3) Light(SmallBox 5kg)/(4) Medium(Package 15kg)/(5) Heavy(PhysicsBarrel 20kg)로 각각 밀착해 전진, 총 5개 시나리오를 동일 위치·동일 입력(1초 `move_forward`)으로 헤드리스 비교해 재현했다.
- **실제 근본 원인 2가지(복합)**:
  1. `GrabbableBody.max_force_per_grabber`(300N)가 어떤 물체를 들었든 동일하게 적용되는 **질량 무관 상수**였다 — 빈손 Body Push(`push_force` 220N)보다 이미 더 큰 값이라, 무엇을 들든 빈손보다 강하게 미는 구조적 결함이었다.
  2. `GrabCollisionBarrier`(Player를 매 물리 프레임 그대로 따라가는 kinematic `AnimatableBody3D`)가, held object가 다른 물체에 막혀 더 물러설 수 없는 동안 Player가 계속 전진하면 그 물체 쪽으로 파고들어(DD-006과 같은 kinematic 침투 해소) Spring Force와 무관하게 큰 속도(실측 최대 약 87m/s)를 주입할 수 있었다 — 1번을 고치는 것만으로는 이 경로가 막히지 않아 별도로 확인·수정이 필요했다.
- **중복 Force 경로 존재 여부**: 조사한 3가지 중 실제로 존재한 것은 이 2가지뿐이었다.
  - Player의 일반 `_push_away_rigid_bodies()`가 held object 자체를 대상으로 삼는지 → **아니오**(이미 `collider is GrabbableBody and collider.has_grabber(self)` 가드로 제외되어 있었음, 정상).
  - Heavy Crate에 Player Body Push와 held-object 충돌력이 동시에 적용되는지 → **아니오**(`already_pushed_via_grab` 가드가 이미 정상 작동, `player_body_directly_touches_crate=false`로 실측 확인).
  - `max_force_per_grabber`가 질량 무관하게 적용되는지 → **예(주원인 1)**.
  - GrabCollisionBarrier의 kinematic 침투 → **예(주원인 2, 처음엔 예상 못한 별도 경로)**.
- **Barrier가 target과 충돌했는지**: Barrier는 Heavy Crate(target)와 **직접 충돌하지 않는다**(target의 `collision_mask`에 Barrier 레이어 32가 애초에 포함되지 않음, 코드 검토로 확인). 대신 Barrier는 **held object**(Player가 들고 있는 물체 자신)를 파고들어 그 물체에 과도한 속도를 주입했고, 그 물체가 다시 target과 충돌하면서 간접적으로 과도한 힘을 전달했다.
- **수정 파일**: `hell-delivery/scenes/objects/GrabbableBody.gd`
- **적용한 Force 전달 제한 방식**:
  1. `push_transmission_accel`(신규 `@export`, 12.0 N/kg) 추가. `_get_unrelated_rigidbody_contacts()`로 이 물체가 접촉 중인 자기 Grabber 이외의 RigidBody를 찾고, `_limit_push_transmission()`이 그 물체 안쪽으로 누르는(압축) 힘 성분만 `mass * push_transmission_accel`로 제한한다(접촉면에서 떼는 방향·접선 방향·공중 운반 힘은 전혀 건드리지 않음). 정확한 접촉 법선 대신 두 물체 중심을 잇는 수평 방향을 근사로 사용(이 프로젝트의 모든 Grabbable이 원점 대칭 Box/Cylinder라 충분).
  2. `_update_barrier_mask_for_contact()` 추가. 이 물체가 무관한 RigidBody와 접촉 중인 동안에는 `_GRAB_BARRIER_MASK_BIT`를 잠시 빼 GrabCollisionBarrier와의 충돌 자체를 끈다(Player 실제 몸과의 충돌은 grabber별 `collision_exception`으로 항상 별도 보장되므로 안전). 접촉이 풀리면 즉시 원래대로 복구.
  - 두 함수 모두 `_apply_grab_forces()`에서 매 물리 프레임 호출되며, 무관한 물체와 접촉하지 않을 때는 완전한 no-op이라 기존 공중 운반·swing·release 동작에는 전혀 관여하지 않는다.
- **빈손/Light/Medium/Heavy 비교 수치**(1초, Heavy Crate 25kg 대상): 빈손 변위 0.471m(최고속도 2.756m/s) · 접촉 없이 든 경우 0.416m(빈손 대비 차이 11.5%, 기준 15% 이내) · Light(5kg) 0.410m(빈손 대비 0.87배) · Medium(15kg) 0.640~0.692m(빈손 대비 1.36~1.47배) · Heavy(20kg) 0.787m(빈손 대비 1.67배) — Light ≤ Medium ≤ Heavy 순서 유지, 3초 지속 압박(별도 시나리오)에서도 속도 폭주·NaN·Player 발사 없음(최고 속도 crate 2.70m/s, barrel 1.92m/s, Player Y 항상 1.5 유지).
- **target 질량별 비교 수치**: 같은 Medium(Package 15kg) held object로 밀 때, Heavy target(Crate 25kg) 변위 2.28~2.35m vs Light target(SmallBox 5kg) 변위 3.49~3.63m — 무거운 target이 명확히 덜 움직임(질량 차이가 압축 상황에서도 사라지지 않음).
- **기존 Grab 조작감 회귀 결과**: 공중 운반 질량 순서(SmallBox 6.91 > Package 1.82 > Barrel 1.42 > Crate 0.74 m/s, 초기 가속 구간 기준) 정상, 무게중심 grab 각속도 거의 0(0.0) vs 모서리 grab 뚜렷한 torque(4.33 rad/s) 정상, 빠른 swing 후 release 시 별도 impulse 없이 속도 유지(코드 검토로 `remove_grabber()`가 velocity를 전혀 건드리지 않음을 재확인) 정상, 좁은 문 통과 중 Package를 든 채 정체·NaN 없이 통과 정상.
- **1인/2인 협동 운반 회귀 결과**: Grabber 수 0→1→2→1→0 순서 정상(로컬 협동 씬에서 재확인). 1인/2인 절대 수치는 T076 최초 검증(위 "완료 근거" 참고)에서 이미 확인된 것을 그대로 재사용했으며, 이번 결함 수정이 다중 Grabber 힘 합산 로직 자체를 건드리지 않아(오직 "무관한 다른 물체와의 접촉" 상황에서만 개입) 별도 회귀가 없음을 코드 검토로 확인했다.
- **자동 검증 결과**: 임시 헤드리스 스크립트(검증 후 삭제) 2개로 나누어 검증. (1) 핵심 수정 검증 스크립트 — Push 비교(4개), target 질량별 비교(1개), 3초 지속 압박 안정성(5개), swing+release(1개), 좁은 문 운반(3개), 협동 Grabber 순서(5개), Delivery/Restart(3개), 입력 독립성(1개) 총 23개 항목 3회 연속 전부 PASS. (2) torque·공중 운반 질량 순서 회귀 검증 스크립트(별도 1회성 Scene 인스턴스로 분리 — 같은 인스턴스에서 두 하위 측정을 이어 하면 잔여 상태가 다음 측정에 영향을 주는 테스트 전용 아티팩트를 실측으로 발견해 우회) 3개 항목 3회 연속 전부 PASS. `--headless --import`, `--headless --quit-after 60` 오류·경고 0건.
  - 검증 중 발견한 테스트 방법론 이슈(게임 코드와 무관, 테스트 스크립트에서만 수정): 물체 크기별 실제 정지 높이·半깊이를 고려하지 않고 동일한 절대 좌표로 배치했다가 큰 물체가 시작부터 겹쳐 순간적으로 튕겨나가는 아티팩트, HoldPoint가 눈높이에 있어 가벼운 물체가 장애물 위로 튀어 넘어가는 아티팩트, 자유 공중 운반 질량 순서 측정 시 "1초 시점 값"이 아니라 "1초간 최고값"을 재면 오히려 순서가 뒤섞이는 아티팩트, 여러 Scene 인스턴스를 한 스크립트에서 연달아 boot/free할 때 완전히 분리하지 않으면 torque 측정이 실패하는 아티팩트 — 총 4건을 발견해 각각 테스트 스크립트에서만 수정했다.
- **수동 재검증 방법**: 에디터에서 `LocalCoopTest.tscn` 또는 `PrototypeLevel.tscn`을 실행해, (1) SmallPhysicsBox를 든 채 PhysicsCrate에 밀착해 계속 전진 — Crate가 빈손으로 밀 때보다 눈에 띄게 강하게 밀리지 않는지, (2) PhysicsBarrel을 든 채 같은 시도 — Light보다는 확실히 더 잘 밀리되 유압식으로 느껴지지 않는지, (3) 기존처럼 물체를 공중에서 들어올리는 손맛(무게감, torque, swing, release)이 그대로인지, (4) 로컬 협동에서 2인 동시 운반이 그대로 잘 작동하는지 확인.
- **상태**: **해결됨(사용자 재검증 승인 완료)** — 아래 "T076 재오픈 결함 사용자 재검증 승인(최종)" 참고. 더 이상 미해결 차단 결함이 아니다.

### T076 재오픈 결함 사용자 재검증 승인(최종)

- **사용자 회귀 테스트 결과: 승인.** 다음 11개 항목을 사용자가 직접 확인함 — 빈손으로 Heavy Crate 밀기 정상, 가벼운 물체를 들었지만 Crate에 닿지 않을 때 빈손과 차이 없음, 가벼운 물체로 Heavy Crate를 밀어도 과도하게 밀리지 않음, Light→Medium→Heavy 순서로 전달 힘이 자연스럽게 증가, 무거운 대상일수록 명확히 덜 움직임, held object가 Player 이동 속도로 대상을 강제 추종시키지 않음, 장시간 밀어도 속도 폭주·NaN·비정상 발사 없음, 기존 Grab·Swing·Release·Torque 감각 정상, 1인·2인 협동 운반 정상, Delivery와 Restart 정상, 싱글플레이·로컬 협동 모두 정상.
- **결함 해결 처리**: "T076 재오픈 — Held Light Object Push 결함"은 이 승인으로 **해결됨**으로 확정한다. 원인(질량 무관 `max_force_per_grabber` + GrabCollisionBarrier kinematic 침투)과 해결 방식(`push_transmission_accel` 기반 압축 힘 제한 + 접촉 중 Barrier mask 일시 해제)은 위 "T076 결함 수정" 섹션에 기록된 그대로다. 발견·차단(`[BLOCKED]`) 이력은 삭제하지 않고 보존한다.
- **완료 처리**: 이 승인으로 T076은 (이미 받았던 사용자 최종 협동 테스트 승인과 함께) `[DONE]`으로 최종 확정한다(섹션 28 상단 상태 갱신).
- **EPIC-06/v0.3.0/Milestone 2**: T074~T076 전부 `[DONE]`, 미해결 차단 결함 없음 — EPIC-06(Local Co-op Foundation)·v0.3.0(Fun Physics Update)·Milestone 2(Gameplay Expansion)를 완료 상태로 확정한다(`docs/ROADMAP.md`/`docs/MILESTONES.md`/`docs/VERSION.md`/`docs/CHANGELOG.md` 갱신 참고).
- **Baseline 확정**: `push_transmission_accel`(12.0 N/kg)을 사용자 승인된 v0.3.0 프로토타입 Baseline으로 기록한다(`docs/TECH_DEBT.md` TD-019 갱신 참고) — 완료를 막는 미해결 결함이 아니며, 추가 튜닝 가능성은 비차단 항목으로 유지한다.

## 29. T077 — Steam Demo Readiness Audit & Scope Lock

- 상태: `[x]` `[DONE]` (조사·범위 제안 완료, 사용자가 안 A(싱글플레이 중심)를 승인해 v0.4.0 데모 범위 확정 — 아래 "T077 사용자 승인(최종)" 참고)
- 목적: 구현이 아니라 **조사와 계획**. v0.3.0 완료(T074~T076, EPIC-06, Milestone 2) 상태를 문서로 재확인한 뒤, 저장소의 실제 상태(실행 구조·콘텐츠·UI/UX·기술 상태)를 조사해 v0.4.0(Steam Demo)에 필요한 항목을 필수/권장/선택/완료로 분류하고, 현실적인 데모 범위 안을 제안한다.
- 소속: `docs/ROADMAP.md` v0.4.0(Steam Demo) 신규 EPIC-07(Steam Demo Readiness) 1단계
- 선행 작업: v0.3.0 전체 완료(T074~T076 `[DONE]`, EPIC-06 `[DONE]`, Milestone 2 `[DONE]`) — 아래 "v0.3.0 완료 상태 재확인"에서 문서 근거로 확인함.
- 작업 범위: 저장소·문서 조사, 필수/권장/선택/완료 분류, 데모 범위 안 A/B 비교 및 권장안 제시, v0.4.0 후속 Task 목록 제안(계획만, 구현 없음).
- 제외 범위: 게임 코드·Scene 수정, Steamworks SDK 연동, Steam 페이지·빌드 업로드, 신규 Asset 제작, Git 작업, 버전 번호 변경, 후속 Task 구현.
- 생성 파일: 없음
- 수정 파일: 없음(문서만 갱신 — `docs/TASKS.md`, `docs/ROADMAP.md`, `docs/VERSION.md`, `docs/MILESTONES.md`)
- 에디터 수동 작업: 없음.

### v0.3.0 완료 상태 재확인

- `docs/TASKS.md` 섹션 26~28(T074/T075/T076) 상단 상태 전부 `[x]` `[DONE]`, 각 섹션 말미에 사용자 승인 기록 존재.
- `docs/ROADMAP.md`: v0.3.0 헤딩 "✅ 완료(EPIC-06 완료, 사용자 최종 승인)", EPIC-06 헤딩 "✅ 완료", FEATURE-06-A/B/C 전부 "✅ 완료".
- `docs/VERSION.md`: Current Status "v0.3.0(Fun Physics Update) Complete — Milestone 2(Gameplay Expansion) Complete".
- `docs/MILESTONES.md`: Milestone 2 헤딩 "✅ 완료", 완료 근거 기록 존재.
- `docs/CHANGELOG.md`: `[0.3.0] — Fun Physics Update` 정식 항목으로 정리됨(더 이상 `[Unreleased]`가 아님).
- **결론: 완료 상태 정상. 불일치 없음.** 이를 근거로 v0.4.0 준비 조사를 시작함.

### 1. 실행 구조 조사

- **Main Scene**: `project.godot`의 `run/main_scene`은 여전히 `res://scenes/level/PrototypeLevel.tscn`(싱글플레이). 로컬 협동용 `LocalCoopTest.tscn`은 Main Scene이 아니며, Godot 에디터에서 씬을 열어 F6(현재 씬 실행)으로만 실행 가능 — **빌드된 실행 파일에서는 도달할 방법이 전혀 없음**(진입 메뉴·씬 전환 코드 없음).
- **싱글플레이 실행 경로**: 실행 파일 시작 → 즉시 `PrototypeLevel.tscn` 로드 → Player 조작 가능(메뉴·로딩 화면 없음).
- **로컬 협동 실행 경로**: 없음(에디터 전용). 데모에 포함하려면 최소한 "Main Scene에서 이 씬으로 전환하는 방법"이 새로 필요함.
- **에디터 밖 실행 가능 여부**: 미확인 — `export_presets.cfg` 파일 자체가 저장소에 존재하지 않음(Godot Export Preset이 한 번도 구성된 적 없음). 즉 **현재 Windows 실행 파일을 만들 수 없다**(에디터로 프로젝트를 열어야만 플레이 가능).
- **Restart 및 게임 종료 방법**: Restart는 `R`키(`restart` 액션, `PrototypeLevel.gd`/`LocalCoopTest.gd`가 `get_tree().reload_current_scene()` 호출)로 정상 동작. **게임 종료 방법이 전혀 없음** — `quit`/`ui_cancel` 액션 자체가 Input Map에 없고, `get_tree().quit()`을 호출하는 코드가 프로젝트 어디에도 없다. `release_mouse`(ESC 키)는 마우스 캡처만 풀 뿐 종료가 아니다. 사용자는 Alt+F4나 작업 관리자로만 종료 가능 — **Steam 데모로서는 치명적 결함**.
- **디버그 전용 기능 vs 데모 포함 가능 기능**: 콘솔 `print()`류 디버그 로그는 `KI-003`(Low)에 이미 기록된 대로 미미하게 남아있으나 화면에 노출되지 않아 데모에 실질적 영향 없음. 별도의 "디버그 전용" 씬·치트·개발자 콘솔은 존재하지 않는다. `LocalCoopTest.tscn`은 기능적으로는 실 플레이 가능하지만 "개발 검증용 이름/구조"(예: 임의의 스폰 좌표, 사용자 대상 설명 없음)라 그대로 노출하기보다 별도 정리가 필요.

### 2. 현재 플레이 콘텐츠 조사

- **플레이 흐름**: Spawn(0, 1.5, 0) → 가장 가까운 Package(2.5, 1, 0)까지 도보 약 2.5m → Grab(마우스 좌클릭 유지) → DeliveryZone(5, 0.5, 3)까지 도보 약 3.6m → 진입 즉시 배송 성공 판정 → `DELIVERY COMPLETE` 패널 표시(사라지지 않음, R로만 다음 시도 가능).
- **평균 플레이 가능 시간**: "목표 지향" 최단 경로 기준 1분 미만. Stairs/Ramp/NarrowDoorway/TestWall/환경 물리 오브젝트(Barrel·Crate 2·SmallBox 3) 구역은 배송 경로 밖에 있어, 플레이어가 일부러 탐색하지 않으면 지나칠 수 있다 — 탐색까지 포함하면 3~5분 내외로 추정(측정된 수치 아님, 레벨 배치 기준 추정).
- **반복 가능한 목표**: `DeliveryZone`은 `is_delivered` 플래그로 **최초 1회만** 성공 처리(T069 확정 사양) — Package/PackageB/PackageC 중 아무거나 먼저 들어오면 그걸로 끝, 이후 다른 Package를 넣어도 반응 없음. 반복 배송 루프 자체가 설계상 존재하지 않는다(MVP 완료 조건에는 포함되지 않았던 범위, `KI-002` 참고 배경과 유사).
- **성공·실패 조건**: 성공 = 아무 Package나 DeliveryZone 진입. 실패 조건 없음(시간 제한·목숨·페널티 없음) — Core Loop가 "실패해도 웃긴 물리 코미디"(`PLAYER_EXPERIENCE.md`)라는 설계 의도상 자연스러우나, 데모에서는 "성공 후 무엇을 더 할 수 있는지"에 대한 안내가 없다는 점이 아쉬움.
- **현재 레벨/테스트 공간**: `PrototypeLevel.tscn` 1개뿐(Floor 20×20, Stairs, Ramp, WallTestArea, NarrowDoorwayTestArea, PhysicsObjects 6개, Package 3개, DeliveryZone 1개). 전부 `BoxMesh`/`CapsuleMesh` 등 원시 도형(`TD-004`에 이미 기록된 프로토타입 지오메트리) — 미술적으로 다듬어지지 않음.
- **Package/물리 오브젝트 종류**: Package 1종(3개 인스턴스), PhysicsBarrel/PhysicsCrate/SmallPhysicsBox 각 1종(총 6개 인스턴스) — 전부 `GrabbableBody` 공용 클래스, 시각적으로는 색만 다른 단색 상자/원통.
- **로컬 협동의 데모 포함 가능 상태**: 물리·입력·UX 자체는 T074~T076에서 충분히 검증되어 **기능적으로는 포함 가능한 수준**이나, (a) Main Scene에서 도달할 방법이 없고, (b) 게임패드 연결 여부를 확인·안내하는 코드가 전혀 없어(연결 안 된 상태에서 P2는 그냥 조용히 움직이지 않음, 오류도 안내도 없음) 일반 사용자가 겪으면 "고장난 것"으로 오인하기 쉽다 — 데모 포함 시 최소한 이 두 가지는 반드시 보완이 필요.

### 3. UI/UX 조사

- **메인 메뉴**: 없음.
- **싱글플레이·로컬 협동 선택**: 없음(각각 별도 씬을 에디터에서 직접 열어야 함).
- **조작법 안내**: 없음(화면 내 텍스트·툴팁 전무). `KI-002`(목표 안내 `GoalLabel` 미구현)와 같은 배경 — 애초에 조작법 안내 자체가 범위에 없었음.
- **일시정지 메뉴**: 없음(`pause` 액션 없음, `get_tree().paused` 사용 코드 없음).
- **설정 메뉴**: 없음.
- **게임패드 연결 안내**: 없음(위 참고).
- **해상도·전체 화면 설정**: 없음. `project.godot`에 창 크기 명시 없음(Godot 기본값 1152×648 추정), `window/stretch/mode=canvas_items`만 설정, 전체 화면 기본값·전환 수단 없음.
- **음량 설정**: 해당 없음 — 프로젝트에 `AudioStreamPlayer` 자체가 하나도 없음(사운드/음악 미구현).
- **게임 종료 버튼**: 없음(위 "실행 구조" 참고, 치명적).
- **Restart 안내**: `DeliveryHUD`의 `SuccessLabel`/`RestartLabel`("DELIVERY COMPLETE"/"Press R to Restart")로 존재하나, **성공 후에만** 보이고 평소에는 안내가 없다.
- **배송 성공 피드백**: 텍스트 패널만(효과음·연출·페이드 없음), 한 번 표시되면 Restart 전까지 계속 남아있음.

### 4. 기술 상태 조사

- **Godot Export Preset**: 존재하지 않음(`export_presets.cfg` 파일 없음) — Windows 실행 파일을 만든 적이 없다.
- **Windows 실행 파일 생성 가능 여부**: 현재 불가능(Export Preset 미구성). 프로젝트 자체(스크립트·씬)는 특별히 플랫폼 종속적인 코드가 없어 Preset만 추가하면 생성될 것으로 예상되나 실제 시도·검증은 하지 않았다.
- **빌드 시 오류·경고**: 해당 없음(빌드 자체를 시도한 적 없음). 헤드리스 `--headless --import`/`--quit-after`는 매 Task마다 반복 검증되어 왔고 항상 오류 0건.
- **외부 플러그인과 라이선스**: `addons/` 폴더 자체가 없음 — 서드파티 플러그인 미사용.
- **사용 Asset의 배포 권한**: 외부 이미지·폰트·모델·사운드 Asset이 프로젝트에 전혀 없음(전부 Godot 기본 도형 Mesh와 기본 엔진 폰트만 사용) — **라이선스 위험 없음**(배포 권한 문제가 될 대상 자체가 없음).
- **저장 데이터 사용 여부**: 없음(Save/Load 시스템 미구현, `CLAUDE.md` 금지 범위와도 일치).
- **로그·크래시 확인 방법**: Godot 표준 `user://logs/` 경로 외 별도 로깅 체계 없음. 크래시 리포트 수집 체계 없음(데모 배포 시 Godot 기본 크래시 핸들러에 의존).
- **평균 FPS 및 성능 위험**: 정식 프로파일링 미실시(`TECH_DEBT.md` TD-007). 씬 규모가 작아(물리 바디 십여 개 수준) 현재까지 성능 문제가 보고된 적은 없으나, 실제 빌드 환경에서의 FPS 실측은 없다. 분할 화면(로컬 협동)은 `TD-016`(루트 Viewport 소량 중복 렌더링)이 이미 비차단으로 기록됨.
- **해상도 변경·화면 비율 대응**: `window/stretch/mode=canvas_items`만 설정되어 있어 UI는 어느 정도 대응하나, 실제 다양한 해상도·화면 비율에서의 검증은 없음.
- **키보드·마우스/게임패드 연결 해제 대응**: 키보드·마우스는 OS 표준 입력이라 별도 처리 불필요. 게임패드는 연결 해제/미연결 시 조용히 무입력 처리될 뿐(크래시는 없음) 사용자 안내가 전혀 없다(위 참고).

### Steam Demo 항목 분류

**필수(없으면 일반 사용자가 정상 실행·종료 불가)**

- Windows Export Preset 구성 및 빌드 검증(현재 미존재 — 가장 시급함)
- 게임 종료 수단(현재 전무 — Alt+F4만 가능, 치명적)
- 메인 메뉴(최소한 "시작"·"종료" 버튼)
- 게임 모드 선택(안 A 채택 시 실질적으로 불필요 — 싱글만 있으면 선택 자체가 없어도 됨; 안 B 채택 시 필수)
- 조작법 안내(현재 전무)
- 일시정지(최소한 ESC로 메뉴 열기 정도)
- 기본 설정(최소한 창/전체 화면 전환 정도)
- 치명적 오류 방지(현재 헤드리스 검증상 크래시·NaN·속도 폭주 없음 — 이미 충족)
- 라이선스 확인(외부 Asset 없음 — 이미 충족, 확인 완료)

**권장(품질에 큰 영향이나 첫 실행 자체를 막지는 않음)**

- 배송 성공 연출 개선(효과음·페이드 등, 현재 텍스트만)
- 간단한 튜토리얼/목표 안내(`GoalLabel`, `KI-002` 해소)
- 사운드·음악(현재 전무)
- 설정 저장(현재 저장 시스템 자체가 없음 — v0.4.0에서도 필수는 아님, `CLAUDE.md` 저장 방식 변경 금지 범위와 충돌하지 않도록 신중히 검토)
- 게임패드 연결 안내(현재 전무)
- 성능 최적화(현재 문제 보고 없으나 실측 없음)
- 플레이 흐름 개선(반복 배송·성공 후 다음 행동 안내 등)

**선택(현재 데모 범위에서 제외 가능)**

- Steam 업적/친구 초대(Steamworks 미연동, `ROADMAP.md` v0.4.0 Out of Scope와 일치)
- 클라우드 저장(저장 시스템 자체가 없음)
- 온라인 멀티플레이(`ROADMAP.md` v0.8.0 범위)
- 정식 로비/캐릭터 선택(`ROADMAP.md` Out of Scope)
- 대규모 콘텐츠 확장(`ROADMAP.md` v0.5.0 범위 — 여러 택배 종류, 정식 맵, 파손 시스템 등)

**이미 완료(v0.2.0/v0.3.0에서 검증됨)**

- 싱글플레이 코어 루프(이동·Grab·Force-Based Physics·배송·Restart, EPIC-01~05, T070 최종 승인)
- 좁은 문·벽·계단·경사로 통과, 환경 물리 오브젝트(EPIC-01/02)
- 다수 Package 동시 존재(EPIC-03)
- 로컬 2인 협동 물리(입력 분리, 분할 화면, 동시 Grab, Grab Point 표시, 협동 HUD, Release 피드백, Player 간 충돌, EPIC-06)
- 헤드리스 회귀 검증 체계(매 Task마다 반복 확인, 오류 0건 유지)

### 데모 범위 제안: 안 A vs 안 B

| 비교 항목 | 안 A — 싱글플레이 중심 | 안 B — 싱글+로컬 협동 |
|---|---|---|
| 구현량 | 작음(메뉴·설정·종료·온보딩만 추가) | 큼(안 A 전체 + 모드 선택 UI + `LocalCoopTest` 사용자용 정리 + 게임패드 안내/연결 해제 대응) |
| 예상 위험 | 낮음(이미 T070에서 전체 루프 최종 승인 받은 콘텐츠만 노출) | 높음(게임패드 미보유 사용자 경험 저하, 분할 화면 성능·해상도 대응 미검증, `LocalCoopTest`가 원래 "개발 검증용"이라 사용자 노출 전 재정비 필요) |
| 데모의 차별점 | "실패해도 웃긴 물리 코미디"에 집중, 짧고 완결된 인상 | "친구와 함께"라는 협동 코미디까지 보여줄 수 있어 인상은 더 강하나, 준비 부족 시 역효과(먹통처럼 보이는 P2) 위험 |
| 사용자 접근성 | 높음(추가 하드웨어 불필요) | 낮음(게임패드 필수, 2번째 플레이어 필요 — 1인 시연 상황에서는 체험 불가) |
| 현재 코드 재사용성 | 높음(`PrototypeLevel.tscn` 그대로) | 중간(`LocalCoopTest.tscn` 물리·UX는 재사용하나 진입 경로·안내 신규 필요) |
| 출시 준비 난이도 | 낮음 | 높음 |

**권장안: 안 A(싱글플레이 중심 데모).** 이유: (1) v0.4.0 Done Criteria("외부 플레이어가 설치해 싱글/로컬 다인으로 끝까지 플레이 가능한 빌드 1개 존재")는 "싱글 **또는** 로컬 다인"으로 읽을 수 있어 싱글만으로도 충족 가능. (2) `ROADMAP.md` v0.3.0 Goal 자체가 로컬 협동을 "정식 분할 화면 출시 기능이 아니라 개발용 검증 단계"로 명시해 두어, 협동을 데모의 정식 기능으로 승격하려면 추가 범위 확정(사용자 승인)이 필요하다. (3) 게임패드 없이도 100% 체험 가능해야 접근성이 높다. (4) `CLAUDE.md`의 "작게 만들고 자주 검증" 원칙에 부합 — 안 A로 먼저 데모를 완성하고, 반응이 좋으면 협동을 후속 버전(예: v0.4.1)에서 정식 기능으로 승격하는 점진적 접근을 제안한다. 로컬 협동을 완전히 폐기하는 것은 아니며, 메인 메뉴에 "실험적 기능"으로 최소 링크만 남겨두는 것은 선택 사항으로 남긴다(구현 여부는 후속 Task에서 사용자가 결정).

### v0.4.0 후속 Task 분해안(계획만, 미착수)

Task 번호 충돌 확인 완료(T077 이후 T078~T085 전부 미사용, EPIC-07 미사용). 아래는 **계획 상태**로만 기록하며, 이번 T077에서는 구현하지 않는다. 실제로 이미 구현된 항목(예: Restart, DeliveryZone 판정)은 새 Task로 만들지 않았다.

- **T078 — Main Menu and Mode Selection**: 시작 화면(제목·시작·종료 버튼) 신규. 안 A 채택 시 모드 선택 UI는 불필요(싱글로 바로 진입), "시작" 버튼만으로 `PrototypeLevel.tscn` 진입. 완료 조건: 실행 시 메뉴가 먼저 뜨고, 시작 버튼으로 정상 진입, 종료 버튼으로 정상 종료.
- **T079 — Pause, Settings and Exit Flow**: ESC로 일시정지, 최소 설정(창/전체 화면 전환), 종료 버튼(메뉴·일시정지 양쪽에서 접근 가능). 완료 조건: 플레이 중 언제든 ESC로 멈추고 재개·종료 가능, 창/전체 화면 전환이 실제로 동작.
- **T080 — Player Onboarding and Control Guide**: 조작법 안내 UI, `KI-002`(GoalLabel) 해소. 완료 조건: 신규 사용자가 별도 설명 없이 이동·Grab·배송 목표를 이해할 수 있음(사용자 수동 테스트로 확인).
- **T081 — Demo Gameplay Loop and Completion Flow**: 배송 성공 후 "다시 플레이"/"메뉴로" 선택지 등 완결된 흐름 제공, 반복 배송 여부 결정. 완료 조건: 성공 후 플레이어가 다음에 뭘 해야 할지 명확함.
- **T082 — Audio and Feedback Pass**: 최소 효과음(Grab/Release/배송 성공)·배경음. 완료 조건: 핵심 액션에 최소 1개 이상의 청각 피드백 존재(권장 등급 — 없어도 v0.4.0 완료를 막지 않음).
- **T083 — Windows Export and Build Validation**: `export_presets.cfg` 최초 구성, 실제 Windows 실행 파일 생성 및 실행 검증. 완료 조건: 에디터 없이 빌드된 `.exe`가 처음부터 끝까지 정상 실행됨.
- **T084 — Demo Performance and Compatibility Pass**: 실제 빌드 기준 FPS 측정, 해상도·전체 화면 대응 확인, 게임패드 연결 해제 시 최소 안내 문구 추가(안 B 채택 시에만 해당). 완료 조건: 측정된 FPS·해상도 대응 기록, 크래시 없음.
- **T085 — Final Demo Playtest**: T078~T084 통합 후 전체 데모 흐름 최종 사용자 플레이 테스트. 완료 조건: 외부 관점 사용자가 설명 없이 설치→플레이→종료까지 완주.

Steamworks SDK 연동은 v0.4.0 Done Criteria에 포함되지 않으므로(위 "이미 완료"/"선택" 분류 참고) 이번 Task 목록에 포함하지 않았고, 필요 시 v0.4.0 이후 별도 검토한다. 온라인 기능은 범위에 넣지 않았다.

- 완료 조건(T077 자체): 위 조사·분류·범위 비교·Task 분해안이 문서에 기록되고, 사용자가 안 A/B 중 하나를 확정한 뒤 후속 Task(T078~) 착수를 승인함.
- 테스트 방법: 코드 실행 검증 대상이 아님(조사·문서 작업) — 저장소 파일 존재 여부(`export_presets.cfg`, `addons/`, 오디오 리소스 등) 직접 확인, `docs/*.md` 교차 대조로 진행.
- 예상 위험: 데모 범위(안 A/B) 확정이 늦어지면 후속 Task 착수도 함께 지연된다. Export Preset 미구성 상태로는 "실제 빌드에서의" 성능·호환성(T084)을 검증할 수 없어, T083(Export/Build)이 다른 후속 Task보다 먼저 진행되어야 실질적 의미가 있다.
### 재조사 확인(T076 결함 수정 이후)

- **선행 상태 재확인**: v0.3.0(Fun Physics Update)·EPIC-06(Local Co-op Foundation)·T076(Local Co-op Final Validation)·Milestone 2(Gameplay Expansion) 전부 `docs/ROADMAP.md`/`docs/MILESTONES.md`/`docs/VERSION.md`/`docs/TASKS.md`에서 완료(`[x]` `[DONE]`, ✅ 완료)로 일관되게 확인됨. T076은 사용자 최종 협동 테스트 승인에 더해, 이후 발견된 Held Light Object Push 결함까지 수정·자동 재검증(26개 항목 3회 연속 PASS)·사용자 재검증 승인(11개 항목)까지 모두 완료된 상태 — **불일치 없음.**
- **위 조사 내용 재확인**: T076 결함 수정은 `GrabbableBody.gd`(물리 힘 계산)만 변경했고 메뉴·Export·UI·오디오·Input Map과는 무관하다 — 위 1~4번 조사(실행 구조·콘텐츠·UI/UX·기술 상태) 결과는 전부 그대로 유효함을 재확인.
- **추가로 명시 확인한 항목**:
  - **마우스 감도 설정**: 없음. `Player.gd`의 `mouse_sensitivity`(0.003)는 고정 `@export` 값이며, 인게임에서 조정할 UI가 전혀 없다(에디터에서만 변경 가능).
  - **게임패드 감도·Y축 반전 설정**: 없음. `gamepad_look_sensitivity`(2.5)·`invert_gamepad_y`(false)도 마찬가지로 고정 `@export` 값(`TECH_DEBT.md` TD-014/015 Baseline)이며, 인게임 설정 메뉴 자체가 없다.
  - **실패·재도전 흐름**: 별도의 "실패" 조건 자체가 게임에 없음(시간 제한·목숨·페널티 없음) — 해당사항 없음. "재도전"은 오직 전체 씬을 초기화하는 `Restart`(R키)뿐이며, 부분 재시도·체크포인트 개념은 없음.
  - **첫 실행 시 사용자 안내**: 없음(위 "조작법 안내"와 동일 결론) — T080(Player Onboarding and Control Guide) 계획에 포함되어 있음.
- **Windows Export 빌드 시도 결과**: `export_presets.cfg`가 저장소에 여전히 존재하지 않아, 지시에 따라 **새로 Preset을 만들지 않고 시도하지 않았다** — "Export Preset 없음"으로만 보고한다. Preset이 생기면(T083) 그때 임시 폴더 빌드 검증이 의미를 가진다.

- **상태**: 사용자가 데모 범위(안 A/B)를 확정하고 후속 Task 착수를 승인하기 전까지 `[REVIEW]` 유지. EPIC-07과 v0.4.0은 완료 처리하지 않는다. v0.3.0/Milestone 2 완료 상태는 변경하지 않는다. **(이후 사용자 승인으로 `[DONE]` 확정 — 아래 참고)**

### T077 사용자 승인(최종)

- **사용자 승인**: 조사 결과와 권장안 **안 A(싱글플레이 중심 Steam Demo)**를 승인함.
- **v0.4.0 데모 범위 확정**: 싱글플레이 중심. 로컬 협동(`LocalCoopTest.tscn`)은 v0.4.0 **공개 데모 필수 범위에서 제외** — 다만 삭제하거나 구조를 변경하지 않고, 에디터 F6 실행과 로컬 협동 코드·기능은 그대로 유지한다(회귀 없음).
- **완료 처리**: 이 승인으로 T077은 `[DONE]`으로 확정한다(섹션 29 상단 상태 갱신).
- **EPIC-07/v0.4.0**: 아직 완료 처리하지 않는다 — T078(Main Menu & Demo Entry)이 이어서 진행된다.

## 30. T078 — Main Menu & Demo Entry

- 상태: `[REVIEW]` (구현·자동 검증 완료, 사용자 수동 테스트 승인 전까지 `[DONE]` 처리하지 않음)
- 목적: 실행 시 곧바로 테스트 레벨(`PrototypeLevel.tscn`)로 들어가는 대신, 일반 사용자가 사용할 수 있는 최소 메인 메뉴(제목·데모 시작·게임 종료)를 먼저 표시한다. 설정·일시정지·온보딩·성공 연출은 각각 T079~T081 범위라 이번 Task에서 다루지 않는다.
- 소속: `docs/ROADMAP.md` v0.4.0 EPIC-07(Steam Demo Readiness) — FEATURE-07-B
- 선행 작업: T077 `[DONE]`(사용자 승인 완료, 안 A 확정)
- 작업 범위: 메인 메뉴 Scene 신규 생성, `project.godot`의 `run/main_scene`을 메인 메뉴로 변경, 데모 시작(→`PrototypeLevel.tscn` 전환)·게임 종료(`get_tree().quit()`) 기능, 키보드/마우스/게임패드 메뉴 조작(Godot 기본 Focus 시스템 사용), 게임패드 `ui_accept`에 대한 `JOY_BUTTON_A` 바인딩 추가(기존에 키보드 Enter/Kp Enter/Space만 있고 게임패드 바인딩이 전혀 없었음 — 실측으로 발견).
- 제외 범위: 설정 메뉴, 일시정지 메뉴, 온보딩/조작법 안내, 성공 연출, Steamworks 연동, 로컬 협동 메뉴 노출, `LocalCoopTest.tscn`/`PrototypeLevel.tscn` 구조 변경, 신규 Asset, 버전 번호 변경, Git 작업.
- 생성 파일: `hell-delivery/scenes/ui/MainMenu.tscn`, `hell-delivery/scenes/ui/MainMenu.gd`
- 수정 파일: `hell-delivery/project.godot`(`run/main_scene`을 `MainMenu.tscn`으로 변경, `ui_accept` 액션에 게임패드 A 버튼 바인딩 추가)
- 에디터 수동 작업: 없음(전부 텍스트 편집). 실제 마우스·키보드·게임패드 조작감, 해상도 대응 체감은 사용자 수동 테스트 필요.
- **설계**:
  - `MainMenu.gd`(`class_name MainMenu extends Control`): `DEMO_SCENE_PATH` 상수 하나만 사용(Scene 경로 문자열이 이 한 곳에만 존재 — 전역 Scene Manager는 만들지 않음). `_ready()`에서 `Input.mouse_mode = MOUSE_MODE_VISIBLE`(마우스 커서 표시·캡처 해제)·`StartButton`/`QuitButton`의 `pressed` 시그널 연결·`StartButton.grab_focus()`(초기 Focus)만 수행. `_on_start_pressed()`는 `get_tree().change_scene_to_file(DEMO_SCENE_PATH)`, `_on_quit_pressed()`는 `get_tree().quit()`.
  - 데모 진입 후 마우스 재캡처는 새 코드를 추가하지 않았다 — 기존 `Player.gd._ready()`의 `if input_profile == InputProfile.KEYBOARD_MOUSE: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED`가 그대로 담당한다(중복 처리 없음).
  - 메뉴 입력(키보드 Enter/Space, 마우스 클릭, 게임패드 A)은 전부 Godot 기본 `Button`/`Focus` 시스템으로 처리 — 별도 커스텀 입력 코드를 작성하지 않았다. `ui_up`/`ui_down`(Focus 이동)은 이미 키보드 방향키+게임패드 D-pad+왼쪽 스틱이 기본 바인딩되어 있었으나, `ui_accept`(버튼 활성화)는 키보드만 바인딩되어 있고 **게임패드 바인딩이 전혀 없었다** — `project.godot`에 `JOY_BUTTON_A`를 추가해 게임패드로도 메뉴를 확정할 수 있게 했다(이 프로젝트 최초의 UI 액션 커스터마이징).
  - `MainMenu.tscn` 구조: `MainMenu(Control, full rect)` → `Background(ColorRect, 단색)` + `CenterContainer(full rect)` → `VBoxContainer(중앙 정렬)` → `TitleLabel("Hell Delivery")` → `ButtonSpacer` → `StartButton("데모 시작")` → `QuitButton("게임 종료")`. 외부 이미지·폰트 Asset 없음(Godot 기본 `ColorRect`/`Label`/`Button`만 사용), 버전 번호는 재사용할 런타임 상수가 프로젝트에 존재하지 않아 표시하지 않음(하드코딩 금지 지시에 따름).
- 완료 조건: F5(또는 배포) 실행 시 MainMenu가 먼저 표시되고 PrototypeLevel이 배경에서 미리 실행되지 않음, 데모 시작이 마우스·키보드·게임패드 모두로 가능하고 반복해도 중복 Scene/Signal 문제 없음, 게임 종료가 정상 동작, 여러 해상도에서 UI가 잘리지 않음, 싱글플레이·로컬 협동 기존 기능 회귀 없음.
- 테스트 방법: 임시 헤드리스 `SceneTree` 스크립트(검증 후 삭제)로 44개 항목을 3회 연속 검증 — 시작 흐름·구조(MainMenu 로드, PrototypeLevel 미리 실행 안 됨, 버튼 존재, 초기 Focus, 마우스 커서 표시, 6개), 데모 시작 10회 반복(각 반복마다 정상 전환·Player 정상, 20개), 메뉴 입력(마우스·키보드·게임패드로 시작, Focus 이동, 메뉴에서 이동 입력 무관, 5개), 해상도 4종(1280×720/1920×1080/2560×1440/900×500에서 제목·버튼 안 잘림, 4개), PrototypeLevel 단독 회귀(이동·Grab·Delivery·Restart, 4개), LocalCoopTest 단독 회귀(2인 존재·입력 독립성·동시 Grab, 3개), 그리고 별도 진단으로 Windows Export/Import/Boot 오류 확인.
- 완료 근거(검증): 헤드리스 자동 검증 44개 항목 3회 연속 전부 PASS. 시작 흐름: MainMenu가 `run/main_scene`으로 정상 로드되고 트리 전체에 `Player` 노드가 전혀 없음(PrototypeLevel 미리 실행 안 됨) 확인, StartButton 초기 Focus 확인, 마우스 커서 표시(`MOUSE_MODE_VISIBLE`) 확인. 데모 시작 10회 반복: 매번 `PrototypeLevel`로 정상 전환되고 `Player`가 기본 `input_profile`(KEYBOARD_MOUSE)로 정상 존재 — Scene을 완전히 교체하는 `change_scene_to_file()` 방식이라 중복 인스턴스·중복 Signal 연결이 발생하지 않음을 반복으로 확인. 메뉴 입력: 마우스 클릭(Button.pressed 경로) 정상, 키보드 Enter(press+release 이벤트) 정상, 게임패드 A 버튼(press+release, 신규 바인딩 확인 후) 정상 — 세 경로 모두 동일하게 `PrototypeLevel`로 전환됨. `ui_down` 입력으로 Focus가 StartButton→QuitButton으로 정상 이동. 메뉴에는 Player 자체가 없어 `move_forward`를 눌러도 아무 영향이 없음(오류 없이 정상). 해상도 4종 모두 `CenterContainer` 기반 배치로 제목·버튼이 뷰포트 안에 완전히 들어감(잘림 없음). PrototypeLevel 단독 회귀: 이동·Grab·Delivery·Restart(`R`키 실제 이벤트 주입 후 스폰 위치로 재로드 확인) 전부 정상. LocalCoopTest 단독 회귀: Player 2명 존재, 입력 독립성, 동시 Grab(Grabber 수 2) 전부 정상. `--headless --import`, `--headless --quit-after 60` 오류·경고 0건.
  - 검증 중 발견한 이슈 2건: (1) **게임 코드/설정 이슈(실제 수정)** — `ui_accept`에 게임패드 바인딩이 전혀 없어 게임패드로 메뉴를 확정할 방법이 없었다(위 참고, `project.godot`에 추가해 해결). (2) **테스트 방법론 이슈(테스트 스크립트에서만 수정)** — `Input.action_press()`는 폴링 기반 상태만 바꿀 뿐 `_unhandled_input()`으로 전달되는 실제 이벤트를 만들지 않아, Restart처럼 `_unhandled_input` 기반으로 감지되는 입력은 `Input.parse_input_event()`로 실제 `InputEventKey`를 주입해야 함을 발견(이동처럼 폴링 기반 입력과의 차이). Button의 키보드/게임패드 활성화도 press만으로는 반응하지 않고 press+release 쌍이 필요함을 확인.
- 예상 위험:
  - 마우스 캡처(`MOUSE_MODE_CAPTURED`)는 헤드리스 DisplayServer가 지원하지 않아(직접 대입해도 즉시 `VISIBLE`로 되돌아감을 실측 확인) 자동 검증이 불가능하다 — `Player.gd`의 기존 캡처 로직은 무수정이지만, 실제 캡처 체감은 사용자 수동 테스트로만 확인 가능.
  - 게임패드 Focus 이동(D-pad·왼쪽 스틱)과 A 버튼 확인은 실제 컨트롤러 연결 상태에서의 반응감까지는 헤드리스로 확인할 수 없다.
  - `ui_accept`에 게임패드 바인딩을 추가한 것은 이 프로젝트 최초의 UI 액션 커스터마이징이라, 향후 다른 UI(설정·일시정지 등, T079 이후)도 이 바인딩을 그대로 재사용하게 된다 — 문제 발생 시 이 지점을 함께 검토.
- **상태**: `[DONE]` — 사용자가 메인 메뉴 구현과 수동 테스트 결과를 승인함. 메인 메뉴는 v0.4.0 데모 Baseline으로 기록한다(이후 T079+에서 이 메뉴 구조·`run/main_scene` 경로를 그대로 전제로 사용). EPIC-07과 v0.4.0 자체는 T079 이후로 계속 진행 중이라 완료 처리하지 않는다. v0.3.0/Milestone 2 완료 상태는 변경하지 않는다.

## 31. T079 — Pause, Settings & Exit Flow

- 상태: `[REVIEW]` (구현·자동 검증 완료, 사용자 수동 테스트 승인 전까지 `[DONE]` 처리하지 않음)
- 목적: 플레이 중 Esc로 일시정지하고, 메인 메뉴·일시정지 화면 양쪽에서 공유하는 설정 화면(화면/입력/오디오)을 제공하며, 일시정지에서 다시 시작·메인 메뉴·게임 종료로 안전하게 전환한다. 온보딩/조작법 안내·성공 연출·Steamworks 연동은 T080 이후 범위라 다루지 않는다.
- 소속: `docs/ROADMAP.md` v0.4.0 EPIC-07(Steam Demo Readiness) — FEATURE-07-B
- 선행 작업: T078 `[DONE]`(사용자 승인 완료, 메인 메뉴가 v0.4.0 Baseline)
- 작업 범위: 일시정지 메뉴(`PauseMenu.tscn`/`.gd`), 공용 설정 화면(`SettingsPanel.tscn`/`.gd`, MainMenu·PauseMenu 양쪽에서 동일 Scene 재사용), 설정값을 `user://settings.cfg`에 저장·복원하는 Autoload(`GameSettings.gd`), Player.gd의 마우스/게임패드 감도·Y축 반전 실시간 반영, MainMenu에 설정 버튼 추가, `ui_cancel` 게임패드 바인딩 추가(기존에 키보드 Escape만 있고 게임패드 바인딩이 전혀 없었음 — 실측으로 발견, T078의 `ui_accept` 사례와 동일 패턴).
- 제외 범위: 온보딩/조작법 안내, 성공 연출, Steamworks 연동, 로컬 협동(`LocalCoopTest.tscn`) 전용 일시정지 UX 설계(구조상 함께 딸려 들어오는 것은 남은 위험에 기록), 신규 Asset, 버전 번호 변경, Git 작업.
- 생성 파일: `hell-delivery/autoload/GameSettings.gd`, `hell-delivery/scenes/ui/PauseMenu.tscn`, `hell-delivery/scenes/ui/PauseMenu.gd`, `hell-delivery/scenes/ui/SettingsPanel.tscn`, `hell-delivery/scenes/ui/SettingsPanel.gd`
- 수정 파일: `hell-delivery/project.godot`(`[autoload]`에 `GameSettings` 등록, `ui_cancel` 액션에 게임패드 B 버튼 바인딩 추가), `hell-delivery/scenes/level/PrototypeLevel.tscn`(`UI` 아래 `PauseMenu` 인스턴스 추가), `hell-delivery/scenes/player/Player.gd`(`_apply_settings()` 추가, `GameSettings.settings_changed` 연결), `hell-delivery/scenes/ui/MainMenu.tscn`/`.gd`(설정 버튼·`SettingsPanel` 인스턴스 추가)
- 에디터 수동 작업: 없음(전부 텍스트 편집). 실제 마우스 캡처 해제/재캡처 체감, 감도 체감, 해상도·전체 화면 전환 체감은 사용자 수동 테스트 필요.
- **설계**:
  - `GameSettings`(Autoload, `res://autoload/GameSettings.gd`): 화면(창 모드/해상도)·입력(마우스 감도·게임패드 감도·Y축 반전)·오디오(Master Volume) 설정값을 한곳에서 들고 있는 유일한 출처. `_ready()`에서 `user://settings.cfg`를 읽고, 없거나 손상되면 기존 승인된 Baseline 기본값(`mouse_sensitivity=0.003`은 Player.gd 기존 `@export` 기본값 그대로 재사용, `gamepad_look_sensitivity=2.5`/`invert_gamepad_y=false`는 TECH_DEBT.md TD-014/TD-015 기준 Baseline 그대로 재사용 — 임의의 새 값을 만들지 않음)로 안전하게 복구한다. 각 `set_xxx()`는 값 적용(필요 시 DisplayServer/AudioServer 호출) + 저장 + `settings_changed` Signal 발신을 함께 수행해, Player.gd와 SettingsPanel.gd가 이 Signal 하나만 구독해 자기 상태를 갱신하고 설정값 자체는 절대 중복 저장하지 않는다.
  - 손상 복구는 타입·범위 둘 다 검사한다(`_safe_float`/`_safe_bool`/`_safe_enum`/`_safe_resolution`) — 예를 들어 `mouse_sensitivity`에 범위 밖 숫자나 문자열이 들어 있으면 기본값으로, `window_resolution`이 허용 목록(1280×720/1600×900/1920×1080) 밖이면 기본값으로 되돌린다.
  - `PauseMenu`(`CanvasLayer`, PrototypeLevel의 `UI` 아래 항상 존재하는 단일 인스턴스 — 동적 생성이 아니므로 중복 생성 자체가 불가능): `process_mode = PROCESS_MODE_ALWAYS`로 자기 자신은 `paused` 상태에서도 계속 입력을 받는다. 단일 `_unhandled_input()`이 `ui_cancel`을 사용자가 지정한 우선순위(Settings 열림→Settings만 닫음, 아니면 Pause 열림→재개, 아니면→Pause 열기) 그대로 처리한다. Pause를 열 때 `get_tree().paused = true`만 설정하면 Player.gd·GrabbableBody.gd(RigidBody3D 물리)는 기존에 `process_mode`를 건드리지 않아(기본값 Inherit/Pausable) 이동·회전·Grab Spring 계산이 추가 코드 없이 자동으로 멈춘다 — 이번에 새로 작성한 코드가 없는 지점이다. 재개 시 `Input.mouse_mode`를 다시 `CAPTURED`로 되돌린다. Restart/Main Menu/Quit 버튼은 각각 Scene 전환 전에 반드시 `get_tree().paused = false`를 먼저 호출한다(`paused`가 SceneTree 전역 플래그라 새 Scene에도 그대로 남아있기 때문 — T078에서도 동일하게 처리한 패턴).
  - `SettingsPanel`(`Control`)은 MainMenu·PauseMenu 양쪽에서 동일한 `SettingsPanel.tscn`을 각각 인스턴스해 재사용한다(코드 중복 없음). `_updating_ui` guard로 `GameSettings.settings_changed`에 의한 UI 갱신이 다시 `GameSettings.set_xxx()`를 호출하는 되먹임을 막는다. 적용(Apply) 버튼은 없다 — 모든 조작이 `GameSettings`에 즉시 반영되고 즉시 저장된다. `뒤로 가기`/Esc로 닫아도 변경값은 그대로 유지된다(별도 취소 기능 없음, 사용자 지시대로 "즉시 적용" 원칙).
  - Player.gd는 `_apply_settings()` 하나를 추가해 `mouse_sensitivity`/`gamepad_look_sensitivity`/`invert_gamepad_y` 세 값만 `GameSettings`에서 복사해 온다 — 이동 속도·가속도·Grab Force 등 물리값은 전혀 건드리지 않는다. P1/P2는 같은 전역 설정을 함께 받지만, `KEYBOARD_MOUSE` 슬롯은 마우스 감도만, `GAMEPAD` 슬롯은 게임패드 감도·Y축 반전만 자기 입력 분기에서 실제로 사용하므로(T074에서 이미 분리된 구조) 로컬 협동 입력 독립성에는 영향이 없다.
- 완료 조건: Esc로 언제든 일시정지·재개 가능하고 일시정지 중 물리·입력이 완전히 멈춤, Pause에서 다시 시작/메인 메뉴/게임 종료가 모두 안전하게 동작(전환 후 `paused == false`), MainMenu·PauseMenu 양쪽에서 동일한 설정 화면 진입 가능, 설정값이 `user://settings.cfg`에 저장되고 재실행 후 복원되며 손상된 값은 기본값으로 안전 복구, 마우스/게임패드 감도·Y축 반전이 Player에 즉시 반영, Master Volume이 Master Bus에 적용, 여러 해상도에서 대체로 UI가 잘리지 않음(예외 1건은 남은 위험 참고), 싱글플레이·로컬 협동 기존 기능 회귀 없음.
- 테스트 방법: 임시 헤드리스 테스트 드라이버(Node 스크립트를 임시 `run/main_scene`으로 등록 — Autoload는 `--script` 단독 실행 경로에서는 전혀 로드되지 않음을 실측으로 확인했기 때문. 검증 후 스크립트·씬·`run/main_scene` 임시 변경 모두 원복·삭제)로 55개 항목 검증 — Pause 기본 동작(Esc 1회로만 Pause, 3초간 Package 위치·속도·Player 이동·회전 불변, 재개 후 정상 이동, 12개), Pause/Resume 20회 반복(중복 UI 없음, 2개), Scene 전환 안전성(Restart/Main Menu 각각 전환 후 `paused==false`·상태 정상, 메뉴 재진입 정상, 9개), 설정 즉시 적용(마우스·게임패드 감도·Y축 반전 변경 시 Player 즉시 반영, 물리값 무변경, 4개), 손상된 설정값 복구(6종 필드 각각 실측, 6개), MainMenu 설정 진입(버튼·Esc·뒤로 가기·재진입, 6개), 해상도 5종 UI 잘림 확인(PauseMenu 5종 + SettingsPanel 2종, 7개), 싱글플레이 회귀(Grab/Release/Delivery/Restart/Push-fix, 6개), LocalCoopTest 단독 회귀(2인 존재·구조·입력 독립성·동시 Grab, 4개).
- 완료 근거(검증): 55개 항목 중 52개 PASS. 실패 3건: (1) 재개 후 마우스 재캡처 확인 — 헤드리스 DisplayServer가 `MOUSE_MODE_CAPTURED`를 지원하지 않아(T078에서도 동일하게 확인된 환경 한계) 자동 검증 불가, 코드 자체(`Input.mouse_mode = MOUSE_MODE_CAPTURED` 호출)는 정상 실행됨을 확인 — 사용자 수동 테스트로 위임. (2)(3) PauseMenu·SettingsPanel이 900×500(매우 작은 해상도)에서 버튼이 뷰포트 밖으로 잘림 — 1280×720/1600×900/1920×1080/2560×1440에서는 모두 정상, 900×500만 재현됨(2회 반복 실측 동일). Pause 기본 동작(3초 물리 정지, 재개 후 이동), 20회 반복 무중복, Restart/Main Menu 전환 후 `paused==false`, 설정 저장·즉시 반영·손상값 복구 6종 전부, MainMenu 설정 진입, 싱글플레이 회귀(Grab/Release/Delivery/R Restart/T076 Push-fix), LocalCoopTest 단독 회귀(2인·입력 독립성·동시 Grab)는 전부 PASS. `--headless --import`, `--headless --quit-after 60` 오류·경고 0건.
  - 검증 중 발견한 이슈: (1) **테스트 방법론 이슈(테스트 스크립트에서만 수정)** — Godot의 `--headless --script <file>.gd`(SceneTree 서브클래스) 실행 경로는 Autoload를 전혀 로드하지 않는다(실측: `get_node_or_null("/root/GameSettings")`가 항상 null). GameSettings를 실제로 테스트하려면 임시 Node 스크립트를 `run/main_scene`으로 등록해 정상 부트 경로(Autoload 로드 → main_scene 실행)를 타야 했다 — 검증 후 `run/main_scene`은 `MainMenu.tscn`으로 원복했다. (2) **테스트 스크립트 자체 결함(수정 완료)** — 처음 작성한 스크립트가 동적으로 추가한 Scene을 `get_tree().current_scene`에 반영하지 않아, PauseMenu의 `reload_current_scene()`/`change_scene_to_file()`이 테스트 스크립트 자신(Driver, 즉 그 시점의 `run/main_scene`)을 갈아치워 테스트 전체가 무한 재시작되는 결함을 발견해 수정(`_boot()`에서 `get_tree().current_scene = root_node`를 명시적으로 설정). 게임 코드 자체의 결함이 아니라 테스트 하네스의 결함이었다.
- 예상 위험:
  - PauseMenu·SettingsPanel이 900×500처럼 매우 작은 창 크기에서는 내용이 뷰포트보다 커서 일부 버튼이 잘릴 수 있다(스크롤이나 폰트 축소를 하지 않는 단순 `CenterContainer` 구조라서). 1280×720 이상에서는 문제 없다. 이 프로젝트의 목표 플랫폼(Windows PC, Steam)에서 900×500은 매우 작은 비표준 해상도라 우선순위는 낮다고 판단하지만, 레이아웃을 임의로 바꾸지 않고 발견 사실만 보고한다 — 필요 시 별도 Task로 제안.
  - `LocalCoopTest.tscn`은 `PrototypeLevel.tscn`을 통째로 인스턴스하므로, 이번에 PrototypeLevel에 추가한 `PauseMenu`(CanvasLayer)도 `Level/UI/PauseMenu` 경로로 로컬 협동 씬에 함께 존재하게 된다. `CanvasLayer`는 SubViewport에 속하지 않고 루트 Viewport에 직접 그려지므로, 로컬 협동에서 Esc를 누르면 일시정지 화면이 분할 화면 중 한쪽에만 뜨는 게 아니라 창 전체에 걸쳐 뜰 가능성이 있다 — 이번 T079는 싱글플레이 Pause만 요구 범위였고 로컬 협동에서의 Pause UX는 설계되지 않았다. 실제 동작 확인·필요한 로컬 협동 전용 처리는 후속 Task로 남긴다.
  - 마우스 캡처/재캡처, 실제 해상도·전체 화면 전환 체감, 게임패드 실기 감도 체감은 헤드리스로 확인할 수 없어 사용자 수동 테스트가 반드시 필요하다.
- **상태**: `[DONE]` — 사용자가 T079의 모든 기능을 직접 확인하고 정상 작동을 승인함. Pause·Settings·Exit 흐름과 현재 설정값(마우스 감도 0.003, 게임패드 감도 2.5, Y축 반전 false, Master Volume 100%)은 v0.4.0 Baseline으로 기록한다. EPIC-07과 v0.4.0 자체는 T080 이후로 계속 진행 중이라 완료 처리하지 않는다. 버전 번호는 변경하지 않는다.

## 32. T080 — Player Onboarding & Controls

- 상태: `[REVIEW]` (구현·자동 검증 완료, 사용자 수동 테스트 승인 전까지 `[DONE]` 처리하지 않음)
- 목적: 처음 실행한 사용자가 별도 설명 없이 이동·시점·Grab/Release·배송 목표·Pause·Restart·조작법 재확인 방법을 이해하게 한다. 긴 튜토리얼이나 강제 연습 구간은 만들지 않는다. 성공 연출(재시작/메뉴 선택지)은 T081 범위라 다루지 않는다.
- 소속: `docs/ROADMAP.md` v0.4.0 EPIC-07(Steam Demo Readiness) — FEATURE-07-C
- 선행 작업: T079 `[DONE]`(사용자 승인 완료, Pause/Settings/Exit가 v0.4.0 Baseline)
- 작업 범위: 공용 조작법 화면(`ControlsPanel.tscn`/`.gd`, MainMenu·PauseMenu 양쪽에서 재사용), 첫 실행 안내 Overlay(`OnboardingOverlay.tscn`/`.gd`, PrototypeLevel 최초 진입 시 1회), 짧은 목표 문구(`DeliveryHUD`에 `GoalLabel`/`GoalTimer` 최소 확장), `GameSettings`에 `onboarding_seen` 저장 항목 추가, MainMenu·PauseMenu에 조작법 버튼 추가, Esc 입력 우선순위를 Overlay까지 포함해 확장.
- 제외 범위: 성공 연출(재시작/메뉴 선택지, T081), 로컬 협동 전용 온보딩, 게임패드 전용 상세 안내, 외부 이미지·아이콘·폰트, 신규 Asset, 버전 번호 변경, Git 작업.
- 생성 파일: `hell-delivery/scenes/ui/ControlsPanel.tscn`, `hell-delivery/scenes/ui/ControlsPanel.gd`, `hell-delivery/scenes/ui/OnboardingOverlay.tscn`, `hell-delivery/scenes/ui/OnboardingOverlay.gd`
- 수정 파일: `hell-delivery/autoload/GameSettings.gd`(`onboarding_seen` 저장 항목 추가, `reset_to_defaults()`에서는 의도적으로 제외), `hell-delivery/scenes/level/PrototypeLevel.tscn`(`UI` 아래 `OnboardingOverlay` 인스턴스 추가), `hell-delivery/scenes/level/PrototypeLevel.gd`(Overlay 종료 후 또는 즉시 목표 문구 표시), `hell-delivery/scenes/ui/DeliveryHUD.tscn`/`.gd`(`GoalLabel`/`GoalTimer`/`show_goal()` 추가), `hell-delivery/scenes/ui/MainMenu.tscn`/`.gd`(조작법 버튼·`ControlsPanel` 추가, Settings와 상호 배타적으로 동작), `hell-delivery/scenes/ui/PauseMenu.tscn`/`.gd`(조작법 버튼·`ControlsPanel` 추가, Overlay 우선순위 반영)
- 에디터 수동 작업: 없음(전부 텍스트 편집). 실제 마우스 재캡처 체감, 안내 문구 가독성, 목표 문구 타이밍 체감은 사용자 수동 테스트 필요.
- **설계**:
  - `ControlsPanel`(`Control`)은 정적인 조작법 6줄(이동/시점/잡기·놓기/일시정지/다시 시작/목표)만 표시하는 단순 화면이라 `GameSettings`를 구독하지 않는다 — SettingsPanel과 달리 라이브 값 바인딩이 필요 없다. MainMenu·PauseMenu 양쪽이 동일한 `ControlsPanel.tscn`을 인스턴스해 재사용하고(코드 중복 없음), 여는 쪽에서 SettingsPanel이 열려 있으면 자동으로 닫아 두 화면이 동시에 뜨지 않게 한다.
  - `OnboardingOverlay`(`CanvasLayer`)는 PrototypeLevel의 `UI` 아래 항상 존재하되, 자기 `_ready()`에서 `GameSettings.onboarding_seen`만 확인해 스스로 표시 여부를 결정한다(PrototypeLevel.gd는 이 판단에 관여하지 않음). 표시 중에는 `get_tree().paused = true`로 PauseMenu와 동일한 방식(추가 코드 없이 물리·입력 자동 정지)으로 게임을 멈추고, 키보드/마우스/게임패드 아무 press로나 닫힌다. **발견한 결함(수정 완료)**: Godot의 `Control` 기본 `mouse_filter`가 `STOP`이라, Overlay의 루트 `Control`이 화면 전체를 덮은 채 기본값 그대로 있으면 마우스 클릭이 `_unhandled_input`에 전혀 도달하지 못해 "마우스 클릭으로 닫기"가 항상 실패했다 — 루트 `Control`부터 모든 하위 Container/Label까지 `mouse_filter = MOUSE_FILTER_IGNORE`로 명시해 해결했다. 닫는 입력이 마우스 왼쪽 버튼(=`grab_object`와 동일 바인딩)이었을 경우를 대비해, 닫는 순간 `Input.action_release("grab_object")`를 호출해 그 press가 곧바로 Player의 Grab으로 새어 들어가지 않게 막는다.
  - 목표 문구는 `DeliveryHUD`에 `GoalLabel`+`GoalTimer`(4초, one-shot)만 최소 추가한 `show_goal()`로 표시한다. `PrototypeLevel.gd`가 `_ready()`에서 Overlay가 보이는 중이면 `closed` Signal에 1회성으로 연결해 닫힌 직후 표시하고, 이미 본 상태(재진입·Restart)면 곧바로 표시한다 — 별도로 다시 호출하는 곳이 없어 Delivery 성공 후에는 재표시되지 않는다.
  - Esc 입력 우선순위는 PauseMenu.gd 한 곳에서 계속 전담하되, 맨 앞에 "형제 `OnboardingOverlay`가 보이는 중이면 아무것도 하지 않고 반환(`set_input_as_handled()`도 호출하지 않음)"을 추가해, Overlay를 닫는 바로 그 입력이 동시에 Pause를 열어버리는 문제를 막는다(Overlay 자신의 핸들러가 처리할 수 있도록 넘겨줌). 그 아래는 ControlsPanel → SettingsPanel → Pause 재개 → Pause 열기 순서로 기존 T079 구조에 조작법 계층만 추가했다.
  - `GameSettings.onboarding_seen`은 `_safe_bool`로 손상값을 안전하게 `false`로 복구하고, `reset_to_defaults()`(설정 화면의 "기본값 복원")에서는 의도적으로 건드리지 않는다(사용자 지시 — 자동 표시 여부를 설정 기본값 복원과 연결하지 않음).
- 완료 조건: 첫 데모 진입 시 안내 Overlay가 뜨고 게임이 완전히 멈추며, 아무 키로 닫으면 정상 재개되고 그 입력으로 물체가 즉시 잡히지 않음, MainMenu·PauseMenu 양쪽에서 동일한 조작법 화면 진입 가능, Esc 한 번에 한 계층만 닫힘, 목표 문구가 짧게 표시되고 자동으로 사라지며 Delivery 성공 후 재표시되지 않음, `onboarding_seen`이 실제로 파일에 저장되어 재실행 후에도 유지됨, 싱글플레이·로컬 협동 기존 기능 회귀 없음.
- 테스트 방법: T079와 동일한 임시 헤드리스 테스트 드라이버(Node 스크립트를 임시 `run/main_scene`으로 등록, 검증 후 전부 원복·삭제) 방식으로 50개 항목 검증 — 첫 실행 온보딩(Overlay 표시·물리 정지·좌클릭으로 닫기·Grab 미전달·목표 문구 표시, 11개), 재진입/Restart 시 재표시 없음(4개), MainMenu 조작법 화면(진입·Esc·뒤로 가기·Settings 상호 배타, 8개), PauseMenu 조작법 화면과 입력 우선순위(Overlay 우선순위 포함, 7개), 조작법 20회 반복(3개), 목표 문구 표시/소멸(Crosshair 비침범·타이밍·Delivery 후 미재표시, 6개), 설정 저장 회귀(감도 즉시 반영, onboarding 키 누락·손상 시 안전 복구, 3개), 싱글플레이 회귀(5개), LocalCoopTest 단독 회귀(3개). 별도로 두 프로세스(godot 두 번 순차 실행, 같은 `user://` 공유)로 `onboarding_seen` 실제 파일 영속성을 검증했다(Run A가 저장 후 종료, Run B가 완전히 새 프로세스로 재실행되어 값이 복원되고 Overlay가 뜨지 않음을 확인).
- 완료 근거(검증): 첫 회차 시도에서 마우스 클릭 닫기 관련 6개 항목이 연쇄로 실패해 원인을 조사한 결과 위 "발견한 결함" 문단의 `mouse_filter` 문제를 발견해 수정, 재검증에서 50개 항목 중 49개 PASS. 유일한 실패는 "닫기 입력 후 마우스 재캡처" — 헤드리스 DisplayServer가 `MOUSE_MODE_CAPTURED`를 지원하지 않는 환경 한계(T078·T079에서도 동일하게 확인)로, 코드 자체(`Input.mouse_mode = MOUSE_MODE_CAPTURED` 호출)는 정상 실행됨을 확인했다 — 사용자 수동 테스트로 위임. 별도 2-프로세스 테스트에서 `onboarding_seen` 실제 파일 영속성도 PASS로 확인했다. `--headless --import`, `--headless --quit-after 90` 오류·경고 0건.
  - 검증 중 발견한 이슈: **게임 코드 자체의 결함(실제 수정)** — 위 `mouse_filter` 문제 1건. 그 외 테스트 방법론 이슈는 없었다(T079에서 확립한 Node 드라이버+임시 `run/main_scene` 기법, `current_scene` 명시적 설정, 첫 `_boot()` 전 1프레임 대기를 그대로 재사용해 T079 때 겪은 시행착오가 반복되지 않았다).
- 예상 위험:
  - 마우스 캡처/재캡처, 실제 안내 문구 가독성과 배치 체감, 목표 문구가 실제 플레이 흐름에서 방해되지 않는지는 헤드리스로 확인할 수 없어 사용자 수동 테스트가 필요하다.
  - `ControlsPanel`/`OnboardingOverlay`도 T079의 SettingsPanel/PauseMenu와 마찬가지로 900×500 같은 매우 작은 해상도에서는 잘릴 가능성이 있다(`TD-021`과 같은 성격) — 이번 자동 검증에서는 해상도별 잘림을 별도로 재확인하지 않았으므로, 사용자 수동 테스트에서 함께 확인이 필요하다.
  - `OnboardingOverlay`는 싱글플레이 PrototypeLevel 진입 기준으로만 설계되었다 — `LocalCoopTest.tscn`이 PrototypeLevel을 통째로 인스턴스하므로 구조상 Overlay도 함께 존재하지만(T079의 PauseMenu와 동일한 상속 방식), 로컬 협동에서 실제로 어떻게 보이는지는 검증하지 않았다(T079의 PauseMenu 관련 남은 위험과 동일한 성격).
- **상태**: `[DONE]` — 사용자가 T080의 온보딩·조작법 기능을 확인하고 정상 작동을 승인함. 현재 온보딩 Overlay와 공용 조작법 화면은 v0.4.0 Baseline으로 기록한다. EPIC-07과 v0.4.0 자체는 T081 이후로 계속 진행 중이라 완료 처리하지 않는다. 버전 번호는 변경하지 않는다.

## 33. T081 — Demo Gameplay Loop & Completion Flow

- 상태: `[REVIEW]` (구현·자동 검증 완료, 사용자 수동 테스트 승인 전까지 `[DONE]` 처리하지 않음)
- 목적: 1분 미만의 단일 배송 판정을 "메인 메뉴 → 데모 시작 → Package 3개 배송 → 진행도 갱신 → 완료 화면 → 다시 플레이/메인 메뉴"로 완결되는 짧은 데모 플레이로 확장한다. 새 레벨·외부 Asset·점수 시스템·실패 조건은 만들지 않는다. 오디오는 T082 범위라 다루지 않는다.
- 소속: `docs/ROADMAP.md` v0.4.0 EPIC-07(Steam Demo Readiness) — FEATURE-07-C
- 선행 작업: T080 `[DONE]`(사용자 승인 완료, 온보딩·조작법이 v0.4.0 Baseline)
- 작업 범위: `DeliveryZone`의 단일 배송 판정을 Package 3개 반복 배송(`TARGET_PACKAGE_COUNT`)으로 확장, 배송된 Package의 안전한 Grab 해제·재사용 방지 처리(`GrabbableBody.deliver()`), 진행도/배송 토스트 HUD(`DeliveryHUD` 최소 확장), 플레이 시간 측정, 최종 완료 화면(`CompletionOverlay.tscn`/`.gd` 신규), Restart·다시 플레이·메인 메뉴 전환의 완전한 상태 초기화, 온보딩/조작법 문구와 실제 목표 개수 동기화.
- 제외 범위: 새 레벨/맵, 외부 Asset, 점수·랭킹·최고 기록 저장, 실패 조건, 오디오(T082), 로컬 협동 전용 완료 흐름, 버전 번호 변경, Git 작업.
- 생성 파일: `hell-delivery/scenes/ui/CompletionOverlay.tscn`, `hell-delivery/scenes/ui/CompletionOverlay.gd`
- 수정 파일: `hell-delivery/scenes/delivery/DeliveryZone.gd`(다중 Package 집계·`TARGET_PACKAGE_COUNT`·`all_packages_delivered` Signal 추가), `hell-delivery/scenes/objects/GrabbableBody.gd`(`deliver()`·`_delivered` 플래그·`add_grabber()` 가드 추가), `hell-delivery/scenes/ui/DeliveryHUD.tscn`/`.gd`(기존 단일 성공 패널 제거, `ProgressLabel`/`DeliveryToastLabel`/`GoalLabel` 동적 문구로 교체), `hell-delivery/scenes/level/PrototypeLevel.tscn`/`.gd`(`CompletionOverlay` 인스턴스 추가, 플레이 타이머·Signal 연결), `hell-delivery/scenes/ui/PauseMenu.gd`(완료 화면 표시 중 Esc 무시 가드 추가), `hell-delivery/scenes/ui/OnboardingOverlay.gd`/`hell-delivery/scenes/ui/ControlsPanel.gd`(목표 문구를 `DeliveryZone.TARGET_PACKAGE_COUNT`에서 동적으로 읽어와 동기화)
- 에디터 수동 작업: 없음(전부 텍스트 편집). 완료 화면 체감, 목표 문구 가독성, 전체 배송 흐름의 재미·명확성은 사용자 수동 테스트 필요.
- **설계**:
  - 목표 Package 수는 `DeliveryZone.TARGET_PACKAGE_COUNT`(상수, 현재 3) 한곳에서만 관리한다. `OnboardingOverlay`·`ControlsPanel`·`DeliveryHUD`의 목표 문구는 전부 이 값을 `_ready()`에서 동적으로 읽어와 문자열을 조립하므로, 목표 개수를 바꿔도 하드코딩된 문구가 따로 어긋날 일이 없다. `PrototypeLevel.tscn`에는 이미 Package 3개(Package/PackageB/PackageC)가 배치되어 있어 레벨에 오브젝트를 추가하지 않았다.
  - `DeliveryZone.gd`는 `_delivered_packages: Dictionary`(RigidBody3D -> true)로 같은 Package의 재진입을 중복 집계하지 않으며, `is_in_group("package")` 판정(PhysicsCrate/Barrel/SmallBox는 이 그룹에 없어 자동 제외)은 그대로 유지한다. 목표를 이미 달성한 뒤에는 추가 Package가 들어와도 더 집계하지 않는다(레벨에 여분 Package가 있어도 안전).
  - `GrabbableBody.deliver()`는 DeliveryZone이 배송 판정을 내렸을 때만 호출된다(Package 전용 — 다른 Grabbable은 이 함수를 절대 호출하지 않아 물리·Grab 동작에 전혀 영향이 없다). 기존 `remove_grabber()`를 그대로 재사용해 모든 Grab Connection을 안전하게 해제(Player가 밀리지 않는 기존 Release 동작 그대로, Marker도 함께 정리)한 뒤, `_delivered` 플래그로 이후 `add_grabber()`를 항상 거부하고, `freeze=true`+`collision_layer/mask=0`으로 물리·충돌을 정리하고, 0.6초 뒤 `visible=false`로 감춘다. `queue_free()`는 사용하지 않아 다른 Package나 Signal 연결에 영향이 없다.
  - `DeliveryHUD`의 기존 단일 성공 패널(`SuccessPanel`/`show_success()`)은 1개 Package만 배송하던 옛 흐름 전용이라 3개 반복 배송 흐름과 맞지 않아 제거했다 — 대신 항상 보이는 `ProgressLabel`("배송 완료 N / 3")과 배송마다 1초 안팎 표시되는 `DeliveryToastLabel`("배송 완료!")로 교체했다. 둘 다 Crosshair(화면 중앙)·Pause UI(중앙)와 겹치지 않게 화면 상단에 세로로 배치했다.
  - `CompletionOverlay`(`CanvasLayer`)는 `PauseMenu`와 같은 구조(`process_mode=ALWAYS`, `PrototypeLevel`에 항상 존재하는 단일 인스턴스, 평소 숨김)를 따르되 Esc로는 닫히지 않는다 — `PauseMenu.gd`의 `_unhandled_input` 맨 앞에 "형제 `CompletionOverlay`가 보이는 중이면 아무것도 하지 않고 반환"하는 가드를 `OnboardingOverlay` 가드와 같은 방식으로 추가해, 완료 화면이 떠 있는 동안 Esc가 Pause를 열거나 게임을 재개하지 않게 막았다.
  - 플레이 타이머(`PrototypeLevel.gd`의 `_play_time_elapsed`)는 `_physics_process(delta)`에서 무조건 누적한다 — `PrototypeLevel.gd`는 기본 `process_mode`(Pausable)라 Pause/온보딩/완료 화면이 전부 `get_tree().paused=true`를 쓰는 순간 이 함수 자체가 호출되지 않으므로, 별도 조건 분기 없이 "실제 플레이 시간만" 자연히 집계된다(T079의 Pause 자동 정지와 같은 원리를 재사용).
  - Restart(R 키)·PauseMenu "다시 시작"·CompletionOverlay "다시 플레이" 셋 다 결국 `get_tree().reload_current_scene()`(또는 완료 화면에서는 먼저 `paused=false`) 하나로 귀결된다 — Scene 전체가 새로 인스턴스되므로 진행도·타이머·Package 위치·Grab 상태·collision exception이 전부 자연히 초기화되고, 별도의 수동 리셋 코드가 필요 없다. 완료 화면이 열려 있는 동안에는 `PrototypeLevel.gd`도 Pausable이라 R 키 `_unhandled_input`이 아예 호출되지 않아(Pause 중과 동일한 원리) "완료 화면에서는 UI의 다시 플레이만 사용" 요구사항이 추가 코드 없이 자동으로 만족된다.
- 완료 조건: Package 3개를 서로 다른 개체로 배송해야 완료되고 같은 Package 재진입이나 Crate/Barrel 진입은 집계되지 않음, Grab 중 배송이 안전하게 처리되어 Player가 밀리지 않고 Marker가 남지 않음, 진행도/토스트 HUD가 즉시 갱신되고 Crosshair·Pause UI와 겹치지 않음, 완료 화면이 3번째 배송 후 1 physics frame 이내 표시되고 Player·물리가 정지하며 Esc로 닫히지 않음, 다시 플레이/메인 메뉴가 모든 상태(진행도·타이머·Package·Grab)를 완전히 초기화, 온보딩/조작법 문구가 실제 목표 개수와 일치, 싱글플레이·로컬 협동 기존 기능 회귀 없음.
- 테스트 방법: T079~T080과 동일한 임시 헤드리스 테스트 드라이버(Node 스크립트를 임시 `run/main_scene`으로 등록, 검증 후 전부 원복·삭제) 방식으로 80개 항목 검증 — 배송 집계 0→1→2→3(같은 Package 재진입 무시, Crate 무시, 4번째 Package 있어도 중복 없음, 14개), Grab 중 배송(안전 해제·Marker·Player 밀림 없음·다른 Package Grab, 6개), 플레이 타이머(일반 증가·Pause 정지·재개 후 증가·Restart 초기화·온보딩 중 정지, 6개), 완료 화면과 다시 플레이/메인 메뉴 3회 반복(원 요청은 20회였으나 매 반복이 전체 Scene reload를 동반해 비용이 커 3회로 축소 — 아래 "예상 위험" 참고, 20개), 다양한 상태(배송 전/1개/2개/Grab 중/토스트 중/Pause 중)에서 Restart(18개), 회귀(MainMenu·온보딩·조작법·Pause/Settings/Exit·Grab/Release·Push·DeliveryZone 판정·LocalCoopTest, 11개), 네 번째 Package는 테스트 중에만 동적으로 임시 추가(Scene 파일 자체는 무변경).
- 완료 근거(검증): 80개 항목 중 첫 회차에서 4개 실패 — 원인 조사 결과 전부 **테스트 스크립트 자체의 결함**으로 확인되어 수정 후 재검증에서 80개 전부 PASS. (1) Grab 사전조건 실패 2건 — 테스트가 Package를 Player의 실제 HoldPoint 근처로 스냅하지 않고 원래 위치에서 바로 `add_grabber()`를 호출해, 거리 초과 판정으로 1프레임 만에 자동 해제된 것이었다(T079/T080에서 이미 썼던 "HoldPoint 근처로 스냅 후 Grab" 패턴을 이번 스크립트에서 빠뜨림) — 게임 코드 결함 아님. (2) Restart 후 타이머 확인 실패 — `reload_current_scene()` 직후 몇 프레임이 이미 흐른 뒤 확인해 정확히 0.0이 아니었던 것으로, 정상 동작이었고 검증 허용 오차만 조정했다. (3) Pause 상태에서 Restart 실패 — Pause 중에는 `PrototypeLevel.gd`도 Pausable이라 R 키 `_unhandled_input`이 애초에 호출되지 않는 것이 의도된 동작이며(사용자 지시 "완료 화면에서는 R을 직접 처리하지 말고 UI 사용"과 같은 원리), 테스트가 실제 사용자처럼 PauseMenu의 "다시 시작" 버튼을 쓰도록 수정했다. `--headless --import`, `--headless --quit-after 90` 오류·경고 0건.
- 예상 위험:
  - "완료 화면 20회 반복" 자동 검증을 문자 그대로 20회가 아니라 3회로 축소했다 — 매 반복이 `PrototypeLevel` 전체(지형·물리 오브젝트 포함) 재로드를 동반해 비용이 크기 때문이다. `CompletionOverlay`가 `PauseMenu`와 동일하게 Scene에 미리 배치된 단일 인스턴스(동적 생성이 아님)라는 구조적 보장은 있지만, 문자 그대로 20회 반복한 실측은 아니므로 사용자가 원하면 추가 반복 검증을 요청할 수 있다.
  - 완료 시간 표시(`분:초`)의 실제 체감(너무 빠르거나 느리게 흐르지 않는지)은 자동 검증으로 확인할 수 없다.
  - `deliver()`가 배송 즉시 collision_layer/mask를 0으로 만들어 대기 중이던 collision exception 복구(`_pending_restores`)가 더 이상 진행되지 않을 수 있다 — 다만 그 물체는 이후 숨겨지고 다시 상호작용하지 않으므로 실질적인 영향은 없다고 판단했다(자동 검증으로 부작용 없음은 확인했으나, 코드 구조상 남는 비영구적 흔적이라 기록해 둔다).
  - `CompletionOverlay`도 T079의 PauseMenu와 마찬가지로 900×500 같은 매우 작은 해상도에서는 잘릴 가능성이 있다(이번 자동 검증에서는 재확인하지 않음).
- **상태**: 사용자 수동 테스트 전까지 `[REVIEW]` 유지. EPIC-07과 v0.4.0은 완료 처리하지 않는다. 버전 번호는 변경하지 않는다.

## 34. T085D — Character Selection, Unique Reservation & Gameplay Animation

- 상태: `[REVIEW]` (구현·자동 검증 완료, 사용자 수동 테스트 승인 전까지 `[DONE]` 처리하지 않음)
- **⚠️ 브랜치·번호 불일치 기록**: 이 Task는 사용자가 다른 브랜치(`feature_stage01_villa`/`feature_level_design`)에서 진행 중이던 T085A(Delivery Demo Level Design & Greybox)~T085C(미착수)의 번호 체계를 그대로 이어받아 "T085D"로 명명해 `main` 브랜치에 구현하라고 명시적으로 지시한 것이다. **`main`의 `TASKS.md`(이 문서)에는 실제로 T085A/B/C 섹션이 존재하지 않는다** — `main`은 T081(섹션 33, `[REVIEW]`)까지만 진행되어 있고, 위 섹션 13의 "현재 다음 작업" 포인터도 T073에 머물러 있어(다른 브랜치 작업이 `main`에 병합되며 갱신되지 않은 것으로 보임) 이미 그 자체로 최신 상태가 아니다. 사용자는 "T085A는 REVIEW, T085B/C는 TODO 상태를 유지하고 T085D만 진행"하라고 명시적으로 지시했으며, 이는 다른 브랜치의 상태를 그대로 보존하라는 뜻으로 해석해 이 문서의 섹션 13이나 다른 브랜치의 파일은 건드리지 않았다. 번호·브랜치 정리(모든 T085 하위 작업을 한 브랜치로 합칠지, `main`의 Task 번호 체계를 별도로 정리할지)는 사용자 결정이 필요하다.
- 목적: 캐릭터 선택 UI, 로컬 협동 중복 캐릭터 예약 방지, 선택한 외형의 실제 Player 적용, 이동(Idle/Walk/Sprint/Air) 및 Grab/Carry 애니메이션을 구현한다. Player 물리(이동·Collision·Grab Force·Joint·RayCast)는 전혀 변경하지 않는다.
- 소속: 사용자가 `docs/ROADMAP.md`/`docs/GAME_DESIGN.md`의 기존 Epic 구조와는 별도로 명시적 지시로 진행한 Task(위 브랜치·번호 불일치 기록 참고).
- 사전 조사: `assets/environment/kenney_blocky-characters_20/Models/GLB format/`의 18개 캐릭터(`character-a.glb`~`character-r.glb`) 전수 조사 — 공통 노드 구조(`character-X2/character-X/root/{leg-left, leg-right, torso/{arm-left, arm-right, head}}` + 형제 `AnimationPlayer`), Skeleton3D 없음(파츠별 Node3D 직접 애니메이션), 공통 Animation 27종(idle/walk/sprint/pick-up/holding-both 등), 캐릭터별 전용 Texture, CC0 1.0 라이선스, Import 오류 0건 확인. 상세는 `docs/ASSET_LICENSES.md`.
- 작업 범위: Character Selection(MainMenu 진입, 좌우 순환, 3D Preview, 확인/뒤로), Unique Character Reservation(로컬 협동 2인, 확정 시에만 예약, 충돌 시 자동 다음 이동), Character Visual Application(Player 외형 교체, 1인칭 로컬 카메라에서 머리만 숨김), Movement Animation(Idle/Walk/Sprint/Air 상태 전환, 실제 velocity 기반), Grab/Carry Animation(팔 Pose 절차적 Override, Grab 물리 비영향).
- 제외 범위: 온라인 Lobby·RPC·서버 예약, Full-body IK·Skeleton Retargeting, 원본 GLB 수정, 캐릭터별 능력치·Collision 차이, 새 외부 캐릭터 Asset, MainMenu 전면 재작성, 실행 중 Drop-in/Drop-out, Git·버전 변경.
- 생성 파일:
  - `hell-delivery/scripts/character/CharacterDefinition.gd` — 캐릭터 1종의 Resource 데이터(id/display_name/model_scene/preview_scale/preview_rotation_degrees/player_scale + 선택적 파츠 경로 override).
  - `hell-delivery/scripts/character/CharacterCatalog.gd` — 18개 정의를 명시적 경로 목록(파일 시스템 순회 없음)으로 제공하는 정적 유틸리티(Autoload 아님). `get_all()`/`get_by_id()`/`get_default_id()`/`resolve_id_or_default()`.
  - `hell-delivery/resources/characters/character_a.tres` ~ `character_r.tres`(18개) — 각 캐릭터의 `CharacterDefinition` 인스턴스. `player_scale=0.75`(원본 모델 높이 약 2.7m를 Player CapsuleShape3D 높이 2.0m에 맞춘 공통 보정값), `display_name`은 "캐릭터 A"~"캐릭터 R"(Kenney가 의미 있는 이름을 제공하지 않아 오분류 위험이 있는 외형 추정 이름 대신 안전한 일반 명칭을 사용 — 필요하면 후속 작업에서 교체 가능).
  - `hell-delivery/scripts/character/CharacterAnimationController.gd` — Idle/Walk/Sprint/Air 상태별 `AnimationPlayer.play()` 및 반복 재생(원본 Clip이 `loop_mode=NONE`이라 공유 리소스를 바꾸지 않고 `animation_finished`에서 수동 반복), 실제 이동 속도에 따른 `speed_scale` 보정, Carry Pose 추출("holding-both" Clip에서 arm-left/arm-right 회전만 샘플링) 및 매 프레임 비누적 Slerp Override.
  - `hell-delivery/scripts/character/CharacterVisual.gd` + `hell-delivery/scenes/character/CharacterVisual.tscn` — 외부 GLB를 느슨하게 감싸는 Wrapper(`ModelRoot` + `CharacterAnimationController`). 캐릭터 교체 시 이전 인스턴스를 `remove_child()` 후 `queue_free()`로 완전히 제거(같은 프레임 안에 신·구 인스턴스 공존 없음).
  - `hell-delivery/scripts/character/CharacterSelectionManager.gd` — 로컬 협동 예약 상태 전용(Autoload 아님, 선택 화면을 소유하는 Scene이 인스턴스 생성). 플레이어별 임시/확정 선택, `confirm()`/`unconfirm()`/`get_available_ids()`/`all_confirmed()`. Restart로 Scene이 통째로 재로드돼도 직전 확정 캐릭터를 복원할 수 있도록 `static var`로 프로세스 생존 기간 동안만 세션을 기억(`remember_session()`/`get_last_session_character()`).
  - `hell-delivery/scenes/ui/CharacterSelectPanel.tscn`/`.gd` — 표시·입력 전용 UI(이름/좌우 화살표/SubViewport 3D Preview/확인/뒤로). `selection_manager`가 `null`이면 싱글플레이 모드(전체 18종 자유 선택), 지정되면 로컬 협동 모드(예약 목록 반영, 다른 Player 확정 시 `reservation_changed` Signal로 자동 새로고침). 마우스 클릭·`ui_left`/`ui_right`/`ui_cancel`(키보드+게임패드) 모두 지원, 로컬 협동에서는 `input_profile`/`gamepad_device`로 두 Panel이 서로 다른 입력 장치에만 반응.
  - `docs/ASSET_LICENSES.md` — 신규 문서(이 브랜치에는 없었음). Kenney Blocky Characters 2.0(CC0 1.0) 기록.
- 수정 파일:
  - `hell-delivery/scenes/player/Player.tscn` — `CharacterVisualRoot`(CharacterVisual 인스턴스, Y=-1.0 오프셋으로 캐릭터 발을 Capsule 바닥에 정렬) 추가.
  - `hell-delivery/scenes/player/Player.gd` — `apply_character(id)`(Catalog Fallback 포함, 멱등적) 추가, `_ready()`에서 `GameSettings.selected_character_id`로 기본 적용, `_apply_visual_layer_for_slot()`을 기존 자리표시자 Capsule 대신 캐릭터의 `head` 파츠에 적용하도록 재대상화(T074의 Player별 시각 레이어 구조는 그대로 재사용), `_physics_process()` 끝에서 실제 `velocity`/`held_grabbable`을 읽어 `CharacterAnimationController`에 전달(Grab 물리 자체는 무변경).
  - `hell-delivery/autoload/GameSettings.gd` — `selected_character_id`(기본값은 `CharacterCatalog.get_default_id()`), `set_selected_character_id()`, `_safe_string()` 헬퍼, `user://settings.cfg`의 `[character] selected_id` 저장/복원(잘못된 값은 `CharacterCatalog.resolve_id_or_default()`로 안전 복구) 추가.
  - `hell-delivery/scenes/ui/MainMenu.tscn`/`.gd` — "캐릭터" 버튼(데모 시작 다음, 조작법 앞) 및 `CharacterSelectPanel` 진입 추가. 확인 시 `GameSettings.set_selected_character_id()` 저장 후 패널 닫힘, 기존 설정/조작법 패널과 동일한 상호 배타 표시 패턴 재사용.
  - `hell-delivery/scenes/level/LocalCoopTest.tscn`/`.gd` — `CharacterSelectOverlay`(CanvasLayer, layer=10, 화면 전체를 좌우로 나눈 P1/P2 `CharacterSelectPanel`) 추가. 두 Player가 모두 확정하면(`CharacterSelectionManager.all_confirmed()`) 이미 존재하는 Player/Player2 인스턴스에 `apply_character()`를 호출하고 오버레이를 숨긴다 — 새 Player를 만들지 않는다(요청대로 게임 시작 후 Player 추가/제거 없음).
- **설계**:
  - Kenney 18개 캐릭터가 전부 동일한 노드 구조를 가진다는 조사 결과에 따라, `CharacterDefinition`은 파츠 경로를 반복 기록하지 않고 `CharacterVisual`이 `find_child()`로 표준 이름("root"/"AnimationPlayer"/"head"/"arm-left"/"arm-right")을 찾게 했다. 예외 캐릭터가 생기면 `CharacterDefinition`의 선택적 `*_path` 필드로만 대응한다.
  - Carry(운반) 자세는 전용 Clip이 없어 "holding-both"에서 팔 회전만 추출해 목표 Pose로 쓰고, 다리·몸통은 Walk/Sprint Clip을 그대로 재생한 뒤 `CharacterAnimationController`가 `process_priority=100`으로 AnimationPlayer보다 나중에 실행되어 팔 회전만 매 프레임 새로 Slerp 덮어쓴다(설계 문서 "방식 B"). Grab 시작 시 "pick-up" 원샷을 짧게 재생한 뒤 이동 Clip으로 복귀하며, Release는 별도 Clip 없이 팔 Override 블렌드를 0으로 되돌리는 것만으로 자연스럽게 처리된다.
  - `CharacterSelectionManager`는 "미리보기(임시 선택)는 예약하지 않고 확인(`confirm()`)에서만 예약"을 지키며, 실패(다른 Player가 이미 확정)를 bool로 반환해 호출부가 다음 사용 가능 캐릭터로 자동 이동하게 한다. 동시 확정 충돌은 GDScript 단일 스레드 실행 순서상 먼저 실행된 `confirm()` 호출만 성공해 자연히 해결된다.
  - 1인칭 로컬 숨김은 기존 T074 레이어 스킴(`1 << (1+player_slot)`)을 그대로 재사용하되, 대상만 자리표시자 Capsule 전체에서 캐릭터의 `head` MeshInstance3D 하나로 좁혔다 — 몸통/팔/다리는 항상 기본 레이어(1)에 남아 모든 카메라에 보이고, 다른 Player의 cull_mask는 이 비트를 제외하지 않으므로 캐릭터 전체가 정상적으로 보인다.
- **개발 환경에서 발견한 도구 이슈(게임 코드 결함 아님)**: 새 `class_name` 스크립트를 추가한 직후 `godot --headless --script`로 바로 실행하면 `.godot/global_script_class_cache.cfg`가 아직 갱신되지 않아 "Could not find type" 오류가 난다 — `godot --headless --editor --quit`(전체 재스캔)를 먼저 실행해야 헤드리스 검증 스크립트가 새 클래스를 인식한다. 이번 세션에서 여러 번 겪어 매 신규 클래스 추가 후 습관적으로 재스캔했다.
- 완료 조건: 18개 캐릭터 전부 오류 없이 Catalog 등록·Preview·Player 적용 가능, 싱글플레이 좌우 순환·확정·저장/복원·잘못된 ID Fallback 정상, 이동 애니메이션 4상태 전환이 실제 velocity 기반으로 자연스럽고 반복 재시작·떨림 없음, Grab 시 팔 전환·Carry 유지·Release 복귀가 자연스럽고 Grab 물리(연결·거리·차단 판정)에 전혀 영향 없음, 로컬 협동 2 Player가 서로 다른 캐릭터를 확정하고 중복 확정이 차단되며 확정 해제 시 목록에 복귀, 기존 회귀(MainMenu/Player 이동·Collision/Grab·Push·Release/PrototypeLevel) 이상 없음.
- 테스트 방법: 임시 헤드리스 스크립트(`_tmp_*.gd`, 검증 후 전부 삭제)로 단계별 검증 — CharacterCatalog(18개 로드·기본값·잘못된 ID Fallback), CharacterVisual/AnimationController(인스턴스 교체 시 자식 수 유지, 상태 전환, Carry Blend 0→1→0), Player 통합(자리표시자 숨김, head 레이어 타겟팅, GameSettings 연동), MainMenu 전체 흐름(버튼→Panel→순환→확인→저장), LocalCoopTest 예약 흐름(2 Panel 동시 표시→한쪽 확정→상대 목록 갱신→양쪽 확정→오버레이 숨김→실제 Player 외형 적용), 18개 캐릭터 전수(Texture·Animation 접근성), 실제 GrabbableBody를 이용한 진짜 Grab 물리(애니메이션이 Grab 판정에 영향 없음 직접 확인), PrototypeLevel 회귀(Player 이동·캐릭터 적용). 최종 통합 검증 10개 항목 전부 PASS.
- 예상 위험:
  - 위 "브랜치·번호 불일치" 자체가 가장 큰 위험이다 — `main`과 다른 브랜치의 `TASKS.md`가 서로 다른 T085 하위 상태를 갖게 되어, 향후 병합 시 충돌하거나 어느 쪽이 "진실"인지 혼동될 수 있다.
  - 18개 캐릭터의 `display_name`을 "캐릭터 A"~"R"로 단순화했다 — 실제 외형(닌자/정장/오크 등)과 매칭되는 이름을 원하면 각 `.tres`의 `display_name`만 교체하면 되지만, 이번 세션에서는 18장의 개별 미리보기 이미지를 전수 확인하지 않아 오분류 위험을 피하려 보수적으로 처리했다.
  - Grab/Carry 절차적 Pose는 시각적 근사(팔 회전만 Override)이며 실제 손-물체 접촉을 계산하지 않는다 — Package 크기가 극단적으로 다르면(이번 범위에는 없음) 팔이 파고들거나 뜰 수 있다.
  - 3D Preview의 카메라 각도·조명은 고정값(자동 검증으로는 "보기 좋은지" 확인 불가) — 실제 체감은 사용자 수동 테스트가 필요하다.
  - 로컬 협동 캐릭터 선택 오버레이가 떠 있는 동안 Player 이동 입력을 별도로 막지 않았다(개발용 F6 전용 Scene이라는 범위 한정 — 화면은 오버레이가 완전히 가리므로 실질적 영향은 적다고 판단했으나 확인은 못했다).
- **상태**: 사용자 수동 테스트 전까지 `[REVIEW]` 유지. T085A는 다른 브랜치에서 `[REVIEW]`, T085B/T085C는 `[TODO]` 상태를 그대로 둔다(이 문서에는 애초에 없음). T086·EPIC-07·v0.4.0은 미완료 유지. 버전 번호·Git 작업은 수행하지 않는다.

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
