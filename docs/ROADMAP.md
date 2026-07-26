# ROADMAP.md

이 문서는 《택배기사 지옥》(HellDelivery)의 장기 개발 로드맵을 다룬다.

**역할**: 앞으로 무엇을 만들 것인가. "왜 그렇게 설계했는가"는 `DESIGN_DECISIONS.md`, "지금 무엇이 문제인가"는 `KNOWN_ISSUES.md`/`TECH_DEBT.md`, "무엇이 바뀌었는가"는 `CHANGELOG.md`를 참고한다.

버전 번호와 각 버전의 기능 범위는 `docs/GAME_DESIGN.md` 섹션 29(개발 단계, Phase 0~9)를 기준으로 재편성한 것이다. Phase 구조 자체는 `GAME_DESIGN.md`가 원본이며, 이 문서는 그것을 릴리스 단위(버전)로 묶어 우선순위를 제시한다. 기획 내용을 변경하지 않는다.

**Current Status: v0.2.0 완료, v0.3.0(EPIC-06 — Local Co-op Foundation) 진행 중** — v0.2.0(Physics Playground)은 EPIC-01~05·T070 전부 완료로 확정되었다. v0.3.0(Fun Physics Update) 1단계인 EPIC-06의 T074(로컬 2인 협동 테스트 환경)는 사용자 수동 테스트 승인으로 `[DONE]` 확정되었다. 이어서 T075(Local Co-op Interaction UX — 협동 상태를 직관적으로 알 수 있는 UX 보강)를 구현·자동 검증 완료했으며(`[REVIEW]`), 사용자 수동 테스트 결과를 기다린다. v0.3.0과 Milestone 2는 T075 승인이 끝나기 전까지 완료 처리하지 않는다.

---

## v0.1.0 — MVP Complete ✅

**상태**: 완료 (`docs/TASKS.md` T000~T063 전체 `[DONE]`)

- **Goal**: "플레이어가 택배를 직접 들고 이동하는 행동만으로도 재미있는가?"라는 핵심 질문에 답할 수 있는 최소 프로토타입을 만든다.
- **Features**: 3D 이동/달리기/점프/카메라, 일반 박스 물리(잡기/유지/놓기/던지기), 평지·계단·경사로 통과, 배송 구역 감지 및 성공 판정, 성공 HUD, 재시작.
- **Done Criteria**: `docs/GAME_DESIGN.md` 섹션 28의 MVP 완료 조건 10개 전부 충족(`TASKS.md` T062 PASS 판정으로 확인됨).
- **Out of Scope**: 멀티플레이, 차량, 파손/내구도, 경제, 저장, 여러 택배 종류, 좁은 문, 일반 문 상호작용, Steam 연동, 정식 애니메이션/사운드.
- **Risks**: 해소됨(과거 리스크였던 계단 통과 불가 문제는 T022 재작업으로 해결).

---

## v0.2.0 — Physics Playground ✅ 완료

대응: `GAME_DESIGN.md` Phase 4(재미 검증)

**상태**: 완료 (`docs/TASKS.md` T064~T070·T072·T073 전체 `[DONE]`, EPIC-01~05 전부 완료, T070 사용자 최종 플레이 테스트 승인)

- **Goal**: MVP 코어 루프를 다양한 상황에서 검증하고 다듬어, "기본 운반이 재미있는가"를 확정한다.
- **Features**:
  - 좁은 문 추가 및 통과 테스트(`GAME_DESIGN.md` 섹션 27 MVP 제외 목록에서 명시적으로 Phase 4 예정)
  - 충돌 강도, 잡기 감각, 던지기 감각 조정(v0.1.0의 Baseline Freeze 값을 재검토)
  - 벽 지오메트리 추가 및 "벽에 걸렸을 때 물리 안정성" 실제 검증(`KNOWN_ISSUES.md` Medium 항목 해소)
  - 다수의 Package를 레벨에 동시 배치했을 때의 물리 안정성 확인(`TECH_DEBT.md` 항목)
  - 실제 플레이 테스트 기반 정식 재미 검증
