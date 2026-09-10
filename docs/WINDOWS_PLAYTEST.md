# Windows 첫 테스트 빌드 — 2026-09-10

> 이후 기록: 사용자가 이 빌드의 클리어 정상과 현 시야 사용 가능을 확인했다. 다음 빌드 및 현재 인수인계는 WINDOWS_PLAYTEST_02.md를 참조한다. 아래는 villa-01 당시 기록이다.


목표: 기존 캐릭터와 언덕 빌라 레벨로 시작→운반→배송→완료→재시작/메뉴 복귀가 가능한 로컬 Windows 빌드.
온라인 협동·차량 운전·공개 배포는 후속 목표다.

## 작업 시작 상태

- 로컬 확인 기준 `main` / `48d0c50`. 다른 로컬 브랜치 없음, 추적 브랜치 `origin/main` 동일. 원격 fetch는 수행하지 않음.
- 기존 미커밋 변경 11개 파일(캐릭터 head/torso 시야 처리, FOV 설정 및 문서 등)을 그대로 보존하고 추가 수정한다.
- 작업 브랜치: `work/windows-playtest-20260910`. commit/push 없음.
- AGENTS.md 없음. CLAUDE.md, GAME_DESIGN.md, ARCHITECTURE.md, TASKS.md, ROADMAP.md 확인.
- Godot: 저장소의 `Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe`, 버전 `4.7.1.stable.official.a13da4feb`.
- 1차 임포트는 샌드박스 사용자 폴더 저장·인증서 제한과 상대 로그 경로 오류 발생. 승인 후 절대 로그 경로로 재실행: 오류 없이 완료.
- Windows preset 없음, 사용자 export_templates 폴더 비어 있음. 공식 템플릿 다운로드 진행.

## 구현·검증 계획

1. 레벨 DeliveryZone 인스턴스의 목표를 판정·HUD·안내·완료 화면에 전달한다. 빌라/옥상=1, 프로토타입=3.
2. 메뉴를 빌라로 연결, 운반 팔 포즈가 블렌드 완료 후에도 유지되도록 수정.
3. 낙하 복구, F5 위치 복구, 목적지 안내, 최소 효과음 통합.
4. 헤드리스 회귀/경로 검증, 렌더링 화면 검사, Windows export 및 실행 검증.
5. 실행 폴더·ZIP·변경 내역·검증 결과·미검증 항목·플레이 체크리스트 전달.

## 최종 상태

빌드 ID: `2026-09-10-villa-01`. 구현·Windows export·자동 회귀·자동 운반·D3D12 화면 검증 완료. 사용자 직접 플레이 피드백 대기(`[REVIEW]`). 정식 출시나 v0.4.0 전체 완료를 뜻하지 않는다.

- 실행 폴더: `builds/HellDelivery-Windows-Test/`
- 전달 ZIP: `builds/HellDelivery-2026-09-10-villa-01.zip`
- 플레이 안내 원본: `docs/PLAYTEST_README.md` → 빌드의 `README.md`
- 빌드 검증 기록: `validation/BuildTest.*`, `validation/BuildRouteVisual.*`, `validation/BuildVisual.*`
- 초기 조사/실패 이력 로그는 `validation/`에 남아 있다. 배포 `verification/`에는 최종 검증 로그와 대표 화면만 담는다.

## 실제 변경

