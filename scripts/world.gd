extends Node2D

const DESCENT_SPEED := 200.0
const LOOKAHEAD := 400.0       # камера смотрит на 400px ниже игрока
const CAM_FOLLOW := 5.0        # скорость следования камеры

@onready var player:  CharacterBody2D = $Player
@onready var camera:  Camera2D        = $Camera2D
@onready var spawner: SpawnerManager  = $SpawnerManager

var start_y: float = 0.0

signal depth_changed(meters: float)
signal player_died(depth: float)

func _ready() -> void:
	start_y = player.global_position.y
	player.descent_speed = DESCENT_SPEED
	# Установить камеру сразу в правильную позицию без рывка
	camera.position = Vector2(540.0, player.global_position.y + LOOKAHEAD)
	player.died.connect(_on_player_died)
	spawner.setup(camera)

func _process(delta: float) -> void:
	if player.dead:
		return
	# X фиксирован, Y плавно следует за игроком с опережением
	camera.position.x = 540.0
	camera.position.y = lerp(camera.position.y,
			player.global_position.y + LOOKAHEAD,
			minf(CAM_FOLLOW * delta, 1.0))
	depth_changed.emit(_get_depth())

func _get_depth() -> float:
	return maxf(0.0, (player.global_position.y - start_y) / 10.0)

func _on_player_died() -> void:
	player_died.emit(_get_depth())