- **Done Criteria**: Phase 4 항목 전부 완료, 좁은 문/벽 시나리오 포함 전체 루프 반복 시 치명적 물리 문제 없음, "기본 운반이 재미있다"는 실제 플레이 판단이 내려짐.
- **Out of Scope**: 다인 협동, 온라인 멀티, 차량, 콘텐츠(여러 택배 종류, 정식 맵).
- **Risks**: 해소됨 — T070 사용자 최종 플레이 테스트에서 "기본 운반이 재미있다"는 판단이 내려져(치명적 결함 없음, 14개 평가 항목 모두 승인), 이 리스크가 우려한 "로드맵 재검토" 상황은 발생하지 않았다. 이후 멀티플레이·차량 개발(v0.3.0 이후)을 계속 진행할 근거가 확보됨.

### v0.2.0 Epic 분해 (계획 단계 — 아직 미구현, `docs/TASKS.md`에 Task로 추가되지 않음)

`ROADMAP.md`(위 Features), `docs/GAME_DESIGN.md` Phase 4, 현재 구현 상태(`VERSION.md`, `KNOWN_ISSUES.md`)를 대조해 설계했다. 계층 구조와 각 계층의 정의는 `docs/PROJECT_STRUCTURE.md` 참고.

#### EPIC-01 — Obstacle Course Expansion (장애물 확장) ✅ 완료

- **Goal**: 좁은 문과 벽을 레벨에 추가해 운반 경로를 다채롭게 하고, 지금까지 미검증이던 물리 상호작용(KI-001)을 확인한다.
- **Player Value**: 더 다양하고 흥미로운 실수/사고 상황(`GAME_DESIGN.md` 핵심 재미 원칙과 직결).
- **Dependencies**: 없음 — MVP-1 위에 바로 착수 가능.
- **Estimated Scope**: Medium(신규 지오메트리 2종 + 각각의 검증).
- **완료**: FEATURE-01-A~D 전부 완료(`docs/TASKS.md` T065 `[DONE]`, T066 `[DONE]`). 사용자 최종 수동 테스트 승인 완료.

| Feature | MoSCoW | Task 후보 |
|---|---|---|
| FEATURE-01-A 벽 지오메트리 추가 | Must | ✅ 완료(`docs/TASKS.md` T065 `[DONE]`) — `PrototypeLevel.tscn`에 `TestWall`(`StaticBody3D`) 추가, World 레이어 사용, 기존 계단/경사로/DeliveryZone/PhysicsObjects와 비간섭 확인 |
| FEATURE-01-B 벽 물리 안정성 검증 | Must | ✅ 완료(`docs/TASKS.md` T065 `[DONE]`) — Player 단독/오블리크/모서리, Package(놓인 상태·잡은 상태·던지기·샌드위치) 전부 NaN·관통·폭주 없음 확인, 벽 관련 상호작용 버그 2건(벽 너머 잡기/Hold 유지) 발견 후 가시선 검사로 수정, 사용자 수동 테스트 승인 완료. `KNOWN_ISSUES.md` KI-001 해소 |
| FEATURE-01-C 좁은 문 추가 | Must | ✅ 완료(`docs/TASKS.md` T066 `[DONE]`) — Player capsule(지름1.0)·Package(폭0.8) 실측 기반 clear width 1.4m·height 2.2m로 `NarrowDoorwayTestArea`(`LeftWall`/`RightWall`/`Lintel`) 추가, World 레이어 사용, 기존 계단/경사로/DeliveryZone/PhysicsObjects/TestWall과 비간섭 확인, 사용자 수동 테스트 승인 완료 |
| FEATURE-01-D 좁은 문 통과 검증 | Must | ✅ 완료(`docs/TASKS.md` T066 `[DONE]`) — Player 단독(중앙/오블리크/좌우 문틀)/놓인 Package(밀기/정면/모서리 충돌)/잡은 Package(중앙 통과, 좌우 문틀 걸림, TestWall Auto Release, 재잡기 차단·회복) 헤드리스 검증 44개 항목 전부 PASS, 문 통과 체감(조심하면 통과 가능) 사용자 수동 테스트 승인 완료 |

