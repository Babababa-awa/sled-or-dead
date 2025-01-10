extends BaseUI

func _init():
	super._init(&"select")


func set_player(player_type: Global.PlayerType) -> void:
	set_none()
	
	match player_type:
		Global.PlayerType.JELLY:
			%ControlJelly.visible = true
		Global.PlayerType.REMI:
			%ControlRemi.visible = true
		Global.PlayerType.PIPPA:
			%ControlPippa.visible = true
	
func set_none() -> void:
	%ControlJelly.visible = false
	%ControlRemi.visible = false
	%ControlPippa.visible = false
	%ControlSledHammer.visible = false
	%ControlSnowtorcycle.visible = false
	
func set_vehicle(vehicle_type: Global.VehicleType) -> void:
	set_none()
	
	match vehicle_type:
		Global.VehicleType.SLED_HAMMER:
			%ControlSledHammer.visible = true
		Global.VehicleType.SNOWTORCYCLE:
			%ControlSnowtorcycle.visible = true
