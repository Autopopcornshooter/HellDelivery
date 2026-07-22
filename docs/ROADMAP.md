# ROADMAP.md

이 문서는 《택배기사 지옥》(HellDelivery)의 장기 개발 로드맵을 다룬다.

**역할**: 앞으로 무엇을 만들 것인가. "왜 그렇게 설계했는가"는 `DESIGN_DECISIONS.md`, "지금 무엇이 문제인가"는 `KNOWN_ISSUES.md`/`TECH_DEBT.md`, "무엇이 바뀌었는가"는 `CHANGELOG.md`를 참고한다.

버전 번호와 각 버전의 기능 범위는 `docs/GAME_DESIGN.md` 섹션 29(개발 단계, Phase 0~9)를 기준으로 재편성한 것이다. Phase 구조 자체는 `GAME_DESIGN.md`가 원본이며, 이 문서는 그것을 릴리스 단위(버전)로 묶어 우선순위를 제시한다. 기획 내용을 변경하지 않는다.

**Current Status: Ready for Physics Playground** — MVP-1(v0.1.0) 종료, Baseline 확정. v0.2.0의 Epic/Feature/Task 후보 설계가 완료되었으며(아래 "v0.2.0 Epic 분해" 참고), 착수는 사용자 승인 대기 중이다.

---

## v0.1.0 — MVP Complete ✅ (현재)

**상태**: 완료 (`docs/TASKS.md` T000~T063 전체 `[DONE]`)

- **Goal**: "플레이어가 택배를 직접 들고 이동하는 행동만으로도 재미있는가?"라는 핵심 질문에 답할 수 있는 최소 프로토타입을 만든다.
- **Features**: 3D 이동/달리기/점프/카메라, 일반 박스 물리(잡기/유지/놓기/던지기), 평지·계단·경사로 통과, 배송 구역 감지 및 성공 판정, 성공 HUD, 재시작.
- **Done Criteria**: `docs/GAME_DESIGN.md` 섹션 28의 MVP 완료 조건 10개 전부 충족(`TASKS.md` T062 PASS 판정으로 확인됨).
- **Out of Scope**: 멀티플레이, 차량, 파손/내구도, 경제, 저장, 여러 택배 종류, 좁은 문, 일반 문 상호작용, Steam 연동, 정식 애니메이션/사운드.
- **Risks**: 해소됨(과거 리스크였던 계단 통과 불가 문제는 T022 재작업으로 해결).

---

## v0.2.0 — Physics Playground

대응: `GAME_DESIGN.md` Phase 4(재미 검증)

- **Goal**: MVP 코어 루프를 다양한 상황에서 검증하고 다듬어, "기본 운반이 재미있는가"를 확정한다.
- **Features**:
  - 좁은 문 추가 및 통과 테스트(`GAME_DESIGN.md` 섹션 27 MVP 제외 목록에서 명시적으로 Phase 4 예정)
  - 충돌 강도, 잡기 감각, 던지기 감각 조정(v0.1.0의 Baseline Freeze 값을 재검토)
  - 벽 지오메트리 추가 및 "벽에 걸렸을 때 물리 안정성" 실제 검증(`KNOWN_ISSUES.md` Medium 항목 해소)
  - 다수의 Package를 레벨에 동시 배치했을 때의 물리 안정성 확인(`TECH_DEBT.md` 항목)
  - 실제 플레이 테스트 기반 정식 재미 검증
- **Done Criteria**: Phase 4 항목 전부 완료, 좁은 문/벽 시나리오 포함 전체 루프 반복 시 치명적 물리 문제 없음, "기본 운반이 재미있다"는 실제 플레이 판단이 내려짐.
- **Out of Scope**: 다인 협동, 온라인 멀티, 차량, 콘텐츠(여러 택배 종류, 정식 맵).
- **Risks**: 이 단계에서 "기본 운반이 재미없다"고 판단되면 `GAME_DESIGN.md` 섹션 4의 명시적 지침에 따라 이후 멀티플레이·차량 개발을 시작하지 않는다 — 로드맵 자체가 재검토 대상이 됨.

### v0.2.0 Epic 분해 (계획 단계 — 아직 미구현, `docs/TASKS.md`에 Task로 추가되지 않음)

`ROADMAP.md`(위 Features), `docs/GAME_DESIGN.md` Phase 4, 현재 구현 상태(`VERSION.md`, `KNOWN_ISSUES.md`)를 대조해 설계했다. 계층 구조와 각 계층의 정의는 `docs/PROJECT_STRUCTURE.md` 참고.

#### EPIC-01 — Obstacle Course Expansion (장애물 확장)