#### EPIC-02 — Physics Feel Tuning (물리 감각 재조정) ✅ 완료

- **Goal**: T061에서 동결한 export 값을 확장된 환경(벽·좁은 문 포함)에서 재검증하고 필요 시 조정한다.
- **Player Value**: 더 나은 조작감과 "재미있는 실패"를 만드는 물리 반응.
- **Dependencies**: EPIC-01(장애물이 있어야 확장된 환경에서 재검증 가능) — `[DONE]`.
- **Estimated Scope**: Small~Medium(신규 코드 없음, export 값 조정만 — `TECH_DEBT.md` TD-006과 직결).
- **완료**: `docs/TASKS.md` T068 `[DONE]`. 헤드리스 자동 검증으로 객관적 문제 1건 발견·수정(`max_follow_speed` 6.0→7.5, 순수 스프린트만으로 발생하던 Auto Release 해소). 사용자 수동 테스트에서 밀기·잡기·운반·던지기 감각 전체 승인, 추가 수치 조정 불필요로 확정.

| Feature | MoSCoW | Task 후보 |
|---|---|---|
| FEATURE-02-A 충돌·밀기 감각 재검토(`push_force` 등) | Should | ✅ 완료(`docs/TASKS.md` T068 `[DONE]`) — 평지/`TestWall`/`NarrowDoorway`/Crate/Barrel/SmallBox 밀기 전부 NaN·관통·폭주·지속 진동 없음 확인, 값 변경 없음, 사용자 수동 테스트 승인 |
| FEATURE-02-B 잡기·운반 감각 재검토(`follow_strength` 등) | Should | ✅ 완료(`docs/TASKS.md` T068 `[DONE]`) — 순수 스프린트만으로 Auto Release가 발생하는 객관적 문제를 발견해 `max_follow_speed`를 6.0→7.5로 조정(sprint_speed 7.0을 웃도는 최소값), `follow_strength`/`follow_acceleration`/`max_hold_distance`는 유지, 사용자 수동 테스트 승인 |
| FEATURE-02-C 던지기 감각 재검토(`throw_impulse_strength`) | Could | ✅ 완료(`docs/TASKS.md` T068 `[DONE]`) — 수평/위쪽/스프린트 중/벽 방향 던지기 전부 안정적, T044/T061 튜닝값 그대로 유지, 사용자 수동 테스트 승인 |

#### EPIC-03 — Multi-Package Stability (다수 Package 물리 안정성) ✅ 완료

- **Goal**: 여러 Package가 동시에 존재할 때의 물리 안정성을 확인한다(`KNOWN_ISSUES.md` KI-005, `TECH_DEBT.md` TD-003).
- **Player Value**: 직접적 재미보다 향후 콘텐츠 확장(여러 택배 동시 배송)의 토대를 마련하는 검증 성격.
- **Dependencies**: 없음 — 기존 시스템으로 바로 검증 가능, EPIC-01과 병행 가능.
- **Estimated Scope**: Small(신규 코드 없음, 레벨에 인스턴스 추가 + 헤드리스 검증).
- **완료**: `docs/TASKS.md` T069 `[DONE]`. `PackageB`/`PackageC` 추가 후 헤드리스 자동 검증 55개 항목 전부 PASS, `Package.gd`/`Player.gd`/`DeliveryZone.gd` 무수정(실제 다수 Package 버그 미발견). 사용자 수동 테스트 전체 승인 완료.

