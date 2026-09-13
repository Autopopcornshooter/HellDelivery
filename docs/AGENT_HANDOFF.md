# HellDelivery 작업 인계 프롬프트 (다른 에이전트용)

이 문서는 지금까지 이 저장소에서 진행된 작업을 새로운 에이전트 세션이 그대로 이어받을 수 있도록
정리한 것이다. 아래 내용을 새 세션의 시스템/컨텍스트 프롬프트에 붙여넣으면 된다.

---

## 프로젝트 개요

- Godot 4.7.1, GDScript, 3인칭 물리 기반 협동 택배 게임 《택배기사 지옥》.
- 저장소 루트: `D:\GameProject\HellDelivery` (Windows). 프로젝트 실체는 `hell-delivery/` 하위.
- 엔진 실행 파일: `Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe` (저장소에 포함됨).
- 규칙 문서: `CLAUDE.md`(작업 절차/금지 목록), `docs/GAME_DESIGN.md`(기획 원본), `docs/TASKS.md`(완료 작업 이력 — **가장 중요, 먼저 읽을 것**), `docs/ARCHITECTURE.md`.
- `CLAUDE.md`에는 "MVP-1 전까지 차량/온라인/파손 등 금지" 목록이 있지만, 문서 상단의 여러 승인 기록(2026-09-10~11)으로 이미 대부분 해금된 상태다. **가장 중요한 건 사용자의 최신 명시적 지시가 항상 최우선**이라는 점(문서 9번 우선순위).

## 지금까지 확정된 작업 방식 (표준 루프)

사용자가 명시적으로 승인한 자율 개발 루프:
1. 요청받은 기능을 직접 코드/씬에 구현한다 (1회 1기능 제한, 승인 대기 규칙은 이 표준 루프에서는 해제됨).
2. `tools/Run-Godot.ps1 -Mode Import` / `-Mode Test`로 헤드리스 회귀 검증.
3. 실제 D3D12 렌더링으로 스크린샷을 찍어 시각적으로 확인한다(아래 "테스트 노하우" 참고).
4. 문제 발견 시 스스로 원인을 찾아 고치고 2~3단계 재수행.
5. 정상 동작 확인 후에만 변경 내용을 요약 보고하고 `docs/TASKS.md`에 새 항목(`villa-NN`)으로 기록한다.
6. 자동 검사만 하고 실제 렌더링/패키징 exe 확인을 생략한 경우 이를 "통과"로 보고하지 않는다.

git commit/push/branch 생성은 요청 없이 하지 않는다. 파일 삭제·대규모 변경 전에는 반드시 사용자에게 알린다.

## 지금까지 만든 것 (요약 — 상세는 `docs/TASKS.md`의 villa-73~79 항목 참고)

핵심 게임 루프: 물류센터에서 택배 적재 → 트럭 운전 → 목적지 도착 → 도보로 배송 → 성공/실패 평가.
최대 4인 온라인 협동(호스트-권위 ENet), 로비에서 캐릭터·주문 종류 선택 가능.

### 레벨 3종 (전부 독립된 별도 레벨 씬)

1. **빌라 (`VillaDeliveryRun.tscn` / `OnlineLevel.gd`)** — 원래부터 있던 기본 레벨. 2층 201/202호 두 목적지, 일반/다건/공동운반/혼합/가전 등 여러 "주문" 종류 지원.
2. **엘리베이터 고장 아파트 (villa-77)** — `scenes/level/ApartmentDeliveryRun.tscn` + `ApartmentBuilding.gd`(건물 생성) + `scenes/vehicle/ApartmentDepot.gd`(적재소) + `scenes/network/ApartmentOnlineLevel.gd`(온라인 스캐폴딩). 11층 건물, 목표는 6층 604호, 복도식(층당 8세대), U자로 꺾이는 계단을 실제로 걸어 올라가야 함(엘리베이터는 고장난 장식). 목표 층까지만 실제로 걸을 수 있고 그 위층은 시각적 매스만 있음. villa-78에서 진입로에 코너 2개 추가 + 바닥 뚫림 수정 + 건물 외피(실루엣) 추가.
3. **대저택 정원 미로 (villa-79)** — `scenes/level/MansionDeliveryRun.tscn` + `MansionGarden.gd`(정원/미로 생성) + `scenes/vehicle/MansionDepot.gd`(적재소, 코너 있는 진입로) + `scenes/network/MansionOnlineLevel.gd`. 대문에서 저택 현관까지 생울타리 미로(코너 4개 + 막다른 길 1개)를 도보로 통과해야 함. 저택 내부는 없고 현관 앞이 배송 목표.

