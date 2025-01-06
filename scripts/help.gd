class_name Help

var notices: Array[StringName] = []

func reset():
	notices = []

func issue_notice(unit: BaseUnit, name: StringName) -> void:
	if notices.has(name):
		return

	match name:
		&"":
			notices.push_back(name)
			unit.show_speech_bubble("", 2.5)