| Feature | MoSCoW | Task 후보 |
|---|---|---|
| FEATURE-03-A 레벨에 Package 2~3개 배치 | Must | ✅ 완료(`docs/TASKS.md` T069 `[DONE]`) — `PrototypeLevel.tscn` `Gameplay`에 `PackageB`(2.5,1,-2.5)·`PackageC`(-4.5,1,-1) 추가, 기존 `Package`(2.5,1,0) 유지, 서로 1.0m 이상 이격·DeliveryZone/PhysicsObjects/배송 경로와 비간섭 확인, 사용자 수동 테스트 승인 |
| FEATURE-03-B Package 간 충돌·적재 안정성 검증 | Must | ✅ 완료(`docs/TASKS.md` T069 `[DONE]`) — 나란히 배치/2단/3단 적층/붕괴/더미로 던지기/홀드 중 비홀드 대상과 충돌/벽 샌드위치/좁은 문 인근/Barrel 충돌 전부 NaN·관통·폭발적 속도 없음 확인, 사용자 수동 테스트 승인 |
| FEATURE-03-C 여러 Package 순차 배송 시나리오 검증 | Should | ✅ 완료(`docs/TASKS.md` T069 `[DONE]`) — `DeliveryZone`의 "임의의 package 진입 시 최초 1회만 성공" 특성을 그대로 유지, 순차 배송 3회(B→C→A) 모두 성공 시그널 정확히 1회만 발화·중복 없음 확인, 사용자 수동 테스트 승인 |

#### EPIC-04 — Playtest & Fun Validation (재미 검증) ✅ 완료

- **Goal**: "기본 운반이 재미있는가"를 실제 플레이로 확정한다.
- **Player Value**: 게임의 핵심 재미 검증 — 이후 다인/온라인/차량 투자를 정당화하는 관문.
- **Dependencies**: EPIC-01, EPIC-02, EPIC-03, EPIC-05 전부 `[DONE]`. T073(First-Person Camera Transition and Grab Usability, Epic 분해 외 추가 구현)도 사용자 수동 테스트 승인으로 `[DONE]` 완료 — 시점·조준 조작이 확정되어 "기본 운반이 재미있는가"를 최종 판정할 수 있는 상태가 되었다.
- **Estimated Scope**: Small(신규 코드 없음, 순수 플레이테스트 + 기록).
- **완료**: `docs/TASKS.md` T070 `[DONE]` — EPIC-05(T072) 완료로 한 차례 해제되었다가 T073 착수로 재차단, T073 사용자 승인으로 다시 해제된 뒤, 14개 평가 항목(기존 12개 + 1인칭 카메라·조준점 2개) 전체와 전체 루프 플레이 경로(Spawn→환경 오브젝트 밀집 구역→Stairs→Ramp→NarrowDoorway→TestWall→DeliveryZone→Restart)에서 치명적 결함 없이 사용자 최종 승인을 받아 완료됨. "기본 운반이 재미있다"는 실제 플레이 판단이 내려졌다(`docs/TASKS.md` 섹션 22 "T070 사용자 최종 플레이 테스트 승인(최종)" 참고).

| Feature | MoSCoW | Task 후보 |
|---|---|---|
| FEATURE-04-A 확장된 전체 루프 플레이 테스트 | Must | ✅ 완료(`docs/TASKS.md` T070 `[DONE]`) — 사용자 실제 플레이로 전체 경로 완료, 치명적 문제 없음 |
| FEATURE-04-B 재미 판정 및 로드맵 재검토 여부 결정 | Must | ✅ 완료(`docs/TASKS.md` T070 `[DONE]`) — "기본 운반이 재미있다"는 판단 확정, 로드맵 재검토 불필요 |

#### EPIC-05 — Generalized Object Interaction (범용 오브젝트 상호작용) ✅ 완료

