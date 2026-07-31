# CHANGELOG.md

이 문서는 버전별 변경 내역을 [Semantic Versioning](https://semver.org/) 스타일로 기록한다.

**역할**: 무엇이 변경되었는가. "앞으로 무엇을 만들 것인가"는 `ROADMAP.md`, "지금 프로젝트 상태가 어떤가"는 `VERSION.md`를 참고한다.

실제로 구현되어 `docs/TASKS.md`에서 완료(`[DONE]`) 확인된 항목만 기록한다. 계획 단계이거나 보류된 기능은 기록하지 않는다.

---

## [Unreleased] — Steam Demo (In Progress)

v0.4.0 범위의 구현 작업 착수. `docs/TASKS.md` T077(Demo Readiness Audit & Scope Lock) `[DONE]` — 조사 전용 Task로 코드 변경은 없으며, 사용자가 권장안(안 A — 싱글플레이 중심 데모)을 승인해 v0.4.0 범위를 확정했다. T078(Main Menu & Demo Entry) `[DONE]`(사용자 승인) — 실행 시 곧바로 테스트 레벨로 들어가던 것을 멈추고, 제목·데모 시작·게임 종료만 갖춘 최소 메인 메뉴를 먼저 보여주도록 했으며, v0.4.0 데모 Baseline으로 기록되었다. T079(Pause, Settings & Exit Flow) `[DONE]`(사용자 승인) — Esc 일시정지, MainMenu·PauseMenu 공용 설정 화면(화면/입력/오디오), `user://settings.cfg` 저장·복원을 추가했으며, Pause/Settings/Exit 흐름과 현재 설정값이 v0.4.0 Baseline으로 기록되었다. T080(Player Onboarding & Controls) `[DONE]`(사용자 승인) — 첫 실행 안내 Overlay, MainMenu·PauseMenu 공용 조작법 화면, 짧은 목표 문구를 추가했으며, 온보딩·조작법 UI가 v0.4.0 Baseline으로 기록되었다. 이어서 T081(Demo Gameplay Loop & Completion Flow) `[REVIEW]` — 단일 배송 판정을 Package 3개 반복 배송으로 확장하고, 진행도/토스트 HUD, 플레이 타이머, 완료 화면(다시 플레이/메인 메뉴)을 추가했다. 자동 검증(80개 항목 전부 PASS) 완료, 사용자 수동 테스트 대기 중이라 v0.4.0은 아직 완료 처리하지 않는다. 별도로 T085D(Character Selection, Unique Reservation & Gameplay Animation) `[REVIEW]` — 사용자가 다른 브랜치의 T085 하위 작업 번호를 이어받아 명시적으로 지시한 Task로, `main`의 T081 이후 순서와는 독립적이다(`docs/TASKS.md` 섹션 34의 브랜치·번호 불일치 기록 참고). Kenney Blocky Characters 18종을 캐릭터 선택 UI·로컬 협동 중복 예약 방지·Player 외형 적용·이동/Grab/Carry 애니메이션까지 구현했다. 자동 검증 완료, 사용자 수동 테스트 대기 중.

### Added

- `scenes/ui/MainMenu.tscn`/`MainMenu.gd` 신규 — 제목("Hell Delivery")·데모 시작·게임 종료 버튼만 있는 최소 메인 메뉴. Scene 경로는 `DEMO_SCENE_PATH` 상수 하나로만 관리(전역 Scene Manager 없음). 데모 시작은 `get_tree().change_scene_to_file()`로 `PrototypeLevel.tscn` 전환, 게임 종료는 `get_tree().quit()`(T078)
- `project.godot`의 `ui_accept` 액션에 게임패드 `JOY_BUTTON_A` 바인딩 추가 — 기존에는 키보드(Enter/Kp Enter/Space)만 있고 게임패드 확인 버튼이 전혀 없어 메뉴를 게임패드로 확정할 방법이 없었다(T078에서 실측으로 발견해 추가, 이 프로젝트 최초의 UI 액션 커스터마이징)
- `autoload/GameSettings.gd` 신규(이 프로젝트 최초의 Autoload) — 화면(창 모드/해상도)·입력(마우스·게임패드 감도, Y축 반전)·오디오(Master Volume) 설정값을 `user://settings.cfg`에 저장·복원하는 유일한 출처. 손상되거나 범위를 벗어난 값은 안전하게 기본값으로 복구되며, 값이 바뀔 때마다 `settings_changed` Signal을 발신해 Player·UI가 각자 반영한다(T079)
- `scenes/ui/PauseMenu.tscn`/`PauseMenu.gd` 신규 — `PrototypeLevel.tscn`의 `UI` 아래 항상 존재하는 일시정지 메뉴(계속하기/다시 시작/설정/메인 메뉴/게임 종료). Esc(`ui_cancel`) 하나로 Settings→Pause→게임플레이 우선순위대로 닫히며, Pause 중에는 `get_tree().paused = true`만으로 Player 이동·카메라 회전·물리(RigidBody3D)·Grab Spring 계산이 추가 코드 없이 전부 멈춘다(T079)
- `scenes/ui/SettingsPanel.tscn`/`SettingsPanel.gd` 신규 — MainMenu와 PauseMenu 양쪽이 동일하게 재사용하는 공용 설정 화면. 창 모드/해상도, 마우스·게임패드 시점 감도, 게임패드 Y축 반전, Master Volume, 기본값 복원을 제공하며 별도 적용 버튼 없이 즉시 `GameSettings`에 반영·저장된다(T079)
- `project.godot`의 `ui_cancel` 액션에 게임패드 `JOY_BUTTON_B` 바인딩 추가 — 기존에는 키보드 Escape만 있고 게임패드 뒤로 가기/일시정지 버튼이 전혀 없었다(T078의 `ui_accept` 사례와 동일 패턴으로 T079에서 실측으로 발견해 추가)
- `Player.gd`에 `_apply_settings()` 추가 — `GameSettings`의 마우스 감도·게임패드 감도·Y축 반전을 `_ready()`와 `settings_changed` Signal 수신 시 즉시 반영한다(이동 속도·Grab Force 등 물리값은 무변경, T079)
- `scenes/ui/OnboardingOverlay.tscn`/`OnboardingOverlay.gd` 신규 — `PrototypeLevel.tscn`의 `UI` 아래 항상 존재하며, `GameSettings.onboarding_seen`이 아직 `false`일 때만 스스로 표시되는 첫 실행 안내. 표시 중에는 `get_tree().paused = true`로 PauseMenu와 동일한 방식으로 게임이 멈추고, 키보드/마우스/게임패드 아무 press로나 닫힌다(T080)
- `scenes/ui/ControlsPanel.tscn`/`ControlsPanel.gd` 신규 — MainMenu와 PauseMenu 양쪽이 재사용하는 공용 조작법 화면(이동/시점/잡기·놓기/일시정지/다시 시작/목표 6줄, 정적 안내라 GameSettings 구독 없음)(T080)
- `GameSettings.gd`에 `onboarding_seen` 저장 항목과 `set_onboarding_seen()` 추가 — 손상값은 안전하게 `false`로 복구되며, "기본값 복원"(`reset_to_defaults()`)에서는 의도적으로 제외한다(T080)
- `DeliveryHUD.tscn`/`.gd`에 `GoalLabel`/`GoalTimer`/`show_goal()` 추가 — 목표 문구를 4초간 표시한 뒤 자동으로 사라지게 하는 최소 확장(T080)
- `MainMenu.tscn`/`.gd`, `PauseMenu.tscn`/`.gd`에 조작법 버튼과 `ControlsPanel` 진입 기능 추가 — 여는 쪽에서 SettingsPanel이 열려 있으면 자동으로 닫아 두 화면이 동시에 뜨지 않는다(T080)
- `scenes/ui/CompletionOverlay.tscn`/`CompletionOverlay.gd` 신규 — Package `TARGET_PACKAGE_COUNT`개를 전부 배송했을 때 표시하는 최종 완료 화면(배송 완료 문구, 완료 시간, 다시 플레이/메인 메뉴 버튼). `PauseMenu`와 같은 구조(`CanvasLayer`, `process_mode=ALWAYS`, `PrototypeLevel`에 항상 존재하는 단일 인스턴스)를 따르되 Esc로는 닫히지 않는다(T081)
- `DeliveryZone.gd`에 `TARGET_PACKAGE_COUNT` 상수(현재 3)와 `all_packages_delivered` Signal 추가 — 같은 Package의 재진입은 중복 집계하지 않고, 목표 개수는 이 상수 하나에서만 관리해 온보딩·조작법·HUD 문구가 전부 이 값을 동적으로 읽어온다(T081)
- `GrabbableBody.gd`에 `deliver()`와 `_delivered` 플래그 추가 — DeliveryZone이 배송 판정을 내렸을 때만 호출되는(Package 전용) 안전한 은퇴 처리: 기존 `remove_grabber()`로 모든 Grab Connection을 먼저 해제하고, 이후 `add_grabber()`를 항상 거부하며, `freeze`+`collision_layer/mask=0`으로 물리를 정리한 뒤 0.6초 후 숨긴다(T081)
- `DeliveryHUD.tscn`/`.gd`에 `ProgressLabel`("배송 완료 N / 3")과 `DeliveryToastLabel`("배송 완료!", 1초) 추가(T081)
- `PrototypeLevel.gd`에 플레이 시간 측정(`_play_time_elapsed`, `_physics_process`에서 누적) 추가 — Pause/온보딩/완료 화면 모두 `get_tree().paused`를 쓰므로 이 함수 자체가 호출되지 않아 별도 조건 없이 실제 플레이 시간만 집계된다(T081)
- `scripts/character/CharacterDefinition.gd`(Resource), `scripts/character/CharacterCatalog.gd`(정적 유틸리티, Autoload 아님) 신규 — Kenney Blocky Characters 18종을 `resources/characters/character_a.tres`~`character_r.tres`로 등록. 파일 시스템 순회 없이 명시적 ID 목록으로만 조회하며, 잘못된 ID는 `resolve_id_or_default()`로 안전하게 첫 유효 캐릭터로 복구한다(T085D)
- `scripts/character/CharacterAnimationController.gd` 신규 — Idle/Walk/Sprint/Air 이동 상태를 실제 물리 velocity 기반으로 전환하고, "holding-both" Clip에서 추출한 팔 Pose를 Walk/Sprint Animation 위에 매 프레임 비누적 Slerp로 덮어써 운반(Carry) 자세를 표현한다. Grab 시작 시 "pick-up" 원샷 재생, Release는 팔 Override 블렌드를 0으로 되돌리는 것만으로 자연스럽게 처리(T085D)
- `scripts/character/CharacterVisual.gd` + `scenes/character/CharacterVisual.tscn` 신규 — 외부 GLB 모델을 감싸는 Wrapper. 캐릭터 교체 시 이전 인스턴스를 완전히 제거해 중복 인스턴스가 남지 않는다(T085D)
- `scripts/character/CharacterSelectionManager.gd` 신규(Autoload 아님) — 로컬 협동 캐릭터 중복 예약 방지 전용. 확정(`confirm()`) 시에만 예약되고 미리보기는 예약하지 않으며, 다른 Player가 확정하면 상대 목록에서 즉시 제외되고 자동으로 다음 사용 가능 캐릭터로 이동한다(T085D)
- `scenes/ui/CharacterSelectPanel.tscn`/`.gd` 신규 — 이름/좌우 화살표/SubViewport 3D Preview/확인/뒤로로 구성된 캐릭터 선택 UI. 마우스·키보드·게임패드를 모두 지원하며, 로컬 협동에서는 두 Panel이 서로 다른 입력 장치에만 반응한다(T085D)
- `docs/ASSET_LICENSES.md` 신규 — Kenney Blocky Characters 2.0(CC0 1.0) 라이선스 기록(T085D)

### Changed

- `project.godot`의 `run/main_scene`을 `PrototypeLevel.tscn`에서 `MainMenu.tscn`으로 변경 — F5(또는 배포 실행) 시 메인 메뉴가 먼저 표시되고, "데모 시작" 선택 시에만 `PrototypeLevel.tscn`으로 전환된다. 로컬 협동(`LocalCoopTest.tscn`)은 메뉴에 노출하지 않으며 기존과 동일하게 에디터 F6으로만 실행한다(T078)
- `MainMenu.tscn`/`MainMenu.gd`에 설정 버튼과 `SettingsPanel` 진입 기능 추가(데모 시작, 설정, 게임 종료 순서) — 기존 데모 시작·게임 종료 동작은 무변경(T079). 이후 T080에서 버튼 순서가 데모 시작·조작법·설정·게임 종료로 확장되었다.
- `PauseMenu.gd`의 Esc(`ui_cancel`) 처리 우선순위가 ControlsPanel → SettingsPanel → Pause 재개 → Pause 열기로 확장되었고, 맨 앞에 형제 `OnboardingOverlay`가 보이는 동안에는 아무것도 하지 않고 반환하는 가드가 추가되었다(T080). T081에서 `CompletionOverlay`가 보이는 동안 아무것도 하지 않는 동일한 가드가 하나 더 추가되었다.
- `DeliveryHUD.tscn`/`.gd`의 기존 단일 성공 패널(`SuccessPanel`/`show_success()`)을 제거 — 1개 Package만 배송하던 옛 흐름 전용이라 3개 반복 배송 흐름과 맞지 않아, 상시 진행도 표시와 배송별 짧은 토스트로 대체했다(T081)
- `OnboardingOverlay.gd`·`ControlsPanel.gd`의 목표 문구가 `DeliveryZone.TARGET_PACKAGE_COUNT`를 동적으로 읽어와 실제 배송 목표(Package 3개)와 항상 일치하도록 변경되었다(T081)
- `Player.tscn`에 `CharacterVisualRoot`(`CharacterVisual` 인스턴스) 추가, `Player.gd`에 `apply_character()` 추가 — `_ready()`에서 `GameSettings.selected_character_id`를 기본 적용하고, 로컬 협동 등 외부에서 다시 호출해 Player별로 다른 캐릭터를 덮어쓸 수 있다. 기존 자리표시자 Capsule Mesh는 캐릭터 적용 성공 시 숨긴다. T074의 Player별 시각 레이어 숨김 로직(`_apply_visual_layer_for_slot()`)은 자리표시자 Capsule 대신 캐릭터의 `head` 파츠에 적용하도록 재대상화했다 — 몸통·팔·다리는 로컬 화면에도 계속 보인다(T085D)
- `GameSettings.gd`에 `selected_character_id`, `set_selected_character_id()`, `_safe_string()` 추가 — `user://settings.cfg`의 `[character] selected_id`로 저장/복원되며 잘못된 값은 안전하게 첫 유효 캐릭터로 복구된다(T085D)
- `MainMenu.tscn`/`.gd`에 "캐릭터" 버튼과 `CharacterSelectPanel` 진입 기능 추가(데모 시작 다음, 조작법 앞) — 기존 설정/조작법 패널과 동일한 상호 배타 표시 패턴을 재사용한다(T085D)
- `LocalCoopTest.tscn`/`.gd`에 `CharacterSelectOverlay`(화면을 좌우로 나눈 P1/P2 캐릭터 선택 UI) 추가 — 두 Player가 모두 확정해야 오버레이가 사라지고 이미 존재하는 Player/Player2 인스턴스에 선택한 외형이 적용된다(새 Player를 생성하지 않음)(T085D)

### Fixed

- `OnboardingOverlay`의 루트 `Control`이 Godot 기본값(`mouse_filter=STOP`)을 그대로 쓰면 화면 전체를 덮은 채 마우스 클릭을 전부 흡수해 `_unhandled_input`에 전달되지 않아, "마우스 클릭으로 닫기"가 전혀 동작하지 않던 결함을 발견해 루트부터 모든 하위 Container/Label까지 `mouse_filter = MOUSE_FILTER_IGNORE`로 수정했다(T080, 자동 검증 중 발견)

### Known Notes

- 마우스 캡처(`MOUSE_MODE_CAPTURED`)는 헤드리스 환경에서 자동 검증이 불가능하다(직접 대입해도 즉시 `VISIBLE`로 되돌아감을 실측 확인, 엔진 자체 제약) — 데모 진입 후 실제 캡처 여부는 사용자 수동 테스트로 확인
- PauseMenu·SettingsPanel은 900×500처럼 매우 작은 창 크기에서는 버튼이 뷰포트 밖으로 잘릴 수 있다(1280×720 이상에서는 문제 없음, 실측 확인) — 우선순위 낮은 것으로 판단, 필요 시 별도 Task로 제안. ControlsPanel·OnboardingOverlay·CompletionOverlay도 같은 성격의 위험이 있으나 T080·T081 자동 검증에서는 재확인하지 않았다.
- `LocalCoopTest.tscn`은 `PrototypeLevel.tscn`을 통째로 인스턴스하므로 새 `PauseMenu`·`OnboardingOverlay`·`CompletionOverlay`도 구조상 함께 존재하게 되지만, `CanvasLayer`가 SubViewport가 아닌 루트 Viewport에 그려져 분할 화면 한쪽이 아니라 창 전체에 걸쳐 뜰 가능성이 있다 — 로컬 협동에서의 Pause·온보딩·완료 화면 UX는 각각 T079·T080·T081 범위 밖이라 설계되지 않았다
- "완료 화면 20회 반복" 자동 검증은 매 반복이 전체 Scene reload를 동반해 비용이 커 3회로 축소해 검증했다(T081)
- 오디오 Asset·Windows Export는 아직 없음(각각 T082·T083 계획)

---

## [0.3.0] — Fun Physics Update

v0.3.0 범위의 구현 작업 전체 완료. `docs/TASKS.md` T074(Local Co-op Test Environment)·T075(Local Co-op Interaction UX)·T076(Local Co-op Final Validation) 전부 자동 검증(각 46/39/46개 항목 3회 연속 PASS)과 사용자 테스트를 거쳐 EPIC-06(Local Co-op Foundation)이 완료되었다. 온라인 멀티플레이가 아닌 **로컬 2인 물리 검증 기반**으로, T074가 입력 슬롯 분리·분할 화면·실제 2인 동시 Grab을 구현했고, T075가 협동 상태(누가 무엇을 잡았는지, 같은 물체를 함께 잡았는지, 연결이 왜 끊겼는지)를 직관적으로 알 수 있도록 UX를 보강했으며, T076이 새 기능 추가 없이 전체 플레이 흐름의 통합 안정성을 검증했다. **T076 사용자 최종 승인 이후 진행된 추가 수동 테스트에서 차단 결함(Held Light Object가 Heavy Object를 과도하게 미는 문제)이 발견되어 T076이 잠시 재오픈되었으나**, 원인 규명·수정·자동 재검증(26개 항목 3회 연속 PASS)과 사용자 재검증(11개 항목)을 모두 마쳐 다시 완료 확정되었다(아래 Fixed 참고) — 이로써 v0.3.0과 Milestone 2(Gameplay Expansion)가 최종 완료되었다.

**한눈에 보는 v0.3.0 (사용자 관점 요약)**: 로컬에서 두 번째 Player(게임패드)와 함께 하나의 물리 월드를 공유하며 플레이한다 — 화면이 좌우로 분할되고, 각자 독립된 입력(P1 키보드+마우스, P2 게임패드 왼쪽 스틱 이동/오른쪽 스틱 시점/트리거+A로 Grab)과 조준점·HUD를 가진다. 같은 물체를 둘이 동시에 잡으면 각자의 힘이 합산되어 혼자보다 확실히 더 잘 들리고, 화면에는 "협동 운반" 표시와 각자의 Grab Point 마커(색으로 구분)가 나타난다. 한 명이 놓아도 다른 한 명의 연결은 그대로 유지되며, 거리 초과나 장애물로 인해 자기 연결만 예기치 않게 끊기면 그 사람 화면에만 짧게 표시된다. 혼자 운반하는 것도 여전히 그대로 가능하다.

### Added

- `scenes/level/LocalCoopTest.tscn`/`LocalCoopTest.gd` 신규 — 기존 `PrototypeLevel`을 그대로 인스턴스해 재사용하고 그 위에 Player2를 추가하는 방식의 로컬 2인 분할 화면 테스트 Scene(레벨·물리 월드 중복 생성 없음). 좌우 `SubViewport` 2개가 동일한 `World3D`를 공유하고, 각각 전용 `ViewCamera`(해당 Player의 실제 Camera3D를 매 프레임 추종)와 전용 `Crosshair`를 가진다(T074)
- `Player.gd`에 `InputProfile` enum(KEYBOARD_MOUSE/GAMEPAD)과 `player_slot`/`input_profile`/`gamepad_device`/`gamepad_look_sensitivity`/`gamepad_deadzone` export 추가 — 기본값(slot 0, KEYBOARD_MOUSE)은 기존 싱글플레이와 완전히 동일하게 동작(T074)
- `Player.gd`에 게임패드 이동(왼쪽 스틱+deadzone)·시점 회전(오른쪽 스틱, `JOY_BUTTON_A`로 Grab) 입력 경로 추가, 마우스/키보드 입력과 프레임 단위로 독립 처리(T074)
- `Player.gd`에 `_apply_visual_layer_for_slot()` 추가 — `player_slot`마다 다른 시각 레이어를 계산해, 로컬 협동에서도 "자기 카메라에는 자기 모델만 안 보이고 다른 Player는 보이는" 동작이 성립하도록 함(T073에서 예견된 위험 해소, T074)
- `Player.gd`에 오른쪽 트리거(`gamepad_grab_trigger_threshold`)+`JOY_BUTTON_A` OR 조합 Grab 입력, `invert_gamepad_y` 옵션 추가 — 둘 다 눌려도 중복 Connection·조기 Release가 생기지 않도록 단일 edge로 추적(T075)
- `GrabbableBody.gd`에 Player별 Grab Point 절차적 마커(작은 구, 물체 자식 노드로 붙어 이동/회전 자동 추종, 슬롯별 색 구분, CollisionShape 없음) 추가(T075)
- `GrabbableBody.gd`에 `DisconnectReason` enum(MANUAL/DISTANCE_EXCEEDED/BLOCKED)과 `grabber_disconnected` 시그널 추가, `Player.gd`에 이를 중계하는 `grab_connection_lost` 시그널 추가(T075)
- `Crosshair.gd`에 `flash()` 추가 — 거리 초과·정적 차단으로 자동 Release될 때만 0.4초 짧게 링 점멸(수동 Release는 점멸 없음)(T075)
- `LocalCoopTest.tscn`/`.gd`에 `CoopStatus` Label 추가 — 같은 물체를 두 Player가 동시에 잡았을 때만("협동 운반") 양쪽 화면에 표시, 한쪽이 놓으면 다음 physics frame 안에 해제(T075)

### Changed

- `Player.tscn`의 `collision_mask`를 21→23(World+**Player**+Package+PhysicsObject)으로 수정 — Player끼리 전혀 충돌하지 않던 결함 수정(T074)
- `Player.gd`의 단일 `gamepad_deadzone`을 `move_deadzone`(왼쪽 스틱)/`look_deadzone`(오른쪽 스틱)으로 분리(T075)

### Fixed

- Player 2명이 로컬에서 동시에 존재할 때, 한 Player가 `sprint`(Shift)나 `jump`(Space)를 누르면 게임패드를 쓰는 다른 Player에게도 그대로 적용되던 입력 누수 → 두 액션 모두 `input_profile == KEYBOARD_MOUSE`로 게이트해 해결(T074)
- `Player.tscn`의 `collision_mask`(21)에 Player 자신의 레이어(2)가 빠져 있어 Player끼리 물리적으로 전혀 충돌하지 않던 문제 → `collision_mask`를 23으로 수정해 해결(T074)
- `LocalCoopTest.gd`에 `PrototypeLevel.gd`와 달리 `restart` 입력 처리가 전혀 없어 로컬 협동 씬에서 R키가 아무 효과도 없던 문제 → 기존 `PrototypeLevel.gd`와 동일한 패턴을 승계해 해결(T076)
- **(T076 사용자 승인 후 재발견·수정)** 가벼운 물체를 Grab한 채로 무거운 물체에 밀착해 전진하면 빈손으로 미는 것보다 더 쉽게 밀리던 결함 → 원인 2가지를 모두 수정: (1) `max_force_per_grabber`(300N)가 held object 질량과 무관하게 적용되던 것을, 무관한 다른 RigidBody와 접촉해 누르는 압축 힘 성분만 `mass * push_transmission_accel`(신규 값, 12.0 N/kg)로 제한하도록 `GrabbableBody.gd`에 `_limit_push_transmission()` 추가. (2) `GrabCollisionBarrier`(Player를 그대로 따라가는 kinematic Body)가 막힌 held object 쪽으로 파고들어 Spring Force와 무관하게 큰 속도를 주입하던 경로를, 무관한 물체와 접촉 중인 동안 Barrier 충돌 mask를 잠시 해제하는 `_update_barrier_mask_for_contact()`로 차단. 공중 운반·swing·release·다중 Grabber 힘 합산은 전혀 변경하지 않음. 자동 검증(26개 항목 3회 연속 PASS)과 사용자 재검증(11개 항목) 모두 승인 완료(T076)

### Known Notes

- `gamepad_look_sensitivity`(2.5)·`move_deadzone`/`look_deadzone`(각 0.2)은 T074에서 사용자 승인된 프로토타입 기준값(Baseline)(`TECH_DEBT.md` TD-014)
- `gamepad_grab_trigger_threshold`(0.5)·`invert_gamepad_y`(기본 false)는 T075에서 새로 도입된, 아직 실측 후보 비교를 거치지 않은 초기값(`TECH_DEBT.md` TD-015)
- `push_transmission_accel`(12.0 N/kg)은 T076 재오픈 결함 수정에서 새로 도입되어 사용자 재검증으로 승인된 v0.3.0 프로토타입 기준값(Baseline) — 여러 후보 실측 비교는 아직 거치지 않은 비차단 튜닝 항목으로 유지(`TECH_DEBT.md` TD-019)
- 기존 `GrabbableBody`의 다중 `grab_connections` 구조(T072)는 T074에서 실제 Player 2명으로 처음 검증되었다 — 별도의 2인 전용 물리나 인원수 배율 없이, 기존 Grabber별 힘 합산만으로 협동 효과가 발생함을 확인(1인 대비 2인이 Crate를 더 높이·더 정확하게 들어올림)

---

## [0.2.0] — Physics Playground

v0.2.0 범위의 구현 작업 전체 완료. `docs/TASKS.md` T064~T070·T072·T073 전부 `[DONE]` — EPIC-01(Obstacle Course Expansion), EPIC-02(Physics Feel Tuning), EPIC-03(Multi-Package Stability), EPIC-05(Generalized Object Interaction), EPIC-04(Playtest & Fun Validation) 전부 완료, 사용자 최종 승인. EPIC-05는 T071 `[REVIEW]`(승인 전)로 시작했다가, 사용자 지시로 T072 "Force-Based Physics Grab"로 이동 방식 자체가 재설계되었고, Player 밀림·관통 결함 수정 2건을 거쳐 사용자 수동 테스트 승인으로 `[DONE]` 확정되었다. T070(EPIC-04)은 EPIC-05 완료로 한 차례 `[BLOCKED]`가 해제되었으나, 곧이어 사용자 지시로 T073(3인칭→1인칭 시점 전환 및 Grab 조작성 개선)이 착수되어 조작·시점이 다시 바뀌는 중이라 `[BLOCKED]`로 되돌아갔다. T073은 자동 검증(128개+18개 항목)과 이후 발견된 Body Push 결함 2건 수정을 거쳐 사용자 수동 테스트 승인으로 `[DONE]` 확정되었고, 이 승인으로 T070의 `[BLOCKED]`가 다시 해제되었다. T070은 14개 평가 항목과 전체 루프 플레이 경로(Spawn→환경 오브젝트 밀집 구역→Stairs→Ramp→NarrowDoorway→TestWall→DeliveryZone→Restart)에서 치명적 결함 없이 사용자 최종 승인을 받아 `[DONE]`으로 확정되었고, 이로써 EPIC-04와 v0.2.0(Physics Playground) 전체가 완료되었다.

**한눈에 보는 v0.2.0 (사용자 관점 요약)**: 1인칭 시점으로 직접 물리 운반을 체감 — 좌클릭을 누르고 있으면 실제로 클릭한 물체의 표면 지점을 잡고(Spring-Damper 기반 Force Grab), 물체마다 질량과 관성에 따라 다르게 반응하며(가벼운 SmallBox는 가볍게, 무거운 Crate는 묵직하게), 중앙과 모서리 중 어디를 잡느냐에 따라 자연스러운 회전이 생긴다. 놓으면 그 순간의 실제 속도로 자연스럽게 날아가고(별도 던지기 임펄스 없음), 잡은 물체가 Player를 뚫고 지나가거나 Player를 밀어내지 않는다. 화면 중앙의 조준점이 항상 실제 Grab 대상과 일치한다. 이 모든 것으로 Package를 배송하고 Restart로 반복 플레이할 수 있으며, 이 전체 경험이 최종 사용자 플레이 테스트를 통과했다.

### Added

- 환경 물리 오브젝트 3종 신규 씬(`scenes/objects/`): `PhysicsBarrel.tscn`(원통형 드럼통, 옆으로 쓰러지면 굴러감), `PhysicsCrate.tscn`(나무 상자, 적층 가능), `SmallPhysicsBox.tscn`(작은 상자, 가볍게 밀림)(T064)
- 신규 collision layer 16(PhysicsObject) — World/Player/Package와 상호 충돌하되 배송 판정 대상에서는 제외
- `PrototypeLevel.tscn`에 `PhysicsObjects` 그룹 노드와 인스턴스 6개(Barrel 1, Crate 2[적층], SmallBox 3) 배치 — 굴림·연쇄 충돌 구역, 적층·붕괴 구역, 배송 경로 인접 구역 구성(T064)
- `PrototypeLevel.tscn`에 `WallTestArea/TestWall`(`StaticBody3D`) 수직 벽 테스트 구역 추가, 기존 World collision layer 사용(T065)
- 전역 Physics Interpolation 활성화(`project.godot`, `physics/common/physics_interpolation=true`)
- `Player.gd`/`Package.gd`에 상호작용·Hold 유지용 물리적 가시선(Ray Query) 검사 추가(T065) — 벽 등으로 막히면 감지·잡기 대상에서 제외되고, 잡은 상태에서 경로가 막히면 연속 3프레임 후 자동 Release
- `PrototypeLevel.tscn`에 `NarrowDoorwayTestArea`(`LeftWall`/`RightWall`/`Lintel`, `StaticBody3D`) 좁은 문 테스트 구역 추가, clear width 1.4m·height 2.2m, 기존 World collision layer 사용(T066)
- `PrototypeLevel.tscn`의 `Gameplay`에 `PackageB`/`PackageC` 인스턴스 추가(기존 `Package`는 유지) — 다수 Package 동시 존재 검증용(T069)
- `scenes/objects/GrabbableBody.gd` 신규(`class_name GrabbableBody extends RigidBody3D`) — 잡기/놓기/HoldPoint 추종/자동 놓기/충돌 예외/지연 복구/스윙 릴리즈를 전부 소유하는 범용 클래스(T071)
- PhysicsBarrel/PhysicsCrate/SmallPhysicsBox에 `GrabbableBody.gd` 스크립트와 `grabbable` 그룹 추가 — 3종 모두 Package처럼 직접 잡을 수 있게 됨(T071)
- Input Map에 `grab_object`(마우스 왼쪽 버튼) 액션 추가(T071)
- `GrabbableBody.gd`에 다중 Grab Connection 구조(`grab_connections: Dictionary`) 추가 — 여러 Grabber가 같은 물체를 동시에 잡고 각자의 힘이 합산되는 구조(로컬 싱글플레이에서는 항상 1개, 향후 멀티플레이 협동 운반의 물리적 기반, T072)
- `Player.tscn`에 `GrabCollisionBarrier`(`AnimatableBody3D`) 추가, 신규 collision layer 6(`GrabBarrier`, 값 32) — Grab 중인 물체만 이 레이어와 일시적으로 충돌해 Player 관통을 막으면서도 실제 Player 몸과는 항상 정상적으로 충돌하도록 분리(T072 결함 수정)
- `scenes/ui/Crosshair.gd` 신규(`class_name Crosshair extends Control`) — 화면 정중앙에 상태형 조준점(기본/조준/홀드 3단계)을 표시, `DeliveryHUD.tscn`의 자식으로 추가, `mouse_filter=IGNORE`(T073)
- `Player.gd`에 `grab_aim_state_changed(state: int)` 시그널 추가 — 기존 Grab 감지/보유 데이터를 그대로 재사용해 조준점 UI에 전달(중복 탐색 없음), `PrototypeLevel.gd`가 `DeliveryHUD.set_crosshair_state()`로 중개(T073)

### Changed

- `Player.gd`의 `E`(`interact`) 잡기 조작을 Hold 방식에서 Toggle 방식으로 변경(T067, `DD-017`) — 한 번 누르면 잡고, 다시 누르면 놓음.
- 잡기 조작을 다시 마우스 왼쪽 버튼(`grab_object`) Hold 방식으로 재변경(T071, `DD-019` 이후) — 누르면 잡고 누르고 있는 동안 유지, 놓으면 최근 카메라 스윙 속도에 비례한 릴리즈. `E`(`interact`)는 잡기·놓기와 완전히 분리되어 아무 동작도 하지 않음(향후 버튼/문/레버용으로 예약)
- `Package.gd`를 `GrabbableBody` 상속으로 축소(`class_name Package extends GrabbableBody` 두 줄), 잡기·이동·놓기 로직 전체를 `GrabbableBody.gd`로 이관(T071)
- `Player.gd`의 `InteractShapeCast`를 `GrabShapeCast`로 개명하고 감지 마스크를 Package(4)에서 Package+PhysicsObject(20)로 확장, 감지 로직을 "가장 가까운 가시선 확보 후보 우선"으로 일반화(T071)
- 잡힌 대상의 이동 가속을 고정값(`follow_acceleration`)에서 공유 `max_carry_force`를 질량으로 나눈 값으로 변경 — 무거운 오브젝트(Crate)일수록 반응이 느림(T071, **T072에서 완전히 폐기**)
- Hold 경로 차단(자동 Release) 판정을 World+Package+PhysicsObject에서 **World만**으로 좁힘 — 동적 오브젝트 접촉만으로는 더 이상 자동 Release되지 않음(T071, T072에서 연결 단위 판정으로 재구현하며 원칙 유지)
- **잡기·운반·놓기 방식을 속도 강제 추종(`move_toward`)에서 Force-Based Physics Grab으로 전면 재설계**(T072, `DD-022`~`DD-024`) — 플레이어는 물체의 위치·속도를 직접 제어하지 않고, 실제로 클릭한 표면 지점(Grab Point)에 제한된 Spring-Damper 힘만 가한다. 잡힌 물체는 항상 정상적인 `RigidBody3D`로 gravity/mass/충돌의 영향을 그대로 받는다
- Grab 중 Player collision exception을 완전히 제거(T072) — 이제 잡은 물체와 Player가 항상 정상적으로 충돌하며, 관통은 예외 처리가 아니라 HoldPoint가 항상 Player 몸 바깥에 있는 물리적 구조로 방지된다 → **T072 결함 수정에서 부분 정정**: 이 구조가 실제로는 Player를 밀어내는 반작용을 낳아, 전용 `GrabCollisionBarrier`와 Grabber별 collision exception(지연 복구 포함)을 재도입했다. HoldPoint가 항상 몸 바깥에 있다는 원래 전제 자체는 유지되지만, "예외 처리 없이" 관통을 막는다는 서술은 더 이상 사실이 아니다(아래 Fixed 참고)
- 고정 전방 Throw(T044~T068)에 이어 T071의 스윙 속도 측정+release impulse 방식도 완전히 제거(T072) — 놓는 순간 별도 impulse 없이, 잡고 있는 동안 Spring-Damper 힘이 이미 만들어 둔 실제 운동량을 그대로 유지하며 날아간다
- 단일 `holder`/`hold_point` 구조를 다중 `grab_connections` Dictionary 구조로 교체(T072) — `TECH_DEBT.md` TD-009 해소
- **기본 카메라 시점을 3인칭에서 1인칭으로 전환**(T073, 사용자 지시) — 3인칭 캐릭터 Mesh가 잡은 물체와 조준 대상을 가리는 문제를 해결하기 위함. `Player.tscn`의 3인칭용 `SpringArm3D`(spring_length=4.5)를 제거하고 `CameraPivot`을 Player 눈높이(로컬 y=0.7)로 옮겨 `Camera3D`를 그 원점에 직접 배치했다. 마우스 좌우 회전은 `CameraPivot`이 아닌 Player 자신의 `rotation.y`(yaw)가 담당하도록 분리했고(`CameraPivot`은 상하 회전만 담당), 이동 방향 계산도 Player 자신의 basis를 사용하도록 변경했다. `docs/GAME_DESIGN.md`의 "3인칭 카메라 기본" 서술과 배치되지만 사용자의 명시적 지시가 우선하며, `GAME_DESIGN.md` 자체는 이번 변경 범위에 포함되지 않아 수정하지 않았다
- `GrabShapeCast`를 `CameraPivot` 로컬 y=-0.5 오프셋에서 `Camera3D`와 완전히 같은 로컬 원점으로 재배치(T073) — Grab 판정이 항상 화면 중앙(조준점)과 구조적으로 일치하도록 함(정렬 오차 0px)
- 로컬 Player의 `MeshInstance3D`에 Visual Layer 2를 부여하고 `Camera3D.cull_mask`에서 해당 레이어를 제외(T073) — 전역 `visible=false`를 쓰지 않아 씬 트리·다른 카메라 기준으로는 여전히 존재, 자신의 카메라에서만 렌더링되지 않음

### Fixed

- PhysicsCrate를 계속 밀 때 발생하던 화면·카메라 떨림 → 원인은 물리 시뮬레이션 불안정이 아니라 물리 틱(60Hz)과 렌더 프레임 사이 보간 부재로 확인, 전역 Physics Interpolation 활성화로 해결(T064, 사용자 재테스트 승인 완료)
- 벽 너머(가려진) Package가 사거리 안에 있으면 그대로 감지·잡기가 가능하던 문제 → 상호작용 판정에 물리적 가시선 검사 추가로 해결(T065)
- Package를 잡은 뒤 벽이 Player-Package 사이에 들어와도 Hold가 계속 유지되던 문제 → Hold 유지 중 경로 차단 검사와 자동 Release 추가로 해결(T065)
- 장애물 없이 순수하게 직선으로 스프린트만 계속해도 Package Hold가 자동으로 풀리던 문제 → `max_follow_speed`(6.0)가 `sprint_speed`(7.0)보다 낮아 구조적으로 따라잡지 못하던 것이 원인, `max_follow_speed`를 7.5로 조정해 해결(T068, `DD-018`, 사용자 재테스트 승인 완료)
- 잡은 Package 등이 다른 Package/환경 물리 오브젝트에 스치기만 해도 Hold가 쉽게 풀리던 문제 → Hold 차단 판정에서 동적 오브젝트를 제외해 해결(T071, 사용자 피드백)
- 고정 Throw 임펄스가 어색하게 느껴지던 문제 → 카메라 스윙 속도 기반 릴리즈로 대체(T071, 사용자 피드백) → **T072에서 그 스윙 릴리즈 방식 자체도 제거하고 자연 운동량 유지로 재대체**
- 잡은 Package로 무거운 Crate를 밀면 비현실적으로 쉽게 밀리던 문제(속도 강제 추종 방식에서는 사실상 무한한 힘처럼 작동할 수 있었음) → Grabber 1명당 힘 상한(`max_force_per_grabber`)이 있는 Force-Based Grab으로 전환해 구조적으로 해결(T072, 사용자 지시)
- Player collision exception을 완전히 제거한 결과, 잡은 물체가 Spring 힘으로 Player 캡슐을 압박하면 `move_and_slide()` 충돌 해석상 Player가 반대로 밀려나던 문제(사용자 재현 보고) → 전용 `GrabCollisionBarrier`(`AnimatableBody3D`, 신규 collision layer 6)를 도입해 실제 Player 충돌과 "잡은 물체 차단"을 분리, Grabber별 collision exception + `intersect_shape()` 기반 지연된 안전 분리 확인으로 해결(T072 결함 수정)
- 위 수정 직후에도 실제 플레이(특히 빠른 카메라 스윙 중)에서 Player 관통이 그대로 재현되던 문제 → `GrabCollisionBarrier`가 Player의 자식 노드였음에도 `sync_to_physics` 특성상 부모 Transform 변경을 자동으로 따라가지 않아 사실상 한 번도 Player를 따라 움직이지 않고 있었던 것이 원인, `Player.gd`에서 `move_and_slide()` 직후 매 물리 프레임 명시적으로 `grab_collision_barrier.global_transform`을 동기화해 해결(T072 결함 수정 후속 정정)

### Known Notes

- 환경 물리 오브젝트의 물리 파라미터(mass/friction/damp), 좁은 문(1.4m) 폭, Export 값 전반은 모두 실측 비교가 아닌 추론/동결값으로 시작되었으나, T068 사용자 수동 테스트에서 전부 승인되어 `TECH_DEBT.md` TD-006/TD-010/TD-011이 해결 처리됨
- T071의 `max_carry_force`(600.0)·스윙 릴리즈 게인(`_SWING_IMPULSE_GAIN=8.0`, `_MAX_SWING_SPEED=12.0`)은 T072에서 이동 방식 자체가 대체되며 함께 폐기됨(`TECH_DEBT.md` TD-012, 역사 기록으로 유지)
- T072의 `grab_spring_strength`(500.0)·`grab_damping`(60.0)·`max_force_per_grabber`(300.0) 등은 각 오브젝트의 실제 mass×gravity를 기준으로 역산한 초기 추정값으로 시작했으나, 사용자 수동 테스트 승인으로 프로토타입 기준값(Baseline)으로 확정됨 — T070 최종 플레이 테스트에서도 "무게 차이 체감", "torque 자연스러움" 등이 재확인됨. 완료를 막는 미해결 결함은 아니며, 추가 조정은 별도 Task로 진행(`TECH_DEBT.md` TD-013)
- T070(Final Playtest and Fun Validation)이 14개 평가 항목·전체 루프 플레이 경로에서 치명적 결함 없이 사용자 최종 승인을 받아 `[DONE]` 확정 — "기본 운반이 재미있는가?"라는 v0.2.0의 핵심 질문에 "재미있다"는 실제 플레이 판단이 내려졌다. EPIC-04와 v0.2.0(Physics Playground) 완료
- T073의 카메라 눈높이(`CameraPivot` 로컬 y=0.7)는 여러 후보를 실측 비교하지 않은 초기 추정값으로 시작했으나, 사용자 수동 테스트 승인으로 프로토타입 기준값(Baseline)으로 확정됨 — 완료를 막는 미해결 결함은 아니며, 추가 조정은 별도 Task로 진행
- T073로 시점이 1인칭으로 바뀐 뒤 한동안 `docs/GAME_DESIGN.md`(섹션 26, 29 등)가 "3인칭 카메라 기본"으로 서술되어 실제 구현과 불일치했었으나, T073 사용자 승인 이후 해당 서술을 1인칭으로 최소 수정해 동기화함(해결됨)

---

## [Unreleased] — Project Bootstrap

MVP-1 종료 후, 장기 개발을 위한 프로젝트 관리 체계를 구축했다. 게임 코드/씬/스크립트 변경은 없다.

### Added

- 공식 프로젝트 관리 문서 8종 채택: `ROADMAP.md`, `CHANGELOG.md`, `VERSION.md`, `KNOWN_ISSUES.md`, `TECH_DEBT.md`, `MILESTONES.md`, `DESIGN_DECISIONS.md`, `PROJECT_STRUCTURE.md`
- Task 중심 관리에서 **Epic → Feature → Task** 계층 구조로 전환(`PROJECT_STRUCTURE.md`)
- v0.2.0(Gameplay Expansion) Epic/Feature/Task 후보 설계(`ROADMAP.md`, 아직 미구현·미착수)

### Changed

- `VERSION.md`: Current Status를 "Project Baseline Established"로, Current Phase를 "Gameplay Expansion Planning"으로 갱신
- `ROADMAP.md`: Current Status를 "Ready for Gameplay Expansion"으로 갱신

### Fixed

- (해당 없음)

### Known Notes

- 이 항목은 게임 기능 변경이 아니라 프로젝트 관리 체계 구축이다 — 버전 번호를 올리지 않고 `[Unreleased]`로 표기한다.

---

## [0.1.0] — MVP Complete

### Added

- 3인칭 플레이어 이동(WASD), 중력, 가감속(`Player.gd`)
- 점프(바닥에 있을 때만, 공중 연속 점프 불가)
- 달리기(`sprint`)
- 마우스 기반 카메라 회전(수평/수직, 수직 각도 제한), 마우스 캡처/해제/재캡처
- 택배(`Package`) 물리 오브젝트(`RigidBody3D`) — 중력, World/Player 충돌
- Player의 제한된 `RigidBody3D` 밀기 보조(`_push_away_rigid_bodies()`)
- `ShapeCast3D` 기반 상호작용 감지(`InteractShapeCast`)
- 홀드(hold) 방식 잡기·유지·놓기(`E` 입력)
- `HoldPoint` 목표 위치로의 물리 추종(속도/가속도 상한, 최대 허용 거리 초과 시 자동 놓기)
- 던지기(마우스 왼쪽 버튼, 카메라 방향 기준 임펄스)
- 계단(13단) 및 경사로 지오메트리, 물리적으로 통과 가능
- 배송 구역(`DeliveryZone`, `Area3D`) — Package 진입 감지, 최초 1회 성공 판정, `package_delivered` 시그널
- 배송 성공 HUD(`DeliveryHUD`) — "DELIVERY COMPLETE" 및 재시작 안내 표시
- 재시작(`R` 입력, 현재 씬 전체 재로드) — 성공 전/후 모두 동작, 반복 가능
- Input Map 10개 액션(이동 4, 점프, 달리기, 상호작용, 던지기, 재시작, 마우스 해제)
- 충돌 레이어 4종(World/Player/Package/DeliveryZone) 체계

### Changed

- (해당 없음 — 최초 버전)

### Fixed

- `CharacterBody3D`의 `safe_margin` 기본값(0.001)이 `RigidBody3D`와의 접촉 시 폭발적 튕김을 유발하던 문제 → 0.08로 조정
- 잡힌 Package가 holder(Player)와 여전히 물리적으로 충돌 관계라 Player가 밀리거나 함께 공중부양하던 문제 → holder와의 `add_collision_exception_with()` 양방향 예외 처리로 해결
- 겹친 상태에서 Package를 놓을 때 침투 해소 충격으로 Player가 튕기거나 밀리던 문제 → 물리적 놓기와 충돌 예외 해제를 분리, 연속 3프레임 미겹침 확인 후 지연 복구
- HUD 표시 후 마우스로 카메라 회전이 되지 않던 문제(전체 화면 `Control`의 기본 `mouse_filter`가 마우스 입력을 소비) → `MOUSE_FILTER_IGNORE` 적용
- 계단을 걸어서 오를 수 없던 문제 → 원인 2가지 확인 후 해결: (1) Floor와 Stairs 사이 실제 존재하던 1m 간격 제거, (2) 단 높이를 0.4m → 0.15m로 낮추고 단 수를 5 → 13으로 늘려 전체 높이 유지
- 던지기 힘이 너무 약해 "던지기"가 아니라 "드롭"처럼 느껴지던 문제 → impulse 값을 실측 재탐색해 12.0 → 200.0으로 조정(수평 비행거리 약 4m)

### Known Notes

- 목표 안내(`GoalLabel`) UI 미구현(`GAME_DESIGN.md` 완료 조건에는 없음)
- 벽에 택배가 걸렸을 때의 물리 안정성 미검증(현재 레벨에 벽 지오메트리 없음)
- 상세 내용은 `KNOWN_ISSUES.md`, `TECH_DEBT.md` 참고
