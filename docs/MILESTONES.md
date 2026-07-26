# MILESTONES.md

이 문서는 프로젝트의 큰 목표(마일스톤)를 기록한다.

**역할**: 프로젝트의 큰 목표. 각 마일스톤을 이루는 세부 버전과 기능 범위는 `ROADMAP.md`를 참고한다. 이 문서는 "무엇을 위해 개발하는가"를 요약하고, `ROADMAP.md`는 "어떻게 나누어 만드는가"를 다룬다.

---

## Milestone 1 — MVP ✅ 완료

- **Goal**: 물리 기반 택배 운반이라는 핵심 행동만으로 재미를 검증할 수 있는 싱글플레이 프로토타입을 완성한다.
- **Done Criteria**: `docs/GAME_DESIGN.md` 섹션 28의 MVP 완료 조건 10개 충족(완료). 대응 버전: `ROADMAP.md` v0.1.0.

## Milestone 2 — Gameplay Expansion

- **Goal**: MVP 코어 루프를 다양한 장애물과 물리 상황에서 검증하고, 협동 물리의 재미를 다인 환경에서 실험한다.
- **Done Criteria**: 좁은 문·벽 등 추가 장애물을 포함한 전체 루프가 치명적 문제 없이 반복 가능하고, 로컬 다인 협동 운반이 최소한 한 가지 형태로 동작함. 대응 버전: `ROADMAP.md` v0.2.0, v0.3.0.

## Milestone 3 — Steam Demo

- **Goal**: 온라인 멀티플레이·차량 없이도 외부에 공개 가능한 데모 빌드를 배포한다.
- **Done Criteria**: 싱글/로컬 다인 기준으로 처음부터 끝까지 플레이 가능한 빌드가 존재하고, Steam 상점 페이지용 최소 자료(스크린샷 등)가 준비됨. 대응 버전: `ROADMAP.md` v0.4.0.

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
| 2. Gameplay Expansion | 진행 중 — v0.2.0(Physics Playground) 완료, v0.3.0(로컬 다인 협동) 진행 중(EPIC-06, T074 `[DONE]`, T075 `[REVIEW]`, `ROADMAP.md` 참고) |
| 3. Steam Demo | 시작 전 |
| 4. Early Access | 시작 전 |
| 5. Steam Release | 시작 전 |

다음 마일스톤(또는 마일스톤 내 다음 버전) 착수는 사용자의 명시적 승인이 있을 때 시작한다(`CLAUDE.md` 섹션 6).
