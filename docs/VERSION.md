# VERSION.md

이 문서는 현재 프로젝트 상태를 한눈에 보여준다.

**역할**: 지금 프로젝트가 어떤 상태인가. 변경 이력은 `CHANGELOG.md`, 앞으로의 계획은 `ROADMAP.md`를 참고한다. 이 문서는 매 버전 릴리스 시점에 갱신한다.

---

| 항목 | 내용 |
|---|---|
| **Current Status** | **v0.3.0 Complete — v0.4.0(Steam Demo) Readiness Audit In Progress (EPIC-07)** |
| **Current Version** | v0.3.0 — Fun Physics Update Complete (v0.4.0은 아직 미완료, 준비 조사 단계) |
| **Development Stage** | v0.2.0·v0.3.0 모두 완료. v0.4.0(Steam Demo) 준비 조사 착수 — T077 `[REVIEW]`(조사·범위 제안 완료, 사용자 범위 확정 대기) |
| **Current Phase** | Gameplay Expansion 완료, Steam Demo 준비 조사 중 (`docs/TASKS.md` T064~T076 전부 `[DONE]`, T077 `[REVIEW]`; EPIC-01~06 전부 완료, EPIC-07 진행 중) |
| **Current Milestone** | Milestone 2 완료. Milestone 3(Steam Demo) 준비 조사 착수(`MILESTONES.md` 참고) |
| **Engine** | Godot 4.7.1 (stable, win64) |
| **Language** | GDScript |
| **Physics Engine** | Jolt Physics |
| **Renderer** | Forward+ (Windows: D3D12) |
| **Repository State** | 정상 동작하는 기준선(Baseline) — `docs/TASKS.md` T000~T076 전체 완료, T077(조사·계획) 완료 |
| **Baseline** | v0.1.0 = MVP-1 Baseline, v0.2.0 = Physics Playground Baseline, v0.3.0 = Fun Physics Update Baseline(본 문서 갱신 시점) |
| **Target Platform** | Windows PC (Steam) |
| **Target Release** | v1.0.0 — Steam Release (`ROADMAP.md` 참고, 확정 일정 없음) |
| **Last QA** | `docs/TASKS.md` T060(전체 코어 루프 통합 테스트, PASS), T062(MVP-1 완료 검토, PASS), T070(v0.2.0 최종 재미·조작성 검증, 14개 평가 항목 전체 승인), T074(로컬 2인 협동 자동 검증 46개 항목 3회 연속 PASS, 사용자 수동 테스트 승인 완료), T075(협동 상호작용 UX 자동 검증 39개 항목 3회 연속 PASS, 사용자 수동 테스트 승인 완료), T076(전체 플레이 흐름 통합 검증 46개 항목 3회 연속 PASS, 14개 항목 사용자 최종 협동 테스트 승인 완료 — 이후 발견된 Held Light Object Push 결함도 원인 수정 후 자동 검증 26개 항목 3회 연속 PASS + 11개 항목 사용자 재검증 승인 완료) |
| **Next Milestone** | Milestone 3 — Steam Demo(`MILESTONES.md`, `ROADMAP.md` v0.4.0 참고) — T077 감사 결과 데모 범위(안 A/B) 확정 및 후속 Task(T078~) 착수 승인 필요 |

## 현재 구현 범위 요약