| 범위 | 변경 |
|---|---|
| 메뉴/레벨 | `MainMenu` 시작을 `Stage01HillsideVilla`로 변경. 기존 캐릭터 18종과 미커밋 FOV 설정 유지 |
| 배송 목표 | `DeliveryZone.target_package_count`를 export 변수로 변경. 빌라/옥상 1, 프로토타입 3. 해당 인스턴스가 HUD·온보딩·조작법·완료 화면의 공통 출처 |
| 애니메이션 | Carry blend=1 이후 early return을 제거해 이동 애니메이션 갱신 후에도 팔 포즈 유지 |
| 복구 | F5: 플레이어/미배송 물건 원위치, 배송 개수 보존. y<-12 낙하 자동 복구. R/메뉴는 전체 재시작 |
| 물리/지형 | 빌라 플레이어 전용 계단 보행면, 원래 계단과 Player만 충돌 예외. 택배는 기존 계단 충돌 유지. 위층 코너를 막던 NorthWall 폭/위치 수정 |
| 시각 안내 | 주변광·배경색, 갈색 택배, 초록 배송 영역·현관 표식, 경로/복구 안내 |
| 오디오 | 레벨 소유 `LevelAudio`: 잡기·놓기·발걸음·배송·복구 PCM. 기존 Master 볼륨 사용, 외부 음원 없음 |
| 빌드 | 공식 4.7.1 x86_64 debug template, EXE/PCK/선택 console wrapper. 자체 검증은 명시적 `-- self-test`만 활성화 |
| 문서 | CLAUDE/TASKS/GAME_DESIGN 작업 규칙에 이번 목표의 연속 실행 예외 명시. ARCHITECTURE/ROADMAP/CHANGELOG 갱신 |

## 검증 결과와 한계

| 검사 | 결과 | 근거·한계 |
|---|---|---|
| Godot 임포트/Windows export | 통과 | 최종 `Export.log` 오류·경고 없음 |
| 소스 헤드리스 회귀 | 통과 | 초기 57개. 이후 검사는 실제 Windows 빌드에서 확대 |
| 최종 Windows 빌드 회귀 | **77/77 통과** | `BuildTest.report.txt`, `START exported=true`, `EXIT 0` |
| 캐릭터 | 18종 정의·모델 적용·운반 포즈 데이터 로드 통과 | 18종 모든 자세를 사람이 시각 검사한 것은 아님 |
| 목표/복구/배송 | 세 레벨 target/HUD/안내 일치, 낙하·F5 복구, 일반 노드 거부, 실제 Area3D 감지, 중복 방지, 완료·재시작·메뉴 복귀 통과 | 회귀 검사에서는 물건을 fixture 위치로 배치. 이를 실제 운반으로 간주하지 않음 |
| 입력 기반 빌라 전체 운반 | **14/14 통과** | 실제 EXE/PCK에서 Grab·이동 입력과 카메라 조준으로 출발→두 계단→복도→현관 완료. 플레이어/택배 순간이동이나 목표 강제 호출 없음. `BuildRouteVisual.report.txt` |
| 실제 렌더링 | 통과 | D3D12 Forward+, RTX 2070 SUPER / NVIDIA 572.70. 메뉴·온보딩·운반·완료·계단 이후 화면을 PNG로 확인. 렌더링 회귀 77/77, 렌더링 운반 14/14 |
| 자동 종료 | 통과 | EXE의 기본 메뉴 실행 + `--quit-after` smoke 수행 |
| 직접 조작·청감·재미 | **미검증 / 사용자 확인 필요** | 자동 입력은 사람의 직접 플레이가 아님. 효과음의 체감 품질도 통과로 기록하지 않음 |
| 다른 PC/GPU·장시간·게임패드·로컬 협동 | **미검증** | 이번 필수 범위 제외. 권장/최소 사양을 확정하지 않음 |

환경 OS 빌드 번호는 `26200`, DisplayVersion `25H2`로 확인했다. 레지스트리 ProductName 문자열은 Windows 10 Home으로 남아 있어 해당 문자열만으로 OS 브랜드를 확정하지 않는다.

## 알려진 문제

