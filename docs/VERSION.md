# VERSION.md

이 문서는 현재 프로젝트 상태를 한눈에 보여준다.

**역할**: 지금 프로젝트가 어떤 상태인가. 변경 이력은 `CHANGELOG.md`, 앞으로의 계획은 `ROADMAP.md`를 참고한다. 이 문서는 매 버전 릴리스 시점에 갱신한다.

---

| 항목 | 내용 |
|---|---|
| **Current Status** | **Project Baseline Established** |
| **Current Version** | v0.1.0 — MVP Complete |
| **Development Stage** | MVP 완료, 장기 개발 준비 단계 |
| **Current Phase** | Gameplay Expansion — In Progress (`docs/TASKS.md` T064~T069·T072 전부 `[DONE]`, EPIC-01·EPIC-02·EPIC-03·EPIC-05 완료; T071은 과거 구현 이력으로 종료(T072가 대체); T070은 EPIC-05 완료로 잠시 `[BLOCKED]` 해제되었다가 T073(1인칭 시점 전환) 착수로 다시 `[BLOCKED]`; T073 `[REVIEW]`, 자동 검증 완료·사용자 수동 테스트 대기) |
| **Current Milestone** | Milestone 1 — MVP 완료(`MILESTONES.md` 참고) |
| **Engine** | Godot 4.7.1 (stable, win64) |
| **Language** | GDScript |
| **Physics Engine** | Jolt Physics |
| **Renderer** | Forward+ (Windows: D3D12) |
| **Repository State** | 정상 동작하는 기준선(Baseline) — `docs/TASKS.md` T000~T063 전체 완료 |
| **Baseline** | v0.1.0 = MVP-1 Baseline (본 문서 작성 시점) |
| **Target Platform** | Windows PC (Steam) |
| **Target Release** | v1.0.0 — Steam Release (`ROADMAP.md` 참고, 확정 일정 없음) |
| **Last QA** | `docs/TASKS.md` T060(전체 코어 루프 통합 테스트, 사용자 3회 이상 수동 플레이 PASS), T045(계단·경사로 운반 통합 검증, PASS WITH NOTES), T062(MVP-1 완료 검토, 최종 판정 PASS) |
| **Next Milestone** | Milestone 2 — Gameplay Expansion (`MILESTONES.md`, `ROADMAP.md` v0.2.0 참고) — 착수 여부는 사용자 승인 필요 |

## 현재 구현 범위 요약

- **완료**: 이동/점프/달리기/카메라, 계단·경사로 통과, 배송 구역 감지·성공(Package 전용), 성공 HUD, 재시작, 환경 물리 오브젝트(`PhysicsBarrel`/`PhysicsCrate`/`SmallPhysicsBox`, T064), 전역 Physics Interpolation 활성화, 수직 벽 테스트 구역(`TestWall`)과 상호작용 물리적 가시선 검사(벽 너머 잡기·Hold 유지 차단, T065), 좁은 문 테스트 구역(`NarrowDoorwayTestArea`, T066) — EPIC-01(Obstacle Course Expansion) 전체 완료, 사용자 최종 승인. 확장 환경 물리 감각 재검토(`max_follow_speed` 6.0→7.5로 조정, 나머지 값 유지, T068) — EPIC-02(Physics Feel Tuning) 전체 완료, 사용자 최종 승인. 다수 Package 동시 존재(`PackageB`/`PackageC` 추가, T069) — EPIC-03(Multi-Package Stability) 전체 완료, 사용자 최종 승인. 범용 `GrabbableBody` 잡기(Package/PhysicsBarrel/PhysicsCrate/SmallPhysicsBox 전부 잡기 가능)와 **Force-Based Physics Grab**(실제 클릭 표면 지점에 Spring-Damper 힘 적용, 위치/속도 직접 제어 없음, 다중 Grab Connection 구조, `GrabCollisionBarrier` 기반 Player 관통·밀림 방지, 고정 Throw·스윙 impulse 완전 제거, T071→T072) — EPIC-05(Generalized Object Interaction) 전체 완료, 사용자 최종 승인(T072)
- **구현 중(REVIEW, 사용자 수동 테스트 대기)**: 3인칭 → 1인칭 시점 전환 및 Grab 조작성 개선(T073) — 캐릭터 Mesh가 잡은 물체·조준 대상을 가리는 문제 해결을 위해 카메라를 Player 눈높이로 옮기고, Grab 판정을 화면 중앙 기준으로 재정렬, 상태형 조준점 UI 추가. Force-Based Grab 힘 계산 자체는 무변경, 헤드리스 자동 검증 128개 항목 통과, 사용자 수동 테스트 대기 중
- **대기 중(T073 승인 후 재개)**: 전체 루프 최종 재미 검증(T070) — EPIC-05 완료로 한 차례 `[BLOCKED]`가 해제되었으나, T073이 조작·시점을 다시 바꾸는 중이라 재차단됨. T073 승인 후 1인칭 기준으로 재개한다. EPIC-04(재미 검증)는 이 평가 결과로 완료 여부가 결정된다
- **미구현(MVP-1 범위 밖, 계획됨)**: 멀티플레이(온라인/로컬 다인), 차량, 파손·내구도, 경제, 저장, 여러 택배 종류, 일반 문 상호작용, Steam 연동, 정식 애니메이션/사운드 — 상세는 `docs/GAME_DESIGN.md` 섹션 27, `ROADMAP.md` 참고

## 알려진 문제/부채

- 현재 알려진 문제: `KNOWN_ISSUES.md`
- 향후 개선 필요 항목(버그 아님): `TECH_DEBT.md`

## 프로젝트 관리 체계

- **Documentation System**: 완료 — `ROADMAP.md`/`CHANGELOG.md`/`VERSION.md`/`KNOWN_ISSUES.md`/`TECH_DEBT.md`/`MILESTONES.md`/`DESIGN_DECISIONS.md`/`PROJECT_STRUCTURE.md` 8종 공식 문서 채택
- **Project Management System**: Task 중심 관리에서 Epic → Feature → Task 계층 구조로 전환(`PROJECT_STRUCTURE.md` 참고)
- **MVP-1**: 종료(Closed) — `docs/TASKS.md` T000~T063 전체 완료, 이후 신규 Task는 Epic → Feature → Task 계층을 통해 생성
