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

## Kenney — City Kit Commercial (2.1)

- 로컬 원본: hell-delivery/assets/environment/kenney_city-kit-commercial_2.1/License.txt
- 제작/배포: Kenney (www.kenney.nl). 동봉 라이선스: Creative Commons Zero, CC0.
- villa-02 사용: Models/GLB format/building-a.glb, building-b.glb, building-c.glb 및 참조 텍스처.
- VillaPresentation의 배경 건물. 원본 자산 수정 없음. 배포 폴더에 원본 License.txt 동봉.
## villa-03 추가 사용

- City Kit Commercial 2.1: detail-awning.glb, detail-overhang-wide.glb (골목 차양·현관 처마).
- Factory Kit 3.0: box-small.glb (실제 배송 택배 및 적재 소품), cone.glb (트럭 소품).
- Factory 원본 라이선스: hell-delivery/assets/environment/kenney_factory-kit_3.0/License.txt, 제작 Kenney, CC0.
- 배포 licenses/Kenney-Factory-Kit.txt에 라이선스 원문 동봉. 원본 모델 수정 없이 인스턴스 변환만 적용.
- Modular Cave Kit는 이번 빌라에는 미사용.

## villa-06 추가 사용

City Kit Commercial 2.1의 building-d.glb, building-e.glb를 배경에 추가했다. 기존 building-a/b/c와 함께 인스턴스 크기·위치만 조정했다. 기존 CC0 라이선스 동봉. VillaSurface 셰이더와 지형 받침은 프로젝트 코드로 제작했다.

## Kenney Car Kit (3.1) — villa-09

- 공식 출처: https://kenney.nl/assets/car-kit
- 원본 ZIP: https://kenney.nl/media/pages/assets/car-kit/1a312ec241-1775131960/kenney_car-kit.zip
- 라이선스: CC0 (동봉 License.txt 확인), 제작 Kenney.
- 로컬: hell-delivery/assets/environment/kenney_car-kit/Models/delivery.glb, sedan.glb, Textures.
- 사용: 배송 트럭과 주차 승용차. 원본 모델 수정 없이 인스턴스 변환·별도 로고·단순 충돌 적용.
- 배포 licenses/Kenney-Car-Kit.txt에 원문 동봉. 원본 ZIP은 build-tools/kenney_car-kit.zip 보관.