### 아키텍처 패턴 (반드시 지킬 것)

- **레벨 스크립트 상속 구조**: `PrototypeLevel.gd`(공통 베이스: 단일 배송존/HUD/온보딩/완료화면/추락 복구) → `VillaDeliveryRun.gd`(다중 목적지 지원) → `VillaCoopLevel.gd`(2인) → `OnlineLevel.gd`(4인+주문별 동적 택배 개수). **아파트/대저택처럼 빌라 전용 로직(201/202 다중 목적지)이 필요 없는 단일 목적지 신규 레벨은 `OnlineLevel.gd`를 상속하지 말고 `PrototypeLevel.gd`를 직접 확장**해서, `OnlineSession.gd`/`FreightRun.gd`가 기대하는 범용 인터페이스(`destinations`, `destination(id)`, `_total_target()`, `_delivered_total()`, `_update_stops()`, `recover_slot()`, `recover_all()`, `player2`/`couriers`/`extra_spawns`/`extra_audio` 등)만 새로 구현한다. `ApartmentOnlineLevel.gd`/`MansionOnlineLevel.gd`가 이 패턴의 정확한 예시이자 템플릿이다 — 새 단일 목적지 레벨을 또 추가한다면 이 두 파일을 거의 그대로 복사해서 이름만 바꾸면 된다.
- **노선별 좌표/문구 일반화**: `scenes/vehicle/FreightRun.gd`에 `ROUTE_DEFAULTS`(빌라 값)와 `ROUTES`(`"apartment"`, `"mansion"` 키의 override 값) 딕셔너리 + `_route(key)` 조회 함수가 있다. 새 노선을 추가할 때 개별 `if/else` 불리언을 늘리지 말고 **`ROUTES`에 새 키를 추가**하는 방식을 따른다. `session.order_id`로 depot 클래스(`FreightDepot`/`ApartmentDepot`/`MansionDepot`)도 `match` 문으로 분기한다.
- **적재소(Depot) 클래스 패턴**: `FreightDepot.gd`/`ApartmentDepot.gd`/`MansionDepot.gd`는 전부 `class_name`, `START`/`PARK` 상수, `box()`/`add_sign()` 헬퍼(공통 로직이지만 의도적으로 파일마다 중복 — 이 프로젝트는 작은 규모라 공유 베이스 클래스를 만들지 않는 것이 관례). 도로에 코너를 넣을 때는 `_road_segment()`/`_curb_segment()`(두 점 사이 방향·길이를 계산해 회전된 박스 생성) 패턴을 그대로 재사용한다(`ApartmentDepot.gd`/`MansionDepot.gd` 참고).
- **건물/정원 생성 스크립트 패턴**: `ApartmentBuilding.gd`/`MansionGarden.gd`는 `_box()`(StaticBody3D+MeshInstance3D+CollisionShape3D 생성)와 `_add_sign()`(**Label3D 한 장만** — 이미 양면에서 보이므로 뒷면 복제하면 텍스트가 겹쳐 깨진다)로 코드 생성된다. `door_position`(또는 유사 필드)을 `var`로 공개해서 온라인 레벨 스크립트가 `DeliveryZone.global_position`을 거기 맞추게 한다.
- **주문(Order) 등록**: `scenes/network/DeliveryOrders.gd`의 `IDS` 배열에 추가하면 로비 드롭다운에 자동 노출된다. 차량 노선 전용(전체 배송 모드에서만 선택 가능) 주문은 `scenes/network/OnlineLobby.gd`의 `FULL_ROUTE_ONLY` 배열에도 추가해야 일반 온라인 협동 모드 목록에서 빠진다.
- **`OnlineSession.gd`의 `_start_world()`**: `order_id`에 따라 어떤 레벨 씬(`.tscn`)과 스크립트(`.gd`)를 인스턴스화할지 `match` 문으로 분기한다. 새 레벨 추가 시 여기에 분기 하나 추가.

