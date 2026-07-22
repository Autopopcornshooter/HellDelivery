# PROJECT_STRUCTURE.md

이 문서는 MVP-1 종료 이후 프로젝트 관리 체계를 정의한다. MVP-1까지는 `docs/TASKS.md`의 단일 계층 Task 목록(T000~T063)으로 관리했다. 이후로는 **Epic → Feature → Task** 계층을 도입해 더 큰 단위의 계획과 세부 실행 단위를 분리한다.

이 문서는 게임 기획(`GAME_DESIGN.md`)이나 기술 구조(`ARCHITECTURE.md`)를 다루지 않는다. **프로젝트를 어떻게 계획하고 추적하는가**만 다룬다.

---

## 1. 프로젝트 계층

```text
Vision              (GAME_DESIGN.md 섹션 35 "최종 비전" — 변하지 않음)
  ↓
  Player Experience

  ↓

Design Pillars

  ↓

Gameplay Loop

  ↓
Roadmap             (ROADMAP.md — 버전 단위 장기 계획)
  ↓
Milestone           (MILESTONES.md — 로드맵을 묶은 큰 목표)
  ↓
Epic                (ROADMAP.md 내 버전별 섹션 — 하나의 버전 안에서 다루는 큰 작업 덩어리)
  ↓
Feature             (Epic을 이루는 개별 기능 단위)
  ↓
Task                (docs/TASKS.md — 실제로 구현하는 최소 실행 단위)
```

## 2. 각 계층의 역할

| 계층 | 역할 | 담당 문서 |
|---|---|---|
| **Vision** | 이 게임이 왜 존재하는가. 거의 바뀌지 않는다. | `docs/GAME_DESIGN.md` |
| **Roadmap** | 버전(v0.x.0~v1.0.0) 단위로 "무엇을 언제 만들 것인가"를 배열한다. | `docs/ROADMAP.md` |
| **Milestone** | 여러 버전을 묶어 "지금 우리가 향하는 큰 목표"를 요약한다(예: MVP, Gameplay Expansion, Steam Demo). | `docs/MILESTONES.md` |
| **Epic** | 하나의 버전(Roadmap 항목) 안에서, 독립적으로 가치를 낼 수 있는 큰 작업 덩어리. 여러 Feature로 구성된다. | `docs/ROADMAP.md`의 해당 버전 섹션 |
| **Feature** | Epic을 이루는 개별 기능. 하나의 Feature는 사용자(플레이어)가 체감할 수 있는 단위여야 한다. | `docs/ROADMAP.md`의 Epic 하위 표 |
| **Task** | 실제로 구현·검증하는 최소 실행 단위. 기존 `docs/TASKS.md`의 T0xx 형식을 그대로 사용한다. | `docs/TASKS.md` |

## 3. 각 계층의 생성 기준

- **Vision**은 새로 만들지 않는다 — `GAME_DESIGN.md`에 이미 확정되어 있다.
- **Roadmap** 항목(버전)은 Milestone이 정의된 뒤, 그 Milestone을 이루기 위해 필요한 버전 단위로 나눌 때 추가한다.
- **Milestone**은 여러 버전을 하나로 묶을 만한 명확한 대외적 목표(예: "데모 출시", "Early Access")가 있을 때만 만든다. Roadmap 버전마다 Milestone을 만들지 않는다.
- **Epic**은 다음 조건을 모두 만족할 때 만든다:
  - 하나의 Roadmap 버전(v0.x.0) 안에 속한다.
  - 여러 Feature로 나뉠 만큼 크다(Feature가 1개뿐이면 Epic 없이 Feature만 둔다).
  - 완료되면 그 자체로 플레이어가 체감할 수 있는 가치를 만든다.
- **Feature**는 Epic 하나를 실제로 구현 가능한 단위로 쪼갤 때 만든다. Feature 하나는 보통 1~5개의 Task로 구성된다.
- **Task**는 Feature(또는 독립적인 유지보수/버그 수정)를 실제로 구현할 준비가 되었을 때, **사용자 승인을 받은 뒤** `docs/TASKS.md`에 추가한다. Task 후보 단계(Roadmap에만 기록된 상태)에서는 아직 Task가 아니다.

## 4. 문서 간 관계

```text
GAME_DESIGN.md ──(기획 원본)──> ROADMAP.md ──(버전별 Epic/Feature)──> TASKS.md(Task)
                                    │
                                    ├──> MILESTONES.md (버전 묶음의 큰 목표)
                                    ├──> VERSION.md (현재 어디에 있는가)
                                    ├──> CHANGELOG.md (완료된 버전의 기록)
                                    ├──> KNOWN_ISSUES.md (진행 중 발견된 문제)
                                    ├──> TECH_DEBT.md (진행 중 미룬 개선 사항)
                                    └──> DESIGN_DECISIONS.md (진행 중 내린 설계 결정)
```