- **Goal**: Package 전용 잡기·이동·놓기 구조를 모든 물리 오브젝트(PhysicsBarrel/PhysicsCrate/SmallPhysicsBox 포함)로 일반화하고, 질량에 따라 다른 이동감·좌클릭 Hold 조작·카메라 스윙 기반 릴리즈로 재설계한다. 사용자 플레이 피드백(고정 Throw의 어색함, 잡은 Package가 무거운 Crate를 비현실적으로 쉽게 미는 문제, 동적 오브젝트 접촉만으로 Release되는 문제)에서 직접 발견된 범위다.
- **Player Value**: 더 폭넓은 물리 사고 가능성(Barrel/Crate/SmallBox도 직접 들고 흔들고 던질 수 있음)과 더 일관되고 예측 가능한 조작감.
- **Dependencies**: 없음 — 기존 시스템 위에 바로 진행 가능.
- **Estimated Scope**: Medium(신규 클래스 1개, 기존 스크립트 3개 수정, 씬 5개 수정, Input Map 변경).
- **완료**: `docs/TASKS.md` T071 `[REVIEW]`(사용자 승인 전, 아래 FEATURE-05-B/C/D/F의 내부 이동 방식) → **T072(Force-Based Physics Grab)로 후속 대체**되었고, T072가 Player 밀림·관통 결함 수정 2건을 거쳐 `[DONE]`으로 완료됨(사용자 수동 테스트 승인, `docs/TASKS.md` 섹션 24 "T072 사용자 수동 테스트 승인(최종)" 참고). 헤드리스 자동 검증(T071 60개 이상 + T072 59개 + 결함 수정 36개 + 후속 정정 37개) 모두 3회 연속 전부 PASS, 사용자 실제 플레이로 최종 승인 완료.

| Feature | MoSCoW | Task 후보 |
|---|---|---|
| FEATURE-05-A 범용 Grabbable 구조(`GrabbableBody`) | Must | ✅ 완료(`docs/TASKS.md` T072 `[DONE]`) — `Package`가 `GrabbableBody`를 상속, PhysicsBarrel/Crate/SmallBox도 동일 클래스로 잡기 가능, `grabbable`/`package` 그룹 분리 유지, 사용자 승인 |
| FEATURE-05-B 질량 기반 이동 속도 | Must | ✅ 완료(`docs/TASKS.md` T072 `[DONE]`) — T071의 `effective_acceleration = max_carry_force/mass` 방식은 폐기, T072의 Force-Based Grab(각 물체의 실제 mass×gravity 저항)으로 대체. SmallBox>Package>Barrel>Crate 순서(1 Grabber 조건, 1초간 최고 상승 속도 6.43/2.80/2.51/1.27 m/s) 재실측 확인, 사용자 승인(무게 차이 체감됨) |
| FEATURE-05-C 좌클릭 Hold 이동 | Must | ✅ 완료(`docs/TASKS.md` T072 `[DONE]`) — `grab_object`(좌클릭) `just_pressed`=잡기/`just_released`=놓기, `E` Toggle 방식 완전 대체. 내부적으로는 T072에서 `add_grabber`/`remove_grabber` 다중 연결 API로 전환, 사용자 승인 |
| FEATURE-05-D 카메라 스윙 기반 릴리즈 | Must | **T072에서 폐기·대체, 사용자 승인 완료** — T071의 별도 스윙 속도 측정+release impulse 방식은 완전히 제거되었다. T072에서는 잡고 있는 동안 Spring-Damper 힘이 자연스럽게 만든 운동량을 release 시 그대로 유지할 뿐, 놓는 순간에 적용하는 별도 impulse가 없다(빠르게 흔들다 놓으면 그 순간의 실제 속도만큼 날아감) — "빠른 카메라 이동 후 Release 시 자연스러운 운동량" 사용자 승인 |
| FEATURE-05-E `E` 상호작용 분리 | Should | ✅ 완료(`docs/TASKS.md` T072 `[DONE]`) — `E`가 Grabbable 상태에 전혀 영향 없음, 향후 버튼/문/레버용으로 예약(미구현), 사용자 승인 |
| FEATURE-05-F 동적/정적 충돌 Hold 안정성 | Must | ✅ 완료(`docs/TASKS.md` T072 `[DONE]`) — Hold 차단 판정을 정적 World 장애물로만 제한하는 원칙 유지, 연결(Grab Connection) 단위로 개별 판정. 동적 오브젝트 접촉만으로는 Release 안 됨(3초 연속 접촉 재검증), 사용자 승인 |
| FEATURE-05-G 스윙 이후 손맛 일관성 | Should | FEATURE-05-H로 재검증 방식이 흡수됨 — "스윙"이라는 별도 단계가 없어져 Player collision exception·`GrabCollisionBarrier` 기반 관통 방지 검증으로 대체, 사용자 승인 |
| FEATURE-05-H Force-Based Physics Grab | Must | ✅ 완료(`docs/TASKS.md` T072 `[DONE]`) — 위치/속도 직접 제어 대신 실제 Grab Point에 Spring-Damper 힘 적용, 다중 Grab Connection 구조(향후 멀티플레이 협동 운반의 물리적 기반), 전용 `GrabCollisionBarrier`(신규 collision layer 6)로 관통·Player 밀림 방지, Grab Point 오프셋에 따른 torque 발생, 2 Grabber가 1 Grabber보다 Crate를 빠르게 들어올림 확인, 사용자 승인 |