### 알려진 함정 / 실수 (반복하지 말 것)

1. **`Label3D` 뒷면 복제 금지** — 이미 양면 렌더링됨. 복제하면 텍스트가 거울상으로 겹쳐 깨진다.
2. **`Package.configure_destination(id, label)` 호출 필수** — 안 하면 `destination_id`가 비어 있어 배송존이 "다른 주소"로 판정해 영구히 거부한다.
3. **`level._update_stops()`는 `OnlineSession.gd`가 무조건 호출** — 새 레벨 스크립트에 이 함수가 없으면 런타임에 `SCRIPT ERROR: Nonexistent function '_update_stops'`가 난다. 반드시 구현할 것(최소한 HUD 텍스트 갱신만이라도).
4. **목적지 `target_package_count == 0`인 배송존을 위한 Package를 미리 만들어두지 말 것** — `FreightRun.tick()`의 완료 판정(`resolved == parcels.size()`)이 그 택배를 영원히 못 배송하게 되어 노선 자체가 끝나지 않는다.
5. **바닥/지면은 항상 실제 이동 경로 전체 폭을 덮는 큰 평평한 안전 슬래브로 깔 것** — 도로/통로 시각 메시만 있고 충돌이 없거나 폭이 좁으면(예: villa-78에서 발견) 코너 바깥이나 도로 밖으로 나가는 순간 그냥 허공으로 떨어진다.
6. **외부 껍데기(shell)/매스를 실내 위에 겹쳐 배치하지 말 것** — 실내 좌표 범위보다 명백히 바깥쪽에 배치해야 한다(안 그러면 로비/계단/복도를 그대로 막아버린 실수가 실제로 있었다).
7. **GDScript 타입 추론 함정**: `for x in [-1, 1]:`처럼 타입 없는 배열 리터럴의 루프 변수(`x`)를 `Vector3 * x` 같은 연산에 바로 쓰면 `:=` 대입에서 "Cannot infer the type" 파싱 오류가 날 수 있다. `float(x)`로 명시 캐스팅할 것.
8. **`tools/Run-Godot.ps1 -Mode Export`를 `-BuildName` 없이 실행하면 안 됨** — `export_presets.cfg`에 적힌 `export_path`(예: Test-14)가 아니라 스크립트 파라미터 기본값 `HellDelivery-Windows-Test-48`에 새로 내보내진다. 최신 빌드를 확인할 때는 반드시 `builds/HellDelivery-Windows-Test-48` 폴더의 타임스탬프를 확인하고, 배포용으로는 이 폴더를 원하는 번호(다음 순번)로 복사한다. (한 번 이 함정에 빠져서 사흘 전 낡은 Test-14 빌드로 네트워크 테스트가 멎는 걸 실제 버그로 오인한 적이 있다.)

## 테스트 노하우 (매우 중요)

