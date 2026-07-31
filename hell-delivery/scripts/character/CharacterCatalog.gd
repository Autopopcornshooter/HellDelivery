class_name CharacterCatalog
extends RefCounted

## T085D: 18개 캐릭터 정의를 단일 출처로 제공한다. Autoload가 아니다 — 상태를 갖지 않는 정적
## 목록이라 매번 `load()`로 조회해도 Godot 리소스 캐시 덕분에 비용이 없고, 여러 UI가 각자 다른
## 목록을 복제해 들고 있는 문제를 막는다. 파일 시스템을 순회하지 않고, ID 순서가 파일 목록 순서에
## 의존하지 않도록 아래 목록을 명시적으로 고정한다.

const _DEFINITION_PATHS: Array[String] = [
	"res://resources/characters/character_a.tres",
	"res://resources/characters/character_b.tres",
	"res://resources/characters/character_c.tres",
	"res://resources/characters/character_d.tres",
	"res://resources/characters/character_e.tres",
	"res://resources/characters/character_f.tres",
	"res://resources/characters/character_g.tres",
	"res://resources/characters/character_h.tres",
	"res://resources/characters/character_i.tres",
	"res://resources/characters/character_j.tres",
	"res://resources/characters/character_k.tres",
	"res://resources/characters/character_l.tres",
	"res://resources/characters/character_m.tres",
	"res://resources/characters/character_n.tres",
	"res://resources/characters/character_o.tres",
	"res://resources/characters/character_p.tres",
	"res://resources/characters/character_q.tres",
	"res://resources/characters/character_r.tres",
]


static func get_all() -> Array[CharacterDefinition]:
	var result: Array[CharacterDefinition] = []
	for path in _DEFINITION_PATHS:
		var def: CharacterDefinition = load(path)
		if def != null:
			result.append(def)
	return result


static func get_by_id(id: String) -> CharacterDefinition:
	for def in get_all():
		if def.id == id:
			return def
	return null


static func get_default_id() -> String:
	var all := get_all()
	return all[0].id if not all.is_empty() else ""


## GameSettings 등에 저장된 ID가 더 이상 Catalog에 없을 때 안전하게 되돌릴 기본 ID를 반환한다.
static func resolve_id_or_default(id: String) -> String:
	if get_by_id(id) != null:
		return id
	return get_default_id()