**Won't(this version)**: 다인 협동 네트워크 동기화(→ v0.3.0, 단 T072에서 다중 Grabber 물리 구조 자체는 로컬로 준비됨), 온라인 멀티·차량(→ v0.8.0), 콘텐츠 확장(→ v0.5.0), Steam 관련(→ v0.4.0 이후), 실제 버튼/문/레버 구현(EPIC-05 FEATURE-05-E는 입력 분리까지만, 향후 별도 Epic).

**추천 착수 순서**: EPIC-01과 EPIC-03은 서로 의존하지 않아 병행 가능 → EPIC-02(EPIC-01 완료 후) → EPIC-05(사용자 피드백으로 EPIC-04보다 먼저 착수) → EPIC-04(EPIC-05 완료 후, 마지막). **(EPIC-01~05 전부 완료 — v0.2.0 Epic 분해 전체 완료)**

**Task 후보 총 개수**: 22개(EPIC-01: 10, EPIC-02: 6, EPIC-03: 3, EPIC-04: 3). EPIC-01(FEATURE-01-A/B/C/D)은 `docs/TASKS.md` T065·T066으로, EPIC-02(FEATURE-02-A/B/C)는 T068로, EPIC-03(FEATURE-03-A/B/C)은 T069로 전환되어 각각 전부 완료(`[DONE]`), 사용자 최종 승인 완료. EPIC-04(FEATURE-04-A/B)는 T070으로 전환되어 EPIC-05 완료로 한 차례 차단이 해제되었다가, T073(1인칭 전환) 착수로 다시 `[BLOCKED]`된 뒤, T073 사용자 승인 완료로 다시 해제되어 사용자 최종 플레이 평가를 거쳐 `[DONE]`으로 완료되었다. **EPIC-05는 원래의 22개 후보 목록에 없던 신규 Epic**으로, 사용자 플레이 피드백에 따라 추가되었고 처음 T071로 전환되어 자동 검증 완료(`[REVIEW]`, 승인 전)했다가, 다시 사용자 지시로 T072(Force-Based Physics Grab, FEATURE-05-H 추가)로 재설계되어 Player 밀림·관통 결함 수정 2건을 거쳐 사용자 수동 테스트 승인, `[DONE]`으로 완료되었다. **v0.2.0 Epic 분해(EPIC-01~05) 전체 완료.**

### T064 — Interactive Physics Objects (Epic 분해 외 추가 구현) ✅ 완료