- `ARCHITECTURE.md`는 이 계층 구조와 별도로, **현재 시점의 기술 구조**만 다룬다(Task 완료 시 동기화 대상).
- `CLAUDE.md`는 이 계층 구조와 별도로, **작업 수행 규칙**만 다룬다(승인 절차, 보고 형식 등은 계속 유효).

## 5. Task 생성 규칙

1. Task는 반드시 하나의 Feature(또는 명시적으로 승인된 독립 유지보수 항목)에 속해야 한다.
2. Task 후보는 `ROADMAP.md`의 Epic/Feature 표에만 기록하고, 사용자가 "이 Task를 시작하라"고 명시적으로 승인하기 전에는 `docs/TASKS.md`에 추가하지 않는다.
3. `docs/TASKS.md`에 추가할 때는 기존 형식(작업별 작성 형식 — 상태/목적/선행 작업/작업 범위/제외 범위/생성 파일/수정 파일/완료 조건/테스트 방법/예상 위험)을 그대로 따른다.
4. 한 번에 하나의 Task만 진행한다(`CLAUDE.md` 섹션 4와 동일한 원칙).
5. Task 번호는 계속 이어서 매긴다(T064부터). Epic/Feature 번호와 Task 번호는 서로 다른 채번 체계다.

## 6. Epic 완료 조건

- 소속된 모든 Feature가 완료됨(아래 7번 기준).
- Epic의 Goal에 명시된 Player Value가 실제로 확인됨(플레이 테스트 또는 검증으로).
- 해당 Epic이 속한 Roadmap 버전의 Done Criteria 중 이 Epic이 담당하는 부분이 충족됨.
- 사용자가 Epic 단위로 완료를 승인함.

## 7. Feature 완료 조건

- 소속된 모든 Task가 `[DONE]`으로 확정됨.
- Feature가 의도한 사용자 체감 결과가 실제 플레이 또는 헤드리스 검증으로 확인됨.
- 회귀 테스트(관련 기존 기능)에 영향이 없음이 확인됨.
- 문서(`ARCHITECTURE.md` 등)가 필요한 경우 동기화됨.

## 8. Task 완료 조건

- 기존 `docs/TASKS.md` 관례를 그대로 따른다: 완료 조건 충족, 테스트 결과 기록, 오류·반복 경고 0건, 사용자 승인 후 `[DONE]`.
- `CLAUDE.md`의 절차(구현 전 보고 → 승인 → 구현 → 완료 후 보고 → 승인 → 상태 변경)를 그대로 적용한다. 이 문서는 그 절차를 바꾸지 않는다.

## 9. 문서 갱신 순서

Task가 완료되어 승인될 때마다:

1. `docs/TASKS.md`에 해당 Task를 `[DONE]`으로 표시하고 완료 근거 기록.
2. 그 Task가 속한 Feature의 모든 Task가 끝났다면, `docs/ROADMAP.md`의 해당 Feature/Epic 표에 완료 표시.
3. 구현 결과가 `docs/ARCHITECTURE.md`와 달라졌다면 동기화(T063 방식과 동일).
4. 새로 발견된 문제가 있다면 `docs/KNOWN_ISSUES.md`에 추가.
5. 나중으로 미룬 개선 사항이 있다면 `docs/TECH_DEBT.md`에 추가.
6. 중요한 설계 결정을 내렸다면 `docs/DESIGN_DECISIONS.md`에 DD-0XX로 추가.

Epic이 완료되어 승인될 때마다:

7. `docs/ROADMAP.md`의 Epic 상태를 완료로 표시.
8. 그 Epic이 속한 Roadmap 버전의 모든 Epic이 끝났다면 10번(버전 릴리스 절차)으로 진행.

## 10. 버전 릴리스 절차

하나의 Roadmap 버전(v0.x.0)에 속한 모든 Epic이 완료되면:

1. 해당 버전의 Done Criteria(`ROADMAP.md`)를 실제 결과와 대조해 충족 여부를 확인한다.
2. `docs/CHANGELOG.md`에 새 버전 섹션을 추가한다(Added/Changed/Fixed/Known Notes).
3. `docs/VERSION.md`의 Current Version/Current Phase/Last QA 등을 갱신한다.
4. 해당 버전이 어느 Milestone에 속하는지 확인하고, Milestone이 완료되었다면 `docs/MILESTONES.md`의 상태를 갱신한다.
5. `docs/ROADMAP.md`에서 다음 버전을 "현재"로 표시하고 Current Status를 갱신한다.
6. 이 모든 문서 갱신은 사용자 승인 후 진행한다. Git 커밋/태그 등 저장소 조작은 사용자가 명시적으로 요청할 때만 수행한다(`CLAUDE.md` 섹션 8).

---

## 이 문서의 적용 범위

이 문서는 v0.2.0(Gameplay Expansion)부터 적용된다. MVP-1(v0.1.0, T000~T063)은 이미 완료되어 소급 적용하지 않는다.
