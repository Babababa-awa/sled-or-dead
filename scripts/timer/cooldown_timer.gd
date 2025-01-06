class_name CooldownTimer

var cooldown_delta: float
var current_delta: float = 0.0
var is_active: bool = false
var is_complete: bool = false
var auto_complete: bool = false
var steps: Array[Dictionary] = []

func _init(cooldown_delta_: float, auto_complete_: bool = false) -> void:
	cooldown_delta = cooldown_delta_
	auto_complete = auto_complete_

func reset() -> void:
	reset_steps()

	current_delta = 0.0
	is_active = false
	is_complete = false
	
func reset_steps() -> void:
	for step in steps:
		step.is_active = false
		step.is_complete = false

func add_step(alias: StringName, delta: float) -> void:
	steps.push_back({
		"alias": alias,
		"delta": delta,
		"is_active": false,
		"is_complete": false,
	})

func process(delta: float) -> void:
	if not is_active:
		if is_complete:
			reset_steps()
		return

	current_delta += delta

	for step in steps:
		if step.is_complete:
			continue
		elif step.is_active:
			step.is_active = false
			step.is_complete = true
		elif current_delta >= step.delta:
			step.is_active = true

	if current_delta > cooldown_delta:
		current_delta = cooldown_delta
		is_active = false
		is_complete = true
		if auto_complete:
			complete()

func is_before_step(alias: StringName) -> bool:
	if not is_active and not is_complete:
		return false

	for step in steps:
		if step.alias == alias:
			return not step.is_active and not step.is_complete

	return false

func is_on_step(alias: StringName) -> bool:
	if not is_active and not is_complete:
		return false

	for step in steps:
		if step.alias == alias:
			return step.is_active

	return false

func is_after_step(alias: StringName) -> bool:
	if not is_active and not is_complete:
		return false

	for step in steps:
		if step.alias == alias:
			return step.is_complete

	return false

func start() -> bool:
	if is_active or is_complete:
		return false

	reset()
	is_active = true

	return true

func complete() -> void:
	for step in steps:
		step.is_active = false
		step.is_complete = false
		
	is_active = false
	is_complete = false
