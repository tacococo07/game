extends CharacterBody2D

@export var bullet_speed: float = 300.0
@export var homing_bullet_speed: float = 220.0
@export var bullet_radius: float = 6.0
@export var spawn_distance: float = 30.0
@export var bullet_spread: float = 12.0

var player: CharacterBody2D = null

var shooting: bool = false
var run_started: bool = false

var gravity_bullets_enabled: bool = false

var bullets: Array[CharacterBody2D] = []
var volley_bullets: Array[CharacterBody2D] = []

var volley_number: int = 1
var hit_count: int = 0

@onready var run_music = $AudioStreamPlayer
@onready var shoot_sound = $ShootSound

var tail_start_time: float = 0.0
var music_total_length: float = 0.0
var is_using_tail: bool = false

@onready var save_manager = get_node("/root/Node2D/Node")

func _ready() -> void:
	$AnimatedSprite2D.stop()

	$DetectionArea.body_entered.connect(_on_player_entered)
	$AnimatedSprite2D.frame_changed.connect(_on_animation_frame_changed)

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	for bullet in bullets.duplicate():
		if not is_instance_valid(bullet):
			bullets.erase(bullet)
			volley_bullets.erase(bullet)
			continue

		var homing: bool = bullet.get_meta("homing", false)

		if homing:
			var direction: Vector2 = bullet.global_position.direction_to(player.global_position)
			bullet.global_position += direction * homing_bullet_speed * delta
		else:
			var bullet_velocity: Vector2 = bullet.get_meta("velocity", Vector2.ZERO)
			bullet.global_position += bullet_velocity * delta

			var screen_size: Vector2 = get_viewport_rect().size
			var margin: float = 100.0

			if bullet.global_position.x < -margin or bullet.global_position.x > screen_size.x + margin or bullet.global_position.y < -margin or bullet.global_position.y > screen_size.y + margin:
				bullet.queue_free()
				bullets.erase(bullet)
				volley_bullets.erase(bullet)
				check_barrage_progress()
				continue

		var distance = bullet.global_position.distance_to(player.global_position)
		if distance <= bullet_radius + 10.0:
			if gravity_bullets_enabled:
				player.apply_gravity_effect()
			
			bullet.visible = false
			bullet.set_process(false)
			bullet.set_physics_process(false)
			bullet.call_deferred("queue_free")
			
			bullets.erase(bullet)
			volley_bullets.erase(bullet)
			
			hit_count += 1

			# 🔥 RETALIATION TRIGGER — fires on EVERY hit
			if save_manager.retaliation_unlocked:
				clear_all_bullets()
			
			if hit_count >= 2:
				reset_barrage()
			else:
				check_barrage_progress()

	# --- 10-second tail loop ---
	if run_music.playing and not is_using_tail and music_total_length > 0:
		if run_music.get_playback_position() >= tail_start_time:
			is_using_tail = true
	
	if run_music.playing and is_using_tail:
		if run_music.get_playback_position() >= music_total_length:
			run_music.play(tail_start_time)


func _on_player_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Player":
		player = body

		if not run_started:
			run_started = true
			hit_count = 0
			volley_number = 1
			$"../HUD".start_run()

			if not run_music.playing:
				if run_music.stream:
					music_total_length = run_music.stream.get_length()
					tail_start_time = music_total_length - 10.0
				
				is_using_tail = false
				run_music.play()
			get_node("/root/Node2D").stop_idle()

		if not shooting and volley_bullets.is_empty():
			start_shooting()


func start_shooting() -> void:
	if player == null or not is_instance_valid(player):
		return

	shooting = true

	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("shoot")


func _on_animation_frame_changed() -> void:
	if shooting and $AnimatedSprite2D.frame == 2:
		shoot_volley()


func shoot_volley() -> void:
	shooting = false
	volley_bullets.clear()

	if not shoot_sound.playing:
		shoot_sound.play()

	var bullet_count: int

	if volley_number < 4:
		bullet_count = volley_number
	else:
		bullet_count = randi_range(1, 4)

	var homing_index: int = -1

	if bullet_count == 4:
		homing_index = randi_range(0, 3)

	for i in range(bullet_count):
		var is_homing: bool = i == homing_index
		create_bullet(is_homing, i, bullet_count)

	if volley_number < 4:
		volley_number += 1


func create_bullet(homing: bool, index: int, total_bullets: int) -> void:
	if player == null or not is_instance_valid(player):
		return

	var bullet := CharacterBody2D.new()
	bullet.name = "Bullet"
	bullet.add_to_group("bullets")

	bullet.collision_layer = 0
	bullet.collision_mask = 0

	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = bullet_radius
	collision.shape = circle
	bullet.add_child(collision)

	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-bullet_radius, 0),
		Vector2(0, -bullet_radius),
		Vector2(bullet_radius, 0),
		Vector2(0, bullet_radius)
	])

	if gravity_bullets_enabled:
		visual.color = Color.BLUE
	else:
		visual.color = Color.RED

	bullet.add_child(visual)

	get_tree().current_scene.add_child(bullet)

	var direction: Vector2 = global_position.direction_to(player.global_position)

	if total_bullets > 1:
		var center: float = float(total_bullets - 1) / 2.0
		var angle_offset: float = (float(index) - center) * bullet_spread
		direction = direction.rotated(deg_to_rad(angle_offset))

	bullet.global_position = global_position + direction * spawn_distance
	bullet.set_meta("homing", homing)

	if homing:
		bullet.set_meta("velocity", Vector2.ZERO)
	else:
		bullet.set_meta("velocity", direction * bullet_speed)

	bullets.append(bullet)
	volley_bullets.append(bullet)


func check_barrage_progress() -> void:
	for bullet in volley_bullets:
		if is_instance_valid(bullet):
			if not bullet.get_meta("homing", false):
				return

	volley_bullets.clear()

	if player != null and is_instance_valid(player) and run_started:
		start_shooting()


func reset_barrage() -> void:
	shooting = false

	volley_number = 1
	hit_count = 0

	if run_music.playing:
		run_music.stop()
		is_using_tail = false
	get_node("/root/Node2D").resume_idle()

	clear_all_bullets()

	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.frame = 0

	if run_started:
		$"../HUD".end_run()

	run_started = false


func clear_all_bullets() -> void:
	for bullet in bullets:
		if is_instance_valid(bullet):
			bullet.visible = false
			bullet.set_process(false)
			bullet.set_physics_process(false)
			bullet.call_deferred("queue_free")
	bullets.clear()
	volley_bullets.clear()
