extends Node

const SAVE_PATH = "user://save_data.cfg"

var money: int = 0
var gravity_bullets_bought: bool = false

func _ready() -> void:
	load_data()

func save_data() -> void:
	var config = ConfigFile.new()
	
	config.set_value("player_data", "money", money)
	config.set_value("player_data", "gravity_bullets_bought", gravity_bullets_bought)
	
	config.save(SAVE_PATH)

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		# No save file yet — default values
		money = 0
		gravity_bullets_bought = false
		return
	
	var config = ConfigFile.new()
	config.load(SAVE_PATH)
	
	money = config.get_value("player_data", "money", 0)
	gravity_bullets_bought = config.get_value("player_data", "gravity_bullets_bought", false)
