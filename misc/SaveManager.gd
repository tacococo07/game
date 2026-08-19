extends Node

const SAVE_PATH = "res://save_data.cfg"

var money: int = 0
var gravity_bullets_bought: bool = false
var retaliation_unlocked: bool = false

func _ready() -> void:
	load_data()

func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("player_data", "money", money)
	config.set_value("player_data", "gravity_bullets_bought", gravity_bullets_bought)
	config.set_value("player_data", "retaliation_unlocked", retaliation_unlocked)
	config.save(SAVE_PATH)
	print("Saved: money = ", money, ", gravity = ", gravity_bullets_bought, ", retaliation = ", retaliation_unlocked)

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		money = 0
		gravity_bullets_bought = false
		retaliation_unlocked = false
		return
	
	var config = ConfigFile.new()
	config.load(SAVE_PATH)
	money = config.get_value("player_data", "money", 0)
	gravity_bullets_bought = config.get_value("player_data", "gravity_bullets_bought", false)
	retaliation_unlocked = config.get_value("player_data", "retaliation_unlocked", false)
	print("Loaded: money = ", money, ", gravity = ", gravity_bullets_bought, ", retaliation = ", retaliation_unlocked)
