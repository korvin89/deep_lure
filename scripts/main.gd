extends Node2D

@onready var world = $World
@onready var hud = $HUD

func _ready() -> void:
	world.depth_changed.connect(hud.update_depth)
	world.player_died.connect(_on_player_died)

func _on_player_died(depth: float) -> void:
	hud.show_death_screen(depth)
