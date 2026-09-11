extends Node

# T079: 설정값을 한곳에서 관리하는 Autoload. 화면/입력/오디오 설정을 user://settings.cfg에
# 저장·복원하고, 값이 바뀔 때마다 settings_changed를 발생시켜 Player/UI가 각자 반영하게 한다.
# Player.gd/UI가 설정값을 직접 저장하지 않고 이 Autoload를 유일한 출처로 참조한다.

signal settings_changed
var last_server_ip := "127.0.0.1"
var network_port := 27926

enum WindowMode { WINDOWED, FULLSCREEN }

const SETTINGS_PATH := "user://settings.cfg"
const RESOLUTIONS: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]

# 기본값은 기존에 사용자 승인된 Baseline을 그대로 사용한다(TECH_DEBT.md TD-014/TD-015,
# Player.gd의 기존 @export 기본값과 동일 — 임의로 새 값을 만들지 않음).
const _DEFAULT_WINDOW_MODE: WindowMode = WindowMode.WINDOWED
const _DEFAULT_WINDOW_RESOLUTION: Vector2i = Vector2i(1280, 720)
const _DEFAULT_MOUSE_SENSITIVITY: float = 0.003
const _DEFAULT_GAMEPAD_LOOK_SENSITIVITY: float = 2.5
const _DEFAULT_INVERT_GAMEPAD_Y: bool = false
const _DEFAULT_MASTER_VOLUME: float = 1.0
const _DEFAULT_ONBOARDING_SEEN: bool = false
const _DEFAULT_CHARACTER_ID: String = "" # T085D: 실제 기본값은 CharacterCatalog.get_default_id()에서 가져온다(캐릭터 목록을 여기서 중복 관리하지 않기 위함).
const _DEFAULT_FOV: float = 75.0 # T085D: Player.tscn의 기존 Camera3D가 fov를 따로 지정하지 않아 Godot 4 Camera3D 기본값(75.0)을 그대로 썼다 — 임의로 새 값을 만들지 않음.

const _MOUSE_SENSITIVITY_RANGE := Vector2(0.0005, 0.02)
const _GAMEPAD_SENSITIVITY_RANGE := Vector2(0.5, 10.0)
const _FOV_RANGE := Vector2(70.0, 110.0)

var window_mode: WindowMode = _DEFAULT_WINDOW_MODE
var shadows_enabled: bool = true
var window_resolution: Vector2i = _DEFAULT_WINDOW_RESOLUTION
var mouse_sensitivity: float = _DEFAULT_MOUSE_SENSITIVITY
var gamepad_look_sensitivity: float = _DEFAULT_GAMEPAD_LOOK_SENSITIVITY
var invert_gamepad_y: bool = _DEFAULT_INVERT_GAMEPAD_Y
var master_volume: float = _DEFAULT_MASTER_VOLUME # 0.0~1.0
var onboarding_seen: bool = _DEFAULT_ONBOARDING_SEEN # T080: 첫 실행 안내 Overlay를 이미 봤는지
var selected_character_id: String = _DEFAULT_CHARACTER_ID # T085D: 싱글플레이 확정 캐릭터 ID. 로컬 협동의 Player별 선택은 CharacterSelectionManager가 별도로 소유한다(여기 저장하지 않음).
var fov: float = _DEFAULT_FOV # T085D: 실제 Gameplay Camera3D.fov에만 적용(Preview Camera·UI SubViewport Camera는 제외).


func _ready() -> void:
	load_settings()
	selected_character_id = CharacterCatalog.resolve_id_or_default(selected_character_id)
	_apply_display_settings()
	_apply_audio_settings()


func _freight_test_path(path: String) -> String:
	if path != SETTINGS_PATH or "freight-test" not in OS.get_cmdline_user_args(): return path
	var folder := "user://"
	var seat := "0"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("network-output="): folder = arg.trim_prefix("network-output=")
		if arg.begins_with("freight-seat="): seat = arg.trim_prefix("freight-seat=")
	return folder.path_join("settings-" + seat + ".cfg")