- **완료**: 이동/점프/달리기/카메라, 계단·경사로 통과, 배송 구역 감지·성공(Package 전용), 성공 HUD, 재시작, 환경 물리 오브젝트(`PhysicsBarrel`/`PhysicsCrate`/`SmallPhysicsBox`, T064), 전역 Physics Interpolation 활성화, 수직 벽 테스트 구역(`TestWall`)과 상호작용 물리적 가시선 검사(벽 너머 잡기·Hold 유지 차단, T065), 좁은 문 테스트 구역(`NarrowDoorwayTestArea`, T066) — EPIC-01(Obstacle Course Expansion) 전체 완료, 사용자 최종 승인. 확장 환경 물리 감각 재검토(`max_follow_speed` 6.0→7.5로 조정, 나머지 값 유지, T068) — EPIC-02(Physics Feel Tuning) 전체 완료, 사용자 최종 승인. 다수 Package 동시 존재(`PackageB`/`PackageC` 추가, T069) — EPIC-03(Multi-Package Stability) 전체 완료, 사용자 최종 승인. 범용 `GrabbableBody` 잡기(Package/PhysicsBarrel/PhysicsCrate/SmallPhysicsBox 전부 잡기 가능)와 **Force-Based Physics Grab**(실제 클릭 표면 지점에 Spring-Damper 힘 적용, 위치/속도 직접 제어 없음, 다중 Grab Connection 구조, `GrabCollisionBarrier` 기반 Player 관통·밀림 방지, 고정 Throw·스윙 impulse 완전 제거, T071→T072) — EPIC-05(Generalized Object Interaction) 전체 완료, 사용자 최종 승인(T072). **3인칭 → 1인칭 시점 전환 및 Grab 조작성 개선**(카메라를 Player 눈높이로, Grab 판정을 화면 중앙 기준으로 재정렬, 상태형 조준점 UI 추가, T073) — Force-Based Grab 힘 계산 자체는 무변경, 이후 발견된 Body Push 결함 2건(RigidBody 질량별 Player Push 차이, held 상태 Body Push 과강화) 수정 포함, 헤드리스 자동 검증(128개+18개) 및 사용자 수동 테스트 승인 완료
- **완료(v0.2.0 최종)**: 전체 루프 최종 재미 검증(T070, `[DONE]`) — 14개 평가 항목(Grab/Release 직관성, 질량별 무게감, torque, 저속·스윙 반응, Release 운동량, Player 관통·밀림 방지, Body Push 감각, 좁은 문·벽·계단·경사로, 다수 Package 운반, 배송 흐름, Restart, 전체 재미, 1인칭 카메라 편안함, 조준점 일치)와 전체 루프 플레이 경로에서 치명적 결함 없이 사용자 최종 승인. EPIC-04(재미 검증)와 v0.2.0(Physics Playground) 완료 확정
- **완료(v0.3.0 최종)**: v0.3.0(Fun Physics Update) EPIC-06(Local Co-op Foundation) 전체 완료 — ① 로컬 2인 분할 화면 테스트 환경(T074, `[DONE]`): `Player.gd` 입력 슬롯(키보드+마우스/게임패드) 분리, `Player.tscn` collision_mask 수정(Player 간 충돌 활성화), `LocalCoopTest.tscn`에서 `PrototypeLevel` 재사용해 실제 Player 2명이 같은 물리 월드를 공유하며 하나의 Package를 동시에 잡는 것까지 검증(46개 항목 3회 연속 PASS). ② Local Co-op Interaction UX(T075, `[DONE]`): Player별 Grab Point 마커, 동시 Grab 협동 HUD, Release 사유별 Crosshair 점멸, 게임패드 트리거+A OR 조합 Grab 입력·`move_deadzone`/`look_deadzone` 분리(39개 항목 3회 연속 PASS). ③ Local Co-op Final Validation(T076, `[DONE]`): 새 기능 추가 없이 전체 플레이 흐름(독립 이동→서로 다른 물체 Grab→동시 Grab→Crate 1인/2인 비교→좁은 문→배송→Restart) 통합 안정성 검증(46개 항목 3회 연속 PASS), `LocalCoopTest.gd`에 누락되어 있던 Restart 입력 처리를 발견해 보완. 세 Task 모두 사용자 수동/최종 테스트 승인 완료 — EPIC-06과 v0.3.0 전체 완료 확정, 이로써 Milestone 2(Gameplay Expansion)도 완료 확정. **T076 최종 승인 이후 사용자 수동 테스트에서 Held Light Object Push 결함(가벼운 held object가 빈손 Body Push보다 무거운 물체를 더 쉽게 미는 문제)이 추가로 발견되어 잠시 `[BLOCKED]`로 재오픈되었으나**, `max_force_per_grabber`의 질량 무관 적용과 `GrabCollisionBarrier`의 kinematic 침투라는 두 원인을 규명해 `push_transmission_accel` 기반 압축 힘 제한으로 수정하고, 자동 검증(26개 항목 3회 연속 PASS)과 사용자 재검증(11개 항목)을 모두 거쳐 다시 완료 확정되었다
- **진행 중(사용자 범위 확정 대기)**: v0.4.0(Steam Demo) EPIC-07(Steam Demo Readiness) — T077(Demo Readiness Audit & Scope Lock, `[REVIEW]`). 구현 없이 조사만 수행 — 현재 Main Scene은 여전히 `PrototypeLevel.tscn`(싱글), 로컬 협동은 에디터 전용(빌드에서 도달 불가), Windows Export Preset 미구성(빌드 자체 불가), 메뉴·설정·일시정지·조작법 안내·오디오·게임 종료 수단 전무(치명적). 필수/권장/선택/완료 항목 분류, 데모 범위 안 A(싱글 중심, 권장)/안 B(싱글+로컬 협동) 비교, 후속 Task(T078~T085) 계획을 완료했다. 사용자가 범위를 확정하고 착수를 승인해야 EPIC-07·v0.4.0을 진행할 수 있다.
- **미구현(MVP-1 범위 밖, 계획됨)**: 멀티플레이(온라인/로컬 다인), 차량, 파손·내구도, 경제, 저장, 여러 택배 종류, 일반 문 상호작용, Steam 연동, 정식 애니메이션/사운드 — 상세는 `docs/GAME_DESIGN.md` 섹션 27, `ROADMAP.md` 참고

## 알려진 문제/부채

- 현재 알려진 문제: `KNOWN_ISSUES.md`
- 향후 개선 필요 항목(버그 아님): `TECH_DEBT.md`

## 프로젝트 관리 체계

- **Documentation System**: 완료 — `ROADMAP.md`/`CHANGELOG.md`/`VERSION.md`/`KNOWN_ISSUES.md`/`TECH_DEBT.md`/`MILESTONES.md`/`DESIGN_DECISIONS.md`/`PROJECT_STRUCTURE.md` 8종 공식 문서 채택
- **Project Management System**: Task 중심 관리에서 Epic → Feature → Task 계층 구조로 전환(`PROJECT_STRUCTURE.md` 참고)
- **MVP-1**: 종료(Closed) — `docs/TASKS.md` T000~T063 전체 완료, 이후 신규 Task는 Epic → Feature → Task 계층을 통해 생성
