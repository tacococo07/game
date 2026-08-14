extends CharacterBody2D

@export var speed: float = 5000.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _physics_process(_delta: float) -> void:
	var target: Vector2 = get_global_mouse_position()
	var distance: float = global_position.distance_to(target)

	if distance > 1.0:
		var direction: Vector2 = global_position.direction_to(target)
		var motion: Vector2 = direction * min(speed * _delta, distance)
		move_and_collide(motion)
