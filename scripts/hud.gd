extends CanvasLayer

@onready var depth_label: Label = $DepthLabel
@onready var death_screen: Control = $DeathScreen
@onready var death_depth_label: Label = $DeathScreen/DepthLabel

func _ready() -> void:
	death_screen.hide()
	$DeathScreen/RestartButton.pressed.connect(_on_restart_pressed)

func update_depth(meters: float) -> void:
	depth_label.text = "%d m" % int(meters)

func show_death_screen(depth: float) -> void:
	death_depth_label.text = "%d m" % int(depth)
	death_screen.show()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
