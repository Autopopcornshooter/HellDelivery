# VERSION.md

이 문서는 현재 프로젝트 상태를 한눈에 보여준다.

**역할**: 지금 프로젝트가 어떤 상태인가. 변경 이력은 `CHANGELOG.md`, 앞으로의 계획은 `ROADMAP.md`를 참고한다. 이 문서는 매 버전 릴리스 시점에 갱신한다.

---

| 항목 | 내용 |
|---|---|
| **Current Status** | **Project Baseline Established** |
| **Current Version** | v0.1.0 — MVP Complete |
| **Development Stage** | MVP 완료, 장기 개발 준비 단계 |
| **Current Phase** | Gameplay Expansion — In Progress (`docs/TASKS.md` T064 `[DONE]`, T065 `[DONE]`) |
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

- **완료**: 이동/점프/달리기/카메라, Package 물리(잡기/유지/놓기/던지기), 계단·경사로 통과, 배송 구역 감지·성공, 성공 HUD, 재시작, 환경 물리 오브젝트(`PhysicsBarrel`/`PhysicsCrate`/`SmallPhysicsBox`, `docs/TASKS.md` T064), 전역 Physics Interpolation 활성화, 수직 벽 테스트 구역(`TestWall`)과 상호작용 물리적 가시선 검사(벽 너머 잡기·Hold 유지 차단, `docs/TASKS.md` T065)
- **미구현(MVP-1 범위 밖, 계획됨)**: 멀티플레이(온라인/로컬 다인), 차량, 파손·내구도, 경제, 저장, 여러 택배 종류, 좁은 문, 일반 문 상호작용, Steam 연동, 정식 애니메이션/사운드 — 상세는 `docs/GAME_DESIGN.md` 섹션 27, `ROADMAP.md` 참고

## 알려진 문제/부채

- 현재 알려진 문제: `KNOWN_ISSUES.md`
- 향후 개선 필요 항목(버그 아님): `TECH_DEBT.md`

## 프로젝트 관리 체계

- **Documentation System**: 완료 — `ROADMAP.md`/`CHANGELOG.md`/`VERSION.md`/`KNOWN_ISSUES.md`/`TECH_DEBT.md`/`MILESTONES.md`/`DESIGN_DECISIONS.md`/`PROJECT_STRUCTURE.md` 8종 공식 문서 채택
- **Project Management System**: Task 중심 관리에서 Epic → Feature → Task 계층 구조로 전환(`PROJECT_STRUCTURE.md` 참고)
- **MVP-1**: 종료(Closed) — `docs/TASKS.md` T000~T063 전체 완료, 이후 신규 Task는 Epic → Feature → Task 계층을 통해 생성
