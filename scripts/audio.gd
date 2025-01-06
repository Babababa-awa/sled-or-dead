class_name Audio

var sfx = {}
var music = {}
var last = {}

func reset() -> void:
	reset_state()
	reset_audio()
	
func reset_state() -> void:
	stop_music()
	last = {}
	
func reset_audio() -> void:
	reset_sfx()
	reset_music()
	
func reset_sfx() -> void:
	for name in sfx:
		Global.game.remove_child(sfx[name])
	sfx = {}
	
func reset_music() -> void:
	for name in music:
		Global.game.remove_child(music[name])
	music = {}

func play_music(name: String):	
	if not music.has(name):
		load_music(name)
	
	stop_music(name)

	if music[name].playing:
		return
	
	if not last.has(name):
		last[name] = 0.0
	
	music[name].play(last[name])

func stop_music(name: String = ""):
	for existing_name in music:
		if existing_name != name and music[existing_name].playing:
			music[existing_name].stop()
	
func load_music(name: String):
	if music.has(name):
		return
		
	var audio_player = AudioStreamPlayer.new()
	audio_player.bus = &"Music"
	
	if ResourceLoader.exists("res://assets/audio/music/" + name + ".ogg"):
		audio_player.stream = load("res://assets/audio/music/" + name + ".ogg")
	else:
		audio_player.stream = load("res://assets/audio/music/" + name + ".mp3")
	
	Global.game.add_child(audio_player)
	
	music[name] = audio_player

func play_sfx(name: String, count: int = -1, rand: bool = false):
	if count == 0:
		return
		
	if count != -1:
		if rand:
			var index: int
			
			while true:
				index = randi() % count + 1
				if not last.has(name) or last[name] != index:
					break
			
			last[name] = index	
			name += "_" + str(last[name])
		else:
			if not last.has(name) or last[name] == count:
				last[name] = 1
				name += "_1"
			else:
				last[name] += 1
				name += "_" + str(last[name])
				
	if not sfx.has(name):
		load_sfx(name)
		
	sfx[name].play()
	
func load_sfx(name: String):
	if sfx.has(name):
		return
		
	var audio_player = AudioStreamPlayer.new()
	audio_player.bus = &"SFX"
	if ResourceLoader.exists("res://assets/audio/sfx/" + name + ".ogg"):
		audio_player.stream = load("res://assets/audio/sfx/" + name + ".ogg")
	else:
		audio_player.stream = load("res://assets/audio/sfx/" + name + ".wav")
	
	Global.game.add_child(audio_player)
	
	sfx[name] = audio_player
