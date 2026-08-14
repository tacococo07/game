extends CharacterBody2D

@export var bullet_speed: float = 300.0
@export var homing_bullet_speed: float = 220.0
@export var bullet_radius: float = 6.0
@export var spawn_distance: float = 30.0
@export var bullet_spread: float = 12.0

var player: CharacterBody2D = null

var shooting: bool = false
var run_started: bool = false

var bullets: Array[Area2D] = []
var volley_bullets: Array[Area2D] = []

var volley_number: int = 1
var hit_count: int = 0


func _ready() -> void:
	$AnimatedSprite2D.stop()

	$DetectionArea.body_entered.connect(_on_player_entered)
	$AnimatedSprite2D.frame_changed.connect(_on_animation_frame_changed)


func _process(delta: float) -> void:
	for bullet in bullets.duplicate():

		if not is_instance_valid(bullet):
			bullets.erase(bullet)
			volley_bullets.erase(bullet)
			continue

		if player == null or not is_instance_valid(player):
			continue

		var homing: bool = bullet.get_meta("homing", false)

		# HOMING BULLET
		if homing:

			var direction: Vector2 = bullet.global_position.direction_to(
				player.global_position
			)

			bullet.global_position += direction * homing_bullet_speed * delta

		# NORMAL BULLET
		else:

			var velocity: Vector2 = bullet.get_meta(
				"velocity",
				Vector2.ZERO
			)

			bullet.global_position += velocity * delta

			# Delete normal bullets when they leave the screen.
			var screen_size: Vector2 = get_viewport_rect().size
			var margin: float = 100.0

			if (
				bullet.global_position.x < -margin
				or bullet.global_position.x > screen_size.x + margin
				or bullet.global_position.y < -margin
				or bullet.global_position.y > screen_size.y + margin
			):
				bullet.queue_free()

				bullets.erase(bullet)
				volley_bullets.erase(bullet)

				check_barrage_progress()

				continue

		# CHECK FOR PLAYER HIT
		if (
			is_instance_valid(bullet)
			and bullet.global_position.distance_to(
				player.global_position
			) <= bullet_radius + 10.0
		):
			bullet.queue_free()

			bullets.erase(bullet)
			volley_bullets.erase(bullet)

			hit_count += 1

			# SECOND HIT = END THE RUN
			if hit_count >= 2:
				reset_barrage()
			else:
				check_barrage_progress()


func _on_player_entered(body: Node2D) -> void:

	if body is CharacterBody2D and body.name == "Player":

		player = body

		# First touch starts a completely new run.
		if not run_started:

			run_started = true

			$"../HUD".start_run()

			hit_count = 0
			volley_number = 1

		# Start the barrage if the cube isn't already firing.
		if not shooting and volley_bullets.is_empty():
			start_shooting()


func start_shooting() -> void:

	if player == null or not is_instance_valid(player):
		return

	shooting = true

	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("shoot")


func _on_animation_frame_changed() -> void:

	# Frame 3 is index 2.
	if shooting and $AnimatedSprite2D.frame == 2:
		shoot_volley()


func shoot_volley() -> void:

	shooting = false

	volley_bullets.clear()

	var bullet_count: int

	# 1 -> 2 -> 3
	if volley_number < 4:

		bullet_count = volley_number

	# After that, random 1 -> 4
	else:

		bullet_count = randi_range(1, 4)

	# If there are exactly 4 bullets,
	# choose ONE to be homing.
	var homing_index: int = -1

	if bullet_count == 4:
		homing_index = randi_range(0, 3)

	for i in range(bullet_count):

		var is_homing: bool = i == homing_index

		create_bullet(
			is_homing,
			i,
			bullet_count
		)

	# Progress toward the random stage.
	if volley_number < 4:
		volley_number += 1


func create_bullet(
	homing: bool,
	index: int,
	total_bullets: int
) -> void:

	if player == null or not is_instance_valid(player):
		return

	var bullet := Area2D.new()

	bullet.name = "Bullet"

	# Don't let the bullet collide with the cube.
	bullet.collision_layer = 0
	bullet.collision_mask = 1

	# Collision shape.
	var collision := CollisionShape2D.new()

	var circle := CircleShape2D.new()
	circle.radius = bullet_radius

	collision.shape = circle

	bullet.add_child(collision)

	# Red temporary bullet visual.
	var visual := Polygon2D.new()

	visual.polygon = PackedVector2Array([
		Vector2(-bullet_radius, 0),
		Vector2(0, -bullet_radius),
		Vector2(bullet_radius, 0),
		Vector2(0, bullet_radius)
	])

	visual.color = Color.RED

	bullet.add_child(visual)

	get_tree().current_scene.add_child(bullet)

	# Aim toward where the player is NOW.
	var direction: Vector2 = global_position.direction_to(
		player.global_position
	)

	# Spread bullets apart.
	if total_bullets > 1:

		var center: float = float(total_bullets - 1) / 2.0

		var angle_offset: float = (
			float(index) - center
		) * bullet_spread

		direction = direction.rotated(
			deg_to_rad(angle_offset)
		)

	# Spawn outside the cube.
	bullet.global_position = (
		global_position
		+ direction * spawn_distance
	)

	# Remember whether this bullet is homing.
	bullet.set_meta(
		"homing",
		homing
	)

	if homing:

		bullet.set_meta(
			"velocity",
			Vector2.ZERO
		)

	else:

		bullet.set_meta(
			"velocity",
			direction * bullet_speed
		)

	bullets.append(bullet)
	volley_bullets.append(bullet)


func check_barrage_progress() -> void:

	# Wait for normal bullets from the current volley.
	#
	# Homing bullets DON'T count here.
	for bullet in volley_bullets:

		if is_instance_valid(bullet):

			if not bullet.get_meta(
				"homing",
				false
			):
				return

	# All normal bullets are gone.
	#
	# Any homing bullets are allowed to keep chasing
	# while the next volley begins.
	volley_bullets.clear()

	if (
		player != null
		and is_instance_valid(player)
		and run_started
	):
		start_shooting()


func reset_barrage() -> void:

	# Stop the barrage.
	shooting = false

	# Reset progression.
	volley_number = 1
	hit_count = 0

	# Delete ALL active bullets,
	# including homing bullets.
	for bullet in bullets:

		if is_instance_valid(bullet):
			bullet.queue_free()

	bullets.clear()
	volley_bullets.clear()

	# Reset cube animation.
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.frame = 0

	# End the timer and calculate money.
	if run_started:
		$"../HUD".end_run()

	# The player must touch the cube again.
	run_started = false