func load_settings(path: String = SETTINGS_PATH) -> void:
	path = _freight_test_path(path)
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return # 파일이 없거나 읽을 수 없으면 위에서 선언한 기본값을 그대로 사용한다.
	window_mode = _safe_enum(config, "display", "window_mode", _DEFAULT_WINDOW_MODE, [WindowMode.WINDOWED, WindowMode.FULLSCREEN])
	window_resolution = _safe_resolution(config, "display", "window_resolution", _DEFAULT_WINDOW_RESOLUTION)
	mouse_sensitivity = _safe_float(config, "input", "mouse_sensitivity", _DEFAULT_MOUSE_SENSITIVITY, _MOUSE_SENSITIVITY_RANGE)
	gamepad_look_sensitivity = _safe_float(config, "input", "gamepad_look_sensitivity", _DEFAULT_GAMEPAD_LOOK_SENSITIVITY, _GAMEPAD_SENSITIVITY_RANGE)
	invert_gamepad_y = _safe_bool(config, "input", "invert_gamepad_y", _DEFAULT_INVERT_GAMEPAD_Y)
	master_volume = _safe_float(config, "audio", "master_volume", _DEFAULT_MASTER_VOLUME, Vector2(0.0, 1.0))
	onboarding_seen = _safe_bool(config, "onboarding", "seen", _DEFAULT_ONBOARDING_SEEN)
	var loaded_character_id: String = _safe_string(config, "character", "selected_id", _DEFAULT_CHARACTER_ID)
	selected_character_id = CharacterCatalog.resolve_id_or_default(loaded_character_id)
	fov = _safe_fov(config, "display", "fov", _DEFAULT_FOV, _FOV_RANGE)
	shadows_enabled = _safe_bool(config, "display", "shadows_enabled", true)
	last_server_ip = _safe_string(config, "network", "last_server_ip", "127.0.0.1")
	if not last_server_ip.is_valid_ip_address(): last_server_ip = "127.0.0.1"
	var loaded_port: Variant = config.get_value("network", "port", 27926)
	network_port = loaded_port if loaded_port is int and loaded_port >= 1024 and loaded_port <= 65535 else 27926


