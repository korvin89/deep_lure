class_name SpawnerManager
extends Node2D

const SPAWN_AHEAD    := 400.0   # spawn when last chunk bottom is within this distance below camera bottom
const DESPAWN_MARGIN := 200.0   # free chunk when its bottom is this far above camera top

@export var chunk_scenes: Array[PackedScene] = []

var _camera: Camera2D
var _active_chunks: Array[Node2D] = []
var _next_spawn_y    := 0.0
var _viewport_half_h := 0.0

func setup(camera: Camera2D) -> void:
	_camera = camera
	_viewport_half_h = get_viewport().get_visible_rect().size.y / 2.0
	_next_spawn_y = 400.0  # start spawning below the player (player starts at y=200)
	# fill screen immediately
	while _last_chunk_bottom_y() < _camera_bottom_y() + SPAWN_AHEAD:
		var prev_y := _next_spawn_y
		_spawn_next()
		if _next_spawn_y == prev_y:
			break

func _physics_process(_delta: float) -> void:
	if _camera == null:
		push_warning("SpawnerManager: _physics_process called before setup(camera)")
		return
	_despawn_old()
	while _last_chunk_bottom_y() < _camera_bottom_y() + SPAWN_AHEAD:
		var prev_y := _next_spawn_y
		_spawn_next()
		if _next_spawn_y == prev_y:
			break

func _spawn_next() -> void:
	if chunk_scenes.is_empty():
		return
	var scene: PackedScene = chunk_scenes.pick_random()
	var chunk: Node2D = scene.instantiate()
	get_parent().add_child(chunk)
	chunk.global_position = Vector2(0.0, _next_spawn_y)
	_active_chunks.append(chunk)
	_next_spawn_y += chunk.height

func _despawn_old() -> void:
	var threshold := _camera_top_y() - DESPAWN_MARGIN
	for chunk in _active_chunks.duplicate():
		if chunk.global_position.y + chunk.height < threshold:
			_active_chunks.erase(chunk)
			chunk.queue_free()

func _last_chunk_bottom_y() -> float:
	if _active_chunks.is_empty():
		return _next_spawn_y
	var last: Node2D = _active_chunks.back()
	return last.global_position.y + last.height

func _camera_bottom_y() -> float:
	return _camera.global_position.y + _viewport_half_h

func _camera_top_y() -> float:
	return _camera.global_position.y - _viewport_half_h
