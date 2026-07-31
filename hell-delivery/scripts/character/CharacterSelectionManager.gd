class_name CharacterSelectionManager
extends RefCounted

## T085D: 로컬 협동 캐릭터 선택의 예약 상태만 소유한다(표시·입력은 CharacterSelectPanel의 몫).
## Autoload가 아니다 — 선택 화면을 소유하는 Scene(LocalCoopTest 등)이 인스턴스를 만들고 들고 있는다.
## 미리보기(임시 선택)만으로는 예약되지 않으며, confirm()을 호출해야 비로소 다른 Player 목록에서
## 제외된다.

signal reservation_changed

var _num_players: int
var _temp_selection: Dictionary = {} # player_index(int) -> character_id(String), 예약 아님
var _confirmed_selection: Dictionary = {} # player_index(int) -> character_id(String), 예약됨

## Restart로 Scene이 통째로 다시 로드돼도(reload_current_scene) 직전 세션의 확정 캐릭터를
## 다시 적용할 수 있도록, 스크립트 자체에 귀속된 static 값에 남겨 둔다(Autoload 신설 없이 프로세스
## 생존 기간 동안만 유지 — 그 이상의 영속 저장은 이번 범위가 아니다).
static var _last_confirmed_session: Dictionary = {}


func _init(num_players: int = 2) -> void:
	_num_players = num_players


func get_num_players() -> int:
	return _num_players


## player_index를 제외한 다른 Player가 이미 확정한 캐릭터를 뺀 목록을 순서대로 반환한다.
func get_available_ids(player_index: int) -> Array[String]:
	var reserved_by_others: Array[String] = []
	for idx in _confirmed_selection:
		if idx != player_index:
			reserved_by_others.append(_confirmed_selection[idx])
	var result: Array[String] = []
	for def in CharacterCatalog.get_all():
		if not reserved_by_others.has(def.id):
			result.append(def.id)
	return result


func set_temp_selection(player_index: int, character_id: String) -> void:
	_temp_selection[player_index] = character_id


func get_temp_selection(player_index: int) -> String:
	return _temp_selection.get(player_index, "")


## 확정을 시도한다. 다른 Player가 이미 그 캐릭터를 확정했다면 실패(false)하며, 어떤 상태도 바뀌지
## 않는다 — 호출부(CharacterSelectPanel)가 실패 시 다음 사용 가능 캐릭터로 자동 이동해야 한다.
func confirm(player_index: int, character_id: String) -> bool:
	for idx in _confirmed_selection:
		if idx != player_index and _confirmed_selection[idx] == character_id:
			return false
	_confirmed_selection[player_index] = character_id
	reservation_changed.emit()
	return true


func unconfirm(player_index: int) -> void:
	if not _confirmed_selection.has(player_index):
		return
	_confirmed_selection.erase(player_index)
	reservation_changed.emit()


func is_confirmed(player_index: int) -> bool:
	return _confirmed_selection.has(player_index)


func get_confirmed(player_index: int) -> String:
	return _confirmed_selection.get(player_index, "")


func all_confirmed() -> bool:
	for i in _num_players:
		if not is_confirmed(i):
			return false
	return true


## 플레이어가 선택 화면을 나갈 때(퇴장) 호출 — 임시 선택과 확정을 모두 해제해 다른 Player 목록에
## 다시 나타나게 한다.
func release_player(player_index: int) -> void:
	_temp_selection.erase(player_index)
	unconfirm(player_index)


func remember_session() -> void:
	CharacterSelectionManager._last_confirmed_session = _confirmed_selection.duplicate()


static func get_last_session_character(player_index: int, fallback_id: String) -> String:
	var remembered = CharacterSelectionManager._last_confirmed_session.get(player_index, "")
	if remembered != "" and CharacterCatalog.get_by_id(remembered) != null:
		return remembered
	return fallback_id
