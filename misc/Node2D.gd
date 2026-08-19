extends Node2D

@onready var idle_music = $AudioStreamPlayer2D
@onready var save_manager = $Node
@onready var hud = $HUD

func _ready() -> void:
	if not idle_music.playing:
		idle_music.play()

	hud.money = save_manager.money
	hud.update_money_display()

	if save_manager.gravity_bullets_bought:
		$Cube.gravity_bullets_enabled = true

func stop_idle() -> void:
	if idle_music.playing:
		idle_music.stop()

func resume_idle() -> void:
	if not idle_music.playing:
		idle_music.play()
