# MILESTONES.md

이 문서는 프로젝트의 큰 목표(마일스톤)를 기록한다.

**역할**: 프로젝트의 큰 목표. 각 마일스톤을 이루는 세부 버전과 기능 범위는 `ROADMAP.md`를 참고한다. 이 문서는 "무엇을 위해 개발하는가"를 요약하고, `ROADMAP.md`는 "어떻게 나누어 만드는가"를 다룬다.

---

## Milestone 1 — MVP ✅ 완료

- **Goal**: 물리 기반 택배 운반이라는 핵심 행동만으로 재미를 검증할 수 있는 싱글플레이 프로토타입을 완성한다.
- **Done Criteria**: `docs/GAME_DESIGN.md` 섹션 28의 MVP 완료 조건 10개 충족(완료). 대응 버전: `ROADMAP.md` v0.1.0.

## Milestone 2 — Gameplay Expansion ✅ 완료

- **Goal**: MVP 코어 루프를 다양한 장애물과 물리 상황에서 검증하고, 협동 물리의 재미를 다인 환경에서 실험한다.
- **Done Criteria**: 좁은 문·벽 등 추가 장애물을 포함한 전체 루프가 치명적 문제 없이 반복 가능하고, 로컬 다인 협동 운반이 최소한 한 가지 형태로 동작함. 대응 버전: `ROADMAP.md` v0.2.0, v0.3.0.
- **완료 근거**: v0.2.0(Physics Playground)이 EPIC-01~05·T070 사용자 최종 승인으로 완료되었고(좁은 문·벽 포함 전체 루프 반복 검증), v0.3.0(Fun Physics Update)이 EPIC-06(Local Co-op Foundation, T074~T076) 사용자 최종 승인으로 완료되어(로컬 2인 협동 운반 동작 확인) 두 대응 버전이 모두 충족되었다. T076 최종 승인 이후 발견된 Held Light Object Push 결함(가벼운 held object가 무거운 물체를 과도하게 미는 문제)도 원인 수정과 사용자 재검증을 거쳐 해결되어, 이 완료 상태에 영향을 주지 않는다.

## Milestone 3 — Steam Demo 🔶 구현 진행 중

- **Goal**: 온라인 멀티플레이·차량 없이도 외부에 공개 가능한 데모 빌드를 배포한다.
- **Done Criteria**: 싱글/로컬 다인 기준으로 처음부터 끝까지 플레이 가능한 빌드가 존재하고, Steam 상점 페이지용 최소 자료(스크린샷 등)가 준비됨. 대응 버전: `ROADMAP.md` v0.4.0.
- **진행 상태**: `docs/TASKS.md` T077(Demo Readiness Audit & Scope Lock) `[DONE]` — 준비 조사 및 데모 범위 안 A(싱글 중심) 확정. T078(Main Menu & Demo Entry) `[DONE]`, T079(Pause, Settings & Exit Flow) `[DONE]`, T080(Player Onboarding & Controls) `[DONE]`, T081(Demo Gameplay Loop & Completion Flow) `[DONE]` — 메뉴 진입부터 반복 배송·완료 화면·다시 플레이까지 처음부터 끝까지 완결된 플레이 흐름이 전부 사용자 승인을 거쳐 구현되었다. T082(Audio and Feedback Pass) `[DONE]` — 무음 상태를 해소하기 위한 최소 절차적 효과음 8개(외부 음원 없음)·시각 피드백 추가, 헤드리스 자동 검증 82개 항목 3회 연속 PASS 및 사용자 수동 테스트 승인 완료. T083(Windows Export and Build Validation) `[BLOCKED]` — `export_presets.cfg` 신규 구성·검증 완료(설정 오류 0건), 로컬에 Godot 4.7.1.stable Export Template이 없어 실제 `.exe` 생성·실행 검증은 진행하지 못함(임의 다운로드 없이 설치 방법만 보고, `docs/TASKS.md` 섹션 35 참고). T084(Performance & Compatibility)~T085(Final Demo Playtest)는 아직 착수 전.

## Milestone 4 — Early Access

- **Goal**: 콘텐츠(여러 택배, 정식 맵)와 핵심 기능(온라인 멀티, 차량)을 갖춘 상태로 Steam Early Access에 진입한다.
- **Done Criteria**: `KNOWN_ISSUES.md` High 항목 0건, 온라인 멀티로 다인 플레이 가능, 차량으로 택배 운반 가능, 최소 콘텐츠(택배 2종 이상, 정식 맵 1개 이상) 확보. 대응 버전: `ROADMAP.md` v0.5.0, v0.8.0.
- **비고**: `ROADMAP.md`에는 별도의 "Early Access" 버전 번호가 없다 — v0.5.0(Content Expansion)부터 v0.8.0(Release Candidate)까지의 누적 결과물이 Early Access 진입 기준에 해당한다.

## Milestone 5 — Steam Release

- **Goal**: 정식 출시.
- **Done Criteria**: `ROADMAP.md` v1.0.0의 Done Criteria(버그 수정 마무리, 최종 최적화, 상점 페이지 완성) 충족, Steam 정식 출시. 대응 버전: `ROADMAP.md` v1.0.0.

---

## 진행 상태 요약

| Milestone | 상태 |
|---|---|
| 1. MVP | 완료 |
| 2. Gameplay Expansion | 완료 — v0.2.0(Physics Playground) 완료, v0.3.0(로컬 다인 협동) 완료(EPIC-06, T074~T076 전부 `[DONE]`, `ROADMAP.md` 참고) |
| 3. Steam Demo | 구현 진행 중 — T077~T082 `[DONE]`(전부 사용자 승인 완료), T083 `[BLOCKED]`(Export Template 설치 대기), T084~T085 시작 전(`ROADMAP.md` EPIC-07 참고) |
| 4. Early Access | 시작 전 |
| 5. Steam Release | 시작 전 |

다음 마일스톤(또는 마일스톤 내 다음 버전) 착수는 사용자의 명시적 승인이 있을 때 시작한다(`CLAUDE.md` 섹션 6).
