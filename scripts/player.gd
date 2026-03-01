extends CharacterBody2D

const HORIZONTAL_SPEED := 400.0
const DASH_TIME        := 0.12   # секунд на перемещение к цели
const DASH_OFFSET      := 40.0   # останавливаемся на 40px от поверхности
const DASH_RANGE       := 600.0  # максимальная дальность горизонтального дэша
const COOLDOWN         := 1.0

var descent_speed := 200.0
var dead := false
var cooldown_remaining := 0.0

enum State { DESCENDING, PULLING }
var state := State.DESCENDING

var _dash_from := Vector2.ZERO
var _dash_to   := Vector2.ZERO
var _dash_t    := 0.0

@onready var visual: Polygon2D = $Visual

signal died

func _physics_process(delta: float) -> void:
	if dead:
		return
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)
	_update_visual()
	match state:
		State.DESCENDING:
			var h := Input.get_axis("ui_left", "ui_right")
			velocity = Vector2(h * HORIZONTAL_SPEED, descent_speed)
			move_and_slide()
			_check_lethal_collision()
		State.PULLING:
			_dash_t = minf(_dash_t + delta / DASH_TIME, 1.0)
			var ease_t := 1.0 - (1.0 - _dash_t) * (1.0 - _dash_t)
			global_position.x = lerpf(_dash_from.x, _dash_to.x, ease_t)
			global_position.y = lerpf(_dash_from.y, _dash_to.y, ease_t) \
				+ descent_speed * _dash_t * DASH_TIME
			if _dash_t >= 1.0:
				_end_pull()

func _unhandled_input(event: InputEvent) -> void:
	if dead or state != State.DESCENDING or cooldown_remaining > 0.0:
		return
	if event is InputEventKey and event.keycode == KEY_SPACE \
			and event.pressed and not event.echo:
		var kb_dir := Input.get_axis("ui_left", "ui_right")
		if kb_dir != 0.0:
			_try_dash(Vector2(sign(kb_dir), 0.0))
		else:
			_try_dash(Vector2(0.0, 1.0))

func _try_dash(dir: Vector2) -> void:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position, global_position + dir * DASH_RANGE)
	query.exclude = [get_rid()]
	var result := space.intersect_ray(query)
	if dir.y > 0.0:
		# Дэш вниз: работает всегда — к препятствию или на полную дальность
		var target_y: float = result.position.y - DASH_OFFSET if result else global_position.y + DASH_RANGE
		_start_dash(Vector2(global_position.x, target_y))
	else:
		# Горизонтальный дэш: только если есть стена
		if result:
			var target_x: float = result.position.x - sign(dir.x) * DASH_OFFSET
			_start_dash(Vector2(target_x, global_position.y))
		else:
			_start_cooldown()

func _start_dash(target: Vector2) -> void:
	state = State.PULLING
	_dash_from = global_position
	_dash_to   = target
	_dash_t    = 0.0

func _end_pull() -> void:
	if dead:
		return
	velocity = Vector2(0.0, descent_speed)
	state = State.DESCENDING
	_start_cooldown()

func _check_lethal_collision() -> void:
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider().is_in_group("lethal"):
			_die()
			return

func _start_cooldown() -> void:
	cooldown_remaining = COOLDOWN

func _update_visual() -> void:
	var can_fire := state == State.DESCENDING and cooldown_remaining <= 0.0
	visual.color = Color(0.2, 0.6, 1.0, 1.0) if can_fire else Color(0.4, 0.4, 0.5, 1.0)

func _die() -> void:
	if dead:
		return
	dead = true
	died.emit()
