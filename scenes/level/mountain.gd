extends SledLevel

func _init() -> void:
	super._init(&"mountain", Global.MAX_MAP_HEIGHT)
	Global.audio.play_music("mountain")
	
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	super._process(delta)