func save_settings(path: String = SETTINGS_PATH) -> void:
	path = _freight_test_path(path)
	var config := ConfigFile.new()
	config.set_value("display", "window_mode", window_mode)
	config.set_value("display", "window_resolution", window_resolution)
	config.set_value("input", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("input", "gamepad_look_sensitivity", gamepad_look_sensitivity)
	config.set_value("input", "invert_gamepad_y", invert_gamepad_y)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("onboarding", "seen", onboarding_seen)
	config.set_value("character", "selected_id", selected_character_id)
	config.set_value("display", "fov", fov)
	config.set_value("display", "shadows_enabled", shadows_enabled)
	config.set_value("network", "last_server_ip", last_server_ip)
	config.set_value("network", "port", network_port)
	config.save(path)

func remember_server(ip: String, port: int) -> void:
	if not ip.is_valid_ip_address() or port < 1024 or port > 65535: return
	last_server_ip = ip
	network_port = port
	save_settings()


func set_window_mode(mode: WindowMode) -> void:
	window_mode = mode
	_apply_display_settings()
	save_settings()
	settings_changed.emit()


func set_window_resolution(resolution: Vector2i) -> void:
	window_resolution = resolution
	_apply_display_settings()
	save_settings()
	settings_changed.emit()


func set_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = value
	save_settings()
	settings_changed.emit()


func set_gamepad_look_sensitivity(value: float) -> void:
	gamepad_look_sensitivity = value
	save_settings()
	settings_changed.emit()


func set_invert_gamepad_y(value: bool) -> void:
	invert_gamepad_y = value
	save_settings()
	settings_changed.emit()


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_audio_settings()
	save_settings()
	settings_changed.emit()


func set_onboarding_seen(value: bool) -> void:
	onboarding_seen = value
	save_settings()
	settings_changed.emit()


func set_selected_character_id(value: String) -> void:
	selected_character_id = CharacterCatalog.resolve_id_or_default(value)
	save_settings()
	settings_changed.emit()


func set_fov(value: float) -> void:
	fov = clampf(value, _FOV_RANGE.x, _FOV_RANGE.y)
	save_settings()
	settings_changed.emit()


func set_shadows_enabled(value: bool) -> void:
	shadows_enabled = value
	save_settings()
	settings_changed.emit()


func reset_to_defaults() -> void:
	# T080: onboarding_seen은 의도적으로 여기서 건드리지 않는다 — "기본값 복원"은 화면/입력/오디오
	# 설정만 되돌리는 기능이고, 첫 실행 안내를 다시 보게 만드는 것과는 무관하다(사용자 지시).
	window_mode = _DEFAULT_WINDOW_MODE
	window_resolution = _DEFAULT_WINDOW_RESOLUTION
	mouse_sensitivity = _DEFAULT_MOUSE_SENSITIVITY
	gamepad_look_sensitivity = _DEFAULT_GAMEPAD_LOOK_SENSITIVITY
	invert_gamepad_y = _DEFAULT_INVERT_GAMEPAD_Y
	master_volume = _DEFAULT_MASTER_VOLUME
	fov = _DEFAULT_FOV
	shadows_enabled = true
	_apply_display_settings()
	_apply_audio_settings()
	save_settings()
	settings_changed.emit()


func _apply_display_settings() -> void:
	if window_mode == WindowMode.FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(window_resolution)


func _apply_audio_settings() -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	if bus_index < 0:
		return
	AudioServer.set_bus_mute(bus_index, master_volume <= 0.0)
	if master_volume > 0.0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(master_volume))


func _safe_float(config: ConfigFile, section: String, key: String, default: float, valid_range: Vector2) -> float:
	var value = config.get_value(section, key, default)
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		return default
	value = float(value)
	if is_nan(value) or value < valid_range.x or value > valid_range.y:
		return default
	return value


func _safe_fov(config: ConfigFile, section: String, key: String, default: float, valid_range: Vector2) -> float:
	# T085D: 다른 _safe_float 값들과 달리 FOV는 범위를 벗어나면(사용자 지시) 기본값이 아니라
	# 가장 가까운 경계값으로 Clamp한다 — 숫자가 아니거나(타입 오류) NaN일 때만 기본값으로 되돌린다.
	var value = config.get_value(section, key, default)
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		return default
	value = float(value)
	if is_nan(value):
		return default
	return clampf(value, valid_range.x, valid_range.y)


func _safe_bool(config: ConfigFile, section: String, key: String, default: bool) -> bool:
	var value = config.get_value(section, key, default)
	if typeof(value) != TYPE_BOOL:
		return default
	return value


func _safe_string(config: ConfigFile, section: String, key: String, default: String) -> String:
	var value = config.get_value(section, key, default)
	if typeof(value) != TYPE_STRING:
		return default
	return value


func _safe_enum(config: ConfigFile, section: String, key: String, default: int, allowed: Array) -> int:
	var value = config.get_value(section, key, default)
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return default
	value = int(value)
	if not allowed.has(value):
		return default
	return value


func _safe_resolution(config: ConfigFile, section: String, key: String, default: Vector2i) -> Vector2i:
	var value = config.get_value(section, key, default)
	var resolved: Vector2i
	if typeof(value) == TYPE_VECTOR2I:
		resolved = value
	elif typeof(value) == TYPE_VECTOR2:
		resolved = Vector2i(value)
	else:
		return default
	if not RESOLUTIONS.has(resolved):
		return default
	return resolved