- **Goal**: 좁은 문과 벽을 레벨에 추가해 운반 경로를 다채롭게 하고, 지금까지 미검증이던 물리 상호작용(KI-001)을 확인한다.
- **Player Value**: 더 다양하고 흥미로운 실수/사고 상황(`GAME_DESIGN.md` 핵심 재미 원칙과 직결).
- **Dependencies**: 없음 — MVP-1 위에 바로 착수 가능.
- **Estimated Scope**: Medium(신규 지오메트리 2종 + 각각의 검증).

| Feature | MoSCoW | Task 후보 |
|---|---|---|
| FEATURE-01-A 벽 지오메트리 추가 | Must | ✅ 완료(`docs/TASKS.md` T065 `[DONE]`) — `PrototypeLevel.tscn`에 `TestWall`(`StaticBody3D`) 추가, World 레이어 사용, 기존 계단/경사로/DeliveryZone/PhysicsObjects와 비간섭 확인 |
| FEATURE-01-B 벽 물리 안정성 검증 | Must | ✅ 완료(`docs/TASKS.md` T065 `[DONE]`) — Player 단독/오블리크/모서리, Package(놓인 상태·잡은 상태·던지기·샌드위치) 전부 NaN·관통·폭주 없음 확인, 벽 관련 상호작용 버그 2건(벽 너머 잡기/Hold 유지) 발견 후 가시선 검사로 수정, 사용자 수동 테스트 승인 완료. `KNOWN_ISSUES.md` KI-001 해소 |
| FEATURE-01-C 좁은 문 추가 | Must | (1) 문 폭 결정(Player capsule + Package 크기 기반 실측) (2) `PrototypeLevel.tscn`에 문 지오메트리 추가 |
| FEATURE-01-D 좁은 문 통과 검증 | Must | (1) Player 단독 통과 (2) Package 미소지 통과 (3) Package 소지 통과 (4) 문에 낀 상태에서 Auto Release/충돌 안정성 검증 |

#### EPIC-02 — Physics Feel Tuning (물리 감각 재조정)

- **Goal**: T061에서 동결한 export 값을 확장된 환경(벽·좁은 문 포함)에서 재검증하고 필요 시 조정한다.
- **Player Value**: 더 나은 조작감과 "재미있는 실패"를 만드는 물리 반응.
- **Dependencies**: EPIC-01(장애물이 있어야 확장된 환경에서 재검증 가능).
- **Estimated Scope**: Small~Medium(신규 코드 없음, export 값 조정만 — `TECH_DEBT.md` TD-006과 직결).

| Feature | MoSCoW | Task 후보 |
|---|---|---|
| FEATURE-02-A 충돌 강도 재검토(`push_force` 등) | Should | (1) 확장된 환경에서 실제 플레이 (2) 필요 시 값 조정 |
| FEATURE-02-B 잡기 감각 재검토(`follow_strength` 등) | Should | (1) 실제 플레이 (2) 필요 시 값 조정 |
| FEATURE-02-C 던지기 감각 재검토(`throw_impulse_strength`) | Could | (1) 실제 플레이 (2) 필요 시 값 조정 — T044/T061에서 이미 상당히 튜닝되어 우선순위 낮음 |

#### EPIC-03 — Multi-Package Stability (다수 Package 물리 안정성)

- **Goal**: 여러 Package가 동시에 존재할 때의 물리 안정성을 확인한다(`KNOWN_ISSUES.md` KI-005, `TECH_DEBT.md` TD-003).
- **Player Value**: 직접적 재미보다 향후 콘텐츠 확장(여러 택배 동시 배송)의 토대를 마련하는 검증 성격.
- **Dependencies**: 없음 — 기존 시스템으로 바로 검증 가능, EPIC-01과 병행 가능.
- **Estimated Scope**: Small(신규 코드 없음, 레벨에 인스턴스 추가 + 헤드리스 검증).

| Feature | MoSCoW | Task 후보 |
|---|---|---|
| FEATURE-03-A 레벨에 Package 2~3개 배치 | Must | (1) `PrototypeLevel.tscn`에 Package 인스턴스 추가 |
| FEATURE-03-B Package 간 충돌·적재 안정성 검증 | Must | (1) Package를 서로 쌓기/부딪히기 헤드리스 검증 |
| FEATURE-03-C 여러 Package 순차 배송 시나리오 검증 | Should | (1) 각 Package를 순서대로 `DeliveryZone`에 배송, `is_delivered` 로직이 첫 Package에만 반응하지 않는지 확인(현재 `DeliveryZone`은 "임의의 package 그룹 진입"만 판정하므로 여러 개를 모두 요구하는 로직은 없음 — 이 특성을 그대로 유지할지 결정 필요) |