- 기본 도형 중심의 테스트 레벨이며 외부 환경 에셋을 본격 적용한 아트 완성본은 아니다. 택배 운반 중 하단 시야 일부는 박스에 가려진다.
- 코너와 계단에서 택배가 벽에 충돌하면 잡기가 끊어질 수 있다. 다시 잡거나 F5/R로 복구한다. 자동 경로는 코너 회전 여유를 확보해 성공했으며, 임의의 모든 조작 경로를 보장하지 않는다.
- 계단의 Player용 경사 충돌면과 실제 계단 표면이 달라 발이 약간 떠 보일 수 있다. 택배의 단차 물리는 유지했다.
- OpenGL Compatibility 초기 검사에서 캐릭터 시야 가림/왜곡이 있었다. 최종 빌드는 기존 기본 D3D12에서 검사했고 OpenGL을 지원/통과로 표시하지 않는다.
- BGM, 본격적인 충돌·점프 효과음, 효과음 청감 조정, 정식 캐릭터 운반 자세 아트는 후속 작업이다.
- 사용자 설정은 기존 `%APPDATA%/Godot/app_userdata/HellDelivery/settings.cfg`를 공유한다. 자체 테스트는 설정을 메모리에서만 바꾸며 저장하지 않는다.

## 재현/재빌드

저장소 루트 PowerShell에서:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Run-Godot.ps1 -Mode Export
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Run-Godot.ps1 -Mode BuildTest
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Run-Godot.ps1 -Mode BuildRouteVisual
```

- 스크립트는 프로젝트 안의 Godot 실행 파일과 `build-tools/templates/windows_debug_x86_64.exe`를 사용한다. 기본 템플릿 사용자 폴더에 설치하지 않고 preset의 custom template 경로로 사용했다.
- 템플릿 출처: [Godot 공식 4.7.1 릴리스](https://github.com/godotengine/godot-builds/releases/tag/4.7.1-stable). TPZ의 `version.txt`=`4.7.1.stable` 확인.
- 공식 템플릿의 외부 `--script`/`--scene` 경로 덮어쓰기 제한 때문에 외부 harness 실행은 검증으로 인정하지 않았다. [Godot CLI 옵션 설명](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)의 extended 옵션 조건을 확인하고, 최종 빌드에는 자체 테스트 진입점을 넣었다.
- 배포 전에 `BuildTest.report.txt`의 `EXIT 0 checks=77 failures=0`와 로그 오류·경고를 확인한다. 생성된 EXE/PCK 해시를 기록하고 README/라이선스/검증 기록을 같이 압축한다.
- 보존된 사용자 미커밋 파일: ARCHITECTURE/CHANGELOG/PLAYER_EXPERIENCE/TASKS, GameSettings, LocalCoopTest, Player, SettingsPanel.gd/.tscn, CharacterDefinition, CharacterVisual. 삭제·reset·stash·commit·push 없음.

## 다음 세션

1. `PLAYTEST_README.md`의 체크리스트를 기준으로 사용자 피드백을 받는다.
2. 재현되는 운반·시야·복구 문제를 이 빌드의 후속 수정으로 해결한다.
3. 아트/사운드와 다른 PC 호환성 검사를 진행한다. 온라인 협동과 차량은 새 목표에서 다룬다.

## 전달 아카이브 최종 확인 (압축 완료 후 기록)

- `builds/HellDelivery-2026-09-10-villa-01.zip`: 36,849,783 bytes (약 35.1 MiB).
- SHA-256: `B17595EE7D006309D3840F3D6C5C917B1075D03D08B139A8B4D4C453FE975EDD`.
- 별도 `builds/verify-unpacked-villa-01/`에 압축 해제한 19개 파일을 원본과 SHA-256 대조: 누락·불일치 0개.
- 압축 해제 폴더를 작업 디렉터리로 하여 EXE 기본 메뉴 headless smoke 실행: `EXIT=0`, 오류·경고 없음(`validation/UnpackedSmoke.log`). 이 검사는 소스나 에디터를 사용하지 않았다.
- `git diff --check` 통과. Git의 LF→CRLF 변환 안내만 존재. 작업 브랜치와 미커밋 상태를 유지하며 commit/push하지 않았다.
- ZIP 자체 해시는 자기 자신에 포함할 수 없으므로 이 항목은 저장소 문서에 압축 이후 기록했다. ZIP 안의 VALIDATION.md에는 압축 직전까지의 구현·게임 검증 내용이 포함된다.
