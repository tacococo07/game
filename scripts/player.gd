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
	print("Player ready!")

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
	cube.clear_all_bullets()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("parry") and save_manager.gravity_bullets_bought:
		print("Parry pressed!")
		try_parry()

func try_parry() -> void:
	if not cube.gravity_bullets_enabled:
		print("Gravity bullets not enabled!")
		return
	
	print("Checking for red bullets...")
	var parried = false
	var parry_pos: Vector2 = Vector2.ZERO
	
	for bullet in cube.bullets:
		if not is_instance_valid(bullet):
			continue
		
		var visual = bullet.get_child(1)
		if visual:
			print("Bullet color: ", visual.color)
			if visual.color == Color.RED:
				var distance = bullet.global_position.distance_to(global_position)
				print("Red bullet found! Distance: ", distance)
				if distance <= 100.0:
					parry_pos = bullet.global_position
					bullet.visible = false
					bullet.set_process(false)
					bullet.set_physics_process(false)
					bullet.call_deferred("queue_free")
					cube.bullets.erase(bullet)
					cube.volley_bullets.erase(bullet)
					parried = true
					print("Parry successful!")
					break
	
	if parried:
		# SPAWN RED PARTICLES at bullet position
		print("Spawning particles at: ", parry_pos)
		spawn_red_particles(parry_pos)
		
		# Reward
		var hud = get_node("../HUD")
		if hud:
			hud.money += 10
			hud.update_money_display()
		
		if save_manager:
			save_manager.money = hud.money
			save_manager.save_data()
		
		# Resume shooting immediately
		if cube.run_started:
			cube.shooting = false
			cube.volley_bullets.clear()
			await get_tree().process_frame
			if cube.run_started and not cube.shooting:
				cube.start_shooting()
	else:
		print("No red bullet found!")

func spawn_red_particles(explosion_position: Vector2) -> void:
	print("SPAWNING PARTICLES NOW!")
	
	# Create a simple sprite-based particle system for visibility
	var particles := CPUParticles2D.new()
	particles.global_position = explosion_position
	
	# --- MAKE PARTICLES VISIBLE - Use a white square with red color ---
	# Create a simple white square texture for particles
	var image := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture := ImageTexture.create_from_image(image)
	
	# Particle settings - MORE VISIBLE
	particles.amount = 60  # More particles
	particles.lifetime = 1.0
	particles.speed_scale = 2.0
	particles.one_shot = true
	particles.explosiveness = 1.0
	
	# Size - BIGGER
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 2.0
	
	# Color - BRIGHT RED
	particles.color = Color.RED
	
	# Spread
	particles.spread = 360.0
	particles.gravity = Vector2(0, -50)
	
	# Direction
	particles.direction = Vector2(0, -1)
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 300.0
	
	# Add the texture
	particles.texture = texture
	
	# Add to scene
	get_tree().current_scene.add_child(particles)
	print("Particles added to scene! Position: ", particles.global_position)
	
	# Auto-remove after particles finish
	var timer := Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	timer.timeout.connect(func(): 
		if is_instance_valid(particles):
			particles.queue_free()
			print("Particles cleaned up!")
		timer.queue_free()
	)
	get_tree().current_scene.add_child(timer)
	timer.start()
