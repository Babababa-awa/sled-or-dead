extends Node

const MENU_LEVEL = &"start"
const START_LEVEL = &"mountain"

const TILE_SIZE = 32

const MIN_MAP_UNLOAD_HEIGHT = 32
const MIN_MAP_LOAD_HEIGHT = 128
const MAX_MAP_HEIGHT = 4096 # 64 sections
#const MAX_MAP_HEIGHT = 128

const PHYSICS_COLLISION_LAYER_MASK: int = 1 << 0
const DAMAGE_COLLISION_LAYER_MASK: int = 1 << 1
const KILL_COLLISION_LAYER_MASK: int = 1 << 2

const PISTOL_LOCKON_DELTA: float = 0.01
const MACHINE_GUN_LOCKON_DELTA: float = 0.01
const SHOTGUN_LOCKON_DELTA: float = 0.01
const ROCKET_LAUNCHER_LOCKON_DELTA: float = 0.01

const NODE_LOADER_DEAD_ZONE: Vector2 = Vector2(0, 2048)

const MOUSE_CAPTURE: bool = true
const MOUSE_CURSOR_SIZE: int = 64

# Minimum amount of time for killables to wait after death before being hidden and disabled
const MIN_COLLISION_WAIT_DELTA = 0.1

var mouse_speed: float = 1.0
var joystick_speed_slow: float = 1.0
var joystick_speed_fast: float = 1.0

enum DataType {
	AREA,
	OBSTACLE,
}

enum ItemType {
	HEALTH,
	ARMOR,
}

enum UIType {
	MENU,
	GAME,
	LOADER,
}
enum GameMode {
	NORMAL,
	INFINITE,
}
enum GameDifficulty {
	EASY,
	NORMAL,
	HARD,
}

enum PlayerMode {
	NONE,
	NORMAL,
	DRIVER,
	PASSENGER,
}

enum PlayerMovement {
	IDLE,
}

enum VehicleType {
	NONE,
	SLED_HAMMER,
	SNOWTORCYCLE,
}

enum PlayerType {
	NONE,
	JELLY,
	PIPPA,
	REMI,
}

enum UnitType {
	ENEMY,
	OBJECT,
	PLAYER,
	PROJECTILE,
	VEHICLE,
}

enum ProjectileType {
	NONE,
	BULLET,
	EXPLOSION,
	ROCKET,
}

enum WeaponType {
	MACHINE_GUN,
	PISTOL,
	ROCKET_LAUNCHER,
	SHOTGUN,
}

enum BoostMode {
	CONSUME,
	DRAIN,
}

var game: BaseGame
var game_mode: Global.GameMode = Global.GameMode.NORMAL
var game_difficulty: Global.GameDifficulty = Global.GameDifficulty.NORMAL

var vehicle: VehicleUnit
var vehicle_type: Global.VehicleType = Global.VehicleType.SNOWTORCYCLE

var driver: PlayerUnit
var driver_player_type: Global.PlayerType = Global.PlayerType.REMI

var passenger: PlayerUnit
var passenger_player_type: Global.PlayerType = Global.PlayerType.JELLY

var active_player: Global.PlayerMode = Global.PlayerMode.PASSENGER

var cursor: WeaponCursor

var nodes: NodeLoader
var camera: Camera2D
var level: BaseLevel
var hud: Node
var audio: Audio
var help: Help

func apply_difficulty_modifier(value: int, inverse: bool = false, safe: bool = false) -> int:
	if inverse:
		if Global.game_difficulty == Global.GameDifficulty.EASY:
			value *= 2
		elif Global.game_difficulty == Global.GameDifficulty.HARD:
			value /= 2
	else:
		if Global.game_difficulty == Global.GameDifficulty.EASY:
			value /= 2
		elif Global.game_difficulty == Global.GameDifficulty.HARD:
			value *= 2

	if value == 0:
		value = 1
	
	if safe and value >= 100:
		value = 99
	
	return value
	

func is_friends(node1: Node2D, node2: Node2D) -> bool:
	return !is_enemies(node1, node2)
	
func is_enemies(node1: Node2D, node2: Node2D) -> bool:
	if node1 == node2:
		return false
		
	if node1.is_in_group(&"object") or node2.is_in_group(&"object"):
		return true
	
	if node1.is_in_group(&"player") or node1.is_in_group(&"vehicle"):
		if node2.is_in_group(&"enemy"):
			return true
	elif node1.is_in_group(&"enemy"):
		if node2.is_in_group(&"player") or node2.is_in_group(&"vehicle"):
			return true
			
	return false
	
func is_friend(node: Node2D) -> bool:
	return !is_enemy(node)
	
func is_enemy(node: Node2D) -> bool:
	if node.is_in_group("enemy") or node.is_in_group("object"):
		return true
	
	return false
	
func get_weapon(weapon_type: Global.WeaponType) -> BaseWeapon:
	match weapon_type:
		Global.WeaponType.PISTOL:
			return PistolWeapon.new()
		Global.WeaponType.MACHINE_GUN:
			return MachineGunWeapon.new()
		Global.WeaponType.SHOTGUN:
			return ShotgunWeapon.new()
		Global.WeaponType.ROCKET_LAUNCHER:
			return RocketLauncherWeapon.new()
			
	return null

func get_projectile_type_from_weapon_type(weapon_type: Global.WeaponType) -> Global.ProjectileType:
	match weapon_type:
		Global.WeaponType.PISTOL:
			return Global.ProjectileType.BULLET
		Global.WeaponType.MACHINE_GUN:
			return Global.ProjectileType.BULLET
		Global.WeaponType.SHOTGUN:
			return Global.ProjectileType.BULLET
		Global.WeaponType.ROCKET_LAUNCHER:
			return Global.ProjectileType.ROCKET
			
	return Global.ProjectileType.NONE

func clear_groups(node: Node2D) -> void:
	var groups = node.get_groups()
	
	for group in groups:
		node.remove_from_group(group)
		

func select_random_items(array: Array, count: int) -> Array:
	count = min(count, array.size())
	
	var shuffled = array.duplicate()
	shuffled.shuffle()
	return shuffled.slice(0, count)


func format_distance(distance: int) -> String:
	return str(distance) + "m"
	
	
func format_time(time: int) -> String:
	var total_seconds = floor(time / 1000)
	var hours = floor(total_seconds / 3600)
	var minutes = floor((total_seconds % 3600) / 60)
	var seconds = total_seconds % 60
	return "%d:%02d:%02d" % [hours, minutes, seconds]
