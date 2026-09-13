class_name LevelAudio
extends Node

# 짧은 절차적 PCM 효과음. 외부 음원 없이 재현 가능하며 기존 Master 볼륨을 따른다.
var _cues: Dictionary = {}
var _voices: Array[AudioStreamPlayer] = []
var _voice_index: int = 0
var _last_played: Dictionary = {}
var player_pan: float = 0.0
var _stereo_cues: Dictionary = {}
var _previous_held: GrabbableBody
var _step_time: float = 0.0
var _was_grounded: bool = false
var _last_vertical_velocity: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cues["grab"] = _tone([330.0, 440.0], 0.12, 0.13)
	_cues["release"] = _tone([300.0, 190.0], 0.10, 0.10)
	_cues["delivery"] = _tone([523.25, 659.25, 783.99, 1046.5], 0.65, 0.16)
	_cues["recover"] = _tone([392.0, 523.25], 0.25, 0.12)
	_cues["step"] = _impact(0.065, 0.07, 110.0)
	_cues["jump"] = _tone([220.0, 330.0], 0.10, 0.08)
	_cues["land"] = _impact(0.16, 0.16, 75.0)
	_cues["impact"] = _impact(0.12, 0.13, 155.0)
	_cues["scan"] = _tone([1400.0, 1800.0], 0.09, 0.14) # 택배 적재 확인 "삑" (바코드 스캐너 연상)
	_cues["warning"] = _tone([1046.5, 1046.5], 0.22, 0.15) # 제한 시간 얼마 안 남았을 때 1회
	_cues["mistake"] = _tone([392.0, 293.66], 0.2, 0.16) # 오배송 등 실수 피드백
	_cues["damage"] = _impact(0.2, 0.2, 90.0) # 택배/차량 파손 공용
	_cues["failure"] = _tone([392.0, 329.63, 261.63], 0.45, 0.18) # 택배가 완전히 파손/분실되어 배송 불가로 확정되는 순간 1회
	_cues["request"] = _tone([880.0, 1108.73], 0.16, 0.15) # 동료의 공동 운반 요청 수신 알림
	for i in 4:
		var voice := AudioStreamPlayer.new()
		voice.bus = "SFX"
		add_child(voice)
		_voices.append(voice)


func play_cue(cue: String, intensity: float = 1.0) -> void:
	if not _cues.has(cue):
		return
	var now := Time.get_ticks_msec()
	if cue == "impact" and now - int(_last_played.get(cue, -1000)) < 120:
		return
	_last_played[cue] = now
	var voice := _voices[_voice_index]
	_voice_index = (_voice_index + 1) % _voices.size()
	voice.stream = _player_stream(cue)
	voice.volume_db = linear_to_db(clampf(intensity, 0.2, 1.0))
	# 발소리가 매번 완전히 같은 음높이로 반복되면 단조롭게 들린다(품질 점검 "나중에" 항목) —
	# 발소리에만 살짝 랜덤 피치를 줘 반복감을 줄인다. 다른 큐(배송/경고 등)는 명확한 신호여야
	# 하므로 그대로 둔다.
	voice.pitch_scale = randf_range(0.92, 1.08) if cue == "step" else 1.0
	voice.play()


func _player_stream(cue: String) -> AudioStreamWAV:
	if is_zero_approx(player_pan) or cue not in ["step", "jump", "land", "grab", "release"]:
		return _cues[cue]
	var key := cue + str(player_pan)
	if not _stereo_cues.has(key):
		var source: AudioStreamWAV = _cues[cue]
		var data := PackedByteArray()
		data.resize(source.data.size() * 2)
		var angle := (clampf(player_pan, -1.0, 1.0) + 1.0) * PI / 4.0
		for i in source.data.size() / 2:
			var sample := source.data.decode_s16(i * 2)
			data.encode_s16(i * 4, int(sample * cos(angle)))
			data.encode_s16(i * 4 + 2, int(sample * sin(angle)))
		var stereo := AudioStreamWAV.new()
		stereo.format = source.format
		stereo.mix_rate = source.mix_rate
		stereo.stereo = true
		stereo.data = data
		_stereo_cues[key] = stereo
	return _stereo_cues[key]


func _impact(duration: float, amplitude: float, frequency: float) -> AudioStreamWAV:
	var random := RandomNumberGenerator.new()
	random.seed = 8127
	var rate := 22050
	var data := PackedByteArray()
	var count := int(duration * rate)
	data.resize(count * 2)
	var noise := 0.0
	for i in count:
		var time := float(i) / rate
		var envelope := minf(time / 0.003, 1.0) * exp(-time * 35.0)
		noise = lerpf(noise, random.randf_range(-1, 1), 0.28)
		var sample := (noise * 0.65 + sin(TAU * frequency * time) * 0.35) * envelope * amplitude
		data.encode_s16(i * 2, int(sample * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	return stream


func _tone(notes: Array, duration: float, amplitude: float) -> AudioStreamWAV:
	var rate := 22050
	var samples := int(duration * rate)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var phase := 0.0
	for i in samples:
		var progress := float(i) / samples
		var note_index := mini(int(progress * notes.size()), notes.size() - 1)
		var note_progress := fmod(progress * notes.size(), 1.0)
		var envelope := minf(note_progress * 15.0, 1.0) * (1.0 - note_progress)
		phase += TAU * float(notes[note_index]) / rate
		var sample := int(sin(phase) * amplitude * envelope * 32767.0)
		data.encode_s16(i * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	return stream


func update_player(player: Player, delta: float) -> void:
	update_motion(player.held_grabbable, player.is_on_floor(), player.velocity, delta)

func update_motion(held: GrabbableBody, grounded: bool, motion: Vector3, delta: float) -> void:
	if held != _previous_held:
		play_cue("grab" if held != null else "release")
		_previous_held = held
	if _was_grounded and not grounded and motion.y > 1.0:
		play_cue("jump")
	elif not _was_grounded and grounded and _last_vertical_velocity < -2.0:
		play_cue("land", absf(_last_vertical_velocity) / 7.0)
	_was_grounded = grounded
	_last_vertical_velocity = motion.y
	var speed := Vector2(motion.x, motion.z).length()
	if grounded and speed > 0.5:
		_step_time += delta
		if _step_time >= clampf(1.8 / speed, 0.26, 0.6):
			_step_time = 0.0
			play_cue("step")
	else:
		_step_time = 0.0