사용자가 위 Epic 분해와 별개로 "Feature-001 — Interactive Physics Objects"를 직접 지정해 `docs/TASKS.md`에 T064로 추가 승인했다(EPIC-01~04 어디에도 속하지 않는 신규 범위). PhysicsBarrel/PhysicsCrate/SmallPhysicsBox 환경 물리 오브젝트를 `PrototypeLevel`에 추가해 물리 연쇄 충돌(구름·적층 붕괴·배송 경로 간섭)을 만든다. `docs/DESIGN_PILLARS.md` Pillar 1(Unscripted Physics Chaos)과 직결되는 내용이라 EPIC-01(Obstacle Course Expansion)의 물리 검증 목적과도 자연스럽게 연결되지만, 계획 문서에는 사전에 반영되어 있지 않았다는 점을 기록해 둔다. **`[DONE]`으로 완료됨** — 구현 중 발견된 Crate 밀기 화면 떨림은 전역 Physics Interpolation 활성화로 해결, 사용자 최종 승인 완료. 상태와 완료 근거는 `docs/TASKS.md` T064 항목 참고.

### T067 — Package Interaction Toggle (Epic 분해 외 추가 구현) ✅ 완료

T064와 마찬가지로 Epic 분해에 없던 범위다. T066(좁은 문) 완료 직후, 이동키(WASD)와 `E`를 동시에 계속 눌러야 하는 조작 부담을 사용자가 직접 지적해 잡기 입력 방식을 Hold(DD-001)에서 Toggle(DD-017)로 변경했다. `Player.gd`의 `_handle_interact_input()`만 수정했고, 가시선 검사·Hold 차단 자동 Release(T065)·`max_hold_distance` 자동 Release 등 기존 안전장치는 전혀 건드리지 않았다. 헤드리스 자동 검증 40개 항목 전부 PASS. **`[DONE]`으로 완료됨** — 토글 방식 적용 후 T066(좁은 문)도 최종 조작으로 재검증해 함께 사용자 최종 승인을 받았다. 상태와 완료 근거는 `docs/TASKS.md` T067 항목 참고.

### T073 — First-Person Camera Transition and Grab Usability (Epic 분해 외 추가 구현) ✅ 완료

T064·T067과 마찬가지로 Epic 분해에 없던 범위다. EPIC-05(T072) 완료로 T070이 재개되기 직전, 사용자가 "3인칭 카메라에서는 캐릭터가 잡은 물체를 가리는 문제가 있다"고 직접 지적해 시점을 1인칭으로 전환하고, Grab 판정을 화면 중앙(Camera) 기준으로 재정렬했다. `docs/GAME_DESIGN.md`가 명시하던 "3인칭 카메라 기본"과 정면으로 배치되는 변경이었지만, `CLAUDE.md` 섹션 9(사용자의 최신 명시적 지시가 최우선)에 따라 사용자 승인 사항으로 진행했다 — 사용자 최종 승인 이후 `docs/GAME_DESIGN.md`의 "3인칭" 서술도 실제 구현(1인칭)과 일치하도록 최소 수정해 동기화했다. T072의 Force-Based Grab 힘 계산·다중 Grab Connection·Player 관통/밀림 방지 구조는 전혀 수정하지 않았다. 헤드리스 자동 검증 128개 항목 3회 연속 전부 PASS(Grab 정확도 80/80, 거리별 경계 판정, 가시선·우선순위, 조준점 정렬 오차 0px, 입력 반응 지연 0~1프레임, 자기 가림 0회, 실제 레벨 운반 회귀), 이후 두 차례의 Push 결함 수정(RigidBody 질량별 Player Push 차이, Held 상태 Body Push 과강화) 이후에도 18개 항목 재검증 3회 연속 전부 PASS. **`[DONE]`으로 완료됨** — 사용자 수동 테스트 승인 완료(1인칭 카메라 정상, 시야·Grab 판정 가림 없음, 조준점-Grab 일치, torque 정상, 좁은 문·계단·경사로 운반, held 상태 Body Push 정상, 배송·Restart 회귀 정상). 이 승인으로 T070의 `[BLOCKED]`가 해제되었다(위 EPIC-04 참고). 상태와 완료 근거는 `docs/TASKS.md` T073 항목(섹션 25, "T073 사용자 수동 테스트 승인(최종)") 참고.

