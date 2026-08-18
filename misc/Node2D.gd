extends Node2D

@onready var idle_music = $AudioStreamPlayer2D

func _ready():
	idle_music.play()

func stop_idle():
	idle_music.stop()

func resume_idle():
	if not idle_music.playing:
		idle_music.play()