#### EPIC-04 — Playtest & Fun Validation (재미 검증)

- **Goal**: "기본 운반이 재미있는가"를 실제 플레이로 확정한다.
- **Player Value**: 게임의 핵심 재미 검증 — 이후 다인/온라인/차량 투자를 정당화하는 관문.
- **Dependencies**: EPIC-01, EPIC-02, EPIC-03 전부(확장되고 튜닝되고 안정성이 확인된 상태에서 진행해야 함).
- **Estimated Scope**: Small(신규 코드 없음, 순수 플레이테스트 + 기록).

| Feature | MoSCoW | Task 후보 |
|---|---|---|
| FEATURE-04-A 확장된 전체 루프 플레이 테스트 | Must | (1) 좁은 문+벽+계단+경사로 포함 전체 루프를 최소 3회 반복 플레이 |
| FEATURE-04-B 재미 판정 및 로드맵 재검토 여부 결정 | Must | (1) 판정 기록(`GAME_DESIGN.md` 섹션 4 핵심 질문에 대한 답) (2) 필요 시 `ROADMAP.md` v0.3.0 이후 재검토 |

**Won't(this version)**: 다인 협동(→ v0.3.0), 온라인 멀티·차량(→ v0.8.0), 콘텐츠 확장(→ v0.5.0), Steam 관련(→ v0.4.0 이후).

**추천 착수 순서**: EPIC-01과 EPIC-03은 서로 의존하지 않아 병행 가능 → EPIC-02(EPIC-01 완료 후) → EPIC-04(전부 완료 후, 마지막).

**Task 후보 총 개수**: 22개(EPIC-01: 10, EPIC-02: 6, EPIC-03: 3, EPIC-04: 3). 이 중 FEATURE-01-A/B에 해당하는 항목이 사용자 승인을 받아 `docs/TASKS.md` T065로 전환되어 완료됨(`[DONE]`). 나머지는 아직 `docs/TASKS.md`에 추가하지 않았다 — 사용자 승인 후 개별 Task로 전환한다(`PROJECT_STRUCTURE.md`의 Task 생성 규칙 참고).

### T064 — Interactive Physics Objects (Epic 분해 외 추가 구현) ✅ 완료

사용자가 위 Epic 분해와 별개로 "Feature-001 — Interactive Physics Objects"를 직접 지정해 `docs/TASKS.md`에 T064로 추가 승인했다(EPIC-01~04 어디에도 속하지 않는 신규 범위). PhysicsBarrel/PhysicsCrate/SmallPhysicsBox 환경 물리 오브젝트를 `PrototypeLevel`에 추가해 물리 연쇄 충돌(구름·적층 붕괴·배송 경로 간섭)을 만든다. `docs/DESIGN_PILLARS.md` Pillar 1(Unscripted Physics Chaos)과 직결되는 내용이라 EPIC-01(Obstacle Course Expansion)의 물리 검증 목적과도 자연스럽게 연결되지만, 계획 문서에는 사전에 반영되어 있지 않았다는 점을 기록해 둔다. **`[DONE]`으로 완료됨** — 구현 중 발견된 Crate 밀기 화면 떨림은 전역 Physics Interpolation 활성화로 해결, 사용자 최종 승인 완료. 상태와 완료 근거는 `docs/TASKS.md` T064 항목 참고.

---

## v0.3.0 — Fun Physics Update

대응: `GAME_DESIGN.md` Phase 5(로컬 다인 협동 검토)

- **Goal**: 물리 기반 협동의 핵심 재미(엉망이 되는 상황)를 다인 환경에서 검증한다. 정식 분할 화면 출시 기능이 아니라 개발용 검증 단계다.
- **Features**:
  - 로컬 2인 테스트 환경
  - 같은 Package 동시 잡기(현재 `Package.gd`의 `holder`는 단일 참조 구조 — 다인 확장 시 이 구조 자체를 재설계해야 함, `DESIGN_DECISIONS.md` DD-002/DD-007 참고)
  - 플레이어 간 충돌
  - 협동 운반 테스트, 혼자 운반과의 속도/안정성 차이 검증
- **Done Criteria**: 두 플레이어가 동시에 하나의 Package를 안정적으로 옮길 수 있음(또는 명확한 제약이 문서화됨), 혼자 운반이 여전히 가능함(강제 다인화 아님).
- **Out of Scope**: 온라인 네트워크, 4인 이상, 정식 분할 화면 UI.
- **Risks**: 현재 `Package.gd`의 잡기 구조(단일 holder, collision exception 1:1)가 다인 운반을 전제하지 않아 상당한 리팩터링이 필요할 수 있음(`TECH_DEBT.md` 참고).

---

## v0.4.0 — Steam Demo

