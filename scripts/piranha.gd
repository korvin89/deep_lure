extends CharacterBody2D

const SPEED := 300.0

var _dir := 1.0  # 1 = вправо, -1 = влево

func _physics_process(_delta: float) -> void:
	velocity = Vector2(_dir * SPEED, 0.0)
	move_and_slide()
	for i in get_slide_collision_count():
		if abs(get_slide_collision(i).get_normal().x) > 0.5:
			_dir = -_dir
			break
	$Visual.scale.x = _dir

func die() -> void:
	queue_free()