---

## v0.3.0 — Fun Physics Update 🔶 착수(EPIC-06 진행 중)

대응: `GAME_DESIGN.md` Phase 5(로컬 다인 협동 검토)

- **Goal**: 물리 기반 협동의 핵심 재미(엉망이 되는 상황)를 다인 환경에서 검증한다. 정식 분할 화면 출시 기능이 아니라 개발용 검증 단계다.
- **Features**:
  - 로컬 2인 테스트 환경
  - 같은 Package 동시 잡기 — **T072에서 이미 다중 `grab_connections: Dictionary` 구조로 재설계되어(`TECH_DEBT.md` TD-009 해결됨) 실제로는 재설계가 필요 없었고, T074에서 실제 Player 2명으로 검증만 수행했다.**
  - 플레이어 간 충돌
  - 협동 운반 테스트, 혼자 운반과의 속도/안정성 차이 검증
- **Done Criteria**: 두 플레이어가 동시에 하나의 Package를 안정적으로 옮길 수 있음(또는 명확한 제약이 문서화됨), 혼자 운반이 여전히 가능함(강제 다인화 아님).
- **Out of Scope**: 온라인 네트워크, 4인 이상, 정식 분할 화면 UI.
- **Risks**: (해소됨) 애초 우려했던 "`Package.gd`의 단일 holder 구조 재설계 필요"는 T072에서 이미 해결되어 v0.3.0 착수 시점에는 남아있지 않았다. 현재 리스크는 게임패드 감도/deadzone 등 협동 조작감 튜닝값이 실측 전 추정값이라는 점 정도(`TECH_DEBT.md` 참고).

### v0.3.0 Epic 분해 (진행 중)

#### EPIC-06 — Local Co-op Foundation (로컬 협동 기반) 🔶 진행 중

- **Goal**: 온라인 네트워크 없이, 로컬에서 실제 Player 2명이 같은 물리 월드를 공유하며 물체를 함께 잡고 나르는 협동 물리 기반을 검증한다.
- **Player Value**: 물리 기반 협동의 핵심 재미(무게를 나눠 들기, 서로 부딪히기, 같이 실수하기)를 실제로 확인할 수 있는 최초의 다인 환경.
- **Dependencies**: v0.2.0 전체 완료(`[DONE]`).
- **Estimated Scope**: Medium(Player.gd 입력 슬롯 분리, Player.tscn 충돌 마스크 수정, 신규 테스트 Scene 1개).
- **진행 상태**: `docs/TASKS.md` T074 `[DONE]`(사용자 수동 테스트 승인 완료) — 로컬 2인 분할 화면 테스트 환경 구현·자동 검증(46개 항목 3회 연속 PASS) 완료. 이어서 T075 `[REVIEW]` — Grab Point 표시·협동 HUD·Release 피드백·게임패드 조작 개선(39개 항목 3회 연속 PASS) 완료, 사용자 수동 테스트 대기.

| Feature | MoSCoW | Task 후보 |
|---|---|---|
| FEATURE-06-A 로컬 2인 분할 화면 테스트 환경(입력 슬롯 분리, 실제 2인 동시 Grab, Player 간 충돌) | Must | ✅ 완료(`docs/TASKS.md` T074 `[DONE]`) |
| FEATURE-06-B 로컬 협동 상호작용 UX(Grab Point 표시, 협동 HUD, Release 피드백, 게임패드 조작 개선) | Must | 🔶 진행 중(`docs/TASKS.md` T075 `[REVIEW]`) — 사용자 수동 테스트 대기 |

**Won't(이번 Task)**: 온라인 멀티플레이, RPC/네트워크 동기화, Steam 기능, 로비/매칭, 캐릭터 선택, 정식 메뉴 UI, 3인 이상, 정식 분할 화면 출시 UI.

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
