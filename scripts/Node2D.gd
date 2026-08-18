extends Node2D

@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	if not music_player.playing:
		music_player.play()
