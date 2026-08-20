extends CharacterBody2D

@export var mouse_follow_speed: float = 1000.0
@export var gravity_strength: float = 900.0
@export var gravity_duration: float = 10.0

var gravity_active: bool = false
var gravity_timer: float = 0.0

@onready var cube: CharacterBody2D = $"../Cube"
@onready var save_manager = get_node("/root/Node2D/Node")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _physics_process(delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()

	if not cube.run_started and not cube.shooting:
		gravity_active = false
		gravity_timer = 0.0
		velocity = Vector2.ZERO

	if gravity_active:
		gravity_timer -= delta
		var x_difference: float = mouse_position.x - global_position.x
		velocity.x = x_difference * 20.0
		velocity.y += gravity_strength * delta
		move_and_slide()
		if gravity_timer <= 0.0:
			gravity_active = false
			velocity = Vector2.ZERO
	else:
		var difference: Vector2 = mouse_position - global_position
		velocity = difference * 20.0
		move_and_slide()

func apply_gravity_effect() -> void:
	gravity_active = true
	gravity_timer = gravity_duration
	velocity.y = 0.0
	trigger_retaliation()

func trigger_retaliation() -> void:
	if not save_manager.retaliation_unlocked:
		return

	# Destroy all bullets in the "bullets" group
	var bullets = get_tree().get_nodes_in_group("bullets")
	for bullet in bullets:
		if is_instance_valid(bullet):
			bullet.queue_free()
