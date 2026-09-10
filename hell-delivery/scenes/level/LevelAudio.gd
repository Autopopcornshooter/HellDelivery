class_name LevelAudio
extends Node

# 짧은 절차적 PCM 효과음. 외부 음원 없이 재현 가능하며 기존 Master 볼륨을 따른다.
var _cues: Dictionary = {}
var _voices: Array[AudioStreamPlayer] = []
var _voice_index: int = 0
var _last_played: Dictionary = {}


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
	for i in 4:
		var voice := AudioStreamPlayer.new()
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
	voice.stream = _cues[cue]
	voice.volume_db = linear_to_db(clampf(intensity, 0.2, 1.0))
	voice.play()


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