대응: `GAME_DESIGN.md` Phase 9 중 데모 제작·상점 자료 준비를 조기 실행

- **Goal**: 온라인 멀티플레이·차량 없이도 공개 가능한 수준의 데모를 만든다(싱글 + 로컬 다인 협동 기준).
- **Features**:
  - 최소 UI 정리(목표 안내 `GoalLabel` 등 v0.1.0에서 보류된 항목 포함)
  - 빌드 배포 파이프라인 최초 구성
  - Steam 상점 페이지용 자료(스크린샷, 트레일러 소재) 준비
  - 기초 최적화 및 버그 수정
- **Done Criteria**: 외부 플레이어가 설치해 싱글/로컬 다인으로 끝까지 플레이 가능한 빌드 1개 존재.
- **Out of Scope**: 온라인 멀티플레이(Phase 6), 차량(Phase 7), 정식 콘텐츠 확장(Phase 8), Steamworks 업적/친구 초대.
- **Risks**: 데모 시점에 온라인 멀티가 없다는 것이 데모 인상에 불리할 수 있음 — 데모 범위를 "협동 물리 코미디"에 집중해 상쇄하는 방향으로 접근.

---

## v0.5.0 — Content Expansion

대응: `GAME_DESIGN.md` Phase 8(콘텐츠 확장)

- **Goal**: 반복 플레이 가치를 위한 콘텐츠를 추가한다.
- **Features**: 다양한 택배 종류(`GAME_DESIGN.md` 섹션 10 참고), 정식 맵, 랜덤 이벤트, 파손 시스템(현재 MVP-1은 물리 충돌만 구현, 내구도 없음), 점수 시스템, 보상 시스템.
- **Done Criteria**: 최소 2종 이상의 택배 종류와 1개 이상의 정식 맵이 플레이 가능, 파손 판정이 물리 충돌과 연동됨.
- **Out of Scope**: 온라인 멀티(별도 Phase), 차량(별도 Phase), Steamworks 연동.
- **Risks**: 택배 종류가 늘어나면 현재 `Package.gd`의 단일 스크립트 구조(내구도/파손 없음)를 확장해야 하며, 상속/데이터 기반 설계가 필요해질 수 있음.

---

## v0.8.0 — Release Candidate

대응: `GAME_DESIGN.md` Phase 6(온라인 멀티) + Phase 7(차량) + Phase 9 대부분

- **Goal**: 출시에 필요한 핵심 기능(온라인 멀티, 차량)을 모두 구현하고 안정화한다.
- **Features**: 로비/호스트-클라이언트, 플레이어·택배·배송 상태 동기화, 택배 밴(운전/탑승/하차/차량 문/화물 적재), Steamworks 연동(업적, 친구 초대), 설정 화면, 전반적 최적화.
- **Done Criteria**: 온라인 멀티로 4인까지 안정적으로 플레이 가능, 차량으로 택배를 운반할 수 있음, 알려진 치명적 버그 없음(`KNOWN_ISSUES.md` High 항목 0건).
- **Out of Scope**: 새로운 콘텐츠 추가(v0.5.0에서 완료된 것으로 간주), 실험적 기능.
- **Risks**: 가장 큰 아키텍처 변경(온라인 동기화)이 이 단계에 집중되어 있어 일정 리스크가 가장 큼. 현재 MVP-1은 싱글플레이 전용 구조(Autoload 없음, 권한(authority) 개념 없음)라 상당 부분 재설계 필요.

---

## v1.0.0 — Steam Release

대응: `GAME_DESIGN.md` Phase 9 완료

- **Goal**: 정식 출시.
- **Features**: 버그 수정 마무리, 최종 최적화, 상점 페이지 완성, 빌드 배포 확정.
- **Done Criteria**: Steam 정식 출시.
- **Out of Scope**: 없음(출시 이후 로드맵은 이 문서의 범위 밖).
- **Risks**: 없음으로 간주(이전 단계에서 리스크가 대부분 해소되어야 도달 가능한 단계).

---

## 우선순위 원칙

- `GAME_DESIGN.md` 섹션 4의 원칙에 따라, v0.2.0(재미 검증)에서 "기본 운반이 재미없다"고 판단되면 v0.3.0 이후 단계 전체를 재검토한다.
- 온라인 멀티플레이(v0.8.0 일부)는 `CLAUDE.md`/`GAME_DESIGN.md` 공통 원칙에 따라 싱글플레이 핵심 재미가 검증된 이후에만 시작한다.
- 각 버전의 정확한 착수 시점은 이 문서에서 확정하지 않는다 — 사용자의 명시적 승인이 있을 때 다음 버전 작업을 시작한다.