- **`tools/Run-Godot.ps1 -Mode Import`**: 파싱 오류만 빠르게 확인.
- **`-Mode Test`**: `res://tests/Playtest.tscn` 헤드리스 실행, 현재 197개 체크(빌라 경로 회귀). `RESULT checks=197 failures=0`이 나와야 정상(엔진 종료 시 나오는 "2 ObjectDB instances were leaked" 경고 때문에 PowerShell 종료 코드가 1이 되는 건 무해한 노이즈이니 무시할 것 — 실제 `RESULT` 줄만 확인).
- **`tools/Run-FreightTest.ps1` / `Run-PartyTest.ps1` / `Run-OnlineTest.ps1` 폴링 스크립트의 함정**: `.report.txt`에서 `^(FAIL |EXIT [1-9])` 패턴이 처음 보이는 즉시 **모든 프로세스를 강제 종료**한다. `FreightPlaytest.gd`에 이미 알려진 플레이키 테스트("low remaining time plays the warning cue once", 약 49번째 줄 근처)가 이 세션 환경에서 거의 항상 실패하는데, 이게 그 이후에 추가한 새 테스트 코드를 **아예 실행되기도 전에 죽여버려서** 검증이 안 됐다는 걸 나중에야 알아챈 적이 있다. **새 시나리오를 `FreightPlaytest.gd`에 추가했다면 이 폴링 스크립트를 믿지 말고, 아래처럼 Godot을 직접 `Start-Process`로 실행해서 전체 `.report.txt`를 확인한다**:
  ```powershell
  $workspace = (Resolve-Path .).Path
  $out = Join-Path $workspace 'validation/villa-48/<임시태그>'
  New-Item -ItemType Directory -Force $out | Out-Null
  $engine = Join-Path $workspace 'Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe'
  $arguments = @('--log-file',(Join-Path $out "freight-0.log"),'--resolution','960x540','--path',(Join-Path $workspace 'hell-delivery'),'--headless','--','network-test-host','freight-test','freight-seat=0','freight-members=1','freight-port=<임의 고유 포트>',('network-output='+$out))
  $proc = Start-Process -FilePath $engine -ArgumentList $arguments -WindowStyle Hidden -PassThru
  $proc.WaitForExit(200000) | Out-Null
  Get-Content (Join-Path $out "freight-0.report.txt") -Tail 40
  ```
  **`report-path=`/`network-output=`는 반드시 절대 경로**여야 한다 — 상대 경로면 `FileAccess.open()`이 null을 반환해 `Playtest.gd`가 조용히 크래시하고 리포트 파일 자체가 안 생긴다.
- **실제 D3D12 렌더링 스크린샷**: 위와 같은 방식으로 `--headless` 대신 `--rendering-driver d3d12`를 주고, cmdline에 `network-visual`을 추가하면(`freight-test`와 함께) `FreightPlaytest.gd`의 `capture(label)` 호출이 실제로 `p{seat+1}-{label}.png`를 저장한다. 새 시나리오를 검증할 때는 `FreightPlaytest.gd`에 `await capture("설명적인-이름")` 줄을 영구적으로 추가해두고(다른 스테이지 캡처들도 전부 이렇게 영구 보관되어 있다), Read 툴로 png를 직접 열어 눈으로 확인한다.
- **패키징된 실제 exe로도 검증**: `-Mode Export`(→ 위 함정 주의)로 내보낸 뒤, `builds/<빌드명>/HellDelivery.console.exe`를 위와 같은 `network-test-host freight-test` 인자로 직접 실행해서 소스 엔진과 동일하게 통과하는지 확인한다. `-Mode BuildTest -BuildName <빌드명>`으로 패키징된 exe의 범용 자체 테스트(`Playtest.tscn` 197건)도 확인한다.
- 헤드리스로 잘 안 잡히는 실제 조작 확인(운전감, 난이도 체감 등)은 "미검증"이라고 정직하게 보고할 것 — 자동 검사 통과를 실제 플레이 확인으로 둔갑시키지 않는다.

## 현재 상태 / 다음 예정 작업

- 완료: 빌라(기본), 아파트(villa-77~78), 대저택 정원 미로(villa-79). 최신 Windows 빌드: `builds/HellDelivery-Windows-Test-84`(대저택 포함본 압축·전달 완료).
- 사용자가 예전에 제안했던 남은 레벨 후보(아직 승인만 됐지 미구현): **강풍 지대**(플레이어/택배/트럭이 바람에 밀려나는 기믹), **우천 지대**(차량이 더 잘 미끄러짐, 택배가 야외에 지속 노출되면 내구도 감소). 다음 대화에서 사용자가 "다음"이라고 하거나 특정 레벨을 지목하면 그때 착수한다 — **먼저 임의로 구현하지 말고 설계를 제안**한 뒤 진행 승인을 받는다(단, 이미 승인된 표준 루프 안에서는 세부 구현 승인은 매번 받지 않아도 된다 — 새로운 레벨 종류 자체를 시작할 때만 다시 확인).
- `docs/TASKS.md`가 이 프로젝트의 유일한 신뢰 가능한 이력 기록이다. 새 작업을 시작하기 전 반드시 먼저 읽고, 끝나면 반드시 새 `villa-NN` 항목을 추가할 것.
