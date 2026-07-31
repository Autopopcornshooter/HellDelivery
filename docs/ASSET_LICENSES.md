# ASSET_LICENSES.md

이 문서는 저장소에 포함된 외부(제3자) 에셋의 출처와 라이선스를 기록한다. 프로젝트 자체 코드·Scene·문서는 포함하지 않는다.

---

## Kenney — Blocky Characters (2.0)

- 경로: `hell-delivery/assets/environment/kenney_blocky-characters_20/`
- 출처: [Kenney](https://www.kenney.nl) — `www.kenney.nl`
- 라이선스: CC0 1.0 (Creative Commons Zero — Public Domain)
- 사용 조건: 개인·교육·상업적 사용 무료. 크레딧 표시는 필수가 아니다(자발적).
- 사용 형식: `Models/GLB format/character-a.glb` ~ `character-r.glb` (18개, T085D에서 전부 등록)
- 사용처: `docs/TASKS.md` T085D — 캐릭터 선택·Player 외형 적용
- 비고: Skeleton3D 없이 파츠별 Node3D(`root/leg-left, leg-right, torso/arm-left, arm-right, head`)를 직접 애니메이션하는 구조. 캐릭터별 전용 Texture(`Models/GLB format/Textures/texture-a.png` 등) 포함. 원본 파일은 수정하지 않았다 — 스케일·회전 보정은 `scenes/character/CharacterVisual.tscn` Wrapper에서만 수행한다.
