extends Node

# T082: 효과음 재생을 한곳에서 관리하는 최소 Autoload. GameSettings와 마찬가지로 Player/UI가
# 직접(Scene 트리 경로 없이) 참조하는 유일한 오디오 출처다. 모든 재생은 엔진 기본 "Master" Bus를
# 그대로 사용하므로, GameSettings._apply_audio_settings()가 이미 관리하는 Master Volume이
# 추가 배선 없이 그대로 적용된다.
#
# 효과음 8개는 전부 외부 음원 없이 순수 사인파/노이즈 절차적 합성으로 만들었다(라이선스 문제 없음).
# 생성에 사용한 1회성 도구 스크립트(_tmp_generate_sfx.gd)는 TD-008 관례대로 실행 후 삭제했고,
# 재현 가능하도록 정확한 합성 방식을 아래에 그대로 기록해 둔다(모두 22050Hz, 16bit mono WAV,
# Attack 최대 5ms 후 끝까지 선형 감쇠하는 퍼커시브 Envelope로 클릭 노이즈 방지):
#   ui_select.wav            사인 스윕 700→1000Hz, 70ms, 음량 0.25
#   ui_back.wav               사인 스윕 600→400Hz, 70ms, 음량 0.22
#   ui_pause_open.wav         사인 스윕 500→750Hz, 140ms, 음량 0.22
#   grab_success.wav          사인 스윕 350→550Hz, 55ms, 음량 0.30
#   grab_release.wav          사인 스윕 500→320Hz, 90ms, 음량 0.22
#   grab_forced_release.wav   220Hz 사인 60% + 화이트 노이즈 40%(고정 시드 12345), 110ms, 음량 0.28
#   delivery_success.wav      660Hz(90ms) → 880Hz(110ms) 연속 2음
#   delivery_complete.wav     523Hz(100ms) → 659Hz(100ms) → 784Hz(200ms) 연속 3음(도-미-솔)

enum Sfx {
	UI_SELECT,
	UI_BACK,
	UI_PAUSE_OPEN,
	GRAB_SUCCESS,
	GRAB_RELEASE,
	GRAB_FORCED_RELEASE,
	DELIVERY_SUCCESS,
	DELIVERY_COMPLETE,
}

const _STREAM_DIR := "res://assets/audio/generated/"
const _STREAM_FILENAMES := {
	Sfx.UI_SELECT: "ui_select.wav",
	Sfx.UI_BACK: "ui_back.wav",
	Sfx.UI_PAUSE_OPEN: "ui_pause_open.wav",
	Sfx.GRAB_SUCCESS: "grab_success.wav",
	Sfx.GRAB_RELEASE: "grab_release.wav",
	Sfx.GRAB_FORCED_RELEASE: "grab_forced_release.wav",
	Sfx.DELIVERY_SUCCESS: "delivery_success.wav",
	Sfx.DELIVERY_COMPLETE: "delivery_complete.wav",
}

# 풀 크기를 고정해 AudioStreamPlayer를 요청마다 새로 만들지 않는다 — 풀이 전부 사용 중이면
# 그냥 조용히 재생을 건너뛴다(동일 효과음이 과도하게 겹치는 것을 자연히 제한).
const _UI_POOL_SIZE: int = 4
const _SFX2D_POOL_SIZE: int = 4
const _SFX3D_POOL_SIZE: int = 8

var _streams: Dictionary = {} # Sfx -> AudioStream, 존재하는 파일만 미리 로드
var _ui_pool: Array = []
var _sfx2d_pool: Array = []
var _sfx3d_pool: Array = []


func _ready() -> void:
	# Pause 중에도 UI 효과음(PauseMenu 버튼 클릭음 등)은 재생돼야 한다 — 월드(3D)/배송(2D) 효과음은
	# 그 이벤트를 발생시키는 코드 자체가 Pausable 노드에서만 호출되므로 Pause 중에는 자연히 호출되지 않는다.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_streams()
	_build_pool(_ui_pool, _UI_POOL_SIZE, false)
	_build_pool(_sfx2d_pool, _SFX2D_POOL_SIZE, false)
	_build_pool(_sfx3d_pool, _SFX3D_POOL_SIZE, true)


func _load_streams() -> void:
	for sfx in _STREAM_FILENAMES.keys():
		var path: String = _STREAM_DIR + String(_STREAM_FILENAMES[sfx])
		if ResourceLoader.exists(path):
			_streams[sfx] = load(path)
		# 없는 Stream은 그냥 등록하지 않는다 — play_*()가 조용히 무시한다(요구사항).


func _build_pool(pool: Array, size: int, is_3d: bool) -> void:
	for i in size:
		var player: Node
		if is_3d:
			var p3d := AudioStreamPlayer3D.new()
			p3d.bus = "Master"
			player = p3d
		else:
			var p := AudioStreamPlayer.new()
			p.bus = "Master"
			p.process_mode = Node.PROCESS_MODE_ALWAYS
			player = p
		add_child(player)
		pool.append(player)


func play_ui(sfx: int) -> void:
	_play_from_pool(sfx, _ui_pool)


func play_2d(sfx: int) -> void:
	_play_from_pool(sfx, _sfx2d_pool)


func play_3d(sfx: int, world_position: Vector3) -> void:
	if not _streams.has(sfx):
		return
	var player: AudioStreamPlayer3D = _find_free_player(_sfx3d_pool)
	if player == null:
		return # 풀이 전부 사용 중 — 조용히 무시(과도한 중첩 방지).
	player.global_position = world_position
	player.stream = _streams[sfx]
	player.play()


func _play_from_pool(sfx: int, pool: Array) -> void:
	if not _streams.has(sfx):
		return
	var player: AudioStreamPlayer = _find_free_player(pool)
	if player == null:
		return
	player.stream = _streams[sfx]
	player.play()


func _find_free_player(pool: Array) -> Node:
	for player in pool:
		if not player.playing:
			return player
	return null
